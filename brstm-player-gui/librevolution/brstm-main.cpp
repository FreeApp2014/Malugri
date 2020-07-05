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
    for (unsigned int c = 0; c < 16; c++){
        brstmp->ADPCM_buffer[c] = nullptr;
        brstmp->ADPCM_data[c] = nullptr;
        brstmp->ADPCM_hsamples_1[c] = nullptr;
        brstmp->ADPCM_hsamples_2[c] = nullptr;
        brstmp->PCM_blockbuffer[c] = nullptr;
        brstmp->PCM_buffer[c] = nullptr;
        brstmp->PCM_samples[c] = nullptr;
    }
}

extern "C" unsigned long  gHEAD1_sample_rate(){
    return brstmp->sample_rate;
};
extern "C" unsigned long gHEAD1_loop_start(){
    return brstmp->loop_start;
}
extern "C" unsigned char readABrstm (const unsigned char* fileData, unsigned char debugLevel, bool decodeADPCM){
    return brstm_read(brstmp, fileData, debugLevel, decodeADPCM);
}
extern "C" unsigned char readFstreamBrstm(){
    return brstm_fstream_read(brstmp, brstmfile, 1);
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
    unsigned int readLength;
    if (sampleOffset/brstmp->blocks_samples < (brstmp->total_blocks)) readLength = brstmp->blocks_samples;
    else readLength = brstmp->final_block_size;
    brstm_fstream_getbuffer(brstmp, brstmfile, sampleOffset, readLength);
    return brstmp->PCM_buffer;
}
extern "C" void closeBrstm(){
    brstm_close(brstmp);
    delete brstmp;
    brstmfile.close();
}
extern "C" unsigned long gHEAD1_total_samples(){
    return brstmp->total_samples;
}
extern "C" unsigned int gHEAD1_loop(){
    return brstmp->loop_flag;
}

extern "C" int createIFSTREAMObject(char* filename){
     brstmfile.open(filename);
     return brstmfile.is_open();
}
extern "C" unsigned long gHEAD1_total_blocks(){
    return brstmp->total_blocks;
}

extern "C" unsigned long gHEAD1_final_block_samples(){
    return brstmp->final_block_samples;
}

extern "C" unsigned int gFileType(){
    return brstmp->file_format;
}
