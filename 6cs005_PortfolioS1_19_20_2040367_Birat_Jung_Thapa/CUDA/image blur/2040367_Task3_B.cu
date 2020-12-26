#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>

#include "lodepng.h"

/********
Compile with nvcc 2040367_Task3_B.cu lodepng.cpp -o task3b

             ./task3b
*********/

__global__ void blur_image(unsigned char * gpu_imageOuput, unsigned char * gpu_imageInput,int width,int height){

    int counter=0;

    int idx = blockDim.x * blockIdx.x + threadIdx.x;

    
    int i=blockIdx.x;
    int j=threadIdx.x;


    float t_r=0;
	float t_g=0;
	float t_b=0;
    float t_a=0;
    float s=1;

    if(i+1 && j-1){

        // int pos= idx/2-2;

        int pos=blockDim.x * (blockIdx.x+1) + threadIdx.x-1;
        int pixel = pos*4;

        // t_r=s*gpu_imageInput[idx*4];
        // t_g=s*gpu_imageInput[idx*4+1];
        // t_b=s*gpu_imageInput[idx*4+2];
        // t_a=s*gpu_imageInput[idx*4+3];

        t_r += s*gpu_imageInput[pixel];
        t_g += s*gpu_imageInput[1+pixel];
        t_b += s*gpu_imageInput[2+pixel];
        t_a += s*gpu_imageInput[3+pixel];
        
        counter++;



    }

    if(j+1){

        // int pos= idx/2-2;

        int pos=blockDim.x * (blockIdx.x) + threadIdx.x+1;

        int pixel = pos*4;

        // t_r=s*gpu_imageInput[idx*4];
        // t_g=s*gpu_imageInput[idx*4+1];
        // t_b=s*gpu_imageInput[idx*4+2];
        // t_a=s*gpu_imageInput[idx*4+3];

        t_r += s*gpu_imageInput[pixel];
        t_g += s*gpu_imageInput[1+pixel];
        t_b += s*gpu_imageInput[2+pixel];
        t_a += s*gpu_imageInput[3+pixel];

        counter++;
    }

    if(i+1 && j+1){

        // int pos= idx/2+1;

        int pos=blockDim.x * (blockIdx.x+1) + threadIdx.x+1;


        int pixel = pos*4;

        // t_r=s*gpu_imageInput[idx*4];
        // t_g=s*gpu_imageInput[idx*4+1];
        // t_b=s*gpu_imageInput[idx*4+2];
        // t_a=s*gpu_imageInput[idx*4+3];

        t_r += s*gpu_imageInput[pixel];
        t_g += s*gpu_imageInput[1+pixel];
        t_b += s*gpu_imageInput[2+pixel];
        t_a += s*gpu_imageInput[3+pixel];

        counter++;


    }

    if(i+1){
        // int pos= idx+1;

        int pos=blockDim.x * (blockIdx.x+1) + threadIdx.x;

        int pixel = pos*4;

        // t_r=s*gpu_imageInput[idx*4];
        // t_g=s*gpu_imageInput[idx*4+1];
        // t_b=s*gpu_imageInput[idx*4+2];
        // t_a=s*gpu_imageInput[idx*4+3];

        t_r += s*gpu_imageInput[pixel];
        t_g += s*gpu_imageInput[1+pixel];
        t_b += s*gpu_imageInput[2+pixel];
        t_a += s*gpu_imageInput[3+pixel];

        counter++;



    }

    if(j-1){

        // int pos= idx*2-2;
        int pos=blockDim.x * (blockIdx.x) + threadIdx.x-1;

        int pixel = pos*4;

        // t_r=s*gpu_imageInput[idx*4];
        // t_g=s*gpu_imageInput[idx*4+1];
        // t_b=s*gpu_imageInput[idx*4+2];
        // t_a=s*gpu_imageInput[idx*4+3];

        t_r += s*gpu_imageInput[pixel];
        t_g += s*gpu_imageInput[1+pixel];
        t_b += s*gpu_imageInput[2+pixel];
        t_a += s*gpu_imageInput[3+pixel];

        counter++;




    }

    if(i-1){

        // int pos= idx-1;
        int pos=blockDim.x * (blockIdx.x-1) + threadIdx.x;

        int pixel = pos*4;

        // t_r=s*gpu_imageInput[idx*4];
        // t_g=s*gpu_imageInput[idx*4+1];
        // t_b=s*gpu_imageInput[idx*4+2];
        // t_a=s*gpu_imageInput[idx*4+3];

        t_r += s*gpu_imageInput[pixel];
        t_g += s*gpu_imageInput[1+pixel];
        t_b += s*gpu_imageInput[2+pixel];
        t_a += s*gpu_imageInput[3+pixel];

        counter++;


    }
    
    int current_pixel=idx*4;

    gpu_imageOuput[current_pixel]=(int)t_r/counter;
    gpu_imageOuput[1+current_pixel]=(int)t_g/counter;
    gpu_imageOuput[2+current_pixel]=(int)t_b/counter;
    gpu_imageOuput[3+current_pixel]=gpu_imageInput[3+current_pixel];


}

int time_difference(struct timespec *start, 
	struct timespec *finish, 
	long long int *difference) {
	long long int ds =  finish->tv_sec - start->tv_sec; 
	long long int dn =  finish->tv_nsec - start->tv_nsec; 
	if(dn < 0 ) {
		ds--;
		dn += 1000000000; 
	} 
	*difference = ds * 1000000000 + dn;
	return !(*difference > 0);
}

int main(int argc, char **argv){
struct  timespec start, finish;
	long long int time_elapsed;
	clock_gettime(CLOCK_MONOTONIC, &start);
	
	unsigned int error;
	unsigned int encError;
	unsigned char* image;
	unsigned int width;
	unsigned int height;
	const char* filename = "image.png";
	const char* newFileName = "blur.png";

	error = lodepng_decode32_file(&image, &width, &height, filename);
	if(error){
		printf("error %u: %s\n", error, lodepng_error_text(error));
	}

	const int ARRAY_SIZE = width*height*4;
	const int ARRAY_BYTES = ARRAY_SIZE * sizeof(unsigned char);

	unsigned char host_imageInput[ARRAY_SIZE * 4];
	unsigned char host_imageOutput[ARRAY_SIZE * 4];

	for (int i = 0; i < ARRAY_SIZE; i++) {
		host_imageInput[i] = image[i];
	}

	// declare GPU memory pointers
	unsigned char * d_in;
	unsigned char * d_out;

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES);
	cudaMalloc((void**) &d_out, ARRAY_BYTES);

	cudaMemcpy(d_in, host_imageInput, ARRAY_BYTES, cudaMemcpyHostToDevice);

	// launch the kernel
	blur_image<<<height, width>>>(d_out, d_in,width,height);


	// copy back the result array to the CPU
	cudaMemcpy(host_imageOutput, d_out, ARRAY_BYTES, cudaMemcpyDeviceToHost);
	
	encError = lodepng_encode32_file(newFileName, host_imageOutput, width, height);
	if(encError){
		printf("error %u: %s\n", error, lodepng_error_text(encError));
	}

	//free(image);
	//free(host_imageInput);
	cudaFree(d_in);
	cudaFree(d_out);

	//free(image);
	//free(host_imageInput);
	cudaFree(d_in);
	cudaFree(d_out);
	clock_gettime(CLOCK_MONOTONIC, &finish);
	time_difference(&start, &finish, &time_elapsed);
	printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, (time_elapsed/1.0e9)); 
	
	return 0;
}

