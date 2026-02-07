// CHIM Settings Menu JavaScript

let currentNPCTarget = '';

// Initialize when DOM is ready
function initSettingsMenu() {
    console.log('[CHIM Settings] Menu initialized');
    
    // Signal to C++ that DOM is ready
    if (window.chimSettingsMenuCommand) {
        window.chimSettingsMenuCommand('dom_ready');
    }
    
    // Remove ESC key handler - only hotkey closes now
    // No ESC handling here
}

// Called by C++ to signal that the JavaScript environment is ready
window.chimSettingsMenuReady = function() {
    console.log('[CHIM Settings] JS ready callback received');
};

// Handle option selection
function selectOption(optionId) {
    console.log('[CHIM Settings] Selected option:', optionId);
    
    // If NPC-targeted action, include NPC name
    let command = optionId;
    if (currentNPCTarget && currentNPCTarget !== '' && currentNPCTarget !== 'none') {
        // NPC-specific actions
        const npcActions = ['rp_write_diary', 'rp_update_npc', 'rp_wait', 'rp_follow', 'rp_rename', 'profile_1', 'profile_2', 'profile_3', 'profile_4'];
        if (npcActions.includes(optionId)) {
            command = optionId + '|' + currentNPCTarget;
        }
    }
    
    // Send command to C++ bridge
    if (window.chimSettingsMenuCommand) {
        window.chimSettingsMenuCommand(command);
        
        // For Papyrus actions, trigger an immediate check
        const papyrusActions = ['rp_', 'sg_'];
        if (papyrusActions.some(prefix => optionId.startsWith(prefix))) {
            // Signal C++ to trigger Papyrus polling
            setTimeout(() => {
                window.chimSettingsMenuCommand('trigger_papyrus_check');
            }, 100); // Small delay to ensure action is stored
        }
    }
}

// Close menu
function closeMenu() {
    console.log('[CHIM Settings] Closing menu');
    
    // Send close command to C++
    if (window.chimSettingsMenuCommand) {
        window.chimSettingsMenuCommand('close');
    }
}

// Set NPC target - called by C++ when menu opens
window.setNPCTarget = function(npcName) {
    console.log('[CHIM Settings] Set NPC target:', npcName);
    currentNPCTarget = npcName;
    
    if (npcName && npcName !== '' && npcName !== 'none') {
        // Show NPC-specific sections
        document.getElementById('npc-settings').style.display = 'block';
        document.getElementById('roleplay-npc-actions').style.display = 'block';
        
        // Update NPC names in UI
        document.getElementById('npc-name').textContent = npcName;
        document.getElementById('roleplay-npc-name').textContent = npcName;
    } else {
        // Hide NPC-specific sections
        document.getElementById('npc-settings').style.display = 'none';
        document.getElementById('roleplay-npc-actions').style.display = 'none';
        currentNPCTarget = '';
    }
};

// Initialize on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSettingsMenu);
} else {
    initSettingsMenu();
}
