' emPolygonizer4_DisplayPluginManagerPlugin
' 
' displays the plugin manager view
' 

function XSILoadPlugin( in_reg )
	in_reg.Author = "Eric Mootz"
	in_reg.Name = "emPolygonizer4_DisplayPluginManagerPlugin"
	in_reg.Major = 1
	in_reg.Minor = 0
	in_reg.RegisterCommand "emPolygonizer4_DisplayPluginManager","emPolygonizer4_DisplayPluginManager"
	'RegistrationInsertionPoint - do not remove this line
	XSILoadPlugin = true
end function

function XSIUnloadPlugin( in_reg )
	dim strPluginName
	strPluginName = in_reg.Name
	XSIUnloadPlugin = true
end function

function emPolygonizer4_DisplayPluginManager_Init( in_ctxt )
	dim oCmd
	set oCmd = in_ctxt.Source
	oCmd.Description = ""
	oCmd.ReturnValue = true
	emPolygonizer4_DisplayPluginManager_Init = true
end function

function emPolygonizer4_DisplayPluginManager_Execute(  )
	set layout = Desktop.ActiveLayout
	set v = Layout.CreateView( "Plugin Manager", "Plugin Manager" )
	v.move		8+72, 400
	v.resize   420,750	'
	emPolygonizer4_DisplayPluginManager_Execute = true
end function

