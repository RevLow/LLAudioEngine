//
//  LLAudioAssertion.h
//  LLAudioEngine
//
//  Created by RevLow on 2016/10/23.
//
//

#ifndef LLAudioEngine_LLAudioAssertion_h
#define LLAudioEngine_LLAudioAssertion_h

#ifdef DEBUG
#include <stdio.h>
#include <stdlib.h>

//デバッグモード時のデフォルトアサート
#define ll_assert(expr, msg)\
if(!(expr)) {\
    printf("Assertion failed in [%s]:%s:%d " msg "\n", __FILE__, __func__, __LINE__);\
    abort();\
}

#define ll_assert_arg(expr, msg,...)\
if(!(expr)){\
  printf("Assertion failed in [%s]:%s:%d " msg "\n", __FILE__, __func__, __LINE__, __VA_ARGS__);\
  abort();\
}

#else

//リリース時は無効にする
#define ll_assert(...)
#define ll_assert_arg(...)
#endif

#endif
