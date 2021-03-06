//
//  LLAudioSessionUtil.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/18.
//
//

#ifndef __LLAudioEngine__LLAudioSessionUtil__
#define __LLAudioEngine__LLAudioSessionUtil__

namespace LLAudioSessionUtil
{
    void initialize();
    void setRouteChangeCallback(void(*func)(int));
    void setSessionInterruptionCallback(void(*func)(int));
};

#endif /* defined(__LLAudioEngine__LLAudioSessionUtil__) */
