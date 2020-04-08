//C++ BRSTM reader
//Copyright (C) 2020 Extrasklep
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include "brstm.h"

Brstm* brstmp;
std::ifstream brstmfile;

//Getters for outer world access

extern "C" void initStruct(){
    brstmp = new Brstm;
}

extern "C" unsigned long  gHEAD1_sample_rate(){
    return brstmp->sample_rate;
};
extern "C" unsigned long gHEAD1_loop_start(){
    return brstmp->loop_start;
}
extern "C" unsigned char readABrstm (const unsigned char* fileData, unsigned char debugLevel, bool decodeADPCM)
{
    return brstm_read(brstmp, fileData, debugLevel, decodeADPCM);
}
extern "C" int16_t** gPCM_samples(){
    return brstmp->PCM_samples;
}
extern "C" unsigned int  gHEAD3_num_channels(){
    return brstmp->num_channels;
}
extern "C" unsigned long gHEAD1_blocks_samples(){
    return brstmp->blocks_samples;
}



extern "C" int16_t**  getBufferBlock(unsigned long sampleOffset){
    //Prevent reading garbage from outside the file
//    std::cout << brstmp->total_samples << " " << sampleOffset << " " << brstmp->blocks_samples << " " << readLen << std::endl;
//    if ((sampleOffset + brstmp->blocks_samples) > brstmp->total_samples) {readLen = brstmp->total_samples - sampleOffset; std::cout << "End";}
    brstm_fstream_getbuffer(brstmp, brstmfile, sampleOffset, brstmp->blocks_samples);
    return brstmp->PCM_buffer;
}
extern "C" void closeBrstm(){
    brstm_close(brstmp);
    delete brstmp;
}
extern "C" unsigned long gHEAD1_total_samples(){
    return brstmp->total_samples;
}
extern "C" unsigned int gHEAD1_loop(){
    return brstmp->loop_flag;
}

extern "C" void createIFSTREAMObject(char* filename){
     brstmfile.open(filename);
}
extern "C" unsigned long gHEAD1_total_blocks(){
    return brstmp->total_blocks;
}
