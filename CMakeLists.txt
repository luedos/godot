cmake_minimum_required (VERSION 3.19.0)
project (godot VERSION 4.0 LANGUAGES CXX C)

# Seting defualt language standarts. 
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Just for all hardcoded folders out there.
set(ENGINE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

# package config is used by the project here and there
find_package(PkgConfig QUIET)
find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
message(STATUS "Found python: ${PYTHON_EXECUTABLE}")

# First of all, including all needed functions
include(methods.cmake)

############### Processing platforms ###############

# Platform of the godot is decided by the system,
# and if you want to change it, you must change CMAKE_SYSTEM_NAME.
# Because this will not only let the godot know which platform you are using,
# but also cmake itself, which then will instruct compiler as well.
# For that is suggested to write some toolchain files.
# That said, you also has the ability to override godot platform, in toolchain file or console for example,
# by specifying godot_platform variable. That is useful if you want something like "server" as a platform.
if ("${godot_platform}" STREQUAL "")
	string(TOLOWER "${CMAKE_SYSTEM_NAME}" __SYSTEM_NAME)
	if(__SYSTEM_NAME MATCHES "(windows|win32)")
		set(godot_platform "windows") # windows case
	elseif(__SYSTEM_NAME MATCHES "(linux)")
		set(godot_platform "linuxbsd")
	else()
		# For now we are not supporting any other platforms..
		message(FATAL_ERROR "Platform \"${CMAKE_SYSTEM_NAME}\" is not supported.")
	endif()
endif()

# Just in case we provided platform from some options
if(godot_platform MATCHES "(linux|dragonfly|freebsd|netbsd|openbsd)")
	set(godot_platform "linuxbsd")
elseif(godot_platform STREQUAL "x11")
	message(WARNING "Platform \"x11\" has been renamed to \"linuxbsd\" in Godot 4.0. Building for platform \"linuxbsd\".")
	set(godot_platform "linuxbsd")
endif()

message(STATUS "Godot detected platform: ${godot_platform}")

############### Processing processor ###############

set(PROCESSOR_IS_X86_32 FALSE)
set(PROCESSOR_IS_X86_64 FALSE)
set(PROCESSOR_IS_ARM32 FALSE)
set(PROCESSOR_IS_ARM64 FALSE)
set(PROCESSOR_IS_PPC32 FALSE)
set(PROCESSOR_IS_PPC64 FALSE)
set(PROCESSOR_IS_WASM32 FALSE)
set(PROCESSOR_IS_RV64 FALSE)

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" __PROCESSOR_ARCHITECTURE)
if(godot_platform STREQUAL "android")
	string(TOLOWER "${CMAKE_ANDROID_ARCH}" __PROCESSOR_ARCHITECTURE)
endif()

set(PROCESSOR_ARCH_ALIAS "")

if (__PROCESSOR_ARCHITECTURE MATCHES "(^x86$)|(^x86_32$)|(^i.86$)")
	set(PROCESSOR_IS_X86_32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "x86_32")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(^x86_64)|(x64)|(amd64)")
	set(PROCESSOR_IS_X86_64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "x86_64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(armv7|arm32)")
	set(PROCESSOR_IS_ARM32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "arm32")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(armv8|arm64v8|aarch64|arm64)")
	set(PROCESSOR_IS_ARM64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "arm64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(ppcle)|(^ppc$)|(ppc32)")
	set(PROCESSOR_IS_PPC32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "ppc32")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(ppc64le|ppc64)")
	set(PROCESSOR_IS_PPC64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "ppc64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(rv|riscv|riscv64)")
	set(PROCESSOR_IS_RV64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "rv64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "wasm32")
	set(PROCESSOR_IS_WASM32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "wasm32")
else()
	# This is mostly mean that our script will go blind folded into build process, 
	# but that doesn't necessarily mean that build will failed.
	set(PROCESSOR_ARCH_ALIAS "${__PROCESSOR_ARCHITECTURE}")
	message(WARNING "The target architecture \"${__PROCESSOR_ARCHITECTURE}\" wasn't processed, this can lead to some problems in build time")
endif()

set(PROCESSOR_BITS 64)
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(PROCESSOR_BITS 32)
endif()

############### Creating default parameters ###############

# Important note: even though all option variables here is cache variables, when we referencing them we only use simple variant, so some variables can be overridden.
# (for example, some platforms tend to override godot_editor_build option)
# Another important note: even though every variable in cmake is upper case, options use strictly lower case. This is done to have at least some comparability with scons options which is important for build profile.
# Options are not fully comparable with their scons counterparts, but the main difference is just a 'godot_' suffix in front of them.

# Target build options
set_string_option   (godot_bin_directory            "bin/$<CONFIG>"     DESCRIPTION "Build directory. (can use generator expression). If not absolute, will be relative to CMAKE_BINARY_DIR (aka directory where you configured your cmake).")
# In godot 4 this option was deprecated in favor of 'target' (which could be editor/release/debug),
# but, because in some cases in cmake we can choose target post configuration,
# and it would be really hard to configure project without knowing whatever we should or should not build editor,
# I decided to create an additional option 'godot_editor_build' to more precisely specify in configuration time whenever or not we are building editor.
set_string_option   (godot_editor_build             "auto"              DESCRIPTION "Build the tools (a.k.a. the Godot editor). This option is complimentary to CMAKE_BUILD_TYPE. In single configuration generators this option has next behavior: auto - fully rely on CMAKE_BUILD_TYPE, true - transfer whatever build type was decided to 'editor' analogue, false - if CMAKE_BUILD_TYPE is editor choose the 'debug' analogue. In case of multi-configuration generator, this option decide whenever 'editor' configs should be added." ENUM "auto" "true" "false")
set_bool_option     (godot_dev_build                FALSE               DESCRIPTION "Developer build with dev-only debugging code (DEV_ENABLED).")
set_bool_option     (godot_debug_symbols            FALSE               DESCRIPTION "Build with debugging symbols.")
set_bool_option     (godot_separate_debug_symbols   FALSE               DESCRIPTION "Build with debugging symbols.")
set_string_option   (godot_lto                      "none"              DESCRIPTION "Link-time optimization (production builds)." ENUM "none" "auto" "thin" "full")
set_string_option   (godot_lto_jobs_count	        "4"              	DESCRIPTION "Link-time optimization number of jobs (production builds). This additional configuration used here because cmake configures number of compilation jobs at build time, so we can't know it at configuration time, and we need it to setup lto properly.")
set_bool_option     (godot_production               FALSE               DESCRIPTION "Set defaults to build Godot for use in production.")

# Components
set_bool_option     (godot_deprecated               TRUE                DESCRIPTION "Enable deprecated features.")
set_string_option   (godot_precision                "single"            DESCRIPTION "Set the floating-point precision level." ENUM "single" "double")
set_bool_option     (godot_minizip                  TRUE                DESCRIPTION "Enable ZIP archive support using minizip.")
set_bool_option     (godot_xaudio2                  FALSE               DESCRIPTION "Enable the XAudio2 audio driver.")
set_bool_option     (godot_vulkan                   TRUE                DESCRIPTION "Enable the vulkan rendering driver.")
set_bool_option     (godot_opengl3                  TRUE                DESCRIPTION "Enable the OpenGL/GLES3 rendering driver.")
set_bool_option     (godot_openxr                   TRUE                DESCRIPTION "Enable the OpenXR driver.")
set_bool_option     (godot_use_volk                 TRUE                DESCRIPTION "Use the volk library to load the Vulkan loader dynamically.")
set_string_option   (godot_custom_modules           ""                  DESCRIPTION "A list of semicolum-separated directory paths containing custom modules to build.")
set_bool_option     (godot_custom_modules_recursive TRUE                DESCRIPTION "Detect custom modules recursively for each specified path.")

# Advanced options
set_bool_option     (godot_dev_mode                 FALSE               DESCRIPTION "Alias for dev options: verbose=yes warnings=extra werror=yes tests=yes.")
set_bool_option     (godot_tests                    FALSE               DESCRIPTION "Build the unit tests.")

set_string_option   (godot_warnings                 "all"               DESCRIPTION "Level of compilation warnings." ENUM "extra" "all" "moderate" "no")
set_bool_option     (godot_werror                   FALSE               DESCRIPTION "Treat compiler warnings as errors.")

set_string_option   (godot_extra_suffix             ""                  DESCRIPTION "Custom extra suffix added to the base filename of all generated binary files.")
set_bool_option     (godot_disable_3d               FALSE               DESCRIPTION "Disable 3D nodes for a smaller executable.")
set_bool_option     (godot_disable_advance_gui      FALSE               DESCRIPTION "Disable advanced GUI nodes and behaviors.")
set_string_option   (godot_build_profile            ""                  DESCRIPTION "Path to a file containing a feature build profile (currently the only thing we are reading from a profile is disabled_classes).")
set_bool_option     (godot_modules_enabled_by_default TRUE              DESCRIPTION "If no, disable all modules except ones explicitly enabled.")
set_bool_option     (godot_no_editor_splash         TRUE                DESCRIPTION "Don't use the custom splash screen for the editor.")
set_string_option   (godot_system_certs_path        ""                  DESCRIPTION "Use this path as SSL certificates default for editor (for package maintainers).")
set_bool_option     (godot_use_precise_math_checks  FALSE               DESCRIPTION "Math checks use very precise epsilon (debug option).")

# Thirdparty libraries
set_bool_option     (godot_builtin_certs            TRUE    DESCRIPTION "Use the built-in SSL certificates bundles.")
set_bool_option     (godot_builtin_embree           TRUE    DESCRIPTION "Use the built-in Embree library.")
set_bool_option     (godot_builtin_enet             TRUE    DESCRIPTION "Use the built-in ENet library.")
set_bool_option     (godot_builtin_freetype         TRUE    DESCRIPTION "Use the built-in FreeType library.")
set_bool_option     (godot_builtin_msdfgen          TRUE    DESCRIPTION "Use the built-in MSDFgen library.")
set_bool_option     (godot_builtin_glslang          TRUE    DESCRIPTION "Use the built-in glslang library.")
set_bool_option     (godot_builtin_graphite         TRUE    DESCRIPTION "Use the built-in Graphite library.")
set_bool_option     (godot_builtin_harfbuzz         TRUE    DESCRIPTION "Use the built-in HarfBuzz library.")
set_bool_option     (godot_builtin_icu4c            TRUE    DESCRIPTION "Use the built-in ICU library.")
set_bool_option     (godot_builtin_libogg           TRUE    DESCRIPTION "Use the built-in libogg library.")
set_bool_option     (godot_builtin_libpng           TRUE    DESCRIPTION "Use the built-in libpng library.")
set_bool_option     (godot_builtin_libtheora        TRUE    DESCRIPTION "Use the built-in libtheora library.")
set_bool_option     (godot_builtin_libvorbis        TRUE    DESCRIPTION "Use the built-in libvorbis library.")
set_bool_option     (godot_builtin_libwebp          TRUE    DESCRIPTION "Use the built-in libwebp library.")
set_bool_option     (godot_builtin_wslay            TRUE    DESCRIPTION "Use the built-in wslay library.")
set_bool_option     (godot_builtin_mbedtls          TRUE    DESCRIPTION "Use the built-in mbedTLS library.")
set_bool_option     (godot_builtin_miniupnpc        TRUE    DESCRIPTION "Use the built-in miniupnpc library.")
set_bool_option     (godot_builtin_pcre2            TRUE    DESCRIPTION "Use the built-in PCRE2 library.")
set_bool_option     (godot_builtin_pcre2_with_jit   TRUE    DESCRIPTION "Use JIT compiler for the built-in PCRE2 library.")
set_bool_option     (godot_builtin_recastnavigation TRUE    DESCRIPTION "Use the built-in Recast navigation library.")
set_bool_option     (godot_builtin_rvo2             TRUE    DESCRIPTION "Use the built-in RVO2 library.")
set_bool_option     (godot_builtin_squish           TRUE    DESCRIPTION "Use the built-in squish library.")
set_bool_option     (godot_builtin_xatlas           TRUE    DESCRIPTION "Use the built-in xatlas library.")
set_bool_option     (godot_builtin_zlib             TRUE    DESCRIPTION "Use the built-in zlib library.")
set_bool_option     (godot_builtin_zstd             TRUE    DESCRIPTION "Use the built-in Zstd library.")

############### Finding platforms ###############

#[=[
DOCUMENTATION FOR PLATFORMS

All functions platform detect.cmake file should implement
- function(<platform_id>_get_platform_name __OUTPUT) -> returns platform name (will be stored in "<platfom_id>_PLATFROM_NAME")
- function(<platform_id>_get_is_platform_active __OUTPUT) -> returns true is platform active (will be stored in "<platfom_id>_IS_PLATFORM_ACTIVE")
- function(<platform_id>_get_can_platform_build __OUTPUT) -> returns true is platform can be built (will be stored in "<platfom_id>_PLATFROM_CAN_BUILD")
- function(<platform_id>_create_custom_options) -> will add some custom options with set_<type>_option function
- function(<platform_id>_configure_platform) -> doing all kind of stuff, like adding specific flags for compiler/linker, modifying some option etc.
- (optional) function(<platform_id>_get_program_suffix <output_variable>) -> returns some platform dependent suffix for program file

Variables which will be defined for platforms
- ACTIVE_PLATFORM_PATHS -> active platform paths
- ACTIVE_PLATFORMS -> active platform actual names
- PLATFORMS_LIST -> buildable platforms raw names (folder names)
- PLATFORMS_EXPORTERS -> list of platform ids (raw names) which has export.cpp file
- PLATFORMS_APIS -> list of platform ids (raw names) which has api.cpp file
- <platform_name>_IS_PLATFORM_ACTIVE -> is platform active (usually just defined from <platform_name>_get_is_platform_active)
- <platform_name>_PLATFROM_NAME -> actual platform name. This variable is output from <platform_name>_get_platform_name method
]=]

set(ACTIVE_PLATFORM_PATHS "")
set(ACTIVE_PLATFORMS "")
set(PLATFORMS_EXPORTERS "")
set(PLATFORMS_APIS "")
set(PLATFORMS_LIST "")

file_glob_dirs(__PLATFORM_DIRS "${ENGINE_SOURCE_DIR}/platform/*")

# for each available platform
foreach(__DIR IN LISTS __PLATFORM_DIRS)

	unset(__PLATFORM_ID) # just in case

	if(NOT IS_DIRECTORY "${__DIR}" OR NOT EXISTS "${__DIR}/detect.cmake")
		continue()
	endif()

	include("${__DIR}/detect.cmake")
	
	# getting platform id
	get_top_directory("${__DIR}" __PLATFORM_ID)

	# just to be sure
	unset(${__PLATFORM_ID}_IS_PLATFORM_ACTIVE)
	unset(${__PLATFORM_ID}_PLATFROM_NAME)
	unset(${__PLATFORM_ID}_PLATFROM_CAN_BUILD)

	# if export file exist 
	if(EXISTS "${__DIR}/export/export.cpp")
		list(APPEND PLATFORMS_EXPORTERS "${__PLATFORM_ID}")
	endif()

	# if api file exist
	if(EXISTS "${__DIR}/api/api.cpp")
		list(APPEND PLATFORMS_APIS "${__PLATFORM_ID}")
	endif()

	# if platform defined as active (must be defined in detect.cmake)
	cmake_language(CALL "${__PLATFORM_ID}_get_is_platform_active" ${__PLATFORM_ID}_IS_PLATFORM_ACTIVE)
	if(${__PLATFORM_ID}_IS_PLATFORM_ACTIVE)

		cmake_language(CALL "${__PLATFORM_ID}_get_platform_name" "${__PLATFORM_ID}_PLATFROM_NAME")
		list(APPEND ACTIVE_PLATFORMS "${${__PLATFORM_ID}_PLATFROM_NAME}")
		list(APPEND ACTIVE_PLATFORM_PATHS "${__DIR}")
		list(APPEND ACTIVE_PLATFORMS_IDS "${__PLATFORM_ID}")

	endif()

	# if platform can be built (must be defined in detect.cmake)
	cmake_language(CALL "${__PLATFORM_ID}_get_can_platform_build" ${__PLATFORM_ID}_PLATFROM_CAN_BUILD)
	if(${__PLATFORM_ID}_PLATFROM_CAN_BUILD)

		list(APPEND PLATFORMS_LIST "${__PLATFORM_ID}")
		if(__PLATFORM_ID STREQUAL godot_platform)
			cmake_language(CALL "${__PLATFORM_ID}_create_custom_options")
		endif()

	endif()

endforeach()


set(__ACTIVE_PLATFORMS_SVG_FILES "")
foreach(__PLATFORM_DIR IN LISTS ACTIVE_PLATFORM_PATHS)
	if (EXISTS "${__PLATFORM_DIR}/logo.svg")
		list(APPEND __ACTIVE_PLATFORMS_SVG_FILES
			"${__PLATFORM_DIR}/logo.svg"
			"${__PLATFORM_DIR}/logo_svg.gen.h"
		)
	endif()

	if (EXISTS "${__PLATFORM_DIR}/run_icon.svg")
		list(APPEND __ACTIVE_PLATFORMS_SVG_FILES
			"${__PLATFORM_DIR}/run_icon.svg"
			"${__PLATFORM_DIR}/run_icon_svg.gen.h"
		)
	endif()
endforeach()

execute_python_method(cmake_methods save_active_platforms
	PYTHON_ARGS 
		ARR_VAR "ACTIVE_PLATFORMS"
		ARR_VAR "ACTIVE_PLATFORM_PATHS"
	ACTION_CACHE_NAME "save_active_platforms"
	DEPENDENT_FILES ${__ACTIVE_PLATFORMS_SVG_FILES}
)

set_string_option(godot_platform "${godot_platform}" DESCRIPTION "Target platform." ENUM ${PLATFORMS_LIST})

if(NOT godot_platform IN_LIST PLATFORMS_LIST)
	message(FATAL_ERROR "Platform \"${godot_platform}\" can't be found in active platforms (${PLATFORMS_LIST}). Maybe current platform \"${CMAKE_SYSTEM_NAME}\" is not supported yet.")
elseif(NOT ${godot_platform}_PLATFROM_CAN_BUILD)
	message(FATAL_ERROR "Platform \"${godot_platform}\" exist, but can't be built.")
endif()


############### Utility setup ###############

# Generator expressions for easier working with build types which can be used in the future.
set(IS_DEBUG_GEN_EXPR            $<CONFIG:Debug_OptNone,Debug_OptDebug,Debug_OptSpeed,Debug_OptSpeedTrace,Debug_OptSize>)
set(IS_RELEASE_GEN_EXPR          $<CONFIG:Release_OptNone,Release_OptDebug,Release_OptSpeed,Release_OptSpeedTrace,Release_OptSize>)
set(IS_OPT_NONE_GEN_EXPR         $<CONFIG:Editor_OptNone,Debug_OptNone,Release_OptNone>)
set(IS_OPT_DEBUG_GEN_EXPR        $<CONFIG:Editor_OptDebug,Debug_OptDebug,Release_OptDebug>)
set(IS_OPT_SPEED_GEN_EXPR        $<CONFIG:Editor_OptSpeed,Debug_OptSpeed,Release_OptSpeed>)
set(IS_OPT_SPEEDTRACE_GEN_EXPR   $<CONFIG:Editor_OptSpeedTrace,Debug_OptSpeedTrace,Release_OptSpeedTrace>)
set(IS_OPT_SIZE_GEN_EXPR         $<CONFIG:Editor_OptSize,Debug_OptSize,Release_OptSize>)


# Normilizing godot bin directory and making it absolute.
if(NOT IS_ABSOLUTE "${godot_bin_directory}")
	join_paths(godot_bin_directory "${CMAKE_BINARY_DIR}" "${godot_bin_directory}")
else()
	normilize_path(godot_bin_directory "${godot_bin_directory}")
endif()

############### Processing configurations ###############

set(__POSSIBLE_EDITOR_BUILD_TYPES
	"Editor_OptNone"
	"Editor_OptDebug"
	"Editor_OptSpeed"
	"Editor_OptSpeedTrace"
	"Editor_OptSize"
)

set(__POSSIBLE_RELEASE_BUILD_TYPES
	"Release_OptNone"
	"Release_OptDebug"
	"Release_OptSpeed"
	"Release_OptSpeedTrace"
	"Release_OptSize"
)

set(__POSSIBLE_DEBUG_BUILD_TYPES
	"Debug_OptNone"
	"Debug_OptDebug"
	"Debug_OptSpeed"
	"Debug_OptSpeedTrace"
	"Debug_OptSize"
)

set(__POSSIBLE_ALL_BUILD_TYPES ${__POSSIBLE_EDITOR_BUILD_TYPES} ${__POSSIBLE_RELEASE_BUILD_TYPES} ${__POSSIBLE_DEBUG_BUILD_TYPES})

if (CMAKE_CONFIGURATION_TYPES)
	# If we are using multi-configuration generator.
	if (godot_editor_build STREQUAL "auto" OR "${godot_editor_build}" STREQUAL "")
		message(FATAL_ERROR "Configuring cmake for multi-configuration generator. In this case strong specification of 'godot_editor_build' is required (choose 'true' of 'false').")
	endif()

	if (godot_editor_build)
		set(CMAKE_CONFIGURATION_TYPES ${__POSSIBLE_EDITOR_BUILD_TYPES})
	else()
		set(CMAKE_CONFIGURATION_TYPES ${__POSSIBLE_RELEASE_BUILD_TYPES} ${__POSSIBLE_DEBUG_BUILD_TYPES})
	endif()

	message(STATUS "Possible configurations are: ${CMAKE_CONFIGURATION_TYPES}")
else()

	# if no build type defined, make default Editor_OptDebug.
	if("${CMAKE_BUILD_TYPE}" STREQUAL "")
		if (godot_editor_build STREQUAL "auto" OR godot_editor_build)
			set(__DEFAULT_TARGET "Editor")
		elseif (godot_dev_build)
			set(__DEFAULT_TARGET "Debug")
		else()
			set(__DEFAULT_TARGET "Release")
		endif()

		if (godot_dev_build)
			set(__DEFAULT_OPT "None")
		elseif(__DEFAULT_TARGET MATCHES "(Debug|Editor)")
			set(__DEFAULT_OPT "SpeedTrace")
		else()
			set(__DEFAULT_OPT "Speed")
		endif()

		set(CMAKE_BUILD_TYPE "${__DEFAULT_TARGET}_Opt${__DEFAULT_OPT}" CACHE STRING "" FORCE)
	endif()

	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${__POSSIBLE_ALL_BUILD_TYPES}")

	if (NOT CMAKE_BUILD_TYPE IN_LIST __POSSIBLE_ALL_BUILD_TYPES)
		message(FATAL_ERROR "Invalid build type ${CMAKE_BUILD_TYPE}. Possible build types are: ${__POSSIBLE_ALL_BUILD_TYPES}")
	endif()

	if (godot_editor_build STREQUAL "auto")
		if (CMAKE_BUILD_TYPE MATCHES "^Editor")
			set(godot_editor_build TRUE)
		else()
			set(godot_editor_build FALSE)
		endif()
	elseif (godot_editor_build AND NOT CMAKE_BUILD_TYPE MATCHES "^Editor")
		string(REGEX REPLACE "^.+(_.+)" "Editor\\1" __NEW_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
		message(WARNING "Switching build type from '${CMAKE_BUILD_TYPE}' to '${__NEW_BUILD_TYPE}' because 'godot_editor_build' specified as true.")
		set(CMAKE_BUILD_TYPE "${__NEW_BUILD_TYPE}" CACHE STRING "" FORCE)
	elseif (NOT godot_editor_build AND CMAKE_BUILD_TYPE MATCHES "^Editor")
		string(REGEX REPLACE "^Editor(.+)" "Debug\\1" __NEW_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
		message(WARNING "Switching build type from '${CMAKE_BUILD_TYPE}' to '${__NEW_BUILD_TYPE}' because 'godot_editor_build' specified as false.")
		set(CMAKE_BUILD_TYPE "${__NEW_BUILD_TYPE}" CACHE STRING "" FORCE)
	endif()

	message(STATUS "Current build type is '$CACHE{CMAKE_BUILD_TYPE}'.")
endif()

# We will clean up all flags which were added by the cmake itself, 
# because all those flags will be specifically added by the platforms

foreach(__LANG "CXX" "C" "OBJCXX" "OBJC")

	set(CMAKE_${__LANG}_FLAGS "")

	foreach(__BUILD_TYPE IN LISTS __POSSIBLE_ALL_BUILD_TYPES)
		string(TOUPPER "${__BUILD_TYPE}" __BUILD_TYPE)
		set(CMAKE_${__LANG}_FLAGS_${__BUILD_TYPE} "")
	endforeach()
endforeach()

foreach (__BUILD_TYPE IN LISTS __POSSIBLE_ALL_BUILD_TYPES)
	string(TOUPPER "${__BUILD_TYPE}" __BUILD_TYPE)
	set(CMAKE_EXE_LINKER_FLAGS_${__BUILD_TYPE} "")
endforeach()

############### Creating the environment ###############

# This is basically the analog of the SCons Environment variable.
# This environment library can be configured later, from platform/module scripts (same as it done in scons)
# In the future this can be changed..
add_env(global-env)

# setting some "global" variables, which can be appended by modules
set_target_properties(global-env 
	PROPERTIES
		USE_PTRCALL FALSE # do we need to define PTRCALL_ENABLED. This variable can be overriten on module configuration
		X86_LIBTHEORA_OPT_GCC FALSE
		X86_LIBTHEORA_OPT_VC FALSE
		EXTRA_SUFFIX ""
)

# some thirdparty libs does not have warnings in them, so we will create separate environment to handle all warnings levels
add_env(global-warnings-env)
add_env(thirdparty-warnings-env)

############### Processing modules ###############

#[=[
DOCUMENTATION FOR MODULES

All functions modules config.cmake file should implement
- function(<module_name>_configure_module) -> configures module if needed
- function(<module_name>_get_module_can_build <output>) -> returns true if module can be build and should be processed
- (optional) function(<module_name>_get_is_module_enabled <output>) -> to override default value of the <module_name>_IS_MODULE_ENABLED option
- (optional) function(<module_name>_get_module_dependencies <dependencies_list_output> <optional_dependencies_list_output>) -> Returns dependencies for the module
- (optional) function(<module_name>_create_custom_options) -> will add some custom options with set_<type>_option function
- (optional) function(<module_name>_get_doc_classes <output>) -> works with <module_name>_get_doc_relative_path. Used to define module classes for documentation
- (optional) function(<module_name>_get_doc_relative_path <output>) -> works with <module_name>_get_doc_classes. Used to define relative path of the module classes.
- (optional) function(<module_name>_get_relative_icon_path <output>) -> used to define icons path for module. If this function wasn't defined, default path is "icons"
- (optional) function(<module_name>_get_version_string <output>) -> used to add some specific info to the version of the current build (for now it is used only in the mono module)

Variables which will be defined for modules
- MODULES_IDS -> all modules names
- MODULES_PATHS -> all modules paths (in sync with MODULES_IDS)
- <module_name>_MODULE_PATH -> path for the specific module
- godot_module_<module_name>_enabled -> this is option (a.k.a. CACHE value) which determines is module enabled (will be processed) or not. Usually it is set up through console line, or simply through cache
- <module_name>_REQUIRED_DEPENDENCIES -> Required modules for the one <module_name> to be build
- <module_name>_OPTIONAL_DEPENDENCIES -> Optional modules which only affect module sorting
- <module_name>_MODULE_CAN_BUILD -> this variable is output from <module_name>_get_module_can_build function. Also defines if module can be built
- MODULES_CLASSES -> classses names from all modules
- <module_name>_MODULE_DOC_CLASSES -> list of classes for specific module
- <class_name>_CLASS_PATH -> path for the doc of the specific class
- <module_name>_MODULE_DOC_RELATIVE_PATH -> relative path of the modules doc folder
- <module_name>_ICONS_PATH -> icon path for specific module
- MODULES_ICONS_PATHS -> icon paths of all modules
- <module_name>_VERSION_STRING -> version string returned from '<module_name>_get_version_string' of specific module
- MODULES_VERSION_STRING -> total combined version string of all modules
- MODULES_LIST -> all modules which is enabled and will be built
]=]

# getting all modules
#[=[
important thing is, modules paths provided by the GODOT_CUSTOM_MODULES must lead to the folders which holds modules folders 
not the modules itself: 
path is "some/provided/path"
structure is:
some/provided/path/module1/
some/provided/path/module2/
some/provided/path/module3/
...
]=]

set(__MODULES_DIRS "") # just to be sure
# Built in directories we are detecting without recursion
get_modules_paths(__BUILTIN_MODULES_DIRS "modules")

set(__ADDITIONAL_ARGS "")
if(godot_custom_modules_recursive)
	set(__ADDITIONAL_ARGS "RECURSIVE")
endif()
get_modules_paths(__CUSTOM_MODULES_DIRS ${__ADDITIONAL_ARGS} ${godot_custom_modules})

# those lists are sync with each other
set(__ALL_MODULES_IDS "") # all modules ids (a.k.a. folder names)

# processing all modules
macro(detect_modules __MODULES_DIRS_VAR __MODULES_IDS_VAR)
	foreach(__DIR IN LISTS ${__MODULES_DIRS_VAR})
		# just in case..
		normilize_path(__DIR "${__DIR}" ABSOLUTE)

		is_module("${__DIR}" __MODULE_VALID)
		if(NOT __MODULE_VALID)
			message(WARNING "Provided module by the path '${__DIR}'' is not valid, and can't be processed..")
			continue()
		endif()

		get_top_directory("${__DIR}" __MODULE_ID)

		if(__MODULE_ID IN_LIST __ALL_MODULES_IDS)
			# if module with same id was already defined..
			message(WARNING "Provided module '${__MODULE_ID}' is already defined. Old module path is '${${__MODULE_ID}_MODULE_PATH}', new module path is '${__DIR}'. New module will override old one.")
			list(REMOVE_ITEM __ALL_MODULES_IDS "${__MODULE_ID}")
		endif()

		if (__MODULE_ID IN_LIST ${__MODULES_IDS_VAR})
			list(REMOVE_ITEM ${__MODULES_IDS_VAR} "${__MODULE_ID}")
		endif()

		# appending module id to the list
		list(APPEND __ALL_MODULES_IDS "${__MODULE_ID}")
		list(APPEND ${__MODULES_IDS_VAR} "${__MODULE_ID}")
		set(${__MODULE_ID}_MODULE_PATH "${__DIR}")

	endforeach()
endmacro()


set(__BUILTIN_MODULES_IDS "")
set(__CUSTOM_MODULES_IDS "")
detect_modules(__BUILTIN_MODULES_DIRS __BUILTIN_MODULES_IDS)
detect_modules(__CUSTOM_MODULES_DIRS __CUSTOM_MODULES_IDS)

list(REMOVE_ITEM __BUILTIN_MODULES_IDS ${__CUSTOM_MODULES_IDS})

set(MODULES_IDS ${__BUILTIN_MODULES_IDS} ${__CUSTOM_MODULES_IDS})
set(MODULES_PATHS "") # all modules paths
# Then processing selected modules without duplicates.
foreach (__MODULE_ID IN LISTS MODULES_IDS)

	# Resetting some variables just in case
	set(${__MODULE_ID}_REQUIRED_DEPENDENCIES "")
	set(${__MODULE_ID}_OPTIONAL_DEPENDENCIES "")

	set(__MODULE_DIR "${${__MODULE_ID}_MODULE_PATH}")

	list(APPEND MODULES_PATHS "${__MODULE_DIR}")

	include("${__MODULE_DIR}/config.cmake")

	set(__MODULE_ENABLED FALSE)
	# if we are not already provided that property..
	if (NOT DEFINED godot_module_${__MODULE_ID}_enabled)
		if (godot_modules_enabled_by_default)
			set(__MODULE_ENABLED TRUE)
		endif()

		# if module can give us answer
		if(COMMAND ${__MODULE_ID}_get_is_module_enabled) 
			cmake_language(CALL ${__MODULE_ID}_get_is_module_enabled __MODULE_ENABLED)
		elseif (__MODULE_ENABLED)
			# Just so we will not get annoying warnings later, we will disable module by default if we can't built it
			cmake_language(CALL ${__MODULE_ID}_get_module_can_build __MODULE_ENABLED)
		endif()

	endif()

	set_bool_option(godot_module_${__MODULE_ID}_enabled "${__MODULE_ENABLED}" DESCRIPTION "Enable module '${__MODULE_ID}'.")	

	if (COMMAND ${__MODULE_ID}_create_custom_options)
		cmake_language(CALL ${__MODULE_ID}_create_custom_options)
	endif()
endforeach()

# Provide default include path for both the custom module search `path`
# and the base directory containing custom modules, as it may be different
# from the built-in "modules" name (e.g. "custom_modules/summator/summator.h"),
# so it can be referenced simply as `#include "summator/summator.h"`
# independently of where a module is located on user's filesystem.

set(__ADDITIONAL_INCLUDES "")
foreach(__MODULE_ID IN LISTS __CUSTOM_MODULES_IDS)
	set(__MODULE_DIR "${__MODULE_ID}_MODULE_PATH")
	get_filename_component(__MODULE_PARENT_DIR "${__MODULE_DIR}" DIRECTORY)
	get_filename_component(__MODULES_BASE_DIR "${__MODULE_PARENT_DIR}" DIRECTORY)

	list(APPEND __ADDITIONAL_INCLUDES "${__MODULE_PARENT_DIR}" "${__MODULES_BASE_DIR}")
endforeach()

list(REMOVE_DUPLICATES __ADDITIONAL_INCLUDES)
target_include_directories(global-env INTERFACE ${__ADDITIONAL_INCLUDES})

# generating some files
execute_python_method(cmake_methods cmake_write_modules
	PYTHON_ARGS
		ARR_VAR "MODULES_IDS"
		ARR_VAR "MODULES_PATHS"
	ACTION_CACHE_NAME "register_module_types"
	DEPENDENT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/modules/register_module_types.gen.cpp"
)

############### Processing build profile ###############

set(__DISABLED_CLASSES_RAW_ARRAY "[]")
if (NOT "${godot_build_profile}" STREQUAL "")
	normilize_path(__PROFILE_NORMILIZED_PATH "${godot_build_profile}" ABSOLUTE)

	message(STATUS "Using feature build profile: ${__PROFILE_NORMILIZED_PATH}")
	file(READ "${__PROFILE_NORMILIZED_PATH}" __PROFILE_JSON_CONTENT)

	################# reading disabled_classes #################
	string(JSON
		__DISABLED_CLASSES_RAW_ARRAY
		ERROR_VARIABLE __TEMP_ERROR_VAR
		GET "${__PROFILE_JSON_CONTENT}" "disabled_classes"
	)

	if (NOT "${__TEMP_ERROR_VAR}" STREQUAL "NOTFOUND")
		message(FATAL_ERROR "Failed to read 'disabled_classes' from build profile.")
	endif()
	string(REGEX REPLACE "(\n)" "" __DISABLED_CLASSES_RAW_ARRAY "${__DISABLED_CLASSES_RAW_ARRAY}")

	################# reading disabled_build_options #################

	string(JSON
		__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY
		ERROR_VARIABLE __TEMP_ERROR_VAR
		GET "${__PROFILE_JSON_CONTENT}" "disabled_build_options"
	)

	if (NOT "${__TEMP_ERROR_VAR}" STREQUAL "NOTFOUND")
		message(FATAL_ERROR "Failed to read 'disabled_build_options' from build profile.")
	endif()
	string(REGEX REPLACE "(\n)" "" __DISABLED_BUILD_OPTIONS_RAW_DICTIONARY "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}")

	set(__DISABLED_BUILD_OPTIONS_COUNT 0)
	string(JSON
		__DISABLED_BUILD_OPTIONS_COUNT
		ERROR_VARIABLE __TEMP_ERROR_VAR
		LENGTH "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}"
	)

	if ("${__TEMP_ERROR_VAR}" STREQUAL "NOTFOUND" AND NOT __DISABLED_BUILD_OPTIONS_COUNT EQUAL 0)
		math(EXPR __DISABLED_BUILD_OPTIONS_COUNT "${__DISABLED_BUILD_OPTIONS_COUNT} - 1")
		foreach (__OPTION_INDEX RANGE ${__DISABLED_BUILD_OPTIONS_COUNT})
			string(JSON
				__OPTION_NAME
				MEMBER "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}" ${__OPTION_INDEX}
			)
			string(JSON
				__OPTION_VALUE
				GET "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}" "${__OPTION_NAME}"
			)

			message(STATUS "Overriding build option 'godot_${__OPTION_NAME}' with value '${__OPTION_VALUE}'.")
			set("godot_${__OPTION_NAME}" "${__OPTION_VALUE}")
		endforeach()
	endif()
endif()

execute_python_method(cmake_methods write_disabled_classes
	PYTHON_ARGS
		RAW_VAR "__DISABLED_CLASSES_RAW_ARRAY"
	ACTION_CACHE_NAME "write_disabled_classes"
	DEPENDENT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/core/disabled_classes.gen.h"
)

############### Global defines setup ###############

target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}")

if (godot_editor_build)
	target_compile_definitions(global-env INTERFACE "TOOLS_ENABLED")
endif()

# DEBUG_ENABLED enables debugging *features* and debug-only code, which is intended
# to give *users* extra debugging information for their game development.
if (godot_editor_build)
	target_compile_definitions(global-env INTERFACE "DEBUG_ENABLED")
else()
	target_compile_definitions(global-env INTERFACE $<${IS_DEBUG_GEN_EXPR}:DEBUG_ENABLED>)
endif()

if (godot_dev_build)
	# DEV_ENABLED enables *engine developer* code which should only be compiled for those
	# working on the engine itself.
	target_compile_definitions(global-env INTERFACE "DEV_ENABLED")
else()
	target_compile_definitions(global-env INTERFACE "NDEBUG")
endif()

if (godot_use_precise_math_checks)
	target_compile_definitions(global-env INTERFACE "PRECISE_MATH_CHECKS")
endif()

if (NOT EXISTS "${ENGINE_SOURCE_DIR}/main/splash_editor.png")
	# Force disabling editor splash if missing.
	set(godot_no_editor_splash TRUE)
endif()

if (godot_no_editor_splash)
	target_compile_definitions(global-env INTERFACE "NO_EDITOR_SPLASH")
endif()

if (NOT godot_deprecated)
	target_compile_definitions(global-env INTERFACE "DISABLE_DEPRECATED")
endif()

if (godot_precision STREQUAL "double")
	target_compile_definitions(global-env INTERFACE "REAL_T_IS_DOUBLE")
endif()

if (godot_dev_mode)
	set(godot_warnings "extra")
	set(godot_werror TRUE)
	set(godot_tests TRUE)
endif()

if (godot_production)
	set(godot_use_static_cpp TRUE)
	set(godot_debug_symbols FALSE)
	set(godot_lto "auto")
endif()

cmake_language(CALL ${godot_platform}_configure_platform)

if (godot_dev_build)
	message(STATUS "NOTE: Developer build, with debug optimization level and debug symbols (unless overridden).")
endif()

if (MSVC)
	if (godot_debug_symbols)
		target_compile_options(global-env INTERFACE "/Zi" "/FS")
		target_link_options(global-env INTERFACE "/DEBUG:FULL")
	endif()

	target_compile_options(global-env INTERFACE
		$<$<OR:${IS_OPT_SPEED_GEN_EXPR},${IS_OPT_SPEEDTRACE_GEN_EXPR}>:/O2>
		$<${IS_OPT_SIZE_GEN_EXPR}:/O1>
		$<$<OR:${IS_OPT_DEBUG_GEN_EXPR},${IS_OPT_NONE_GEN_EXPR}>:/Od>
	)
	target_link_options(global-env INTERFACE
		$<$<OR:${IS_OPT_SPEED_GEN_EXPR},${IS_OPT_SPEEDTRACE_GEN_EXPR},${IS_OPT_SIZE_GEN_EXPR}>:/OPT:REF>
	)
else()
	if (godot_debug_symbols)
		# Adding dwarf-4 explicitly makes stacktraces work with clang builds,
		# otherwise addr2line doesn't understand them
		target_compile_options(global-env INTERFACE "-gdwarf-4")
		if (godot_dev_build)
			target_compile_options(global-env INTERFACE "-g3")
		else()
			target_compile_options(global-env INTERFACE "-g2")
		endif()
	else()
		if (CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
			target_link_options(global-env INTERFACE "-Wl,-S" "-Wl,-x" "-Wl,-dead_strip")
		else()
			target_link_options(global-env INTERFACE "-s")
		endif()
	endif()

	target_compile_options(global-env INTERFACE
		$<${IS_OPT_SPEED_GEN_EXPR}:-O3>
		$<${IS_OPT_SPEEDTRACE_GEN_EXPR}:-O2>
		$<${IS_OPT_SIZE_GEN_EXPR}:-Os>
		$<${IS_OPT_DEBUG_GEN_EXPR}:-Og>
		$<${IS_OPT_NONE_GEN_EXPR}:-O0>
	)
endif()

if (NOT godot_lto STREQUAL "none")
	message(STATUS "Using LTO: ${godot_lto}")
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	if ("${CMAKE_CXX_COMPILER_VERSION}" STREQUAL "")
		message(WARNING 
			"Couldn't detect compiler version, skipping version checks. "
			"Build may fail if the compiler doesn't support C++17 fully.")
	elseif (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7")
		message(FATAL_ERROR
			"Detected GCC version older than 7, which does not fully support "
			"C++17. Supported versions are GCC 7, 9 and later. Use a newer GCC "
			"version, or Clang 6 or later."
		)
	elseif (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8.0" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8.4")
		message(FATAL_ERROR
			"Detected GCC 8 version < 8.4, which is not supported due to a "
			"regression in its C++17 guaranteed copy elision support. Use a "
			"newer GCC version, or Clang 6 or later."
		)
	elseif (FALSE)
		# checking for mingw win32?
	endif()
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
	if ("${CMAKE_CXX_COMPILER_VERSION}" STREQUAL "")
		message(WARNING 
			"Couldn't detect compiler version, skipping version checks. "
			"Build may fail if the compiler doesn't support C++17 fully."
		)
	# Apple LLVM versions differ from upstream LLVM version \o/, compare
	# in https://en.wikipedia.org/wiki/Xcode#Toolchain_versions
	elseif (godot_platform MATCHES "(macos|ios)")
		if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0")
			message(FATAL_ERROR
				"Detected Clang version older than 6, which does not fully support "
				"C++17. Supported versions are Clang 6 and later."
			)
		elseif (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0")
			message(FATAL_ERROR
				"Detected Apple Clang version older than 10, which does not fully "
				"support C++17. Supported versions are Apple Clang 10 and later."
			)
		endif()
	elseif (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0")
		message(FATAL_ERROR
			"Detected Clang version older than 6, which does not fully support "
			"C++17. Supported versions are Clang 6 and later."
		)
	endif()
endif()

# Configure compiler warnings
if (MSVC)
	target_compile_options(thirdparty-warnings-env INTERFACE "/w")

	if (godot_warnings STREQUAL "no")
		target_compile_options(global-warnings-env INTERFACE "/w")
	else()
		if (godot_warnings STREQUAL "extra")
			target_compile_options(global-warnings-env INTERFACE "/W4")
		elseif (godot_warnings STREQUAL "all")
			# C4458 is like -Wshadow. Part of /W4 but let's apply it for the default /W3 too.
			target_compile_options(global-warnings-env INTERFACE "/W3" "/w34458")
		elseif (godot_warnings STREQUAL "moderate")
			target_compile_options(global-warnings-env INTERFACE "/W2")
		endif()

		# Disable warnings which we don't plan to fix.
		target_compile_options(global-warnings-env INTERFACE 
			"/wd4100" # C4100 (unreferenced formal parameter): Doesn't play nice with polymorphism.
			"/wd4127" # C4127 (conditional expression is constant)
			"/wd4201" # C4201 (non-standard nameless struct/union): Only relevant for C89.
			"/wd4244" # C4244 C4245 C4267 (narrowing conversions): Unavoidable at this scale.
			"/wd4245"
			"/wd4267"
			"/wd4305" # C4305 (truncation): double to float or real_t, too hard to avoid.
			"/wd4514" # C4514 (unreferenced inline function has been removed)
			"/wd4714" # C4714 (function marked as __forceinline not inlined)
			"/wd4820" # C4820 (padding added after construct)
		)
	endif()

	# Set exception handling model to avoid warnings caused by Windows system headers.
	target_compile_options(global-warnings-env INTERFACE "/EHsc")

	if (godot_werror)
		target_compile_options(global-warnings-env INTERFACE "/WX")
	endif()
else() # GCC, Clang
	target_compile_options(thirdparty-warnings-env INTERFACE "-w")

	set(__COMMON_WARNINGS "")
	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		list(APPEND __COMMON_WARNINGS "-Wshadow" "-Wno-misleading-indentation")
		if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "7" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8")
			list(APPEND __COMMON_WARNINGS "-Wno-strict-overflow")
		endif()

		if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "11")
			# Regression in GCC 9/10, spams so much in our variadic templates
			# that we need to outright disable it.
			list(APPEND __COMMON_WARNINGS "-Wno-type-limits")
		endif()

		if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12")
			# False positives in our error macros, see GH-58747.
			list(APPEND __COMMON_WARNINGS "-Wno-return-type")
		endif()
	elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		# We often implement `operator<` for structs of pointers as a requirement
		# for putting them in `Set` or `Map`. We don't mind about unreliable ordering.
		list(APPEND __COMMON_WARNINGS
			"-Wno-ordered-compare-function-pointers"
			"-Wshadow-field-in-constructor"
			"-Wshadow-uncaptured-local"
		)
	endif()

	if (godot_warnings STREQUAL "extra")
		target_compile_options(global-warnings-env INTERFACE
			"-Wall"
			"-Wextra"
			"-Wwrite-strings"
			"-Wno-unused-parameter"
			${__COMMON_WARNINGS}
		)
		target_compile_options(global-warnings-env INTERFACE
			$<$<COMPILE_LANGUAGE:CXX>:-Wctor-dtor-privacy;-Wnon-virtual-dtor>
		)

		if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
			target_compile_options(global-warnings-env INTERFACE
				"-Walloc-zero"
				"-Wduplicated-branches"
				"-Wduplicated-cond"
				"-Wstringop-overflow=4"
			)
			target_compile_options(global-warnings-env INTERFACE
				$<$<COMPILE_LANGUAGE:CXX>:-Wplacement-new=1>
			)

			# Need to fix a warning with AudioServer lambdas before enabling.
			# if cc_version_major != 9:  # GCC 9 had a regression (GH-36325).
			#    env.Append(CXXFLAGS=["-Wnoexcept"])

			if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "9")
				target_compile_options(global-warnings-env INTERFACE "-Wattribute-alias=2")
			endif()

			if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "11")
				# Broke on MethodBind templates before GCC 11.
				target_compile_options(global-warnings-env INTERFACE "-Wlogical-op")
			endif()
		elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			target_compile_options(global-warnings-env INTERFACE "-Wimplicit-fallthrough")
		endif()
	elseif (godot_warnings STREQUAL "all")
		target_compile_options(global-warnings-env INTERFACE "-Wall" ${__COMMON_WARNINGS})
	elseif (godot_warnings STREQUAL "moderate")
		target_compile_options(global-warnings-env INTERFACE "-Wall" "-Wno-unused" ${__COMMON_WARNINGS})
	else()
		target_compile_options(global-warnings-env INTERFACE "-w")
	endif()
endif()

############### Configuring modules ###############

# just to keep track of all classes
set(MODULES_CLASSES "")
# just to keep track of all unique classes directories paths
set(CLASSES_DOC_PATHS "")
# to keep track of all icons paths
set(MODULES_ICONS_PATHS "")
# Actually enabled modules which can be built
set(MODULES_LIST "")
# Version string for the module
set(MODULES_VERSION_STRING "")

foreach (__MODULE_ID IN LISTS MODULES_IDS)
	if (NOT "${godot_module_${__MODULE_ID}_enabled}")
		continue()
	endif()

	cmake_language(CALL ${__MODULE_ID}_get_module_can_build "${__MODULE_ID}_MODULE_CAN_BUILD")

	if(NOT ${__MODULE_ID}_MODULE_CAN_BUILD)
		message(WARNING "Module '${__MODULE_ID}' was enabled, but can't be built. Skipping this module.")
		continue()
	endif()

	if (COMMAND ${__MODULE_ID}_get_module_dependencies)
		cmake_language(CALL ${__MODULE_ID}_get_module_dependencies "${__MODULE_ID}_REQUIRED_DEPENDENCIES" "${__MODULE_ID}_OPTIONAL_DEPENDENCIES")
	endif()

	check_module_dependencies(__DEPENDENCIES_MET "${__MODULE_ID}")

	if (NOT __DEPENDENCIES_MET)
		continue()
	endif()

	cmake_language(CALL ${__MODULE_ID}_configure_module)

	if (COMMAND "${__MODULE_ID}_get_version_string")
		cmake_language(CALL "${__MODULE_ID}_get_version_string" ${__MODULE_ID}_VERSION_STRING)
		if (NOT "${${__MODULE_ID}_VERSION_STRING}" STREQUAL "")
			set(MODULES_VERSION_STRING "${MODULES_VERSION_STRING}.${${__MODULE_ID}_VERSION_STRING}")
		endif()
	endif()

	# Get doc classes paths (if present)
	if(COMMAND "${__MODULE_ID}_get_doc_classes" AND COMMAND "${__MODULE_ID}_get_doc_relative_path")
		cmake_language(CALL "${__MODULE_ID}_get_doc_classes" ${__MODULE_ID}_MODULE_DOC_CLASSES)
		cmake_language(CALL "${__MODULE_ID}_get_doc_relative_path" ${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH)

		join_paths(__DOC_ABS_PATH "${${__MODULE_ID}_MODULE_PATH}" "${${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH}")
		
		if (NOT __DOC_ABS_PATH IN_LIST CLASSES_DOC_PATHS) 
			list(APPEND CLASSES_DOC_PATHS "${__DOC_ABS_PATH}")
		endif()

		foreach(__MODULE_CLASS IN LISTS ${__MODULE_ID}_MODULE_DOC_CLASSES)
			if (DEFINED ${__MODULE_CLASS}_CLASS_PATH)
				# if class allready was defined.
				message(WARNING "Class with the name \"${__MODULE_CLASS}\" already was defined by another module. Old class path is \"${${__MODULE_CLASS}_CLASS_PATH}\". New class path is \"${__DOC_ABS_PATH}\". New class documentation will be discarded.")
				continue()
			endif()

			# setting path of the specific class
			set(${__MODULE_CLASS}_CLASS_PATH "${__DOC_ABS_PATH}")
			list(APPEND MODULES_CLASSES "${__MODULE_CLASS}")
		endforeach()
	endif()

	# configuring icons
	if(COMMAND "${__MODULE_ID}_get_relative_icon_path")
		cmake_language(CALL "${__MODULE_ID}_get_relative_icon_path" __ICON_DIR)
	else()
		set(__ICON_DIR "icons")
	endif()
	# just to keep track of it
	join_paths(${__MODULE_ID}_ICONS_PATH "${${__MODULE_ID}_MODULE_PATH}" "${__ICON_DIR}")
	list(APPEND MODULES_ICONS_PATHS "${${__MODULE_ID}_ICONS_PATH}")

	list(APPEND MODULES_LIST "${__MODULE_ID}")
endforeach()

# This will not be quite.. Composing modules dependencies map for python
parse_to_python_var(__PYTHON_MODULES_LIST ARR_VAR MODULES_LIST)
set(__PYTHON_DEPENDENCIES_MAP "{")
set(__FIRST TRUE)

foreach (__MODULE_ID IN LISTS MODULES_LIST)
	if (__FIRST)
		set(__FIRST FALSE)
	else()
		set(__PYTHON_DEPENDENCIES_MAP "${__PYTHON_DEPENDENCIES_MAP},")
	endif()

	parse_to_python_var(__PYTHON_REQURIED_DEPENDENCIES ARR_VAR "${__MODULE_ID}_REQUIRED_DEPENDENCIES")
	parse_to_python_var(__PYTHON_OPTIONAL_DEPENDENCIES ARR_VAR "${__MODULE_ID}_OPTIONAL_DEPENDENCIES")

	set(__PYTHON_DEPENDENCIES_MAP "${__PYTHON_DEPENDENCIES_MAP}'${__MODULE_ID}':[${__PYTHON_REQURIED_DEPENDENCIES},${__PYTHON_OPTIONAL_DEPENDENCIES}]")
endforeach()
set(__PYTHON_DEPENDENCIES_MAP "${__PYTHON_DEPENDENCIES_MAP}}")

execute_python_method(cmake_methods sort_module_list
	PYTHON_ARGS
		"RAW_VAR" "module_list=__PYTHON_MODULES_LIST"
		"RAW_VAR" "module_dependencies=__PYTHON_DEPENDENCIES_MAP"
	OUTPUT_VARIABLE MODULES_LIST
)

execute_python_method(cmake_methods generate_version_header
	PYTHON_ARGS
		STR_VAR "MODULES_VERSION_STRING"
	ACTION_CACHE_NAME "generate_version_header"
	DEPENDENT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/core/version_generated.gen.h"
)

############### Processing program suffix ###############

# If I correct, order of suffixes should work like that:
# 1. Suffix specified by the platform (or the platform name itself)
# 2. Target (in our case .editor/.release/.debug)
# 3. ".dev" if godot_dev_build
# 4. ".double" if godot_precision == "double"
# 5. Architecture
# 6. Anything user specifies in godot_extra_suffix
# 7. Anything platform will add in <platform_id>_configure_platform method
# And only for godot main program:
# 8. Anything modules could have returned from _get_version_string method (specifically mono)

# Processing suffix for the godot program and libraries
# This variable will be used by add_lib and add_exe functions,
# as a default suffix for libraries and executables.
set(__SUFFIX "")

if(COMMAND "${godot_platform}_get_program_suffix")
	cmake_language(CALL "${godot_platform}_get_program_suffix" "__${godot_platform}_PROGRAM_SUFFIX")
else()
	set("__${godot_platform}_PROGRAM_SUFFIX" "${godot_platform}")
endif()

set(__SUFFIX "${__SUFFIX}.${__${godot_platform}_PROGRAM_SUFFIX}")

if (godot_editor_build)
	set(__SUFFIX "${__SUFFIX}.editor")
else()
	set(__SUFFIX "${__SUFFIX}$<IF:${IS_RELEASE_GEN_EXPR},.template_release,.template_debug>")
endif()

if (godot_dev_build)
	set(__SUFFIX "${__SUFFIX}.dev")
endif()

if (godot_precision STREQUAL "double")
	set(__SUFFIX "${__SUFFIX}.double")
endif()

set(__SUFFIX "${__SUFFIX}.${PROCESSOR_ARCH_ALIAS}")

if(NOT godot_extra_suffix STREQUAL "")
	set(__SUFFIX "${__SUFFIX}.${godot_extra_suffix}")
endif()

# Prepend extra suffix
target_property(PREPEND_STR global-env EXTRA_SUFFIX "${__SUFFIX}")

if (godot_disable_3d)
	if (godot_editor_build)
		message(FATAL_ERROR 
			"Build option 'disable_3d=yes' cannot be used for editor builds, "
			"but only for export templates.")
	endif()

	target_compile_definitions(global-env INTERFACE "_3D_DISABLED")
endif()

if (godot_disable_advance_gui)
	if (godot_editor_build)
		message(FATAL_ERROR 
			"Build option 'disable_advanced_gui=yes' cannot be used for editor builds, "
			"but only for export templates."
		)
	endif()

	target_compile_definitions(global-env INTERFACE "ADVANCED_GUI_DISABLED")
endif()

if (godot_minizip)
	target_compile_definitions(global-env INTERFACE "MINIZIP_ENABLED")
endif()

add_env(global-libs-list)

add_subdirectory(core)
add_subdirectory(servers)
add_subdirectory(scene)
if (godot_editor_build)
	add_subdirectory(editor)
endif()
add_subdirectory(drivers)
add_subdirectory(platform)
add_subdirectory(modules)
if (godot_tests)
	add_subdirectory(tests)
endif()
add_subdirectory(main)
add_subdirectory("platform/${godot_platform}")