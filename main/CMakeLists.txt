
add_lib(main-lib
	STANDALONE
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		warnings-env
)
target_glob_sources(main-lib PRIVATE "*.cpp")


# Order matters here. Higher index controller database files write on top of lower index database files.
set(__CONTROLLER_MAPING_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/default_controller_mappings.gen.cpp")
add_python_generator_command(main_builders cmake_make_default_controller_mappings
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/gamecontrollerdb.txt"
		"${CMAKE_CURRENT_SOURCE_DIR}/godotcontrollerdb.txt"
	TARGET_FILES
		"${__CONTROLLER_MAPING_GEN_FILE}"
)
target_sources(main-lib PRIVATE "${__CONTROLLER_MAPING_GEN_FILE}")


set(__SPLASH_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/splash.gen.h")
add_python_generator_command(main_builders cmake_make_splash
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/splash.png"
	TARGET_FILES
		"${__SPLASH_GEN_FILE}"
)
target_sources(main-lib PRIVATE "${__SPLASH_GEN_FILE}")


set(__SPLASH_EDITOR_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/splash_editor.gen.h")
add_python_generator_command(main_builders cmake_make_splash_editor
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/splash_editor.png"
	TARGET_FILES
		"${__SPLASH_EDITOR_GEN_FILE}"
)
target_sources(main-lib PRIVATE "${__SPLASH_EDITOR_GEN_FILE}")


set(__APP_ICON_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/app_icon.gen.h")
add_python_generator_command(main_builders cmake_make_app_icon
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/app_icon.png"
	TARGET_FILES
		"${__APP_ICON_GEN_FILE}"
)
target_sources(main-lib PRIVATE "${__APP_ICON_GEN_FILE}")


if(GODOT_BUILD_TOOLS)

	add_subdirectory(tests)

endif()

