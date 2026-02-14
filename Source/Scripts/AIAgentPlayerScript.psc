Scriptname AIAgentPlayerScript extends actor


Event OnPlayerFastTravelEnd(float afTravelGameTimeHours)

	Utility.wait(5);Give time to NPCs around to load
	AIAgentFunctions.logMessage("", "location")
	AIAgentFunctions.logMessage("The Narrator: The party has been travelling for "+afTravelGameTimeHours+" hours.", "infoaction")

	

EndEvent

Bool Function IsActorNakedVanilla(Actor who)
    Return !(who.WornHasKeyword(Game.GetFormFromFile(0x06C0EC, "Skyrim.esm") as Keyword) || who.WornHasKeyword(Game.GetFormFromFile(0x0A8657, "Skyrim.esm") as Keyword))
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if (IsActorNakedVanilla(Game.GetPlayer()))
		AIAgentFunctions.logMessage("player_naked@1","setconf")
	else
		AIAgentFunctions.logMessage("player_naked@0", "setconf")
	endIf
endEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	if (IsActorNakedVanilla(Game.GetPlayer()))
		AIAgentFunctions.logMessage("player_naked@1","setconf")
	else
		AIAgentFunctions.logMessage("player_naked@0", "setconf")
	endIf
endEvent

Event OnLocationChange(Location oldLoc,Location newLoc)
	Location currParentLvl1=PO3_SKSEFunctions.GetParentLocation(newLoc)
	Location currParentLvl2=PO3_SKSEFunctions.GetParentLocation(currParentLvl1)
	
	if (currParentLvl2 && currParentLvl2.getName() != "Tamriel" )
		AIAgentFunctions.logMessage(currParentLvl2.getName(), "region")
	elseif (currParentLvl1)
		AIAgentFunctions.logMessage(currParentLvl1.getName(), "region")
	elseif newLoc
		AIAgentFunctions.logMessage(newLoc.getName(), "region")
	endif;
	sendCellInfo(Game.GetPlayer().getParentCell(),newLoc,false)
endEvent

; DLL TESCellFullyLoadedEvent will take care
;  Event OnLoad()

	;  Cell currCell = Game.GetPlayer().getParentCell()
	;  Location currLoc = Game.GetPlayer().getCurrentLocation();
	;  Debug.Trace("[CHIM] AIAgentPlayerScript, cell <0x"+DecToHex(currCell.GetFormId())+"> location <0x"+DecToHex(currLoc.GetFormId())+">" );
	
	;  sendCellInfo(currCell,currLoc)
	
;  endEvent

 Event OnPlayerLoadGame()

	Cell currCell = Game.GetPlayer().getParentCell()
	Location currLoc = Game.GetPlayer().getCurrentLocation();
	Debug.Trace("[CHIM] AIAgentPlayerScript, cell <0x"+DecToHex(currCell.GetFormId())+"> location <0x"+DecToHex(currLoc.GetFormId())+">" );
	
	UnregisterForUpdate()
	RegisterForSingleUpdate(5)
	sendCellInfo(currCell,currLoc,false)
	
endEvent

Event OnCellLoad()
	Cell currCell = Game.GetPlayer().getParentCell()
	Location currLoc = Game.GetPlayer().getCurrentLocation();
	Debug.Trace("[CHIM] AIAgentPlayerScript, cell <0x"+DecToHex(currCell.GetFormId())+"> location <0x"+DecToHex(currLoc.GetFormId())+">" );
	
	sendCellInfo(currCell,currLoc,false)
	
EndEvent 
; Utils 
String Function DecToHex(Int n) global
    String hexChars = "0123456789ABCDEF"
    String result = ""
    Int i = 0

    ; Convert 8 nibbles (32 bits)
    while i < 8
        ; Shift down to isolate nibble
        Int shiftAmount = (7 - i) * 4
        Int shifted = Math.RightShift(n, shiftAmount)

        ; Mask lowest 4 bits
        Int nibble = Math.LogicalAnd(shifted, 0xF)

        ; Append hex digit
        result += StringUtil.GetNthChar(hexChars, nibble)

        i += 1
    endwhile

    return result
EndFunction

; Will scan for doors
function sendCellInfo(Cell localCell,Location fromLocation,bool detailed = false) global

	
	
	Debug.Trace("[CHIM] sendCellInfo START for <0x"+DecToHex(localCell.GetFormId())+">")

	Location curr =  fromLocation
	ObjectReference refMarker = AIAgentFunctions.getWorldLocationMarkerFor(curr)
	LocationrefType bossContainer = Game.GetFormEx(0x0130f8) as LocationrefType;
	
	ObjectReference player = Game.GetPlayer()

	int j = 0
	
	;  ObjectReference[] children=PO3_SKSEFunctions.GetLinkedChildren(refMarker,None);	
	;  Debug.Trace("[CHIM] sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> children "+children.Length);
	
	;  while j < children.length
		;  Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> marker <0x"+DecToHex(refMarker.GetFormId())+">");
		;  Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> child  <0x"+DecToHex(children[j].GetFormId())+">");
		;  j = j +1
	;  endwhile
	
	
	;  Debug.Trace("[CHIM] sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> interior "+(localCell.IsInterior())+" refs <"+(nrefs)+">");
	;  j = 0
	
	;  int intFormtype =  29
	;  if (detailed)
		;  intFormtype = 0
	;  endif
	
	
	int nrefs = 0
	string staticList = ""
	bool sent = false
	int nStatics=0
	int minDistance = 512
	
	
	ObjectReference[] doors=PO3_SKSEFunctions.FindAllReferencesOfFormType(player,29,0);Doors, can be on anoher cells
	nrefs = doors.length
	while j < nrefs
		int doorToCell = 0
		int doorToExterior = -1 ; Unknown
		int doorId = -1 ; Unknown
		int closed = -1 ;Unknown
		ObjectReference sref = doors[j]
		
		doorId = sref.GetFormId()
		Cell thisCell=sref.getParentCell()
		
		
	
		Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+"> north rotation:"+northRotation);
			
		ObjectReference doorDest = PO3_SKSEFunctions.GetDoorDestination(sref)
		if (!doorDest)
			doorDest = none
		else
			;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> Using PO3.GetDoorDestination");
		endif
		if (doorDest)
			if (doorDest.getParentCell())
				;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> doordst <0x"+DecToHex(doorDest.GetFormId())+"> destcell <0x"+DecToHex(doorDest.getParentCell().getFormId())+">");
				doorToCell = doorDest.getParentCell().getFormId()
				if (doorDest.getParentCell().IsInterior())
					doorToExterior = 0 
				else
					doorToExterior = 1 
				endif
			else
				if (doorDest.IsInInterior())
					;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> doordst <0x"+DecToHex(doorDest.getFormId())+"> destcell <0x0>, exterior <0>");
					doorToExterior = 0 ; Assuming is the case of an unloaded interior cell
				else
					;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> doordst <0x"+DecToHex(doorDest.getFormId())+"> destcell <0x0>, exterior <1>");
					doorToExterior = 1 ; Assuming is the case of an unloaded exterior cell
				endif
			endIf
		else 
			ObjectReference lkRef=sref.GetLinkedRef()
			if (lkRef)
				if (lkRef.getParentCell() == thisCell)
					;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> internal door"); In-cell doors
					doorToExterior = -2 
					doorToCell = localCell.getFormId()
				endif
			else
				;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(thisCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> internal door"); In-cell doors
				doorToExterior = -2 
				doorToCell = thisCell.getFormId()
				;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> unkown door"); In-cell doors
			endif

		endif
		int isInterior = 0
		if (thisCell.IsInterior())
			isInterior = 1
		endIf
		string cellName = thisCell.GetName();
		if (!cellName)
			cellName = curr.GetName()+" area"
		endif
		if sref.IsLocked() || sref.IsActivationBlocked();
			closed = 1 
		endif
		string doorName=AIAgentFunctions.GetDoorActivationText(sref);
		string worldSpaceName = ""
		if (sref.getWorldspace())
			worldSpaceName = sref.getWorldspace().GetName()
		endif
		
		float northRotation = 0.0
		northRotation = PO3_SKSEFunctions.GetCellNorthRotation(thisCell)
		
		float dx = sref.x
		float dy = sref.y

		; Convert degrees to radians
		float rad = northRotation * 0.017453292 ; PI / 180

			; Rotate world-space vector into screen-space (north-up)
		float xhint =  dx * Math.Cos(northRotation) + dy * Math.Sin(northRotation)
		float yhint = -dx * Math.Sin(northRotation) + dy * Math.Cos(northRotation)
		
		Location currLoc = sref.getCurrentLocation();
		AIAgentFunctions.logMessage(cellName+ "/" + thisCell.GetFormID() + "/" + currLoc.GetFormId() + "/" +isInterior+ "/"+doorToCell+"/"+doorToExterior+"/"+doorId+"/"+worldSpaceName+"/"+closed+"/"+doorName+"/"+(xhint)+"/"+(yhint),"named_cell")
		sent = true
		j = j +1
	endwhile
	
	; This cell itself	
	int isInterior = 0
	if (localCell.IsInterior())
		isInterior = 1
	endIf
	string cellName = localCell.GetName();
	if (!cellName)
		cellName = curr.GetName()+" area"
	endif
	if (!cellName)
		cellName = fromLocation+" area"
	endif
	ObjectReference randomRef = localCell.GetNthRef(0,0)
	if (randomRef)
		AIAgentFunctions.logMessage(cellName+ "/" + localCell.GetFormID() + "/" + curr.GetFormId() + "/" +isInterior+ "/-1/-1/0/"+randomRef.getWorldspace().GetName()+"////","named_cell")
	else
		Debug.Trace("[CHIM] sendCellInfo cell with no refs <0x"+DecToHex(localCell.GetFormId())+">")
	endIf
	
	; Rolemaster helper thingies; If interior, spawn and rolemastered activator
	if (detailed)
		ObjectReference[] containers=PO3_SKSEFunctions.FindAllReferencesOfFormType(player,28,0);Containers
		int i = 0
		while i<containers.length
			if (containers[i].HasRefType(bossContainer)) ; Boss Container
				string niceName = containers[i].GetDisplayName()
				string baseFormEditorId
				if (niceName)
					baseFormEditorId = niceName
				else
					baseFormEditorId = PO3_SKSEFunctions.GetFormEditorID(containers[i].GetBaseObject())
				endIf
				
				staticList = staticList +baseFormEditorId + "@"+containers[i].GetFormId()+","
				nStatics = nStatics + 1
			endif
			i = i +1
		endwhile
						
		if (localCell.IsInterior())
			Form hiddenActivator = Game.GetFormEx(0x00069e4b) as Form ;Raised Stone     
			;Form hiddenActivator = Game.GetFormEx(0x0008797c) as Form ;Talking activator    
			ObjectReference hiddenActivatorRef=player.placeAtMe(hiddenActivator,1,false,true)
			hiddenActivatorRef.SetDisplayName("Hidden stone activator")
			bool navSuccess = PO3_SKSEFunctions.MoveToNearestNavmeshLocation(hiddenActivatorRef)
		
			staticList = staticList +"Hidden stone activator" + "@"+hiddenActivatorRef.GetFormId()+","
			nStatics = nStatics + 1
		endif
	endIf
						
	if (staticList)
		Debug.Trace("[CHIM] sendCellInfo sending statics list for <0x"+DecToHex(localCell.GetFormId())+"> N:"+nStatics)
		AIAgentFunctions.logMessage(localCell.GetFormID() + "/"+staticList,"named_cell_static")
	endif

	;AIAgentFunctions.logMessage("Player Cell/0/" + player.getCurrentLocation().GetFormId() + "/" +isInterior+ "/-1/-1/0/"+player.getWorldspace().GetName()+"////","named_cell")

	Debug.Trace("[CHIM] sendCellInfo END for <0x"+DecToHex(localCell.GetFormId())+">")
	
EndFunction

function sendCellInfoPlayer() 

	

	ObjectReference player = Game.GetPlayer()
	Cell localCell = player.getParentCell()
	cellName = "Player Cell"
	string worldSpaceName = player.getWorldspace().GetName()
	
	float northRotation = 0.0
	northRotation = PO3_SKSEFunctions.GetCellNorthRotation(localCell)
	
	float dx = player.x
	float dy = player.y

	; Rotate world-space vector into screen-space (north-up)
	float xhint =  dx * Math.Cos(northRotation) + dy * Math.Sin(northRotation)
	float yhint = -dx * Math.Sin(northRotation) + dy * Math.Cos(northRotation)

	Location currLoc = player.getCurrentLocation();

	int isInterior = 0
	if (localCell.IsInterior())
		isInterior = 1
	endIf
	string cellName = localCell.GetName();
	if (!cellName)
		cellName = currLoc.GetName()+" area"
	endif
	
	
	AIAgentFunctions.logMessage(cellName+ "/0/" + currLoc.GetFormId() + "/" +isInterior+ "/-1/-1/0/"+worldSpaceName+"///"+(xhint)+"/"+(yhint),"named_cell")
	
EndFunction

function sendCellInfoSingle(Cell localCell,Location fromLocation,bool detailed = false) global

	
	
	Debug.Trace("[CHIM] sendCellInfoSingle START for <0x"+DecToHex(localCell.GetFormId())+">")

	Location curr =  fromLocation
	ObjectReference refMarker = AIAgentFunctions.getWorldLocationMarkerFor(curr)
	ObjectReference player = Game.GetPlayer()

	; This cell itself	
	int isInterior = 0
	if (localCell.IsInterior())
		isInterior = 1
	endIf
	string cellName = localCell.GetName();
	if (!cellName)
		cellName = curr.GetName()+" area"
	endif
	if (!cellName)
		cellName = fromLocation+" area"
	endif
	ObjectReference randomRef = localCell.GetNthRef(0,0)
	if (randomRef)
		string worldSpaceName = randomRef.getWorldspace().GetName()
		AIAgentFunctions.logMessage(cellName+ "/" + localCell.GetFormID() + "/" + curr.GetFormId() + "/" +isInterior+ "/-1/-1/0/"+worldSpaceName+"////","named_cell")
	else
		Debug.Trace("[CHIM] sendCellInfoSingle cell with no refs <0x"+DecToHex(localCell.GetFormId())+">")
	endIf
	
	Debug.Trace("[CHIM] sendCellInfoSingle END for <0x"+DecToHex(localCell.GetFormId())+">")
	
EndFunction

Event OnUpdate()
    ; Do some stuff
	sendCellInfoPlayer()
    RegisterForSingleUpdate(5)
endEvent