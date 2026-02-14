/**
 * CHIM Overlay
 * JavaScript for displaying system status
 */

(function() {
    'use strict';

    // DOM Elements
    const modeElement = document.getElementById('current-mode');
    const activeModelElement = document.getElementById('active-model');
    const focusChatElement = document.getElementById('focus-chat');
    const agentsListElement = document.getElementById('agents-list');
    const slotsGridElement = document.getElementById('slots-grid');

    // Update timer
    let updateInterval = null;

    // Mode display names and classes
    const modeConfig = {
        'STANDARD': { label: 'Standard', class: 'standard' },
        'WHISPER': { label: 'Whisper', class: 'whisper' },
        'DIRECTOR': { label: 'Director', class: 'director' },
        'SPAWN': { label: 'Spawn', class: 'director' },
        'CHEATMODE': { label: 'Cheat Mode', class: 'cheatmode' },
        'AUTOCHAT': { label: 'Auto Chat', class: 'autochat' },
        'INJECTION_LOG': { label: 'Event Inject', class: 'director' },
        'INJECT_LOG': { label: 'Event Inject', class: 'director' }
    };

    /**
     * Update the overlay with data from the server
     * Called from C++ via PrismaUI->Invoke()
     * @param {string} jsonString - JSON string containing the overlay data
     */
    window.updateOverlay = function(jsonString) {
        try {
            const data = JSON.parse(jsonString);
            
            if (!data.success || !data.data) {
                console.error('Invalid response format');
                return;
            }

            const overlay = data.data;
            
            console.log('Overlay data received:', overlay);
            
            // Update mode
            updateMode(overlay.mode);
            
            // Update active model
            updateActiveModel(overlay.active_model_slot, overlay.active_model_label, overlay.active_model_name);
            
            // Update focus chat
            updateFocusChat(overlay.focus_chat);
            
            // Update active agents
            updateActiveAgents(overlay.active_agents);
            
            // Update profile slots
            updateProfileSlots(overlay.profile_slots, overlay.active_model_slot);
            
        } catch (e) {
            console.error('Error parsing overlay data:', e);
        }
    };

    /**
     * Update the mode display
     */
    function updateMode(mode) {
        const modeUpper = mode ? mode.toUpperCase().trim() : 'STANDARD';
        const config = modeConfig[modeUpper] || { label: mode || 'Unknown', class: 'standard' };
        modeElement.innerHTML = `<span class="mode-badge ${config.class}">${config.label}</span>`;
    }

    /**
     * Update the active model display
     */
    function updateActiveModel(slot, modelLabel, modelName) {
        // Show just the model label with badge styling like mode
        const labelLower = modelLabel ? modelLabel.toLowerCase().trim() : 'standard';
        let modelClass = '';
        
        // Map model labels to CSS classes
        if (labelLower.includes('standard')) {
            modelClass = 'standard';
        } else if (labelLower.includes('fast')) {
            modelClass = 'fast';
        } else if (labelLower.includes('powerful')) {
            modelClass = 'powerful';
        } else if (labelLower.includes('experimental')) {
            modelClass = 'experimental';
        }
        
        activeModelElement.innerHTML = `<span class="mode-badge ${modelClass}">${escapeHtml(modelLabel)}</span>`;
    }

    /**
     * Update the focus chat display
     */
    function updateFocusChat(enabled) {
        const statusClass = enabled ? 'on' : 'off';
        const statusText = enabled ? 'ON' : 'OFF';
        focusChatElement.innerHTML = `<span class="toggle-indicator ${statusClass}">${statusText}</span>`;
    }

    /**
     * Update the active agents list
     */
    function updateActiveAgents(agents) {
        const countElement = document.querySelector('.agent-count');
        
        if (!agents || agents.length === 0) {
            agentsListElement.innerHTML = '<div class="empty-agents">No agents nearby</div>';
            countElement.textContent = '0';
            return;
        }

        countElement.textContent = agents.length.toString();
        
        let html = '';
        agents.forEach(agent => {
            html += `<div class="agent-item">${escapeHtml(agent)}</div>`;
        });
        
        agentsListElement.innerHTML = html;
    }

    /**
     * Update the profile slots grid
     */
    function updateProfileSlots(slots, activeSlot) {
        let html = '';
        
        for (let i = 1; i <= 4; i++) {
            const slot = slots[i];
            const isActive = i === activeSlot;
            
            if (slot) {
                html += `<div class="slot-card ${isActive ? 'active' : ''}">`;
                html += `<div class="slot-header">`;
                html += `<span class="slot-number">Slot ${i}</span>`;
                if (isActive) {
                    html += `<span style="color: rgb(242, 124, 17); font-size: 0.7em;">●</span>`;
                }
                html += `</div>`;
                html += `<div class="slot-profile-name">${escapeHtml(slot.profile_name)}</div>`;
                
                // Show all connectors
                const connectorKeys = Object.keys(slot.connectors);
                if (connectorKeys.length > 0) {
                    connectorKeys.forEach((key) => {
                        const conn = slot.connectors[key];
                        const shortName = key.replace(' LLM', '');
                        html += `<div class="slot-connector">`;
                        html += `<span class="slot-connector-label">${shortName}:</span> `;
                        html += `${escapeHtml(conn.label)}`;
                        html += `</div>`;
                    });
                }
                
                html += `</div>`;
            } else {
                html += `<div class="slot-card empty">`;
                html += `<div class="slot-header">`;
                html += `<span class="slot-number">Slot ${i}</span>`;
                html += `</div>`;
                html += `<div class="empty-slot-text">No profile assigned</div>`;
                html += `</div>`;
            }
        }
        
        slotsGridElement.innerHTML = html;
    }

    /**
     * Escape HTML special characters
     * @param {string} text - Text to escape
     * @returns {string} - Escaped text
     */
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Update the crosshair target display
     * @param {string} name - Name of the targeted NPC
     * @param {number} distance - Distance to the NPC in meters
     */
    window.updateCrosshairTarget = function(name, distance) {
        const targetElement = document.getElementById('crosshair-target');
        if (name && name !== '') {
            targetElement.innerHTML = `
                <span class="target-name">${escapeHtml(name)}</span>
                <span class="target-distance">(${distance.toFixed(1)}m)</span>
            `;
        } else {
            targetElement.innerHTML = '<span class="target-name no-target">No target</span>';
        }
    };

    /**
     * Close the overlay
     */
    window.closeOverlay = function() {
        stopAutoUpdate();
        if (window.chimOverlayCommand) {
            window.chimOverlayCommand('close');
        }
    };

    /**
     * Start auto-updating every 5 seconds
     */
    window.startAutoUpdate = function() {
        stopAutoUpdate(); // Clear any existing interval
        updateInterval = setInterval(function() {
            // Request C++ to fetch and update
            if (window.chimOverlayCommand) {
                window.chimOverlayCommand('refresh');
            }
        }, 5000); // 5 seconds
        console.log('CHIM Overlay auto-update started');
    };

    /**
     * Stop auto-updating
     */
    function stopAutoUpdate() {
        if (updateInterval) {
            clearInterval(updateInterval);
            updateInterval = null;
            console.log('CHIM Overlay auto-update stopped');
        }
    }

    // Initialize with loading state
    console.log('CHIM Overlay initialized');
    
    // Start auto-update when overlay is shown
    window.startAutoUpdate();
    
})();
