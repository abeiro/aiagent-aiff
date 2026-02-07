// CHIM Settings Menu JavaScript

let currentNPCTarget = '';
let profilesData = [];

// Initialize when DOM is ready
function initSettingsMenu() {
    console.log('[CHIM Settings] Menu initialized');
    
    // Signal to C++ that DOM is ready
    if (window.chimSettingsMenuCommand) {
        window.chimSettingsMenuCommand('dom_ready');
    }
    
    // Fetch profile information
    fetchProfilesInfo();
    
    // Remove ESC key handler - only hotkey closes now
    // No ESC handling here
}

// Fetch profiles and connector information from server
async function fetchProfilesInfo() {
    try {
        // Get server URL from C++ or use default
        const serverUrl = window.chimServerUrl || 'http://127.0.0.1:8081';
        const response = await fetch(`${serverUrl}/HerikaServer/ui/api/chim_profiles.php`);
        
        if (!response.ok) {
            console.error('[CHIM Settings] Failed to fetch profiles:', response.status);
            return;
        }
        
        const data = await response.json();
        
        if (data.success && data.profiles) {
            profilesData = data.profiles;
            updateProfileButtons();
            console.log('[CHIM Settings] Loaded profile data:', profilesData);
        }
    } catch (error) {
        console.error('[CHIM Settings] Error fetching profiles:', error);
    }
}

// Update profile buttons with detailed information
function updateProfileButtons() {
    for (let slot = 1; slot <= 4; slot++) {
        const nameDiv = document.querySelector(`#profile-${slot}-connectors`);
        if (!nameDiv) continue;
        
        const profile = profilesData.find(p => p.slot === slot);
        if (!profile) {
            nameDiv.innerHTML = '<span style="color: #888;">Loading...</span>';
            continue;
        }
        
        // Find the parent button to update the profile name
        const button = nameDiv.closest('.profile-btn');
        if (button) {
            const nameElement = button.querySelector('.profile-name');
            if (nameElement) {
                nameElement.textContent = `${profile.profile_name}`;
            }
        }
        
        // Build connector list
        if (profile.connectors && profile.connectors.length > 0) {
            let connectorsHTML = '';
            profile.connectors.forEach((conn, idx) => {
                if (idx > 0) connectorsHTML += '<br>';
                connectorsHTML += `<span style="color: #aaa;">•</span> ${conn.slot_name.replace(' LLM', '')}: ${conn.label}`;
            });
            nameDiv.innerHTML = connectorsHTML;
        } else {
            nameDiv.innerHTML = '<span style="color: #888;">No connectors configured</span>';
        }
        
        // Build detailed tooltip
        let tooltipText = `Assign "${profile.profile_name}" to this NPC permanently.\n\n`;
        
        if (profile.connectors && profile.connectors.length > 0) {
            tooltipText += 'Configured LLMs:\n';
            profile.connectors.forEach(conn => {
                tooltipText += `• ${conn.slot_name}: ${conn.label}`;
                if (conn.model) {
                    tooltipText += ` (${conn.model})`;
                }
                tooltipText += '\n';
            });
        } else {
            tooltipText += 'No LLM connectors configured for this profile.';
        }
        
        if (button) {
            button.setAttribute('title', tooltipText);
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
