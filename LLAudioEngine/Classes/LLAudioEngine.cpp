//
//  LLAudioEngine.cpp
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/30.
//
//

#include "LLAudioEngine.h"
#include "LLAudioEngineImpl_ios.h"
#include "LLAudioAssertion.h"

std::shared_ptr<LLAudioEngine> LLAudioEngine::instance;

void LLAudioEngineDelFunc(LLAudioEngine* p)
{
    ll_assert(p != nullptr, "p was deleted. But call destractor");
    delete p;
}


std::shared_ptr<LLAudioEngine> LLAudioEngine::getInstance()
{
    if (instance == nullptr)
    {
        instance = std::shared_ptr<LLAudioEngine>(new LLAudioEngine, LLAudioEngineDelFunc);
    }

    return instance;
}

LLAudioEngine::LLAudioEngine()
{
    pImpl = std::unique_ptr<LLAudioEngineImpl>(new LLAudioEngineImpl);
}

LLAudioEngine::~LLAudioEngine()
{
}

void LLAudioEngine::playBackgroundMusic(const std::string& fileName, bool repeat)
{
    pImpl->playBackgroundMusic(fileName, repeat);
}

void LLAudioEngine::stopBackgroundMusic()
{
    pImpl->stopBackgroundMusic();
}

void LLAudioEngine::resumeBackgroundMusic()
{
    pImpl->resumeBackgroundMusic();
}

void LLAudioEngine::pauseBackgroundMusic()
{
    pImpl->pauseBackgroundMusic();
}

void LLAudioEngine::seekBackgroundMusic(float millisec)
{
    pImpl->seekBackgroundMusic(millisec);
}

float LLAudioEngine::tellBackgroundMusic() const
{
    return pImpl->tellBackgroundMusic();
}

bool LLAudioEngine::isBackgroundMusicPlaying() const
{
    return pImpl->isBackgroundMusicPlaying();
}

void LLAudioEngine::setBackgroundMusic(const float& volume)
{
    pImpl->setBackgroundMusicVolume(volume);
}

float LLAudioEngine::getBackgroundMusic() const
{
    return pImpl->getBackgroundMusicVolume();
}

void LLAudioEngine::setBackgroundExitCallback(const std::function<void(void)>& func)
{
    pImpl->setBackgroundExitCallback(func);
}

void LLAudioEngine::playEffect(const std::string& fileName)
{
    pImpl->playEffect(fileName);
}

void LLAudioEngine::pauseAllEffect()
{
    pImpl->pauseAllEffect();
}

void LLAudioEngine::stopAllEffect()
{
    pImpl->stopAllEffect();
}

void LLAudioEngine::setEffectVolume(const float& vol)
{
    pImpl->setEffectVolume(vol);
}

float LLAudioEngine::getEffectVolume() const
{
    return pImpl->getEffectVolume();
}

void LLAudioEngine::preloadEffect(const std::string& fileName)
{
    pImpl->preloadEffect(fileName);
}

void LLAudioEngine::unloadEffect(const std::string& fileName)
{
    pImpl->unloadEffect(fileName);
}

void LLAudioEngine::unloadAllEffect()
{
    pImpl->unloadAllEffect();
}
