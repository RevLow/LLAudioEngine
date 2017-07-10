//
//  LLSoundCache.cpp
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/22.
//
//

#include "LLSoundCache.h"

std::shared_ptr<LLSoundCache> LLSoundCache::instance = 0;
bool LLSoundCache::was_destroyed = false;

void LLSoundCacheDelFunc(LLSoundCache* p)
{
    ll_assert(p != nullptr, "p was deleted. But call destractor");
    delete p;
}

std::shared_ptr<LLSoundCache> LLSoundCache::getInstance()
{
    {
        if(instance == nullptr)
        {
            ll_assert(was_destroyed==false, "LLSoundCache instance was destoryed");
            instance = std::shared_ptr<LLSoundCache>(new LLSoundCache(), LLSoundCacheDelFunc);
        }
    }
    
    return instance;
}

LLSoundCache::LLSoundCache()
{
}

LLSoundCache::~LLSoundCache()
{
    instance.reset();
    was_destroyed = true;

    releaseAllCache();
}

bool LLSoundCache::hasFileCache(const std::string &fileName)
{
    if(bufferCache.count(fileName) == 0)
    {
        return false;
    }

    return true;
}

const SoundEffectData LLSoundCache::getFileCache(const std::string& fileName)
{
    if (!hasFileCache(fileName))
    {
        loadMem(fileName);
    }
    
    return bufferCache[fileName];
}

void LLSoundCache::loadMem(const std::string& fileName)
{
    if (hasFileCache(fileName))
    {
        return;
    }
    
    ExtAudioFileRef audioRef;
    NSString* nsFilePath = [NSString stringWithCString:fileName.c_str() encoding:NSUTF8StringEncoding];
    CFURLRef urlFilePath = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)nsFilePath, kCFURLPOSIXPathStyle, false);
    SoundEffectData data;

    OSStatus result = ExtAudioFileOpenURL(urlFilePath, &audioRef);
    ll_assert_arg(result==0, "Audio File Open Error \"%s\"", fileName.c_str());
    
    // urlFilePathを解放
    CFRelease(urlFilePath);

    //ファイルデータフォーマットを取得
    AudioStreamBasicDescription asbd;
    UInt32 propSize = sizeof(asbd);
    result = ExtAudioFileGetProperty(audioRef,
                                     kExtAudioFileProperty_FileDataFormat,
                                     &propSize,
                                     &asbd);
    ll_assert(result==0, "Format get Error");

    AudioStreamBasicDescription clientDescription = LinearPcmDescription(asbd.mSampleRate, asbd.mChannelsPerFrame);

    data.sampleRate = asbd.mSampleRate;
    data.numberOfChannels = asbd.mChannelsPerFrame;
    
    //読み込むフォーマットをリニアPCMに変換
    result = ExtAudioFileSetProperty(audioRef,
                                     kExtAudioFileProperty_ClientDataFormat,
                                     sizeof(AudioStreamBasicDescription),
                                     &clientDescription);
    ll_assert(result==0, "PCM conversion error");
    
    //トータルフレーム数取得
    SInt64 fileLengthFrames;
    propSize = sizeof(SInt64);
    result = ExtAudioFileGetProperty(audioRef,
                                     kExtAudioFileProperty_FileLengthFrames,
                                     &propSize,
                                     &fileLengthFrames);
    ll_assert(result==0, "cannot get totalframe from audiofile");
    data.totalFrames = fileLengthFrames;
    
    // 必要バッファ分のメモリ確保
    data.playBuffer = new AudioUnitSampleType*[data.numberOfChannels];
    for (int i=0; i < data.numberOfChannels; i++)
    {
        data.playBuffer[i] = new AudioUnitSampleType[data.totalFrames];
    }
    
    AudioBufferList* audioBufferList = new AudioBufferList;
    audioBufferList->mNumberBuffers = data.numberOfChannels;
    for (int i=0; i < data.numberOfChannels; i++)
    {
        audioBufferList->mBuffers[i].mNumberChannels = 1;
        audioBufferList->mBuffers[i].mDataByteSize = sizeof(AudioUnitSampleType) * data.totalFrames;
        audioBufferList->mBuffers[i].mData = data.playBuffer[i];
    }
    
    //すべてをバッファに格納
    UInt32 readFrameSize = fileLengthFrames;
    result = ExtAudioFileRead(audioRef,
                              &readFrameSize,
                              audioBufferList);
    ll_assert(result==0, "audio buffer read error");

    ExtAudioFileDispose(audioRef);
    delete audioBufferList;
    
    // キャッシュテーブルにセット
    // 内部はただの整数値3つとポインタ一つのためコピーに時間がかからない
    bufferCache[fileName] = data;
}

void LLSoundCache::releaseCache(const std::string& fileName)
{
    if (!hasFileCache(fileName))
    {
        return;
    }
    
    UInt32 numChannel = bufferCache[fileName].numberOfChannels;
    for (int i=0; i < numChannel; i++)
    {
        delete bufferCache[fileName].playBuffer[i];
    }
    
    if (bufferCache[fileName].playBuffer)
    {
        delete [] bufferCache[fileName].playBuffer;
    }
}


void LLSoundCache::releaseAllCache()
{
    for(auto it = bufferCache.begin(); it != bufferCache.end();)
    {
        releaseCache(it->first);
        it = bufferCache.erase(it);
    }
}
