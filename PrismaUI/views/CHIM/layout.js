/**
 * CHIM Layout Manager
 * Shared module for corner-placement of all HUD/panel views.
 */

(function () {
    'use strict';

    var STORAGE_KEY = 'chim_layout_corners';
    var GAP_STORAGE_KEY = 'chim_layout_gap';
    var DEFAULT_GAP = 20;

    var VIEW_DEFAULTS = {
        'chatbox':          'bottom-left',
        'overlay':          'top-right',
        'status_hud':       'top-right',
        'aiview_identity':  'top-left',
        'aiview_settings':  'top-right',
        'aiview_bio':       'bottom-right'
    };

    var liveElements = {};

    function loadAll() {
        try {
            var data = localStorage.getItem(STORAGE_KEY);
            return data ? JSON.parse(data) : {};
        } catch (e) {
            console.warn('[chimLayout] localStorage read failed:', e);
            return {};
        }
    }

    function saveAll(map) {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(map));
        } catch (e) {
            console.warn('[chimLayout] localStorage write failed:', e);
        }
    }

    var CORNER_CLASSES = [
        'chim-corner-top-left',
        'chim-corner-top-right',
        'chim-corner-bottom-left',
        'chim-corner-bottom-right'
    ];

    function applyCornerClass(el, corner, gap) {
        for (var i = 0; i < CORNER_CLASSES.length; i++) {
            el.classList.remove(CORNER_CLASSES[i]);
        }
        if (corner) {
            el.classList.add('chim-corner-' + corner);
        }
        
        // Apply gap dynamically
        var gapPx = (gap !== undefined ? gap : DEFAULT_GAP) + 'px';
        
        // Reset all inline positioning first
        el.style.removeProperty('top');
        el.style.removeProperty('bottom');
        el.style.removeProperty('left');
        el.style.removeProperty('right');
        
        // Apply new positioning based on corner with !important to override CSS classes
        if (corner === 'top-left') {
            el.style.setProperty('top', gapPx, 'important');
            el.style.setProperty('left', gapPx, 'important');
            el.style.setProperty('bottom', 'auto', 'important');
            el.style.setProperty('right', 'auto', 'important');
        } else if (corner === 'top-right') {
            el.style.setProperty('top', gapPx, 'important');
            el.style.setProperty('right', gapPx, 'important');
            el.style.setProperty('bottom', 'auto', 'important');
            el.style.setProperty('left', 'auto', 'important');
        } else if (corner === 'bottom-left') {
            el.style.setProperty('bottom', gapPx, 'important');
            el.style.setProperty('left', gapPx, 'important');
            el.style.setProperty('top', 'auto', 'important');
            el.style.setProperty('right', 'auto', 'important');
        } else if (corner === 'bottom-right') {
            el.style.setProperty('bottom', gapPx, 'important');
            el.style.setProperty('right', gapPx, 'important');
            el.style.setProperty('top', 'auto', 'important');
            el.style.setProperty('left', 'auto', 'important');
        }

        // Force reflow to ensure WebKit applies the new positioning immediately
        void el.offsetHeight;
    }

    var chimLayout = {
        views: VIEW_DEFAULTS,

        getCorner: function(viewId) {
            var saved = loadAll();
            return saved[viewId] || VIEW_DEFAULTS[viewId] || 'top-left';
        },

        getGap: function() {
            try {
                var gap = localStorage.getItem(GAP_STORAGE_KEY);
                return gap !== null ? parseInt(gap, 10) : DEFAULT_GAP;
            } catch (e) {
                return DEFAULT_GAP;
            }
        },

        setGap: function(gap) {
            try {
                localStorage.setItem(GAP_STORAGE_KEY, gap.toString());
            } catch (e) {}
            
            var map = loadAll();
            for (var viewId in liveElements) {
                if (liveElements.hasOwnProperty(viewId)) {
                    var corner = map[viewId] || VIEW_DEFAULTS[viewId] || 'top-left';
                    applyCornerClass(liveElements[viewId], corner, gap);
                }
            }
        },

        setCorner: function(viewId, corner) {
            var valid = ['top-left', 'top-right', 'bottom-left', 'bottom-right'];
            if (valid.indexOf(corner) === -1) return;

            var map = loadAll();
            map[viewId] = corner;
            saveAll(map);

            if (liveElements[viewId]) {
                applyCornerClass(liveElements[viewId], corner, this.getGap());
            }

            console.log('[chimLayout] setCorner', viewId, '->', corner);
        },

        apply: function(el, viewId, defaultCorner) {
            if (!el) return;
            liveElements[viewId] = el;

            if (defaultCorner && !(viewId in VIEW_DEFAULTS)) {
                VIEW_DEFAULTS[viewId] = defaultCorner;
            }

            var corner = this.getCorner(viewId);
            applyCornerClass(el, corner, this.getGap());
            console.log('[chimLayout] apply', viewId, '->', corner);
        }
    };

    // Listen for cross-view storage changes (if WebViews share localStorage)
    window.addEventListener('storage', function(e) {
        if (e.key === STORAGE_KEY || e.key === GAP_STORAGE_KEY) {
            var map = loadAll();
            var gap = chimLayout.getGap();
            for (var viewId in liveElements) {
                if (liveElements.hasOwnProperty(viewId)) {
                    var corner = map[viewId] || VIEW_DEFAULTS[viewId] || 'top-left';
                    applyCornerClass(liveElements[viewId], corner, gap);
                }
            }
        }
    });

    // Fallback: Poll for changes (WebKit often doesn't fire 'storage' events for file:// URLs)
    var lastSavedState = null;
    var lastSavedGap = null;
    try {
        lastSavedState = localStorage.getItem(STORAGE_KEY);
        lastSavedGap = localStorage.getItem(GAP_STORAGE_KEY);
    } catch (e) {}

    setInterval(function() {
        try {
            var currentState = localStorage.getItem(STORAGE_KEY);
            var currentGap = localStorage.getItem(GAP_STORAGE_KEY);
            if (currentState !== lastSavedState || currentGap !== lastSavedGap) {
                lastSavedState = currentState;
                lastSavedGap = currentGap;
                var map = currentState ? JSON.parse(currentState) : {};
                var gap = currentGap !== null ? parseInt(currentGap, 10) : DEFAULT_GAP;
                for (var viewId in liveElements) {
                    if (liveElements.hasOwnProperty(viewId)) {
                        var corner = map[viewId] || VIEW_DEFAULTS[viewId] || 'top-left';
                        applyCornerClass(liveElements[viewId], corner, gap);
                    }
                }
            }
        } catch (e) {}
    }, 500);

    window.chimLayout = chimLayout;

})();
