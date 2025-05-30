Scriptname AIAgentFaceReset 


; patches intended to solve the open mouth issue, should overwrite this

function resetFace(Actor target) global
	
	
	; This shoold work with opparco mfgfix
	;MfgConsoleFunc.ResetPhonemeModifier(target);
	;target.ClearExpressionOverride();
	
	
	;; this works if using mfgfix, but maybe will reset some face effect
	if (!target.IsOnMount())
		MfgConsoleFunc.ResetPhonemeModifier(target);
		;MfgConsoleFunc.SetPhonemeModifier(ActorRef, -1, 0, 0)
		target.QueueNiNodeUpdate()
	endif	
	;https://forums.nexusmods.com/index.php?/topic/5915098-mfg-fix/page-93#entry120402382 Coffee to this guy

	;Debug.Notification("[SPG] Reset expression")

endFunction