//
//  LLBackgroundMusic.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/25.
//
//

#ifndef __LLAudioEngine__LLBackgroundMusic__
#define __LLAudioEngine__LLBackgroundMusic__

#include "LLAudio.h"

class LLBackgroundMusic
{
    friend void outputCallback(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);
public:
    LLBackgroundMusic(const std::string& fileName);
    ~LLBackgroundMusic();
    LLBackgroundMusic(const LLBackgroundMusic& music) =delete;
    const LLBackgroundMusic& operator=(const LLBackgroundMusic& music)=delete;
    void stop();
    void play();
    void pause();
    float tell() const;
    void seek(float millisec);
    void setOnExitCallback(const std::function<void(void)>& func);
    void setLoop(bool loop);
    bool getLoop() const;
    bool isPlaying() const;
private:
    SInt64 getCurrentPosition() const;
    void setCurrentPosition(SInt64 frame);
    void openFile(const std::string& fileName);
    void initializeAudioQueue();
    void prepareAudioBuffer();
    void setMagicCookie();
    UInt32 calcPacketCount(UInt32 framePerPacket, UInt32 requestFrame);

    BgmData _data;
    bool _isLoadedBuffer; // AudioBufferの準備が整っているか
    bool _isPlaying;  // 再生を行っているか
    bool _isDone; // 再生が終了したか
    bool _isLoop; // ループするか
    AudioQueueTimelineRef _timeline;
    AudioQueueRef _queueRef;
    UInt32 _packetReadCount; // 1バッファに何パケット使うか
    SInt64 _startingPacketCount;
    SInt64 _frameOffset;
    std::function<void(void)> callbackFunc;
};

#endif /* defined(__LLAudioEngine__LLBackgroundMusic__) */
