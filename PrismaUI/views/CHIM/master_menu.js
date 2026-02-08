// CHIM Master Menu JavaScript

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
        descElement.textContent = 'Select a panel to toggle';
        descElement.style.color = '#999';
    }
};

// Initialize when DOM is ready
function initMasterMenu() {
    console.log('[CHIM Master Menu] Menu initialized');
    
    // Signal to C++ that DOM is ready
    if (window.chimMasterMenuCommand) {
        window.chimMasterMenuCommand('dom_ready');
    }
    
    // Add keyboard listener for ESC key to close menu
    document.addEventListener('keydown', handleKeyDown);
}

// Handle keyboard events
function handleKeyDown(event) {
    // ESC key closes the menu
    if (event.key === 'Escape' || event.keyCode === 27) {
        event.preventDefault();
        event.stopPropagation();
        closeMenu();
    }
}

// Handle panel selection
function selectPanel(panelId) {
    console.log('[CHIM Master Menu] Selected panel:', panelId);
    
    // Send command to C++ bridge
    if (window.chimMasterMenuCommand) {
        window.chimMasterMenuCommand(panelId);
    }
}

// Close menu
function closeMenu() {
    console.log('[CHIM Master Menu] Closing menu');
    
    // Send close command to C++
    if (window.chimMasterMenuCommand) {
        window.chimMasterMenuCommand('close');
    }
}

// Called by C++ to signal that the JavaScript environment is ready
window.chimMasterMenuReady = function() {
    console.log('[CHIM Master Menu] JS ready callback received');
};

// Initialize on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMasterMenu);
} else {
    initMasterMenu();
}
