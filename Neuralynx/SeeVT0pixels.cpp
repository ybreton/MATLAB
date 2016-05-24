//--------------------------------
// LoadVT - Read video tracker file
// 
// ADR 2001
//
//
// Reads in video records stored by cheetah.
//
// Version 1.0.
// MEX File 
// 
// inputs -- 
//		fn: filename
// outputs --  
//		ts: timestamps
//		x: x coordinates
//		y: y coordinates
//		phi: heading direction
//
// Algorithm:
//     Find centroid of red LEDs, find centroid of green LEDs,
//     <x,y> = mean of centroids
//     phi = arctan of C_r and C_g
//
// Status:
//
//------------------------------------

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#include "mex.h"
#include <matrix.h>

#pragma pack(1) // necessary for correct alignment of VideoRec
struct VideoRec {
	short nstx; // should be 800 as from the DCDCB
	short nid; // should be 0x1000 or 0x1001 as from the DCDCB
	short ndata_size; // should be 800 as from the DCDCB
	__int64 qwTimeStamp; // TS
	__int32 dnPoints[400]; // the points with color bit values x&y
	short ncrc; // as from the dcdcb
	__int32 nextracted_x; // from nlx extraction algorithm
	__int32 nextracted_y; // from nlx extraction algorithm
	__int32 nextracted_angle; // from nlx extraction algorithm
	__int32 targets[50]; // colored targets with same format as the points
}; 

const unsigned int VREC_LU_MASK = 0x8000; //luminance mask
const unsigned int VREC_RR_MASK = 0x4000; //pure & raw RGB masks
const unsigned int VREC_RG_MASK = 0x2000;
const unsigned int VREC_RB_MASK = 0x1000;
const unsigned int VREC_PR_MASK = 0x40000000;
const unsigned int VREC_PG_MASK = 0x20000000;
const unsigned int VREC_PB_MASK = 0x10000000;
const unsigned int VREC_RS_MASK = 0x80000000; //reserved bit mask 
const unsigned int VREC_X_MASK = 0x00000FFF; //x value mask
const unsigned int VREC_Y_MASK = 0x0FFF0000; //y val
const unsigned int VREC_Y_SHFT = 16;

const double version = 1.0;

//---------------------------------------------
// Library functions
inline bool STREQ(const char *a, const char *b)
{
	if (strcmp(a,b)==0) return true; else return false;
}



// ReadHeader -- Reads Neuralynx header
bool ReadHeader(FILE *fp)
{
	char buffer[16385];
	rewind(fp);
	fread(buffer, 1, 16384, fp);
	if (strncmp(buffer, "########", 8))				// not equal
		{rewind(fp);return false;}
	return true;

}

//----------------------------------------------
__int32 getX(__int32 target)
{return (target & VREC_X_MASK);}

__int32 getY(__int32 target)
{return ((target & VREC_Y_MASK) >> VREC_Y_SHFT);}

/*-----------------------------------
 * Get all targets
 -----------------------------------*/
void GetXYcolors(
	VideoRec &curframe,					// inputs
	double *BlueTargetsX, double *BlueTargetsY,
	double *RedTargetsX, double *RedTargetsY,
	double *LumTargetsX, double *LumTargetsY) // outputs
{
	__int32 BLUE_MASK = VREC_PB_MASK; // pure blue
	__int32 RED_MASK  = VREC_PR_MASK; // pure red
	__int32 LUM_MASK  = VREC_LU_MASK; // pure red

	for (int iT = 0; iT < 400; iT++) {
	    if (curframe.dnPoints[iT] & BLUE_MASK) {
	      BlueTargetsX[iT] = (double) getX(curframe.dnPoints[iT]);
	      BlueTargetsY[iT] = (double) getY(curframe.dnPoints[iT]);
	    } else {
	      BlueTargetsX[iT] = mxGetNaN();
	      BlueTargetsY[iT] = mxGetNaN();
	    };
	    if (curframe.dnPoints[iT] & RED_MASK) {
	      RedTargetsX[iT] = (double) getX(curframe.dnPoints[iT]);
	      RedTargetsY[iT] = (double) getY(curframe.dnPoints[iT]);
	    } else {
	      RedTargetsX[iT] = mxGetNaN();
	      RedTargetsY[iT] = mxGetNaN();
	    };
	   if (curframe.dnPoints[iT] & LUM_MASK) {
	      LumTargetsX[iT] = (double) getX(curframe.dnPoints[iT]);
	      LumTargetsY[iT] = (double) getY(curframe.dnPoints[iT]);
	    } else {
	      LumTargetsX[iT] = mxGetNaN();
	      LumTargetsY[iT] = mxGetNaN();
	    };
	 };
}


/*-----------------------------------
 * main MEX function
 -----------------------------------*/
 void mexFunction(
			int nOUT, mxArray *pOUT[],
			int nINP, const mxArray *pINP[])
{

  double *ts = NULL, *xPB = NULL, *yPB = NULL, *xPR = NULL, *yPR = NULL, *xLU = NULL, *yLU = NULL;
  struct VideoRec curframe;
  int startFrame = -1, endFrame = -1;
  
  
  /* check number of arguments: expects 1 input, 6 outputs */
  if (!(nINP==1 || nINP==3))
   mexErrMsgTxt("Call as SeeVT0(fn) or SeeVT0(fn,startFrame,endFrame).");

  if (nOUT != 1 && nOUT != 7)
    mexErrMsgTxt("Call as TS=SeeVT0(fn); [TS,Xblue,Yblue,Xred,Yred,Xlum,Ylum]=SeeVT0(fn).");

  // open input
  if (!mxIsChar(pINP[0])) mexErrMsgTxt("Input must be a string.");
  char *fn_in = mxArrayToString(pINP[0]);
  if (nINP==3) {
      startFrame = (*mxGetPr(pINP[1]))-1;
      endFrame = (*mxGetPr(pINP[2]))-1;
      };
  FILE *fp = fopen(fn_in, "rb");
  if (!fp) mexErrMsgTxt("Cannot open input file.");

  // Find nFrames
  ReadHeader(fp);
  long postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
  fseek(fp,0,SEEK_END);                     // goto end of file
  int nFrames = (ftell(fp) - postHeaderPos)/sizeof(struct VideoRec);
  fseek(fp,postHeaderPos,SEEK_SET);

  if (startFrame < 0) startFrame = 0;
  if (endFrame < 0) endFrame = nFrames;
  nFrames = endFrame - startFrame + 1;
  //mexPrintf("nFrames = %d\n", nFrames);
  
  // Allocate outputs
  // nOUT == any
  ts = mxGetPr(pOUT[0]= mxCreateDoubleMatrix(1, nFrames, mxREAL));
  //mexPrintf("At 1.\n");
  // nOUT == 5
  if (nOUT > 1) {
	  xPB = mxGetPr(pOUT[1] = mxCreateDoubleMatrix(400, nFrames, mxREAL));
	  yPB = mxGetPr(pOUT[2] = mxCreateDoubleMatrix(400, nFrames, mxREAL));
	  xPR = mxGetPr(pOUT[3] = mxCreateDoubleMatrix(400, nFrames, mxREAL));
	  yPR = mxGetPr(pOUT[4] = mxCreateDoubleMatrix(400, nFrames, mxREAL));
	  xLU = mxGetPr(pOUT[5] = mxCreateDoubleMatrix(400, nFrames, mxREAL));
	  yLU = mxGetPr(pOUT[6] = mxCreateDoubleMatrix(400, nFrames, mxREAL));
	  if (!xPB | !yPB | !xPR | !yPR | !xLU | !yLU)
	    mexErrMsgTxt("Not all outputs allocated.");
  };
  //mexPrintf("At 2.\n");

  // Read records
  for (int iFrame = 0; iFrame <= endFrame; iFrame++) {
      //mexPrintf("At 3: iFrame = %d (c=%d) ", iFrame+1, iFrame);
      
	  // read next record
      fread(&curframe, sizeof(curframe), 1, fp);

      // checks

      if (iFrame < startFrame) {
        //mexPrintf(" skipping...\n");
      } else {
        //mexPrintf(" (@ %d) \n", iFrame-startFrame);
        ts[iFrame-startFrame] = (double) curframe.qwTimeStamp/1.0;	
        if (nOUT > 1) {
	       GetXYcolors(curframe, 
	         xPB+((iFrame-startFrame)*400), yPB+((iFrame-startFrame)*400),
	         xPR+((iFrame-startFrame)*400), yPR+((iFrame-startFrame)*400),
	         xLU+((iFrame-startFrame)*400), yLU+((iFrame-startFrame)*400));
	    }
	  }
}

  // Close I/O files
  if (fp) fclose(fp);
  mxFree(fn_in);
}