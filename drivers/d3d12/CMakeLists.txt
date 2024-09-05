
add_lib(dirvers-d3d12-lib
	OBJECT
	PARENT_LIB
		drivers-lib
	COMPONENTS
		drivers-env
		global-warnings-env
)

# DirectX Headers (must take precedence over Windows SDK's).
target_include_directories(global-env BEFORE INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/directx_headers/include/directx")
target_include_directories(dirvers-d3d12-lib BEFORE PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/directx_headers/include/dxguids")


# Direct3D 12 Memory Allocator.
target_include_directories(global-env BEFORE INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/d3d12ma")

# Agility SDK.
if (NOT "${godot_agility_sdk_path}" STREQUAL "" AND EXISTS "${godot_agility_sdk_path}")
	target_compile_definitions(dirvers-d3d12-lib PRIVATE "AGILITY_SDK_ENABLED")
	if (godot_agility_sdk_multiarch)
		target_compile_definitions(dirvers-d3d12-lib PRIVATE "AGILITY_SDK_MULTIARCH_ENABLED")
	endif()
endif()

# PIX.
if (godot_use_pix)
	target_compile_definitions(dirvers-d3d12-lib PRIVATE "PIX_ENABLED")
	target_include_directories(dirvers-d3d12-lib PRIVATE "${godot_pix_path}/Include")
endif()

# Mesa (SPIR-V to DXIL functionality).
normilize_path(__MESA_ABSOLUTE_PATH "${godot_mesa_libs}" ABSOLUTE PARENT_PATH_PREFIX "${ENGINE_SOURCE_DIR}")
join_paths(__MESA_ABSOLUTE_PATH "${__MESA_ABSOLUTE_PATH}" "godot-mesa")
join_paths(__MESA_ABSOLUTE_GEN_DIR "${__MESA_ABSOLUTE_PATH}" "generated")

# This is taken from scons 'custom_build_steps' variable
# As I understand this is all subdirs which contains generated .h files
set(__MESA_GEN_INCLUDE_PATHS
	"${__MESA_ABSOLUTE_PATH}/generated/src/compiler"
	"${__MESA_ABSOLUTE_PATH}/generated/src/compiler/nir"
	"${__MESA_ABSOLUTE_PATH}/generated/src/compiler/spirv"
	"${__MESA_ABSOLUTE_PATH}/generated/src/util/format"
)

set(__MESA_BLACKLIST_INCLUDE_PATHS "${__MESA_ABSOLUTE_PATH}/src/c11")

file(GLOB_RECURSE __MESA_PRIVATE_INC_FILES LIST_DIRECTORIES TRUE "${__MESA_ABSOLUTE_PATH}/**/")
set(__MESA_PRIVATE_INC_PATHS)
foreach (__FILE IN LISTS __FILES)
	if (NOT IS_DIRECTORY "${__FILE}")
		continue()
	endif()

	cmake_path(IS_PREFIX __MESA_ABSOLUTE_GEN_DIR "${__FILE}" __IS_GEN_PATH)
	if (__IS_GEN_PATH)
		continue()
	endif()

	cmake_path(IS_PREFIX __MESA_BLACKLIST_INCLUDE_PATHS "${__FILE}" __IS_BLACKLIST_PATH)
	if (__IS_BLACKLIST_PATH)
		continue()
	endif()

	list(APPEND __MESA_PRIVATE_INC_PATHS "${__FILE}")
endforeach()

list(APPEND __MESA_PRIVATE_INC_PATHS ${__MESA_GEN_INCLUDE_PATHS})
list(SORT __MESA_PRIVATE_INC_FILES)
list(REMOVE_DUPLICATES __MESA_PRIVATE_INC_FILES)

set(__MESA_VERSION_FILE "${__MESA_ABSOLUTE_PATH}/VERSION.info")
if (NOT EXISTS "${__MESA_VERSION_FILE}")
	set(__MESA_VERSION_FILE "${__MESA_ABSOLUTE_PATH}/VERSION")
endif()

file(READ "${__MESA_VERSION_FILE}" __MESA_VERSION)
string(STRIP "${__MESA_VERSION}" __MESA_VERSION)

set(__EXTRA_DEFINES
	"__STDC_CONSTANT_MACROS"
	"__STDC_FORMAT_MACROS"
	"__STDC_LIMIT_MACROS"
	"PACKAGE_VERSION=\"${__MESA_VERSION}\""
	"PACKAGE_BUGREPORT=\"https://gitlab.freedesktop.org/mesa/mesa/-/issues\""
	"PIPE_SUBSYSTEM_WINDOWS_USER"
	"_Static_assert=static_assert"
)

if (MSVC)
	list(APPEND __EXTRA_DEFINES
		"_USE_MATH_DEFINES"
		"VC_EXTRALEAN"
		"_CRT_SECURE_NO_WARNINGS"
		"_CRT_SECURE_NO_DEPRECATE"
		"_SCL_SECURE_NO_WARNINGS"
		"_SCL_SECURE_NO_DEPRECATE"
		"_ALLOW_KEYWORD_MACROS"
		"_HAS_EXCEPTIONS=0"
		"NOMINMAX"
		"HAVE_STRUCT_TIMESPEC"
	)
else()
	list(APPEND __EXTRA_DEFINES
		"__REQUIRED_RPCNDR_H_VERSION__=475"
		"HAVE_STRUCT_TIMESPEC"
	)
endif()

target_include_directories(dirvers-d3d12-lib PRIVATE ${__MESA_PRIVATE_INC_FILES})
target_compile_definitions(dirvers-d3d12-lib PRIVATE ${__EXTRA_DEFINES})
target_glob_sources(dirvers-d3d12-lib PRIVATE "*.cpp")