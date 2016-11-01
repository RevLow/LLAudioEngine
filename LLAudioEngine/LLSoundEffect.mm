//
//  LLSoundEffect.cpp
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/10.
//
//

#include "LLSoundEffect.h"
#include "LLSoundCache.h"

float LLSoundEffect::volume = 1.0f;

// AudioUnit再生時のコールバック
OSStatus renderProc(void* inRefCon,
                    AudioUnitRenderActionFlags* ioActionFlags,
                    const AudioTimeStamp* inTimeStamp,
                    UInt32 inBusNumber,
                    UInt32 inNumberFrames,
                    AudioBufferList* ioData)
{
    LLSoundEffect* soundEffect = reinterpret_cast<LLSoundEffect*>(inRefCon);
    
    //モノラルとステレオの判定
    int indexR = (soundEffect->_data.numberOfChannels == 2) ? 1 : 0;
    
    AudioUnitSampleType* outL = (AudioUnitSampleType*)ioData->mBuffers[0].mData;
    AudioUnitSampleType* outR = (AudioUnitSampleType*)ioData->mBuffers[indexR].mData;
    
    AudioUnitSampleType** buffer = soundEffect->_data.playBuffer;
    SInt64 currentFrame = soundEffect->_currentFrame;
    SInt64 totalFrames = soundEffect->_data.totalFrames;
    
    for (int i=0; i < inNumberFrames; i++)
    {
        
        if (!soundEffect->_playing)
        {
            // 停止、ポーズ中
            *outL++ = *outR++ = 0;
        }
        else if(currentFrame == totalFrames)
        {
            // 再生終了
            currentFrame = 0;
            soundEffect->_playing = false;
        }
        else
        {
            // バッファ格納処理
            *outL++ = buffer[0][currentFrame] * LLSoundEffect::volume;
            *outR++ = buffer[indexR][currentFrame++] * LLSoundEffect::volume;
        }
    }
    
    soundEffect->_currentFrame = currentFrame;
    if (!soundEffect->_playing)
    {
        soundEffect->stop();
    }
    
    return noErr;
}

LLSoundEffect::LLSoundEffect(const std::string& filePath) :
_playing(false),
_currentFrame(0)
{
    _data = LLSoundCache::getInstance()->getFileCache(filePath);
    prepareAudioUnit();
}

LLSoundEffect::~LLSoundEffect()
{
    if (_playing) {
        AudioOutputUnitStop(_outputUnit);
    }
    AudioUnitUninitialize(_outputUnit);
    AudioComponentInstanceDispose(_outputUnit);
}

void LLSoundEffect::play()
{
    if (_playing) return;

    AudioOutputUnitStart(_outputUnit);
    _playing = true;
}

void LLSoundEffect::stop()
{
    if(!_playing) return;
    
    AudioOutputUnitStop(_outputUnit);
    _playing = false;
    _currentFrame = 0;
}
void LLSoundEffect::pause()
{
    if(!_playing) return;

    AudioOutputUnitStop(_outputUnit);
    _playing = false;
}

bool LLSoundEffect::isPlaying() const
{
    return _playing;
}

Float32 LLSoundEffect::tell() const
{
    return 0;
}

void LLSoundEffect::seek(Float32 millisec)
{
    
}

void LLSoundEffect::setVolume(const float& vol)
{
    float value = vol;
    if(vol > 1.0) value = 1.0;
    if(vol < 0.0) value = 0.0;

    volume = value;
}

float LLSoundEffect::getVolume()
{
    return volume;
}

void LLSoundEffect::prepareAudioUnit()
{
    AudioComponentDescription acd;
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_RemoteIO;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(nullptr, &acd);
    AudioComponentInstanceNew(component, &_outputUnit);
    AudioUnitInitialize(_outputUnit);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderProc;
    callbackStruct.inputProcRefCon = this;
    
    AudioUnitSetProperty(_outputUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0,
                         &callbackStruct,
                         sizeof(AURenderCallbackStruct));

    AudioStreamBasicDescription asbd = LinearPcmDescription(_data.sampleRate, _data.numberOfChannels);
    AudioUnitSetProperty(_outputUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &asbd,
                         sizeof(AudioStreamBasicDescription));
    
}

