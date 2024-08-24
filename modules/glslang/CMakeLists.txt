add_env(glslang-env
	COMPONENTS
		modules-env
)

add_lib(glslang-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		glslang-env
		global-warnings-env
)
target_glob_sources(glslang-lib PRIVATE "*.cpp")

if (godot_builtin_glslang)
	add_lib(thirdparty-glslang-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			glslang-env
			thirdparty-warnings-env
	)
	set(__THIRDPARTY_GLSLANG_SOURCES
		"glslang/MachineIndependent/attribute.cpp"
		"glslang/MachineIndependent/Constant.cpp"
		"glslang/MachineIndependent/glslang_tab.cpp"
		"glslang/MachineIndependent/InfoSink.cpp"
		"glslang/MachineIndependent/Initialize.cpp"
		"glslang/MachineIndependent/Intermediate.cpp"
		"glslang/MachineIndependent/intermOut.cpp"
		"glslang/MachineIndependent/IntermTraverse.cpp"
		"glslang/MachineIndependent/iomapper.cpp"
		"glslang/MachineIndependent/limits.cpp"
		"glslang/MachineIndependent/linkValidate.cpp"
		"glslang/MachineIndependent/parseConst.cpp"
		"glslang/MachineIndependent/ParseContextBase.cpp"
		"glslang/MachineIndependent/ParseHelper.cpp"
		"glslang/MachineIndependent/PoolAlloc.cpp"
		"glslang/MachineIndependent/preprocessor/PpAtom.cpp"
		"glslang/MachineIndependent/preprocessor/PpContext.cpp"
		"glslang/MachineIndependent/preprocessor/Pp.cpp"
		"glslang/MachineIndependent/preprocessor/PpScanner.cpp"
		"glslang/MachineIndependent/preprocessor/PpTokens.cpp"
		"glslang/MachineIndependent/propagateNoContraction.cpp"
		"glslang/MachineIndependent/reflection.cpp"
		"glslang/MachineIndependent/RemoveTree.cpp"
		"glslang/MachineIndependent/Scan.cpp"
		"glslang/MachineIndependent/ShaderLang.cpp"
		"glslang/MachineIndependent/SpirvIntrinsics.cpp"
		"glslang/MachineIndependent/SymbolTable.cpp"
		"glslang/MachineIndependent/Versions.cpp"
		"glslang/GenericCodeGen/CodeGen.cpp"
		"glslang/GenericCodeGen/Link.cpp"
		"OGLCompilersDLL/InitializeDll.cpp"
		"SPIRV/disassemble.cpp"
		"SPIRV/doc.cpp"
		"SPIRV/GlslangToSpv.cpp"
		"SPIRV/InReadableOrder.cpp"
		"SPIRV/Logger.cpp"
		"SPIRV/SpvBuilder.cpp"
		"SPIRV/SpvPostProcess.cpp"
		"SPIRV/SPVRemapper.cpp"
		"SPIRV/SpvTools.cpp"
	)
	if (godot_platform STREQUAL "windows")
		list(APPEND __THIRDPARTY_GLSLANG_SOURCES "glslang/OSDependent/Windows/ossource.cpp")
	else()
		list(APPEND __THIRDPARTY_GLSLANG_SOURCES "glslang/OSDependent/Unix/ossource.cpp")
	endif()

	set(__THIRDPARTY_GLSLANG_PATH "${ENGINE_SOURCE_DIR}/thirdparty/glslang")
	target_sources_from_path(thirdparty-glslang-lib PRIVATE "${__THIRDPARTY_GLSLANG_PATH}"
		${__THIRDPARTY_GLSLANG_SOURCES}
	)

	target_include_directories(glslang-env SYSTEM INTERFACE
		"${__THIRDPARTY_GLSLANG_PATH}"
		"${ENGINE_SOURCE_DIR}/thirdparty"
	)
	target_compile_definitions(glslang-env INTERFACE "ENABLE_OPT=0")
endif()