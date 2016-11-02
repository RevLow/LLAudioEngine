//
//  LLSoundCache.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/22.
//
//

#ifndef __LLAudioEngine__LLSoundCache__
#define __LLAudioEngine__LLSoundCache__

#import <AudioToolbox/AudioToolbox.h>
#include "LLAudio.h"

class LLSoundCache
{
    friend void LLSoundCacheDelFunc(LLSoundCache* p);
public:
    static std::shared_ptr<LLSoundCache> getInstance();

    const SoundEffectData getFileCache(const std::string& fileName);
    void loadMem(const std::string& fileName);
    void releaseCache(const std::string& fileName);
    void releaseAllCache();
private:
    LLSoundCache();
    ~LLSoundCache();
    LLSoundCache(const LLSoundCache& cache){}
    LLSoundCache& operator=(const LLSoundCache& cache){ return *this; }
    bool hasFileCache(const std::string& fileName);

    static std::shared_ptr<LLSoundCache> instance;
    static bool was_destroyed;
    
    std::unordered_map<std::string, SoundEffectData>  bufferCache;
};


#endif /* defined(__LLAudioEngine__LLSoundCache__) */
