target_glob_sources(servers-lib PRIVATE "*.cpp")

add_lib(thirdparty-spirv-reflect-lib 
	OBJECT
	PARENT_LIB 
		servers-lib
	COMPONENTS
		global-env
		thirdparty-warnings-env
)

target_sources_from_path(thirdparty-spirv-reflect-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/spirv-reflect"
	"spirv_reflect.c"
)