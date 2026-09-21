# Uploads debug information files for the built app to sentry.

set(HERE ${CMAKE_CURRENT_LIST_DIR})

# Options for generate
set(APP_BIN "" CACHE STRING "Path to app binary")
set(GENERATE_ARCHS "" CACHE STRING "Generate symbols for architectures")
set(BUILD_DIR "${CMAKE_SOURCE_DIR}/build.release" CACHE STRING "Path to build directory")
set(DIF_PATHS "" CACHE STRING "Native debug info files to upload as is, instead of generating breakpad symbols")

if(DIF_PATHS)
    message(STATUS "Upload native debug info files, skip breakpad symbols generation")
    set(SYMBOLS_PATH "${DIF_PATHS}")
else()
    set(CONFIG
        -DAPP_BIN=${APP_BIN}
        -DGENERATE_ARCHS=${GENERATE_ARCHS}
        -DBUILD_DIR=${BUILD_DIR}
    )

    execute_process(
        COMMAND cmake ${CONFIG} -P ${HERE}/ci_generate_dumpsyms.cmake
        RESULT_VARIABLE result
    )

    if(result)
        message(FATAL_ERROR "Failed to generate dump symbols, exit code: ${result}")
    endif()

    set(SYMBOLS_PATH "${CMAKE_SOURCE_DIR}/build.artifacts/symbols")
endif()

# Options for upload
set(SENTRY_URL "" CACHE STRING "Sentry URL")
set(SENTRY_AUTH_TOKEN "" CACHE STRING "Sentry Auth Token")
set(SENTRY_ORG "" CACHE STRING "Sentry Organization")
set(SENTRY_PROJECT "" CACHE STRING "Sentry Project")
set(STAGE "" CACHE STRING "Build stage (e.g. stable, testing, nightly, devel)")

set(CONFIG
    -DSENTRY_URL=${SENTRY_URL}
    -DSENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN}
    -DSENTRY_ORG=${SENTRY_ORG}
    -DSENTRY_PROJECT=${SENTRY_PROJECT}
    -DSTAGE=${STAGE}
)

execute_process(
    COMMAND cmake "-DSYMBOLS_PATH=${SYMBOLS_PATH}" ${CONFIG} -P ${HERE}/ci_sentry_dumpsyms_upload.cmake
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR "Failed to upload symbols, exit code: ${result}")
endif()
