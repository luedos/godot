
set(__GEN_TARGETS "")

if (godot_use_sowrap)
	macro(__wayland_api_header __TARGET __SOURCE)
		list(APPEND __GEN_TARGETS "${__TARGET}")
		set(__TARGET_PATH "${__TARGET}")
		cmake_path(GET __TARGET_PATH PARENT_PATH __TARGET_PARENT_PATH)
		add_custom_command(
			OUTPUT "${__TARGET}"
			COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${__TARGET_PARENT_PATH}"
			COMMAND "wayland-scanner" "-c" "client-header" "<" "${__SOURCE}" "|" "sed" "s:wayland-client-core\\.h:../dynwrappers/wayland-client-core-so_wrap\\.h:" ">" "${__TARGET}"
			DEPENDS "${__SOURCE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "Generating Wayland client header: \"${TARGET}\""
			VERBATIM
		)
	endmacro()
	macro(__wayland_api_code __TARGET __SOURCE)
		list(APPEND __GEN_TARGETS "${__TARGET}")
		set(__TARGET_PATH "${__TARGET}")
		cmake_path(GET __TARGET_PATH PARENT_PATH __TARGET_PARENT_PATH)
		add_custom_command(
			OUTPUT "${__TARGET}"
			COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${__TARGET_PARENT_PATH}"
			COMMAND "wayland-scanner" "-c" "private-code" "<" "${__SOURCE}" "|" "sed" "s:wayland-util\\.h:../dynwrappers/wayland-client-core-so_wrap\\.h:" ">" "${__TARGET}"
			DEPENDS "${__SOURCE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "Generating Wayland protocol marshaling code: \"${TARGET}\""
			VERBATIM
		)
	endmacro()
else()
	macro(__wayland_api_header __TARGET __SOURCE)
		list(APPEND __GEN_TARGETS "${__TARGET}")
		set(__TARGET_PATH "${__TARGET}")
		cmake_path(GET __TARGET_PATH PARENT_PATH __TARGET_PARENT_PATH)
		add_custom_command(
			OUTPUT "${__TARGET}"
			COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${__TARGET_PARENT_PATH}"
			COMMAND "wayland-scanner" "-c" "client-header" "<" "${__SOURCE}" ">" "${__TARGET}"
			DEPENDS "${__SOURCE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "Generating Wayland client header: \"${TARGET}\""
			VERBATIM
		)
	endmacro()
	macro(__wayland_api_code __TARGET __SOURCE)
		list(APPEND __GEN_TARGETS "${__TARGET}")
		set(__TARGET_PATH "${__TARGET}")
		cmake_path(GET __TARGET_PATH PARENT_PATH __TARGET_PARENT_PATH)
		add_custom_command(
			OUTPUT "${__TARGET}"
			COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${__TARGET_PARENT_PATH}"
			COMMAND "wayland-scanner" "-c" "client-code" "<" "${__SOURCE}" ">" "${__TARGET}"
			DEPENDS "${__SOURCE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "Generating Wayland protocol marshaling code: \"${TARGET}\""
			VERBATIM
		)
	endmacro()
endif()

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/wayland.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland/protocol/wayland.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/wayland.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland/protocol/wayland.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/viewporter.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/stable/viewporter/viewporter.xml"
)
__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/viewporter.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/stable/viewporter/viewporter.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/fractional_scale.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/staging/fractional-scale/fractional-scale-v1.xml"
)
__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/fractional_scale.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/staging/fractional-scale/fractional-scale-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_shell.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/stable/xdg-shell/xdg-shell.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_shell.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/stable/xdg-shell/xdg-shell.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_decoration.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_decoration.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_activation.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/staging/xdg-activation/xdg-activation-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_activation.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/staging/xdg-activation/xdg-activation-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/relative_pointer.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/relative-pointer/relative-pointer-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/relative_pointer.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/relative-pointer/relative-pointer-unstable-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/pointer_constraints.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/pointer_constraints.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/pointer_gestures.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/pointer-gestures/pointer-gestures-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/pointer_gestures.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/pointer-gestures/pointer-gestures-unstable-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/primary_selection.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/primary-selection/primary-selection-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/primary_selection.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/primary-selection/primary-selection-unstable-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/idle_inhibit.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/idle-inhibit/idle-inhibit-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/idle_inhibit.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/idle-inhibit/idle-inhibit-unstable-v1.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/tablet.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/tablet/tablet-unstable-v2.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/tablet.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/tablet/tablet-unstable-v2.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/text_input.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/text-input/text-input-unstable-v3.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/text_input.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/text-input/text-input-unstable-v3.xml"
)

__wayland_api_header(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_foreign.gen.h"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/xdg-foreign/xdg-foreign-unstable-v1.xml"
)

__wayland_api_code(
	"${CMAKE_CURRENT_SOURCE_DIR}/protocol/xdg_foreign.gen.c"
	"${ENGINE_SOURCE_DIR}/thirdparty/wayland-protocols/unstable/xdg-foreign/xdg-foreign-unstable-v1.xml"
)

add_custom_target(wayland-gen)
target_sources(wayland-gen PRIVATE ${__GEN_TARGETS})
set_source_files_properties(${__GEN_TARGETS} TARGET_DIRECTORY wayland-gen PROPERTIES GENERATED TRUE)

add_dependencies(godot-exe wayland-gen)

target_sources(godot-exe PRIVATE
	"protocol/wayland.gen.c"
	"protocol/viewporter.gen.c"
	"protocol/fractional_scale.gen.c"
	"protocol/xdg_shell.gen.c"
	"protocol/xdg_foreign.gen.c"
	"protocol/xdg_decoration.gen.c"
	"protocol/xdg_activation.gen.c"
	"protocol/relative_pointer.gen.c"
	"protocol/pointer_constraints.gen.c"
	"protocol/pointer_gestures.gen.c"
	"protocol/primary_selection.gen.c"
	"protocol/idle_inhibit.gen.c"
	"protocol/tablet.gen.c"
	"protocol/text_input.gen.c"
	"display_server_wayland.cpp"
	"wayland_thread.cpp"
	"key_mapping_xkb.cpp"
	"detect_prime_egl.cpp"
)

if (godot_use_sowrap)
	target_sources(godot-exe PRIVATE
		"dynwrappers/wayland-cursor-so_wrap.c"
		"dynwrappers/wayland-client-core-so_wrap.c"
		"dynwrappers/wayland-egl-core-so_wrap.c"
	)

	if (godot_libdecor)
		target_sources(godot-exe PRIVATE "dynwrappers/libdecor-so_wrap.c")
	endif()
endif()

if (godot_vulkan)
	target_sources(godot-exe PRIVATE "rendering_context_driver_vulkan_wayland.cpp")
endif()

if (godot_opengl3)
	target_sources(godot-exe PRIVATE
		"egl_manager_wayland.cpp"
		"egl_manager_wayland_gles.cpp"
	)
endif()

