/**
 * CHIM Chatbox JavaScript
 * Handles MMO-style chat interface with tabs and real-time updates
 * Focus text composition is handled by a centered modal
 */

(function() {
    'use strict';

    // DOM Elements
    const chatMessages = document.getElementById('chat-messages');
    const systemMessages = document.getElementById('system-messages');
    const chatboxRoot = document.getElementById('chim-chatbox');
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabPanes = document.querySelectorAll('.tab-pane');
    const focusModal = document.getElementById('focus-chatbox-modal');
    const focusInput = document.getElementById('focus-chatbox-input');
    const currentTargetElement = document.getElementById('chatbox-current-target');
    const currentModeElement = document.getElementById('chatbox-current-mode');
    const modeSelectElement = document.getElementById('chatbox-mode-select');
    const focusIndicatorElement = document.getElementById('chatbox-focus-indicator');
    const focusToggleButton = document.getElementById('chatbox-focus-toggle');

    // State
    let currentTab = 'chat';
    const maxMessages = 100;
    let systemLogRefreshInterval = null;
    let isChatFocused = false;
    let quickChatMode = false;
    let isFocusChatEnabled = false;
    let currentModeAction = 'mode_standard';
    
    // Server URL
    const SERVER_URL = window.CHIM_SERVER_URL || 'http://192.168.169.218:8081/HerikaServer';

    const modeConfig = {
        STANDARD: { label: 'Standard', class: 'standard', action: 'mode_standard' },
        WHISPER: { label: 'Whisper', class: 'whisper', action: 'mode_whisper' },
        DIRECTOR: { label: 'Director', class: 'director', action: 'mode_director' },
        SPAWN: { label: 'Spawn', class: 'director', action: 'mode_spawn' },
        CHEATMODE: { label: 'Cheat Mode', class: 'cheatmode', action: 'mode_cheat' },
        AUTOCHAT: { label: 'Auto Chat', class: 'autochat', action: 'mode_autochat' },
        INJECTION_LOG: { label: 'Event Inject', class: 'director', action: 'mode_inject_log' },
        INJECTION_CHAT: { label: 'Inject & Chat', class: 'director', action: 'mode_inject_chat' }
    };

    /**
     * Switch between Chat and System tabs
     */
    window.switchTab = function(tabName) {
        currentTab = tabName;
        tabButtons.forEach(btn => btn.classList.toggle('active', btn.dataset.tab === tabName));
        tabPanes.forEach(pane => pane.classList.toggle('active', pane.id === 'tab-' + tabName));

        if (tabName === 'system') {
            fetchSystemLogs();
            if (!systemLogRefreshInterval) {
                systemLogRefreshInterval = setInterval(fetchSystemLogs, 30000);
            }
        } else if (systemLogRefreshInterval) {
            clearInterval(systemLogRefreshInterval);
            systemLogRefreshInterval = null;
        }
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
        if (!message) return;
        level = level || 'info';
        timestamp = timestamp || getCurrentTime();

        var logDiv = document.createElement('div');
        logDiv.className = 'log-entry ' + level;

        var timestampSpan = document.createElement('span');
        timestampSpan.className = 'log-timestamp';
        timestampSpan.textContent = timestamp;

        var levelSpan = document.createElement('span');
        levelSpan.className = 'log-level';
        levelSpan.textContent = level;

        var messageSpan = document.createElement('span');
        messageSpan.className = 'log-message';
        messageSpan.textContent = message;

        logDiv.appendChild(timestampSpan);
        logDiv.appendChild(levelSpan);
        logDiv.appendChild(messageSpan);
        systemMessages.appendChild(logDiv);

        while (systemMessages.children.length > maxMessages) {
            systemMessages.removeChild(systemMessages.firstChild);
        }
        systemMessages.scrollTop = systemMessages.scrollHeight;
    };

    /**
     * Fetch system logs from server
     */
    async function fetchSystemLogs() {
        try {
            var response = await fetch(SERVER_URL + '/ui/api/chim_debugger_logs.php?type=chim&lines=50');
            if (!response.ok) return;
            var data = await response.json();
            if (!data.success || !data.lines) return;

            systemMessages.innerHTML = '';
            data.lines.forEach(function(line) {
                var text = line.text || '';
                var type = line.type || 'info';
                var match = text.match(/^\[(.*?)\]\s*\[(.*?)\]\s*(.*)$/);
                if (match) {
                    window.pushSystemLog(type, match[3], formatTimestamp(match[1]));
                } else {
                    window.pushSystemLog(type, text);
                }
            });
        } catch (_err) {
            // Network error, ignore
        }
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
        if (!focusIndicatorElement || !focusToggleButton) return;
        focusIndicatorElement.classList.remove('on', 'off');
        focusIndicatorElement.classList.add(enabled ? 'on' : 'off');
        focusIndicatorElement.textContent = enabled ? 'ON' : 'OFF';
        focusToggleButton.textContent = enabled ? 'Disable' : 'Enable';
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
     * Open centered focus chat modal
     */
    window.openFocusChatbox = function() {
        if (!focusModal || !focusInput) return;
        focusModal.classList.remove('hidden');
        focusModal.setAttribute('aria-hidden', 'false');
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
        isChatFocused = false;
        quickChatMode = false;
        setChatboxViewerVisible(true);
        window.closeFocusChatbox(false);
    };

    window.updateChatboxTarget = function(name, distance) {
        if (!currentTargetElement) return;
        if (name && name !== '') {
            currentTargetElement.innerHTML = `
                <span class="target-name">${escapeHtml(name)}</span>
                <span class="target-distance">(${distance.toFixed(1)}m)</span>
            `;
        } else {
            currentTargetElement.innerHTML = '<span class="target-name no-target">No target</span>';
        }
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

    if (focusToggleButton) {
        focusToggleButton.addEventListener('click', function() {
            sendControlCommand('focus_chat_toggle');
        });
    }

    updateFocusIndicator(isFocusChatEnabled);
    window.updateChatboxMode('STANDARD');

    window.addEventListener('beforeunload', function() {
        if (systemLogRefreshInterval) {
            clearInterval(systemLogRefreshInterval);
        }
    });

    console.log('[Chatbox] Initialized - display mode + focus modal input');
})();
