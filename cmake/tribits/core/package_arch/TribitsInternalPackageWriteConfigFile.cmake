# @HEADER
# ************************************************************************
#
#            TriBITS: Tribal Build, Integrate, and Test System
#                    Copyright 2013 Sandia Corporation
#
# Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
# the U.S. Government retains certain rights in this software.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the Corporation nor the names of the
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ************************************************************************
# @HEADER


################################################################################
#
# Module TribitsInternalPackageWriteConfigFile.cmake
#
# This module contains code for generating <Package>Config.cmake files for
# internal TriBITS packages.
#
################################################################################


include(TribitsGeneralMacros)
include(TribitsPkgExportCacheVars)
include(TribitsWritePackageConfigFileHelpers)


# Generate the ${PACKAGE_NAME}Config.cmake file for package PACKAGE_NAME.
#
# ToDo: Finish documentation!
#
function(tribits_write_package_client_export_files PACKAGE_NAME)

  if(${PROJECT_NAME}_VERBOSE_CONFIGURE)
    message("\nTRIBITS_WRITE_PACKAGE_CLIENT_EXPORT_FILES: ${PACKAGE_NAME}")
  endif()

  set(buildDirCMakePkgsDir
     "${${PROJECT_NAME}_BINARY_DIR}/${${PROJECT_NAME}_BUILD_DIR_CMAKE_PKGS_DIR}")

  set(EXPORT_FILES_ARGS PACKAGE_NAME ${PACKAGE_NAME})

  if (${PROJECT_NAME}_ENABLE_INSTALL_CMAKE_CONFIG_FILES)
    if(${PROJECT_NAME}_VERBOSE_CONFIGURE)
      message("For package ${PACKAGE_NAME} creating ${PACKAGE_NAME}Config.cmake")
    endif()
    set(PACKAGE_CONFIG_FOR_BUILD_BASE_DIR
      "${buildDirCMakePkgsDir}/${PACKAGE_NAME}" )
    set(PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR
      "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles" )
    append_set(EXPORT_FILES_ARGS
      PACKAGE_CONFIG_FOR_BUILD_BASE_DIR "${PACKAGE_CONFIG_FOR_BUILD_BASE_DIR}"
      PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR "${PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR}"
      )
  endif()

  tribits_write_flexible_package_client_export_files(${EXPORT_FILES_ARGS})

  tribits_write_package_client_export_files_install_targets(${EXPORT_FILES_ARGS})

endfunction()


# @FUNCTION: tribits_write_package_client_export_files_install_targets()
#
# Create the ``<Package>ConfigTargets.cmake`` file and install rules and the
# install() target for the previously generated
# ``<Package>Config_install.cmake`` files generated by the
# `tribits_write_flexible_package_client_export_files()`_ function.
#
# Usage::
#
#   tribits_write_package_client_export_files_install_targets(
#     PACKAGE_NAME <packageName>
#     PACKAGE_CONFIG_FOR_BUILD_BASE_DIR <packageConfigForBuildBaseDir>
#     PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR <packageConfigForInstallBaseDir>
#     )
#
# The install() commands must be in a different subroutine or CMake will not
# allow you to call the routine, even if you if() it out!
#
function(tribits_write_package_client_export_files_install_targets)

  cmake_parse_arguments(
     #prefix
     PARSE
     #options
     ""
     #one_value_keywords
     "PACKAGE_NAME;PACKAGE_CONFIG_FOR_BUILD_BASE_DIR;PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR"
     #multi_value_keywords
     ""
     ${ARGN}
     )

  set(PACKAGE_NAME ${PARSE_PACKAGE_NAME})

  if (PARSE_PACKAGE_CONFIG_FOR_BUILD_BASE_DIR)
    tribits_get_package_config_build_dir_targets_file(${PACKAGE_NAME}
      "${PARSE_PACKAGE_CONFIG_FOR_BUILD_BASE_DIR}" packageConfigBuildDirTargetsFile )
    export(
      EXPORT ${PACKAGE_NAME}
      NAMESPACE ${PACKAGE_NAME}::
      FILE "${packageConfigBuildDirTargetsFile}" )
  endif()

  if (PARSE_PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR)
    install(
      FILES
        "${PARSE_PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR}/${PACKAGE_NAME}Config_install.cmake"
      DESTINATION "${${PROJECT_NAME}_INSTALL_LIB_DIR}/cmake/${PACKAGE_NAME}"
      RENAME ${PACKAGE_NAME}Config.cmake
      )
    install(
      EXPORT ${PACKAGE_NAME}
      NAMESPACE ${PACKAGE_NAME}::
      DESTINATION "${${PROJECT_NAME}_INSTALL_LIB_DIR}/cmake/${PACKAGE_NAME}"
      FILE "${PACKAGE_NAME}Targets.cmake" )
  endif()

endfunction()


# @FUNCTION: tribits_generate_package_config_file_for_build_tree()
#
# Called from tribits_write_flexible_package_client_export_files() to finish
# up generating text for and writing the file `<Package>Config.cmake` for the
# build tree.
#
# Usage::
#
#   tribits_generate_package_config_file_for_build_tree( <packageName>
#     [EXPORT_FILE_VAR_PREFIX <exportFileVarPrefix>]
#     )
#
# These files get placed under <buildDir>/cmake_packages/<packageName>/
#
# That makes them easy to find by find_package() by adding
# <buildDir>/cmake_packages/ to CMAKE_PREFIX_PATH.
#
function(tribits_generate_package_config_file_for_build_tree  packageName)

  if (TRIBITS_WRITE_FLEXIBLE_PACKAGE_CLIENT_EXPORT_FILES_DEBUG_DUMP)
    message("tribits_generate_package_config_file_for_build_tree(${ARGV})")
  endif()

  cmake_parse_arguments(
     PARSE  #prefix
     ""    #options
     "EXPORT_FILE_VAR_PREFIX"  #one_value_keywords
     "" #multi_value_keywords
     ${ARGN}
     )

   if (PARSE_EXPORT_FILE_VAR_PREFIX)
     set(EXPORT_FILE_VAR_PREFIX ${PARSE_EXPORT_FILE_VAR_PREFIX})
   else()
     set(EXPORT_FILE_VAR_PREFIX ${packageName})
   endif()

  set(buildDirExtPkgsDir
     "${${PROJECT_NAME}_BINARY_DIR}/${${PROJECT_NAME}_BUILD_DIR_EXTERNAL_PKGS_DIR}")
  set(buildDirCMakePkgsDir
     "${${PROJECT_NAME}_BINARY_DIR}/${${PROJECT_NAME}_BUILD_DIR_CMAKE_PKGS_DIR}")

  if (PARSE_PACKAGE_CONFIG_FOR_BUILD_BASE_DIR
      OR PARSE_PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR
    )
    # Custom code in configuration file (gets pulled from by configure_file()
    # below)
    set(PACKAGE_CONFIG_CODE "")

    tribits_append_dependent_package_config_file_includes_and_enables_str(${packageName}
      EXPORT_FILE_VAR_PREFIX ${EXPORT_FILE_VAR_PREFIX}
      EXT_PKG_CONFIG_FILE_BASE_DIR "${buildDirExtPkgsDir}"
      PKG_CONFIG_FILE_BASE_DIR "${buildDirCMakePkgsDir}"
      CONFIG_FILE_STR_INOUT PACKAGE_CONFIG_CODE )

    # Import build tree targets into applications.
    #
    # BMA: Export only the immediate libraries of this project to the
    # build tree. Should manage more carefully, checking that they are
    # targets of this project and not other libs.  Also, should
    # consider more careful recursive management of targets when there
    # are sub-packages.  We'd like to export per-package, but deps
    # won't be satisfied, so we export one file for the project for
    # now...
    if (PARSE_PACKAGE_CONFIG_FOR_BUILD_BASE_DIR)
      tribits_get_package_config_build_dir_targets_file(${packageName}
        "${PACKAGE_CONFIG_FOR_BUILD_BASE_DIR}" packageConfigBuildDirTargetsFile )
      string(APPEND PACKAGE_CONFIG_CODE
        "\n# Import ${packageName} targets\n"
        "include(\"${packageConfigBuildDirTargetsFile}\")\n")
    endif()

    tribits_extpkg_append_tribits_compliant_package_config_vars_str(${packageName}
      PACKAGE_CONFIG_CODE)

    tribits_set_compiler_vars_for_config_file(BUILD_DIR)

    if ("${CMAKE_CXX_FLAGS}" STREQUAL "")
      set(CMAKE_CXX_FLAGS_ESCAPED "")
    else()
      # Replace " by \".
      string(REGEX REPLACE "\"" "\\\\\"" CMAKE_CXX_FLAGS_ESCAPED ${CMAKE_CXX_FLAGS})
    endif()

    # Used in configured file below
    set(EXPORTED_PACKAGE_LIBS_NAMES ${${packageName}_EXPORTED_PACKAGE_LIBS_NAMES})
    set(PDOLLAR "$")

    set(tribitsConfigFilesDir
      "${${PROJECT_NAME}_TRIBITS_DIR}/${TRIBITS_CMAKE_INSTALLATION_FILES_DIR}")
    configure_file(
      "${tribitsConfigFilesDir}/TribitsPackageConfigTemplate.cmake.in"
      "${PARSE_PACKAGE_CONFIG_FOR_BUILD_BASE_DIR}/${packageName}Config.cmake"
      )

  endif()

endfunction()


# @FUNCTION: tribits_generate_package_config_file_for_install_tree()
#
# Called from tribits_write_flexible_package_client_export_files() to finish
# up generating text for and writing the file `<Package>Config_install.cmake`
# that will get installed.
#
# Usage::
#
#   tribits_generate_package_config_file_for_install_tree( <packageName>
#     [EXPORT_FILE_VAR_PREFIX <exportFileVarPrefix>]
#     )
#
# The export files are typically installed in
#     <install-dir>/<lib-path>/cmake/<package-name>/.
#
# This file isn't generally useful inside the build tree so it is being
# "hidden" in the CMakeFiles directory.  It gets installed in a separate
# function.  (NOTE: The install target is added in a different function to
# allow this function to be unit tested in a cmake -P script.)
#
function(tribits_generate_package_config_file_for_install_tree  packageName)

  if (TRIBITS_WRITE_FLEXIBLE_PACKAGE_CLIENT_EXPORT_FILES_DEBUG_DUMP)
    message("tribits_generate_package_config_file_for_install_tree(${ARGV})")
  endif()

  cmake_parse_arguments(
     PARSE  #prefix
     ""    #options
     "EXPORT_FILE_VAR_PREFIX"  #one_value_keywords
     "" #multi_value_keywords
     ${ARGN}
     )

   if (PARSE_EXPORT_FILE_VAR_PREFIX)
     set(EXPORT_FILE_VAR_PREFIX ${PARSE_EXPORT_FILE_VAR_PREFIX})
   else()
     set(EXPORT_FILE_VAR_PREFIX ${packageName})
   endif()

  # Custom code in configuration file.
  set(PACKAGE_CONFIG_CODE "")

  tribits_append_dependent_package_config_file_includes_and_enables_str(${packageName}
    EXPORT_FILE_VAR_PREFIX ${EXPORT_FILE_VAR_PREFIX}
    EXT_PKG_CONFIG_FILE_BASE_DIR
      "\${CMAKE_CURRENT_LIST_DIR}/../../${${PROJECT_NAME}_BUILD_DIR_EXTERNAL_PKGS_DIR}"
    PKG_CONFIG_FILE_BASE_DIR "\${CMAKE_CURRENT_LIST_DIR}/.."
    CONFIG_FILE_STR_INOUT PACKAGE_CONFIG_CODE )

  # Import install targets
  string(APPEND PACKAGE_CONFIG_CODE
    "\n# Import ${packageName} targets\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/${packageName}Targets.cmake\")\n")

  tribits_extpkg_append_tribits_compliant_package_config_vars_str(${packageName}
    PACKAGE_CONFIG_CODE)

  # Write the specification of the rpath if necessary. This is only needed if
  # we're building shared libraries.
  if (BUILD_SHARED_LIBS)
    set(SHARED_LIB_RPATH_COMMAND
      ${CMAKE_SHARED_LIBRARY_RUNTIME_CXX_FLAG}${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_INSTALL_LIB_DIR}
      )
  endif()

  tribits_set_compiler_vars_for_config_file(INSTALL_DIR)

  # Used in configure file below
  set(EXPORTED_PACKAGE_LIBS_NAMES ${${packageName}_EXPORTED_PACKAGE_LIBS_NAMES})
  set(PDOLLAR "$")

  if (PARSE_PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR)
    configure_file(
      "${${PROJECT_NAME}_TRIBITS_DIR}/${TRIBITS_CMAKE_INSTALLATION_FILES_DIR}/TribitsPackageConfigTemplate.cmake.in"
      "${PARSE_PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR}/${packageName}Config_install.cmake"
      )
  endif()

endfunction()


# @FUNCTION: tribits_write_flexible_package_client_export_files()
#
# Utility function for writing ``${PACKAGE_NAME}Config.cmake`` files for
# package ``${PACKAGE_NAME}`` with some greater flexibility than what is
# provided by the function ``tribits_write_package_client_export_files()`` and
# to allow unit testing the generation of these files..
#
# Usage::
#
#   tribits_write_flexible_package_client_export_files(
#     PACKAGE_NAME <packageName>
#     [EXPORT_FILE_VAR_PREFIX <exportFileVarPrefix>]
#     [PACKAGE_CONFIG_FOR_BUILD_BASE_DIR <packageConfigForBuildBaseDir>]
#     [PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR <packageConfigForInstallBaseDir>]
#     )
#
# The arguments are:
#
#   ``PACKAGE_NAME <packageName>``
#
#     Gives the name of the TriBITS package for which the export files should
#     be created.
#
#   ``EXPORT_FILE_VAR_PREFIX <exportFileVarPrefix>``
#
#     If specified, then all of the variables in the generated export files
#     will be prefixed with ``<exportFileVarPrefix>_`` instead of
#     ``<packageName>_``.
#
#   ``PACKAGE_CONFIG_FOR_BUILD_BASE_DIR <packageConfigForBuildBaseDir>``
#
#     If specified, then the package's ``<packageName>Config.cmake`` file and
#     supporting files will be written under the directory
#     ``<packageConfigForBuildBaseDir>/`` (and any subdirs that does exist
#     will be created).  The generated file ``<packageName>Config.cmake`` is
#     for usage of the package in the build tree (not the install tree) and
#     points to include directories and libraries in the build tree.
#
#   ``PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR <packageConfigForInstallBaseDir>``
#
#     If specified, then the package's ``<packageName>Config_install.cmake``
#     file and supporting files will be written under the directory
#     ``<packageConfigForInstallBaseDir>/`` (and any subdirs that does exist
#     will be created).  The file ``${PACKAGE_NAME}Config_install.cmake`` is
#     meant to be installed renamed as ``<packageName>Config.cmake`` in the
#     install tree and it points to installed include directories and
#     libraries.
#
# NOTE: This function does *not* contain any ``install()`` command itself
# because CMake will not allow those to even be present in scripting mode that
# is used for unit testing this function.  Instead, the commands to install
# the files are added by the function
# ``tribits_write_package_client_export_files_install_targets()``.
#
function(tribits_write_flexible_package_client_export_files)

  if (TRIBITS_WRITE_FLEXIBLE_PACKAGE_CLIENT_EXPORT_FILES_DEBUG_DUMP)
    message("\ntribits_write_flexible_package_client_export_files(${ARGN})")
  endif()

  #
  # A) Process the command-line arguments
  #

  cmake_parse_arguments(
     #prefix
     PARSE
     #options
     "WRITE_INSTALL_CMAKE_CONFIG_FILE"
     #one_value_keywords
     "PACKAGE_NAME;EXPORT_FILE_VAR_PREFIX;PACKAGE_CONFIG_FOR_BUILD_BASE_DIR;PACKAGE_CONFIG_FOR_INSTALL_BASE_DIR"
     #multi_value_keywords
     ""
     ${ARGN}
     )

  tribits_check_for_unparsed_arguments()

  if (NOT ${PROJECT_NAME}_GENERATE_EXPORT_FILE_DEPENDENCIES)
    message(SEND_ERROR "Error: Can't generate export dependency files because"
      " ${PROJECT_NAME}_GENERATE_EXPORT_FILE_DEPENDENCIES is not ON!")
    return()
  endif()

  set(PACKAGE_NAME ${PARSE_PACKAGE_NAME})
  if (TRIBITS_WRITE_FLEXIBLE_PACKAGE_CLIENT_EXPORT_FILES_DEBUG_DUMP)
    print_var(PACKAGE_NAME)
  endif()

  set(EXPORT_FILE_VAR_PREFIX ${PACKAGE_NAME})
  if (PARSE_EXPORT_FILE_VAR_PREFIX)
    set(EXPORT_FILE_VAR_PREFIX ${PARSE_EXPORT_FILE_VAR_PREFIX})
  endif()
  if (TRIBITS_WRITE_FLEXIBLE_PACKAGE_CLIENT_EXPORT_FILES_DEBUG_DUMP)
    print_var(EXPORT_FILE_VAR_PREFIX)
  endif()

  # Generate a note discouraging editing of the <package>Config.cmake file
  set(DISCOURAGE_EDITING "Do not edit: This file was generated automatically by CMake.")

  #
  # B) Deal with the library rpath issues with shared libs
  #

  # Write the specification of the rpath if necessary. This is only needed if
  # we're building shared libraries.

  if(BUILD_SHARED_LIBS)
    string(REPLACE ";" ":" SHARED_LIB_RPATH_COMMAND "${FULL_LIBRARY_DIRS_SET}")
    set(SHARED_LIB_RPATH_COMMAND
      ${CMAKE_SHARED_LIBRARY_RUNTIME_CXX_FLAG}${SHARED_LIB_RPATH_COMMAND})
  endif()

  #
  # C) Create the contents of the <Package>Config.cmake file for the build tree
  #

  tribits_generate_package_config_file_for_build_tree(${PACKAGE_NAME}
    EXPORT_FILE_VAR_PREFIX ${EXPORT_FILE_VAR_PREFIX})

  #
  # D) Create <Package>Config_install.cmake file for the install tree
  #

  tribits_generate_package_config_file_for_install_tree(${PACKAGE_NAME}
    EXPORT_FILE_VAR_PREFIX ${EXPORT_FILE_VAR_PREFIX})

endfunction()


# @FUNCTION: tribits_append_dependent_package_config_file_includes_and_enables_str()
#
# Append the includes for upstream external packages (TPLs) and internal
# packages as well as the enables/disables for upstream dependencies to an
# output `<Package>Config.cmake` file string.
#
# Usage::
#
#   tribits_append_dependent_package_config_file_includes_and_enables_str(
#     <packageName>
#     EXPORT_FILE_VAR_PREFIX <exportFileVarPrefix>
#     EXT_PKG_CONFIG_FILE_BASE_DIR <extPkgconfigFileBaseDir>
#     PKG_CONFIG_FILE_BASE_DIR <pkgConfigFileBaseDir>
#     CONFIG_FILE_STR_INOUT <configFileStrInOut>
#     )
#
function(tribits_append_dependent_package_config_file_includes_and_enables_str packageName)

  if (TRIBITS_WRITE_FLEXIBLE_PACKAGE_CLIENT_EXPORT_FILES_DEBUG_DUMP)
    message("tribits_append_dependent_package_config_file_includes_and_enables_str(${ARGV})")
  endif()

  # Parse input

  cmake_parse_arguments(
     PARSE ""  # prefix, options
     #one_value_keywords
     "EXPORT_FILE_VAR_PREFIX;EXT_PKG_CONFIG_FILE_BASE_DIR;PKG_CONFIG_FILE_BASE_DIR;CONFIG_FILE_STR_INOUT"
     "" #multi_value_keywords
     ${ARGN}
     )
  tribits_check_for_unparsed_arguments()

   if (PARSE_EXPORT_FILE_VAR_PREFIX)
     set(EXPORT_FILE_VAR_PREFIX ${PARSE_EXPORT_FILE_VAR_PREFIX})
   else()
     set(EXPORT_FILE_VAR_PREFIX ${packageName})
   endif()

  set(extPkgConfigFileBaseDir "${PARSE_EXT_PKG_CONFIG_FILE_BASE_DIR}")
  set(pkgConfigFileBaseDir "${PARSE_PKG_CONFIG_FILE_BASE_DIR}")
  set(configFileStr "${${PARSE_CONFIG_FILE_STR_INOUT}}")

  # Add set of enables/disables for all upstream dependencies
  string(APPEND configFileStr
    "# Enables/Disables for upstream package dependencies\n")
  foreach(depPkg IN LISTS ${packageName}_LIB_DEFINED_DEPENDENCIES)
    if (${packageName}_ENABLE_${depPkg})
      set(enableVal ON)
    else()
      set(enableVal OFF)
    endif()
    string(APPEND configFileStr
      "set(${EXPORT_FILE_VAR_PREFIX}_ENABLE_${depPkg} ${enableVal})\n")
  endforeach()

  # Put in set() statements for exported cache vars
  string(APPEND configFileStr
    "\n# Exported cache variables\n")
  tribits_pkg_append_set_commands_for_exported_vars(${packageName} configFileStr)

  # Include configurations of dependent packages
  string(APPEND configFileStr
    "\n# Include configuration of dependent packages\n")
  foreach(depPkg IN LISTS ${packageName}_LIB_ENABLED_DEPENDENCIES)
    set(packageConfigBaseDir "") # Initially, no add include()
    if (${depPkg}_PACKAGE_BUILD_STATUS STREQUAL "INTERNAL")
      set(packageConfigBaseDir "\${CMAKE_CURRENT_LIST_DIR}/../${depPkg}")
    elseif (${depPkg}_PACKAGE_BUILD_STATUS STREQUAL "EXTERNAL")
      if (NOT "${${depPkg}_TRIBITS_COMPLIANT_PACKAGE_CONFIG_FILE_DIR}" STREQUAL "")
        set(packageConfigBaseDir "${${depPkg}_TRIBITS_COMPLIANT_PACKAGE_CONFIG_FILE_DIR}")
      else()
        set(packageConfigBaseDir
          "\${CMAKE_CURRENT_LIST_DIR}/../../${${PROJECT_NAME}_BUILD_DIR_EXTERNAL_PKGS_DIR}/${depPkg}")
      endif()
    else()
      message(FATAL_ERROR "ERROR:"
        " ${depPkg}_PACKAGE_BUILD_STATUS='${${depPkg}_PACKAGE_BUILD_STATUS}' invalid!")
    endif()
    if (packageConfigBaseDir)
      string(APPEND configFileStr
        "if (NOT TARGET ${depPkg}::all_libs)\n"
        "  include(\"${packageConfigBaseDir}/${depPkg}Config.cmake\")\n"
        "endif()\n"
        )
    endif()
  endforeach()

  # Set the output
  set(${PARSE_CONFIG_FILE_STR_INOUT} "${configFileStr}" PARENT_SCOPE)

endfunction()


# Function to return the full path the targets file for the
# <Package>Config.cmake file in the build tree.
#
function(tribits_get_package_config_build_dir_targets_file  PACKAGE_NAME
    packageConfigForBuildBaseDir  packageConfigBuildDirTargetsFileOut
  )
  set(${packageConfigBuildDirTargetsFileOut}
    "${PACKAGE_CONFIG_FOR_BUILD_BASE_DIR}/${PACKAGE_NAME}Targets.cmake"
    PARENT_SCOPE )
endfunction()


macro(tribits_set_compiler_var_for_config_file LANG FOR_DIR)
  if (NOT "${CMAKE_${LANG}_COMPILER_FOR_CONFIG_FILE_${FOR_DIR}}" STREQUAL "")
    set(CMAKE_${LANG}_COMPILER_FOR_CONFIG_FILE
      "${CMAKE_${LANG}_COMPILER_FOR_CONFIG_FILE_${FOR_DIR}}")
  else()
    set(CMAKE_${LANG}_COMPILER_FOR_CONFIG_FILE
      "${CMAKE_${LANG}_COMPILER}")
  endif()
  #message("${FOR_DIR}: CMAKE_${LANG}_COMPILER_FOR_CONFIG_FILE='${CMAKE_${LANG}_COMPILER_FOR_CONFIG_FILE}'")
endmacro()


macro(tribits_set_compiler_vars_for_config_file FOR_DIR)
  tribits_set_compiler_var_for_config_file(CXX ${FOR_DIR})
  tribits_set_compiler_var_for_config_file(C ${FOR_DIR})
  tribits_set_compiler_var_for_config_file(Fortran ${FOR_DIR})
endmacro()
