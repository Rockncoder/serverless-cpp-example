cmake_minimum_required(VERSION 3.5)
set(CMAKE_CXX_STANDARD 17)
project("serverless-cpp-example" LANGUAGES C CXX)

find_package(aws-lambda-runtime REQUIRED)

add_library(
  base64 STATIC
    base64/lib/libb64/src/cdecode.c
    base64/lib/libb64/src/cencode.c
    base64/src/base64.cpp
)

target_include_directories(base64 PRIVATE base64/lib/libb64/include)
target_include_directories(base64 PUBLIC base64/src)

add_executable("example" example.cpp)

target_link_libraries("example" PUBLIC AWS::aws-lambda-runtime base64)

aws_lambda_package_target("example")

# CTest / doctest test runner
enable_testing()

add_library(test_runner OBJECT test_runner_main.cpp)

add_executable(test_example test_example.cpp $<TARGET_OBJECTS:test_runner>)
add_test(NAME test_example COMMAND ${CTEST_BINARY_OUTPUT_DIRECTORY}test_example)
