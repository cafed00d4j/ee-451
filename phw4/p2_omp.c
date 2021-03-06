#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <omp.h>
#include <math.h>
#include<omp.h>


#define		size	   16
//16*1024*1024
void printArray(int *array) {
        int x;
        
        /*
         */
         
        for (x = 0; x < size; x++) {
            printf("%d ",array[x]);
        }
        printf("\n");
        /*
         */
        
}

int my_random(int length) {
    return (rand() % length);
}
void swap(int *a, int i, int j) {
    int t;
    
    //printf("i,j %d %d; ai,aj %d %d  \n",i,j,a[i], a[j]);
    t = a[i];
    a[i] = a[j];
    a[j] = t;
    

}

int partition(int *array, int left, int right) {
    int pivot;
    int wall;
    int i;
    int randIdx;

    randIdx = left + my_random(right-left);
    randIdx = right-1;
    pivot = array[randIdx];
    ///printf("piv=%d;arr= ", pivot);
    
    wall = left;
    
    for (i = left; i < right; i++) {
        if (array[i] < pivot) {
            // swap a[i] & a[wall]
            swap(array, i, wall);
            wall += 1;
        }
    }
    swap(array, wall, randIdx);
    //printArray(array);
    
    
    return wall;
}


void quickSort(int *array, int start, int end){
    // you quick sort function goes here
    int pivotIdx; int x;
    if (start < end) {
        pivotIdx = partition(array, start, end);
      #pragma omp parallel sections
      {  
        #pragma omp section
        {
            quickSort(array, start, pivotIdx);
        }
        #pragma omp section
        {
            quickSort(array, pivotIdx+1, end);
        }
     }
    }
}

int main(void){
	int i, j, tmp;
	struct timespec start, stop; 
	double exe_time;
	srand(time(NULL)); 
	int * m = (int *) malloc (sizeof(int)*size);
	
	for(i=0; i<size; i++){
		m[i]=size-i;
	}
	
	if( clock_gettime(CLOCK_REALTIME, &start) == -1) { perror("clock gettime");}
	////////**********Your code goes here***************//
	omp_set_num_threads(2);
	quickSort(m, 0, size);
			
	///////******************************////
	
	if( clock_gettime( CLOCK_REALTIME, &stop) == -1 ) { perror("clock gettime");}		
	exe_time = (stop.tv_sec - start.tv_sec)+ (double)(stop.tv_nsec - start.tv_nsec)/1e9;
	
	for(i=0;i<16;i++) printf("%d ", m[i]);		
	printf("\nExecution time = %f sec\n",  exe_time);		
}	
