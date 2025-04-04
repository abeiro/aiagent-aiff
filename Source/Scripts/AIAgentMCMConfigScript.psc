Scriptname AIAgentMCMConfigScript extends SKI_ConfigBase  


AIAgentPapyrusFunctions Property controlScript Auto

int			_keymapOID_K
int			_myKey					= -1

int			_keymapOID_K2
int			_myKey2					= -1

int			_keymapOID_K3
int			_myKey3					= -1

int			_keymapOID_K4
int			_myKey4					= -1

int			_toggle1OID_B
bool		_toggleState1			= true

int			_toggle1OID_C
bool		_toggleState2			= false

int			_toggle1OID_D
bool		_toggleState3			= false

int			_keymapOID_K5
int			_myKey5				= -1

int			_keymapOID_K6
int			_myKey6				= -1

int			_keymapOID_K7
int			_myKey7				= -1


int			_slider_volume
float		_sound_volume				= 50.0

int			_slider_preclip
float		_sound_preclip				= 100.0

int			_slider_postclip
float		_sound_postclip				= 100.0

int			_slider_ds
float		_sound_ds				= 1.0


int			_toggle1OID_E
bool		_toggleState7			= true


int			_slider_lip_res
float		_lip_res				= 500.0

int			_slider_lip_int
float		_lip_int				= 1.0


int 		_slider_timeout
float		_timeout_int				= 30.0


int			_toggleAnimation
bool		_animationstate			= false


int			_toggle1OID_Rereg


int			_toggleInvertHeading
bool		_invertheadingstate			= false

int			_togglePauseDialogue
bool		_pauseDialogueState			= false


; Auto Activate related
int			_toggleResetNPC
int			_toggleAddAllNowNPC

int			_toggleAddAllNPC 
bool		_toggleAddAllNPCState			= false

int			_slider_max_distance_inside
float		_max_distance_inside		= 1200.0

int			_slider_max_distance_outside
float		_max_distance_outside		= 2400.0

int			_slider_bored_period
float		_bored_period		= 60.0

int 		_toggleRechat_policy_asap
bool  		_rechat_policy_asap = true

int 		_toggle_npc_go_near
bool  		_toggle_npc_go_near_state = true


int 		_toggle_autofocus_on_sit
bool  		_toggle_autofocus_on_sit_state = false

int 		_toggle_usewebsocketstt
bool  		_toggle_usewebsocketstt_state = false


int 		_toggle_restrict_onscene
bool  		_toggle_restrict_onscene_state = false


int 		_toggle_autoadd_hostile
bool  		_toggle_autoadd_hostile_state = false


int 		_toggle_autoadd_allraces
bool  		_toggle_autoadd_allraces_state = false


int			_keymap_godmode
int			_godmode_key					= -1


; default settings
int			_myKeyDefault					= -1
int			_myKey2Default					= -1
int			_myKey3Default					= -1
int			_myKey4Default					= -1
int			_myKey5Default					= -1
int			_myKey6Default					= -1
int			_myKey7Default					= -1
bool		_toggleState2Default			= false
float		_sound_volumeDefault			= 75.0
float		_sound_preclipDefault			= 100.0
float		_sound_postclipDefault			= 0.0
float		_sound_dsDefault				= 1.0
bool		_toggleState7Default			= true
float		_lip_resDefault					= 500.0
float		_lip_intDefault					= 1.0
float		_timeout_intDefault				= 30.0
bool		_animationstateDefault			= false
bool		_invertheadingstateDefault		= false
bool		_pauseDialogueStateDefault		= false


event OnConfigInit()
	ModName="CHIM"
	Pages = new string[3]
	Pages[0] = "Main"
	Pages[1] = "Behavior"
	Pages[2] = "Sound"
	

	Debug.Trace("CHIM: OnConfigInit")
	Debug.Notification("[CHIM] Updating menu ... v3.7");
	
	_sound_postclip				= 0.0
	_sound_preclip				= 100.0
	_sound_volume				= 75 
	_lip_res				= 500.0
	_lip_int				= 1.0
	if (CurrentVersion>1)
		_sound_ds					= 1.0
	endIf
	if (CurrentVersion<25)
		_toggleState7= true
		_toggle1OID_E = 1
	endIf
	if (CurrentVersion<28)
		_animationstate= false
		_toggleAnimation = 1
	endIf
	if (CurrentVersion<26)
		;controlScript.setSoulgazeModeNative(1)
	endIf
	if (CurrentVersion<29)
		SetTitleText("CHIM")
	endIf
	
	if (CurrentVersion<35)
		controlScript.setConf("_rechat_policy_asap",1)
		_rechat_policy_asap=true
	endIf
	
	if (CurrentVersion<37)
		_bored_period=60
		StorageUtil.SetIntValue(None, "AIAgentNpcWalkNear",1);
		_toggle_npc_go_near_state=true
	endIf
	
	if (CurrentVersion<38)
		_toggle_autofocus_on_sit=0
		StorageUtil.SetIntValue(None, "AIAgentAutoFocusOnSit",0);
		_toggle_autofocus_on_sit_state=false
	endIf
	
	if (CurrentVersion<39)
		_toggle_usewebsocketstt=0 
		StorageUtil.SetIntValue(None, "AIAgentWebSockeSTT",0);
		_toggle_usewebsocketstt_state=false
		

		controlScript.setConf("_restrict_onscene",0)
		_toggle_restrict_onscene=0 
		_toggle_restrict_onscene_state=false;
	endIf
	
	if (CurrentVersion<41)
		controlScript._currentGodmodeStatus=false
		controlScript.setConf("_godmode",0)
		controlScript.setConf("_autoadd_hostile",0)
		controlScript.setConf("_autoadd_allraces",0)
	endIf

	
	ConsoleUtil.ExecuteCommand("setstage SKI_ConfigManagerInstance 1")
endEvent

int function GetVersion()

	return 41

endFunction

event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version

	if (a_version >= 2 && CurrentVersion < 38)
		OnConfigInit()
		
		; Clear any AutoActivate related settings from existing saves
		if (CurrentVersion < 37)
			controlScript.setConf("_max_distance_inside", 0.0)
			controlScript.setConf("_max_distance_outside", 0.0)
			controlScript.setConf("_bored_period", 60)
			controlScript.setConf("_toggleAddAllNPC", 0)
		endif
	endIf
endEvent


int function getActionMode() 

	if (_toggleState2)
		controlScript.setNewActionMode(1)
	else
		controlScript.setNewActionMode(0)
		
	endif
	return 0
EndFunction

event OnPageReset(string a_page)

	SetCursorFillMode(LEFT_TO_Right)
	
	
	if (a_page=="Main" || a_page=="")
		_keymapOID_K7		= AddKeyMapOption("Activate AI", _myKey7)
		_keymapOID_K = AddKeyMapOption("Text Chat with AI", _myKey)	
		_keymapOID_K2 = AddKeyMapOption("Voice Chat with AI/Summarize Book", _myKey2)	
		;_toggle1OID_B		= AddToggleOption("Enable AI Voice (TTS)", _toggleState1)
		_toggle1OID_C		= AddToggleOption("Enable AI Actions", _toggleState2)
		_keymapOID_K3		= AddKeyMapOption("Follow and Unfollow NPC/Summarize book", _myKey3)
		;_toggle1OID_D		= AddToggleOption("Use Custom Voicetype or standard", _toggleState3)
		_keymapOID_K4		= AddKeyMapOption("Have AI NPC Write Diary Entry", _myKey4)
		_keymapOID_K5		= AddKeyMapOption("Change AI/LLM Model", _myKey5)
		_keymapOID_K6		= AddKeyMapOption("Soulgaze", _myKey6)
		
		_slider_timeout	= AddSliderOption("AIAgent connection timeout ",_timeout_int,"{1}" )
		_toggleAnimation		= AddToggleOption("Enable animations", _animationstate)
		
		_toggle1OID_E		= AddToggleOption("Soulgaze HD", _toggleState7)
		_keymap_godmode		= AddKeyMapOption("AI God Mode", _godmode_key)
		;_toggle1OID_Rereg		= AddToggleOption("Register mod name again", false)
	endif
	

	if (a_page=="Behavior")
		_toggleAddAllNPC		= AddToggleOption("Auto Activate ON/OFF", _toggleAddAllNPCState)
		AddEmptyOption();
		_toggleResetNPC		= AddToggleOption("Remove all NPCs", false)
		_toggleAddAllNowNPC	= AddToggleOption("Add all current NPCs", false)
		
		_slider_bored_period	= AddSliderOption("Bored event period",_bored_period,"{0}" )
		_toggleRechat_policy_asap	= AddToggleOption("Rechat policy asap", _rechat_policy_asap)
		
		
		_slider_max_distance_inside	= AddSliderOption("Distance (interiors) to AI controlled speech",_max_distance_inside,"{0}" )
		_slider_max_distance_outside	= AddSliderOption("Distance (exteriors) to AI controlled speech",_max_distance_outside,"{0}" )
		
		_toggle_npc_go_near	= AddToggleOption("NPCs walk near player", _toggle_npc_go_near_state)
		_toggle_autofocus_on_sit	= AddToggleOption("Autofocus on sitting", _toggle_autofocus_on_sit_state)
		
		_toggle_restrict_onscene	= AddToggleOption("Restrict Actors On Scene", _toggle_restrict_onscene_state)
		AddEmptyOption();
		AddHeaderOption("Auto Activate Options")	
		AddEmptyOption();
		_toggle_autoadd_hostile	= AddToggleOption("Add Hostile NPCs", _toggle_autoadd_hostile_state)
		AddEmptyOption(); 
		_toggle_autoadd_allraces	= AddToggleOption("Add All races", _toggle_autoadd_allraces_state)
		
	endif
	

	if (a_page=="Sound")
		_slider_volume		= AddSliderOption("AI Voice Volume", _sound_volume,"{0}")
		_slider_ds			= AddSliderOption("AI Voice Distance Scale ",_sound_ds,"{1}" )
		
		_slider_preclip		= AddSliderOption("Skip milliseconds at begin",_sound_preclip,"{0}" )
		_slider_postclip	= AddSliderOption("Skip milliseconds at end",_sound_postclip,"{0}" )
		
		_toggleInvertHeading	= AddToggleOption("3D sound invert heading",_invertheadingstate)
		AddEmptyOption();
		
		_slider_lip_res	= AddSliderOption("Resolution of lip anim.",_lip_res,"{0}" )
		_slider_lip_int			= AddSliderOption("Intensity of lip anim ",_lip_int,"{1}" )
		
		;AddEmptyOption();
		_togglePauseDialogue	= AddToggleOption("Pause dialogue during game pauses",_pauseDialogueState)
		_toggle_usewebsocketstt			= AddToggleOption("Use WebSocket STT",_toggle_usewebsocketstt_state)

	
	endif

endEvent

event OnOptionSliderOpen(int a_option)
	{Called when the user selects a slider option}

	if (a_option == _slider_volume)
		SetSliderDialogStartValue(_sound_volume)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(2)
	endIf
	
	if (a_option == _slider_preclip)
		SetSliderDialogStartValue(_sound_preclip)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(10)
	endIf
	
	if (a_option == _slider_postclip)
		SetSliderDialogStartValue(_sound_postclip)
		SetSliderDialogDefaultValue(1000)
		SetSliderDialogRange(0, 2000)
		SetSliderDialogInterval(2)
	endIf
	if (a_option == _slider_ds)
		SetSliderDialogStartValue(_sound_ds)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, 1000)
		SetSliderDialogInterval(0.1)
	endIf
	if (a_option == _slider_lip_int)
		SetSliderDialogStartValue(_lip_int)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 2)
		SetSliderDialogInterval(0.1)
	endIf
	if (a_option == _slider_lip_res)
		SetSliderDialogStartValue(_lip_res)
		SetSliderDialogDefaultValue(500)
		SetSliderDialogRange(0, 1000)
		SetSliderDialogInterval(10)
	endIf
	
	if (a_option == _slider_timeout)
		SetSliderDialogStartValue(_timeout_int)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(15, 300)
		SetSliderDialogInterval(1)
	endIf
	
	if (a_option == _slider_max_distance_inside)
		SetSliderDialogStartValue(_max_distance_inside)
		SetSliderDialogDefaultValue(1200)
		SetSliderDialogRange(10, 5000)
		SetSliderDialogInterval(1)
	endIf
	
	if (a_option == _slider_max_distance_outside)
		SetSliderDialogStartValue(_max_distance_outside)
		SetSliderDialogDefaultValue(2400)
		SetSliderDialogRange(10, 5000)
		SetSliderDialogInterval(1)
	endIf
	
	if (a_option == _slider_bored_period)
		SetSliderDialogStartValue(_bored_period)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(15, 600)
		SetSliderDialogInterval(1)
	endIf
	
endEvent

event OnOptionSliderAccept(int a_option, float a_value)
	if (a_option == _slider_volume)
		_sound_volume = a_value
		controlScript.setConf("_sound_volume",a_value)
		SetSliderOptionValue(a_option, a_value, "{0}")
	endIf
		if (a_option == _slider_preclip)
		_sound_preclip = a_value
		controlScript.setConf("_sound_preclip",a_value)
		SetSliderOptionValue(a_option, a_value, "{0}")

	endIf
	if (a_option == _slider_postclip)
		_sound_postclip = a_value
		controlScript.setConf("_sound_postclip",a_value)
		SetSliderOptionValue(a_option, a_value, "{0}")
	endIf
	if (a_option == _slider_ds)
		_sound_ds = a_value
		controlScript.setConf("_sound_ds",a_value)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	if (a_option == _slider_lip_int)
		_lip_int = a_value
		controlScript.setConf("_lip_int",_lip_int)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	if (a_option == _slider_lip_res)
		_lip_res = a_value
		controlScript.setConf("_lip_res",_lip_res)
		SetSliderOptionValue(a_option, a_value, "{0}")
	endIf
	
	if (a_option == _slider_timeout)
		_timeout_int = a_value
		controlScript.setConf("_timeout",_timeout_int)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_max_distance_inside)
		_max_distance_inside = a_value
		controlScript.setConf("_max_distance_inside",_max_distance_inside)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_max_distance_outside)
		_max_distance_outside = a_value
		controlScript.setConf("_max_distance_outside",_max_distance_outside)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_bored_period)
		_bored_period = a_value
		controlScript.setConf("_bored_period",_bored_period)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	
endEvent
	
	
event OnGameReload()
	parent.OnGameReload()
	if (_toggleState1)
		;controlScript.setTTSOn();
		getActionMode();
	endIf
	if (_toggleState3)
		controlScript.setVoiceType(1);	
	else
		controlScript.setVoiceType(0);
	endif

	controlScript.setConf("_sound_postclip",_sound_postclip)
	controlScript.setConf("_sound_preclip",_sound_preclip)
	controlScript.setConf("_sound_volume",_sound_volume)
	controlScript.setConf("_sound_ds",_sound_ds)
	controlScript.setConf("_lip_int",_lip_int)
	controlScript.setConf("_lip_res",_lip_res)
	controlScript.setConf("_timeout",_timeout_int)


	controlScript.setConf("_max_distance_inside",_max_distance_inside)
	controlScript.setConf("_max_distance_outside",_max_distance_outside)
	
	controlScript.setConf("_bored_period",_bored_period)
	
	if (_toggleAddAllNPCState)
		controlScript.setConf("_toggleAddAllNPC",1)
	else
		controlScript.setConf("_toggleAddAllNPC",0)
	endif

	if (_rechat_policy_asap)
		controlScript.setConf("_rechat_policy_asap",1)
	else
		controlScript.setConf("_rechat_policy_asap",0)
	endif

	
	if (_animationstate)
		controlScript.setConf("_animations",1)
	else
		controlScript.setConf("_animations",0)
	endif
	
	if (_pauseDialogueState)
		controlScript.setConf("_pause_dialogue_when_menu_open",1)
	else
		controlScript.setConf("_pause_dialogue_when_menu_open",0)
	endif
	
	if (_toggle_autoadd_hostile_state)
		controlScript.setConf("_autoadd_hostile",1)
	else
		controlScript.setConf("_autoadd_hostile",0)
	endif
	
	if (_toggle_autoadd_allraces_state)
		controlScript.setConf("_autoadd_allraces",1)
	else
		controlScript.setConf("_autoadd_allraces",0)
	endif
	
	controlScript.setSoulgazeModeNative(_toggleState7 as Int)
	
	controlScript.setConf("_godmode",0)
	controlScript._currentGodmodeStatus=false
	
endEvent

event OnOptionDefault(int a_option)
	if (a_option == _keymapOID_K)
		controlScript.removeBinding(_myKey)
		_myKey = _myKeyDefault
		SetKeymapOptionValue(a_option, _myKey)
		controlScript.doBinding(_myKey)

	elseif (a_option == _keymapOID_K2)
		controlScript.removeBinding(_myKey2)
		_myKey2 = _myKey2Default
		SetKeymapOptionValue(a_option, _myKey2)
		controlScript.doBinding2(_myKey2)

	elseif (a_option == _keymapOID_K3)
		controlScript.removeBinding(_myKey3)
		_myKey3 = _myKey3Default
		SetKeymapOptionValue(a_option, _myKey3)
		controlScript.doBinding3(_myKey3)

	elseif (a_option == _keymapOID_K4)
		controlScript.removeBinding(_myKey4)
		_myKey4 = _myKey4Default
		SetKeymapOptionValue(a_option, _myKey4)
		controlScript.doBinding4(_myKey4)

	elseif (a_option == _keymapOID_K5)
		controlScript.removeBinding(_myKey5)
		_myKey5 = _myKey5Default
		SetKeymapOptionValue(a_option, _myKey5)
		controlScript.doBinding5(_myKey5)

	elseif (a_option == _keymapOID_K6)
		controlScript.removeBinding(_myKey6)
		_myKey6 = _myKey6Default
		SetKeymapOptionValue(a_option, _myKey6)
		controlScript.doBinding6(_myKey6)

	elseif (a_option == _keymapOID_K7)
		controlScript.removeBinding(_myKey7)
		_myKey7 = _myKey7Default
		SetKeymapOptionValue(a_option, _myKey7)
		controlScript.doBinding7(_myKey7)

	elseif (a_option == _toggle1OID_C)
		_toggleState2 = _toggleState2Default
		SetToggleOptionValue(a_option, _toggleState2)

	elseif (a_option == _slider_timeout)
		_timeout_int = _timeout_intDefault
		SetSliderOptionValue(a_option, _timeout_int, "{1}")

	elseif (a_option == _toggleAnimation)
		_animationstate = _animationstateDefault
		SetToggleOptionValue(a_option, _animationstate)

	elseif (a_option == _toggle1OID_E)
		_toggleState7 = _toggleState7Default
		SetToggleOptionValue(a_option, _toggleState7)

	elseif (a_option == _slider_volume)
		_sound_volume = _sound_volumeDefault
		SetSliderOptionValue(a_option, _sound_volume, "{1}")

	elseif (a_option == _slider_ds)
		_sound_ds = _sound_dsDefault
		SetSliderOptionValue(a_option, _sound_ds, "{1}")

	elseif (a_option == _slider_preclip)
		_sound_preclip = _sound_preclipDefault
		SetSliderOptionValue(a_option, _sound_preclip, "{1}")

	elseif (a_option == _slider_postclip)
		_sound_postclip = _sound_postclipDefault
		SetSliderOptionValue(a_option, _sound_postclip, "{1}")

	elseif (a_option == _slider_lip_res)
		_lip_res = _lip_resDefault
		SetSliderOptionValue(a_option, _lip_res, "{1}")

	elseif (a_option == _slider_lip_int)
		_lip_int = _lip_intDefault
		SetSliderOptionValue(a_option, _lip_int, "{1}")

	elseif (a_option == _toggleInvertHeading)
		_invertheadingstate = _invertheadingstateDefault
		SetToggleOptionValue(a_option, _invertheadingstate)

	elseif (a_option == _togglePauseDialogue)
		_pauseDialogueState = _pauseDialogueStateDefault
		SetToggleOptionValue(a_option, _pauseDialogueState)
	endIf
	
endEvent

event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped}

	bool continue = true
	if (a_conflictControl != "" && a_keyCode != 1)
		string msg
		if (a_conflictName != "")
			msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
		else
			msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
		endIf

		continue = ShowMessage(msg, true, "$Yes", "$No")
	endIf

	; clear if escape key
	if (a_keyCode == 1)
		a_keyCode = -1
	endIf

	if (continue)
		if (a_option == _keymapOID_K)
			controlScript.removeBinding(_myKey)
			_myKey = a_keyCode
			controlScript.doBinding(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif

		elseif (a_option == _keymapOID_K2)
			controlScript.removeBinding(_myKey2)
			_myKey2 = a_keyCode
			controlScript.doBinding2(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif

		elseif (a_option == _keymapOID_K3)
			controlScript.removeBinding(_myKey3)
			_myKey3 = a_keyCode
			controlScript.doBinding3(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif

		elseif (a_option == _keymapOID_K4)
			controlScript.removeBinding(_myKey4)
			_myKey4 = a_keyCode
			controlScript.doBinding4(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif

		elseif (a_option == _keymapOID_K5)
			controlScript.removeBinding(_myKey5)
			_myKey5 = a_keyCode
			controlScript.doBinding5(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif

		elseif (a_option == _keymapOID_K6)
			controlScript.removeBinding(_myKey6)
			_myKey6 = a_keyCode
			controlScript.doBinding6(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif

		elseif (a_option == _keymapOID_K7)
			controlScript.removeBinding(_myKey7)
			_myKey7 = a_keyCode
			controlScript.doBinding7(a_keyCode)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_godmode)
			controlScript.removeBinding(_godmode_key)
			_godmode_key = a_keyCode
			controlScript.doBinding8(_godmode_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif	
		endIf
		
	endIf
endEvent

event OnOptionSelect(int a_option)
	{Called when the user selects a non-dialog option}
	
	if (a_option == _toggle1OID_B)
		_toggleState1 = !_toggleState1
		if (_toggleState1)
			;controlScript.setTTSOn();
		else
			;controlScript.setTTSOff();		
		endIf
		SetToggleOptionValue(a_option, _toggleState1)
	endIf
	if (a_option == _toggle1OID_C)
		_toggleState2 = !_toggleState2
		if (_toggleState2)
			controlScript.setNewActionMode(1);	
		else
			controlScript.setNewActionMode(0);
		endif		
		SetToggleOptionValue(a_option, _toggleState2)
	endIf
	if (a_option == _toggle1OID_D)
		_toggleState3 = !_toggleState3
		if (_toggleState3)
			controlScript.setVoiceType(1);	
		else
			controlScript.setVoiceType(0);
		endif		
		SetToggleOptionValue(a_option, _toggleState3)
	endIf
	if (a_option == _toggle1OID_E)
		_toggleState7 = !_toggleState7
		if (_toggleState7)
			controlScript.setSoulgazeModeNative(1)
		else
			controlScript.setSoulgazeModeNative(0)
		endif		
		SetToggleOptionValue(a_option, _toggleState7)
	endIf
	if (a_option == _toggleAnimation)
		_animationstate = !_animationstate
		
		if (_animationstate)
			bool r=controlScript.setConf("_animations",1)
		else
			bool r=controlScript.setConf("_animations",0)
		endif
		
		SetToggleOptionValue(a_option, _animationstate)
	endIf
	if (a_option == _toggle1OID_Rereg)
		ConsoleUtil.ExecuteCommand("SetStage SKI_ConfigManagerInstance 1")
		ShowMessage("Close menu")
	endIf
	
	if (a_option == _toggleInvertHeading)
		_invertheadingstate = !_invertheadingstate
		
		if (_invertheadingstate)
			controlScript.setConf("_invertheadingstate",1)
		else
			controlScript.setConf("_invertheadingstate",0)
		endif
		
		SetToggleOptionValue(a_option, _invertheadingstate)
	endIf

	if (a_option == _togglePauseDialogue)
		_pauseDialogueState = !_pauseDialogueState
		
		if (_pauseDialogueState)
			controlScript.setConf("_pause_dialogue_when_menu_open",1)
		else
			controlScript.setConf("_pause_dialogue_when_menu_open",0)
		endif
		
		SetToggleOptionValue(a_option, _pauseDialogueState)
	endIf
	
	if (a_option == _toggleRechat_policy_asap)
		_rechat_policy_asap = !_rechat_policy_asap
		if (_rechat_policy_asap)
			controlScript.setConf("_rechat_policy_asap",1)
		else
			controlScript.setConf("_rechat_policy_asap",0)
		endif
		SetToggleOptionValue(a_option, _rechat_policy_asap)

	endif
	
	
	if (a_option == _toggle_npc_go_near)
		_toggle_npc_go_near_state = !_toggle_npc_go_near_state
		if (_toggle_npc_go_near_state)
			StorageUtil.SetIntValue(None, "AIAgentNpcWalkNear",1);
		else
			StorageUtil.SetIntValue(None, "AIAgentNpcWalkNear",0);
		endif
		SetToggleOptionValue(a_option, _toggle_npc_go_near_state)

	endif
	
	if (a_option == _toggle_autofocus_on_sit)
		_toggle_autofocus_on_sit_state = !_toggle_autofocus_on_sit_state
		if (_toggle_autofocus_on_sit_state)
			StorageUtil.SetIntValue(None, "AIAgentAutoFocusOnSit",1);
		else
			StorageUtil.SetIntValue(None, "AIAgentAutoFocusOnSit",0);
		endif
		SetToggleOptionValue(a_option, _toggle_autofocus_on_sit_state)

	endif
	
	if (a_option == _toggleAddAllNPC)
 		_toggleAddAllNPCState = !_toggleAddAllNPCState
 
 		if (_toggleAddAllNPCState)
 			controlScript.setConf("_toggleAddAllNPC",1)
 		else
 			controlScript.setConf("_toggleAddAllNPC",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggleAddAllNPCState)
 	endIf
	
	if (a_option == _toggleResetNPC)
 		AIAgentFunctions.testRemoveAll()
 		ShowMessage("Done")
 	endIf
 
 	if (a_option == _toggleAddAllNowNPC)
 		AIAgentFunctions.testAddAllNPCAround()
 		ShowMessage("Done")
 	endIf
	
	
	if (a_option == _toggle_restrict_onscene)
 		_toggle_restrict_onscene_state = !_toggle_restrict_onscene_state
 
 		if (_toggle_restrict_onscene_state)
 			controlScript.setConf("_restrict_onscene",1)
 		else
 			controlScript.setConf("_restrict_onscene",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_restrict_onscene_state)
 	endIf
	
	if (a_option == _toggle_usewebsocketstt)
 		_toggle_usewebsocketstt_state = !_toggle_usewebsocketstt_state
 
 		if (_toggle_usewebsocketstt_state)
			StorageUtil.SetIntValue(None, "AIAgentWebSockeSTT",1);
 		else
 			StorageUtil.SetIntValue(None, "AIAgentWebSockeSTT",0);
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_usewebsocketstt_state)
 	endIf
	
	if (a_option == _toggle_autoadd_hostile)
 		_toggle_autoadd_hostile_state = !_toggle_autoadd_hostile_state
 
 		if (_toggle_autoadd_hostile_state)
 			controlScript.setConf("_autoadd_hostile",1)
 		else
 			controlScript.setConf("_autoadd_hostile",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_autoadd_hostile_state)
 	endIf
	
	if (a_option == _toggle_autoadd_allraces)
 		_toggle_autoadd_allraces_state = !_toggle_autoadd_allraces_state
 
 		if (_toggle_autoadd_allraces_state)
 			controlScript.setConf("_autoadd_allraces",1)
 		else
 			controlScript.setConf("_autoadd_allraces",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_autoadd_allraces_state)
 	endIf
	
endEvent

event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}
	
	if (a_option == _keymapOID_K)
		SetInfoText("Open chatbox to type to an AI NPC.")
	endIf
	if (a_option == _toggle1OID_B)
		SetInfoText("Enables Text-to-Speech for AI NPC's.")
	endIf
	if (a_option == _keymapOID_K2)
		SetInfoText("Push-to-talk key to speak with an AI NPC. Make sure your microphone is setup as your default recording device in windows. Also allows an AI NPC to summarize books you have open.")
	endIf
	if (a_option == _toggle1OID_C)
		SetInfoText("Enable AI actions (exchange items, attack monster, take me to X location, etc).")
	endIf
	if (a_option == _toggle1OID_D)
		SetInfoText("If using mods like RDO, check this to force default voice, so dialog Follow me should appear. Note that checking this will disable custom voiced sounds. As of version 0.9.x, this shouldn't be needed.")
	endIf
	if (a_option == _keymapOID_K3)
		SetInfoText("If reading a book, will ask an AI NPC to summarize it. If not, toggle auto follow.")
	endIf
	if (a_option == _keymapOID_K4)
		SetInfoText("Use this to force an AI NPC to summarize the currenet events into their diary. NEEDS ACTIONS ENABLED!")
	endIf
	if (a_option == _keymapOID_K5)
		SetInfoText("Change AI/LLM. Models should be selected in the CHIM server configuration wizard.")
	endIf
	if (a_option == _keymapOID_K6)
		SetInfoText("Take a screeshot and sends to an ITT AI service to summarize what is shown.")
	endIf
	if (a_option == _keymapOID_K7)
		SetInfoText("Imports the NPC you are looking at into CHIM. Can use it to turn their AI on and off.")
	endIf
	if (a_option == _slider_volume)
		SetInfoText("Sets AI NPC speech volume.")
	endIf
	if (a_option == _slider_preclip)
		SetInfoText("Skips specified millisecods at begin of sentence. Some TTS services add some silence at the begining of audio clips.")
	endIf
	if (a_option == _slider_postclip)
		SetInfoText("Skips specified millisecods at end of sentence. Some TTS services add some silence at the end of audio clips.")
	endIf
	if (a_option == _slider_ds)
		SetInfoText("Adjust AI NPC volume at distance.")
	endIf
	if (a_option == _toggle1OID_E)
		SetInfoText("Enable to use SoulGaze HD. Will directly access to the DirectX backbuffer, so compression will be made by server. Disable to use SoulGaze via in-game screenshot (VR users should disable this).")
	endIf
	
	if (a_option == _slider_lip_int)
		SetInfoText("Lip modifier intensity. Set lower if mouth opens too much ")
	endIf
	
	if (a_option == _slider_lip_res)
		SetInfoText("Lip modifier resolution. Set lower if movement is too laggy. Lower uses more CPU. Find your sweet spot.")
	endIf
	
	if (a_option == _slider_timeout)
		SetInfoText("Timeout in seconds when requesting data to server. Keep this a 30 for best experience.")
	endIf
	
	if (a_option == _toggleAnimation)
		SetInfoText("Enable animations. If using openanimation replacer or custom animations you should disable it to prevent CTDs")
	endIf
	
	if (a_option == _toggle1OID_Rereg)
		SetInfoText("Mod name has changed. This will reset MCM to show new name. May affect other mods. Will call setstage SKI_ConfigManagerInstance 1")
	endIf
	
	if (a_option == _toggleInvertHeading)
		SetInfoText("When using 3D sound, try inverting the heading. This may resolve issues where NPCs in front are heard at a lower volume. (Need people to help solve this)")
	endIf

	if (a_option == _togglePauseDialogue)
		SetInfoText("Enable to pause dialogue during game pauses. Disable to allow dialogue to continue during game pauses.")
	endIf

	
	if (a_option == _toggleAddAllNowNPC)
		SetInfoText("Will add (almost) all NPCs around to framework. Will be executed once right now.")
	endIf
	
	if (a_option == _slider_max_distance_inside)
		SetInfoText("AIs below this distance in interiors can start talking")
	endIf
	
	if (a_option == _slider_max_distance_outside)
		SetInfoText("AIs below this distance in exteriors can start talking")
	endIf
	
	if (a_option == _toggleAddAllNPC)
		SetInfoText("Will add automagically (almost) all NPCs around to framework. ")
	endIf
	
	if (a_option == _toggleResetNPC)
 		SetInfoText("Removes all NPCs from framework. Confs and Bios are kept untouched")
 	endIf
	
	if (a_option == _slider_bored_period)
		SetInfoText("A bored event (random NPC will start to talk) every x seconds.")
	endIf
	
	if (a_option == _toggleRechat_policy_asap)
		SetInfoText("When enabled rechat event will be fired on first LLM response.")
	endIf
	
	if (a_option == _toggle_npc_go_near)
		SetInfoText("When enabled, NPCs subtly walk toward the player to avoid having dialogues occur too far away. Only works when player is sitting")
	endIf
	
	if (a_option == _toggle_autofocus_on_sit)
		SetInfoText("Rotate camera to talking NPC, works only when player is sitting and in 1st person")
	endIf
	
	if (a_option == _toggle_restrict_onscene)
		SetInfoText("When activated, NPCs running a scene will not be selected for AI speech unless directly addressed using 'Hey Dude' or targeted under the crosshair")
	endIf
	
	if (a_option == _toggle_usewebsocketstt)
		SetInfoText("Use WebSocket STT. External plugin needed.")
	endIf
	
	if (a_option == _keymap_godmode)
		SetInfoText("This is a switch to enter/leave 'AI god mode'")
	endIf
	
	if (a_option == _toggle_autoadd_hostile)
		SetInfoText("Auto activate policy, By default, it applies to non-hostile NPCs whose race allows player dialogue (PC Dialogue = 1).Check this to allow auto activate hostile NPCs")
	endIf
	
	if (a_option == _toggle_autoadd_allraces)
		SetInfoText("Auto activate policy, By default, it applies to non-hostile NPCs whose race allows player dialogue (PC Dialogue = 1).Check this to allow auto activate all races")
	endIf
	

endEvent