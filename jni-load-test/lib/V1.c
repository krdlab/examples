#include "V1.h"

JNIEXPORT jstring JNICALL Java_V1_run(JNIEnv *env, jclass clazz)
{
  jstring res = (*env)->NewStringUTF(env, "I'm V1");
  return res;
}
