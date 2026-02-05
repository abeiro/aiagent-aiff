/**
 * CHIM Status HUD
 * Lightweight JavaScript for pipeline status monitoring
 */

(function() {
    'use strict';

    // Configuration
    const POLL_INTERVAL = 500;
    let serverUrl = '';
    
    // DOM Elements
    const thinkingStatus = document.getElementById('thinking-status');
    const voiceStatus = document.getElementById('voice-status');
    const modeBadge = document.getElementById('mode-badge');
    const modelBadge = document.getElementById('model-badge');
    const focusIndicator = document.getElementById('focus-indicator');
    const targetRow = document.getElementById('target-row');
    const targetName = document.getElementById('target-name');
    
    // Mode configuration
    const modeConfig = {
        'STANDARD': { label: 'Standard', class: '' },
        'WHISPER': { label: 'Whisper', class: 'whisper' },
        'DIRECTOR': { label: 'Director', class: 'director' },
        'SPAWN': { label: 'Spawn', class: 'director' },
        'CHEATMODE': { label: 'Cheat', class: 'cheatmode' },
        'AUTOCHAT': { label: 'Auto', class: 'autochat' },
        'INJECTION_LOG': { label: 'Inject', class: 'director' },
        'INJECT_LOG': { label: 'Inject', class: 'director' }
    };
    
    // Model slot configuration
    const modelConfig = {
        'standard': { label: 'Std', class: 'standard' },
        'fast': { label: 'Fast', class: 'fast' },
        'powerful': { label: 'Power', class: 'powerful' },
        'experimental': { label: 'Exp', class: 'experimental' }
    };
    
    // State
    let pollTimer = null;
    let initialized = false;

    /**
     * Update status from API response
     */
    function updateStatus(data) {
        if (!data || !data.data) return;
        
        const status = data.data;
        const pipeline = status.pipeline || {};
        
        // Thinking = LLM/STT/PlayerTTS active
        const isThinking = pipeline.llm || pipeline.stt || pipeline.player_tts;
        thinkingStatus.classList.toggle('active', isThinking);
        
        // Voice = TTS playing
        voiceStatus.classList.toggle('active', !!pipeline.tts);
        
        // Mode
        updateMode(status.mode);
        
        // Model slot
        updateModelSlot(status.model_slot_label);
        
        // Focus chat
        focusIndicator.classList.toggle('active', !!status.focus_chat);
    }
    
    /**
     * Update mode badge
     */
    function updateMode(mode) {
        const modeUpper = mode ? mode.toUpperCase().trim() : 'STANDARD';
        const config = modeConfig[modeUpper] || { label: mode || 'Standard', class: '' };
        
        modeBadge.textContent = config.label;
        modeBadge.className = 'badge mode-badge' + (config.class ? ' ' + config.class : '');
    }
    
    /**
     * Update model slot badge
     */
    function updateModelSlot(slotLabel) {
        const slotLower = slotLabel ? slotLabel.toLowerCase().trim() : 'standard';
        const config = modelConfig[slotLower] || { label: slotLabel || 'Std', class: 'standard' };
        
        modelBadge.textContent = config.label;
        modelBadge.className = 'badge model-badge ' + config.class;
    }
    
    /**
     * Update target NPC (called from C++)
     */
    function updateTarget(name, distance) {
        if (name && name.length > 0) {
            targetRow.classList.add('has-target');
            targetName.textContent = name;
            targetName.title = distance > 0 ? name + ' (' + distance.toFixed(1) + 'm)' : name;
        } else {
            targetRow.classList.remove('has-target');
            targetName.textContent = '—';
            targetName.title = '';
        }
    }
    
    /**
     * Fetch status from API
     */
    function fetchStatus() {
        if (!serverUrl) return;
        
        fetch(serverUrl + '/ui/api/chim_status.php', { method: 'GET', cache: 'no-cache' })
            .then(r => r.ok ? r.json() : Promise.reject('HTTP ' + r.status))
            .then(data => { if (data.success) updateStatus(data); })
            .catch(e => console.error('Status fetch error:', e));
    }
    
    /**
     * Start polling
     */
    function startPolling() {
        if (pollTimer) clearInterval(pollTimer);
        fetchStatus();
        pollTimer = setInterval(fetchStatus, POLL_INTERVAL);
    }
    
    /**
     * Stop polling
     */
    function stopPolling() {
        if (pollTimer) {
            clearInterval(pollTimer);
            pollTimer = null;
        }
    }
    
    /**
     * Visibility change handler
     */
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            stopPolling();
        } else if (initialized) {
            startPolling();
        }
    });
    
    /**
     * Initialize (called from C++)
     */
    function initStatusHUD(url) {
        if (initialized) return;
        serverUrl = url;
        initialized = true;
        console.log('CHIM Status HUD: Init with', serverUrl);
        startPolling();
    }
    
    // Cleanup
    window.addEventListener('beforeunload', stopPolling);
    
    // Expose to C++
    window.initStatusHUD = initStatusHUD;
    window.updateStatusHUDTarget = updateTarget;
    
    // Expose controls
    window.chimStatusHUD = {
        start: startPolling,
        stop: stopPolling,
        refresh: fetchStatus,
        init: initStatusHUD,
        updateTarget: updateTarget
    };
    
})();
