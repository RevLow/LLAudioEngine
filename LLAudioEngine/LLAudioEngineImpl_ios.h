//
//  LLAudioEngineImpl.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/30.
//
//

#ifndef __LLAudioEngine__LLAudioEngineImpl__
#define __LLAudioEngine__LLAudioEngineImpl__

class LLSoundEffect;
class LLBackgroundMusic;

class LLAudioEngineImpl
{
public:
    LLAudioEngineImpl();
    ~LLAudioEngineImpl();
    const LLAudioEngineImpl& operator=(const LLAudioEngineImpl&)=delete;
    LLAudioEngineImpl(const LLAudioEngineImpl&)=delete;
    void playBackgroundMusic(const std::string& fileName, bool repeat = false);
    void stopBackgroundMusic();
    void resumeBackgroundMusic();
    void pauseBackgroundMusic();
    void seekBackgroundMusic(float millisec);
    float tellBackgroundMusic() const;
    bool isBackgroundMusicPlaying() const;
    void setBackgroundMusicVolume(const float& volume);
    float getBackgroundMusicVolume() const;
    void setBackgroundExitCallback(const std::function<void(void)>& func);
    void playEffect(const std::string& fileName);
    void pauseAllEffect();
    void stopAllEffect();
    void setEffectVolume(const float& vol);
    float getEffectVolume() const;
    void preloadEffect(const std::string& fileName);
    void unloadEffect(const std::string& fileName);
    void unloadAllEffect();
private:
    void cleanup();
    std::list<LLSoundEffect*> _effectBuffer;
    std::unique_ptr<LLBackgroundMusic> _music;
};

#endif /* defined(__LLAudioEngine__LLAudioEngineImpl__) */
