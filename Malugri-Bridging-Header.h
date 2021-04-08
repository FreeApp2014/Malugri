//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <stdbool.h>
#import <stdint.h>

unsigned char readABrstm(const unsigned char* fileData, unsigned char debugLevel, bool decodeADPCM);
unsigned long gHEAD1_sample_rate();
unsigned int  gHEAD3_num_channels(int trackNumber);
unsigned int gLChId(int trackNumber);
unsigned int gRChId(int trackNumber);
unsigned int gnum_tracks();
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
unsigned int gFileCodec();
int16_t** getbuffer(unsigned long offset, uint32_t frames);
#include "EZAudio.h"
#include "EZOutput.h"
struct Brstm {
    //Byte order mark
    bool BOM;
    //File type, 1 = BRSTM, see above for full list
    unsigned int  file_format;
    //Audio codec, 0 = PCM8, 1 = PCM16, 2 = DSPADPCM
    unsigned int  codec;
    bool          loop_flag;
    unsigned int  num_channels;
    unsigned long sample_rate;
    unsigned long loop_start;
    unsigned long total_samples;
    unsigned long audio_offset;
    unsigned long total_blocks;
    unsigned long blocks_size;
    unsigned long blocks_samples;
    unsigned long final_block_size;
    unsigned long final_block_samples;
    unsigned long final_block_size_p;
    
    //track information
    unsigned int  num_tracks;
    unsigned int  track_desc_type;
    unsigned int  track_num_channels[8];
    unsigned int  track_lchannel_id [8];
    unsigned int  track_rchannel_id [8];
    unsigned int  track_volume      [8];
    unsigned int  track_panning     [8];
    
    int16_t* PCM_samples[16];
    int16_t* PCM_buffer [16];
    
    unsigned char* ADPCM_data   [16];
    unsigned char* ADPCM_buffer [16]; //Not used yet
    int16_t  ADPCM_coefs    [16][16];
    int16_t* ADPCM_hsamples_1   [16];
    int16_t* ADPCM_hsamples_2   [16];
    
    //Encoder
    unsigned char* encoded_file;
    unsigned long  encoded_file_size;
    
    //Things you probably shouldn't touch
    //block cache
    int16_t* PCM_blockbuffer[16];
    int PCM_blockbuffer_currentBlock;
    bool getbuffer_useBuffer;
    //Audio stream format,
    //0 for normal block data in BRSTM and similar files
    //1 for WAV which has 1 sample per block
    //so the block size here can be made bigger and block reads
    //won't be made one by one for every sample
    unsigned int audio_stream_format;
};
