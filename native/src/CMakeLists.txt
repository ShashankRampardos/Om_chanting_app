cmake_minimum_required(VERSION 3.10)
project(om)

add_library(om SHARED om.cpp)

target_include_directories(om PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
