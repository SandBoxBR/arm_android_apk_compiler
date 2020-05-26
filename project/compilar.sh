#!/bin/bash

set -e

AAPT="/home/sandbox/android-build-tools-for-arm/out/host/linux-arm/bin/aapt"
DX="/home/sandbox/android-build-tools-for-arm/out/host/linux-arm/bin/dx"
ZIPALIGN="/home/sandbox/android-build-tools-for-arm/out/host/linux-arm/bin/zipalign"
APKSIGNER="/home/sandbox/android-build-tools-for-arm/out/host/linux-arm/bin/apksigner" # /!\ version 26
PLATFORM="/home/sandbox/android-build-tools-for-arm/out/host/linux-arm/bin/android.jar"

echo "Cleaning..."
rm -rf obj/*
rm -rf src/com/example/helloandroid/R.java

echo "Generating R.java file..."
$AAPT package -f -m -J src -M AndroidManifest.xml -S res -I $PLATFORM

echo "Compiling..."
javac -d obj -classpath src -bootclasspath $PLATFORM -source 1.7 -target 1.7 src/com/example/helloandroid/MainActivity.java
javac -d obj -classpath src -bootclasspath $PLATFORM -source 1.7 -target 1.7 src/com/example/helloandroid/R.java

echo "Translating in Dalvik bytecode..."
$DX --dex --output=classes.dex obj

echo "Making APK..."
$AAPT package -f -m -F bin/hello.unaligned.apk -M AndroidManifest.xml -S res -I $PLATFORM
$AAPT add bin/hello.unaligned.apk classes.dex

echo "Aligning and signing APK..."
$APKSIGNER sign --ks mykey.keystore bin/hello.unaligned.apk
$ZIPALIGN -f 4 bin/hello.unaligned.apk bin/hello.apk
