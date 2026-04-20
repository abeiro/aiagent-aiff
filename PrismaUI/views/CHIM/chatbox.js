/**
 * CHIM Chatbox JavaScript
 * Handles MMO-style chat interface and real-time updates
 * Focus text composition is handled by a centered modal
 */

(function() {
    'use strict';

    // DOM Elements
    const chatMessages = document.getElementById('chat-messages');
    const chatboxRoot = document.getElementById('chim-chatbox');
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabPanes = document.querySelectorAll('.tab-pane');
    const focusModal = document.getElementById('focus-chatbox-modal');
    const focusInput = document.getElementById('focus-chatbox-input');
    const currentTargetElement = document.getElementById('chatbox-current-target');
    const targetsListElement = document.getElementById('chatbox-targets-list');
    const currentModeElement = document.getElementById('chatbox-current-mode');
    const modeSelectElement = document.getElementById('chatbox-mode-select');
    const currentModelElement = document.getElementById('chatbox-current-model');
    const modelSelectElement = document.getElementById('chatbox-model-select');
    const focusToggleButton = document.getElementById('chatbox-focus-toggle');

    // State
    let currentTab = 'chat';
    const maxMessages = 100;
    let isChatFocused = false;
    let quickChatMode = false;
    let isFocusChatEnabled = false;
    let currentModeAction = 'mode_standard';
    let currentModelAction = 'llm_standard';
    let currentTargetName = '';
    let currentTargetFormId = 0;
    let currentTargetOverrideActive = false;
    let currentTargetOverrideMode = 'auto';
    
    // Server URL
    const SERVER_URL = window.CHIM_SERVER_URL || 'http://192.168.169.218:8081/HerikaServer';

    const modeConfig = {
        STANDARD: { label: 'Standard', class: 'standard', action: 'mode_standard' },
        WHISPER: { label: 'Whisper', class: 'whisper', action: 'mode_whisper' },
        NARRATOR: { label: 'Narrator', class: 'narrator', action: 'mode_narrator' },
        DIRECTOR: { label: 'Director', class: 'director', action: 'mode_director' },
        SPAWN: { label: 'Spawn', class: 'director', action: 'mode_spawn' },
        CHEATMODE: { label: 'Cheat Mode', class: 'cheatmode', action: 'mode_cheat' },
        AUTOCHAT: { label: 'Auto Chat', class: 'autochat', action: 'mode_autochat' },
        INJECTION_LOG: { label: 'Event Inject', class: 'director', action: 'mode_inject_log' },
        INJECTION_CHAT: { label: 'Inject & Chat', class: 'director', action: 'mode_inject_chat' }
    };

    const modelConfig = {
        standard: { label: 'Standard', class: 'standard', action: 'llm_standard' },
        fast: { label: 'Fast', class: 'fast', action: 'llm_fast' },
        powerful: { label: 'Powerful', class: 'powerful', action: 'llm_powerful' },
        experimental: { label: 'Experimental', class: 'experimental', action: 'llm_experimental' }
    };

    /**
     * Switch between available chatbox tabs.
     */
    window.switchTab = function(tabName) {
        currentTab = tabName;
        tabButtons.forEach(btn => btn.classList.toggle('active', btn.dataset.tab === tabName));
        tabPanes.forEach(pane => pane.classList.toggle('active', pane.id === 'tab-' + tabName));
    };

    /**
     * Push a new chat message (called from C++ via Invoke)
     */
    window.pushChatMessage = function(speaker, text, timestamp, type) {
        if (!speaker || !text) return;
        type = type || 'npc';
        timestamp = timestamp || getCurrentTime();

        var messageDiv = document.createElement('div');
        messageDiv.className = 'message ' + type;

        var headerDiv = document.createElement('div');
        headerDiv.className = 'message-header';

        var speakerSpan = document.createElement('span');
        speakerSpan.className = 'message-speaker';
        speakerSpan.textContent = speaker;

        var timestampSpan = document.createElement('span');
        timestampSpan.className = 'message-timestamp';
        timestampSpan.textContent = timestamp;

        headerDiv.appendChild(speakerSpan);
        headerDiv.appendChild(timestampSpan);

        var textDiv = document.createElement('div');
        textDiv.className = 'message-text';
        textDiv.textContent = text;

        messageDiv.appendChild(headerDiv);
        messageDiv.appendChild(textDiv);
        chatMessages.appendChild(messageDiv);

        while (chatMessages.children.length > maxMessages) {
            chatMessages.removeChild(chatMessages.firstChild);
        }
        chatMessages.scrollTop = chatMessages.scrollHeight;
    };

    /**
     * Push a system log entry (called from C++ via Invoke)
     */
    window.pushSystemLog = function(level, message, timestamp) {
        // System tab removed from chatbox view. Keep bridge hook as a harmless no-op.
    }

    /**
     * Send user message through Prisma bridge
     */
    function sendMessageToBridge(message) {
        if (!message || !message.trim()) return;
        if (window.chimChatboxCommand) {
            window.chimChatboxCommand('send|' + message);
        }
    }

    function sendControlCommand(command) {
        if (window.chimChatboxCommand) {
            window.chimChatboxCommand(command);
        }
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function updateFocusIndicator(enabled) {
        if (!focusToggleButton) return;
        focusToggleButton.classList.remove('on', 'off');
        focusToggleButton.classList.add(enabled ? 'on' : 'off');
        focusToggleButton.textContent = enabled ? 'ON' : 'OFF';
        focusToggleButton.setAttribute('aria-pressed', enabled ? 'true' : 'false');
        focusToggleButton.title = enabled ? 'Disable Focus Chat' : 'Enable Focus Chat';
    }

    /**
     * Close chatbox
     */
    window.closeChat = function() {
        window.closeFocusChatbox(false);
        isChatFocused = false;
        quickChatMode = false;
        if (window.chimChatboxCommand) {
            window.chimChatboxCommand('close');
        }
    };

    /**
     * Prepare the quick text chat mode before the Prisma view is shown/focused.
     * This keeps the tabbed chat/history viewer hidden so only the modal is exposed.
     */
    window.prepareQuickChatFocus = function() {
        quickChatMode = true;
        currentTab = 'chat';
        setChatboxViewerVisible(false);
        if (focusModal) {
            focusModal.classList.add('hidden');
            focusModal.setAttribute('aria-hidden', 'true');
        }
        if (focusInput) {
            focusInput.value = '';
            focusInput.blur();
        }
        window.switchTab('chat');
    };

    /**
     * Open centered focus chat modal
     */
    window.openFocusChatbox = function() {
        if (!focusModal || !focusInput) return;
        focusModal.classList.remove('hidden');
        focusModal.setAttribute('aria-hidden', 'false');
        focusInput.value = '';
        setTimeout(function() {
            focusInput.focus();
            focusInput.selectionStart = focusInput.value.length;
            focusInput.selectionEnd = focusInput.value.length;
        }, 0);
    };

    /**
     * Close centered focus chat modal
     */
    window.closeFocusChatbox = function(notifyBridge) {
        if (!focusModal || !focusInput) return;
        const shouldNotifyBridge = notifyBridge !== false;
        focusModal.classList.add('hidden');
        focusModal.setAttribute('aria-hidden', 'true');
        focusInput.value = '';
        focusInput.blur();
        if (shouldNotifyBridge && window.chimChatboxCommand) {
            if (quickChatMode) {
                window.chimChatboxCommand('close');
            } else {
                window.chimChatboxCommand('unfocus');
            }
        }
    };

    /**
     * Send message from focus chat modal
     */
    window.sendFocusMessage = function() {
        if (!focusInput) return;
        const message = focusInput.value;
        if (!message.trim()) return;
        sendMessageToBridge(message);
        focusInput.value = '';
        window.closeFocusChatbox(true);
    };

    window.clearFocusMessage = function() {
        if (!focusInput) return;
        focusInput.value = '';
        focusInput.focus();
    };

    window.triggerContinueSpeaking = function() {
        if (!currentTargetName) {
            sendControlCommand('continue_chat');
            return;
        }

        sendControlCommand('continue_chat');
        window.closeFocusChatbox(true);
    };

    window.triggerStopAllDialogue = function() {
        sendControlCommand('stop_all_dialogue');
    };

    window.triggerHaltAIActions = function() {
        sendControlCommand('halt_ai_actions');
    };

    if (focusInput) {
        focusInput.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                e.preventDefault();
                window.closeFocusChatbox(true);
                return;
            }

            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                window.sendFocusMessage();
            }
        });
    }

    /**
     * Called when chatbox gains focus from C++
     */
    window.onChatboxFocused = function(quickChat) {
        isChatFocused = true;
        quickChatMode = !!quickChat;
        setChatboxViewerVisible(!quickChatMode);
        window.openFocusChatbox();
    };

    /**
     * Called when chatbox loses focus from C++
     */
    window.onChatboxUnfocused = function() {
        const wasQuickChatMode = quickChatMode;
        isChatFocused = false;
        quickChatMode = false;
        setChatboxViewerVisible(!wasQuickChatMode);
        window.closeFocusChatbox(false);
    };

    window.updateChatboxTarget = function(name, distance) {
        if (!currentTargetElement) return;
        currentTargetName = name || '';
        const suffix = currentTargetOverrideActive ? '<span class="target-distance">(Override)</span>' : '';
        if (currentTargetOverrideMode === 'everyone') {
            currentTargetElement.innerHTML = `
                <span class="target-name">Everyone</span>
                <span class="target-distance">(Broadcast)</span>
                ${suffix}
            `;
        } else if (name && name !== '') {
            currentTargetElement.innerHTML = `
                <span class="target-name">${escapeHtml(name)}</span>
                <span class="target-distance">(${distance.toFixed(1)}m)</span>
                ${suffix}
            `;
        } else {
            currentTargetElement.innerHTML = '<span class="target-name no-target">No target</span>';
        }
    };

    window.updateChatboxTargets = function(payloadJson) {
        if (!targetsListElement) return;

        let payload = null;
        try {
            payload = JSON.parse(payloadJson);
        } catch (_err) {
            return;
        }

        const targets = Array.isArray(payload.targets) ? payload.targets : [];
        currentTargetOverrideActive = !!payload.override_active;
        currentTargetOverrideMode = payload.override_mode || 'auto';
        currentTargetFormId = Number(payload.active_form_id || 0);
        currentTargetName = payload.active_name || '';

        const parts = [];
        if (payload.show_auto) {
            parts.push(`
                <button class="chatbox-target-item auto-target ${payload.auto_active ? 'active' : ''}" type="button" data-auto="true">
                    <span class="chatbox-target-meta">
                        <span class="chatbox-target-name">Auto</span>
                    </span>
                    <span class="chatbox-target-distance">Mode</span>
                </button>
            `);
        }
        if (payload.show_everyone) {
            parts.push(`
                <button class="chatbox-target-item everyone-target ${payload.everyone_active ? 'active' : ''}" type="button" data-everyone="true">
                    <span class="chatbox-target-meta">
                        <span class="chatbox-target-name">Everyone</span>
                    </span>
                    <span class="chatbox-target-distance">Broadcast</span>
                </button>
            `);
        }

        targets.forEach(function(target) {
            const formId = Number(target.form_id || 0);
            const itemClasses = ['chatbox-target-item'];
            if (target.active) itemClasses.push('active');
            if (target.override) itemClasses.push('override');
            const distanceLabel = target.narrator ? 'Narrator' : `${Number(target.distance || 0).toFixed(1)}m`;
            parts.push(`
                <button class="${itemClasses.join(' ')}" type="button" data-form-id="${formId}" data-target-name="${escapeHtml(target.name || '')}">
                    <span class="chatbox-target-meta">
                        <span class="chatbox-target-name">${escapeHtml(target.name || 'Unknown Target')}</span>
                    </span>
                    <span class="chatbox-target-distance">${escapeHtml(distanceLabel)}</span>
                </button>
            `);
        });

        if (parts.length === 0) {
            parts.push(`<div class="chatbox-target-empty">${escapeHtml(payload.empty_message || 'No spatially available targets right now.')}</div>`);
        }

        targetsListElement.innerHTML = parts.join('');
        const activeTarget = currentTargetOverrideMode === 'everyone' ? null : targets.find(function(target) {
            return Number(target.form_id || 0) === currentTargetFormId || (target.name || '') === currentTargetName;
        });
        window.updateChatboxTarget(currentTargetName, Number(activeTarget ? activeTarget.distance || 0 : 0));
    };

    window.updateChatboxMode = function(mode) {
        const modeUpper = mode ? mode.toUpperCase().trim() : 'STANDARD';
        const config = modeConfig[modeUpper] || modeConfig.STANDARD;
        currentModeAction = config.action;
        if (currentModeElement) {
            currentModeElement.className = 'mode-badge ' + config.class;
            currentModeElement.textContent = config.label;
        }
        if (modeSelectElement) {
            modeSelectElement.value = config.action;
        }
    };

    window.updateChatboxModel = function(modelLabel) {
        const labelLower = modelLabel ? modelLabel.toLowerCase().trim() : 'standard';
        const config = modelConfig[labelLower] || modelConfig.standard;
        currentModelAction = config.action;
        if (currentModelElement) {
            currentModelElement.className = 'mode-badge ' + config.class;
            currentModelElement.textContent = config.label;
        }
        if (modelSelectElement) {
            modelSelectElement.value = config.action;
        }
    };

    window.updateChatboxFocus = function(enabled) {
        isFocusChatEnabled = !!enabled;
        updateFocusIndicator(isFocusChatEnabled);
    };

    function setChatboxViewerVisible(isVisible) {
        if (!chatboxRoot) return;
        chatboxRoot.classList.toggle('focus-only-hidden', !isVisible);
    }

    function getCurrentTime() {
        return new Date().toLocaleTimeString('en-US', { hour12: false });
    }

    function formatTimestamp(timestamp) {
        try {
            return new Date(timestamp).toLocaleTimeString('en-US', { hour12: false });
        } catch (_e) {
            return timestamp;
        }
    }

    if (modeSelectElement) {
        modeSelectElement.addEventListener('change', function() {
            const action = modeSelectElement.value;
            if (!action || action === currentModeAction) return;
            sendControlCommand(action);
        });
    }

    if (modelSelectElement) {
        modelSelectElement.addEventListener('change', function() {
            const action = modelSelectElement.value;
            if (!action || action === currentModelAction) return;
            sendControlCommand(action);
        });
    }

    if (focusToggleButton) {
        focusToggleButton.addEventListener('click', function() {
            sendControlCommand('focus_chat_toggle');
        });
    }

    if (targetsListElement) {
        targetsListElement.addEventListener('click', function(e) {
            const targetButton = e.target.closest('.chatbox-target-item');
            if (!targetButton) return;

            if (targetButton.dataset.auto === 'true') {
                sendControlCommand('target_override_clear');
                return;
            }
            if (targetButton.dataset.everyone === 'true') {
                sendControlCommand('target_override_everyone');
                return;
            }

            const formId = targetButton.dataset.formId || '0';
            const targetName = targetButton.dataset.targetName || '';
            if (!targetName) return;
            sendControlCommand(`target_override|${formId}|${targetName}`);
        });
    }

    updateFocusIndicator(isFocusChatEnabled);
    window.updateChatboxMode('STANDARD');
    window.updateChatboxModel('Standard');

    // Apply corner placement via shared layout manager
    if (window.chimLayout) {
        window.chimLayout.apply(chatboxRoot, 'chatbox');
    }

    console.log('[Chatbox] Initialized - display mode + focus modal input');
})();
