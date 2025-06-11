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
bool property _currentGodmodeStatus  auto
bool		currentTTSStatus= false
bool		followingHerika= false
bool		_diaryKeyPressed= false ; Track if diary key is currently pressed

int		_nativeSoulGaze= 1

Spell Property IntimacySpell  Auto  


Actor	currentPlayerFollowTarget;
Actor	currentPlayerHorse;


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
		
		; If held for more than 0.5 seconds, trigger all followers
		If (holdTime >= 0.5)
			Debug.Notification("[CHIM] Diary: All followers are writing entries...")
			AIAgentFunctions.sendMessage("Please, update your diary","diary_followers")
		Else
			; Quick press - normal behavior (target or closest)
			; Get the target NPC name for the notification
			ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
			String targetName = ""
			If (crosshairRef && crosshairRef.GetBaseObject() as ActorBase)
				targetName = (crosshairRef.GetBaseObject() as ActorBase).GetName()
			EndIf
			
			If (targetName != "")
				Debug.Notification("[CHIM] " + targetName + " is writing diary entry")
			Else
				Debug.Notification("[CHIM] Writing diary entry...")
			EndIf
			AIAgentFunctions.sendMessage("Please, update your diary","diary")
		EndIf
	EndIf
EndEvent

Event OnKeyDown(int keyCode)
   
  If(keyCode == _currentKey)
  
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

		
		if (false) 
			Debug.Notification("[CHIM] Sending all actors names");
			Form[] allActors=PO3_SKSEFunctions.GetAllForms(43)
			Debug.Trace("Total "+allActors.Length);
			int lengthA=allActors.Length
			int i=0;
			while i < lengthA
				Form j=allActors[i] as Form
				Debug.Trace("Adding NPC "+j.GetName());
				AIAgentFunctions.logMessage(j.GetName(),"util_npcname")
				i=i+1
			endwhile
			return
		endif
		
		
		if (!followingHerika)
			followingHerika=true;
			
			Actor player=Game.GetPlayer()
			;if (!player.IsOnMount()) 
			if (true)	
			
				Game.SetPlayerAiDriven(true)
				Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
				Package FollowPackage = Game.GetFormFromFile(0x01BC25, "AIAgent.esp") as Package 

								
				Actor leader = Game.GetCurrentCrosshairRef() as Actor
				if (!leader)
					leader = AIAgentFunctions.getClosestAgent()
				EndIf	
				
				currentPlayerFollowTarget = leader;
				player.SetFactionRank(FollowFaction,1)
				PO3_SKSEFunctions.SetLinkedRef(player,leader)
				ActorUtil.AddPackageOverride(player, FollowPackage, 100, 0)
				player.EvaluatePackage()
				;player.ForceActorValue("SpeedMult",leader.GetActorValue("SpeedMult"));
				Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
				Debug.Notification("[CHIM] "+player.GetDisplayName()+" is following "+leader.GetDisplayName())
			else
				
				Actor horse=PO3_SKSEFunctions.GetMount(player)
				currentPlayerHorse = horse 
				Actor leader = Game.GetCurrentCrosshairRef() as Actor
				if (!leader)
					leader = AIAgentFunctions.getClosestAgent()
				EndIf	
				
				currentPlayerFollowTarget = leader;
				
				player.PathToReference(leader, 1)

				;float offsetCustomX=100
				;float offsetCustomZ=50
				;player.setVehicle(currentPlayerHorse)
				;Game.DisablePlayerControls(1, 1, 0, 0, 1, 0, 1)
				;Utility.Wait(1)
				;player.KeepOffsetFromActor(leader, afOffsetX = offsetCustomX, afOffsetY =  0, afOffsetZ = offsetCustomZ, afOffsetAngleZ=0, afCatchUpRadius = 1350, afFollowRadius = 100)
				;RegisterForSingleUpdate(3.0)
				
				Debug.Notification("[CHIM] "+player.GetDisplayName()+" is horse-following "+leader.GetDisplayName())
			
			endif
		
			
		else
			Actor player=Game.GetPlayer()
			Faction FollowFaction=Game.GetFormFromFile(0x01BC24, "AIAgent.esp") as Faction 
			player.RemoveFromFaction(FollowFaction)
			AIAgentAIMind.ResetPackages(player);
			Debug.Notification("[CHIM] Player Unfollowing ");
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
	
	AIAgentSoulGazeEffect.Soulgaze(_nativeSoulGaze);
	
  EndIf
  
  If(keyCode == _currentCtl)
	If !SafeProcess()
		Return
	EndIf
	
	AIAgentFunctions.setDrivenByAI();
	
  EndIf
  
  If(keyCode == _currentGodmodeKey)
	_currentGodmodeStatus=!_currentGodmodeStatus
	if (_currentGodmodeStatus)
		setConf("_godmode",1);
	else
		setConf("_godmode",0);	
	endif
	
  EndIf
  
  If(keyCode == _currentOpenMicMuteKey)
	If !SafeProcess()
		Return
	EndIf
	
	setConf("_openmic_toggle_mute",1);
	
  EndIf
  
EndEvent

Event OnUpdate()
    ;Debug.Notification("Updating...")
    If(followingHerika)
		
		Actor  herika = currentPlayerFollowTarget
		int iCameraState = Game.GetCameraState()
		
		float offsetCustomX=-150
		float offsetCustomZ=-150

		if (herika.isRunning())
			offsetCustomX=0
			offsetCustomZ=100
		endif
			
		If(iCameraState == 0)
			Game.GetPlayer().ClearKeepOffsetFromActor()
			Game.GetPlayer().SetLookAt(herika,true)
			Utility.Wait(1)
			
		    currentPlayerHorse.KeepOffsetFromActor(herika, afOffsetX = offsetCustomX, afOffsetY =  0, afOffsetZ = offsetCustomZ, afOffsetAngleZ=0, afCatchUpRadius = 350, afFollowRadius = 0)
		else
		;Game.GetPlayer().SetLookAt(herika,true)
		;Utility.Wait(1)
			currentPlayerHorse.ClearKeepOffsetFromActor()
			
			Utility.Wait(1)
			
		    currentPlayerHorse.KeepOffsetFromActor(herika, afOffsetX = offsetCustomX, afOffsetY =  0, afOffsetZ = offsetCustomZ, afOffsetAngleZ=0, afCatchUpRadius = 350, afFollowRadius = 0)
		endif
	RegisterForSingleUpdate(10.0)
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


bool Function setNewActionMode( int mode) 
	AIAgentFunctions.setNewActionMode(mode)

	AIAgentFunctions.setConf("_sgmode",0,_nativeSoulGaze,"");
	

	; Removed action mode notifications - no longer displayed on save load
	
	InitTSE();	
	thirdPartyInit();	
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
		AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" levels up to "+aiStatValue,"rpg_lvlup")
    
    elseif (asStatFilter == "Shouts Learned") 
		AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" learns a new shout","rpg_shout")
		
	elseif (asStatFilter == "Dragon Souls Collected") 
		AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" absorbs a dragon soul.","rpg_soul")
                
	elseif (asStatFilter == "Words of Power Learned") 
		AIAgentFunctions.requestMessage("The Narrator: "+player.GetName()+" learns a new Word of Power.","rpg_word")
	else
		AIAgentFunctions.logMessage(asStatFilter+"@"+aiStatValue,"setconf")
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
		Debug.Trace("Adding Location "+j.GetName());
		AIAgentFunctions.logMessage(j.GetName()+"/"+j.GetFormId(),"util_location_name")
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

