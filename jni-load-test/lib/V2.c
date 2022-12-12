#include "V2.h"

JNIEXPORT jstring JNICALL Java_V2_run(JNIEnv *env, jclass clazz)
{
  jstring res = (*env)->NewStringUTF(env, "I'm V2");
  return res;
}
