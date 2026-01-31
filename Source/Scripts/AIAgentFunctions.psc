Scriptname AIAgentFunctions

;Main Functions
int function sendMessage(String a_msg,String a_type) Global Native		; Send message as user input and expects an IA response
int function commandEnded(String command)  Global Native
int function commandEndedForActor(String command,string npc)  Global Native

int function recordSoundEx(int bindedKey)  Global Native
int function stopRecording(int bindedKey)  Global Native
int function startOpenMicMonitoring()  Global Native
int function stopOpenMicMonitoring()  Global Native
int function setOpenMicMuted(bool muted)  Global Native
int function setNewActionMode(int mode)  Global Native
int function logMessage(String a_msg,String type) Global Native			; Send message for logging purposes. Doesn't expect response
int function logMessageForActor(String a_msg,String type,String npc) Global Native			; Send message for logging purposes. Doesn't expect response
int function requestMessage(String a_msg,String type) Global Native		; Send message (no user input). expects an IA response
int function requestMessageForActor(String a_msg,String type,String npc) Global Native		; Send message (no user input). expects an IA response
int function setAnimationBusy(int busy,String npc) Global Native
int function setLocked(int locked,String npc) Global Native; 1 locks agent for talking, 0 releases.
int function sendRequest() Global Native
int function hardResetExpression() Global Native
int function shotAndUpload(String hints,int mode) Global Native
int function isGameVR() Global Native									; 1 if VR

; Conf opts send
int function setConf(String code,float float_value,int int_value,String string_value) Global Native

;Internal
int function get_conf_i(String code) Global Native

int function setAIKeyWord(Actor targetActor) Global Native

; Agent functions
int function setDrivenByAI() Global Native
int function setDrivenByAIA(Actor forcedActor,bool salutation) Global Native
int function removeAgentByName(String name) Global Native
Actor function getClosestAgent() Global Native
Actor function getAgentByName(String npcName) Global Native
Actor[] function findAllNearbyAgents() Global Native
Actor[] function findAllAgents() Global Native
Actor[] function findAllNearbyNonAgents() Global Native
Actor[] function findAllNearbyActors(bool onlyBgl) Global Native; Only gets actors with BgL flag

; Helpers
ObjectReference function getLocationMarkerFor(Location loc) Global Native
ObjectReference function getWorldLocationMarkerFor(Location loc) Global Native
ObjectReference function getNearestDoor() global Native
ObjectReference function findLocationsToSafeSpawn(float minDistance,bool restriction=true) global Native;restriction, ref must have a name

int Function isUsingFurniture(Actor akActor) global Native
int Function isInContainer(ObjectReference item) global Native

int Function SayTo(Actor source,Actor dest,Form topicToSay) global Native

; Prisma UI History Panel functions
int function toggleHistoryPanel() Global Native
int function showHistoryPanel() Global Native
int function hideHistoryPanel() Global Native
int function focusHistoryPanel(bool pauseGame = false) Global Native
int function unfocusHistoryPanel() Global Native
int function toggleHistoryPanelFocus(bool pauseGame = false) Global Native

int function toggleOverlayPanel() Global Native
int function showOverlayPanel() Global Native
int function hideOverlayPanel() Global Native

int function toggleDiariesPanel() Global Native
int function showDiariesPanel() Global Native
int function hideDiariesPanel() Global Native

int function toggleBrowserPanel() Global Native
int function showBrowserPanel() Global Native
int function hideBrowserPanel() Global Native

int function toggleAIViewPanel() Global Native
int function showAIViewPanel() Global Native
int function hideAIViewPanel() Global Native

int function toggleDebuggerPanel() Global Native
int function showDebuggerPanel() Global Native
int function hideDebuggerPanel() Global Native

; Test functions
int function sendAllVoices() Global Native
int function  testAddAllNPCAround() Global Native
int function  testRemoveAll() Global Native

; Legacy 
int function getHerikaFormId()  Global Native


; Utils

int function jsonGetInt(string keyName,string jsonString) global native
int function jsonGetFormId(string keyName,string jsonString) global native
string function jsonGetString(string keyName,string jsonString) global native
float function jsonGetFloat(string keyName,string jsonString) global native
Actor function jsonGetActor(string keyName,string jsonString) global native
ObjectReference function jsonGetReference(string keyName,string jsonString) global native
FormList function jsonGetFormList(string keyName,string jsonString) global native
EffectShader function jsonGetEffectShader(string keyName,string jsonString) global native

string function GetDoorActivationText(ObjectReference akRef) global native