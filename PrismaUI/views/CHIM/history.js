/**
 * CHIM Conversation History Panel
 * JavaScript for handling UI updates and interactions
 */

(function() {
    'use strict';

    // DOM Elements
    const historyList = document.getElementById('history-list');
    const loadingIndicator = document.getElementById('loading-indicator');
    const emptyMessage = document.getElementById('empty-message');

    // State
    let entries = [];
    let lastRowId = 0;

    /**
     * Update the history panel with data from the server
     * Called from C++ via PrismaUI->Invoke()
     * @param {string} jsonString - JSON string containing the event data
     */
    window.updateHistory = function(jsonString) {
        try {
            const data = JSON.parse(jsonString);
            
            if (!data.success || !data.data) {
                console.error('Invalid response format');
                showEmpty();
                return;
            }

            hideLoading();

            if (data.data.length === 0) {
                showEmpty();
                return;
            }

            hideEmpty();
            
            // Keep entries in DESC order (newest first at top, oldest at bottom)
            entries = data.data;
            
            renderEntries();
            
            // Update last row ID for incremental updates (first entry is most recent)
            if (entries.length > 0 && entries[0].ROWID) {
                lastRowId = parseInt(entries[0].ROWID);
            }
            
        } catch (e) {
            console.error('Error parsing history data:', e);
            showEmpty();
        }
    };

    /**
     * Push a single new entry to the panel
     * Called from C++ for real-time updates
     * @param {string} jsonString - JSON string containing a single entry
     */
    window.pushEntry = function(jsonString) {
        try {
            const entry = JSON.parse(jsonString);
            
            // Skip context history entries
            const speakerText = entry.speaker || '';
            const textContent = entry.text || '';
            if (speakerText.startsWith('Context History') || 
                speakerText.startsWith('Context location') ||
                textContent.startsWith('Context History') ||
                textContent.startsWith('Context location') ||
                textContent.includes('(Context location:')) {
                return; // Skip this entry
            }
            
            hideEmpty();
            
            const entryEl = createEntryElement({
                'Event': entry.eventType || 'chat',
                'Events': entry.speaker + ': ' + entry.text,
                'Tamrielic Time': entry.timestamp || ''
            });
            
            // Prepend new entry at top (newest first)
            historyList.insertBefore(entryEl, historyList.firstChild);
            
            // Scroll to top to show the new entry
            historyList.scrollTop = 0;
            
        } catch (e) {
            console.error('Error pushing entry:', e);
        }
    };

    /**
     * Render all entries to the DOM
     */
    function renderEntries() {
        historyList.innerHTML = '';
        
        // Entries are already in DESC order (newest first)
        // Filter out "Context History" entries
        entries.forEach(entry => {
            const eventData = stripHtml(entry['Events'] || '');
            
            // Skip entries that start with "Context History" or "Context location"
            if (eventData.startsWith('Context History') || 
                eventData.startsWith('Context location') ||
                eventData.includes('(Context location:')) {
                return; // Skip this entry
            }
            
            const entryEl = createEntryElement(entry);
            historyList.appendChild(entryEl);
        });
        
        // Scroll to top (newest entries are at top)
        historyList.scrollTop = 0;
    }

    /**
     * Strip HTML tags from a string
     * @param {string} html - String potentially containing HTML
     * @returns {string} - Clean text without HTML
     */
    function stripHtml(html) {
        if (!html) return '';
        // First decode HTML entities, then strip tags
        const temp = document.createElement('div');
        temp.innerHTML = html;
        return temp.textContent || temp.innerText || '';
    }

    /**
     * Create a DOM element for a history entry
     * @param {Object} entry - Entry data from the server
     * @returns {HTMLElement} - The entry element
     */
    function createEntryElement(entry) {
        const div = document.createElement('div');
        div.className = 'history-entry';
        
        // Parse the event data - strip HTML from all fields
        const eventType = stripHtml(entry['Event'] || 'chat');
        const eventData = stripHtml(entry['Events'] || '');
        
        // Handle timestamp - key might have HTML in older API responses
        let timestamp = '';
        for (const key of Object.keys(entry)) {
            if (key.toLowerCase().includes('tamrielic') || key.toLowerCase().includes('time')) {
                timestamp = stripHtml(entry[key] || '');
                break;
            }
        }
        if (!timestamp) {
            timestamp = stripHtml(entry['Tamrielic Time'] || '');
        }
        
        // Determine speaker and text
        let speaker = '';
        let text = eventData;
        
        // Try to extract speaker from "Speaker: text" format
        const colonIndex = eventData.indexOf(':');
        if (colonIndex > 0 && colonIndex < 50) {
            speaker = eventData.substring(0, colonIndex).trim();
            text = eventData.substring(colonIndex + 1).trim();
        }
        
        // Determine entry class based on speaker/type
        const speakerLower = speaker.toLowerCase();
        if (speakerLower === 'player' || speakerLower.includes('dovahkiin')) {
            div.classList.add('player');
        } else if (speakerLower === 'the narrator' || speakerLower === 'narrator') {
            div.classList.add('narrator');
        } else if (eventType === 'infoaction' || eventType === 'action') {
            div.classList.add('action');
        } else {
            div.classList.add('npc');
        }
        
        // Build entry HTML
        div.innerHTML = `
            <div class="entry-header">
                <span class="entry-speaker">${escapeHtml(speaker || 'Unknown')}</span>
                <span class="entry-timestamp">${escapeHtml(timestamp)}</span>
            </div>
            <div class="entry-text">${escapeHtml(text)}</div>
        `;
        
        return div;
    }

    /**
     * Escape HTML special characters
     * @param {string} text - Text to escape
     * @returns {string} - Escaped text
     */
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Show the loading indicator
     */
    function showLoading() {
        loadingIndicator.classList.remove('hidden');
        emptyMessage.classList.add('hidden');
    }

    /**
     * Hide the loading indicator
     */
    function hideLoading() {
        loadingIndicator.classList.add('hidden');
    }

    /**
     * Show the empty message
     */
    function showEmpty() {
        hideLoading();
        emptyMessage.classList.remove('hidden');
    }

    /**
     * Hide the empty message
     */
    function hideEmpty() {
        emptyMessage.classList.add('hidden');
    }

    /**
     * Refresh the history by requesting from C++
     * This sends a command back to the plugin
     */
    window.refreshHistory = function() {
        showLoading();
        // Call the registered JS listener in C++
        if (window.chimHistoryCommand) {
            window.chimHistoryCommand('refresh');
        }
    };

    /**
     * Close the panel by requesting from C++
     */
    window.closePanel = function() {
        if (window.chimHistoryCommand) {
            window.chimHistoryCommand('close');
        }
    };

    // Initialize
    showLoading();
    
})();
