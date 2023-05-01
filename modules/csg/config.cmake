# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	if (NOT godot_disable_3d)
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()

function(${__MODULE_NAME}_get_doc_classes __OUTPUT)
	set(${__OUTPUT}
		"CSGBox3D"
		"CSGCombiner3D"
		"CSGCylinder3D"
		"CSGMesh3D"
		"CSGPolygon3D"
		"CSGPrimitive3D"
		"CSGShape3D"
		"CSGSphere3D"
		"CSGTorus3D"
		PARENT_SCOPE
	)
endfunction()

function(${__MODULE_NAME}_get_doc_relative_path __OUTPUT)
	set(${__OUTPUT} "doc_classes" PARENT_SCOPE)
endfunction()