//
//  LLSound.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/22.
//
//

#ifndef LLAudioEngine_LLSound_h
#define LLAudioEngine_LLSound_h

#import <AudioToolbox/AudioToolbox.h>
#include "LLAudioAssertion.h"

struct SoundEffectData
{
    SInt64 totalFrames;
    UInt32 numberOfChannels;
    Float64 sampleRate;
    AudioUnitSampleType** playBuffer;
};

struct BgmData
{
    AudioStreamBasicDescription audioFormat;
    AudioFileID audioId;
    bool isVBR;
    Float64 sampleRate;
    SInt64 totalFrames;
};

inline AudioStreamBasicDescription LinearPcmDescription(Float64 sampleRate, UInt32 channelNum)
{
    AudioStreamBasicDescription tFormat;
	tFormat.mChannelsPerFrame = channelNum;
	tFormat.mSampleRate = sampleRate;
	tFormat.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
	tFormat.mFormatID = kAudioFormatLinearPCM;
	tFormat.mBytesPerPacket = sizeof(AudioUnitSampleType);
	tFormat.mFramesPerPacket = 1;
	tFormat.mBytesPerFrame = sizeof(AudioUnitSampleType);
	tFormat.mBitsPerChannel = 8 * sizeof(AudioUnitSampleType);
    tFormat.mReserved = 0;
    
    return  tFormat;
}

#endif
