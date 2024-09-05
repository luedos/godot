add_env(fbx-env
	COMPONENTS
		modules-env
)

add_lib(fbx-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		fbx-env
		global-warnings-env
)

add_lib(thirdparty-fbx-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		fbx-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_FBX_PATH "${ENGINE_SOURCE_DIR}/thirdparty/ufbx")
target_include_directories(fbx-env INTERFACE "${__THIRDPARTY_FBX_PATH}")

target_sources(thirdparty-fbx-lib PRIVATE "${__THIRDPARTY_FBX_PATH}/ufbx.c")
target_compile_definitions(thirdparty-fbx-lib PRIVATE
	"UFBX_NO_SUBDIVISION"
	"UFBX_NO_TESSELLATION"
	"UFBX_NO_GEOMETRY_CACHE"
	"UFBX_NO_SCENE_EVALUATION"
	"UFBX_NO_INDEX_GENERATION"
	"UFBX_NO_SKINNING_EVALUATION"
	"UFBX_NO_FORMAT_OBJ"
)

target_glob_sources(fbx-lib PRIVATE "*.cpp")
target_glob_sources(fbx-lib PRIVATE "structures/*.cpp")

if (EDITOR_BUILD)
	target_glob_sources(fbx-lib PRIVATE "editor/*.cpp")
endif()
