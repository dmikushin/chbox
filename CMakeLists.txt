cmake_minimum_required(VERSION 3.5)

project(fakeroot LANGUAGES C)

add_library(${PROJECT_NAME}_communicate STATIC
	src/communicate.c)
target_include_directories(${PROJECT_NAME}_communicate PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_compile_definitions(${PROJECT_NAME}_communicate PRIVATE HAVE_CONFIG_H)
set_property(TARGET ${PROJECT_NAME}_communicate PROPERTY POSITION_INDEPENDENT_CODE ON)

add_library(${PROJECT_NAME} SHARED
	src/libfakeroot.c
	src/libfakeroot_time64.c)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_CONFIG_H)
target_link_libraries(${PROJECT_NAME} ${PROJECT_NAME}_communicate ${CMAKE_DL_LIBS})

add_executable(faked src/faked.c)
target_compile_definitions(faked PRIVATE HAVE_CONFIG_H)
target_include_directories(faked PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(faked ${PROJECT_NAME}_communicate ${CMAKE_DL_LIBS})
