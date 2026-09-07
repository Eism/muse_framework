message(STATUS "Generate dump symbols")

set(HERE ${CMAKE_CURRENT_LIST_DIR})

set(GEN_SCRIPT "${HERE}/generate_syms.cmake")
set(ARTIFACTS_DIR "${CMAKE_SOURCE_DIR}/build.artifacts")
set(SYMBOLS_DIR ${ARTIFACTS_DIR}/symbols)

# Options
set(APP_BIN "" CACHE STRING "Path to app binary")
set(GENERATE_ARCHS "" CACHE STRING "Generate symbols for architectures")

# dump_syms is provided by extdeps. _deps lands next to this script (gitignored).
# extdeps defaults to <project root>/muse_deps; override with -DEXTDEPS_DIR.
set(LOCAL_ROOT_PATH "${HERE}/_deps")
set(EXTDEPS_DIR "${CMAKE_SOURCE_DIR}/muse_deps" CACHE PATH "muse_deps checkout")
include("${EXTDEPS_DIR}/buildtools/manifest.cmake")
require_tool(dump_syms)
get_property(_bin_dir GLOBAL PROPERTY dump_syms_BIN_DIR)
if(WIN32)
    set(DUMPSYMS_BIN "${_bin_dir}/dump_syms.exe")
else()
    set(DUMPSYMS_BIN "${_bin_dir}/dump_syms")
endif()

file(REMOVE_RECURSE ${SYMBOLS_DIR})

set(CONFIG
    -DDUMPSYMS_BIN=${DUMPSYMS_BIN}
    -DSYMBOLS_DIR=${SYMBOLS_DIR}
    -DAPP_BIN=${APP_BIN}
    -DGENERATE_ARCHS=${GENERATE_ARCHS}
)

execute_process(
    COMMAND cmake ${CONFIG} -P ${GEN_SCRIPT}
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR "Failed to generate symbols, exit code: ${result}")
endif()

file(GLOB_RECURSE symbols_files RELATIVE ${SYMBOLS_DIR} ${SYMBOLS_DIR}/*.sym)
list(JOIN symbols_files "\n  " symbols_files)
message(STATUS "SYMBOLS_DIR contents:\n  ${symbols_files}")
