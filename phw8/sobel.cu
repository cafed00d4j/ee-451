#include<stdlib.h>
#include<stdio.h>
#include<time.h>
#include<math.h>

#define n 192

#define input_file  "phw8.raw"
#define output_file "output.raw"

__global__ void sobel(unsigned char *a, unsigned char *c) {
	int myx, myy, i;
	myx = blockIdx.x * blockDim.x + threadIdx.x;
	myy = blockIdx.y * blockDim.y + threadIdx.y;    
    
    int gx[3][3] =
    {
        {-1,2,-1},
        {0,0,0},
        {1,2,1}
    };
    
    int gy[3][3] =
    {
        {-1,0,1},
        {-2,0,2},
        {-1,0,1}
    };
    
    int dx = 0, dy = 0;

    dx += (a[((myx-1)*(n+2)) + myy-1] * gx[0][0])
       +  (a[((myx-1)*(n+2)) + myy] * gx[0][1])
       +  (a[((myx-1)*(n+2)) + myy+1] * gx[0][2])
       
       +  (a[((myx)*(n+2)) + myy-1] * gx[1][0])
       +  (a[((myx)*(n+2)) + myy] * gx[1][1])
       +  (a[((myx)*(n+2)) + myy+1] * gx[1][2])
       
       +  (a[((myx+1)*(n+2)) + myy-1] * gx[2][0])
       +  (a[((myx+1)*(n+2)) + myy] * gx[2][1])
       +  (a[((myx+1)*(n+2)) + myy+1] * gx[2][2]);
    
    dy += (a[((myx-1)*(n+2)) + myy-1] * gy[0][0])
       +  (a[((myx-1)*(n+2)) + myy] * gy[0][1])
       +  (a[((myx-1)*(n+2)) + myy+1] * gy[0][2])
       
       +  (a[((myx)*(n+2)) + myy-1] * gy[1][0])
       +  (a[((myx)*(n+2)) + myy] * gy[1][1])
       +  (a[((myx)*(n+2)) + myy+1] * gy[1][2])
       
       +  (a[((myx+1)*(n+2)) + myy-1] * gy[2][0])
       +  (a[((myx+1)*(n+2)) + myy] * gy[2][1])
       +  (a[((myx+1)*(n+2)) + myy+1] * gy[2][2]);
    
    
	c[myx*n+myy] = (unsigned char)sqrt( ( ((double)dx)*((double)dx) + ((double)dy)*((double)dy) ) );
}

int main() {
	unsigned char *a = (unsigned char*)malloc(sizeof(unsigned char)*(n+2)*(n+2));
	unsigned char *c = (unsigned char*)malloc(sizeof(unsigned char)*n*n);
    
	cudaEvent_t start, stop;
	float time;
    
    FILE *fp;
	
    dim3 numBlocks(64,64);
    dim3 threadsPerBlock(3,3);
    
    
    // Read image
    if (!(fp=fopen(input_file, "rb"))) {
		printf("can not opern file\n");
		return 1;
	}
	fread(a, sizeof(unsigned char), (n+2)*(n+2), fp);
	fclose(fp);


	unsigned char *gpua, *gpuc;

	cudaMalloc((void**)&gpua, sizeof(unsigned char *)*(n+2)*(n+2));
	cudaMalloc((void**)&gpuc, sizeof(unsigned char *)*n*n);

	cudaMemcpy(gpua, a, sizeof(unsigned char *)*(n+2)*(n+2), cudaMemcpyHostToDevice);
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start,0);
	sobel<<<numBlocks, threadsPerBlock>>> (gpua, gpuc);
	cudaEventRecord(stop,0);


	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	cudaMemcpy(c, gpuc, sizeof(unsigned char *)*n*n, cudaMemcpyDeviceToHost);

    if (!(fp=fopen(output_file,"wb"))) {
		printf("can not opern file\n");
		return 1;
	}	
	fwrite(c, sizeof(unsigned char),n*n, fp);
    fclose(fp);
	
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	free(a);
	free(c);

	cudaFree(gpua);
	cudaFree(gpuc);

	return 0;

}
