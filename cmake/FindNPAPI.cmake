# Copyright (c) 2013 Yichao Yu <yyc1992@gmail.com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

find_package(PkgConfig)
unset(__pkg_config_checked_NPAPI CACHE)
pkg_check_modules(NPAPI npapi-sdk)

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set NPAPI_FOUND to TRUE if
# all listed variables are TRUE
find_package_handle_standard_args(NpApi
  REQUIRED_VARS NPAPI_FOUND NPAPI_VERSION
  VERSION_VAR NPAPI_VERSION)
mark_as_advanced(NPAPI_INCLUDE_DIRS NPAPI_VERSION NPAPI_CFLAGS)
