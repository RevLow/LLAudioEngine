//
//  LLAudioSessionUtil.cpp
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/18.
//
//

#include "LLAudioSessionUtil.h"

#import <AVFoundation/AVAudioSession.h>
#import "LLAudioSessionObserver.h"

#define IOS_HARDWARE_BUFFER_SIZE 256

static LLAudioSessionObserver* observer = [[LLAudioSessionObserver alloc] init];

void LLAudioSessionUtil::initialize()
{
    AVAudioSession* session = [AVAudioSession sharedInstance];

//    if (observer == nil)
//    {
//        observer =
//    }

    // サンプリング指定
    double rate = [session sampleRate];

    // 入出力のバッファの大きさを設定
    Float32 duration = IOS_HARDWARE_BUFFER_SIZE / rate;
    bool result = [session setPreferredIOBufferDuration:duration error:nil];

    // カテゴリ指定
    // このアプリケーション自体の音以外を再生しない
    result = [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    if (notificationCenter != nil)
    {
        // ヘッドホンの抜き差しの通知設定
        [notificationCenter addObserver:observer selector:@selector(audioSessionRouteChangeObserver:) name:@"AVAudioSessionRouteChangeNotification" object:nil];
        
        // 電話の割り込み処理の設定
        [notificationCenter addObserver:observer selector:@selector(audioSessionInterruptionObserver:) name:@"AVAudioSessionInterruptionNotification" object:nil];
    }

    // AudioSessonの利用開始
    [session setActive:YES error:nil];
}

void LLAudioSessionUtil::setRouteChangeCallback(void(*func)(int))
{
    [observer setRouteChangeCallback:func];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

void LLAudioSessionUtil::setSessionInterruptionCallback(void(*func)(int))
{
    [observer setInterruptionCallback:func];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}
