# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	set(${__OUTPUT} true PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_doc_classes __OUTPUT)
	set(${__OUTPUT}
		"VisualScriptBasicTypeConstant"
		"VisualScriptBuiltinFunc"
		"VisualScriptClassConstant"
		"VisualScriptComment"
		"VisualScriptComposeArray"
		"VisualScriptCondition"
		"VisualScriptConstant"
		"VisualScriptConstructor"
		"VisualScriptCustomNode"
		"VisualScriptDeconstruct"
		"VisualScriptEditor"
		"VisualScriptEmitSignal"
		"VisualScriptEngineSingleton"
		"VisualScriptExpression"
		"VisualScriptFunctionCall"
		"VisualScriptFunctionState"
		"VisualScriptFunction"
		"VisualScriptGlobalConstant"
		"VisualScriptIndexGet"
		"VisualScriptIndexSet"
		"VisualScriptInputAction"
		"VisualScriptIterator"
		"VisualScriptLists"
		"VisualScriptLocalVarSet"
		"VisualScriptLocalVar"
		"VisualScriptMathConstant"
		"VisualScriptNode"
		"VisualScriptOperator"
		"VisualScriptPreload"
		"VisualScriptPropertyGet"
		"VisualScriptPropertySet"
		"VisualScriptResourcePath"
		"VisualScriptReturn"
		"VisualScriptSceneNode"
		"VisualScriptSceneTree"
		"VisualScriptSelect"
		"VisualScriptSelf"
		"VisualScriptSequence"
		"VisualScriptSubCall"
		"VisualScriptSwitch"
		"VisualScriptTypeCast"
		"VisualScriptVariableGet"
		"VisualScriptVariableSet"
		"VisualScriptWhile"
		"VisualScript"
		"VisualScriptYieldSignal"
		"VisualScriptYield"
		PARENT_SCOPE
	)
endfunction()

function(${__MODULE_NAME}_get_doc_relative_path __OUTPUT)
	set(${__OUTPUT} "doc_classes" PARENT_SCOPE)
endfunction()
