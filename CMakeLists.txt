#### CMakeLists.txt : CMake configuration and build script
####                  for the gtDMMB/gtfold sources
#### Author: Maxie D. Schmidt (github.com/maxieds)
#### Created: 2021.03.24

## CMake specific configuration and build environment settings:
cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

if(DEFINED MACOS_OFFICE_BOX)
     message(" >> COPYING CMakeLists.txt CONFIG for MacOS Office Box (10.14/Mojave)")
     include("GTFoldCMakeBuild/CMakeLists.txt-clang-macos10.14-office")
elseif(DEFINED LINUX_GCC)
     message(" >> COPYING CMakeLists.txt CONFIG for Linux/Generic Unix using gcc/g++")
     include("GTFoldCMakeBuild/CMakeLists.txt-linux-unix-g++")
else()
     message(" >> COPYING CMakeLists.txt CONFIG for MacMini Desktop Box (10.14/Mojave)")
     include("GTFoldCMakeBuild/CMakeLists.txt-clang-macmini10.14-desktop")
endif()
