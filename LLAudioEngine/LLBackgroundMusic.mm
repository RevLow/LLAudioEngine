//
//  LLBackgroundMusic.cpp
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/25.
//
//

#include "LLBackgroundMusic.h"

void outputCallback(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    LLBackgroundMusic* bgm = static_cast<LLBackgroundMusic*>(inUserData);
    if(bgm->_isDone)
    {
        return;
    }
    
    UInt32 numPacket = bgm->_packetReadCount;
    UInt32 numBytes;
    AudioFileReadPackets(bgm->_data.audioId,
                         false,
                         &numBytes,
                         inBuffer->mPacketDescriptions,
                         bgm->_startingPacketCount,
                         &numPacket,
                         inBuffer->mAudioData);
    if (numPacket > 0)
    {
        inBuffer->mAudioDataByteSize = numBytes;
        inBuffer->mPacketDescriptionCount = numPacket;
        AudioQueueEnqueueBuffer(inAQ,
                                inBuffer,
                                bgm->_data.isVBR ? numPacket : 0,
                                bgm->_data.isVBR ? inBuffer->mPacketDescriptions : NULL);
        bgm->_startingPacketCount += numPacket;
    }
    else
    {
        //再生終了の処理
        if(bgm->_isLoop)
        {
            //ループするならば, 開始のパケット時間をリセットし、再起呼び出し
            bgm->_startingPacketCount = 0;
            outputCallback(inUserData, inAQ, inBuffer);
        }
        else
        {
            //ループしないなら終了し、コールバックを呼び出す
            bgm->stop();
            bgm->_isDone = true;
            if (bgm->callbackFunc != nullptr)
            {
                bgm->callbackFunc();
            }
        }
    }
    
}

LLBackgroundMusic::LLBackgroundMusic(const std::string& fileName) :
_isDone(false),
_isLoadedBuffer(false),
_isPlaying(false),
_isLoop(false),
_packetReadCount(0),
_startingPacketCount(0),
_frameOffset(0),
callbackFunc(nullptr)
{
    openFile(fileName);
    initializeAudioQueue();
    prepareAudioBuffer();

    _isPlaying = false;
}

LLBackgroundMusic::~LLBackgroundMusic()
{
    if (_isLoadedBuffer)
    {
        this->stop();
    }
    AudioFileClose(_data.audioId);
    AudioQueueDispose(_queueRef, YES);
}

void LLBackgroundMusic::openFile(const std::string &fileName)
{
    // オーディオファイルのオープン
    NSString* nsFilePath = [[NSString alloc] initWithCString:fileName.c_str() encoding:nil];
    CFURLRef urlFilePath = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)nsFilePath, kCFURLPOSIXPathStyle, false);
    OSStatus result = AudioFileOpenURL(urlFilePath, kAudioFileReadPermission, 0, &_data.audioId);
    
    ll_assert_arg(result == 0, "Audio File cannot read. [%s]", fileName.c_str());
}

void LLBackgroundMusic::initializeAudioQueue()
{
    _frameOffset = 0;
    _startingPacketCount = 0;
    
    // ASBDの取得
    UInt32 size = sizeof(AudioStreamBasicDescription);
    AudioFileGetProperty(_data.audioId, kAudioFilePropertyDataFormat, &size, &_data.audioFormat);
    
    _data.isVBR = (_data.audioFormat.mBytesPerPacket == 0 || _data.audioFormat.mFramesPerPacket == 0);
    _data.sampleRate = _data.audioFormat.mSampleRate;
    
    //総パケット数の取得
    UInt64 packetCount;
    UInt32 propertySize = sizeof(packetCount);
    OSStatus result = AudioFileGetProperty(_data.audioId, kAudioFilePropertyAudioDataPacketCount, &propertySize, &packetCount);
    ll_assert(result == 0, "Cannot get audio file property");
    _data.totalFrames = packetCount * _data.audioFormat.mFramesPerPacket;
    
    // AudioQueueの作成
    AudioQueueNewOutput(&_data.audioFormat, outputCallback, this, NULL, NULL, 0, &_queueRef);
    
    // マジッククッキーを設定
    setMagicCookie();
}

void LLBackgroundMusic::prepareAudioBuffer()
{
    AudioQueueBufferRef buffers[3];
    
    // バッファのサイズを設定
    // ひとつのバッファには1024くらいのフレームが入る
    // 1パケットの最大バイトサイズを取得
    UInt32 maxPacketSize;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(_data.audioId, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
    
    _packetReadCount = (_data.audioFormat.mFormatID == kAudioFormatLinearPCM) ? 1024 : calcPacketCount(_data.audioFormat.mFramesPerPacket, 1024);
    UInt32 bufferByteSize = _packetReadCount * maxPacketSize;
    
    // AudioQueueBufferの初期化
    for (int bufferIndex = 0; bufferIndex < 3; bufferIndex++)
    {
        AudioQueueAllocateBufferWithPacketDescriptions(_queueRef, bufferByteSize, _packetReadCount, &buffers[bufferIndex]);
        outputCallback(this, _queueRef, buffers[bufferIndex]);
        if(_isDone) break;
    }
    
    _isLoadedBuffer = true;
}

void LLBackgroundMusic::play()
{
    if(_isPlaying) return;

    if (!_isLoadedBuffer) prepareAudioBuffer();
    AudioQueueCreateTimeline(_queueRef, &_timeline);
    AudioQueueStart(_queueRef, 0);
    _isPlaying = true;
}

void LLBackgroundMusic::pause()
{
    if(!_isPlaying) return;
    
    // 時間を記録しておく
    _frameOffset = getCurrentPosition();
    _startingPacketCount = _frameOffset / _data.audioFormat.mFramesPerPacket;

    AudioQueueStop(_queueRef, true);
    _isLoadedBuffer = false;
    _isPlaying = false;
}

void LLBackgroundMusic::stop()
{
    if(!_isPlaying) return;

    _startingPacketCount = 0;
    _frameOffset = 0;

    AudioQueueStop(_queueRef, true);
    AudioQueueDisposeTimeline(_queueRef, _timeline);
    _isLoadedBuffer = false;
    _isPlaying = false;
}

float LLBackgroundMusic::tell() const
{
    SInt64 frame = getCurrentPosition();
    return frame * (1000.0f / _data.sampleRate);
}

void LLBackgroundMusic::seek(float millisec)
{
    SInt64 frame = (millisec / 1000.0f) * _data.sampleRate;
    setCurrentPosition(frame);
}

void LLBackgroundMusic::setLoop(bool loop)
{
    _isLoop = loop;
}

bool LLBackgroundMusic::getLoop() const
{
    return _isLoop;
}

bool LLBackgroundMusic::isPlaying() const
{
    return _isPlaying;
}

void LLBackgroundMusic::setVolume(const float& volume)
{
    float value = volume;
    if (volume > 1.0) {
        value = 1.0;
    }
    if (volume < 0.0) {
        value = 0.0;
    }
    AudioQueueSetParameter(_queueRef, kAudioQueueParam_Volume, value);
}

float LLBackgroundMusic::getVolume() const
{
    float value = 0.0f;
    AudioQueueGetParameter(_queueRef, kAudioQueueParam_Volume, &value);

    return value;
}

void LLBackgroundMusic::setOnExitCallback(const std::function<void ()>& func)
{
    callbackFunc = func;
}

SInt64 LLBackgroundMusic::getCurrentPosition() const
{
    AudioTimeStamp timeStamp;
    AudioQueueGetCurrentTime(_queueRef,
                             _timeline,
                             &timeStamp,
                             NULL);
    SInt64 currentSampleTime = timeStamp.mSampleTime + _frameOffset;
    return currentSampleTime % _data.totalFrames;
}

void LLBackgroundMusic::setCurrentPosition(SInt64 frame)
{
    //ストップしたときに状態が変化するため、再生中だったかを取得しておく
    bool playing = _isPlaying;
    pause();
    _startingPacketCount = frame / _data.audioFormat.mFramesPerPacket;
    _frameOffset = frame;

    // 再生中だったら再生を行う
    if (playing)
    {
        play();
    }
}

void LLBackgroundMusic::setMagicCookie()
{
    UInt32 propertySize = sizeof(UInt32);
    AudioFileGetPropertyInfo(_data.audioId, kAudioFilePropertyMagicCookieData, &propertySize, NULL);
    
    if (propertySize)
    {
        char* cookie = (char*)malloc(propertySize);
        
        AudioFileGetProperty(_data.audioId, kAudioFilePropertyMagicCookieData, &propertySize, cookie);
        AudioQueueSetProperty(_queueRef, kAudioQueueProperty_MagicCookie, cookie, propertySize);
        
        free(cookie);
    }
}

UInt32 LLBackgroundMusic::calcPacketCount(UInt32 framePerPacket, UInt32 requestFrame)
{
    if(framePerPacket >= requestFrame) return 1;
    
    int packets = 2;
    for (int frames = 0; frames > requestFrame; packets++)
    {
        frames = packets * framePerPacket;
    }
    
    // 近似値計算
    // 下限からの差分より上限からの差分のほうが大きければ下限のほうが近い
    int lowerSub = requestFrame - ( (packets - 1) * framePerPacket);
    int upperSub = (packets * framePerPacket) - requestFrame;
    
    if (upperSub > lowerSub) return packets - 1;
    return packets;
}
