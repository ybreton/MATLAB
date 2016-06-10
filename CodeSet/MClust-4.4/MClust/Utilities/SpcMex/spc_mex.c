/* Performs a superparamagnetic-inspired hierarchical clustering algorithm
 *  on multidimensional samples.
 *
 * USAGE
 *
 *      [C, P] = spc_mex(D)
 *
 * Compile with:
 *
 *      mex spc_mex.c SPC.c MergeSort.c L.c FAIRSPLIT.c ALGRAPH.c
 *
 * INPUT
 *  D - Ndimensions-by-Npoints array of feature data
 *
 * OUTPUT
 *  C - The clusters.  Cell array of #clusters vectors, where each vector 
 *      contains a list of indexes of points in D which are in that cluster
 *  P - Cluster parents.  Cluster i's parent cluster is C{P(i)}
 *
 * SETTINGS
 *  MIN_CLUS_SIZE - minimum cluster size to consider.
 *  NMC - number of max-size clusters to consider
 *  K - number of K-nearest neighbors to use
 *
 * This is a MEX file for MATLAB.
 *
 * Brendan Hasz
 * haszx010@umn.edu
 * Feb 2016
 * David Redish Lab, University of Minnesota, Twin Cities
 */

#include "mex.h"
#include <stdint.h>
#include "SPC.h"

#define MIN_CLUS_SIZE 50
#define NMC 20
#define K 11

/* MATLAB MEX FUNCTION: [C, P] = spc_mex(D) */
void mexFunction( int nlhs, mxArray *plhs[], 
                  int nrhs, const mxArray * prhs[])
{
    // Declare variables
    double * Dm;//the data in matlab
    edge_t * D; //the data 
    nid_t n,i,j;//number of points
    int d;      //number of dimensions
    int Nc;     //number of clusters found by SPC
    nid_t * Cn; //number of points in each cluster (length Nc vector)
    nid_t ** hC;//list of clusterid lists
    nid_t * P;  //parent cluster id of each cluster
    int * dims;
    mxArray * Cout; //cell array of clusters in matlab
    mxArray * curcell; //cell array of clusters in matlab
    double * ca; //cell array of clusters in matlab
    mxArray * Pout; //vector of parent ids
    mwSize ca_dims[2];

    // Get data values, # of points, and # dimensions from input
    dims = mxGetDimensions(prhs[0]);
    d = (int) dims[0]; //number of dimensions
    n = (nid_t) dims[1]; //number of points
    Dm = mxGetPr(prhs[0]); // pointer to the data
    D = malloc(n*d*sizeof(edge_t));
    for (i=0; i<n*d; i++) D[i] = (edge_t) Dm[i]; // Copy into float array
    
    // Run the clustering
    SPC_HIERARCHICAL(D, n, d, K, MIN_CLUS_SIZE, NMC, &Nc, &Cn, &hC, &P);
        
    // Write the clusters to matlab space
    ca_dims[0] = (mwSize) Nc; //length of cell array is # clusters
    ca_dims[1] = 1;
    plhs[0] = mxCreateCellArray(2, ca_dims);
    for (i=0; i<Nc; i++) { //for each cluster
        curcell = mxCreateDoubleMatrix(Cn[i], 1, mxREAL);
        ca = mxGetPr(curcell); //pointer to data
        for (j=0; j<Cn[i]; j++) { //copy ids in each cluster -> matlab array
            ca[j] = (double) hC[i][j];
        }
        mxSetCell(plhs[0], i, curcell); //stick it in the cell array
    }
    
    // Write the parent vector to matlab space
    plhs[1] = mxCreateDoubleMatrix(Nc, 1, mxREAL);
    ca = mxGetPr(plhs[1]); //pointer to data
    for (i=0; i<Nc; i++) { //for each cluster
        ca[i] = (double) P[i];
    }
    
    // Cleanup
    free(D);
    free(Cn);
    for (i=0; i<Nc; i++) free(hC[i]);
    free(hC);
    free(P);

}

