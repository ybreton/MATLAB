//--------------------------------
// LoadEP - Read event packet file
// 
// ADR 2001
//
//
// Reads in event packets stored by cheetah.
//
// Version 1.0.
// MEX File 
// 
// inputs -- 
//		fn: filename
// outputs --  
//		ts: timestamps (array of timestamps 1xn)
//		ttl: TTL at each event (array of 1xn)
//		ev: event string at each event (array of 128xn)
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

#pragma pack(1) // necessary for correct alignment
struct EventRec {
	__int16 PktStart; // 0x0800
	__int16 PktID;    // 0x1002
	__int16 PktDataSize;
	__int64 qwTimeStamp; // TS
	__int16 EventID;
	unsigned __int16 TTL;
	__int16 CRC;
	__int32 Dummy;
	__int32 Extra[8];
	char EventString[128];
}; 

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

/*-----------------------------------
 * main MEX function
 -----------------------------------*/
 void mexFunction(
			int nOUT, mxArray *pOUT[],
			int nINP, const mxArray *pINP[])
{

  double *ts = NULL;
  double *ttl = NULL;
  double *evs = NULL;

  int iC;

  struct EventRec curframe;

  /* check number of arguments: expects 2 inputs, 1 output */
  if (nINP != 1)
    mexErrMsgTxt("Call with filename as inputs.");
  if (nOUT != 1 && nOUT != 2 && nOUT != 3)
    mexErrMsgTxt("Call as TS=LoadEP0(fn); [TS,TTL]=LoadEP0(fn); [TS,TTL,EVS]=LoadEP0(fn).");

  // open input
  if (!mxIsChar(pINP[0])) mexErrMsgTxt("Input must be a string.");
  char *fn_in = mxArrayToString(pINP[0]);
  FILE *fp = fopen(fn_in, "rb");
  if (!fp) mexErrMsgTxt("Cannot open input file.");

  // Find nFrames
  ReadHeader(fp);
  long postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
  fseek(fp,0,SEEK_END);                     // goto end of file
  int nFrames = (ftell(fp) - postHeaderPos)/sizeof(struct EventRec);
  fseek(fp,postHeaderPos,SEEK_SET);

  // Allocate outputs
  // nOUT == any
  ts = mxGetPr(pOUT[0]= mxCreateDoubleMatrix(1, nFrames, mxREAL));
  // nOUT == 2 or 3
  if (nOUT > 1) 
	  ttl = mxGetPr(pOUT[1] = mxCreateDoubleMatrix(1, nFrames, mxREAL));
  // nOUT == 3
  if (nOUT > 2) 
	  evs = mxGetPr(pOUT[2] = mxCreateDoubleMatrix(128, nFrames, mxREAL));

  // Read records
  for (int iFrame=0; iFrame < nFrames; iFrame++) {
	  // read next record
      fread(&curframe, sizeof(curframe), 1, fp);

      // checks

	  // fill variables
	  switch (nOUT) {
		case 3:
			for (iC = 0; iC<128; iC++)
				evs[iFrame*128 + iC] = curframe.EventString[iC];
		case 2:
			ttl[iFrame] = (double) curframe.TTL;
		case 1:
			ts[iFrame] = (double) curframe.qwTimeStamp/1.0;
	  };

	}

  // Close I/O files
  if (fp) fclose(fp);
  mxFree(fn_in);
}