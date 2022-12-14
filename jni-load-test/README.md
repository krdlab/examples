```bash
$ docker build -t jni-load-test .
$ docker run --rm -it -v $PWD:/work jni-load-test bash

$ bash build.sh

$ java -Djava.library.path=src -classpath src App
I'm V1
I'm V2

$ rm src/libV2.so
$ objcopy --redefine-sym Java_V1_run=Java_V2_run src/libV1.so src/libV2.so

$ java -Djava.library.path=src -classpath src App
I'm V1
Exception in thread "main" java.lang.UnsatisfiedLinkError: 'java.lang.String V2.run()'
        at V2.run(Native Method)
        at App.main(App.java:4)

# ↑ .dynsym にある Java_V1_run は書き換えられていないため
# readelf -s -W src/libV2.so
# readelf --dyn-sym -W src/libV2.so
```
