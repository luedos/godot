
add_module_lib(gdnative-vsdecoder-lib
	OBJECT
	PARENT_LIB
		gdnative-lib
	COMPONENTS
		gdnative-env
		warnings-env
)

# This is not actually needed, because this include directory allready exist in the gdnative-env
# target_include_directories(gdnative-vsdecoder-lib INTERFACE "${GODOT_SOURCE_DIR}/modules/gdnative/include")

target_glob_sources(gdnative-vsdecoder-lib PRIVATE "*.cpp")
