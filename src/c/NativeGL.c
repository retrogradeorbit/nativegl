#include "NativeGL.h"
#include "SDL.h"

JNIEXPORT jint JNICALL Java_NativeGL_is_1a_1tty(JNIEnv *env, jclass cls)
{
  return 1;
}

JNIEXPORT jint JNICALL Java_NativeGL_init(JNIEnv *env, jclass cls)
{
   if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO) != 0) {
     SDL_Log("Unable to initialize SDL: %s", SDL_GetError());
     return 1;
   }
   return 0;
}

JNIEXPORT void JNICALL Java_NativeGL_quit(JNIEnv *env, jclass cls)
{
  SDL_Quit();
}
