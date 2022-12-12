set -eu

javac src/V1.java -h lib
javac src/V2.java -h lib

gcc -I/usr/lib/jvm/java-11-amazon-corretto/include -I/usr/lib/jvm/java-11-amazon-corretto/include/linux lib/V1.c -shared -o src/libV1.so
gcc -I/usr/lib/jvm/java-11-amazon-corretto/include -I/usr/lib/jvm/java-11-amazon-corretto/include/linux lib/V2.c -shared -o src/libV2.so

javac -classpath src src/App.java
