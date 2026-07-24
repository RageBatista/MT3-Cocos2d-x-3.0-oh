cmake_minimum_required(VERSION 3.6)

project(SLJFPPackageConsumer LANGUAGES CXX)

find_package(SuperLJFilePackUnpack CONFIG REQUIRED)

add_executable(sljfp_package_consumer main.cpp)
target_link_libraries(sljfp_package_consumer PRIVATE SuperLJFilePackUnpack::SuperLJFilePackUnpack)
