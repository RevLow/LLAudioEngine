//
//  LLSoundEffect.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/10.
//
//

#ifndef __LLAudioEngine__LLSoundEffect__
#define __LLAudioEngine__LLSoundEffect__

#include "LLAudio.h"

class LLSoundEffect
{
    // コールバック関数内でメンバー変数(_currentFrame)にアクセスしたいためfriendに設定
    friend OSStatus renderProc(void* inRefCon,
                               AudioUnitRenderActionFlags* ioActionFlags,
                               const AudioTimeStamp* inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList* ioData);
public:
    LLSoundEffect(const std::string &filePath);
    virtual ~LLSoundEffect();
    void play();
    void stop();
    void pause();
    Float32 tell() const;
    void seek(Float32 millisec);
    bool isPlaying() const;
private:
    void prepareAudioUnit();
    AudioUnit _outputUnit;
    SoundEffectData _data;
    bool _playing;
    SInt64 _currentFrame;
};


#endif /* defined(__LLAudioEngine__LLSoundEffect__) */
