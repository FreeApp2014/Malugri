//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#include <stdbool.h>
#import <stdint.h>

unsigned char readABrstm(const unsigned char* fileData, unsigned char debugLevel, bool decodeADPCM);
unsigned long gawritten_samples();
unsigned long gaHEAD1_sample_rate();
unsigned int  gHEAD3_num_channels();
unsigned long gHEAD1_loop_start();
int16_t** gaPCM_samples();

