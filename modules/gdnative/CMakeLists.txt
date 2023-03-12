
add_env(gdnative-env
	COMPONENTS
		modules-env
)

add_module_lib(gdnative-lib
	COMPONENTS
		gdnative-env
		warnings-env
)

target_glob_sources(gdnative-lib PRIVATE "*.cpp")

set(__GDNATIVE_API_TARGETS
	"${CMAKE_CURRENT_SOURCE_DIR}/include/gdnative_api_struct.gen.h"
	"${CMAKE_CURRENT_SOURCE_DIR}/gdnative_api_struct.gen.cpp"
)

add_python_generator_command(gdnative_builders cmake_build_gdnative_api_struct
	SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/gdnative_api.json"
	TARGET_FILES ${__GDNATIVE_API_TARGETS}
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
)
add_custom_target(gdnative-gen
	DEPENDS
		${__GDNATIVE_API_TARGETS}
)
add_dependencies(gdnative-env gdnative-gen)
target_sources(gdnative-lib PRIVATE ${__GDNATIVE_API_TARGETS})

target_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/gdnative.cpp")
target_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/register_types.cpp")
target_glob_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/android/*.cpp")
target_glob_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/gdnative/*.cpp")
target_glob_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/nativescript/*.cpp")
target_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/gdnative_library_singleton_editor.cpp")
target_sources(gdnative-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/gdnative_library_editor_plugin.cpp")

target_include_directories(gdnative-env INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")

add_subdirectory(net)
add_subdirectory(arvr)
add_subdirectory(pluginscript)
add_subdirectory(videodecoder)

# I'm not sure why is this here, because this is used only for one define (PTRCALL_ENABLED), and this define is setuped much erlier then this module will be processed... 
# So I really don't know, why the hell is this here..
set_target_properties(global-env PROPERTIES USE_PTRCALL true)

if(GODOT_GDNATIVE_WRAPPER)
	set(__GDNATIVE_WRAPPER_TARGETS "${CMAKE_CURRENT_SOURCE_DIR}/gdnative_wrapper_code.gen.cpp")
	add_python_generator_command(gdnative_builders cmake_build_gdnative_wrapper_code
		SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/gdnative_api.json"
		TARGET_FILES ${__GDNATIVE_WRAPPER_TARGETS}
	)

	#TODO: this library is also seems to not being connected to anything..
	add_lib(gdnative-wrapper-lib
		COMPONENTS
			gdnative-env
			warnings-env
		SOURCES
			${__GDNATIVE_WRAPPER_TARGETS}
		OUTPUT_DIR
			"${GODOT_BIN_DIRECTORY}"
		OUTPUT_NAME
			"gdnative_wrapper_code"
	)

	add_custom_target(gdnative-wrapper-gen
		DEPENDS 
			${__GDNATIVE_WRAPPER_TARGETS}
	)
	add_dependencies(gdnative-wrapper-lib gdnative-wrapper-gen)

	target_include_directories(gdnative-wrapper-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")

	if(GODOT_USE_LTO)
		# this is actually enables lto!
		set_target_property(gdnative-wrapper-lib PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
	endif()

	if(NOT MSVC)
		target_compile_options(gdnative-wrapper-lib PRIVATE "-fPIC")
	endif()

endif()

