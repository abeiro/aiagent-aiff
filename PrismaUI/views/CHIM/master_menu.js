// CHIM Master Menu JavaScript

let hotkeyCloseArmedAt = 0;
let hudLayoutExpanded = false;
let toolsExpanded = false;

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
    hotkeyCloseArmedAt = Date.now() + 250;
    
    // Signal to C++ that DOM is ready
    if (window.chimMasterMenuCommand) {
        window.chimMasterMenuCommand('dom_ready');
    }
    
    // Add keyboard listener for ESC key to close menu
    document.addEventListener('keydown', handleKeyDown);

    initLayoutPickers();
    setHudLayoutExpanded(false);
    setToolsExpanded(false);
}

// Handle keyboard events
function handleKeyDown(event) {
    // ESC key closes the menu
    if (event.key === 'Escape' || event.keyCode === 27) {
        event.preventDefault();
        event.stopPropagation();
        closeMenu();
        return;
    }

    // Allow the bound hotkey to close the menu again.
    // We intentionally avoid closing on modifier/navigation keys.
    if (Date.now() < hotkeyCloseArmedAt || event.repeat) {
        return;
    }
    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) {
        return;
    }

    const code = event.code || '';
    const isHotkeyLike = code.startsWith('Key') ||
        code.startsWith('Digit') ||
        code.startsWith('Numpad') ||
        code.startsWith('F') ||
        [
            'Backquote', 'Minus', 'Equal',
            'BracketLeft', 'BracketRight', 'Backslash',
            'Semicolon', 'Quote', 'Comma', 'Period', 'Slash'
        ].includes(code);

    if (isHotkeyLike) {
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

function setHudLayoutExpanded(expanded) {
    const dropdown = document.getElementById('hud-layout-dropdown');
    const toggle = document.getElementById('hud-layout-toggle');
    const indicator = document.getElementById('hud-layout-indicator');
    if (!dropdown || !toggle || !indicator) {
        return;
    }

    hudLayoutExpanded = !!expanded;
    toggle.setAttribute('aria-expanded', hudLayoutExpanded ? 'true' : 'false');
    dropdown.hidden = !hudLayoutExpanded;
    indicator.textContent = hudLayoutExpanded ? '-' : '+';
}

window.toggleHudLayout = function() {
    setHudLayoutExpanded(!hudLayoutExpanded);
};

function setToolsExpanded(expanded) {
    const dropdown = document.getElementById('tools-dropdown');
    const toggle = document.getElementById('tools-toggle');
    const indicator = document.getElementById('tools-indicator');
    if (!dropdown || !toggle || !indicator) {
        return;
    }

    toolsExpanded = !!expanded;
    toggle.setAttribute('aria-expanded', toolsExpanded ? 'true' : 'false');
    dropdown.hidden = !toolsExpanded;
    indicator.textContent = toolsExpanded ? '-' : '+';
}

window.toggleToolsDropdown = function() {
    setToolsExpanded(!toolsExpanded);
};

window.setViewCorner = function(viewId, corner) {
    if (window.chimLayout) {
        window.chimLayout.setCorner(viewId, corner);
    }

    const picker = document.querySelector('.corner-picker[data-view="' + viewId + '"]');
    if (!picker) {
        return;
    }

    const buttons = picker.querySelectorAll('.corner-btn');
    for (let i = 0; i < buttons.length; i++) {
        const button = buttons[i];
        if (button.getAttribute('data-corner') === corner) {
            button.classList.add('active');
        } else {
            button.classList.remove('active');
        }
    }
};

window.resetLayoutDefaults = function() {
    if (!window.chimLayout || !window.chimLayout.views) {
        return;
    }

    const defaults = window.chimLayout.views;
    for (const viewId in defaults) {
        if (Object.prototype.hasOwnProperty.call(defaults, viewId)) {
            window.setViewCorner(viewId, defaults[viewId]);
        }
    }

    window.updateLayoutGap(20);
    const slider = document.getElementById('layout-gap-slider');
    if (slider) {
        slider.value = 20;
    }

    window.showDescription('HUD layout reset to defaults');
    setTimeout(window.clearDescription, 1500);
};

window.updateLayoutGap = function(value) {
    const gap = parseInt(value, 10);
    if (Number.isNaN(gap)) {
        return;
    }

    const valueLabel = document.getElementById('layout-gap-value');
    if (valueLabel) {
        valueLabel.textContent = gap + 'px';
    }

    if (window.chimLayout) {
        window.chimLayout.setGap(gap);
    }
};

function initLayoutPickers() {
    const slider = document.getElementById('layout-gap-slider');
    const valueLabel = document.getElementById('layout-gap-value');

    if (!window.chimLayout) {
        if (slider && valueLabel) {
            valueLabel.textContent = slider.value + 'px';
        }
        return;
    }

    const savedGap = window.chimLayout.getGap();
    if (slider) {
        slider.value = savedGap;
    }
    if (valueLabel) {
        valueLabel.textContent = savedGap + 'px';
    }

    const pickers = document.querySelectorAll('.corner-picker[data-view]');
    for (let i = 0; i < pickers.length; i++) {
        const picker = pickers[i];
        const viewId = picker.getAttribute('data-view');
        const savedCorner = window.chimLayout.getCorner(viewId);
        const buttons = picker.querySelectorAll('.corner-btn');

        for (let j = 0; j < buttons.length; j++) {
            const button = buttons[j];
            if (button.getAttribute('data-corner') === savedCorner) {
                button.classList.add('active');
            } else {
                button.classList.remove('active');
            }
        }
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
