Scriptname AIAgentPapyrusFunctions extends Quest  


int			_currentKey = 0x52
int			_currentKeyVoice
int			_currentFollowKey
int			_currentDiaryKey
int			_currentCModelKey
int 		_currentCSoulgaze
int 		_currentCtl
int 		_currentGodmodeKey
int 		_currentOpenMicMuteKey
int 		_currentHaltKey
int 		_currentMasterWheel
bool property _currentGodmodeStatus  auto
bool		currentTTSStatus= false
bool		followingHerika= false
bool		_diaryKeyPressed= false ; Track if diary key is currently pressed

int		_nativeSoulGaze= 1

int _currentModeIndex = 0 

Spell Property IntimacySpell  Auto  


Actor	currentPlayerFollowTarget;
Actor	currentPlayerHorse;


float Property mdi auto
float Property mdo auto


Event OnInit()
	doBinding(_currentKey)
	Debug.Trace("[CHIM] AIAgentPapyrusFunctions quest script OnInit()")
EndEvent

Event OnKeyUp(int keyCode, float holdTime)
	If(keyCode == _currentKeyVoice)
		if (!UI.IsMenuOpen("Book Menu") && SafeProcess())
			int externalSTTactive=StorageUtil.GetIntValue(None, "AIAgentWebSockeSTT");
			if (externalSTTactive>0)
				AIAgentSTTExternal.stopRecording(_currentKeyVoice)
			else
				AIAgentFunctions.stopRecording(_currentKeyVoice)
			endif
			;WebSocketSTT.StopRecordVoice(_currentKeyVoice);
			Debug.Notification("[CHIM] Recording end");
		endif
	endif
	
	; Handle diary key release with hold time detection
	If(keyCode == _currentDiaryKey && _diaryKeyPressed)
		_diaryKeyPressed = false
		If !SafeProcess()
			Return
		EndIf
		
		
	
		
		; If held for more than 0.5 seconds, trigger all nearby NPCs
		If (holdTime >= 0.5)
			Debug.Notification("[CHIM] Diary: Nearby NPCs are writing diary entries")
			AIAgentFunctions.sendMessage("Please, update your diary","diary_nearby")
		Else
			; Quick press - normal behavior (target or closest)
			; Get the target NPC name for the notification
			ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
			Actor leader = None
			String targetName = ""
			If (crosshairRef && crosshairRef.GetBaseObject() as ActorBase)
				targetName = (crosshairRef.GetBaseObject() as ActorBase).GetName()
				leader = crosshairRef as Actor

			EndIf
			
			
		String[] _modes = new String[8]
		_modes[0] = "Write Diary"
		_modes[1] = "GATHER"
		_modes[2] = "FOLLOW_NPC"
		_modes[3] = "UPDATE_NPC"
		_modes[4] = "WAIT"
		_modes[5] = "FOLLOW"
		_modes[6] = "HALT"
		_modes[7] = "RENAME"
		
		String[] _label = new String[8]

		_label[0] = "Write Diary"
		_label[1] = "Gather friends"
		_label[2] = "Follow NPC"
		_label[3] = "Update NPC"
		_label[4] = "Wait Here"
		_label[5] = "Follow Me"
		_label[6] = "Stop All AI"
		_label[7] = "Add to BgL"

		if leader
			if leader.GetrelationShipRank(Game.GetPlayer()) < 0
				_label[4] = "Force Wait"
				_label[5] = "Force Follow"
			elseif leader.GetrelationShipRank(Game.GetPlayer()) < 1
				_label[5] = "Force Follow"
			endif
		endif
		
		int j=0
		UIExtensions.InitMenu("UIWheelMenu")
		while j < _modes.length
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
			UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
			j = j +1
		endwhile
			
		int ret = UIExtensions.OpenMenu("UIWheelMenu")
		;Debug.Trace("Option " + ret + " selectioned")
		String currentMode = _modes[ret]
		_currentModeIndex = ret
		; Store mode index for spell system sync
		Debug.trace("[CHIM] Wheel mode "+currentMode)
		if ( currentMode ==  "Write Diary")
		
			If (targetName != "")
				; Has a target - send diary request to specific actor
				Actor targetActor = crosshairRef as Actor
				If (targetActor)
					Debug.Notification("[CHIM] " + targetName + " is writing diary entry")
					AIAgentFunctions.requestMessageForActor("Please, update your diary","diary", targetActor.GetDisplayName())
				Else
					Debug.Notification("[CHIM] You must look at a target to generate a Diary Entry.")
				EndIf
			EndIf
		ElseIf ( currentMode ==  "GATHER")
			AIAgentAIMind.GatherAround();
			
		ElseIf ( currentMode ==  "FOLLOW_NPC")
			If (leader)
				if (!followingHerika)
					followingHerika=true;
					Actor player=Game.GetPlayer()
					if (true)	
						Game.SetPlayerAiDriven(true)
						currentPlayerFollowTarget = leader;
						float offsetCustomX=0
						float offsetCustomZ=150
						Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
						player.TranslateToRef(leader,100)
						RegisterForSingleUpdate(1.0)
						Debug.Notification("[CHIM] "+player.GetDisplayName()+" is following "+leader.GetDisplayName())
					endif
				else
					Actor player=Game.GetPlayer()
					player.ClearKeepOffsetFromActor();
					Game.SetPlayerAiDriven(false)
					Game.EnablePlayerControls()
					followingHerika=false;
				endif
			Else
				Debug.Notification("[CHIM] You must look at a target to use this")
			EndIf
			
		ElseIf ( currentMode ==  "UPDATE_NPC")
			If (leader)
				Debug.Trace("[CHIM] Updating dynamic profile for "+leader.GetDisplayName());
				AIAgentFunctions.logMessage(leader.GetDisplayName(),"updateprofiles_batch_async")
			Else
				Debug.Notification("[CHIM] You must look at a target to use this")
			EndIf
			
		elseif (currentMode == "WAIT")
				Actor targetActor = crosshairRef as Actor
				If (targetActor)
					AIagentAIMind.StartWait(leader)
				else
					Debug.Notification("[CHIM] You must look at a target to use this")
				endif
				return		
		elseif (currentMode == "FOLLOW")
			Actor targetActor = crosshairRef as Actor
			If (targetActor)
				AIagentAIMind.Follow(leader,Game.GetPlayer())
			else
				Debug.Notification("[CHIM] You must look at a target to use this")
			endif
			return
		elseif (currentMode == "HALT")
			Debug.Notification("[CHIM] Stopping AI actions")
			ObjectReference crosshairRef2 = Game.GetCurrentCrosshairRef()
			Actor crActor = crosshairRef2 as Actor
			if (crActor) 
				AIAgentAIMind.StopCurrent(crActor)
			else	
				Actor[] actors=AIAgentFunctions.findAllNearbyAgents()
				int i = 0
				while i < actors.Length
					Actor akActor = actors[i]
					Debug.Trace("[CHIM] Stopping actor: " + akActor)
					AIAgentAIMind.StopCurrent(akActor)
					i += 1
				endWhile
			endif
			return
		elseif (currentMode == "RENAME")
			If (leader)
				string originalname = leader.GetDisplayName()
				Debug.trace("[CHIM] Wheel originalname "+originalname)

				UIMenuBase menus=UIExtensions.GetMenu("UITextEntryMenu")
				string savedName=StorageUtil.GetStringValue(leader, "RenamedBuffer",leader.GetDisplayName());
				if savedName != "None"
					UIExtensions.SetMenuPropertyString("UITextEntryMenu","text",savedName)
				else
					UIExtensions.SetMenuPropertyString("UITextEntryMenu","text",originalname)
				endif
				Debug.trace("[CHIM] Wheel savedName "+savedName)

				UIExtensions.OpenMenu("UITextEntryMenu")
				string messageText = UIExtensions.GetMenuResultString("UITextEntryMenu")
				
				StorageUtil.SetStringValue(leader, "RenamedBuffer",None);

				UIExtensions.SetMenuPropertyString("UITextEntryMenu","text","")
				if (messageText != "")
					AIAgentFunctions.logMessage("chim_renamenpc@"+originalname+"@"+messageText+"@"+leader.GetFormId(),"setconf")
					StorageUtil.SetStringValue(leader,"forcedName",messageText)
				endif
			Else
				Debug.Notification("[CHIM] You must look at a target to use this")
			EndIf
			return				
		else
			Debug.Notification("[CHIM] Error")
		EndIf
		EndIf
	EndIf
	
	 If(keyCode == _currentGodmodeKey)
	
	String[] _modes = new String[8]
	_modes[0] = "STANDARD"
	_modes[1] = "WHISPER"
	_modes[2] = "DIRECTOR"
	_modes[3] = "SPAWN"
	_modes[4] = "CHEATMODE"
	_modes[5] = "AUTOCHAT"
	_modes[6] = "INJECTION_LOG"
	_modes[7] = "INJECTION_CHAT"
	
	String[] _label = new String[8]

	_label[0] = "Standard Chat"
	_label[1] = "Whisper Chat"
	_label[2] = "Director Mode"
	_label[3] = "Spawn NPC"
	_label[4] = "Cheat Mode"
	_label[5] = "Auto Chat"
	_label[6] = "Inject Event"
	_label[7] = "Inject & Chat"
			
		If (holdTime < 0.5) 
			; Quick press - Open wheel menu
			int j=0
			UIExtensions.InitMenu("UIWheelMenu")
			while j < _modes.length
				UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
				UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
				UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
				j = j +1
			endwhile
			
			int ret = UIExtensions.OpenMenu("UIWheelMenu")
			;Debug.Trace("Option " + ret + " selectioned")
			String currentMode = _modes[ret]
			_currentModeIndex = ret
			; Store mode index for spell system sync
			StorageUtil.SetIntValue(None, "AIAgent_CurrentModeIndex", _currentModeIndex)
			AIAgentFunctions.logMessage("chim_mode@"+currentMode,"setconf")
		else
			; Hold down - Cycle mode manually
			; Get current mode index from storage for consistency with spell system
			_currentModeIndex = StorageUtil.GetIntValue(None, "AIAgent_CurrentModeIndex", 0)
			_currentModeIndex += 1
			if _currentModeIndex >= _modes.Length
				_currentModeIndex = 0
			endif
			; Store updated mode index
			StorageUtil.SetIntValue(None, "AIAgent_CurrentModeIndex", _currentModeIndex)

			String currentMode = _modes[_currentModeIndex]
			Debug.Notification("Changed to mode "+currentMode)
			AIAgentFunctions.logMessage("chim_mode@"+currentMode,"setconf")
		endif
		
		if (_currentModeIndex==1)
			Debug.Trace("[CHIM] Enabling intimacy bubble effect: saving settings: "+mdi+","+mdo);
			AIAgentFunctions.setConf("_max_distance_inside",256,256,256);
			AIAgentFunctions.setConf("_max_distance_outside",256,256,256);
		else
			Debug.Trace("[CHIM] Disabling intimacy bubble effect: saving settings: "+mdi+","+mdo);
			AIAgentFunctions.setConf("_max_distance_inside",mdi,mdi as int,mdi as string);
			AIAgentFunctions.setConf("_max_distance_outside",mdo,mdo as int,mdo as string);
		endif
	
	EndIf
EndEvent

Event OnKeyDown(int keyCode)
   
  If(keyCode == _currentKey)
	; Text menu entry
	If !SafeProcess()
      Return
    EndIf
	
    UIExtensions.OpenMenu("UITextEntryMenu")
    string messageText = UIExtensions.GetMenuResultString("UITextEntryMenu")
	
	If messageText != ""
		if (Input.IsKeyPressed(29))	; Left Shift
			Debug.Trace("[CHIM] Shift modifier, will cast intimacy bubble");
			IntimacySpell.cast(Game.GetPlayer())
			
		endif;
		AIAgentFunctions.sendMessage(messageText,"")
		
		
    EndIf
  EndIf
   If(keyCode == _currentKeyVoice)
   
	if (UI.IsMenuOpen("Book Menu"))
		;Debug.Notification("[CHIM] lazy reader...");
		AIAgentFunctions.sendMessage("Please, summarize this book i've just found.","chatnf_book")
	elseif SafeProcess()
		int externalSTTactive=StorageUtil.GetIntValue(None, "AIAgentWebSockeSTT");
		if (externalSTTactive>0)
			AIAgentSTTExternal.recordSoundEx(_currentKeyVoice)
		else
			AIAgentFunctions.recordSoundEx(_currentKeyVoice)
		endif
        
		;WebSocketSTT.StartRecordVoice(_currentKeyVoice);
		Debug.Notification("[CHIM] recording....");
	endif
  EndIf
  If(keyCode == _currentFollowKey)
  
	if (UI.IsMenuOpen("Book Menu"))
		;Debug.Notification("[CHIM] lazy reader...");
		AIAgentFunctions.sendMessage("Please, summarize this book i've just found.","chatnf_book")
	else
		If !SafeProcess()
		  Return
		EndIf

		; Lets use this for more things
		
		Actor leader = Game.GetCurrentCrosshairRef() as Actor
		
		if (leader) ; Pointing to NPC
			String[] _modes = new String[4]
			_modes[0] = "1"
			_modes[1] = "2"
			_modes[2] = "3"
			_modes[3] = "4"
			
			String[] _label = new String[4]

			_label[0] = "Profile 1"
			_label[1] = "Profile 2"
			_label[2] = "Profile 3"
			_label[3] = "Profile 4"
			
			UIExtensions.InitMenu("UIWheelMenu")

			int j = 0
			while j < _modes.length
				UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
				UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
				UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
				j = j +1
			endwhile
			
			int ret = UIExtensions.OpenMenu("UIWheelMenu")
			String currentMode = _modes[ret]

			if (currentMode == "1")
				AIAgentFunctions.logMessageForActor("1","core_profile_assign",leader.GetDisplayName())
				return
			elseif (currentMode == "2")
				AIAgentFunctions.logMessageForActor("2","core_profile_assign",leader.GetDisplayName())
				return
			elseif (currentMode == "3")
				AIAgentFunctions.logMessageForActor("3","core_profile_assign",leader.GetDisplayName())
				return
			elseif (currentMode == "4")
				AIAgentFunctions.logMessageForActor("4","core_profile_assign",leader.GetDisplayName())
				return	
			else
				return
			endif

		else 
			String[] _modes = new String[5]
			_modes[0] = "1"
			_modes[1] = "2"
			_modes[2] = "3"
			_modes[3] = "4"
			_modes[4] = "5"
			
			
			String[] _label = new String[5]

			_label[0] = "Standard LLM"
			_label[1] = "Fast LLM"
			_label[2] = "Powerful LLM"
			_label[3] = "Experimental LLM"
			_label[4] = "Focus Chat"
		
			
			UIExtensions.InitMenu("UIWheelMenu")

			int j = 0
			int retFnc
			while j < _modes.length
				UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
				UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
				UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
				j = j +1
			endwhile
			
			int ret = UIExtensions.OpenMenu("UIWheelMenu")
			String currentMode = _modes[ret]

			if (currentMode == "1")
				retFnc=AIAgentFunctions.logMessage("chim_profile_model@1","setconf")
				return
			elseif (currentMode == "2")
				retFnc=AIAgentFunctions.logMessage("chim_profile_model@2","setconf")
				return
			elseif (currentMode == "3")
				retFnc=AIAgentFunctions.logMessage("chim_profile_model@3","setconf")
				return
			elseif (currentMode == "4")
				retFnc=AIAgentFunctions.logMessage("chim_profile_model@4","setconf")
				return	
			elseif (currentMode == "5")
				retFnc=AIAgentFunctions.logMessage("chim_context_mode@1","setconf")
				return
			else
				return
			endif
		
		endif;

		
		
		if (!followingHerika)
			followingHerika=true;
			
			Actor player=Game.GetPlayer()
			;if (!player.IsOnMount()) 
			if (true)	
			
				Game.SetPlayerAiDriven(true)
				
								
				
				if (!leader)
					leader = AIAgentFunctions.getClosestAgent()
				EndIf	
				
				currentPlayerFollowTarget = leader;
				
				float offsetCustomX=0
				float offsetCustomZ=150
				;player.ForceActorValue("SpeedMult",leader.GetActorValue("SpeedMult"));
				Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
				;Game.GetPlayer().SetLookAt(leader,true)
				;float zOffset = Game.GetPlayer().GetHeadingAngle(leader)
				;Game.GetPlayer().SetAngle(leader.GetAngleX(), leader.GetAngleY(), leader.GetAngleZ() + zOffset)

				;player.KeepOffsetFromActor(leader, afOffsetX = offsetCustomX, afOffsetY =  0, afOffsetZ = offsetCustomZ, afOffsetAngleZ=0, afCatchUpRadius = 1350, afFollowRadius = 150)
				player.TranslateToRef(leader,100)
				RegisterForSingleUpdate(1.0)
				Debug.Notification("[CHIM] "+player.GetDisplayName()+" is following "+leader.GetDisplayName())
			else
				
				Actor horse=PO3_SKSEFunctions.GetMount(player)
				currentPlayerHorse = horse 
				
				if (!leader)
					leader = AIAgentFunctions.getClosestAgent()
				EndIf	
				
				currentPlayerFollowTarget = leader;
				
				player.PathToReference(leader, 1)

				
				;player.setVehicle(currentPlayerHorse)
				;Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
				;Utility.Wait(1)
				;player.KeepOffsetFromActor(leader, afOffsetX = offsetCustomX, afOffsetY =  0, afOffsetZ = offsetCustomZ, afOffsetAngleZ=0, afCatchUpRadius = 1350, afFollowRadius = 100)
				;RegisterForSingleUpdate(3.0)
				
				Debug.Notification("[CHIM] "+player.GetDisplayName()+" is horse-following "+leader.GetDisplayName())
			
			endif
		
			
		else
			Actor player=Game.GetPlayer()
			player.ClearKeepOffsetFromActor();
			Game.SetPlayerAiDriven(false)
			Game.EnablePlayerControls()
			followingHerika=false;
			
		endif
	endif
  EndIf
  If(keyCode == _currentDiaryKey)
	If !SafeProcess()
		Return
	EndIf
	; Just track that the diary key was pressed - actual logic happens in OnKeyUp
	_diaryKeyPressed = true
  EndIf
  If(keyCode == _currentCModelKey)
	If Utility.IsInMenuMode() && SafeProcess(true)
		AIAgentFunctions.logMessage("Model change requested","togglemodel")
	ElseIf SafeProcess()
		Actor target=AIAgentFunctions.getClosestAgent()
		AIAgentFunctions.logMessageForActor("Model change requested","togglemodel",target.GetDisplayName())
	EndIf
  EndIf
  
  If(keyCode == _currentCSoulgaze)
	If !SafeProcess()
		Return
	EndIf
	
	String[] _modes = new String[4]
	_modes[0] = "1"
	_modes[1] = "2"
	_modes[2] = "3"
	_modes[3] = "4"
			
	String[] _label = new String[4]

	_label[0] = "Soulgaze"
	_label[1] = "NPC Photo Zoomed"
	_label[2] = "NPC Photo"
	_label[3] = "Screenshot Upload"

	UIExtensions.InitMenu("UIWheelMenu")

	int j = 0
	while j < _modes.length
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
	j = j +1
	endwhile
			
	int ret = UIExtensions.OpenMenu("UIWheelMenu")
	String currentMode = _modes[ret]

	if (currentMode == "1")
		AIAgentSoulGazeEffect.Soulgaze(_nativeSoulGaze);
		return
	elseif (currentMode == "2")
		AIAgentSoulGazeEffect.SendProfilePicture(_nativeSoulGaze,true);
		return
	elseif (currentMode == "3")
		AIAgentSoulGazeEffect.SendProfilePicture(_nativeSoulGaze,false);
		return	
	elseif (currentMode == "4")
		AIAgentSoulGazeEffect.JustUpload(_nativeSoulGaze);
		return	
	endif
			
	
  EndIf
  
  If(keyCode == _currentCtl)
	If !SafeProcess()
		Return
	EndIf
	
	ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
	
	If (crosshairRef)
		Actor targetActor = crosshairRef as Actor
		if (targetActor)
			Debug.Trace("[CHIM] NPC under cursor: "+targetActor.GetDisplayName())
			AIAgentFunctions.setDrivenByAIA(targetActor,false);
		else
			Debug.Trace("[CHIM] NO NPC under cursor")
		endif
	else 
		AIAgentFunctions.setDrivenByAI();
	EndIf
	
	
  EndIf
  
 
  
  If(keyCode == _currentOpenMicMuteKey)
	If !SafeProcess()
		Return
	EndIf
	
	setConf("_openmic_toggle_mute",1);
	
  EndIf
  
  If(keyCode == _currentHaltKey)
	Debug.Notification("[CHIM] Stopping AI actions")
	; Send halt command directly to all AI agents without server round-trip
	;AIAgentFunctions.logMessage("Halt@", "command")
	
	ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
	Actor crActor = crosshairRef as Actor;
	if (crActor) 
		AIAgentAIMind.StopCurrent(crActor);
	else	
		Actor[] actors=AIAgentFunctions.findAllNearbyAgents();
		int i = 0
		while i < actors.Length
			Actor akActor = actors[i]
			; Do something with akActor, for example:
			Debug.Trace("Found actor for StopCurrent" + akActor)
			AIAgentAIMind.StopCurrent(akActor);

		i += 1
		endWhile
	endif;
	
  EndIf
  
  If(keyCode == _currentMasterWheel)
	If !SafeProcess()
		Return
	EndIf
	
	String[] _modes = new String[4]
	_modes[0] = "ROLEPLAY"
	_modes[1] = "SETTINGS"
	_modes[2] = "MODE"
	_modes[3] = "SOULGAZE"
			
	String[] _label = new String[4]

	_label[0] = "Roleplay Wheel"
	_label[1] = "Settings Wheel"
	_label[2] = "Mode Wheel"
	_label[3] = "Soulgaze Wheel"

	UIExtensions.InitMenu("UIWheelMenu")

	int j = 0
	while j < _modes.length
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
		j = j +1
	endwhile
			
	int ret = UIExtensions.OpenMenu("UIWheelMenu")
	String currentMode = _modes[ret]

	if (currentMode == "ROLEPLAY")
		; Open the roleplay wheel directly
		OpenRoleplayWheel()
		return
	elseif (currentMode == "SETTINGS")
		; Open the settings wheel directly
		OpenSettingsWheel()
		return
	elseif (currentMode == "MODE")
		; Open the mode wheel directly
		OpenModeWheel()
		return	
	elseif (currentMode == "SOULGAZE")
		; Open the soulgaze wheel directly
		OpenSoulgazeWheel()
		return	
	endif
	
  EndIf
  
EndEvent

Event OnUpdate()
    ;Debug.Notification("Updating...")
    If(followingHerika)
		
		float offsetCustomX=0
		float offsetCustomZ=150
		Actor leader = currentPlayerFollowTarget
		;Game.GetPlayer().ClearKeepOffsetFromActor()
		;Game.GetPlayer().SetLookAt(leader,true)
		;Game.GetPlayer().KeepOffsetFromActor(leader, afOffsetX = offsetCustomX, afOffsetY =  0, afOffsetZ = offsetCustomZ, afOffsetAngleZ=0, afCatchUpRadius = 350, afFollowRadius = 150)
		Game.GetPlayer().TranslateToRef(leader,100.0)
		RegisterForSingleUpdate(3.0)
    EndIf
Endevent

Function removeBinding(int keycode) 
	UnregisterForKey(keycode)
EndFunction

Function doBinding(int keycode) 
	_currentKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding2(int keycode) 
	
	_currentKeyVoice=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding3(int keycode) 
	
	_currentFollowKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding4(int keycode) 
	
	_currentDiaryKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding5(int keycode) 
	
	_currentCModelKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding6(int keycode) 
	
	_currentCSoulgaze=keycode
	RegisterForKey(keycode)

EndFunction

Function doBinding7(int keycode) 
	
	_currentCtl=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding8(int keycode) 
	
	_currentGodmodeKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding9(int keycode) 
	
	_currentOpenMicMuteKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding10(int keycode) 
	
	_currentHaltKey=keycode
	RegisterForKey(keycode)
EndFunction

Function doBinding11(int keycode) 
	
	_currentMasterWheel=keycode
	RegisterForKey(keycode)
EndFunction


bool Function setNewActionMode( int mode) 
	AIAgentFunctions.setNewActionMode(mode)
	bool a;To disable Wrnings
	AIAgentFunctions.setConf("_sgmode",0,_nativeSoulGaze,"");
	

	; Removed action mode notifications - no longer displayed on save load
	
	InitTSE();	
	a=thirdPartyInit();	
EndFunction

bool Function setVoiceType( int mode) 
	;
EndFunction

int Function getSoulgazeModeNative() 
	return _nativeSoulGaze
EndFunction

bool Function setSoulgazeModeNative(int mode)
	AIAgentFunctions.setConf("_sgmode",0,mode,"");
	_nativeSoulGaze=mode
EndFunction

bool Function setConf(String code,float value) 
	
	AIAgentFunctions.setConf(code,value,0,"")
	
EndFunction


bool Function thirdPartyInit()
	Debug.Trace("[CHIM] thirdPartyInit")
	UnRegisterForModEvent("CHIM_CommandReceivedInternal")
	RegisterForModEvent("CHIM_CommandReceivedInternal", "CommandManager")

	
EndFunction


Function InitTSE() 
	; Removed player script initialized notification - no longer displayed on save load
    RegisterForTrackedStatsEvent() ; Before we can use OnTrackedStatsEvent we must register.
endFunction


Event OnPlayerFastTravelEnd(float afTravelGameTimeHours)
	AIAgentFunctions.logMessage("The party traveled for "+afTravelGameTimeHours+" hours","infoaction")
  
endEvent

Event OnTrackedStatsEvent(string asStatFilter, int aiStatValue)
	AIAgentFunctions.logMessage(asStatFilter+"@"+aiStatValue,"setconf")
	Actor player = Game.GetPlayer()
	if (asStatFilter == "Level Increases") 
		int retFnc=AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" levels up to "+aiStatValue,"rpg_lvlup")
    
    elseif (asStatFilter == "Shouts Learned") 
		int retFnc=AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" learns a new shout","rpg_shout")
		
	elseif (asStatFilter == "Dragon Souls Collected") 
		int retFnc=AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" absorbs a dragon soul.","rpg_soul")
                
	elseif (asStatFilter == "Words of Power Learned") 
		int retFnc=AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" learns a new Word of Power.","rpg_word")
	else
		int retFnc=AIAgentFunctions.logMessage(asStatFilter+"@"+aiStatValue,"setconf")
	endif
endEvent

Bool Function SafeProcess(bool allowMenuMode = false)
	If (allowMenuMode || !Utility.IsInMenuMode()) \
	&& (!UI.IsMenuOpen("Console")) \
	&& (!UI.IsMenuOpen("Crafting Menu")) \
	&& (!UI.IsMenuOpen("MessageBoxMenu")) \
	&& (!UI.IsMenuOpen("ContainerMenu")) \
	&& (!UI.IsTextInputEnabled()) \
	&& (!UI.IsMenuOpen("LootMenu")) \
	&& (!UI.IsMenuOpen("RaceSex Menu")) \
	&& (!UI.IsMenuOpen("listmenu"))
		;IsInMenuMode to block when game is paused with menus open
		;Console to block when console is open - console does not trigger IsInMenuMode and thus needs its own check
		;Crafting Menu to block when crafting menus are open - game is not paused so IsInMenuMode does not work
		;MessageBoxMenu to block when message boxes are open - while they pause the game, they do not trigger IsInMenuMode
		;ContainerMenu to block when containers are accessed - while they pause the game, they do not trigger IsInMenuMode
		;IsTextInputEnabled to block when editable text fields are open
		;LootMenu to block when looting - when used with Quick Loot
		;RaceSex Menu to block during character creation - when used with RaceMenu
		;listmenu to block during list selection - comes from UIExtensions
		Return True
	Else
		Return False
	EndIf
EndFunction

Function sendAllLocations() global

	Form[] allLocations=PO3_SKSEFunctions.GetAllForms(104)
	Debug.Trace("Total "+allLocations.Length);
	int lengthA=allLocations.Length
	int i=0;
	while i < lengthA
		Form j=allLocations[i] as Form
		Location curr=j as Location
		Location currParent=PO3_SKSEFunctions.GetParentLocation(curr)
		Location currParent2lvl=PO3_SKSEFunctions.GetParentLocation(currParent)
		ObjectReference destMarker= AIAgentFunctions.getWorldLocationMarkerFor(curr);
		if destMarker
			Debug.Trace("Adding Location "+j.GetName() + " / "+currParent.GetName());
			int retFnc=AIAgentFunctions.logMessage(j.GetName()+"/"+j.GetFormId()+"/"+currParent.GetName()+"/"+currParent2lvl.GetName(),"util_location_name")
		endif
		i=i+1
	endwhile
	return
EndFunction

Event CommandManager(String npcname,String  command, String parameter)
	
	if (command=="AnimationEvent")
		Actor npc=AIAgentFunctions.getAgentByName(npcname);
		;if (actor->IsInCombat() || actor->IsOnMount() || actor->IsHorse() || actor->IsPlayer() ) {
		if (npc.IsInCombat() || npc.IsOnMount() || npc.IsFlying() || npc.IsUnconscious() || npc == Game.GetPlayer()  )
			Debug.Trace("[CHIM] [ANIMATION aborted]")
		else
			OnAnimationEvent(npc,parameter)
		endif;
		
	endif
	

EndEvent

Function OnAnimationEvent(ObjectReference akSource, String asEventName)
	Debug.Trace("[CHIM] Sending animation event "+asEventName+" on "+akSource.GetName());
	Debug.SendAnimationEvent(akSource,asEventName)
EndFunction

; Helper functions to open wheels from Master Wheel
Function OpenRoleplayWheel()
	ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
	Actor leader = None
	String targetName = ""
	If (crosshairRef && crosshairRef.GetBaseObject() as ActorBase)
		targetName = (crosshairRef.GetBaseObject() as ActorBase).GetName()
		leader = crosshairRef as Actor
	EndIf
	
	String[] _modes = new String[8]
	_modes[0] = "Write Diary"
	_modes[1] = "GATHER"
	_modes[2] = "FOLLOW_NPC"
	_modes[3] = "UPDATE_NPC"
	_modes[4] = "WAIT"
	_modes[5] = "FOLLOW"
	_modes[6] = "HALT"
	_modes[7] = "RENAME"
	
	String[] _label = new String[8]
	_label[0] = "Write Diary"
	_label[1] = "Gather friends"
	_label[2] = "Follow NPC"
	_label[3] = "Update NPC"
	_label[4] = "Wait Here"
	_label[5] = "Follow Me"
	_label[6] = "Stop All AI"
	_label[7] = "Add to BgL"

	if leader
		if leader.GetrelationShipRank(Game.GetPlayer()) < 0
			_label[4] = "Force Wait"
			_label[5] = "Force Follow"
		elseif leader.GetrelationShipRank(Game.GetPlayer()) < 1
			_label[5] = "Force Follow"
		endif
	endif
	
	int j=0
	UIExtensions.InitMenu("UIWheelMenu")
	while j < _modes.length
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
		j = j +1
	endwhile
		
	int ret = UIExtensions.OpenMenu("UIWheelMenu")
	String currentMode = _modes[ret]
	
	if ( currentMode ==  "Write Diary")
		If (targetName != "")
			Actor targetActor = crosshairRef as Actor
			If (targetActor)
				Debug.Notification("[CHIM] " + targetName + " is writing diary entry")
				AIAgentFunctions.requestMessageForActor("Please, update your diary","diary", targetActor.GetDisplayName())
			Else
				Debug.Notification("[CHIM] You must look at a target to generate a Diary Entry.")
			EndIf
		EndIf
	ElseIf ( currentMode ==  "GATHER")
		AIAgentAIMind.GatherAround()
	ElseIf ( currentMode ==  "FOLLOW_NPC")
		If (leader)
			if (!followingHerika)
				followingHerika=true
				Actor player=Game.GetPlayer()
				Game.SetPlayerAiDriven(true)
				currentPlayerFollowTarget = leader
				Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
				player.TranslateToRef(leader,100)
				RegisterForSingleUpdate(1.0)
				Debug.Notification("[CHIM] "+player.GetDisplayName()+" is following "+leader.GetDisplayName())
			else
				Actor player=Game.GetPlayer()
				player.ClearKeepOffsetFromActor()
				Game.SetPlayerAiDriven(false)
				Game.EnablePlayerControls()
				followingHerika=false
			endif
		Else
			Debug.Notification("[CHIM] You must look at a target to use this")
		EndIf
	ElseIf ( currentMode ==  "UPDATE_NPC")
		If (leader)
			Debug.Trace("[CHIM] Updating dynamic profile for "+leader.GetDisplayName())
			AIAgentFunctions.logMessage(leader.GetDisplayName(),"updateprofiles_batch_async")
		Else
			Debug.Notification("[CHIM] You must look at a target to use this")
		EndIf
	elseif (currentMode == "WAIT")
		Actor targetActor = crosshairRef as Actor
		If (targetActor)
			AIagentAIMind.StartWait(leader)
		else
			Debug.Notification("[CHIM] You must look at a target to use this")
		endif
	elseif (currentMode == "FOLLOW")
		Actor targetActor = crosshairRef as Actor
		If (targetActor)
			AIagentAIMind.Follow(leader,Game.GetPlayer())
		else
			Debug.Notification("[CHIM] You must look at a target to use this")
		endif
	elseif (currentMode == "HALT")
		Debug.Notification("[CHIM] Stopping AI actions")
		ObjectReference crosshairRef2 = Game.GetCurrentCrosshairRef()
		Actor crActor = crosshairRef2 as Actor
		if (crActor) 
			AIAgentAIMind.StopCurrent(crActor)
		else	
			Actor[] actors=AIAgentFunctions.findAllNearbyAgents()
			int i = 0
			while i < actors.Length
				Actor akActor = actors[i]
				Debug.Trace("[CHIM] Stopping actor: " + akActor)
				AIAgentAIMind.StopCurrent(akActor)
				i += 1
			endWhile
		endif
	elseif (currentMode == "RENAME")
		If (leader)
			string originalname = leader.GetDisplayName()
			UIMenuBase menus=UIExtensions.GetMenu("UITextEntryMenu")
			string savedName=StorageUtil.GetStringValue(leader, "RenamedBuffer",leader.GetDisplayName())
			if savedName != "None"
				UIExtensions.SetMenuPropertyString("UITextEntryMenu","text",savedName)
			else
				UIExtensions.SetMenuPropertyString("UITextEntryMenu","text",originalname)
			endif
			UIExtensions.OpenMenu("UITextEntryMenu")
			string messageText = UIExtensions.GetMenuResultString("UITextEntryMenu")
			StorageUtil.SetStringValue(leader, "RenamedBuffer",None)
			UIExtensions.SetMenuPropertyString("UITextEntryMenu","text","")
			if (messageText != "")
				AIAgentFunctions.logMessage("chim_renamenpc@"+originalname+"@"+messageText+"@"+leader.GetFormId(),"setconf")
				StorageUtil.SetStringValue(leader,"forcedName",messageText)
				Debug.Notification("[CHIM] Added to Background Life. Save your game for changes to take effect.")
			endif
		Else
			Debug.Notification("[CHIM] You must look at a target to use this")
		EndIf
	EndIf
EndFunction

Function OpenSettingsWheel()
	Actor leader = Game.GetCurrentCrosshairRef() as Actor
	
	if (leader)
		String[] _modes = new String[4]
		_modes[0] = "1"
		_modes[1] = "2"
		_modes[2] = "3"
		_modes[3] = "4"
		
		String[] _label = new String[4]
		_label[0] = "Profile 1"
		_label[1] = "Profile 2"
		_label[2] = "Profile 3"
		_label[3] = "Profile 4"
		
		UIExtensions.InitMenu("UIWheelMenu")
		int j = 0
		while j < _modes.length
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
			UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
			j = j +1
		endwhile
		
		int ret = UIExtensions.OpenMenu("UIWheelMenu")
		String currentMode = _modes[ret]

		if (currentMode == "1")
			AIAgentFunctions.logMessageForActor("1","core_profile_assign",leader.GetDisplayName())
		elseif (currentMode == "2")
			AIAgentFunctions.logMessageForActor("2","core_profile_assign",leader.GetDisplayName())
		elseif (currentMode == "3")
			AIAgentFunctions.logMessageForActor("3","core_profile_assign",leader.GetDisplayName())
		elseif (currentMode == "4")
			AIAgentFunctions.logMessageForActor("4","core_profile_assign",leader.GetDisplayName())
		endif
	else
		String[] _modes = new String[5]
		_modes[0] = "1"
		_modes[1] = "2"
		_modes[2] = "3"
		_modes[3] = "4"
		_modes[4] = "5"
		
		String[] _label = new String[5]
		_label[0] = "Standard LLM"
		_label[1] = "Fast LLM"
		_label[2] = "Powerful LLM"
		_label[3] = "Experimental LLM"
		_label[4] = "Focus Chat"
		
		UIExtensions.InitMenu("UIWheelMenu")
		int j = 0
		int retFnc
		while j < _modes.length
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
			UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
			j = j +1
		endwhile
		
		int ret = UIExtensions.OpenMenu("UIWheelMenu")
		String currentMode = _modes[ret]

		if (currentMode == "1")
			retFnc=AIAgentFunctions.logMessage("chim_profile_model@1","setconf")
		elseif (currentMode == "2")
			retFnc=AIAgentFunctions.logMessage("chim_profile_model@2","setconf")
		elseif (currentMode == "3")
			retFnc=AIAgentFunctions.logMessage("chim_profile_model@3","setconf")
		elseif (currentMode == "4")
			retFnc=AIAgentFunctions.logMessage("chim_profile_model@4","setconf")
		elseif (currentMode == "5")
			retFnc=AIAgentFunctions.logMessage("chim_context_mode@1","setconf")
		endif
	endif
EndFunction

Function OpenModeWheel()
	String[] _modes = new String[8]
	_modes[0] = "STANDARD"
	_modes[1] = "WHISPER"
	_modes[2] = "DIRECTOR"
	_modes[3] = "SPAWN"
	_modes[4] = "CHEATMODE"
	_modes[5] = "AUTOCHAT"
	_modes[6] = "INJECTION_LOG"
	_modes[7] = "INJECTION_CHAT"
	
	String[] _label = new String[8]
	_label[0] = "Standard Chat"
	_label[1] = "Whisper Chat"
	_label[2] = "Director Mode"
	_label[3] = "Spawn NPC"
	_label[4] = "Cheat Mode"
	_label[5] = "Auto Chat"
	_label[6] = "Inject Event"
	_label[7] = "Inject & Chat"
		
	int j=0
	UIExtensions.InitMenu("UIWheelMenu")
	while j < _modes.length
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
		j = j +1
	endwhile
	
	int ret = UIExtensions.OpenMenu("UIWheelMenu")
	String currentMode = _modes[ret]
	_currentModeIndex = ret
	StorageUtil.SetIntValue(None, "AIAgent_CurrentModeIndex", _currentModeIndex)
	AIAgentFunctions.logMessage("chim_mode@"+currentMode,"setconf")
	
	if (_currentModeIndex==1)
		Debug.Trace("[CHIM] Enabling intimacy bubble effect: saving settings: "+mdi+","+mdo)
		AIAgentFunctions.setConf("_max_distance_inside",256,256,256)
		AIAgentFunctions.setConf("_max_distance_outside",256,256,256)
	else
		Debug.Trace("[CHIM] Disabling intimacy bubble effect: saving settings: "+mdi+","+mdo)
		AIAgentFunctions.setConf("_max_distance_inside",mdi,mdi as int,mdi as string)
		AIAgentFunctions.setConf("_max_distance_outside",mdo,mdo as int,mdo as string)
	endif
EndFunction

Function OpenSoulgazeWheel()
	String[] _modes = new String[4]
	_modes[0] = "1"
	_modes[1] = "2"
	_modes[2] = "3"
	_modes[3] = "4"
			
	String[] _label = new String[4]
	_label[0] = "Soulgaze"
	_label[1] = "NPC Photo Zoom"
	_label[2] = "NPC Photo"
	_label[3] = "Just Upload"

	UIExtensions.InitMenu("UIWheelMenu")

	int j = 0
	while j < _modes.length
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionLabelText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexString("UIWheelMenu","optionText",j,_label[j])
		UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu","optionEnabled",j,true)
		j = j +1
	endwhile
			
	int ret = UIExtensions.OpenMenu("UIWheelMenu")
	String currentMode = _modes[ret]

	if (currentMode == "1")
		AIAgentSoulGazeEffect.Soulgaze(_nativeSoulGaze)
	elseif (currentMode == "2")
		AIAgentSoulGazeEffect.SendProfilePicture(_nativeSoulGaze,true)
	elseif (currentMode == "3")
		AIAgentSoulGazeEffect.SendProfilePicture(_nativeSoulGaze,false)
	elseif (currentMode == "4")
		AIAgentSoulGazeEffect.JustUpload(_nativeSoulGaze)
	endif
EndFunction

