Scriptname AIAgentPapyrusFunctions extends Quest  


int			_currentKey = 0x52
int			_currentKeyVoice
int			_currentFollowKey
int			_currentDiaryKey
int			_currentCModelKey
int 		_currentCSoulgaze
int 		_currentCtl
bool		currentTTSStatus= false
bool		followingHerika= false

int		_nativeSoulGaze= 1



Actor	currentPlayerFollowTarget;
Actor	currentPlayerHorse;


Event OnInit()
	doBinding(_currentKey)
	
EndEvent

Event OnKeyUp(int keyCode, float holdTime)
	If(keyCode == _currentKeyVoice)
		if (!UI.IsMenuOpen("Book Menu"))
			AIAgentFunctions.stopRecording(_currentKeyVoice)
			Debug.Notification("[CHIM] Recording end");
		endif
	endif
EndEvent

Event OnKeyDown(int keyCode)
   
  If(keyCode == _currentKey)
  
	If Utility.IsInMenuMode()
      Return
    EndIf
	
    UIExtensions.OpenMenu("UITextEntryMenu")
    string messageText = UIExtensions.GetMenuResultString("UITextEntryMenu")
	
	If messageText != ""
        AIAgentFunctions.sendMessage(messageText,"")
		
		
    EndIf
  EndIf
   If(keyCode == _currentKeyVoice)
   
	if (UI.IsMenuOpen("Book Menu"))
		;Debug.Notification("[CHIM] lazy reader...");
		AIAgentFunctions.sendMessage("Please, summarize this book i've just found.","chatnf_book")
	else
        AIAgentFunctions.recordSoundEx(_currentKeyVoice)
		Debug.Notification("[CHIM] recording....");
	endif
  EndIf
  If(keyCode == _currentFollowKey)
  
	if (UI.IsMenuOpen("Book Menu"))
		;Debug.Notification("[CHIM] lazy reader...");
		AIAgentFunctions.sendMessage("Please, summarize this book i've just found.","chatnf_book")
	else
		If Utility.IsInMenuMode()
		  Return
		EndIf

		if (true)	; this is for test purposes
			if (!followingHerika)
				followingHerika=true;
				Debug.Notification("[CHIM] Everyone added...");
				AIAgentFunctions.testAddAllNPCAround()
			else
				Debug.Notification("[CHIM] Everyone removed..");
				followingHerika=false;
				AIAgentFunctions.testRemoveAll()
			endif
			return;
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
	If Utility.IsInMenuMode()
		Return
	EndIf
	AIAgentFunctions.sendMessage("Please, update your diary","diary")
  EndIf
  If(keyCode == _currentCModelKey)
	If Utility.IsInMenuMode()
		AIAgentFunctions.logMessage("Model change requested","togglemodel")
		Return
	EndIf
	Actor target=AIAgentFunctions.getClosestAgent()
	AIAgentFunctions.logMessageForActor("Model change requested","togglemodel",target.GetDisplayName())
  EndIf
  
  If(keyCode == _currentCSoulgaze)
	If Utility.IsInMenuMode()
		Return
	EndIf
	
	AIAgentSoulGazeEffect.Soulgaze(_nativeSoulGaze);
	
  EndIf
  
  If(keyCode == _currentCtl)
	If Utility.IsInMenuMode()
		Return
	EndIf
	
	AIAgentFunctions.setDrivenByAI();
	
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

bool Function removeBinding(int keycode) 
	UnregisterForKey(keycode)
EndFunction

bool Function doBinding(int keycode) 
	_currentKey=keycode
	RegisterForKey(keycode)
EndFunction

bool Function doBinding2(int keycode) 
	
	_currentKeyVoice=keycode
	RegisterForKey(keycode)
EndFunction

bool Function doBinding3(int keycode) 
	
	_currentFollowKey=keycode
	RegisterForKey(keycode)
EndFunction

bool Function doBinding4(int keycode) 
	
	_currentDiaryKey=keycode
	RegisterForKey(keycode)
EndFunction

bool Function doBinding5(int keycode) 
	
	_currentCModelKey=keycode
	RegisterForKey(keycode)
EndFunction

bool Function doBinding6(int keycode) 
	
	_currentCSoulgaze=keycode
	RegisterForKey(keycode)

EndFunction

bool Function doBinding7(int keycode) 
	
	_currentCtl=keycode
	RegisterForKey(keycode)
EndFunction


bool Function setNewActionMode( int mode) 
	AIAgentFunctions.setNewActionMode(mode)

	AIAgentFunctions.setConf("_sgmode",0,_nativeSoulGaze,"");
	

	if (mode==0)
		Debug.Notification("[CHIM] Action mode is off");
	else
		Debug.Notification("[CHIM] Action mode is on");
	endif
	
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
	
    
	
EndFunction


Function InitTSE() 
	Debug.Notification("[CHIM] Player script initialized")
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


