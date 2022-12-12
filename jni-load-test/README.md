```bash
docker build -t jni-load-test .
docker run --rm -it -v $PWD:/work jni-load-test bash

bash build.sh

java -Djava.library.path=src -classpath src App
```
