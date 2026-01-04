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
	
	sendCellInfo(currCell,currLoc,false)
	
endEvent

;  Event OnCellLoad()
	;  Cell currCell = Game.GetPlayer().getParentCell()
	;  Location currLoc = Game.GetPlayer().getCurrentLocation();
	;  Debug.Trace("[CHIM] AIAgentPlayerScript, cell <0x"+DecToHex(currCell.GetFormId())+"> location <0x"+DecToHex(currLoc.GetFormId())+">" );
	
	;  sendCellInfo(currCell,currLoc,true)
	
;  EndEvent 
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

function sendCellInfo(Cell localCell,Location fromLocation,bool detailed = false) global

	Debug.Trace("[CHIM] sendCellInfo START for <0x"+DecToHex(localCell.GetFormId())+">")

	Location curr =  fromLocation
	ObjectReference refMarker = AIAgentFunctions.getWorldLocationMarkerFor(curr)
	LocationrefType bossContainer = Game.GetFormEx(0x0130f8) as LocationrefType;
	
	ObjectReference player = Game.GetPlayer()
	
	
	
	ObjectReference[] children=PO3_SKSEFunctions.GetLinkedChildren(refMarker,None);	
	Debug.Trace("[CHIM] sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> children "+children.Length);
	
	int j = 0
	while j < children.length
		Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> marker <0x"+DecToHex(refMarker.GetFormId())+">");
		Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> child  <0x"+DecToHex(children[j].GetFormId())+">");
		j = j +1
	endwhile
	
	Debug.Trace("[CHIM] sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> interior "+(localCell.IsInterior())+" refs <"+(nrefs)+">");
	j = 0
	
	int intFormtype =  29
	if (detailed)
		intFormtype = 0
	endif
	
	
	int nrefs = localCell.GetNumRefs(intFormtype)
	string staticList = ""
	bool sent = false
	int nStatics=0
	int minDistance = 512
	while j < nrefs
		int doorToCell = 0
		int doorToExterior = -1 ; Unknown
		int doorId = -1 ; Unknown
	
		ObjectReference sref = localCell.GetNthRef(j,intFormtype)
		if (sref.GetBaseObject().GetType() == 29 ) ; door
			doorId = sref.GetFormId()
			Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+">");
				
			ObjectReference doorDest = PO3_SKSEFunctions.GetDoorDestination(sref)
			if (!doorDest)
				doorDest = none
			else
				Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> Using PO3.GetDoorDestination");
			endif
			if (doorDest)
				if (doorDest.getParentCell())
					Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> doordst <0x"+DecToHex(doorDest.GetFormId())+"> destcell <0x"+DecToHex(doorDest.getParentCell().getFormId())+">");
					doorToCell = doorDest.getParentCell().getFormId()
					if (doorDest.getParentCell().IsInterior())
						doorToExterior = 0 
					else
						doorToExterior = 1 
					endif
				else
					if (doorDest.IsInInterior())
						Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> doordst <0x"+DecToHex(doorDest.getFormId())+"> destcell <0x0>, exterior <0>");
						doorToExterior = 0 ; Assuming is the case of an unloaded interior cell
					else
						Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> doordst <0x"+DecToHex(doorDest.getFormId())+"> destcell <0x0>, exterior <1>");
						doorToExterior = 1 ; Assuming is the case of an unloaded exterior cell
					endif
				endIf
			else 
				ObjectReference lkRef=sref.GetLinkedRef()
				if (lkRef)
					if (lkRef.getParentCell() == localCell)
						Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> internal door"); In-cell doors
						doorToExterior = -2 
						doorToCell = localCell.getFormId()
					endif
				else
					Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> internal door"); In-cell doors
					doorToExterior = -2 
					doorToCell = localCell.getFormId()
					;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> doorsrc <0x"+DecToHex(sref.GetFormId())+"> unkown door"); In-cell doors
				endif

			endif
			int isInterior = 0
			if (localCell.IsInterior())
				isInterior = 1
			endIf
			string cellName = localCell.GetName();
			if (!cellName)
				cellName = curr.GetName()+" area"
			endif
			AIAgentFunctions.logMessage(cellName+ "/" + localCell.GetFormID() + "/" + curr.GetFormId() + "/" +isInterior+ "/"+doorToCell+"/"+doorToExterior+"/"+doorId,"named_cell")
			sent = true
			Form baseForm =sref.GetBaseObject();
			string baseFormEditorId = PO3_SKSEFunctions.GetFormEditorID(baseForm)
			staticList = staticList +sref.GetDisplayName() + "@"+sref.GetFormId()+","
			nStatics = nStatics + 1
			
		elseif (detailed)
			if (sref.getDistance(Game.GetPlayer()) < minDistance)
				
				Form baseForm =sref.GetBaseObject();
				;if (baseForm.GetType() == 24 || baseForm.GetType() == 33 || baseForm.GetType() == 28 || baseForm.GetType() == 29 || baseForm.GetType() == 39 ||  baseForm.GetType() == 40 || baseForm.GetType() == 23  || baseForm.GetType() == 34  || baseForm.GetType() == 38 )  
				if (baseForm.GetType() == 28|| baseForm.GetType() == 24 )  
					string baseFormEditorId = ""
					string niceName = sref.GetDisplayName()
					if (niceName)
						baseFormEditorId = niceName
					else
						baseFormEditorId = PO3_SKSEFunctions.GetFormEditorID(baseForm)
					endIf
					if (false && baseForm.GetType() == 36 && ( baseForm.HasWorldModel() && sref.Is3DLoaded() && (sref.GetWidth() * sref.getHeight() * sref.getLength())> (2097512 * 2 * 0))); Volume based 256x256x256
						;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+"> <"+baseFormEditorId+">");
						if (StringUtil.Find(baseFormEditorId,"fx") == -1)
							staticList = staticList +baseFormEditorId + "@"+sref.GetFormId()+","
							nStatics = nStatics + 1
						endif
					elseif (baseForm.GetType() == 34 && ( baseForm.GetFormId() == 0x03b || baseForm.GetFormId() == 0x01f || baseForm.GetFormId() == 0x034)) ; XMarker,RoomKMarker,XHeadintMakerker
						;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+"> <"+baseFormEditorId+">");
						staticList = staticList +baseFormEditorId + "@"+sref.GetFormId()+","
						nStatics = nStatics + 1
					elseif (baseForm.GetType() == 28 ) ; Container
						if (sref.HasRefType(bossContainer)) ; Boss Container
						;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+"> <"+baseFormEditorId+">");
							staticList = staticList +baseFormEditorId + "@"+sref.GetFormId()+","
							nStatics = nStatics + 1
						endif
					elseif (baseForm.GetType() == 24  && false) ; Activator
						;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+"> <"+baseFormEditorId+">");
						staticList = staticList +baseFormEditorId + "@"+sref.GetFormId()+","
						nStatics = nStatics + 1
					else
						;Debug.Trace("[CHIM]	sendCellInfo, cell <0x"+DecToHex(localCell.GetFormId())+"> ref <0x"+DecToHex(sref.GetFormId())+"> base <0x"+DecToHex(sref.GetBaseObject().GetFormId())+"> type   <"+(sref.GetBaseObject().GetType())+"> <"+baseFormEditorId+"> discarded");
					endif
				endif
			endif
		endif
		j = j +1
	endwhile
	
	; Cell itself	
	int isInterior = 0
	if (localCell.IsInterior())
		isInterior = 1
	endIf
	string cellName = localCell.GetName();
	if (!cellName)
		cellName = curr.GetName()+" area"
	endif
	AIAgentFunctions.logMessage(cellName+ "/" + localCell.GetFormID() + "/" + curr.GetFormId() + "/" +isInterior+ "/-1/-1/0","named_cell")
	
	; Rolemaster helper thingies
	if (detailed)
		Form hiddenActivator = Game.GetFormEx(0x00069e4b) as Form ;Button     
		ObjectReference hiddenActivatorRef=player.placeAtMe(hiddenActivator,1,false,true)
		hiddenActivatorRef.SetDisplayName("Hidden stone activator")
		bool navSuccess = PO3_SKSEFunctions.MoveToNearestNavmeshLocation(hiddenActivatorRef)
	
		staticList = staticList +"Hidden stone activator" + "@"+hiddenActivatorRef.GetFormId()+","
		nStatics = nStatics + 1
	endIf
						
	if (staticList)
		Debug.Trace("[CHIM] sendCellInfo sending statics list for <0x"+DecToHex(localCell.GetFormId())+"> N:"+nStatics)
		AIAgentFunctions.logMessage(localCell.GetFormID() + "/"+staticList,"named_cell_static")
	endif
	Debug.Trace("[CHIM] sendCellInfo END for <0x"+DecToHex(localCell.GetFormId())+">")
	
EndFunction