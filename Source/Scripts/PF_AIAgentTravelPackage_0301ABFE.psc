;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 10
Scriptname PF_AIAgentTravelPackage_0301ABFE Extends Package Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(Actor akActor)
;BEGIN CODE
AIAgentAIMind.TravelToTargetEnd(akActor)
;AIAgentFunctions.requestMessageForActor("Destination reached","traveldone",akActor.getName())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9(Actor akActor)
;BEGIN CODE
Debug.Trace("[CHIM] Package AIAgentTravelPackage started")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8(Actor akActor)
;BEGIN CODE
AIAgentAIMind.TravelToTargetEnd(akActor)
AIAgentFunctions.logMessageForActor("Travel was interrupted","travelcancel",akActor.getName())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
