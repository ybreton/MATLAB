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
//  Modified 2/11/2011 Andy Papale and Nate J. Powell.  Added a not operator (!) on line 112.  This code now loads all video tracker data EXCEPT that
//  specified by the limits:
//
//  xm = x-coordinate minimum
//  ym = y-coordinate minimum
//  Xm = x maximum
//  Ym = y maximum
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


void XYP(
	VideoRec &curframe,					// inputs
	double &X, double &Y, double &PHI, 	// outputs
    double xm, double xM, double ym, double yM) // restriction
{
	__int32 FRONT_MASK = VREC_PR_MASK; // pure red
	__int32 BACK_MASK  = VREC_RG_MASK; // raw green
	__int32 LUM_MASK  = VREC_LU_MASK; // luminance
	__int32 RR_MASK  = VREC_RR_MASK; // raw and pure RGB

	double Sxf = 0, Syf = 0, nTf = 0;
	double Sxb = 0, Syb = 0, nTb = 0;

	// mean of all targets
	for (int iT = 0; iT<50; iT++) 
		// Not operator added here to 'cut out' a portion of video tracker code.  2/11/2011.
       if (!((getX(curframe.targets[iT]) > xm) &&  
           (getX(curframe.targets[iT]) < xM) &&
           (getY(curframe.targets[iT]) > ym) &&
           (getY(curframe.targets[iT]) < yM)))
       {
		if (curframe.targets[iT] & FRONT_MASK) {
			Sxf += (float) getX(curframe.targets[iT]);
			Syf += (float) getY(curframe.targets[iT]);
			nTf += 1;	
		}
		if (curframe.targets[iT] & BACK_MASK) { // red LEDs also signal as green
			Sxb += (float) getX(curframe.targets[iT]);
			Syb += (float) getY(curframe.targets[iT]);
			nTb += 1;	
		}
		if (curframe.targets[iT] & LUM_MASK) { 
			Sxb += (float) getX(curframe.targets[iT]);
			Syb += (float) getY(curframe.targets[iT]);
			nTb += 1;	
		}
		if (curframe.targets[iT] & RR_MASK) { 
			Sxb += (float) getX(curframe.targets[iT]);
			Syb += (float) getY(curframe.targets[iT]);
			nTb += 1;	
		}
	};
	X = (Sxf + Sxb) / (nTf + nTb);
	Y = (Syf + Syb) / (nTf + nTb);
	PHI = atan2(Syf/nTf - Syb/nTb, Sxf/nTf - Sxb/nTb);
}


/*-----------------------------------
 * main MEX function
 -----------------------------------*/
 void mexFunction(
			int nOUT, mxArray *pOUT[],
			int nINP, const mxArray *pINP[])
{

  double *ts = NULL, *x = NULL, *y = NULL, *phi = NULL;
  double *xm = NULL, *xM = NULL, *yM = NULL, *ym = NULL;
  struct VideoRec curframe;
  double tsi, xi, yi, phii;
  
  /* check number of arguments: expects 5 inputs, 1 output */
  if (nINP != 5)
    mexErrMsgTxt("Call with filename and restriction (xm, xM, ym, yM) as inputs. \n");
  if (nOUT != 1 && nOUT != 3 && nOUT != 4)
    mexErrMsgTxt("Call as TS=LoadVT0(fn); [TS,X,Y]=LoadVT0(fn); [TS,X,Y,PHI]=LoadVT0(fn). \n");

  // open input
  if (!mxIsChar(pINP[0])) mexErrMsgTxt("Input must be a string.");
  char *fn_in = mxArrayToString(pINP[0]);
  FILE *fp = fopen(fn_in, "rb");
  if (!fp) mexErrMsgTxt("Cannot open input file.");

  // restriction
  for (int iC = 1; iC<5; iC++)
      if (!mxIsNumeric(pINP[iC])) mexErrMsgTxt("Inputs 2-5 must be numeric.");
  xm = (double *) mxGetPr(pINP[1]);
  xM = (double *) mxGetPr(pINP[2]);
  ym = (double *) mxGetPr(pINP[3]);
  yM = (double *) mxGetPr(pINP[4]);
  //mexPrintf("Removing %.0f < x < %.0f && %.0f < y < %.0f from video tracker file \n", *xm, *xM, *ym, *yM);
  
  // Find nFrames
  ReadHeader(fp);
  long postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
  fseek(fp,0,SEEK_END);                     // goto end of file
  int nFrames = (ftell(fp) - postHeaderPos)/sizeof(struct VideoRec);
  fseek(fp,postHeaderPos,SEEK_SET);

  // Allocate outputs
  // nOUT == any
  ts = mxGetPr(pOUT[0]= mxCreateDoubleMatrix(1, nFrames, mxREAL));
  // nOUT == 3 or 4
  if (nOUT > 1) {
	  x = mxGetPr(pOUT[1] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
	  y = mxGetPr(pOUT[2] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
  };
  // nOUT = 4
  if (nOUT == 4) 
	  phi = mxGetPr(pOUT[3] = mxCreateDoubleMatrix(1, nFrames, mxREAL));

  // Read records
  for (int iFrame=0; iFrame < nFrames; iFrame++) {
	  // read next record
      fread(&curframe, sizeof(curframe), 1, fp);

      // checks

	  // get x,y,phi
	  tsi = (double) curframe.qwTimeStamp/1.0;
	  XYP(curframe, xi, yi, phii, *xm, *xM, *ym, *yM);
	  
	  // fill variables
	  switch (nOUT) {
		case 4:
			phi[iFrame] = phii;
		case 3:
			x[iFrame] = xi;
			y[iFrame] = yi;
		case 1:
			ts[iFrame] = tsi;
	  };

	}

  // Close I/O files
  if (fp) fclose(fp);
  mxFree(fn_in);
}