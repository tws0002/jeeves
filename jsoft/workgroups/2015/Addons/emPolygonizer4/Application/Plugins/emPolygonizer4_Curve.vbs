' emPolygonizer4_CurvePlugin
' Initial code generated by XSI SDK Wizard
' Executed Fri Jun 12 12:57:13 UTC+0200 2009 by Administrator
' 

function XSILoadPlugin( in_reg )
	in_reg.Author = "Eric Mootz"
	in_reg.Name = "emPolygonizer4_CurvePlugin"
	in_reg.Email = "info@mootzoid.com"
	in_reg.URL = "http://www.mootzoid.com/"
	in_reg.Major = 1
	in_reg.Minor = 0
	in_reg.Help = "http://www.mootzoid.com/wb/pages/documentation/empolygonizer4_redirect_TheCPSCurve.html"
	
	in_reg.RegisterProperty "emPolygonizer4_Curve"
	'RegistrationInsertionPoint - do not remove this line

	XSILoadPlugin = true
end function

function XSIUnloadPlugin( in_reg )
	dim strPluginName
	strPluginName = in_reg.Name
	Application.LogMessage strPluginName & " has been unloaded.",siVerbose
	XSIUnloadPlugin = true
end function

function emPolygonizer4_Curve_Define( in_ctxt )
	dim oFCurveParam,oFCurve,oKey
	dim oCustomProperty
	set oCustomProperty = in_ctxt.Source
	oCustomProperty.AddParameter2 "ppg_showall_liquid",		siBool,		false,	,,,,							siClassifUnknown,	siPersistable OR siSilent OR siNotInspectable
	oCustomProperty.AddParameter2 "active",					siBool,		true,	,,,,						siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "use",					siInt4,		5,		0,100,			0,100,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "isofactor",				siFloat,	1,		-100000,100000,	0,2,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "stepsPerSIunit",			siFloat,	3,		0.0001,10000,	0.5,5,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "isofactor_mulByFCurve",	siBool,		false,	,,,,						siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "radius",					siFloat,	1.0,	0,100000,		0,2.5,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "radius_mulByFCurve",		siBool,		false,	,,,,						siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "falloff",				siFloat,	0.5,	0,100000,		0,5,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "falloff_mulByFCurve",	siBool,		false,	,,,,						siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "falloffType",			siInt4,		3,		0,100,			0,4,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "color_baseR",			siDouble,	0.5,	-100000,100000,	0,1,		siClassifUnknown,	siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "color_baseG",			siDouble,	0.8,	-100000,100000,	0,1,		siClassifUnknown,	siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "color_baseB",			siDouble,	0.3,	-100000,100000,	0,1,		siClassifUnknown,	siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "color_baseA",			siDouble,	1.0,	-100000,100000,	0,1,		siClassifUnknown,	siPersistable OR siAnimatable OR siKeyable
	'
	oCustomProperty.AddParameter2 "mtnActive",				siBool,		true,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "mtnSpeed",				siFloat,	1,		0,10000000,		0,2,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "mtnOffset",				siFloat,	0,		-100000,100000,	-0.5,0.5,		siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "mtnPosition",			siInt4,		0,		,,				,,				siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "mtnCompRad",				siFloat,	1,		0,1,			0,1,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	'
	oCustomProperty.AddParameter2 "LFactive",				siBool,		true,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFself",					siBool,		false,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFcaster",				siBool,		true,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFreceiver",				siBool,		true,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFoptimizedplotting",	siBool,		true,	,,,,							siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFdetail",				siFloat,	1.5,	0.0001,100000,	0.5,4,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFdistance",				siFloat,	5,		0.0001,1000000,	0,10,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFiso",					siFloat,	1,		0,1000000,		0,2,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFthickness",			siFloat,	1,		0,1,			0,1,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFmeetingpoint",			siFloat,	0.4,	0,1,			0.1,1,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFneighMode",			siInt4,		1,		,,				,,				siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFneighMaxNum",			siFloat,	5,		0,,				1,15,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFneighMaxNumFade",		siFloat,	8,		0,,				1,15,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFneighMaxWeight",		siFloat,	9,		0,,				1,15,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	oCustomProperty.AddParameter2 "LFneighMaxWeightFade",	siFloat,	7,		0,,				1,15,			siClassifTopo,		siPersistable OR siAnimatable OR siKeyable
	'
	set oFCurveParam = oCustomProperty.AddFCurveParameter("LFprofile_overallfade")
	set oFCurve = oFCurveParam.Value
	oFCurve.BeginEdit
	oFCurve.RemoveKeys
	oFCurve.AddKey   0,		0
	oFCurve.AddKey	 1,		1
	set oKey = oFCurve.GetKey(0)
	oKey.RightTanX	= 0.65
	oKey.Locked		= true
	set oKey = oFCurve.GetKey(1)
	oKey.LeftTanX	= -0.2
	oFCurve.EndEdit
	'
	set oFCurveParam = oCustomProperty.AddFCurveParameter("LFprofile_overallprofile")
	set oFCurve = oFCurveParam.Value
	oFCurve.BeginEdit
	oFCurve.RemoveKeys
	oFCurve.AddKey   0,		1
	oFCurve.AddKey   0.5,	0.65
	oFCurve.AddKey	 1,		1
	set oKey = oFCurve.GetKey(0)
	oKey.RightTanY	= -0.225
	set oKey = oFCurve.GetKey(1)
	oKey.LeftTanY	= -0.225
	oFCurve.EndEdit
	'
	set oFCurveParam = oCustomProperty.AddFCurveParameter("curve_isofactor") 
	set oFCurve = oFCurveParam.Value
	oFCurve.BeginEdit
	oFCurve.RemoveKeys
	oFCurve.AddKey   0, 1
	oFCurve.AddKey 100, 0
	oFCurve.EndEdit
	'
	set oFCurveParam = oCustomProperty.AddFCurveParameter("curve_radius") 
	set oFCurve = oFCurveParam.Value
	oFCurve.BeginEdit
	oFCurve.RemoveKeys
	oFCurve.AddKey   0, 1
	oFCurve.AddKey 100, 0
	oFCurve.EndEdit
	'
	set oFCurveParam = oCustomProperty.AddFCurveParameter("curve_falloff") 
	set oFCurve = oFCurveParam.Value
	oFCurve.BeginEdit
	oFCurve.RemoveKeys
	oFCurve.AddKey   0, 1
	oFCurve.AddKey 100, 0
	oFCurve.EndEdit
	'
	emPolygonizer4_Curve_Define = true
end function

function myOwnDefineLayout( oLayout, FCurve_height_iso, FCurve_height_rad, FCurve_height_foff, LFprofile_height_overallfade, LFprofile_height_overallprofile, unused_ )
	dim oItem
	dim ppgShowAllLiquid

	' get value of "ppg_showall_liquid"
	If TypeName( PPG ) <> "Empty" Then
		ppgShowAllLiquid = PPG.ppg_showall_liquid.Value
	else
		ppgShowAllLiquid = False
	end if

	' get value of "LFneighMode"
	dim ppgLFneighMode
	ppgLFneighMode = 0
	If TypeName( PPG ) <> "Empty" then
		ppgLFneighMode = PPG.LFneighMode.Value
	end if

	oLayout.Clear 
	oLayout.SetAttribute siUIDictionary, "None"
	' tab "Main"
	oLayout.AddTab "Main"
		oLayout.AddItem "active",									"Active"
		Dim lv1(7)
		lv1(0) = "Use Object's Center"
		lv1(1) = 0
		lv1(2) = "Use Points"
		lv1(3) = 1
		lv1(4) = "Use Knots"
		lv1(5) = 4
		lv1(6) = "Use Curve and LOD"
		lv1(7) = 5
		oLayout.AddEnumControl "use", lv1,							"Use", siControlCombo
		oLayout.AddItem "stepsPerSIunit",							"LOD"
		oLayout.AddGroup "Size and Influence"
			oLayout.AddItem "isofactor",							"Isofactor"
			oLayout.AddItem "radius",								"Radius"
			oLayout.AddItem "falloff",								"Falloff"
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
		oLayout.EndGroup
		oLayout.AddGroup "Color"
			oLayout.AddColor "color_baseR",							"Base Color",true
		oLayout.EndGroup
	' tab "Motion"
	oLayout.AddTab "Motion"
		oLayout.AddGroup "Motion Plotting"
			oLayout.AddSpacer ,4
			oLayout.AddItem "mtnActive",	"Active"
			oLayout.AddItem "mtnSpeed",		"Speed"
			oLayout.AddItem "mtnOffset",	"Offset"
			Dim lvMntPos(5)
			lvMntPos(0) = "Center at Frame"
			lvMntPos(1) = 0
			lvMntPos(2) = "Start at Frame"
			lvMntPos(3) = 1
			lvMntPos(4) = "End at Frame"
			lvMntPos(5) = 2
			oLayout.AddEnumControl "mtnPosition", lvMntPos, "Position", siControlCombo
			set oItem = oLayout.AddItem( "mtnCompRad",	"Compensate Radius and Falloff" )
			oItem.SetAttribute siUILabelPercentage, 90
		oLayout.EndGroup
	' tab "Liquid"
	oLayout.AddTab "Liquid"
		oLayout.AddGroup "Liquid Filaments"
			oLayout.AddSpacer ,4
			oLayout.AddRow
				oLayout.AddGroup "", false, 33
					if ppgShowAllLiquid then i = "Hide" else i = "Show"
					i = i & " Profile FCurves"
					oLayout.AddButton "BtnShowLiquid", i	' Show/Hide Profiles
					oLayout.AddItem "LFactive",				"Active"
				oLayout.EndGroup
				oLayout.AddGroup "Direction of Filaments"
					oLayout.AddItem "LFself",			"Self  <--->  Self"
					oLayout.AddItem "LFcaster",			"Self    --->  Neighbors"
					oLayout.AddItem "LFreceiver",		"Self  <---    Neighbors"
				oLayout.EndGroup
			oLayout.Endrow
			set oItem = oLayout.AddItem("LFdistance",	"Filament Lengths (relative to their Radius and Falloff)")
			oItem.SetAttribute siUILabelPercentage,	60
			oLayout.AddGroup " "
				oLayout.AddItem "LFoptimizedplotting",	"Optimized Plotting"
				set oItem = oLayout.AddItem("LFdetail",		"Level of Detail")
				oItem.SetAttribute siUILabelPercentage, 60
				oLayout.AddItem "LFiso",			"Iso Multiplier"
				oLayout.AddItem "LFthickness",		"Thickness"
				oLayout.AddItem "LFmeetingpoint",	"Meeting at"
			oLayout.EndGroup
			oLayout.AddGroup "Neighboring"
				Dim lvNM(3)
				lvNM( 0) = "by Number of Neighbors"
				lvNM( 1) = 0
				lvNM( 2) = "by Weight of Neighbors"
				lvNM( 3) = 1
				set oItem = oLayout.AddEnumControl("LFneighMode",lvNM,"Filter",siControlCombo)
				if ppgLFneighMode = 0 then
					set oItem = oLayout.AddItem("LFneighMaxNum",		"Max Number")
					oItem.SetAttribute siUILabelPercentage, 50
					set oItem = oLayout.AddItem("LFneighMaxNumFade",	"Fade")
					oItem.SetAttribute siUILabelPercentage, 50
				elseif ppgLFneighMode = 1 then
					set oItem = oLayout.AddItem("LFneighMaxWeight",		"Max Weight")
					oItem.SetAttribute siUILabelPercentage, 50
					set oItem = oLayout.AddItem("LFneighMaxWeightFade",	"Fade")
					oItem.SetAttribute siUILabelPercentage, 50
				else
					oLayout.AddStaticText "Not implemented."
				end if
			oLayout.EndGroup
		oLayout.EndGroup
		if ppgShowAllLiquid then
			oLayout.AddGroup "Profiles"
				oLayout.AddSpacer 0, 10
				oLayout.AddGroup "Overall Fade"
					oLayout.AddRow			
						oLayout.AddSpacer 0,0
						oLayout.AddGroup "FCurve Window"
							oLayout.AddRow			
								oLayout.AddButton "BtnFCurveDisplaySmall",					"Small"
								oLayout.AddButton "BtnFCurveDisplayLarge_overallfade",		"Large"
							oLayout.EndRow
						oLayout.EndGroup
					oLayout.EndRow
					oLayout.AddFCurve "LFprofile_overallfade", LFprofile_height_overallfade
				oLayout.EndGroup
				oLayout.AddSpacer 0, 10
				oLayout.AddGroup "Size Ratio"
					oLayout.AddRow			
						oLayout.AddSpacer 0,0
						oLayout.AddGroup "FCurve Window"
							oLayout.AddRow			
								oLayout.AddButton "BtnFCurveDisplaySmall",					"Small"
								oLayout.AddButton "BtnFCurveDisplayLarge_overallprofile",	"Large"
							oLayout.EndRow
						oLayout.EndGroup
					oLayout.EndRow
					oLayout.AddFCurve "LFprofile_overallprofile", LFprofile_height_overallprofile
				oLayout.EndGroup
			oLayout.EndGroup
		end if
	' tab "FCurves"
	oLayout.AddTab "FCurves"
		oLayout.AddSpacer 0, 10
		oLayout.AddGroup "Isofactor"
			oLayout.AddRow			
				set oItem = oLayout.AddItem( "isofactor_mulByFCurve",		"Multiply by FCurve" )
				oItem.WidthPercentage = 75
				oLayout.AddGroup "FCurve Window"
					oLayout.AddRow			
						oLayout.AddButton "BtnFCurveDisplaySmall",			"Small"
						oLayout.AddButton "BtnFCurveDisplayLarge_iso", 		"Large"
					oLayout.EndRow
				oLayout.EndGroup
			oLayout.EndRow
			oLayout.AddFCurve "curve_isofactor", FCurve_height_iso
		oLayout.EndGroup
		oLayout.AddSpacer 0, 10
		oLayout.AddGroup "Radius"
			oLayout.AddRow			
				set oItem = oLayout.AddItem( "radius_mulByFCurve",			"Multiply by FCurve" )
				oItem.WidthPercentage = 75
				oLayout.AddGroup "FCurve Window"
					oLayout.AddRow			
						oLayout.AddButton "BtnFCurveDisplaySmall",			"Small"
						oLayout.AddButton "BtnFCurveDisplayLarge_rad", 		"Large"
					oLayout.EndRow
				oLayout.EndGroup
			oLayout.EndRow
			oLayout.AddFCurve "curve_radius", FCurve_height_rad
		oLayout.EndGroup
		oLayout.AddSpacer 0, 10
		oLayout.AddGroup "Falloff"
			oLayout.AddRow			
				set oItem = oLayout.AddItem( "falloff_mulByFCurve",			"Multiply by FCurve" )
				oItem.WidthPercentage = 75
				oLayout.AddGroup "FCurve Window"
					oLayout.AddRow			
						oLayout.AddButton "BtnFCurveDisplaySmall",			"Small"
						oLayout.AddButton "BtnFCurveDisplayLarge_foff",		"Large"
					oLayout.EndRow
				oLayout.EndGroup
			oLayout.EndRow
			oLayout.AddFCurve "curve_falloff", FCurve_height_foff
		oLayout.EndGroup
		oLayout.AddStaticText "Note:" & chr(10) & "FCurves are only used with 'Use Knots' or 'Use Curve'."
end function

function emPolygonizer4_Curve_DefineLayout( in_ctxt )
	dim oLayout
	set oLayout = in_ctxt.Source
	myOwnDefineLayout oLayout, 150, 150, 150, 150, 150, 150
	emPolygonizer4_Curve_DefineLayout = true
end function

function emPolygonizer4_Curve_OnInit( )
	myownDefineLayout PPG.PPGLayout, 150, 150, 150, 150, 150, 150 
	PPG.Refresh
end function

function emPolygonizer4_Curve_OnClosed( )
end function

function emPolygonizer4_Curve_BtnShowLiquid_OnClicked( )
	Dim a
	a = PPG.ppg_showall_liquid.Value 
	if a then a=false else a=true
	PPG.ppg_showall_liquid.Value = a
	myownDefineLayout PPG.PPGLayout, 150, 150, 150, 150, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplaySmall_OnClicked( )
	myOwnDefineLayout PPG.PPGLayout, 150, 150, 150, 150, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplayLarge_iso_OnClicked( )
	myOwnDefineLayout PPG.PPGLayout, 400, 150, 150, 150, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplayLarge_rad_OnClicked( )
	myOwnDefineLayout PPG.PPGLayout, 150, 400, 150, 150, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplayLarge_foff_OnClicked( )
	myOwnDefineLayout PPG.PPGLayout, 150, 150, 400, 150, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplaySmall_OnClicked( )
	myownDefineLayout PPG.PPGLayout, 150, 150, 150, 150, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplayLarge_overallfade_OnClicked( )
	myownDefineLayout PPG.PPGLayout, 150, 150, 150, 400, 150, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_BtnFCurveDisplayLarge_overallprofile_OnClicked( )
	myownDefineLayout PPG.PPGLayout, 150, 150, 150, 150, 400, 150
	PPG.Refresh
end function

function emPolygonizer4_Curve_LFneighMode_OnChanged( )
	myownDefineLayout PPG.PPGLayout, 150, 150, 150, 150, 150, 150
	PPG.Refresh
end function
