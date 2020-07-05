//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#include <stdbool.h>
#import <stdint.h>

unsigned char readABrstm(const unsigned char* fileData, unsigned char debugLevel, bool decodeADPCM);
unsigned long gHEAD1_sample_rate();
unsigned int  gHEAD3_num_channels();
unsigned long gHEAD1_loop_start();
unsigned long gHEAD1_blocks_samples();
int16_t** gPCM_samples();
int16_t** gPCM_buffer();
int16_t**  getBufferBlock(unsigned long sampleOffset);
void closeBrstm();
unsigned long gHEAD1_total_samples();
unsigned int  gHEAD1_loop();
int createIFSTREAMObject(char* filename);
void initStruct();
unsigned long gHEAD1_total_blocks();
unsigned long gHEAD1_final_block_samples();
unsigned char readFstreamBrstm();
unsigned int gFileType();
