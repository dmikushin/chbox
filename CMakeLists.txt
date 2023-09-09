cmake_minimum_required(VERSION 3.1)

project(chbox LANGUAGES C)

option(DISABLE_HAVE_CAPSET "On Rocky Linux HAVE_CAPSET is causing errors and must be disabled" OFF)

include(ExternalProject)

find_program(MAKE_EXECUTABLE NAMES make REQUIRED)

set(fakeroot_EXECUTABLE "${CMAKE_INSTALL_PREFIX}/bin/fakeroot")

if (DISABLE_HAVE_CAPSET)
set(FAKEROOT_PATCH_COMMAND "${CMAKE_COMMAND} -E patch < ${CMAKE_CURRENT_SOURCE_DIR}/disable_have_capset.patch")
endif()

ExternalProject_Add(fakeroot
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG fakeroot
    PATCH_COMMAND ${FAKEROOT_PATCH_COMMAND}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_INSTALL_PREFIX}/fakeroot
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

set(fakechroot_EXECUTABLE "${CMAKE_INSTALL_PREFIX}/bin/fakechroot")

ExternalProject_Add(fakechroot
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG fakechroot
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_INSTALL_PREFIX}/fakechroot
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

set(debootstrap_EXECUTABLE "${CMAKE_INSTALL_PREFIX}/bin/debootstrap")

ExternalProject_Add(debootstrap
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG debootstrap
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${MAKE_EXECUTABLE} -C <SOURCE_DIR> install DESTDIR=${CMAKE_INSTALL_PREFIX}/debootstrap
    TEST_COMMAND ""
    BUILD_BYPRODUCTS ${debootstrap_EXECUTABLE})

add_executable(debootstrap::debootstrap IMPORTED)
set_property(TARGET debootstrap::debootstrap PROPERTY IMPORTED_LOCATION ${debootstrap_EXECUTABLE})
add_dependencies(debootstrap::debootstrap debootstrap)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/chbox-debootstrap.in ${CMAKE_INSTALL_PREFIX}/bin/chbox-debootstrap)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/chbox-chroot.in ${CMAKE_INSTALL_PREFIX}/bin/chbox-chroot)

