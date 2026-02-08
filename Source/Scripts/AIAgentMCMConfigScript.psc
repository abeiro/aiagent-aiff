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
bool		_toggleState2			= true

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
float		_timeout_int				= 60.0


int			_toggleAnimation
bool		_animationstate			= false


int			_toggle1OID_Rereg


int			_toggleInvertHeading
bool		_invertheadingstate			= false

int			_togglePauseDialogue
bool		_pauseDialogueState			= false


; Auto Activate related

int			_toggleAddAllNPC 
bool		_toggleAddAllNPCState			= false

int			_slider_max_distance_inside
float		_max_distance_inside		= 1200.0

int			_slider_max_distance_outside
float		_max_distance_outside		= 2400.0

int			_slider_bored_period
float		_bored_period		= 60.0

int			_slider_dynamic_profile_period
float		_dynamic_profile_period		= 20.0

int 		_toggleRechat_policy_asap
bool  		_rechat_policy_asap = false

int 		_toggle_npc_go_near
bool  		_toggle_npc_go_near_state = true

int 		_toggle_npc_walk_to_target
bool  		_toggle_npc_walk_to_target_state = false

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


; Open Mic functionality
int			_toggle_openmic
bool		_toggle_openmic_state			= false

int			_slider_openmic_sensitivity
float		_openmic_sensitivity			= 1000.0

int			_slider_openmic_enddelay
float		_openmic_enddelay				= 1.0

int			_keymap_openmic_mute
int			_openmic_mute_key				= -1


int			_keymap_godmode
int			_godmode_key					= -1

int			_keymap_halt
int			_halt_key					= -1

int			_keymap_masterwheel
int			_masterwheel_key				= -1

; CHIM Browser Beta (Prisma UI)
int			_keymap_browser
int			_browser_key					= -1

; CHIM Debugger (Prisma UI)
int			_keymap_debugger
int			_debugger_key					= -1

; CHIM Chatbox (Prisma UI)
int			_keymap_chatbox
int			_chatbox_key					= -1

; CHIM Chatbox Focus Toggle
int			_keymap_chatbox_focus
int			_chatbox_focus_key				= -1

; CHIM Settings Menu (Prisma UI)
int			_keymap_settingsmenu
int			_settingsmenu_key				= -1

; CHIM Overlay/Status Cycle (Single hotkey)
int			_keymap_overlaystatus_cycle
int			_overlaystatus_cycle_key		= -1

; CHIM History/Diaries Cycle (Single hotkey)
int			_keymap_historydiaries_cycle
int			_historydiaries_cycle_key		= -1

int			_actionSendLocations
bool		_actionSendLocationsState		= false
int			_actionSendVoices


; combat dialogue
int			_toggle_combatdialogue
bool		_toggle_combatdialogue_state		= false

; Cancel dialogue on combat entry
int			_toggle_cancel_dialogue_on_combat
bool		_toggle_cancel_dialogue_on_combat_state		= false

; Combat barks
int			_toggle_combat_barks
bool		_toggle_combat_barks_state		= false

int			_slider_combat_barks_period
float		_combat_barks_period			= 30.0


; AI Agents page variables
int[] 		_agentToggleOIDs
string[]	_currentAgentNames
int			_toggleAddAllNowNPC
int			_removeAllAgentsOID

; New variables for nearby non-agent NPCs
int[]		_nearbyNpcToggleOIDs
string[]	_nearbyNpcNames
int			_refreshNearbyNPCsOID



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
bool 		_rechat_policy_asap_default		= true
bool		_toggle_openmic_stateDefault	= false
float		_openmic_sensitivityDefault		= 1000.0
float		_openmic_enddelayDefault		= 1.0
int			_openmic_mute_keyDefault		= -1
bool		_toggle_cancel_dialogue_on_combat_stateDefault = false
bool		_toggle_combat_barks_stateDefault	= false
float		_combat_barks_periodDefault		= 30.0

int			_halt_keyDefault				= -1

int			_masterwheel_keyDefault			= -1

int			_overlaystatus_cycle_keyDefault	= -1

int			_historydiaries_cycle_keyDefault = -1

event OnPlayerLoadGame()
	; Re-apply combat settings on every game load since C++ plugin doesn't persist them
	
	int combatDialogueValue = AIAgentFunctions.get_conf_i("_combat_dialogue")
	if (combatDialogueValue > 0)
		_toggle_combatdialogue_state = true
		controlScript.setConf("_combat_dialogue", 1)
	else
		_toggle_combatdialogue_state = false
		controlScript.setConf("_combat_dialogue", 0)
	endIf
	
	int combatBarksValue = AIAgentFunctions.get_conf_i("_combat_barks")
	if (combatBarksValue > 0)
		_toggle_combat_barks_state = true
		controlScript.setConf("_combat_barks", 1)
	else
		_toggle_combat_barks_state = false
		controlScript.setConf("_combat_barks", 0)
	endIf
	
	int combatBarksPeriodValue = AIAgentFunctions.get_conf_i("_combat_barks_period")
	if (combatBarksPeriodValue >= 5)
		_combat_barks_period = combatBarksPeriodValue as float
		controlScript.setConf("_combat_barks_period", _combat_barks_period)
	else
		_combat_barks_period = 30.0
		controlScript.setConf("_combat_barks_period", 30.0)
	endIf
	
	int cancelDialogueValue = AIAgentFunctions.get_conf_i("_cancel_dialogue_on_combat")
	if (cancelDialogueValue > 0)
		_toggle_cancel_dialogue_on_combat_state = true
		controlScript.setConf("_cancel_dialogue_on_combat", 1)
	else
		_toggle_cancel_dialogue_on_combat_state = false
		controlScript.setConf("_cancel_dialogue_on_combat", 0)
	endIf
endEvent

event OnConfigInit()

	ModName="CHIM"
	Pages = new string[7]
	Pages[0] = "Main"
	Pages[1] = "Auto Activate"
	Pages[2] = "Behavior"
	Pages[3] = "Sound"
	Pages[4] = "Prisma UI"
	Pages[5] = "AI Agents"
	Pages[6] = "Tools"
	
	Debug.Trace("[AIAGENT] OnConfigInit");
	
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
		controlScript.setConf("_rechat_policy_asap",1); Note , this is inverted. 0 means slow smart rechat (new), 1 shoud be legacy behavior
		_rechat_policy_asap=false
	endIf
	
	if (CurrentVersion<37)
		_bored_period=60
		StorageUtil.SetIntValue(None, "AIAgentNpcWalkNear",1);
		_toggle_npc_go_near_state=true
	endIf
	
	if (CurrentVersion<43)
		_dynamic_profile_period=20
	endIf
	
	; Load combat dialogue settings
	int combatDialogueValue = AIAgentFunctions.get_conf_i("_combat_dialogue")
	if (combatDialogueValue > 0)
		_toggle_combatdialogue_state = true
		controlScript.setConf("_combat_dialogue", 1)
	else
		_toggle_combatdialogue_state = false
		controlScript.setConf("_combat_dialogue", 0)
	endIf
	
	; Load combat barks settings
	int combatBarksValue = AIAgentFunctions.get_conf_i("_combat_barks")
	if (combatBarksValue > 0)
		_toggle_combat_barks_state = true
		controlScript.setConf("_combat_barks", 1)
	else
		_toggle_combat_barks_state = false
		controlScript.setConf("_combat_barks", 0)
	endIf
	
	int combatBarksPeriodValue = AIAgentFunctions.get_conf_i("_combat_barks_period")
	if (combatBarksPeriodValue >= 5)
		_combat_barks_period = combatBarksPeriodValue as float
		controlScript.setConf("_combat_barks_period", _combat_barks_period)
	else
		_combat_barks_period = 30.0
		controlScript.setConf("_combat_barks_period", 30.0)
	endIf
	
	; Load cancel dialogue on combat setting
	int cancelDialogueValue = AIAgentFunctions.get_conf_i("_cancel_dialogue_on_combat")
	if (cancelDialogueValue > 0)
		_toggle_cancel_dialogue_on_combat_state = true
		controlScript.setConf("_cancel_dialogue_on_combat", 1)
	else
		_toggle_cancel_dialogue_on_combat_state = false
		controlScript.setConf("_cancel_dialogue_on_combat", 0)
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
		

		controlScript.setConf("_restrict_onscene",1)
		_toggle_restrict_onscene=1 
		_toggle_restrict_onscene_state=true;
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

	return 53

endFunction

event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version

	if (a_version == 53 && a_version > CurrentVersion)
		; Version 53: Added new Prisma UI page to MCM menu
		OnConfigInit()
	endIf

	if (a_version == 52 && a_version > CurrentVersion)
		; Version 52: Added CHIM Chatbox Focus keybinding
		_chatbox_focus_key = -1
		OnConfigInit()
	endIf

	if (a_version == 51 && a_version > CurrentVersion)
		; Version 51: Added CHIM Chatbox keybinding
		_chatbox_key = -1
		OnConfigInit()
	endIf

	if (a_version == 50 && a_version > CurrentVersion)
		OnConfigInit()
		
	endIf

	if (a_version == 49 && a_version > CurrentVersion)
		OnConfigInit()
		
	endIf

	if (a_version == 48 && a_version > CurrentVersion)
		OnConfigInit()
		
	endIf
	
	if (a_version == 47 && CurrentVersion < 45)
		OnConfigInit()
		
	endIf
	
	if (a_version >= 2 && CurrentVersion < 45)
		OnConfigInit()
		
		; Clear any AutoActivate related settings from existing saves
		if (CurrentVersion < 37)
			controlScript.setConf("_max_distance_inside", 0.0)
			controlScript.setConf("_max_distance_outside", 0.0)
			controlScript.setConf("_bored_period", 60)
			controlScript.setConf("_toggleAddAllNPC", 0)
		endif
		
	endIf
	
	if (CurrentVersion==0)
		Debug.Trace("First install detected")
		controlScript.setConf("_toggleAddAllNPC", 1)
		_toggleAddAllNPC=1
		_toggleAddAllNPCState=true
		
	endif;
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
		; === Communication Hotkeys ===
		_keymapOID_K = AddKeyMapOption("Text Chat", _myKey)
		_keymapOID_K2 = AddKeyMapOption("Voice Chat", _myKey2)
		
		; === Master Wheel ===
		_keymap_masterwheel		= AddKeyMapOption("Master Wheel", _masterwheel_key)
		
		; === Wheel Hotkeys ===
		_keymapOID_K4		= AddKeyMapOption("Roleplay Wheel", _myKey4)
		_keymapOID_K3		= AddKeyMapOption("Settings Wheel", _myKey3)
		_keymap_godmode		= AddKeyMapOption("Mode Wheel", _godmode_key)
		_keymapOID_K6		= AddKeyMapOption("Soulgaze Wheel", _myKey6)
		
		; === Action Hotkeys ===
		_keymapOID_K7		= AddKeyMapOption("Manual AI Activate", _myKey7)
		_keymap_halt		= AddKeyMapOption("Halt AI Actions", _halt_key)
		
		; === Settings ===
		_toggle1OID_C		= AddToggleOption("Enable AI Actions", _toggleState2)
		_toggleAnimation		= AddToggleOption("Enable Animations", _animationstate)
		_toggle1OID_E		= AddToggleOption("Soulgaze HD Mode", _toggleState7)
		_slider_timeout	= AddSliderOption("Connection Timeout (seconds)",_timeout_int,"{1}" )
	endif
	

	if (a_page=="Auto Activate")
		_toggleAddAllNPC		= AddToggleOption("Enable Auto Activate", _toggleAddAllNPCState)
		AddEmptyOption()
		
		_slider_max_distance_inside	= AddSliderOption("Interior Auto Activate Distance",_max_distance_inside,"{0}" )
		_slider_max_distance_outside	= AddSliderOption("Exterior Auto Activate Distance",_max_distance_outside,"{0}" )
		
		AddEmptyOption()
		
		_toggle_autoadd_hostile	= AddToggleOption("Add Hostile NPCs", _toggle_autoadd_hostile_state)
		AddEmptyOption() 
		_toggle_autoadd_allraces	= AddToggleOption("Add All races", _toggle_autoadd_allraces_state)
		
	endif

	if (a_page=="Behavior")
		_slider_bored_period	= AddSliderOption("Bored Event Timer (seconds)",_bored_period,"{0}" )
		_slider_dynamic_profile_period	= AddSliderOption("Dynamic Profile Timer (minutes)",_dynamic_profile_period,"{0}" )
		_toggleRechat_policy_asap	= AddToggleOption("Smart Rechat", _rechat_policy_asap)
		
		AddEmptyOption()
		AddHeaderOption("NPC Behavior")
		AddEmptyOption()
		
		_toggle_npc_go_near	= AddToggleOption("NPCs Sandbox Near Player", _toggle_npc_go_near_state)
		_toggle_npc_walk_to_target	= AddToggleOption("NPCs Walk To Target", _toggle_npc_walk_to_target_state)
		_toggle_autofocus_on_sit	= AddToggleOption("Seat Conversation Camera", _toggle_autofocus_on_sit_state)
		
		_toggle_restrict_onscene	= AddToggleOption("NPC Scene Safety", _toggle_restrict_onscene_state)
		
		AddEmptyOption()
		AddHeaderOption("Combat Settings")
		AddEmptyOption()
		
		_toggle_combatdialogue	= AddToggleOption("Allow combat dialogue", _toggle_combatdialogue_state)
		_toggle_cancel_dialogue_on_combat = AddToggleOption("Clear dialogue entering combat", _toggle_cancel_dialogue_on_combat_state)
		AddEmptyOption()
		_toggle_combat_barks = AddToggleOption("Enable Combat Barks", _toggle_combat_barks_state)
		_slider_combat_barks_period = AddSliderOption("Combat Bark Timer (seconds)", _combat_barks_period, "{0}")
		
	endif
	

	if (a_page=="Sound")
		_slider_volume		= AddSliderOption("AI Voice Volume", _sound_volume,"{0}")
		_slider_ds			= AddSliderOption("AI Voice Distance Scale",_sound_ds,"{1}" )
		
		_slider_preclip		= AddSliderOption("Skip milliseconds at begining",_sound_preclip,"{0}" )
		_slider_postclip	= AddSliderOption("Skip milliseconds at end",_sound_postclip,"{0}" )
		
		_toggleInvertHeading	= AddToggleOption("3D Sound Invert Heading",_invertheadingstate)
		AddEmptyOption();
		
		_slider_lip_res	= AddSliderOption("Resolution of Lip Animations",_lip_res,"{0}" )
		_slider_lip_int			= AddSliderOption("Intensity of Lip Animations ",_lip_int,"{1}" )
		
		;AddEmptyOption();
		_togglePauseDialogue	= AddToggleOption("Pause Dialogue on Game Pause",_pauseDialogueState)
		_toggle_usewebsocketstt			= AddToggleOption("Use WebSocket STT",_toggle_usewebsocketstt_state)
		
		AddEmptyOption();
		AddHeaderOption("Open Mic Settings")
		_toggle_openmic		= AddToggleOption("Enable Open Mic", _toggle_openmic_state)
		_slider_openmic_sensitivity = AddSliderOption("Voice Detection Sensitivity", _openmic_sensitivity, "{0}")
		_slider_openmic_enddelay = AddSliderOption("End of Sentence Delay (seconds)", _openmic_enddelay, "{1}")
		_keymap_openmic_mute = AddKeyMapOption("Mute Open Mic", _openmic_mute_key)

	
	endif
	
	if (a_page=="Prisma UI")
		AddHeaderOption("View Cycling Hotkeys")
		_keymap_historydiaries_cycle = AddKeyMapOption("History/Diaries Cycle", _historydiaries_cycle_key)
		_keymap_overlaystatus_cycle = AddKeyMapOption("Overlay/Status/AI View Cycle", _overlaystatus_cycle_key)
		
		AddEmptyOption()
		AddHeaderOption("Panel Hotkeys")
		_keymap_browser = AddKeyMapOption("CHIM Browser (Beta)", _browser_key)
		_keymap_debugger = AddKeyMapOption("CHIM Logs View (Beta)", _debugger_key)
		_keymap_chatbox = AddKeyMapOption("CHIM Chatbox", _chatbox_key)
		_keymap_chatbox_focus = AddKeyMapOption("CHIM Chatbox Focus", _chatbox_focus_key)
		_keymap_settingsmenu = AddKeyMapOption("CHIM Settings Menu", _settingsmenu_key)
	endif
	
	if (a_page=="AI Agents")
		AddHeaderOption("Agent Management")
		AddEmptyOption()
		
		_toggleAddAllNowNPC	= AddToggleOption("Add all current AI Agents", false)
		_removeAllAgentsOID = AddToggleOption("Remove All AI Agents", false)
		AddEmptyOption()
		
		; Get current AI agents (all agents, not just nearby)
		Actor[] allAgents = AIAgentFunctions.findAllAgents()
		_currentAgentNames = new string[128]  ; Maximum agents we can display
		_agentToggleOIDs = new int[128]
		
		int i = 0
		int displayedAgents = 0
		while i < allAgents.Length && displayedAgents < 120  ; Leave some room for other options
			if (allAgents[i] && allAgents[i].GetDisplayName() != "The Narrator" && allAgents[i] != Game.GetPlayer())
				_currentAgentNames[displayedAgents] = allAgents[i].GetDisplayName()
				_agentToggleOIDs[displayedAgents] = AddToggleOption("Remove: " + _currentAgentNames[displayedAgents], false)
				displayedAgents += 1
			endif
			i += 1
		endwhile
		
		AddHeaderOption("Active AI Agents")
		AddEmptyOption()
		
		if (displayedAgents == 0)
			AddTextOption("No AI agents active", "")
		else
			AddTextOption("Total Active Agents: " + displayedAgents, "")
		endif
		
		AddEmptyOption()
		AddHeaderOption("Nearby Available NPCs")
		AddEmptyOption()
		
		_refreshNearbyNPCsOID = AddToggleOption("Refresh Nearby NPCs List", false)
		AddEmptyOption()
		
		; Get nearby NPCs that are NOT currently AI agents
		Actor[] nearbyNonAgents = AIAgentFunctions.findAllNearbyNonAgents()
		_nearbyNpcNames = new string[128]
		_nearbyNpcToggleOIDs = new int[128]
		
		int j = 0
		int displayedNearbyNPCs = 0
		while j < nearbyNonAgents.Length && displayedNearbyNPCs < 60  ; Limit to reasonable number
			if (nearbyNonAgents[j] && nearbyNonAgents[j].GetDisplayName() != "The Narrator" && nearbyNonAgents[j] != Game.GetPlayer())
				_nearbyNpcNames[displayedNearbyNPCs] = nearbyNonAgents[j].GetDisplayName()
				_nearbyNpcToggleOIDs[displayedNearbyNPCs] = AddToggleOption("Add: " + _nearbyNpcNames[displayedNearbyNPCs], false)
				displayedNearbyNPCs += 1
			endif
			j += 1
		endwhile
		
		if (displayedNearbyNPCs == 0)
			AddTextOption("No nearby available NPCs", "")
		else
			AddTextOption("Available NPCs: " + displayedNearbyNPCs, "")
		endif
		
	endif
	
	if (a_page=="Tools")
		
		_actionSendLocations = AddToggleOption("Send all locations to server", false)
		_actionSendVoices = AddToggleOption("Send all vanilla voice samples to server", false)
	
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
	
	if (a_option == _slider_dynamic_profile_period)
		SetSliderDialogStartValue(_dynamic_profile_period)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(5, 120)
		SetSliderDialogInterval(1)
	endIf
	
	if (a_option == _slider_openmic_sensitivity)
		SetSliderDialogStartValue(_openmic_sensitivity)
		SetSliderDialogDefaultValue(1000)
		SetSliderDialogRange(100, 5000)
		SetSliderDialogInterval(100)
	endIf
	
	if (a_option == _slider_openmic_enddelay)
		SetSliderDialogStartValue(_openmic_enddelay)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.5, 5.0)
		SetSliderDialogInterval(0.1)
	endIf
	
	if (a_option == _slider_combat_barks_period)
		SetSliderDialogStartValue(_combat_barks_period)
		SetSliderDialogDefaultValue(30.0)
		SetSliderDialogRange(5.0, 120.0)
		SetSliderDialogInterval(5.0)
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
		controlScript.mdi=_max_distance_inside;
		SetSliderOptionValue(a_option, a_value, "{1}")
		
	endIf
	
	if (a_option == _slider_max_distance_outside)
		_max_distance_outside = a_value
		controlScript.setConf("_max_distance_outside",_max_distance_outside)
		controlScript.mdo=_max_distance_outside;
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_bored_period)
		_bored_period = a_value
		controlScript.setConf("_bored_period",_bored_period)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_dynamic_profile_period)
		_dynamic_profile_period = a_value
		controlScript.setConf("_dynamic_profile_period",_dynamic_profile_period)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_openmic_sensitivity)
		_openmic_sensitivity = a_value
		controlScript.setConf("_openmic_sensitivity",_openmic_sensitivity)
		SetSliderOptionValue(a_option, a_value, "{0}")
	endIf
	
	if (a_option == _slider_openmic_enddelay)
		_openmic_enddelay = a_value
		controlScript.setConf("_openmic_enddelay",_openmic_enddelay)
		SetSliderOptionValue(a_option, a_value, "{1}")
	endIf
	
	if (a_option == _slider_combat_barks_period)
		_combat_barks_period = a_value
		controlScript.setConf("_combat_barks_period",_combat_barks_period)
		SetSliderOptionValue(a_option, a_value, "{0}")
	endIf
	
	
endEvent
	
	
event OnGameReload()
	parent.OnGameReload()
	bool a; to avoid warnings on runtime
	if (_toggleState1)
		;controlScript.setTTSOn();
		getActionMode();
	endIf
	if (_toggleState3)
		a=controlScript.setVoiceType(1);	
	else
		a=controlScript.setVoiceType(0);
	endif

	a=controlScript.setConf("_sound_postclip",_sound_postclip)
	a=controlScript.setConf("_sound_preclip",_sound_preclip)
	a=controlScript.setConf("_sound_volume",_sound_volume)
	a=controlScript.setConf("_sound_ds",_sound_ds)
	a=controlScript.setConf("_lip_int",_lip_int)
	a=controlScript.setConf("_lip_res",_lip_res)
	a=controlScript.setConf("_timeout",_timeout_int)


	a=controlScript.setConf("_max_distance_inside",_max_distance_inside)
	a=controlScript.setConf("_max_distance_outside",_max_distance_outside)
	
	controlScript.mdi=_max_distance_inside;
	controlScript.mdo=_max_distance_outside;

	
	a=controlScript.setConf("_bored_period",_bored_period)
	a=controlScript.setConf("_dynamic_profile_period",_dynamic_profile_period)
	
	if (_toggleAddAllNPCState)
		a=controlScript.setConf("_toggleAddAllNPC",1)
	else
		a=controlScript.setConf("_toggleAddAllNPC",0)
	endif

	if (_rechat_policy_asap)
		a=controlScript.setConf("_rechat_policy_asap",0); Inverted
	else
		a=controlScript.setConf("_rechat_policy_asap",1); Inverted
	endif

	
	if (_animationstate)
		a=controlScript.setConf("_animations",1)
	else
		a=controlScript.setConf("_animations",0)
	endif
	
	if (_pauseDialogueState)
		a=controlScript.setConf("_pause_dialogue_when_menu_open",1)
	else
		a=controlScript.setConf("_pause_dialogue_when_menu_open",0)
	endif
	
	if (_toggle_autoadd_hostile_state)
		a=controlScript.setConf("_autoadd_hostile",1)
	else
		a=controlScript.setConf("_autoadd_hostile",0)
	endif
	
	if (_toggle_autoadd_allraces_state)
		a=controlScript.setConf("_autoadd_allraces",1)
	else
		a=controlScript.setConf("_autoadd_allraces",0)
	endif
	
	a=controlScript.setSoulgazeModeNative(_toggleState7 as Int)
	
	a=controlScript.setConf("_godmode",0)
	controlScript._currentGodmodeStatus=false
	
	; Open mic settings
	if (_toggle_openmic_state)
		a=controlScript.setConf("_openmic_enabled",1)
	else
		a=controlScript.setConf("_openmic_enabled",0)
	endif
	
	a=controlScript.setConf("_openmic_sensitivity",_openmic_sensitivity)
	a=controlScript.setConf("_openmic_enddelay",_openmic_enddelay)
	
	; Combat settings
	if (_toggle_combatdialogue_state)
		a=controlScript.setConf("_combat_dialogue",1)
	else
		a=controlScript.setConf("_combat_dialogue",0)
	endif
	
	if (_toggle_cancel_dialogue_on_combat_state)
		a=controlScript.setConf("_cancel_dialogue_on_combat",1)
	else
		a=controlScript.setConf("_cancel_dialogue_on_combat",0)
	endif
	
	if (_toggle_combat_barks_state)
		a=controlScript.setConf("_combat_barks",1)
	else
		a=controlScript.setConf("_combat_barks",0)
	endif
	
	a=controlScript.setConf("_combat_barks_period",_combat_barks_period)
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
		
	elseif (a_option == _toggle_openmic)
		_toggle_openmic_state = _toggle_openmic_stateDefault
		SetToggleOptionValue(a_option, _toggle_openmic_state)
		
	elseif (a_option == _slider_openmic_sensitivity)
		_openmic_sensitivity = _openmic_sensitivityDefault
		SetSliderOptionValue(a_option, _openmic_sensitivity, "{0}")
		
	elseif (a_option == _slider_openmic_enddelay)
		_openmic_enddelay = _openmic_enddelayDefault
		SetSliderOptionValue(a_option, _openmic_enddelay, "{1}")
		
	elseif (a_option == _keymap_openmic_mute)
		controlScript.removeBinding(_openmic_mute_key)
		_openmic_mute_key = _openmic_mute_keyDefault
		SetKeymapOptionValue(a_option, _openmic_mute_key)
		controlScript.doBinding9(_openmic_mute_key)
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
		elseif (a_option == _keymap_openmic_mute)
			controlScript.removeBinding(_openmic_mute_key)
			_openmic_mute_key = a_keyCode
			controlScript.doBinding9(_openmic_mute_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_halt)
			controlScript.removeBinding(_halt_key)
			_halt_key = a_keyCode
			controlScript.doBinding10(_halt_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_masterwheel)
			controlScript.removeBinding(_masterwheel_key)
			_masterwheel_key = a_keyCode
			controlScript.doBinding11(_masterwheel_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_overlaystatus_cycle)
			controlScript.removeBinding(_overlaystatus_cycle_key)
			_overlaystatus_cycle_key = a_keyCode
			controlScript.doBinding12(_overlaystatus_cycle_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_historydiaries_cycle)
			controlScript.removeBinding(_historydiaries_cycle_key)
			_historydiaries_cycle_key = a_keyCode
			controlScript.doBinding13(_historydiaries_cycle_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_browser)
			controlScript.removeBinding(_browser_key)
			_browser_key = a_keyCode
			controlScript.doBinding14(_browser_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_debugger)
			controlScript.removeBinding(_debugger_key)
			_debugger_key = a_keyCode
			controlScript.doBinding15(_debugger_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_chatbox)
			controlScript.removeBinding(_chatbox_key)
			_chatbox_key = a_keyCode
			controlScript.doBinding16(_chatbox_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_chatbox_focus)
			controlScript.removeBinding(_chatbox_focus_key)
			_chatbox_focus_key = a_keyCode
			controlScript.doBinding17(_chatbox_focus_key)
			if (a_keyCode == -1)
				ForcePageReset()
			else
				SetKeymapOptionValue(a_option, a_keyCode)
			endif
		elseif (a_option == _keymap_settingsmenu)
			controlScript.removeBinding(_settingsmenu_key)
			_settingsmenu_key = a_keyCode
			controlScript.doBinding18(_settingsmenu_key)
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
			controlScript.setConf("_rechat_policy_asap",0)
		else
			controlScript.setConf("_rechat_policy_asap",1)
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
	
	if (a_option == _toggle_npc_walk_to_target)
		_toggle_npc_walk_to_target_state = !_toggle_npc_walk_to_target_state
		if (_toggle_npc_walk_to_target_state)
			StorageUtil.SetIntValue(None, "AIAgentNpcWalkToTarget",1);
		else
			StorageUtil.SetIntValue(None, "AIAgentNpcWalkToTarget",0);
		endif
		SetToggleOptionValue(a_option, _toggle_npc_walk_to_target_state)

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
	
	if (a_option == _toggle_openmic)
 		_toggle_openmic_state = !_toggle_openmic_state
 
 		if (_toggle_openmic_state)
 			controlScript.setConf("_openmic_enabled",1)
 		else
 			controlScript.setConf("_openmic_enabled",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_openmic_state)
 	endIf
	
	
	if (a_option == _toggle_combatdialogue)
 		_toggle_combatdialogue_state = !_toggle_combatdialogue_state
 
 		if (_toggle_combatdialogue_state)
 			controlScript.setConf("_combat_dialogue",1)
 		else
 			controlScript.setConf("_combat_dialogue",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_combatdialogue_state)
 	endIf
	
	if (a_option == _toggle_cancel_dialogue_on_combat)
 		_toggle_cancel_dialogue_on_combat_state = !_toggle_cancel_dialogue_on_combat_state
 
 		if (_toggle_cancel_dialogue_on_combat_state)
 			controlScript.setConf("_cancel_dialogue_on_combat",1)
 		else
 			controlScript.setConf("_cancel_dialogue_on_combat",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_cancel_dialogue_on_combat_state)
 	endIf
	
	if (a_option == _toggle_combat_barks)
 		_toggle_combat_barks_state = !_toggle_combat_barks_state
 
 		if (_toggle_combat_barks_state)
 			controlScript.setConf("_combat_barks",1)
 		else
 			controlScript.setConf("_combat_barks",0)
 		endif
 
 		SetToggleOptionValue(a_option, _toggle_combat_barks_state)
 	endIf
	
	if (a_option == _actionSendLocations)
		ShowMessage("Please..wait 1 minute for the 'Done' message. ")
 		AIAgentPapyrusFunctions.sendAllLocations();
 		ShowMessage("Done")
 	endIf
	
 	if (a_option == _actionSendVoices)
		ShowMessage("Uploading all voice samples. Will take 5-10 seconds.")
		AIAgentFunctions.sendAllVoices()
		ShowMessage("Voice samples uploaded successfully")
	endIf
	
 	; Handle AI Agents page options
 	if (a_option == _toggleAddAllNowNPC)
 		AIAgentFunctions.testAddAllNPCAround()
 		ForcePageReset()
 		ShowMessage("AI agents added successfully")
 	endIf
 	
 	if (a_option == _removeAllAgentsOID)
 		bool confirmed = ShowMessage("Are you sure you want to remove ALL AI agents? Won't do anything if Auto Activate is enabled.", true, "$Yes", "$No")
 		if (confirmed)
 			AIAgentFunctions.testRemoveAll()
 			ForcePageReset()
 			ShowMessage("All AI agents removed")
 		endif
 	endIf
 	
 	; Handle individual agent removal
 	if (_agentToggleOIDs && _currentAgentNames)
 		int i = 0
 		while i < _agentToggleOIDs.Length
 			if (a_option == _agentToggleOIDs[i] && _currentAgentNames[i] != "")
 				bool confirmed = ShowMessage("Remove AI agent '" + _currentAgentNames[i] + "'?", true, "$Yes", "$No")
 				if (confirmed)
 					AIAgentFunctions.removeAgentByName(_currentAgentNames[i])
 					ForcePageReset()
 					ShowMessage("Removed AI agent: " + _currentAgentNames[i])
 				endif
 				return
 			endif
 			i += 1
 		endwhile
 	endif
 	
 	; Handle refresh nearby NPCs
 	if (a_option == _refreshNearbyNPCsOID)
 		ForcePageReset()
 		ShowMessage("Nearby NPCs list refreshed")
 	endIf
 	
 	; Handle individual nearby NPC addition
 	if (_nearbyNpcToggleOIDs && _nearbyNpcNames)
 		int k = 0
 		while k < _nearbyNpcToggleOIDs.Length
 			if (a_option == _nearbyNpcToggleOIDs[k] && _nearbyNpcNames[k] != "")
 				bool confirmed = ShowMessage("Add AI agent '" + _nearbyNpcNames[k] + "'?", true, "$Yes", "$No")
 				if (confirmed)
 					Actor targetNPC = None
 					
 					; Find the actual actor by name from the nearby non-agents list
 					Actor[] nearbyNonAgents = AIAgentFunctions.findAllNearbyNonAgents()
 					int m = 0
 					while m < nearbyNonAgents.Length && !targetNPC
 						if (nearbyNonAgents[m] && nearbyNonAgents[m].GetDisplayName() == _nearbyNpcNames[k])
 							targetNPC = nearbyNonAgents[m]
 						endif
 						m += 1
 					endwhile
 					
 					if (targetNPC)
 						AIAgentFunctions.setDrivenByAIA(targetNPC, true)
 						ForcePageReset()
 						ShowMessage("Added AI agent: " + _nearbyNpcNames[k])
 					else
 						ShowMessage("Could not find NPC: " + _nearbyNpcNames[k])
 					endif
 				endif
 				return
 			endif
 			k += 1
 		endwhile
 	endif
	
endEvent

event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}
	
	if (a_option == _keymapOID_K)
		SetInfoText("Open a text box to communicate with AI NPCs via typed messages.")
	endIf
	if (a_option == _toggle1OID_B)
		SetInfoText("Enables Text-to-Speech for AI NPCs.")
	endIf
	if (a_option == _keymapOID_K2)
		SetInfoText("Push-to-Talk: Speak with AI NPCs or summarize open books. Ensure your microphone is set as default recording device in Windows.")
	endIf
	if (a_option == _toggle1OID_C)
		SetInfoText("Enable AI to perform actions.")
	endIf
	if (a_option == _toggle1OID_D)
		SetInfoText("If using mods like RDO, check this to force default voice, so dialog Follow me should appear. Note that checking this will disable custom voiced sounds. As of version 0.9.x, this shouldn't be needed.")
	endIf
	if (a_option == _keymapOID_K3)
		SetInfoText("Settings Wheel - Looking at NPC: Assign profiles (1-4). Not looking: Switch LLM models, toggle focus chat.")
	endIf
	if (a_option == _keymapOID_K4)
		SetInfoText("Roleplay Wheel - Write Diary, Gather NPCs, Follow NPC, Update NPC, Wait/Follow, Stop All AI, Add to BgL. Hold it for nearby NPCs to write diary entries.")
	endIf
	if (a_option == _keymapOID_K5)
		SetInfoText("Change AI/LLM Connector.")
	endIf
	if (a_option == _keymapOID_K6)
		SetInfoText("Soulgaze Wheel - Take screenshots for ITT: Full soulgaze, NPC photos (zoomed/standard), or raw upload.")
	endIf
	if (a_option == _keymapOID_K7)
		SetInfoText("Manually activate/deactivate AI control for the targeted NPC or all nearby NPCs if none targeted.")
	endIf
	if (a_option == _slider_volume)
		SetInfoText("Set AI NPC speech volume.")
	endIf
	if (a_option == _slider_preclip)
		SetInfoText("Skips specified millisecods at begining of a sentence. Some TTS services add some silence at the begining of audio clips.")
	endIf
	if (a_option == _slider_postclip)
		SetInfoText("Skips specified millisecods at end of a sentence. Some TTS services add some silence at the end of audio clips.")
	endIf
	if (a_option == _slider_ds)
		SetInfoText("Adjust AI NPC volume at distance.")
	endIf
	if (a_option == _toggle1OID_E)
		SetInfoText("Enable HD mode for Soulgaze (DirectX backbuffer access, server compression). Disable for in-game screenshots (VR users should disable).")
	endIf
	
	if (a_option == _slider_lip_int)
		SetInfoText("Lip modifier intensity. Set it lower if mouth opens too much ")
	endIf
	
	if (a_option == _slider_lip_res)
		SetInfoText("Lip modifier resolution. Set it lower if movement is too laggy. Lower uses more CPU. Find your sweet spot.")
	endIf
	
	if (a_option == _slider_timeout)
		SetInfoText("Connection timeout when requesting data from CHIM Server. Recommended: 60 seconds.")
	endIf
	
	if (a_option == _toggleAnimation)
		SetInfoText("Enable AI NPCs to perform animations during interactions.")
	endIf
	
	if (a_option == _toggle1OID_Rereg)
		SetInfoText("Mod name has changed. This will reset MCM to show new name. May affect other mods. Will call setstage SKI_ConfigManagerInstance 1")
	endIf
	
	if (a_option == _toggleInvertHeading)
		SetInfoText("When using 3D sound, it will try inverting the heading. This may resolve issues where NPCs in the front are heard at a lower volume.")
	endIf

	if (a_option == _togglePauseDialogue)
		SetInfoText("Enable to pause dialogue during game pauses. Disable to allow dialogue to continue during game pauses.")
	endIf

	if (a_option == _slider_max_distance_inside)
		SetInfoText("AI within this distance in interiors are Auto Activated.")
	endIf
	
	if (a_option == _slider_max_distance_outside)
		SetInfoText("AI within this distance outside are Auto Activated.")
	endIf
	
	if (a_option == _toggleAddAllNPC)
		SetInfoText("Will Auto Activate (almost) force all current NPCs.")
	endIf
	
	if (a_option == _slider_bored_period)
		SetInfoText("How many seconds (with some exceptions) a Bored event can potenitally be triggered.")
	endIf
	
	if (a_option == _slider_dynamic_profile_period)
		SetInfoText("Timer for automatic dynamic profile updates. Updates NPC personalities based on recent events.")
	endIf
	
	if (a_option == _toggleRechat_policy_asap)
		SetInfoText("When enabled, will send more context to a responding NPC during a Rechat event.")
	endIf
	
	if (a_option == _toggle_npc_go_near)
		SetInfoText("When enabled NPC's will subtly move around the player to make listening to conversations easier.")
	endIf
	
	if (a_option == _toggle_npc_walk_to_target)
		SetInfoText("NPCs will walk towards the NPC they are talking to. May break scenes - use Scene Safety with this option.")
	endIf
	
	if (a_option == _toggle_autofocus_on_sit)
		SetInfoText("Only works when player is seated and 1st person. Automatically rotate the camrea to a talking NPC. It's like Netflix!")
	endIf
	
	if (a_option == _toggle_restrict_onscene)
		SetInfoText("Prevent AI NPCs in a traditional dialogue scene from responding automatically.")
	endIf
	
	if (a_option == _toggle_usewebsocketstt)
		SetInfoText("Use WebSocket STT. Overrides CHIM server STT. Must download separately from the mod page. WIP.")
	endIf
	
	if (a_option == _keymap_godmode)
		SetInfoText("Mode Wheel - Switch between chat modes: Standard, Whisper, Director, Spawn NPC, Cheat Mode, Auto Chat, Inject. Hold to cycle modes.")
	endIf
	
	if (a_option == _keymap_halt)
		SetInfoText("Immediately stop all CHIM AI actions for targeted NPC or all nearby NPCs.")
	endIf
	
	if (a_option == _keymap_masterwheel)
		SetInfoText("Master Wheel - Quick access menu to open any of the 4 wheels: Roleplay, Settings, Mode, or Soulgaze.")
	endIf
	
	if (a_option == _keymap_historydiaries_cycle)
		SetInfoText("Cycle through reading panels: Press once for Conversation History, press again for Diaries, press again to close both. Both pause the game. Requires Prisma UI.")
	endIf
	
	if (a_option == _keymap_overlaystatus_cycle)
		SetInfoText("Cycle through CHIM UI states: Press once for Overlay, press again for Status HUD, press again for AI View, press again to close. Convenient single-key access to all info panels. Requires Prisma UI.")
	endIf
	
	if (a_option == _keymap_browser)
		SetInfoText("Toggle the CHIM Browser (Beta). Browse the full HerikaServer web interface in-game with cursor and typing support. Game pauses when open. Press the hotkey again to close. Requires Prisma UI.")
	endIf
	
	if (a_option == _keymap_debugger)
		SetInfoText("Open the CHIM Logs View (Beta). Access server logs, settings, and diagnostics from the HerikaServer control panel. Press hotkey again to close. Requires Prisma UI.")
	endIf
	
	if (a_option == _keymap_chatbox)
		SetInfoText("Toggle the CHIM Chatbox. MMO-style chat interface with Chat tab for AI dialogue and System tab for DLL errors. Type messages to communicate with AI agents. Requires Prisma UI.")
	endIf
	
	if (a_option == _keymap_chatbox_focus)
		SetInfoText("Focus/Unfocus the CHIM Chatbox. When chatbox is visible but unfocused, press to enable typing. When focused, press to send message and return control to game.")
	endIf
	
	if (a_option == _keymap_settingsmenu)
		SetInfoText("Open the CHIM Settings Menu. Central interface for all in-game settings from the 4 wheels. Game pauses when open, press hotkey again to close. Requires Prisma UI.")
	endIf
	
	if (a_option == _toggle_autoadd_hostile)
		SetInfoText("Auto Activate policy. By default, it applies to non-hostile NPCs whose race allows player dialogue (PC Dialogue = 1). Check this to allow Auto Activate hostile NPCs")
	endIf
	
	if (a_option == _toggle_autoadd_allraces)
		SetInfoText("Auto Activate policy. By default, it applies to non-hostile NPCs whose race allows player dialogue (PC Dialogue = 1). Check this option to allow Auto Activate for all races - including animals like rabbits, deer, foxes, etc. Note: Enabling this may cause instability.")
	endIf
	
	if (a_option == _actionSendLocations)
		SetInfoText("Will send all locations found in-game to server, so TravelTo action can work better")
	endIf
	
	if (a_option == _actionSendVoices)
		SetInfoText("Upload all vanilla Skyrim voice type samples to the server. This may take 5-10 seconds.")
	endIf

	if (a_option == _toggle_openmic)
		SetInfoText("Enable open microphone mode. Will automatically start recording when it detects voice input above the sensitivity threshold.")
	endIf
	
	if (a_option == _slider_openmic_sensitivity)
		SetInfoText("Voice detection sensitivity for open mic. Higher values require louder voice to trigger recording.")
	endIf
	
	if (a_option == _slider_openmic_enddelay)
		SetInfoText("How long to wait (in seconds) after voice stops before ending the recording and processing the speech.")
	endIf
	
	if (a_option == _keymap_openmic_mute)
		SetInfoText("Key to temporarily mute open microphone.")
	endIf
	

	if (a_option == _toggle_combatdialogue)
		SetInfoText("Enable combat dialogue.")
	endIf
	
	if (a_option == _toggle_cancel_dialogue_on_combat)
		SetInfoText("When enabled, all AI dialogue will be immediately cancelled when you enter combat (prevents NPCs talking during fights)")
	endIf
	
	if (a_option == _toggle_combat_barks)
		SetInfoText("When enabled AI agents in combat will periodically shout taunts/battle cries. Is controlled via Rechat. ")
	endIf
	
	if (a_option == _slider_combat_barks_period)
		SetInfoText("How often (in seconds) combat barks trigger during active combat. Will automatically trigger an event when combat starts. Default: 30 seconds")
	endIf

	; AI Agents page help text
	if (a_option == _toggleAddAllNowNPC)
		SetInfoText("Will Auto Activate (almost) all nearby NPCs.")
	endIf
	
	if (a_option == _removeAllAgentsOID)
		SetInfoText("Remove all active AI agents from the system.")
	endIf
	
	; Help text for individual agent removal options
	if (_agentToggleOIDs && _currentAgentNames)
		int i = 0
		while i < _agentToggleOIDs.Length
			if (a_option == _agentToggleOIDs[i] && _currentAgentNames[i] != "")
				SetInfoText("Remove the AI agent '" + _currentAgentNames[i] + "' from the active AI system.")
				return
			endif
			i += 1
		endwhile
	endif

	; Help text for refresh nearby NPCs
	if (a_option == _refreshNearbyNPCsOID)
		SetInfoText("Refresh the list of nearby NPCs that can be added to the AI system.")
	endIf
	
	; Help text for individual nearby NPC addition
	if (_nearbyNpcToggleOIDs && _nearbyNpcNames)
		int j = 0
		while j < _nearbyNpcToggleOIDs.Length
			if (a_option == _nearbyNpcToggleOIDs[j] && _nearbyNpcNames[j] != "")
				SetInfoText("Add the nearby NPC '" + _nearbyNpcNames[j] + "' to the AI system.")
				return
			endif
			j += 1
		endwhile
	endif


endEvent