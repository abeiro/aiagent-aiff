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

event OnConfigInit()
	ModName="CHIM"
	Pages = new string[2]
	Pages[0] = "Main"
	Pages[1] = "Sound"
	Debug.Trace("CHIM: OnConfigInit")
	Debug.Notification("[CHIM] Updating menu ... v3.5");
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
	ConsoleUtil.ExecuteCommand("setstage SKI_ConfigManagerInstance 1")
endEvent

int function GetVersion()
	return 36
endFunction

event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version
	if (a_version >= 2 && CurrentVersion < 35)
		OnConfigInit()
		
		; Clear any AutoActivate related settings from existing saves
		if (CurrentVersion < 36)
			controlScript.setConf("_max_distance_inside", 0.0)
			controlScript.setConf("_max_distance_outside", 0.0)
			controlScript.setConf("_bored_period", 120.0)
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
		;_toggle1OID_Rereg		= AddToggleOption("Register mod name again", false)
	endif
	

	if (a_page=="Sound")
		_slider_volume		= AddSliderOption("AI Voice Volume", _sound_volume,"{0}")
		_slider_ds			= AddSliderOption("AI Voice Distance Scale ",_sound_ds,"{1}" )
		
		_slider_preclip		= AddSliderOption("Skip milliseconds at begin",_sound_preclip,"{0}" )
		_slider_postclip	= AddSliderOption("Skip milliseconds at end",_sound_postclip,"{0}" )
		
		
		AddEmptyOption();
		_slider_lip_res	= AddSliderOption("Resolution of lip anim.",_lip_res,"{0}" )
		_slider_lip_int			= AddSliderOption("Intensity of lip anim ",_lip_int,"{1}" )
		;AddEmptyOption();
		_toggleInvertHeading	= AddToggleOption("3D sound invert heading",_invertheadingstate)
	
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
	
	if (_animationstate)
		controlScript.setConf("_animations",1)
	else
		controlScript.setConf("_animations",0)
	endif
	controlScript.setSoulgazeModeNative(_toggleState7 as Int)
	
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
			controlScript.setConf("_animations",1)
		else
			controlScript.setConf("_animations",0)
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
		SetInfoText("Change AI/LLM. Models should be selected in the AI-FF server configuration wizard.")
	endIf
	if (a_option == _keymapOID_K6)
		SetInfoText("Take a screeshot and sends to an ITT AI service to summarize what is shown.")
	endIf
	if (a_option == _keymapOID_K7)
		SetInfoText("Imports the NPC you are looking at into AI-FF. Can use it to turn their AI on and off.")
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
		SetInfoText("WIP for debug/testing")
	endIf
	
	if (a_option == _slider_lip_res)
		SetInfoText("WIP for debug/testing")
	endIf
	
	if (a_option == _slider_timeout)
		SetInfoText("Timeout in seconds when requesting data to server. Keep this a 30 for best experience.")
	endIf
	
	if (a_option == _toggleAnimation)
		SetInfoText("Enable animations. If useing openanimation replacer or custom animations you should disable it to prevent CTD")
	endIf
	
	if (a_option == _toggle1OID_Rereg)
		SetInfoText("Mod name has changed. This will reset MCM to show new name. May affect other mods. Will call setstage SKI_ConfigManagerInstance 1")
	endIf
	
	if (a_option == _toggleInvertHeading)
		SetInfoText("When using 3D sound, try inverting the heading. This may resolve issues where NPCs in front are heard at a lower volume.")
	endIf
endEvent