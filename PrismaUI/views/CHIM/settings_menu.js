// CHIM Settings Menu JavaScript

let currentNPCTarget = '';
let profileSlots = {};
let aiGenerateProfileInFlight = false;
let activeModeAction = '';
let activeModelAction = '';
let activeNpcProfileId = null;
let activeNpcProfileLabel = '';
let activeStateRefreshTimeouts = [];
let rumorCreateInFlight = false;
const DEFAULT_SERVER_BASE = 'http://127.0.0.1:8081/HerikaServer';
let rawChimServerUrl = '';

const MODE_ACTION_MAP = {
    STANDARD: 'mode_standard',
    WHISPER: 'mode_whisper',
    NARRATOR: 'mode_narrator',
    DIRECTOR: 'mode_director',
    SPAWN: 'mode_spawn',
    CHEATMODE: 'mode_cheat',
    AUTOCHAT: 'mode_autochat',
    INJECTION_LOG: 'mode_inject_log',
    INJECTION_CHAT: 'mode_inject_chat'
};

const MODEL_ACTION_MAP = {
    1: 'llm_standard',
    2: 'llm_fast',
    3: 'llm_powerful',
    4: 'llm_experimental'
};

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
    
    // Fetch profile information and current active state
    fetchProfilesInfo();
    refreshActiveState();
    
    // Add keyboard listener for ESC key to close menu
    document.addEventListener('keydown', handleKeyDown);
}

// Handle keyboard events
function handleKeyDown(event) {
    // ESC key closes the menu
    if (event.key === 'Escape' || event.keyCode === 27) {
        event.preventDefault();
        event.stopPropagation();
        if (isRumorModalOpen()) {
            closeRumorModal();
            return;
        }
        closeMenu();
    }
}

// Fetch profiles and connector information from server
async function fetchProfilesInfo() {
    try {
        const serverUrl = getServerBaseUrl();
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
            updateActiveHighlights();
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
        1: { profile_id: 1, profile_name: 'Profile 1' },
        2: { profile_id: 2, profile_name: 'Profile 2' },
        3: { profile_id: 3, profile_name: 'Profile 3' },
        4: { profile_id: 4, profile_name: 'Profile 4' }
    };
    updateProfileButtons();
    updateActiveHighlights();
}

function getServerBaseUrl() {
    let base = rawChimServerUrl || DEFAULT_SERVER_BASE;
    base = String(base || '').replace(/\/+$/, '');
    if (!/\/HerikaServer$/i.test(base)) {
        base += '/HerikaServer';
    }
    return base;
}

function bindServerUrlUpdates() {
    const currentValue = typeof window.chimServerUrl === 'string' ? window.chimServerUrl : rawChimServerUrl;
    rawChimServerUrl = currentValue || '';

    Object.defineProperty(window, 'chimServerUrl', {
        configurable: true,
        enumerable: true,
        get() {
            return rawChimServerUrl;
        },
        set(value) {
            const nextValue = String(value || '').trim();
            const changed = nextValue !== rawChimServerUrl;
            rawChimServerUrl = nextValue;

            if (changed) {
                console.log('[CHIM Settings] Updated server URL:', getServerBaseUrl());
                fetchProfilesInfo();
                refreshActiveState();
            }
        }
    });
}

function getRumorModalOverlay() {
    return document.getElementById('rumor-modal-overlay');
}

function getRumorForm() {
    return document.getElementById('rumor-create-form');
}

function getRumorStatusElement() {
    return document.getElementById('rumor-form-status');
}

function isRumorModalOpen() {
    const overlay = getRumorModalOverlay();
    return !!overlay && !overlay.classList.contains('hidden');
}

function setRumorFormStatus(message, type) {
    const status = getRumorStatusElement();
    if (!status) {
        return;
    }

    status.textContent = message || '';
    status.classList.remove('is-error', 'is-success');
    if (type === 'error' || type === 'success') {
        status.classList.add(`is-${type}`);
    }
}

function setRumorSubmitState(busy) {
    rumorCreateInFlight = !!busy;
    const submitBtn = document.getElementById('rumor-submit-btn');
    if (submitBtn) {
        submitBtn.disabled = !!busy;
        submitBtn.textContent = busy ? 'Creating Rumor...' : 'Create Rumor';
    }
}

window.openRumorModal = function() {
    const overlay = getRumorModalOverlay();
    const form = getRumorForm();
    if (!overlay || !form) {
        return;
    }

    form.reset();
    setRumorFormStatus('', '');
    setRumorSubmitState(false);
    overlay.classList.remove('hidden');
    overlay.setAttribute('aria-hidden', 'false');

    const holdSelect = document.getElementById('rumor-hold-select');
    if (holdSelect) {
        setTimeout(function() {
            holdSelect.focus();
        }, 0);
    }
};

window.closeRumorModal = function() {
    const overlay = getRumorModalOverlay();
    const form = getRumorForm();
    if (!overlay) {
        return;
    }

    overlay.classList.add('hidden');
    overlay.setAttribute('aria-hidden', 'true');
    setRumorFormStatus('', '');
    setRumorSubmitState(false);
    if (form) {
        form.reset();
    }
};

window.submitRumorForm = async function(event) {
    if (event) {
        event.preventDefault();
    }

    if (rumorCreateInFlight) {
        return;
    }

    const form = getRumorForm();
    if (!form) {
        return;
    }

    const formData = new FormData(form);
    const hold = String(formData.get('rumor_hold') || '').trim();
    const type = String(formData.get('rumor_type') || '').trim();
    const content = String(formData.get('rumor_content') || '').trim();
    const rumorLengthDays = String(formData.get('rumor_length_days') || '').trim();

    if (!hold) {
        setRumorFormStatus('Select a hold for this rumor.', 'error');
        return;
    }

    if (!content) {
        setRumorFormStatus('Rumor content is required.', 'error');
        return;
    }

    if (rumorLengthDays !== '' && !/^\d+$/.test(rumorLengthDays)) {
        setRumorFormStatus('Rumor length must be a whole number of days.', 'error');
        return;
    }

    if (rumorLengthDays !== '' && Number(rumorLengthDays) < 1) {
        setRumorFormStatus('Rumor length must be at least 1 day.', 'error');
        return;
    }

    setRumorSubmitState(true);
    setRumorFormStatus('Saving rumor...', '');

    try {
        const response = await fetch(`${getServerBaseUrl()}/ui/cmd/action_create_rumor.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: new URLSearchParams({
                rumor_hold: hold,
                rumor_type: type,
                rumor_content: content,
                rumor_length_days: rumorLengthDays || '7'
            }).toString()
        });

        const result = await response.json();
        if (!response.ok || !result || !result.ok) {
            const errorMessage = result && result.message ? result.message : `HTTP ${response.status}`;
            throw new Error(errorMessage);
        }

        setRumorFormStatus(result.message || 'Rumor created successfully.', 'success');
        showDescription(`Rumor saved for ${hold}.`);
        setTimeout(function() {
            closeRumorModal();
        }, 220);
    } catch (error) {
        console.error('[CHIM Settings] Create Rumor failed:', error);
        setRumorFormStatus(`Create Rumor failed: ${error.message || error}`, 'error');
    } finally {
        setRumorSubmitState(false);
    }
};

function setAIGenerateButtonState(busy) {
    const button = document.getElementById('ai-generate-profile-btn');
    if (!button) {
        return;
    }

    button.disabled = !!busy;
    button.classList.toggle('is-busy', !!busy);
    button.textContent = busy ? 'Generating Profile...' : 'AI Generate Profile';
}

function resolveActiveNpcProfileSlot() {
    for (let slot = 1; slot <= 4; slot++) {
        const slotProfile = profileSlots[slot];
        if (!slotProfile) {
            continue;
        }

        if (activeNpcProfileId !== null && activeNpcProfileId !== '' && Number(slotProfile.profile_id) === Number(activeNpcProfileId)) {
            return slot;
        }

        if (activeNpcProfileLabel && slotProfile.profile_name === activeNpcProfileLabel) {
            return slot;
        }
    }

    return null;
}

function updateActiveHighlights() {
    const activeNpcProfileSlot = resolveActiveNpcProfileSlot();
    const buttons = document.querySelectorAll('.setting-btn[data-option]');

    buttons.forEach(function(button) {
        const optionId = button.getAttribute('data-option');
        const isActive =
            optionId === activeModeAction ||
            optionId === activeModelAction ||
            (activeNpcProfileSlot !== null && optionId === `profile_${activeNpcProfileSlot}`);

        button.classList.toggle('is-active', isActive);
        button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
    });
}

async function fetchOverlayState() {
    try {
        const response = await fetch(`${getServerBaseUrl()}/ui/api/chim_overlay.php`);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const payload = await response.json();
        if (!payload || !payload.success || !payload.data) {
            throw new Error('Invalid overlay payload');
        }

        const overlay = payload.data;
        const modeKey = overlay.mode ? String(overlay.mode).toUpperCase().trim() : 'STANDARD';
        activeModeAction = MODE_ACTION_MAP[modeKey] || 'mode_standard';
        activeModelAction = MODEL_ACTION_MAP[Number(overlay.active_model_slot)] || 'llm_standard';
        updateActiveHighlights();
    } catch (error) {
        console.error('[CHIM Settings] Error fetching overlay state:', error);
    }
}

async function fetchNpcProfileState() {
    if (!currentNPCTarget || currentNPCTarget === 'none') {
        activeNpcProfileId = null;
        activeNpcProfileLabel = '';
        updateActiveHighlights();
        return;
    }

    try {
        const params = new URLSearchParams({ npc_name: currentNPCTarget });
        const response = await fetch(`${getServerBaseUrl()}/ui/api/chim_aiview.php?${params.toString()}`);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const payload = await response.json();
        if (!payload || !payload.success || !payload.data || !payload.data.profile) {
            throw new Error('Invalid NPC profile payload');
        }

        activeNpcProfileId = payload.data.profile.id ?? null;
        activeNpcProfileLabel = payload.data.profile.label || '';
        updateActiveHighlights();
    } catch (error) {
        console.error('[CHIM Settings] Error fetching NPC profile state:', error);
        activeNpcProfileId = null;
        activeNpcProfileLabel = '';
        updateActiveHighlights();
    }
}

function scheduleActiveStateRefresh() {
    activeStateRefreshTimeouts.forEach(function(timeoutId) {
        clearTimeout(timeoutId);
    });

    activeStateRefreshTimeouts = [175, 700].map(function(delay) {
        return setTimeout(function() {
            refreshActiveState();
        }, delay);
    });
}

function refreshActiveState() {
    fetchOverlayState();
    fetchNpcProfileState();
}

async function triggerAIGenerateProfile() {
    if (aiGenerateProfileInFlight) {
        return;
    }

    if (!currentNPCTarget || currentNPCTarget === 'none') {
        showDescription('AI Generate Profile requires an NPC target.');
        return;
    }

    aiGenerateProfileInFlight = true;
    setAIGenerateButtonState(true);
    showDescription(`Generating CHIM profile for ${currentNPCTarget} from up to the last 100 usable events...`);

    try {
        const serverUrl = getServerBaseUrl();
        const response = await fetch(`${serverUrl}/ui/cmd/action_ai_regen_profile.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: new URLSearchParams({
                name: currentNPCTarget,
                event_limit: '100'
            }).toString()
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();
        if (!result || !result.done) {
            const errorMessage = result && result.error ? result.error : 'AI profile generation failed.';
            throw new Error(errorMessage);
        }

        showDescription(`AI profile generated for ${currentNPCTarget}.`);
        setTimeout(() => {
            closeMenu();
        }, 150);
    } catch (error) {
        console.error('[CHIM Settings] AI Generate Profile failed:', error);
        showDescription(`AI Generate Profile failed: ${error.message || error}`);
    } finally {
        aiGenerateProfileInFlight = false;
        setAIGenerateButtonState(false);
    }
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

    updateActiveHighlights();
}

// Called by C++ to signal that the JavaScript environment is ready
window.chimSettingsMenuReady = function() {
    console.log('[CHIM Settings] JS ready callback received');
};

// Handle option selection
function selectOption(optionId) {
    console.log('[CHIM Settings] Selected option:', optionId);

    if (optionId === 'rp_ai_generate_profile') {
        triggerAIGenerateProfile();
        return;
    }

    if (optionId === 'open_create_rumor') {
        openRumorModal();
        return;
    }
    
    // If NPC-targeted action, include NPC name
    let command = optionId;
    if (currentNPCTarget && currentNPCTarget !== '' && currentNPCTarget !== 'none') {
        // NPC-specific actions
        const npcActions = ['rp_write_diary', 'rp_update_npc', 'rp_wait', 'rp_follow', 'rp_rename', 'continue_chat', 'profile_1', 'profile_2', 'profile_3', 'profile_4'];
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

    if (optionId.startsWith('mode_') || optionId.startsWith('llm_') || optionId.startsWith('profile_')) {
        scheduleActiveStateRefresh();
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
        setAIGenerateButtonState(false);
        fetchNpcProfileState();
    } else {
        // Hide NPC-specific sections
        document.getElementById('npc-settings').style.display = 'none';
        document.getElementById('roleplay-npc-actions').style.display = 'none';
        currentNPCTarget = '';
        setAIGenerateButtonState(false);
        activeNpcProfileId = null;
        activeNpcProfileLabel = '';
        updateActiveHighlights();
    }
};

// ─── HUD Layout / Corner Placement ──────────────────────────────────────────

/**
 * Set the corner for a specific view.
 * Called from the HTML onclick handlers: setViewCorner('overlay', 'top-left')
 *
 * @param {string} viewId   e.g. 'chatbox', 'overlay', 'status_hud', 'aiview_left' …
 * @param {string} corner   'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
 */
window.setViewCorner = function(viewId, corner) {
    // Apply and persist immediately
    if (window.chimLayout) {
        window.chimLayout.setCorner(viewId, corner);
    }

    // Highlight the active button in the picker for this view
    var picker = document.querySelector('.corner-picker[data-view="' + viewId + '"]');
    if (picker) {
        var btns = picker.querySelectorAll('.corner-btn');
        for (var i = 0; i < btns.length; i++) {
            var btn = btns[i];
            if (btn.getAttribute('data-corner') === corner) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        }
    }
};

/** Reset all layout settings to their defaults */
window.resetLayoutDefaults = function() {
    if (!window.chimLayout) return;
    
    var defaults = window.chimLayout.views;
    for (var viewId in defaults) {
        if (defaults.hasOwnProperty(viewId)) {
            window.setViewCorner(viewId, defaults[viewId]);
        }
    }
    
    // Reset gap
    window.updateLayoutGap(20);
    var slider = document.getElementById('layout-gap-slider');
    if (slider) slider.value = 20;
    
    // Show feedback
    showDescription('Layout reset to defaults!');
    setTimeout(clearDescription, 2000);
};

/** Update the gap from screen edges */
window.updateLayoutGap = function(value) {
    var gap = parseInt(value, 10);
    var valueDisplay = document.getElementById('layout-gap-value');
    if (valueDisplay) {
        valueDisplay.textContent = gap + 'px';
    }
    
    if (window.chimLayout) {
        window.chimLayout.setGap(gap);
    }
};

/** Restore all saved corner highlights when the settings menu opens */
function initLayoutPickers() {
    if (!window.chimLayout) return;
    
    // Restore gap
    var gap = window.chimLayout.getGap();
    var slider = document.getElementById('layout-gap-slider');
    var valueDisplay = document.getElementById('layout-gap-value');
    if (slider) slider.value = gap;
    if (valueDisplay) valueDisplay.textContent = gap + 'px';
    
    var pickers = document.querySelectorAll('.corner-picker[data-view]');
    for (var i = 0; i < pickers.length; i++) {
        var picker = pickers[i];
        var viewId = picker.getAttribute('data-view');
        var saved  = window.chimLayout.getCorner(viewId);
        
        var btns = picker.querySelectorAll('.corner-btn');
        for (var j = 0; j < btns.length; j++) {
            var btn = btns[j];
            if (btn.getAttribute('data-corner') === saved) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────

// Initialize on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        bindServerUrlUpdates();
        initSettingsMenu();
        initLayoutPickers();
    });
} else {
    bindServerUrlUpdates();
    initSettingsMenu();
    initLayoutPickers();
}
