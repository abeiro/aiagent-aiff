/**
 * CHIM AI View Panel - Multi-Window HUD
 * JavaScript for displaying NPC profile data
 */

(function() {
    'use strict';

    // DOM Elements
    const targetNameElement = document.getElementById('target-name');
    const targetMetadataElement = document.getElementById('target-metadata');
    
    const loadingLeft = document.getElementById('loading-indicator-left');
    const emptyLeft = document.getElementById('empty-message-left');
    const contentLeft = document.getElementById('content-left');
    
    const loadingRight = document.getElementById('loading-indicator-right');
    const emptyRight = document.getElementById('empty-message-right');
    const contentRight = document.getElementById('content-right');
    
    const loadingBio = document.getElementById('loading-indicator-bio');
    const emptyBio = document.getElementById('empty-message-bio');
    const contentBio = document.getElementById('content-bio');

    // State
    let currentNpc = null;

    /**
     * Update the AI View with data from the server
     * Called from C++ via PrismaUI->Invoke()
     * @param {string} jsonString - JSON string containing the NPC data
     */
    window.updateAIView = function(jsonString) {
        try {
            console.log('Updating AI View with data');
            const response = JSON.parse(jsonString);
            
            // Check if request was successful
            if (!response.success) {
                console.error('Server returned error:', response.error || 'Unknown error');
                
                // If NPC not found in database yet, show a helpful message
                if (response.error && response.error.includes('not found')) {
                    const npcName = response.searched_name || 'NPC';
                    showError(`${npcName} not in database yet. Wait for auto-add or talk to them first.`);
                } else {
                    showError(response.error || 'Failed to load NPC data');
                }
                return;
            }
            
            if (!response.data) {
                console.error('Invalid response format - no data');
                showError('Invalid server response');
                return;
            }

            const data = response.data;
            currentNpc = data;
            
            // Update target bar
            updateTargetBar(data.npc_name, data.race, data.refid);
            
            // Update all sections
            updateProfile(data.profile);
            updateIdentity(data);
            updateRelationships(data.relationships);
            updateSettings(data.settings);
            updateBio(data.bio);
            
            // Show content
            hideLoading();
            hideEmpty();
            contentLeft.classList.remove('hidden');
            contentRight.classList.remove('hidden');
            contentBio.classList.remove('hidden');
            
            console.log('AI View updated successfully');
            
        } catch (e) {
            console.error('Error parsing AI View data:', e);
            showError('Failed to parse server response');
        }
    };

    /**
     * Update target bar at top of screen
     */
    function updateTargetBar(npcName, race, refid) {
        if (npcName) {
            targetNameElement.textContent = npcName;
            targetNameElement.classList.remove('no-target');
            
            // Show metadata
            let metadata = '';
            if (race) {
                metadata += `<span class="target-race">${escapeHtml(race)}</span>`;
            }
            if (refid) {
                metadata += `<span class="target-refid">RefID: ${escapeHtml(refid)}</span>`;
            }
            targetMetadataElement.innerHTML = metadata;
        } else {
            targetNameElement.textContent = 'No NPC Targeted';
            targetNameElement.classList.add('no-target');
            targetMetadataElement.innerHTML = '';
        }
    }

    /**
     * Update the profile section
     */
    function updateProfile(profileData) {
        document.getElementById('profile-label').textContent = profileData.label || 'Unknown Profile';
        
        const connectorList = document.getElementById('connector-list');
        connectorList.innerHTML = '';
        
        if (profileData.connectors) {
            const connectorNames = {
                'primary': 'Primary LLM',
                'secondary': 'Secondary LLM',
                'tertiary': 'Tertiary LLM',
                'quaternary': 'Quaternary LLM',
                'formatter': 'Formatter LLM',
                'diary': 'Diary LLM'
            };
            
            for (const [slot, connector] of Object.entries(profileData.connectors)) {
                if (connector) {
                    const div = document.createElement('div');
                    div.className = 'connector-item';
                    div.innerHTML = `
                        <div class="connector-slot">${connectorNames[slot] || slot}</div>
                        <div class="connector-name">${escapeHtml(connector.label)}</div>
                        <div class="connector-model">${escapeHtml(connector.model || connector.type)}</div>
                    `;
                    connectorList.appendChild(div);
                }
            }
        }
        
        if (connectorList.children.length === 0) {
            connectorList.innerHTML = '<div style="color: #666; font-style: italic; padding: 8px;">No LLM connectors configured</div>';
        }
    }

    /**
     * Update the identity section
     */
    function updateIdentity(data) {
        document.getElementById('npc-gender').textContent = data.gender || 'Unknown';
        document.getElementById('npc-race').textContent = data.race || 'Unknown';
        document.getElementById('npc-base').textContent = data.base || 'N/A';
        document.getElementById('npc-refid').textContent = data.refid || 'N/A';
        document.getElementById('npc-voiceid').textContent = data.voiceid || 'N/A';
        document.getElementById('npc-oghma').textContent = data.oghma_tags || 'None';
    }

    /**
     * Update the settings section
     */
    function updateSettings(settings) {
        updateToggle('setting-dynamic', settings.dynamic_profile);
        updateToggle('setting-mtm', settings.middle_term_memory);
        updateToggle('setting-diary', settings.auto_diary);
        updateToggle('setting-diary-wait', settings.auto_diary_wait);
        updateToggle('setting-salutations', settings.auto_salutations);
    }

    /**
     * Update a toggle indicator - show ON/OFF and source (inherited vs override)
     */
    function updateToggle(elementId, settingData) {
        const element = document.getElementById(elementId);
        
        // settingData is now {value: bool, source: 'npc'|'profile'|'default'}
        const isOn = settingData.value === true || settingData.value === 1 || settingData.value === '1';
        const source = settingData.source || 'default';
        
        if (isOn) {
            element.textContent = 'ON';
            element.className = 'toggle-value on';
        } else {
            element.textContent = 'OFF';
            element.className = 'toggle-value off';
        }
        
        // Add indicator if inherited from profile
        if (source === 'profile') {
            element.classList.add('inherited');
            element.title = 'Inherited from profile';
        } else if (source === 'npc') {
            element.title = 'NPC override';
        } else {
            element.title = 'Default value';
        }
    }

    /**
     * Update the bio section
     */
    function updateBio(bio) {
        // Hide prompt head if empty
        const promptHeadContainer = document.getElementById('bio-prompt-head-container');
        if (!bio.prompt_head || bio.prompt_head.trim() === '') {
            promptHeadContainer.style.display = 'none';
        } else {
            promptHeadContainer.style.display = 'block';
            document.getElementById('bio-prompt-head').textContent = bio.prompt_head;
        }
        
        document.getElementById('bio-core').textContent = bio.core || '';
        document.getElementById('bio-static').textContent = bio.static_bio || '';
        document.getElementById('bio-appearance').textContent = bio.appearance || '';
        document.getElementById('bio-personality').textContent = bio.personality || '';
        document.getElementById('bio-occupation').textContent = bio.occupation || '';
        document.getElementById('bio-skills').textContent = bio.skills || '';
        document.getElementById('bio-speechstyle').textContent = bio.speechstyle || '';
        document.getElementById('bio-goals').textContent = bio.goals || '';
    }

    /**
     * Update the relationships section
     */
    function updateRelationships(relationshipsData) {
        const textElement = document.getElementById('relationship-text');
        const affinityList = document.getElementById('affinity-list');
        
        // Update relationship text
        if (relationshipsData.text && relationshipsData.text.trim() !== '') {
            textElement.textContent = relationshipsData.text;
            textElement.style.color = '#ccc';
            textElement.style.fontStyle = 'normal';
        } else {
            textElement.textContent = 'No relationship data available.';
            textElement.style.color = '#666';
            textElement.style.fontStyle = 'italic';
        }
        
        // Update affinity list
        affinityList.innerHTML = '';
        
        if (relationshipsData.affinities && Object.keys(relationshipsData.affinities).length > 0) {
            for (const [npcName, affinity] of Object.entries(relationshipsData.affinities)) {
                const item = document.createElement('div');
                item.className = 'affinity-item';
                
                const affinityValue = parseInt(affinity) || 0;
                let valueClass = 'neutral';
                if (affinityValue > 0) valueClass = 'positive';
                else if (affinityValue < 0) valueClass = 'negative';
                
                item.innerHTML = `
                    <span class="affinity-npc">${escapeHtml(npcName)}</span>
                    <span class="affinity-value ${valueClass}">${affinityValue > 0 ? '+' : ''}${affinityValue}</span>
                `;
                
                affinityList.appendChild(item);
            }
        } else {
            affinityList.innerHTML = '<div style="color: #666; font-style: italic; padding: 8px; text-align: center;">No relationship affinities tracked</div>';
        }
    }

    /**
     * Escape HTML special characters
     */
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Show the loading indicator
     */
    function showLoading() {
        loadingLeft.classList.remove('hidden');
        loadingRight.classList.remove('hidden');
        loadingBio.classList.remove('hidden');
        emptyLeft.classList.add('hidden');
        emptyRight.classList.add('hidden');
        emptyBio.classList.add('hidden');
        contentLeft.classList.add('hidden');
        contentRight.classList.add('hidden');
        contentBio.classList.add('hidden');
    }

    /**
     * Hide the loading indicator
     */
    function hideLoading() {
        loadingLeft.classList.add('hidden');
        loadingRight.classList.add('hidden');
        loadingBio.classList.add('hidden');
    }

    /**
     * Show the empty message
     */
    function showEmpty() {
        hideLoading();
        emptyLeft.classList.remove('hidden');
        emptyRight.classList.remove('hidden');
        emptyBio.classList.remove('hidden');
        contentLeft.classList.add('hidden');
        contentRight.classList.add('hidden');
        contentBio.classList.add('hidden');
        updateTargetBar(null);
    }

    /**
     * Hide the empty message
     */
    function hideEmpty() {
        emptyLeft.classList.add('hidden');
        emptyRight.classList.add('hidden');
        emptyBio.classList.add('hidden');
    }

    /**
     * Close the panel
     */
    window.closePanel = function() {
        if (window.chimAIViewCommand) {
            window.chimAIViewCommand('close');
        }
    };

    /**
     * Update with target NPC info from C++
     * @param {string} npcName - Name of the NPC
     * @param {string} refid - Reference ID of the NPC
     */
    window.setTargetNPC = function(npcName, refid) {
        console.log('Target NPC set:', npcName, refid);
        updateTargetBar(npcName, null, refid);
        showLoading();
    };

    /**
     * Clear the target (no NPC selected)
     * Called from C++ when player looks away from all NPCs
     */
    window.clearTarget = function() {
        console.log('Target cleared');
        currentNpc = null;
        updateTargetBar(null);
        showEmpty();
    };

    /**
     * Show an error message
     * @param {string} message - Error message to display
     */
    window.showError = function(message) {
        console.error('AI View error:', message);
        hideLoading();
        
        // Show error in all panels
        emptyLeft.querySelector('p').textContent = message;
        emptyRight.querySelector('p').textContent = message;
        emptyBio.querySelector('p').textContent = message;
        emptyLeft.classList.remove('hidden');
        emptyRight.classList.remove('hidden');
        emptyBio.classList.remove('hidden');
        contentLeft.classList.add('hidden');
        contentRight.classList.add('hidden');
        contentBio.classList.add('hidden');
        
        // Keep the target name in the header if we have one
        // Don't clear it, so user knows which NPC triggered the error
    };

    // Initialize
    showLoading();
    console.log('CHIM AI View (Multi-Window HUD) initialized');
    
})();
