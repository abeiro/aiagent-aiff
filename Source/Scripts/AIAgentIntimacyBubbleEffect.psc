Scriptname AIAgentIntimacyBubbleEffect extends activemagiceffect  

Spell Property IntimacySpell  Auto  
MagicEffect Property IntimacyEffect  Auto  

int Property mdi auto
int Property mdo auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Check if the player already has this effect

	mdi=AIAgentFunctions.get_conf_i("_max_distance_inside");
	mdo=AIAgentFunctions.get_conf_i("_max_distance_outside");
		
	Debug.Trace("[CHIM] Enabling intimacy bubble effect: saving settings: "+mdi+","+mdo);
		
	AIAgentFunctions.setConf("_max_distance_inside",256,256,256);
	AIAgentFunctions.setConf("_max_distance_outside",256,256,256);
	Debug.Trace("[CHIM] Effect applied");
	Debug.Notification("[CHIM] Intimacy bubble applied");
        
    
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
    ; Check if the player already has this effect
	
	Debug.Trace("[CHIM] Restoring settings because intimacy bubble effect ends");
			
	AIAgentFunctions.setConf("_max_distance_inside",mdi,mdi,mdi);
	AIAgentFunctions.setConf("_max_distance_outside",mdo,mdo,mdo);
			
    Debug.Notification("[CHIM] Intimacy bubble dispelled");
    Debug.Trace("[CHIM] Intimacy bubble dispelled")
    
EndEvent


