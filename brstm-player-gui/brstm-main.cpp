//C++ BRSTM reader
//Copyright (C) 2020 Extrasklep
#include <iostream>
#include <stdio.h>
#include <stdlib.h>


//brstm stuff

unsigned int  HEAD1_codec; //char
unsigned int  HEAD1_loop;  //char
unsigned int  HEAD1_num_channels; //char
unsigned int  HEAD1_sample_rate;
unsigned long HEAD1_loop_start;
unsigned long HEAD1_total_samples;
unsigned long HEAD1_ADPCM_offset;
unsigned long HEAD1_total_blocks;
unsigned long HEAD1_blocks_size;
unsigned long HEAD1_blocks_samples;
unsigned long HEAD1_final_block_size;
unsigned long HEAD1_final_block_samples;
unsigned long HEAD1_final_block_size_p;
unsigned long HEAD1_samples_per_ADPC;
unsigned long HEAD1_bytes_per_ADPC;

unsigned int  HEAD2_num_tracks;
unsigned int  HEAD2_track_type;

unsigned int  HEAD2_track_num_channels[8] = {0,0,0,0,0,0,0,0};
unsigned int  HEAD2_track_lchannel_id [8] = {0,0,0,0,0,0,0,0};
unsigned int  HEAD2_track_rchannel_id [8] = {0,0,0,0,0,0,0,0};
//type 1 only
unsigned int  HEAD2_track_volume      [8] = {0,0,0,0,0,0,0,0};
unsigned int  HEAD2_track_panning     [8] = {0,0,0,0,0,0,0,0};
//HEAD3
unsigned int  HEAD3_num_channels;
int16_t* PCM_samples[16];

int16_t* PCM_buffer[16]; //unused in this program

unsigned long written_samples=0;

//TODO: add getters for more vars to make everything work

#include "brstm.h"


//Getters for outer world access

extern "C" unsigned long  gHEAD1_sample_rate(){
    return HEAD1_sample_rate;
};
extern "C" unsigned long gHEAD1_loop_start(){
    return HEAD1_loop_start;
}
extern "C" unsigned char readABrstm (const unsigned char* fileData, unsigned char debugLevel, bool decodeADPCM)
{
    return readBrstm(fileData, debugLevel, decodeADPCM);
}
extern "C" unsigned long gwritten_samples(){
    return written_samples;
};
extern "C" int16_t** gPCM_samples(){
    return PCM_samples;
}
extern "C" unsigned int  gHEAD3_num_channels(){
    return HEAD3_num_channels;
}
extern "C" unsigned long gHEAD1_blocks_samples(){
    return HEAD1_blocks_samples;
}
extern "C" int16_t** gPCM_buffer(){
    return PCM_buffer;
}
extern "C" int16_t**  getBufferBlock(const unsigned char* fileData, unsigned long sampleOffset){
    brstm_getbuffer(fileData, sampleOffset, HEAD1_blocks_samples, true);
    return PCM_buffer;
}
extern "C" void closeBrstm(){
    brstm_close();
}
extern "C" unsigned long gHEAD1_total_samples(){
    return HEAD1_total_samples;
}
extern "C" unsigned int  gHEAD1_loop(){
    return HEAD1_loop;
}