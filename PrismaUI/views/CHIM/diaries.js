// Immediate test - this runs as soon as the file loads
(function() {
    // Try to notify C++ that JS is loaded
    setTimeout(function() {
        if (window.chimDiariesCommand) {
            window.chimDiariesCommand('js_debug|SCRIPT LOADED - diaries.js v2');
        }
    }, 100);
})();

// Navigation state
let currentView = 'people'; // 'people', 'entries', 'diary'
let currentPerson = '';
let navigationStack = [];

// Data cache
let peopleData = [];
let entriesData = [];

/**
 * Initialize when DOM is ready
 */
window.addEventListener('DOMContentLoaded', function() {
    console.log('[Diaries] DOM loaded, initializing...');
    
    // Notify C++ that DOM is ready
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('dom_ready');
    }
    
    // Load initial data
    loadPeopleList();
});

/**
 * Load the list of people with diary entries
 */
function loadPeopleList() {
    console.log('[Diaries] Loading people list...');
    
    // Request data from C++
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('fetch_people');
    }
}

/**
 * Called by C++ to update the people list
 */
window.updatePeopleList = function(data) {
    // Send debug info back to C++
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('js_debug|updatePeopleList called, data length: ' + (data ? data.length : 'null'));
    }
    
    try {
        const parsed = typeof data === 'string' ? JSON.parse(data) : data;
        
        if (window.chimDiariesCommand) {
            window.chimDiariesCommand('js_debug|parsed successfully, people count: ' + (parsed.people ? parsed.people.length : 0));
        }
        
        peopleData = parsed.people || [];
        
        renderPeopleList();
        
        if (window.chimDiariesCommand) {
            window.chimDiariesCommand('js_debug|renderPeopleList completed');
        }
    } catch (error) {
        if (window.chimDiariesCommand) {
            window.chimDiariesCommand('js_debug|ERROR: ' + error.message);
        }
        document.getElementById('people-list').innerHTML = '<div class="empty-state">Failed to load diaries: ' + error.message + '</div>';
    }
};

/**
 * Render the people list
 */
function renderPeopleList() {
    const container = document.getElementById('people-list');
    
    if (!peopleData || peopleData.length === 0) {
        container.innerHTML = '<div class="empty-state">No diary entries found</div>';
        return;
    }
    
    container.innerHTML = '';
    
    peopleData.forEach(person => {
        const item = document.createElement('div');
        item.className = 'person-item';
        item.onclick = () => selectPerson(person.name);
        
        item.innerHTML = `
            <span class="person-name">${escapeHtml(person.name)}</span>
            <span class="person-count">${person.count}</span>
        `;
        
        container.appendChild(item);
    });
}

/**
 * Select a person to view their entries
 */
function selectPerson(personName) {
    console.log('[Diaries] Selected person:', personName);
    currentPerson = personName;
    navigationStack.push('people');
    
    // Update breadcrumb
    document.getElementById('breadcrumb-text').textContent = `Diaries of ${personName}`;
    
    // Show entries view with loading state
    switchView('entries');
    document.getElementById('entries-list').innerHTML = '<div class="loading">Loading entries...</div>';
    
    // Request entries from C++
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('fetch_entries|' + personName);
    }
}

/**
 * Called by C++ to update the entries list
 */
window.updateEntriesList = function(data) {
    console.log('[Diaries] Updating entries list:', data);
    
    try {
        const parsed = typeof data === 'string' ? JSON.parse(data) : data;
        entriesData = parsed.entries || [];
        currentPerson = parsed.person || currentPerson;
        
        renderEntriesList();
    } catch (error) {
        console.error('[Diaries] Error parsing entries data:', error);
        document.getElementById('entries-list').innerHTML = '<div class="empty-state">Failed to load entries</div>';
    }
};

/**
 * Render the entries list
 */
function renderEntriesList() {
    const container = document.getElementById('entries-list');
    
    if (!entriesData || entriesData.length === 0) {
        container.innerHTML = '<div class="empty-state">No diary entries found for this person</div>';
        return;
    }
    
    container.innerHTML = '';
    
    entriesData.forEach(entry => {
        const item = document.createElement('div');
        item.className = 'entry-item';
        item.onclick = () => selectEntry(entry.rowid);
        
        item.innerHTML = `
            <div class="entry-preview">${escapeHtml(entry.preview)}</div>
            <div class="entry-meta">
                <span class="entry-date">${escapeHtml(entry.date || 'Unknown date')}</span>
                <span class="entry-location">${escapeHtml(entry.location || '')}</span>
            </div>
        `;
        
        container.appendChild(item);
    });
}

/**
 * Select an entry to view full content
 */
function selectEntry(entryId) {
    console.log('[Diaries] Selected entry:', entryId);
    navigationStack.push('entries');
    
    // Show diary view with loading state
    switchView('diary');
    document.getElementById('diary-content').innerHTML = '<div class="loading">Loading diary entry...</div>';
    
    // Request full entry from C++
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('fetch_entry|' + entryId);
    }
}

/**
 * Called by C++ to update the diary content
 */
window.updateDiaryContent = function(data) {
    console.log('[Diaries] Updating diary content:', data);
    
    try {
        const parsed = typeof data === 'string' ? JSON.parse(data) : data;
        const entry = parsed.entry;
        
        if (!entry) {
            document.getElementById('diary-content').innerHTML = '<div class="empty-state">Entry not found</div>';
            return;
        }
        
        renderDiaryContent(entry);
    } catch (error) {
        console.error('[Diaries] Error parsing diary data:', error);
        document.getElementById('diary-content').innerHTML = '<div class="empty-state">Failed to load diary entry</div>';
    }
};

/**
 * Render the full diary content
 */
function renderDiaryContent(entry) {
    const container = document.getElementById('diary-content');
    container.className = 'diary-parchment';
    
    container.innerHTML = `
        <div class="diary-header">
            <div class="diary-title">Diary of ${escapeHtml(entry.author)}</div>
            <div class="diary-metadata">
                ${escapeHtml(entry.date || 'Unknown date')} • ${escapeHtml(entry.location || 'Unknown location')}
            </div>
        </div>
        <div class="diary-body">${escapeHtml(entry.content)}</div>
    `;
}

/**
 * Switch between views
 */
function switchView(viewName) {
    // Hide all views
    document.querySelectorAll('.view-container').forEach(view => {
        view.classList.remove('active');
    });
    
    // Show selected view
    const targetView = document.getElementById(viewName + '-view');
    if (targetView) {
        targetView.classList.add('active');
        currentView = viewName;
    }
    
    // Toggle fullscreen mode for diary view
    const modal = document.getElementById('diaries-modal');
    if (viewName === 'diary') {
        modal.classList.add('fullscreen');
    } else {
        modal.classList.remove('fullscreen');
    }
}

/**
 * Navigate back to previous view
 */
function navigateBack() {
    const previousView = navigationStack.pop();
    
    if (previousView === 'people') {
        // Back to people list
        document.getElementById('breadcrumb-text').textContent = 'CHIM Diaries';
        switchView('people');
        currentPerson = '';
    } else if (previousView === 'entries') {
        // Back to entries list
        document.getElementById('breadcrumb-text').textContent = `Diaries of ${currentPerson}`;
        switchView('entries');
    }
    
    // Notify C++ of navigation change
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('navigate_back');
    }
}

/**
 * Close the diaries panel
 */
function closePanel() {
    console.log('[Diaries] Closing panel');
    
    if (window.chimDiariesCommand) {
        window.chimDiariesCommand('close');
    }
}

/**
 * Utility: Escape HTML to prevent injection
 */
function escapeHtml(text) {
    if (!text) return '';
    
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    
    return String(text).replace(/[&<>"']/g, m => map[m]);
}

/**
 * Register command handler for C++ communication
 */
if (!window.chimDiariesCommand) {
    // Placeholder for testing
    window.chimDiariesCommand = function(command) {
        console.log('[Diaries] Command (no C++ bridge):', command);
    };
}
