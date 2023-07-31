cmake_minimum_required(VERSION 3.1)

project(chbox LANGUAGES C)

include(ExternalProject)

find_program(MAKE_EXECUTABLE NAMES make REQUIRED)

set(fakeroot_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/bin/fakeroot")

ExternalProject_Add(fakeroot
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG fakeroot
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}
    BUILD_COMMAND ${MAKE_EXECUTABLE} -j
    INSTALL_COMMAND ${MAKE_EXECUTABLE} -j install
    TEST_COMMAND ""
    BUILD_BYPRODUCTS ${fakeroot_EXECUTABLE})

ExternalProject_Add_Step(fakeroot
    bootstrap
    COMMAND cd <SOURCE_DIR> && ./bootstrap
    DEPENDEES download
    DEPENDERS configure
)

add_executable(fakeroot::fakeroot IMPORTED)
set_property(TARGET fakeroot::fakeroot PROPERTY IMPORTED_LOCATION ${fakeroot_EXECUTABLE})
add_dependencies(fakeroot::fakeroot fakeroot)

set(fakechroot_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/bin/fakechroot")

ExternalProject_Add(fakechroot
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG fakechroot
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}
    BUILD_COMMAND ${MAKE_EXECUTABLE} -j
    INSTALL_COMMAND ${MAKE_EXECUTABLE} -j install
    TEST_COMMAND ""
    BUILD_BYPRODUCTS ${fakechroot_EXECUTABLE})

ExternalProject_Add_Step(fakechroot
    bootstrap
    COMMAND cd <SOURCE_DIR> && ./autogen.sh
    DEPENDEES download
    DEPENDERS configure
)

add_executable(fakechroot::fakechroot IMPORTED)
set_property(TARGET fakechroot::fakechroot PROPERTY IMPORTED_LOCATION ${fakechroot_EXECUTABLE})
add_dependencies(fakechroot::fakechroot fakechroot)

set(debootstrap_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/bin/debootstrap")

ExternalProject_Add(debootstrap
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG debootstrap
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${MAKE_EXECUTABLE} -C <SOURCE_DIR> install DESTDIR=${CMAKE_CURRENT_BINARY_DIR}
    TEST_COMMAND ""
    BUILD_BYPRODUCTS ${debootstrap_EXECUTABLE})

add_executable(debootstrap::debootstrap IMPORTED)
set_property(TARGET debootstrap::debootstrap PROPERTY IMPORTED_LOCATION ${debootstrap_EXECUTABLE})
add_dependencies(debootstrap::debootstrap debootstrap)

