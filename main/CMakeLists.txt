
add_lib(main-lib
	COMPONENTS
		global-env
		warnings-env
	DEPENDENCIES
		core-lib
		servers-lib
		scene-lib
		drivers-lib
		platform-lib
		modules-lib	
)
if (GODOT_BUILD_TOOLS)
	define_lib_dependencies(main-lib
		editor-lib
	)
endif()

register_global_lib(main-lib)
target_glob_sources(main-lib PRIVATE "*.cpp")

# Order matters here. Higher index controller database files write on top of lower index database files.
set(__CONTROLLER_MAPING_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/default_controller_mappings.gen.cpp")
target_sources(main-lib PRIVATE ${__CONTROLLER_MAPING_GEN_FILE})
add_python_generator_command(main_builders cmake_make_default_controller_mappings
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/gamecontrollerdb.txt"
		"${CMAKE_CURRENT_SOURCE_DIR}/godotcontrollerdb.txt"
	TARGET_FILES
		"${__CONTROLLER_MAPING_GEN_FILE}"
	APPEND_SYS_PATH 
		"${GODOT_SOURCE_DIR}"
)

set(__SPLASH_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/splash.gen.h")
add_python_generator_command(main_builders cmake_make_splash
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/splash.png"
	TARGET_FILES
		"${__SPLASH_GEN_FILE}"
	APPEND_SYS_PATH 
		"${GODOT_SOURCE_DIR}"
)

set(__SPLASH_EDITOR_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/splash_editor.gen.h")
add_python_generator_command(main_builders cmake_make_splash_editor
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/splash_editor.png"
	TARGET_FILES
		"${__SPLASH_EDITOR_GEN_FILE}"
	APPEND_SYS_PATH 
		"${GODOT_SOURCE_DIR}"
)

set(__APP_ICON_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/app_icon.gen.h")
add_python_generator_command(main_builders cmake_make_app_icon
	SOURCE_FILES 
		"${CMAKE_CURRENT_SOURCE_DIR}/app_icon.png"
	TARGET_FILES
		"${__APP_ICON_GEN_FILE}"
	APPEND_SYS_PATH 
		"${GODOT_SOURCE_DIR}"
)

add_custom_target(main-gen
	DEPENDS
		${__CONTROLLER_MAPING_GEN_FILE}
		${__SPLASH_GEN_FILE}
		${__SPLASH_EDITOR_GEN_FILE}
		${__APP_ICON_GEN_FILE}
)
add_dependencies(main-lib main-gen)

if(GODOT_BUILD_TOOLS)

	add_subdirectory(tests)

endif()
