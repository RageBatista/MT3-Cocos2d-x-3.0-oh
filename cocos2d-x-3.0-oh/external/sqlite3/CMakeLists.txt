set(SQLITE3_SOURCES
  sqlite3.c
)

add_library(sqlite3 STATIC
  ${SQLITE3_SOURCES}
)

target_include_directories(sqlite3 PUBLIC
  include
)

set_target_properties(sqlite3
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)