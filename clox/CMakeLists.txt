# Set the minimum version of CMake that's required
cmake_minimum_required(VERSION 3.10)

# Set the project name and version
project(MyProject VERSION 1.0)

# Specify the C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

# Add the include directory for the compiler
include_directories(include)

# Generate the compile_commands.json for better language server integration
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Tell CMake to configure the executable
add_executable(clox
  src/chunk.c
  src/debug.c
  src/main.c
  src/memory.c
  src/value.c
  src/vm.c)

if(CMAKE_EXPORT_COMPILE_COMMANDS)
  add_custom_command(TARGET clox POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy_if_different
                     ${CMAKE_BINARY_DIR}/compile_commands.json
                     ${CMAKE_SOURCE_DIR}/compile_commands.json)
endif()
