if("c8188d82678fec6b784597db69a68e74ff4986b5" STREQUAL "")
  message(FATAL_ERROR "Tag for git checkout should not be empty.")
endif()

set(run 0)

if("/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform-stamp/kodi-platform-gitinfo.txt" IS_NEWER_THAN "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform-stamp/kodi-platform-gitclone-lastrun.txt")
  set(run 1)
endif()

if(NOT run)
  message(STATUS "Avoiding repeated git clone, stamp file is up to date: '/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform-stamp/kodi-platform-gitclone-lastrun.txt'")
  return()
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove_directory "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to remove directory: '/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform'")
endif()

# try the clone 3 times incase there is an odd git clone issue
set(error_code 1)
set(number_of_tries 0)
while(error_code AND number_of_tries LESS 3)
  execute_process(
    COMMAND "/usr/bin/git" clone --origin "origin" "https://github.com/xbmc/kodi-platform" "kodi-platform"
    WORKING_DIRECTORY "/root/tools/xbmc/xbmc/build/kodi-platform/src"
    RESULT_VARIABLE error_code
    )
  math(EXPR number_of_tries "${number_of_tries} + 1")
endwhile()
if(number_of_tries GREATER 1)
  message(STATUS "Had to git clone more than once:
          ${number_of_tries} times.")
endif()
if(error_code)
  message(FATAL_ERROR "Failed to clone repository: 'https://github.com/xbmc/kodi-platform'")
endif()

execute_process(
  COMMAND "/usr/bin/git" checkout c8188d82678fec6b784597db69a68e74ff4986b5
  WORKING_DIRECTORY "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to checkout tag: 'c8188d82678fec6b784597db69a68e74ff4986b5'")
endif()

execute_process(
  COMMAND "/usr/bin/git" submodule init 
  WORKING_DIRECTORY "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to init submodules in: '/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform'")
endif()

execute_process(
  COMMAND "/usr/bin/git" submodule update --recursive 
  WORKING_DIRECTORY "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to update submodules in: '/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform'")
endif()

# Complete success, update the script-last-run stamp file:
#
execute_process(
  COMMAND ${CMAKE_COMMAND} -E copy
    "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform-stamp/kodi-platform-gitinfo.txt"
    "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform-stamp/kodi-platform-gitclone-lastrun.txt"
  WORKING_DIRECTORY "/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to copy script-last-run stamp file: '/root/tools/xbmc/xbmc/build/kodi-platform/src/kodi-platform-stamp/kodi-platform-gitclone-lastrun.txt'")
endif()

