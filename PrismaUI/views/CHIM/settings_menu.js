// CHIM Settings Menu JavaScript

let currentNPCTarget = '';
let profileSlots = {};

// Show description in footer
window.showDescription = function(text) {
    const descElement = document.getElementById('hover-description');
    if (descElement) {
        descElement.textContent = text;
        descElement.style.color = '#e8e8e8';
    }
};

// Clear description in footer
window.clearDescription = function() {
    const descElement = document.getElementById('hover-description');
    if (descElement) {
        descElement.textContent = 'Hover over any option to see details';
        descElement.style.color = '#999';
    }
};

// Initialize when DOM is ready
function initSettingsMenu() {
    console.log('[CHIM Settings] Menu initialized');
    
    // Signal to C++ that DOM is ready
    if (window.chimSettingsMenuCommand) {
        window.chimSettingsMenuCommand('dom_ready');
    }
    
    // Fetch profile information
    fetchProfilesInfo();
    
    // Add keyboard listener for ESC key to close menu
    document.addEventListener('keydown', handleKeyDown);
}

// Handle keyboard events
function handleKeyDown(event) {
    // ESC key closes the menu
    if (event.key === 'Escape' || event.keyCode === 27) {
        event.preventDefault();
        event.stopPropagation();
        closeMenu();
    }
}

// Fetch profiles and connector information from server
async function fetchProfilesInfo() {
    try {
        // Get server URL from C++ or use default
        const serverUrl = window.chimServerUrl || 'http://127.0.0.1:8081';
        const apiUrl = `${serverUrl}/ui/api/chim_profiles.php`;
        console.log('[CHIM Settings] Fetching profiles from:', apiUrl);
        
        const response = await fetch(apiUrl);
        
        if (!response.ok) {
            console.error('[CHIM Settings] Failed to fetch profiles:', response.status, response.statusText);
            setFallbackProfiles();
            return;
        }
        
        const data = await response.json();
        console.log('[CHIM Settings] Received profile data:', data);
        
        if (data.success && data.profile_slots) {
            profileSlots = data.profile_slots;
            updateProfileButtons();
        } else {
            console.error('[CHIM Settings] Invalid data structure:', data);
            setFallbackProfiles();
        }
    } catch (error) {
        console.error('[CHIM Settings] Error fetching profiles:', error);
        setFallbackProfiles();
    }
}

// Set fallback profile data when API fails
function setFallbackProfiles() {
    console.log('[CHIM Settings] Using fallback profile data');
    profileSlots = {
        1: { profile_name: 'Profile 1' },
        2: { profile_name: 'Profile 2' },
        3: { profile_name: 'Profile 3' },
        4: { profile_name: 'Profile 4' }
    };
    updateProfileButtons();
}

// Update profile buttons with profile names (simplified)
function updateProfileButtons() {
    console.log('[CHIM Settings] Updating profile buttons');
    
    for (let slot = 1; slot <= 4; slot++) {
        const nameElement = document.getElementById(`profile-${slot}-name`);
        if (!nameElement) {
            console.error(`[CHIM Settings] Could not find #profile-${slot}-name`);
            continue;
        }
        
        const profile = profileSlots[slot];
        if (profile && profile.profile_name) {
            nameElement.textContent = profile.profile_name;
            console.log(`[CHIM Settings] Set slot ${slot} name: ${profile.profile_name}`);
            
            // Update the button's hover description
            const button = nameElement.closest('.profile-btn');
            if (button) {
                button.setAttribute('onmouseenter', `showDescription('Assign "${profile.profile_name}" to this NPC permanently')`);
            }
        } else {
            nameElement.textContent = `Profile ${slot}`;
        }
    }
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
