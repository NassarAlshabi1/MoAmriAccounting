cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# New versions of the template use the `flutter assemble` subcommand to handle
# various build targets, including the application binary. If the target is
# removed, `flutter assemble` will fail with an error about a missing target.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)
apply_standard_settings(${BINARY_NAME})

# Add dependency to the Flutter build so that the application is built
# after the Flutter build is complete.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Define the symbols that are exported from the application. This is needed
# for the embedder to call into the application.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_API_EXPORTS")

# Link the Flutter library.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

# Optional: copy the assets directory from the build directory.
# This is useful for running the application without having to install it.
# add_custom_command(
#   TARGET ${BINARY_NAME} POST_BUILD
#   COMMAND ${CMAKE_COMMAND} -E copy_directory
#           "${CMAKE_CURRENT_SOURCE_DIR}/../build/flutter_assets"
#           "$<TARGET_FILE_DIR:${BINARY_NAME}>/data/flutter_assets"
# )
