//
//  LLAudioEngine.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/30.
//
//

#ifndef __LLAudioEngine__LLAudioEngine__
#define __LLAudioEngine__LLAudioEngine__

class LLAudioEngineImpl;

class LLAudioEngine
{
    friend void LLAudioEngineDelFunc(LLAudioEngine* p);
public:
    static std::shared_ptr<LLAudioEngine> getInstance();
    void playBackgroundMusic(const std::string& fileName, bool repeat = false);
    void stopBackgroundMusic();
    void resumeBackgroundMusic();
    void pauseBackgroundMusic();
    void seekBackgroundMusic(float millisec);
    float tellBackgroundMusic() const;
    bool isBackgroundMusicPlaying() const;
    void setBackgroundMusic(const float& volume);
    float getBackgroundMusic() const;
    void setBackgroundExitCallback(const std::function<void(void)>& func);
    void playEffect(const std::string& fileName);
    void pauseAllEffect();
    void stopAllEffect();
    void setEffectVolume(const float& vol);
    float getEffectVolume() const;
    void preloadEffect(const std::string& fileName);
    void unloadEffect(const std::string& fileName);
    void unloadAllEffect();
    void soundEffectCleanUp();
    const LLAudioEngine& operator=(const LLAudioEngine&) = delete;
    LLAudioEngine(const LLAudioEngine&) = delete;
private:
    LLAudioEngine();
    ~LLAudioEngine();
    std::unique_ptr<LLAudioEngineImpl> pImpl;
    static std::shared_ptr<LLAudioEngine> instance;
};

#endif /* defined(__LLAudioEngine__LLAudioEngine__) */
