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

; Helpers
ObjectReference function getLocationMarkerFor(Location loc) Global Native
ObjectReference function getNearestDoor() global Native
ObjectReference function findLocationsToSafeSpawn(float minDistance,bool restriction=true) global Native

int Function isUsingFurniture(Actor actor) global Native

; Test functions
int function sendAllVoices() Global Native
int function  testAddAllNPCAround() Global Native
int function  testRemoveAll() Global Native

; Legacy 
int function getHerikaFormId()  Global Native