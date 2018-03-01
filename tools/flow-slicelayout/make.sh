#!/bin/sh
if ! mkdir -p build/classes; then
    echo "Error creating build/classes dir"
    exit 1
fi

echo "Compiling into build/classes"
if ! javac -d build/classes SliceLayout.java; then
    echo "Build failed"
    exit 1
fi


if ! mkdir -p build/lib; then
    echo "Error creating build/lib dir"
    exit 1
fi

echo "Creating build/lib/SliceLayout.jar"
if ! jar -cfe build/lib/SliceLayout.jar SliceLayout -C build/classes . ; then
    echo "Error creating jar"
    exit 1
fi
