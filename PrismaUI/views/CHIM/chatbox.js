/**
 * CHIM Chatbox JavaScript
 * Handles MMO-style chat interface with tabs and real-time updates
 * Keyboard input is forwarded from C++ via Windows API polling
 */

(function() {
    'use strict';

    // DOM Elements
    const chatMessages = document.getElementById('chat-messages');
    const systemMessages = document.getElementById('system-messages');
    const chatInput = document.getElementById('chat-input');
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabPanes = document.querySelectorAll('.tab-pane');

    // State
    let currentTab = 'chat';
    let maxMessages = 100;
    let systemLogRefreshInterval = null;
    let isChatFocused = false;
    
    // Server URL
    const SERVER_URL = window.CHIM_SERVER_URL || 'http://192.168.169.218:8081/HerikaServer';

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
     * Send user message
     */
    window.sendMessage = function() {
        var message = chatInput.value.trim();
        if (!message) return;

        // DON'T push to UI here - C++ will push it after sending with actual player name
        // This prevents double entries (one with "Player", one with actual name like "RANGROO")
        // window.pushChatMessage('Player', message, getCurrentTime(), 'player');
        
        if (window.chimChatboxCommand) {
            window.chimChatboxCommand('send|' + message);
        }
        chatInput.value = '';
    };

    /**
     * Close chatbox
     */
    window.closeChat = function() {
        if (window.chimChatboxCommand) {
            window.chimChatboxCommand('close');
        }
    };

    // ===== Keyboard input from C++ =====
    // PrismaUI/CEF doesn't forward keyboard events to JS document listeners.
    // Instead, C++ polls GetAsyncKeyState and calls these functions directly.

    /**
     * Called from C++ when a printable character key is pressed
     */
    window.onKeyChar = function(ch) {
        if (!isChatFocused) return;
        chatInput.value += ch;
    };

    /**
     * Called from C++ when a special key is pressed
     */
    window.onKeySpecial = function(key) {
        if (key === 'enter') {
            if (chatInput.value.trim()) {
                // Has text - send message but stay focused for more typing
                window.sendMessage();
            } else {
                // Empty input - unfocus and resume game
                if (window.chimChatboxCommand) {
                    window.chimChatboxCommand('unfocus');
                }
            }
            return;
        }

        if (key === 'escape') {
            // Just unfocus without sending
            chatInput.value = '';
            if (window.chimChatboxCommand) {
                window.chimChatboxCommand('unfocus');
            }
            return;
        }

        if (!isChatFocused) return;

        if (key === 'backspace') {
            if (chatInput.value.length > 0) {
                chatInput.value = chatInput.value.slice(0, -1);
            }
        } else if (key === 'delete') {
            // For simplicity, same as backspace (no cursor tracking needed)
            if (chatInput.value.length > 0) {
                chatInput.value = chatInput.value.slice(0, -1);
            }
        }
        // left, right, home, end - not needed for simple text input
    };

    /**
     * Called when chatbox gains focus from C++
     */
    window.onChatboxFocused = function() {
        isChatFocused = true;
        chatInput.classList.add('focused');
        chatInput.placeholder = 'Type a message... (Enter to send, Esc to cancel)';
    };

    /**
     * Called when chatbox loses focus from C++
     */
    window.onChatboxUnfocused = function() {
        isChatFocused = false;
        chatInput.classList.remove('focused');
        chatInput.placeholder = 'Type a message...';
    };

    /**
     * Send message if present, called from C++ before unfocusing
     */
    window.sendMessageBeforeUnfocus = function() {
        if (chatInput && chatInput.value.trim()) {
            window.sendMessage();
        }
    };

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

    window.addEventListener('beforeunload', function() {
        if (systemLogRefreshInterval) {
            clearInterval(systemLogRefreshInterval);
        }
    });

    console.log('[Chatbox] Initialized - keyboard input handled via C++ forwarding');
})();
