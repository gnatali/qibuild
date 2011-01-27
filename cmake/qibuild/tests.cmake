##
## Author(s):
##  - Cedric GESTES <gestes@aldebaran-robotics.com>
##
## Copyright (C) 2009, 2010, 2011 Cedric GESTES
##

#! QiBuild Tests
# ==============
#
# This cmake module provide function to interface gtest with ctest.


set(_TESTS_RESULTS_FOLDER "${CMAKE_SOURCE_DIR}/tests-results" CACHE INTERNAL "" FORCE)
# create tests_results folder if it does not exist
file(MAKE_DIRECTORY "${_TESTS_RESULTS_FOLDER}")


#! Add a test using a binary that was created by qi_create_bin
# The only difference with add_test() is that qi_add_test will deal with
# the fact that the the binary is in sdk/ directory, and than it is named
# with _d on visual studio.
# \param:TIMETOUT the timeout of the test
# \group:ARGUMENTS arguments to pass to add_test
function(qi_add_test test_name target_name)
  cmake_parse_arguments(ARG "" "TIMEOUT;ARGUMENTS" "" ${ARGN})
  if(NOT ARG_TIMEOUT)
    set(ARG_TIMEOUT 20)
  endif()
  if(WIN32)
    if (${CMAKE_BUILD_TYPE} STREQUAL "DEBUG")
      add_test(${test_name} ${QI_SDK_DIR}/${target_name}_d ${ARG_ARGUMENTS})
    else()
      add_test(${test_name} ${QI_SDK_DIR}/${target_name} ${ARG_ARGUMENTS})
    endif()
  else()
    # Not on windows, no need to make a distinction:
    add_test(${test_name} ${QI_SDK_DIR}/${target_name} ${ARG_ARGUMENTS})
  endif()
  set_tests_properties(${test_name} PROPERTIES
    TIMEOUT ${ARG_TIMEOUT}
  )
endfunction()



#! This compiles and add_test's a C++ test that uses gtest.
# (so that the test can be run by CTest)
# When run, the C++ test outputs a xUnit xml file in
# ${CMAKE_SOURCE_DIR}/test-results/${test_name}.xml
#
# \flag:NO_ADD_TEST do not call add_test, just create the binary
# \param:TIMEOUT the timeout of the test
# \group:SRC sources
# \group:DEPENDS dependencies to pass to use_lib
# \group:ARGUMENTS arguments to pass to add_test (to your test program)
function(qi_create_gtest test_name target_name)
  cmake_parse_arguments(ARG "NO_ADD_TEST" "TIMEOUT" "SRC;DEPENDS;ARGUMENTS" ${ARGN})

  # First, create the target
  qi_create_bin(${target_name} SRC ${ARG_SRC})
  qi_use_lib(${target_name} ${ARG_DEPENDS})


  # Build a correct xml output name
  set(xml_output "${_TESTS_RESULTS_FOLDER}/${test_name}.xml")

  if (WIN32)
    string(REPLACE "/" "\\\\" xml_output ${xml_output})
  endif()

  # Call qi_add_test with correct arguments:
  qi_add_test({test_name} ${target_name}
    TIMEOUT ${ARG_TIMEOUT}
    ARGUMENTS --gtest_output=xml:${_xml_output} ${ARG_ARGUMENTS}
  )
endfunction()
