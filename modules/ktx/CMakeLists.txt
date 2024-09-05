add_env(ktx-env
	COMPONENTS
		modules-env
)

add_lib(ktx-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		ktx-env
		global-warnings-env
)

add_lib(thirdparty-ktx-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		ktx-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_KTX_PATH "${ENGINE_SOURCE_DIR}/thirdparty/libktx")
target_sources_from_path(thirdparty-ktx-lib PRIVATE "${__THIRDPARTY_KTX_PATH}"
	"lib/basis_transcode.cpp"
	"lib/checkheader.c"
	"lib/filestream.c"
	"lib/hashlist.c"
	"lib/memstream.c"
	"lib/miniz_wrapper.cpp"
	"lib/swap.c"
	"lib/texture.c"
	"lib/texture1.c"
	"lib/texture2.c"
	"lib/vkformat_check.c"
	"lib/vkformat_typesize.c"
	"lib/dfdutils/createdfd.c"
	"lib/dfdutils/colourspaces.c"
	"lib/dfdutils/interpretdfd.c"
	"lib/dfdutils/printdfd.c"
	"lib/dfdutils/queries.c"
	"lib/dfdutils/vk2dfd.c"
)

target_include_directories(ktx-env INTERFACE
	"${__THIRDPARTY_KTX_PATH}/include"
	"${__THIRDPARTY_KTX_PATH}/utils"
	"${__THIRDPARTY_KTX_PATH}/lib"
	"${__THIRDPARTY_KTX_PATH}/other_include"
	"${ENGINE_SOURCE_DIR}/thirdparty/basis_universal"
)

if (EDITOR_BUILD)
	target_compile_definitions(ktx-env INTERFACE "MINIZ_HEADER_FILE_ONLY")
endif()

if (godot_vulkan)
	target_include_directories(ktx-env INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/vulkan/include")
else()
    # Falls back on bundled `vkformat_enum.h`.
	target_compile_definitions(ktx-env INTERFACE "LIBKTX")
endif()

target_compile_definitions(ktx-env INTERFACE "KHRONOS_STATIC=1")

target_glob_sources(ktx-lib PRIVATE "*.cpp")
