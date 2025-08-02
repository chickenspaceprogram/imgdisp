cmake_minimum_required(VERSION 3.21)

project(huffman CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
add_executable(huffman main.cpp huffman.cpp huffman.hpp)
