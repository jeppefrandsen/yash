#!/bin/bash
set -e

CMAKE_ARGS="-DBUILD_TEST=1"

if [ "$1" = "example" ]; then
  CMAKE_ARGS="-DBUILD_EXAMPLE=1"
fi

if [ "$(uname)" = "Linux" ]; then
  CPU_CORES="$(nproc)"
  TOOLCHAIN_FILE="-DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake"
elif [ "$(uname)" = "Darwin" ]; then
  CPU_CORES="$(sysctl -n hw.ncpu)"
  TOOLCHAIN_FILE="-DCMAKE_TOOLCHAIN_FILE=cmake/clang.cmake"
fi

mkdir -p .build-external; pushd .build-external
cmake ../external
make -j "$CPU_CORES"
popd

arch_name="$(uname -m)"

mkdir -p ".build-$arch_name"; pushd ".build-$arch_name"
cmake "$CMAKE_ARGS" "$TOOLCHAIN_FILE" ..
make -j "$CPU_CORES"

if [ "$1" = "coverage" ]; then
  lcov -q -c -i -d . -o base.info
  ctest --verbose
  lcov -q -c -d . -o test.info 2>/dev/null
  lcov -q -a base.info -a test.info > total.info
  lcov -q -r total.info "*usr/include/*" "*CMakeFiles*" "*Catch2*" "*turtle*" "*/test/*" "*src/*" -o coverage.info
  genhtml -o coverage coverage.info
  echo "Coverage report can be found in $(pwd)/coverage"
fi

popd
