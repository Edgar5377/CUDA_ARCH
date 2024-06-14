
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iomanip>
#include <assert.h>
#include <iostream>
#include <vector>
#include <chrono>
const int size = 200;
const double imp0 = 377.0;
const int maxTime = 250;

__global__ void updateHy(double* hy, double* ez, int size, double imp0) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < size - 1) {
        hy[tid] += (ez[tid + 1] - ez[tid]) / imp0;
    }
}

__global__ void updateEz(double* hy, double* ez, int size, double imp0) {
    int mm = blockIdx.x * blockDim.x + threadIdx.x;
    if (mm >= 1 && mm < size) {
        ez[mm] += (hy[mm] - hy[mm - 1]) * imp0;
    }
}

__global__ void setEzNode(double* ez, int qtime) {
    ez[0] = std::exp(-1.0 * (qtime - 30.0) * (qtime - 30.0) / 100.0);
}


int main()
{    

    std::vector<double> ez(size, 0.0);
    std::vector<double> hy(size, 0.0);
    std::vector<double> E50(maxTime, 0.0);
    std::vector<std::vector<double>> ez_time;
    std::vector<std::vector<double>> hy_time;



   
   
    double* d_ez, * d_hy;
    cudaMalloc(&d_ez, size * sizeof(double));
    cudaMalloc(&d_hy, size * sizeof(double));

    cudaMemcpy(d_ez, ez.data(), size * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_hy, hy.data(), size * sizeof(double), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int numBlocksHy = (size - 1 + blockSize - 1) / blockSize;
    int numBlocksEz = (size + blockSize - 1) / blockSize;


    auto start = std::chrono::system_clock::now(); // Tomar tiempo
    for (int qtime = 1; qtime <= maxTime; ++qtime) {
        // actualiar campo magnetico
        updateHy << <numBlocksHy, blockSize >> > (d_hy, d_ez, size, imp0);
        cudaDeviceSynchronize();

        // actualizar campo electrico
        updateEz << <numBlocksEz, blockSize >> > (d_hy, d_ez, size, imp0);
        cudaDeviceSynchronize();

        // actualizar ez en el mismo gpu
        setEzNode << <1, 1 >> > (d_ez, qtime);
    }




    auto end = std::chrono::system_clock::now(); //Tomar tiempo 
    std::chrono::duration<float, std::milli> duration = end - start;

    std::cout << "El tiempo total del proceso fue " << duration.count() << "ms" ;

    cudaMemcpy(ez.data(), d_ez, size * sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy(hy.data(), d_hy, size * sizeof(double), cudaMemcpyDeviceToHost);

    cudaFree(d_ez);
    cudaFree(d_hy);
   
    /*
    

    
    std::cout << "ez matrix:\n";
    for (const auto& time_step : ez_time) {
        for (const auto& value : time_step) {
            std::cout << std::setprecision(2) << std::setw(10) << value << " ";
        }
        std::cout << "\n";
    }

    std::cout << "hy matrix:\n";
    for (const auto& time_step : hy_time) {
        for (const auto& value : time_step) {
            std::cout << std::setprecision(2) << std::setw(10) << value << " ";
        }
        std::cout << "\n";
    }
    */

    return 0;

}
