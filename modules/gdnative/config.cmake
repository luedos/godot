# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	set_target_properties(global-env PROPERTIES USE_PTRCALL true)
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	set(${__OUTPUT} true PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_doc_classes __OUTPUT)
	set(${__OUTPUT}
		"ARVRInterfaceGDNative"
		"GDNative"
		"GDNativeLibrary"
		"MultiplayerPeerGDNative"
		"NativeScript"
		"PacketPeerGDNative"
		"PluginScript"
		"StreamPeerGDNative"
		"VideoStreamGDNative"
		"WebRTCPeerConnectionGDNative"
		"WebRTCDataChannelGDNative"
		PARENT_SCOPE
	)
endfunction()

function(${__MODULE_NAME}_get_doc_relative_path __OUTPUT)
	set(${__OUTPUT} "doc_classes" PARENT_SCOPE)
endfunction()
