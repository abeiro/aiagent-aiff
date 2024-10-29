Scriptname AIAgentFunctions

int function sendMessage(String a_msg,String a_type) Global Native		; Send message as user input and expects an IA response
int function commandEnded(String command)  Global Native
int function commandEndedForActor(String command,string npc)  Global Native
int function getHerikaFormId()  Global Native
int function recordSoundEx(int bindedKey)  Global Native
int function stopRecording(int bindedKey)  Global Native
int function setNewActionMode(int mode)  Global Native
int function logMessage(String a_msg,String type) Global Native			; Send message for logging purposes. Doesn't expect response
int function logMessageForActor(String a_msg,String type,String npc) Global Native			; Send message for logging purposes. Doesn't expect response
int function requestMessage(String a_msg,String type) Global Native		; Send message (no user input). expects an IA response
int function requestMessageForActor(String a_msg,String type,String npc) Global Native		; Send message (no user input). expects an IA response
int function setAnimationBusy(int busy,String npc) Global Native
int function sendRequest() Global Native
int function hardResetExpression() Global Native
int function shotAndUpload(String hints,int mode) Global Native
int function isGameVR() Global Native									; 1 if VR

int function setConf(String code,float float_value,int int_value,String string_value) Global Native
int function get_conf_i(String code) Global Native
int function setDrivenByAI() Global Native
int function setDrivenByAIA(Actor forcedActor,bool salutation) Global Native

int function removeAgentByName(String name) Global Native

int function setAIKeyWord(Actor targetActor) Global Native

Actor function getClosestAgent() Global Native
Actor function getAgentByName(String npcName) Global Native

ObjectReference function getLocationMarkerFor(Location loc) Global Native

Actor[] function findAllNearbyAgents() Global Native

int function sendAllVoices() Global Native

int function  testAddAllNPCAround() Global Native
