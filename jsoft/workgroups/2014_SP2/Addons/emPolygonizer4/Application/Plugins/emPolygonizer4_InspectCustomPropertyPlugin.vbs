' emPolygonizer4_InspectCustomPropertyPlugin

function XSILoadPlugin( in_reg )
	in_reg.Author = "Eric Mootz"
	in_reg.Name = "emPolygonizer4_InspectCustomPropertyPlugin"
	in_reg.Email = ""
	in_reg.URL = ""
	in_reg.Major = 1
	in_reg.Minor = 0

	in_reg.RegisterCommand "emPolygonizer4_InspectCustomProperty","emPolygonizer4_InspectCustomProperty"
	'RegistrationInsertionPoint - do not remove this line

	XSILoadPlugin = true
end function

function XSIUnloadPlugin( in_reg )
	dim strPluginName
	strPluginName = in_reg.Name
	Application.LogMessage strPluginName & " has been unloaded.",siVerbose
	XSIUnloadPlugin = true
end function

function emPolygonizer4_InspectCustomProperty_Init( in_ctxt )
	dim oCmd
	set oCmd = in_ctxt.Source
	oCmd.Description = ""
	oCmd.ReturnValue = true

	emPolygonizer4_InspectCustomProperty_Init = true
end function

function emPolygonizer4_InspectCustomProperty_Execute(  )

	Dim sl,p,plist,o
	set sl = GetValue("SelectionList")
	if sl.Count <> 1 then
		Exit Function
	end if

	set plist = sl(0).Properties
	for each p in plist
		if typename(p) = "CustomProperty" then
			Dim lft
			lft = Left(p.name,Len("emPolygonizer4"))
			if lft = "emPolygonizer4" then
				InspectObj p.fullname
				Exit Function
			end if
			lft = Left(p.name,Len("emTopolizer"))
			if lft = "emTopolizer" then
				InspectObj p.fullname
				Exit Function
			end if
		end if
	next
	
	Dim op,oOpStack
	for each o in sl
		if o.type = "polymsh" then
			set oOpStack = o.ActivePrimitive.ConstructionHistory
			for each op in oOpStack
				if op.name = "emPolygonizer4" then
					InspectObj op.fullname
					Exit Function
				end if
				if op.name = "emReader" then
					InspectObj op.fullname
					Exit Function
				end if
			next
		end if
	next
 
	emPolygonizer4_InspectCustomProperty_Execute = true
end function

