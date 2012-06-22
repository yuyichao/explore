# Copyright 2012 Yu Yichao
# yyc1992@gmail.com
#
# This file is part of alarmd.
#
# alarmd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# alarmd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with alarmd.  If not, see <http://www.gnu.org/licenses/>.
#

find_package(PkgConfig REQUIRED)

macro(check_and_add TARGET VAR)
  pkg_check_modules(${VAR} ${ARGN})
  set(${TARGET}_INCLUDE_DIRS ${${TARGET}_INCLUDE_DIRS} ${${VAR}_INCLUDE_DIRS})
  set(${TARGET}_LINK ${${TARGET}_LINK} ${${VAR}_LIBRARIES})
  set(${TARGET}_LINK_DIRS ${${TARGET}_LINK_DIRS} ${${VAR}_LIBRARIES_DIRS})
  set(${TARGET}_FLAGS ${${TARGET}_FLAGS} ${${VAR}_LDFLAGS}
    ${${VAR}_LDFLAGS_OTHER} ${${VAR}_CFLAGS} ${${VAR}_CFLAGS_OTHER})
endmacro(check_and_add)

macro(check_all_modules __target_name)
  set(__arg_list ${ARGN})
  list(LENGTH __arg_list __l)
  while(__l GREATER 0)
    list(GET __arg_list 0 __VARNAME)
    list(REMOVE_AT __arg_list 0)
    list(LENGTH __arg_list __l)
    if(__l EQUAL 0)
      break()
    endif(__l EQUAL 0)
    list(GET __arg_list 0 __next_arg)
    list(REMOVE_AT __arg_list 0)
    list(LENGTH __arg_list __l)
    if(__next_arg STREQUAL "REQUIRED")
      if(__l EQUAL 0)
        break()
      endif(__l EQUAL 0)
      list(GET __arg_list 0 __module_name)
      list(REMOVE_AT __arg_list 0)
      list(LENGTH __arg_list __l)
      check_and_add(${__target_name} ${__VARNAME} REQUIRED ${__module_name})
    else(__next_arg STREQUAL "REQUIRED")
      check_and_add(${__target_name} ${__VARNAME} REQUIRED ${__next_arg})
    endif(__next_arg STREQUAL "REQUIRED")
  endwhile(__l GREATER 0)
endmacro(check_all_modules __target_name)
