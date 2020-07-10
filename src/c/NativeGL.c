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

JNIEXPORT jlong JNICALL Java_NativeGL_create_1window(JNIEnv *env, jclass cls, jbyteArray title, jint x, jint y, jint w, jint h, jint flags)
{
  //const jchar *s = (*env)->GetStringChars(env, title, NULL);
  jbyte* javaStringByte = (*env)->GetByteArrayElements(env, title, NULL);
  jsize javaStringlen = (*env)->GetArrayLength(env,title);

  SDL_Window *window = SDL_CreateWindow((const char *)javaStringByte, x, y, w, h, flags);
  if (window == NULL)
    {
      SDL_Log("Unable to create window: %s", SDL_GetError());
    }
  //(*env)->ReleaseStringChars(env, title, s);
  return (jlong)window;
}

JNIEXPORT void JNICALL Java_NativeGL_destroy_1window(JNIEnv *env, jclass cls, jlong window)
{
  SDL_DestroyWindow((SDL_Window *)window);
}
