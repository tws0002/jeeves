' emTools_DisplayScriptHistoryPlugin
' 
' displays the plugin manager view
' 

function XSILoadPlugin( in_reg )
	in_reg.Author = "Eric Mootz"
	in_reg.Name = "emTools_DisplayScriptHistoryPlugin"
	in_reg.Major = 1
	in_reg.Minor = 0
	in_reg.RegisterCommand "emTools_DisplayScriptHistory","emTools_DisplayScriptHistory"
	'RegistrationInsertionPoint - do not remove this line
	XSILoadPlugin = true
end function

function XSIUnloadPlugin( in_reg )
	dim strPluginName
	strPluginName = in_reg.Name
	XSIUnloadPlugin = true
end function

function emTools_DisplayScriptHistory_Init( in_ctxt )
	dim oCmd
	set oCmd = in_ctxt.Source
	oCmd.Description = ""
	oCmd.ReturnValue = true
	emTools_DisplayScriptHistory_Init = true
end function

function emTools_DisplayScriptHistory_Execute(  )
	set layout = Desktop.ActiveLayout
	set v = Layout.CreateView( "Script History", "Script History" )
	x = 800
	v.move	1920+4 - x, 475
	v.resize		 x, 600
	emTools_DisplayScriptHistory_Execute = true
end function

