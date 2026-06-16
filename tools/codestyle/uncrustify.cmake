if(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    message(FATAL_ERROR "This file is a script")
endif()

# find the muse_deps location
if(NOT DEFINED EXTDEPS_DIR)
    get_filename_component(_app_root "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
    if(EXISTS "${_app_root}/muse_deps/buildtools/manifest.cmake")
        set(EXTDEPS_DIR "${_app_root}/muse_deps")
    else()
        message(FATAL_ERROR "muse_deps not found; set EXTDEPS_DIR")
    endif()
endif()

include("${EXTDEPS_DIR}/buildtools/manifest.cmake")
require_tool(uncrustify)
find_program(UNCRUSTIFY_BIN uncrustify REQUIRED)
