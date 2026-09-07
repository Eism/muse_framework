# Dumps breakpad symbols with mozilla/dump_syms into SYMBOLS_DIR/<module>/<debug id>/<module>.sym.
# On macOS the frameworks and dylibs bundled with the app are dumped as well.

set(DUMPSYMS_BIN "" CACHE STRING "Path to dump_syms binary")
set(SYMBOLS_DIR "" CACHE STRING "Path to output symbols directory")
set(APP_BIN "" CACHE STRING "Path to app binary (.pdb on Windows)")
set(GENERATE_ARCHS "" CACHE STRING "Architectures to dump from a fat binary, space separated")
separate_arguments(GENERATE_ARCHS_LIST UNIX_COMMAND "${GENERATE_ARCHS}")

foreach(var DUMPSYMS_BIN SYMBOLS_DIR APP_BIN)
    if(NOT ${var})
        message(FATAL_ERROR "error: not set ${var}")
    endif()
endforeach()
if(NOT EXISTS "${APP_BIN}")
    message(FATAL_ERROR "error: ${APP_BIN} not found")
endif()

message(STATUS "DUMPSYMS_BIN: ${DUMPSYMS_BIN}")
message(STATUS "SYMBOLS_DIR: ${SYMBOLS_DIR}")
message(STATUS "APP_BIN: ${APP_BIN}")

set(LIBS "")
if(APPLE AND APP_BIN MATCHES "^(.*\\.app)/Contents/MacOS/")
    file(GLOB_RECURSE candidates LIST_DIRECTORIES false "${CMAKE_MATCH_1}/Contents/Frameworks/*")
    foreach(f ${candidates})
        if(f MATCHES "\\.dSYM/")
            continue()
        endif()
        get_filename_component(f "${f}" REALPATH)
        file(READ "${f}" magic LIMIT 4 HEX)
        if(magic MATCHES "^(cffaedfe|cefaedfe|cafebabe)$") # MH_MAGIC_64, MH_MAGIC, FAT_MAGIC
            list(APPEND LIBS "${f}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES LIBS)
endif()

if(NOT GENERATE_ARCHS_LIST)
    set(GENERATE_ARCHS_LIST "host")
endif()

foreach(arch ${GENERATE_ARCHS_LIST})
    set(arch_args "")
    if(NOT arch STREQUAL "host")
        set(arch_args -a ${arch})
    endif()

    message(STATUS "Generate symbols for ${APP_BIN} (${arch})")
    execute_process(
        COMMAND ${DUMPSYMS_BIN} ${arch_args} --check-cfi --store ${SYMBOLS_DIR} ${APP_BIN}
        RESULT_VARIABLE result
    )
    if(result)
        message(FATAL_ERROR "dump_syms failed for ${APP_BIN}, exit code: ${result}")
    endif()

    if(LIBS)
        list(LENGTH LIBS libs_count)
        message(STATUS "Generate symbols for ${libs_count} bundled libraries (${arch})")
        execute_process(
            COMMAND ${DUMPSYMS_BIN} ${arch_args} --store ${SYMBOLS_DIR} ${LIBS}
            RESULT_VARIABLE result
        )
        if(result)
            message(FATAL_ERROR "dump_syms failed for bundled libraries, exit code: ${result}")
        endif()
    endif()
endforeach()
