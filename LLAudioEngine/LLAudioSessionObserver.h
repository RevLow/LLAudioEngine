//
//  LLAudioSessionObserver.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/19.
//
//

#import <Foundation/Foundation.h>

typedef void (*CallbackFunc)(int);

@interface LLAudioSessionObserver : NSObject
{
    // ヘッドホンを抜き差ししたコールバック
    CallbackFunc routeChangeCallback;
    //割り込み時のコールバック
    CallbackFunc interruptionCallback;
}
@property (nonatomic, assign) BOOL interrupted;
- (void)dealloc;
- (void)audioSessionRouteChangeObserver:(NSNotification*)notification;
- (void)audioSessionInterruptionObserver:(NSNotification*)notification;
- (void)setRouteChangeCallback: (CallbackFunc) func;
- (void)setInterruptionCallback: (CallbackFunc) func;
@end
