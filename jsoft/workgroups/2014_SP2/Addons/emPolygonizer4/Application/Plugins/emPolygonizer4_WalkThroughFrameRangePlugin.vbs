' emPolygonizer4_WalkThroughFrameRangePlugin

function XSILoadPlugin( in_reg )
	in_reg.Author = "Eric Mootz"
	in_reg.Name = "emPolygonizer4_WalkThroughFrameRangePlugin"
	in_reg.Email = ""
	in_reg.URL = ""
	in_reg.Major = 1
	in_reg.Minor = 0

	in_reg.RegisterCommand "emPolygonizer4_WalkThroughFrameRange","emPolygonizer4_WalkThroughFrameRange"
	'RegistrationInsertionPoint - do not remove this line

	XSILoadPlugin = true
end function

function XSIUnloadPlugin( in_reg )
	dim strPluginName
	strPluginName = in_reg.Name
	Application.LogMessage strPluginName & " has been unloaded.",siVerbose
	XSIUnloadPlugin = true
end function

function emPolygonizer4_WalkThroughFrameRange_Init( in_ctxt )
	dim oCmd
	set oCmd = in_ctxt.Source
	oCmd.Description = ""
	'
	Dim oArgs
	set oArgs = oCmd.Arguments
	oArgs.Add "frmStart",	siArgumentInput,	0
	oArgs.Add "frmEnd",		siArgumentInput,	0
	oArgs.Add "frmStep",	siArgumentInput,	0
	'
	oCmd.ReturnValue = fasle
	'
	emPolygonizer4_WalkThroughFrameRange_Init = true
end function

function emPolygonizer4_WalkThroughFrameRange_Execute( frmStart, frmEnd, frmStep )
	'
	if frmStart>frmEnd OR frmStep<=0 then
		logmessage "Illegal parameter value !", siError
		Exit Function
	end if
	
	'
	Dim oProgressBar
	Set oProgressBar			= XSIUIToolkit.ProgressBar
	oProgressBar.Maximum		= 1 + Fix( (frmEnd-frmStart)/frmStep )
	oProgressBar.CancelEnabled	= true
	oProgressBar.Caption		= "Processing.."
	oProgressBar.Visible		= true
	'
	Dim frame 
	frame = frmStart
	'
	Do While oProgressBar.CancelPressed<>True And oProgressBar.Value < oProgressBar.Maximum
		SetValue "PlayControl.Current", frame
		frame = frame + frmStep
		'SceneRefresh
		Refresh
		oProgressBar.Increment
	Loop

	'
	logmessage "finished walking through " & oProgressBar.Maximum & " frame(s)."

	' 
	emPolygonizer4_WalkThroughFrameRange_Execute = true
end function

