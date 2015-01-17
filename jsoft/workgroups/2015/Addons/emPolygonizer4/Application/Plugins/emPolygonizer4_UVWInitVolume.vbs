' emPolygonizer4_UVWInitVolumePlugin
' Initial code generated by XSI SDK Wizard
' Executed Fri Jun 12 10:03:15 UTC+0200 2009 by Administrator
' 

function XSILoadPlugin( in_reg )
	in_reg.Author = "Eric Mootz"
	in_reg.Name = "emPolygonizer4_UVWInitVolumePlugin"
	in_reg.Email = "info@mootzoid.com"
	in_reg.URL = "http://www.mootzoid.com/"
	in_reg.Major = 1
	in_reg.Minor = 0
	in_reg.Help = "http://www.mootzoid.com/wb/pages/documentation/empolygonizer4_redirect_TheCPSUVWInitVolume.html"

	in_reg.RegisterProperty "emPolygonizer4_UVWInitVolume"
	'RegistrationInsertionPoint - do not remove this line

	XSILoadPlugin = true
end function

function XSIUnloadPlugin( in_reg )
	dim strPluginName
	strPluginName = in_reg.Name
	Application.LogMessage strPluginName & " has been unloaded.",siVerbose
	XSIUnloadPlugin = true
end function

function emPolygonizer4_UVWInitVolume_Define( in_ctxt )
	dim oCustomProperty
	set oCustomProperty = in_ctxt.Source
	oCustomProperty.AddParameter2 "active",					siBool,		true,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "strength",				siFloat,	1.0,	-100000,100000,	0,1,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "falloffType",			siInt4,		3,		0,100,			0,4,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	'
	emPolygonizer4_UVWInitVolume_Define = true
end function

function myownDefineLayout( oLayout )
	dim oItem

	oLayout.Clear 
	oLayout.SetAttribute siUIDictionary, "None"
	' tab "Main"
	oLayout.AddTab "Main"
		oLayout.AddItem "active",								"Active"
		oLayout.AddItem "strength",								"Strength"
		Dim lv2(9)
		lv2(0) = "None"
		lv2(1) = 0
		lv2(2) = "Square Root"
		lv2(3) = 1
		lv2(4) = "Linear"
		lv2(5) = 2
		lv2(6) = "Square"
		lv2(7) = 3
		lv2(8) = "Cubic"
		lv2(9) = 4
		oLayout.AddEnumControl "falloffType", lv2,				"Falloff Type", siControlCombo
end function

function emPolygonizer4_UVWInitVolume_DefineLayout( in_ctxt )
	dim oLayout
	set oLayout = in_ctxt.Source
	myownDefineLayout	oLayout
	emPolygonizer4_UVWInitVolume_DefineLayout = true
end function

function emPolygonizer4_UVWInitVolume_OnInit( )
	myownDefineLayout PPG.PPGLayout 
	PPG.Refresh
end function

function emPolygonizer4_UVWInitVolume_OnClosed( )
end function



