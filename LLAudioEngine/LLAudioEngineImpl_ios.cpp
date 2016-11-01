//
//  LLAudioEngineImpl.cpp
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/30.
//
//

#include "LLAudioEngineImpl_ios.h"
#include "LLSoundCache.h"
#include "LLSoundEffect.h"
#include "LLBackgroundMusic.h"

LLAudioEngineImpl::LLAudioEngineImpl()
{
    std::thread th(&LLAudioEngineImpl::cleanup, this);
    th.detach();
}

LLAudioEngineImpl::~LLAudioEngineImpl()
{
    if(_music != nullptr) _music.reset();
    for (auto effect : _effectBuffer)
    {
        effect->stop();
        delete effect;
        _effectBuffer.remove(effect);
    }
}

void LLAudioEngineImpl::playBackgroundMusic(const std::string& fileName, bool repeat)
{
    std::unique_ptr<LLBackgroundMusic> ptr(new LLBackgroundMusic(fileName));
    if(_music != nullptr)
    {
        _music->stop();
        _music.swap(ptr);
    }
    else
    {
        _music = std::move(ptr);
    }
    _music->setLoop(repeat);
    _music->play();
}

void LLAudioEngineImpl::stopBackgroundMusic()
{
    if(_music == nullptr || !_music->isPlaying()) return;
    _music->stop();
}

void LLAudioEngineImpl::resumeBackgroundMusic()
{
    if(_music == nullptr || _music->isPlaying()) return;
    _music->play();
}

void LLAudioEngineImpl::pauseBackgroundMusic()
{
    if(_music == nullptr || !_music->isPlaying()) return;
    _music->pause();
}

void LLAudioEngineImpl::seekBackgroundMusic(float millisec)
{
    if(_music == nullptr) return;
    _music->seek(millisec);
}

float LLAudioEngineImpl::tellBackgroundMusic() const
{
    if(_music == nullptr) return 0;
    return _music->tell();
}

bool LLAudioEngineImpl::isBackgroundMusicPlaying() const
{
    if(_music == nullptr) return false;
    return _music->isPlaying();
}

void LLAudioEngineImpl::setBackgroundMusicVolume(const float& volume)
{
    _music->setVolume(volume);
}

float LLAudioEngineImpl::getBackgroundMusicVolume() const
{
    return _music->getVolume();
}

void LLAudioEngineImpl::setBackgroundExitCallback(const std::function<void(void)>& func)
{
    if(_music == nullptr) return;
    _music->setOnExitCallback(func);
}

void LLAudioEngineImpl::playEffect(const std::string& fileName)
{
    LLSoundEffect* effect = new LLSoundEffect(fileName);
    if (effect != nullptr)
    {
        effect->play();
        _effectBuffer.push_back(effect);
    }
}

void LLAudioEngineImpl::pauseAllEffect()
{
    for(auto effect : _effectBuffer)
    {
        effect->pause();
    }
}

void LLAudioEngineImpl::stopAllEffect()
{
    for(auto effect : _effectBuffer)
    {
        effect->stop();
    }
}

void LLAudioEngineImpl::setEffectVolume(const float& vol)
{
    LLSoundEffect::setVolume(vol);
}

float LLAudioEngineImpl::getEffectVolume() const
{
    return LLSoundEffect::getVolume();
}

void LLAudioEngineImpl::preloadEffect(const std::string& fileName)
{
    LLSoundCache::getInstance()->loadMem(fileName);
}

void LLAudioEngineImpl::unloadEffect(const std::string& fileName)
{
    LLSoundCache::getInstance()->releaseCache(fileName);
}

void LLAudioEngineImpl::unloadAllEffect()
{
    LLSoundCache::getInstance()->releaseAllCache();
}

void LLAudioEngineImpl::cleanup()
{
    while (true)
    {
        for (auto it = _effectBuffer.begin(); it != _effectBuffer.end(); )
        {
            if(!(*it)->isPlaying())
            {
                delete *it;
                it = _effectBuffer.erase(it);
                continue;
            }
            
            it++;
        }
        
        // 50ミリ秒に一回クリーンアップを実行する
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
}