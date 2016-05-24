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
	unsigned __int32 dnPoints[400]; // the points with color bit values x&y
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


void XYcolors(
	VideoRec &curframe,					// inputs
	double &Xpb, double &Ypb, double &Xpr, double &Ypr)	// outputs
{
	__int32 BLUE_MASK = VREC_PB_MASK; // pure blue
	__int32 RED_MASK  = VREC_PR_MASK; // pure red

	double SxB = 0, SyB = 0, nTB = 0;
	double SxR = 0, SyR = 0, nTR = 0;

	// mean of all targets
	for (int iT = 0; iT<50; iT++) {
		if (curframe.targets[iT] & BLUE_MASK) {
			SxB += (float) getX(curframe.targets[iT]);
			SyB += (float) getY(curframe.targets[iT]);
			nTB += 1;	
		}
		if (curframe.targets[iT] & RED_MASK) { // red LEDs also signal as green
			SxR += (float) getX(curframe.targets[iT]);
			SyR += (float) getY(curframe.targets[iT]);
			nTR += 1;	
		}
	}
	Xpb = SxB / nTB;
	Ypb = SyB / nTB;
	Xpr = SxR / nTR;
	Ypb = SyR / nTR;

}


/*-----------------------------------
 * main MEX function
 -----------------------------------*/
 void mexFunction(
			int nOUT, mxArray *pOUT[],
			int nINP, const mxArray *pINP[])
{

  double *ts = NULL, *xPB = NULL, *yPB = NULL, *xPR = NULL, *yPR = NULL;
  struct VideoRec curframe;
  double tsi, xBi, yBi, xRi, yRi;

  /* check number of arguments: expects 2 inputs, 1 output */
  if (nINP != 1)
    mexErrMsgTxt("Call with filename as inputs.");
  if (nOUT != 1 && nOUT != 5)
    mexErrMsgTxt("Call as TS=LoadVT1_boom(fn); [TS,Xblue,Yblue,Xred,Yred]=LoadVT1_boom(fn).");

  // open input
  if (!mxIsChar(pINP[0])) mexErrMsgTxt("Input must be a string.");
  char *fn_in = mxArrayToString(pINP[0]);
  FILE *fp = fopen(fn_in, "rb");
  if (!fp) mexErrMsgTxt("Cannot open input file.");

  // Find nFrames
  ReadHeader(fp);
  long postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
  fseek(fp,0,SEEK_END);                     // goto end of file
  int nFrames = (ftell(fp) - postHeaderPos)/sizeof(struct VideoRec);
  fseek(fp,postHeaderPos,SEEK_SET);

  // Allocate outputs
  // nOUT == any
  ts = mxGetPr(pOUT[0]= mxCreateDoubleMatrix(1, nFrames, mxREAL));
  // nOUT == 5
  if (nOUT > 1) {
	  xPB = mxGetPr(pOUT[1] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
	  yPB = mxGetPr(pOUT[2] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
	  xPR = mxGetPr(pOUT[3] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
	  yPR = mxGetPr(pOUT[4] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
  };

  // Read records
  for (int iFrame=0; iFrame < nFrames; iFrame++) {
	  // read next record
      fread(&curframe, sizeof(curframe), 1, fp);

      // checks

	  // get x,y,phi
	  tsi = (double) curframe.qwTimeStamp/1.0;
	  XYcolors(curframe, xBi, yBi, xRi, yRi);
	  
	  // fill variables
	  switch (nOUT) {
		case 5:
			xPB[iFrame] = xBi;
			yPB[iFrame] = yBi;
			xPR[iFrame] = xRi;
			yPR[iFrame] = yRi;
		case 1:
			ts[iFrame] = tsi;
	  };

	}

  // Close I/O files
  if (fp) fclose(fp);
  mxFree(fn_in);
}