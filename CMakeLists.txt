cmake_minimum_required(VERSION 3.1)

project(chbox LANGUAGES C)
set(PROJECT_VERSION_MAJOR 1)
set(PROJECT_VERSION_MINOR 0)
set(PROJECT_VERSION_PATCH 0)

option(DISABLE_HAVE_CAPSET "On Rocky Linux HAVE_CAPSET is causing errors and must be disabled" OFF)

include(ExternalProject)

find_program(MAKE_EXECUTABLE NAMES make REQUIRED)

set(fakeroot_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/bin/fakeroot")

# Workaround issue with repeated patches application:
# https://gitlab.kitware.com/cmake/cmake/-/issues/21086
function(ExternalProject_Add_Patches name)
    ExternalProject_Get_Property(${name} STAMP_DIR)
    ExternalProject_Get_Property(${name} SOURCE_DIR)

    foreach(patch ${ARGN})
        list(APPEND absolute_paths "${patch}")
    endforeach()

    set(patch_command patch -d "${SOURCE_DIR}" -p1 --fuzz=0 -i)
    foreach(patch ${absolute_paths})
        list(APPEND cmd_list COMMAND ${patch_command} "${patch}")
    endforeach()

    _ep_get_step_stampfile(${name} download download_stampfile)
    add_custom_command(
        APPEND
        OUTPUT ${download_stampfile}
        ${cmd_list}
        DEPENDS ${absolute_paths}
    )
endfunction()

ExternalProject_Add(fakeroot
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG fakeroot
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/fakeroot
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

if (DISABLE_HAVE_CAPSET)
ExternalProject_Add_Patches(fakeroot ${CMAKE_CURRENT_SOURCE_DIR}/disable_have_capset.patch)
endif()

add_executable(fakeroot::fakeroot IMPORTED)
set_property(TARGET fakeroot::fakeroot PROPERTY IMPORTED_LOCATION ${fakeroot_EXECUTABLE})
add_dependencies(fakeroot::fakeroot fakeroot)

set(fakechroot_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/bin/fakechroot")

ExternalProject_Add(fakechroot
    GIT_REPOSITORY https://github.com/dmikushin/chbox.git
    GIT_TAG fakechroot
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/fakechroot
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
    INSTALL_COMMAND ${MAKE_EXECUTABLE} -C <SOURCE_DIR> install DESTDIR=${CMAKE_CURRENT_BINARY_DIR}/debootstrap
    TEST_COMMAND ""
    BUILD_BYPRODUCTS ${debootstrap_EXECUTABLE})

add_executable(debootstrap::debootstrap IMPORTED)
set_property(TARGET debootstrap::debootstrap PROPERTY IMPORTED_LOCATION ${debootstrap_EXECUTABLE})
add_dependencies(debootstrap::debootstrap debootstrap)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/chbox-debootstrap ${CMAKE_CURRENT_BINARY_DIR}/bin/chbox-debootstrap COPYONLY)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/chbox-chroot ${CMAKE_CURRENT_BINARY_DIR}/bin/chbox-chroot COPYONLY)

install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/chbox-debootstrap DESTINATION bin)
install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/chbox-chroot DESTINATION bin)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/fakeroot ${CMAKE_CURRENT_BINARY_DIR}/fakechroot ${CMAKE_CURRENT_BINARY_DIR}/debootstrap
    DESTINATION . USE_SOURCE_PERMISSIONS)

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
if (TARGET_DISTRO)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME}-${VERSION_STRING}-${TARGET_DISTRO})
else()
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME}-${VERSION_STRING})
endif()
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_CONTACT "dmitry@kernelgen.org")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Use your own favorite Linux environment on an uncomfortable shared cluster")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_GENERATOR "STGZ")

include(CPack)

