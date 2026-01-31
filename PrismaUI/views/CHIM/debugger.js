/**
 * CHIM Debugger JavaScript
 * Handles updating the debugger dashboard with timing data and logs
 */

// Get the server URL from the page or use default
const SERVER_URL = window.CHIM_SERVER_URL || 'http://192.168.169.218:8081/HerikaServer';

// Global function to send commands back to C++
window.chimDebuggerCommand = function(command) {
    if (typeof prismaInterop !== 'undefined') {
        prismaInterop.call('chimDebuggerCommand', command);
    }
};

// Direct fetch from PHP API - bypasses all C++ escaping issues
async function fetchLog(type, lines = 200) {
    try {
        const response = await fetch(`${SERVER_URL}/ui/api/chim_debugger_logs.php?type=${type}&lines=${lines}`);
        if (!response.ok) throw new Error('HTTP ' + response.status);
        return await response.json();
    } catch (error) {
        console.error(`[${type}] Fetch error:`, error);
        return { success: false, error: error.message };
    }
}

// Refresh all logs directly from server
async function refreshAllLogs() {
    // Fetch all logs in parallel
    const [chimData, apacheData, contextData, outputData] = await Promise.all([
        fetchLog('chim', 200),
        fetchLog('apache', 100),
        fetchLog('context', 500),
        fetchLog('output', 500)
    ]);
    
    // Use structured rendering for CHIM and Apache logs
    renderLog('chim-log', chimData, true);
    renderLog('apache-log', apacheData, true);
    
    // Use LLM block rendering for context/output
    renderLLMLog('context-log', contextData);
    renderLLMLog('output-log', outputData);
}

// Render log data to a viewer element with structured entries
function renderLog(elementId, data, isStructured = true) {
    const viewer = document.getElementById(elementId);
    if (!viewer) return;
    
    if (!data.success) {
        viewer.innerHTML = '<div class="error-message">' + (data.error || 'Failed to load') + '</div>';
        return;
    }
    
    if (!data.lines || data.lines.length === 0) {
        viewer.innerHTML = '<div class="log-line info">' + (data.message || 'No entries') + '</div>';
        return;
    }
    
    viewer.innerHTML = '';
    
    data.lines.forEach(line => {
        const text = line.text || '';
        const type = line.type || 'info';
        
        // Try to parse structured log format: [timestamp] [level] message
        const match = text.match(/^\[(.*?)\]\s*\[(.*?)\]\s*(.*)$/);
        
        if (match && isStructured) {
            // Structured log entry
            const div = document.createElement('div');
            div.className = 'log-entry ' + type;
            
            const timestamp = document.createElement('span');
            timestamp.className = 'log-timestamp';
            timestamp.textContent = match[1];
            
            const level = document.createElement('span');
            level.className = 'log-level';
            level.textContent = match[2].toUpperCase();
            
            const message = document.createElement('span');
            message.className = 'log-message';
            message.textContent = match[3];
            
            div.appendChild(timestamp);
            div.appendChild(level);
            div.appendChild(message);
            viewer.appendChild(div);
        } else {
            // Simple log line
            const div = document.createElement('div');
            div.className = 'log-line ' + type;
            div.textContent = text;
            viewer.appendChild(div);
        }
    });
    
    viewer.scrollTop = viewer.scrollHeight;
}

// Render LLM logs with block formatting
function renderLLMLog(elementId, data) {
    const viewer = document.getElementById(elementId);
    if (!viewer) return;
    
    if (!data.success) {
        viewer.innerHTML = '<div class="error-message">' + (data.error || 'Failed to load') + '</div>';
        return;
    }
    
    if (!data.lines || data.lines.length === 0) {
        viewer.innerHTML = '<div class="log-line info">No entries</div>';
        return;
    }
    
    viewer.innerHTML = '';
    
    // Group lines into blocks by timestamp markers
    let blocks = [];
    let currentBlock = null;
    let currentContent = [];
    
    data.lines.forEach(line => {
        const text = line.text || '';
        
        // Check for timestamp marker (ISO format)
        if (/^\d{4}-\d{2}-\d{2}T[\d:]+/.test(text)) {
            if (currentBlock && currentContent.length > 0) {
                blocks.push({ timestamp: currentBlock, content: currentContent.join('\n') });
            }
            currentBlock = text.replace(' START', '').replace(' END', '').trim();
            currentContent = [];
        } else if (text !== '=' && text !== '==' && text.trim() !== '') {
            currentContent.push(text);
        }
    });
    
    // Add final block
    if (currentBlock && currentContent.length > 0) {
        blocks.push({ timestamp: currentBlock, content: currentContent.join('\n') });
    }
    
    // If no blocks found, just render as simple lines
    if (blocks.length === 0) {
        data.lines.forEach(line => {
            if (line.text && line.text.trim()) {
                const div = document.createElement('div');
                div.className = 'log-line';
                div.textContent = line.text;
                viewer.appendChild(div);
            }
        });
    } else {
        // Render blocks (newest first)
        blocks.reverse().forEach(block => {
            const blockDiv = document.createElement('div');
            blockDiv.className = 'llm-block';
            
            const header = document.createElement('div');
            header.className = 'block-header';
            
            const timestamp = document.createElement('span');
            timestamp.className = 'block-timestamp';
            timestamp.textContent = '📅 ' + block.timestamp;
            header.appendChild(timestamp);
            
            const content = document.createElement('div');
            content.className = 'block-content';
            content.textContent = block.content;
            
            blockDiv.appendChild(header);
            blockDiv.appendChild(content);
            viewer.appendChild(blockDiv);
        });
    }
    
    viewer.scrollTop = viewer.scrollHeight;
}

// Tab switching
window.switchTab = function(tabName) {
    const buttons = document.querySelectorAll('.tab-button');
    buttons.forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    const contents = document.querySelectorAll('.tab-content');
    contents.forEach(content => content.classList.remove('active'));
    document.getElementById('tab-' + tabName).classList.add('active');
};

// Format time value with color coding
function formatTime(seconds) {
    const time = parseFloat(seconds);
    let className = 'fast';
    
    if (time > 5.0) {
        className = 'slow';
    } else if (time > 2.0) {
        className = 'moderate';
    }
    
    return `<span class="time-value ${className}">${time.toFixed(1)}s</span>`;
}

// Fetch and display timing data
async function refreshTimingData() {
    try {
        const response = await fetch(`${SERVER_URL}/ui/api/chim_debugger.php?limit=20`);
        if (!response.ok) throw new Error('HTTP ' + response.status);
        const data = await response.json();
        
        if (!data.success) {
            showTimingError(data.error || 'Failed to load');
            return;
        }
        
        document.getElementById('timing-loading').style.display = 'none';
        document.getElementById('timing-error').style.display = 'none';
        document.getElementById('timing-content').style.display = 'block';
        document.getElementById('timing-footer').style.display = 'flex';
        
        const tbody = document.getElementById('timing-body');
        tbody.innerHTML = '';
        
        if (!data.data || data.data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #999;">No timing data</td></tr>';
            return;
        }
        
        data.data.forEach((entry, index) => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${index + 1}</td>
                <td>${formatTime(entry.ai_time)}</td>
                <td>${formatTime(entry.tts_time)}</td>
                <td>${formatTime(entry.total_time)}</td>
                <td><span class="status-badge ${entry.status}">${entry.status.toUpperCase()}</span></td>
            `;
            tbody.appendChild(row);
        });
        
        document.getElementById('avg-ai').textContent = data.avg_ai_time.toFixed(1) + 's';
        document.getElementById('avg-tts').textContent = data.avg_tts_time.toFixed(1) + 's';
        document.getElementById('avg-total').textContent = data.avg_total_time.toFixed(1) + 's';
        
    } catch (error) {
        console.error('[Timing] Error:', error);
        showTimingError(error.message);
    }
}

function showTimingError(message) {
    document.getElementById('timing-loading').style.display = 'none';
    document.getElementById('timing-content').style.display = 'none';
    document.getElementById('timing-footer').style.display = 'none';
    document.getElementById('timing-error').style.display = 'block';
    document.getElementById('timing-error-text').textContent = message;
}

// C++ can call this to set server URL and trigger initial load
window.initDebugger = function(serverUrl) {
    window.CHIM_SERVER_URL = serverUrl;
    refreshAll();
};

// Refresh everything
async function refreshAll() {
    await Promise.all([
        refreshTimingData(),
        refreshAllLogs()
    ]);
}

// Auto-refresh every 5 seconds when visible
let refreshInterval = null;

window.startAutoRefresh = function() {
    if (!refreshInterval) {
        refreshInterval = setInterval(refreshAll, 5000);
    }
};

window.stopAutoRefresh = function() {
    if (refreshInterval) {
        clearInterval(refreshInterval);
        refreshInterval = null;
    }
};

// Manual refresh buttons
window.refreshLLMLogs = function() { 
    fetchLog('context', 500).then(d => renderLLMLog('context-log', d)); 
    fetchLog('output', 500).then(d => renderLLMLog('output-log', d)); 
};
window.refreshChimLog = function() { fetchLog('chim', 200).then(d => renderLog('chim-log', d, true)); };
window.refreshApacheLog = function() { fetchLog('apache', 100).then(d => renderLog('apache-log', d, true)); };

// Helper
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Initialize on load - try to start immediately with default URL
console.log('[CHIM Debugger] Ready');
setTimeout(() => refreshAll(), 500);
