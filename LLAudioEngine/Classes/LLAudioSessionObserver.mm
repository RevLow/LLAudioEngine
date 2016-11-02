//
//  LLAudioSessionObserver.m
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/19.
//
//

#import "LLAudioSessionObserver.h"
#import <AVFoundation/AVAudioSession.h>
#include "LLAudioEngine.h"

@implementation LLAudioSessionObserver

- (void)dealloc
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    if (notification != nil)
    {
        //オブザーバーから消去
        [notification removeObserver:self];
    }
}

- (void)setRouteChangeCallback: (CallbackFunc)func
{
    routeChangeCallback = func;
}

- (void)setInterruptionCallback: (CallbackFunc) func
{
    interruptionCallback = func;
}

/**
 *  ヘッドホンの抜き差しを行ったときに呼ばれる
 *
 *  @param notification 通知の情報
 */
- (void)audioSessionRouteChangeObserver:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    AVAudioSessionRouteChangeReason audioSessionReason = static_cast<AVAudioSessionRouteChangeReason>([userInfo[@"AVAudioSessionRouteChangeReasonKey"] longValue]);
    
    // 信号経路変更の理由により分岐
    switch (audioSessionReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            break;
        default:
            break;
    }

    if (routeChangeCallback != NULL)
    {
        routeChangeCallback(audioSessionReason);
    }
}

/**
 *  電話の着信割り込みの処理
 *
 *  @param notification 通知の情報
 */
- (void)audioSessionInterruptionObserver:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    AVAudioSessionInterruptionType audioSessionInterruption = static_cast<AVAudioSessionInterruptionType>([userInfo[@"AVAudioSessionInterruptionTypeKey"] longValue]);
    switch (audioSessionInterruption)
    {
        case AVAudioSessionInterruptionTypeBegan:
            // 割り込み検知
            _interrupted = YES;
            break;
        case AVAudioSessionInterruptionTypeEnded:
            // 割り込み終了
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            if (_interrupted)
            {
                LLAudioEngine::getInstance()->resumeBackgroundMusic();
                _interrupted = NO;
            }
            break;
        default:
            break;
    }
    
    //コールバックを実行
    if (interruptionCallback != NULL)
    {
        interruptionCallback(audioSessionInterruption);
    }
}
@end
