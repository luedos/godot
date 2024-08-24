
add_lib(main-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
)
add_link_dependencies(main-lib
	core-lib
	servers-lib
	scene-lib
	drivers-lib
	platform-lib
	modules-lib
)

if (godot_editor_build)
	add_link_dependencies(main-lib editor-lib)
endif()

if (godot_tests)
	add_link_dependencies(main-lib tests-lib)
endif()

target_glob_sources(main-lib PRIVATE "*.cpp")

if (godot_tests)
	target_compile_definitions(main-lib PRIVATE "TESTS_ENABLED")
endif()

set(__GEN_DEPENDENCIES "")

set(__SPLASH_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/splash.gen.h")
list(APPEND __GEN_DEPENDENCIES "${__SPLASH_GEN_FILE}")
add_python_generator_command(main_builders cmake_make_splash
	SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/splash.png"
	TARGET_FILES "${__SPLASH_GEN_FILE}"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Building splash screen header."
)

if(NOT godot_no_editor_splash)
	set(__SPLASH_EDITOR_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/splash_editor.gen.h")
	list(APPEND __GEN_DEPENDENCIES "${__SPLASH_EDITOR_GEN_FILE}")
	add_python_generator_command(main_builders cmake_make_splash_editor
		SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/splash_editor.png"
		TARGET_FILES "${__SPLASH_EDITOR_GEN_FILE}"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		COMMENT "Building editor splash screen header."
	)
endif()

set(__APP_ICON_GEN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/app_icon.gen.h")
list(APPEND __GEN_DEPENDENCIES "${__APP_ICON_GEN_FILE}")
add_python_generator_command(main_builders cmake_make_app_icon
	SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/app_icon.png"
	TARGET_FILES "${__APP_ICON_GEN_FILE}"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Building application icon."
)

add_custom_target(main-gen DEPENDS ${__GEN_DEPENDENCIES})
add_dependencies(main-lib main-gen)