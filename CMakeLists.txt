#### CMakeLists.txt : CMake configuration and build script
####                  for the gtDMMB/gtfold sources
#### Author: Maxie D. Schmidt (github.com/maxieds)
#### Created: 2021.02.10

## CMake specific configuration and build environment settings:
cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_BUILD_TYPE Release)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_LINKER g++)
set(SHELL /bin/bash)
set(CMAKE_RULE_MESSAGES ON)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

## Define the PMFE project and define the output binaries:
project(gtDMMB_PMFE)

set(GTFOLD_VERSION_MAJOR "1")
set(GTFOLD_VERSION_MINOR "0")
set(GTFOLD_VERSION_PATCH "0")
set(VERSION "${GTFOLD_VERSION_MAJOR}.${GTFOLD_VERSION_MINOR}.${GTFOLD_VERSION_PATCH}")
set(GTFOLD_PACKAGE_NAME "gtDMMB-PMFE")
set(GTFOLD_PACKAGE_VERSION ${VERSION})
set(GTFOLD_PACKAGE_STRING "${GTFOLD_PACKAGE_NAME} v${GTFOLD_PACKAGE_VERSION}")

## Option to enable auto running of unit tests after recompiling:
option(RUN_UNIT_TESTS "Enable running tests after build" FALSE)

## Configure pkg-config script for some dependency libraries (LIBGMP and LIBGMPXX):
include(FindPkgConfig)
if(NOT PKG_CONFIG_FOUND)
     message(FATAL_ERROR "Unable to configure libGMP(xx) : pkg-config not found ..." )
endif()

execute_process(
     COMMAND bash -c "pkg-config gmp --cflags"
     OUTPUT_VARIABLE PC_GMP_INCLUDE_DIRS
)
string(STRIP "${PC_GMP_INCLUDE_DIRS}" PC_GMP_INCLUDE_DIRS)
execute_process(
     COMMAND bash -c "pkg-config gmp --libs --static"
     OUTPUT_VARIABLE PC_GMP_LIBRARIES
)
string(STRIP "${PC_GMP_LIBRARIES}" PC_GMP_LIBRARIES)

execute_process(
     COMMAND bash -c "pkg-config gmpxx --cflags"
     OUTPUT_VARIABLE PC_GMPXX_INCLUDE_DIRS
)
string(STRIP "${PC_GMPXX_INCLUDE_DIRS}" PC_GMPXX_INCLUDE_DIRS)
execute_process(
     COMMAND bash -c "pkg-config gmpxx --libs --static"
     OUTPUT_VARIABLE PC_GMPXX_LIBRARIES
)
string(STRIP "${PC_GMPXX_LIBRARIES}" PC_GMPXX_LIBRARIES)

## Build the binaries for the GTFold (gtfold-mfe) project:

file(GLOB ALL_TARGET_SOURCES gtfold-mfe/src/*.cc gtfold-mfe/src/*.c gtfold-mfe/include/*.h)
set(PROJECT_GTFOLDMFE_SOURCE_DIR "${PROJECT_SOURCE_DIR}/gtfold-mfe")
include_directories("${PROJECT_GTFOLDMFE_SOURCE_DIR}/include")

add_executable(
    gtfold ${ALL_TARGET_SOURCES} gtfold-mfe/src/binexe-utils/main.cc
)
set_target_properties(
     gtfold PROPERTIES
     OUTPUT_NAME "gtfold"
     COMPILE_FLAGS "${CMAKE_CXX_FLAGS}"
)

add_executable(
    gtmfe ${ALL_TARGET_SOURCES} gtfold-mfe/src/mfe_main.cc gtfold-mfe/src/binexe-utils/main.cc
)
set_target_properties(
     gtmfe PROPERTIES
     OUTPUT_NAME "gtmfe"
     COMPILE_FLAGS "${CMAKE_CXX_FLAGS}"
)

add_executable(
    gtsubopt ${ALL_TARGET_SOURCES} gtfold-mfe/src/subopt_main.cc gtfold-mfe/src/binexe-utils/main.cc
)
set_target_properties(
     gtsubopt PROPERTIES
     OUTPUT_NAME "gtsubopt"
     COMPILE_FLAGS "${CMAKE_CXX_FLAGS}"
)

add_executable(
    gtboltzmann ${ALL_TARGET_SOURCES} gtfold-mfe/src/boltzmann_main.cc gtfold-mfe/src/binexe-utils/main.cc
)
set_target_properties(
     gtboltzmann PROPERTIES
     OUTPUT_NAME "gtboltzmann"
     COMPILE_FLAGS "${CMAKE_CXX_FLAGS}"
)

add_executable(
    gtfold-test ${ALL_TARGET_SOURCES} gtfold-mfe/src/binexe-utils/test_ss_constraint.c
)
set_target_properties(
     gtfold-test PROPERTIES
     OUTPUT_NAME "gtfold-test"
     COMPILE_FLAGS "${CMAKE_CXX_FLAGS}"
)

## Install targets (both for binary sub-utilities and the
## Python library to be used with SageMath):
if(IS_DIRECTORY "/opt/rh/devtoolset-9/root/usr/lib/gcc/x86_64-redhat-linux/9")
     set(RHEL_INCLUDE_APPENDS "-I/opt/rh/devtoolset-9/root/usr/include/c++/9")
     set(RHEL_LINKER_APPENDS "-L/opt/rh/devtoolset-9/root/usr/lib/gcc/x86_64-redhat-linux/9")
else()
     set(RHEL_INCLUDE_APPENDS "")
     set(RHEL_LINKER_APPENDS "")
endif()
if(APPLE)
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -Wall -mlinker-version=450 -isystem /usr/local/opt/llvm/include \
        -std=c++11 -fPIC -fopenmp -g -O2 -fno-lto \
        -stdlib=libc++ -nostdinc++ \
        -I/usr/local/opt/llvm/include/c++/v1 /usr/local/opt/llvm/lib/libc++.dylib -stdlib=libc++  \
        -I/usr/local/opt/llvm/include -I/usr/local/include -Igtfold-mfe/include/ \
        -DGTFOLD_PACKAGE_VERSION=\"${GTFOLD_PACKAGE_VERSION}\"" #${PC_GMP_INCLUDE_DIRS} ${PC_GMPXX_INCLUDE_DIRS}
    )
    # NOTE: Providing the explicit LLVM linker path seems to fix the problems on Mojave.
    set(CMAKE_EXE_LINKER_FLAGS
        "${CMAKE_CXX_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} \
         -mlinker-version=450 -L/usr/local/lib -lm -lpthread \
        -L/usr/local/opt/llvm/lib ${PC_GMP_LIBRARIES} ${PC_GMPXX_LIBRARIES}"
    )
elseif(UNIX AND NOT APPLE) # Primary target: Linux (typically RHEL)
    set(CMAKE_CXX_FLAGS
        "-fPIC -fopenmp -Wall -g -O2 -fvisibility=hidden -fvisibility-inlines-hidden \
        -Igtfold-mfe/include ${RHEL_INCLUDE_APPENDS} ${CMAKE_CXX_FLAGS}"
    )
    set(CMAKE_EXE_LINKER_FLAGS
        "${RHEL_LINKER_APPENDS} -L/usr/lib -L/usr/local/lib -lpthread \
        ${CMAKE_EXE_LINKER_FLAGS} ${PC_GMPXX_LIBRARIES} ${PC_GMP_LIBRARIES}"
    )
endif()

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS}")

install(
     TARGETS gtfold gtmfe gtsubopt gtboltzmann gtfold-test
     DESTINATION ${EXECUTABLE_OUTPUT_PATH}
)

## Running of unit tests configuration:
add_custom_command(
    TARGET gtfold-test POST_BUILD
    COMMAND bash -c "${CMAKE_COMMAND} -DRUN_UNIT_TESTS=${RUN_UNIT_TESTS} -P CMakeRunUnitTests.cmake"
)
