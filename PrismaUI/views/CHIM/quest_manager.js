const DEFAULT_SERVER_BASE = "http://127.0.0.1:8081/HerikaServer";

let serverBase = DEFAULT_SERVER_BASE;
let snqeSelf = `${DEFAULT_SERVER_BASE}/ui/addons/snqe/index.php`;
let agent0Url = `${DEFAULT_SERVER_BASE}/ui/addons/snqe/cmd/agent0.php`;
let refreshTimer = null;
let focusRetryTimers = [];
let questManagerPanelFocused = false;

function isEditableTextField(node) {
    if (!node || !node.tagName || node.disabled || node.readOnly) {
        return false;
    }

    const tag = node.tagName.toUpperCase();
    if (tag === "TEXTAREA") {
        return true;
    }

    if (tag === "INPUT") {
        const type = String(node.type || "").toLowerCase();
        return !["button", "submit", "reset", "checkbox", "radio", "range", "color", "file", "hidden", "image"].includes(type);
    }

    return false;
}

function normalizeTextKey(event) {
    if (!event) {
        return null;
    }

    const legacyKey = event.which || event.keyCode || 0;
    if (event.code === "Space" || event.key === " " || event.key === "Space" || event.key === "Spacebar" || legacyKey === 32) {
        return " ";
    }

    return typeof event.key === "string" && event.key.length === 1 ? event.key : null;
}

function dispatchBeforeInput(doc, target, inputType, data) {
    try {
        if (doc && doc.defaultView && typeof doc.defaultView.InputEvent === "function") {
            const beforeEvent = new doc.defaultView.InputEvent("beforeinput", {
                bubbles: true,
                cancelable: true,
                data,
                inputType
            });
            return target.dispatchEvent(beforeEvent);
        }
    } catch (error) {
    }

    try {
        const fallbackEvent = doc.createEvent("Event");
        fallbackEvent.initEvent("beforeinput", true, true);
        fallbackEvent.data = data;
        fallbackEvent.inputType = inputType;
        return target.dispatchEvent(fallbackEvent);
    } catch (error) {
    }

    return true;
}

function dispatchInput(doc, target, inputType, data) {
    try {
        if (doc && doc.defaultView && typeof doc.defaultView.InputEvent === "function") {
            const inputEvent = new doc.defaultView.InputEvent("input", {
                bubbles: true,
                data,
                inputType
            });
            target.dispatchEvent(inputEvent);
            return;
        }
    } catch (error) {
    }

    try {
        const fallbackEvent = doc.createEvent("Event");
        fallbackEvent.initEvent("input", true, false);
        fallbackEvent.data = data;
        fallbackEvent.inputType = inputType;
        target.dispatchEvent(fallbackEvent);
    } catch (error) {
    }
}

function applyTextControlEdit(target, event) {
    const value = typeof target.value === "string" ? target.value : "";
    let start = typeof target.selectionStart === "number" ? target.selectionStart : value.length;
    let end = typeof target.selectionEnd === "number" ? target.selectionEnd : value.length;
    let nextValue = value;
    let nextCaret = start;
    let inputType = "";
    let data = null;
    let handled = false;
    const textKey = normalizeTextKey(event);

    if (event.key === "Backspace") {
        if (start === end && start > 0) {
            start -= 1;
        }
        nextValue = value.slice(0, start) + value.slice(end);
        nextCaret = start;
        inputType = "deleteContentBackward";
        handled = start !== end || nextValue !== value;
    } else if (event.key === "Delete") {
        if (start === end && end < value.length) {
            end += 1;
        }
        nextValue = value.slice(0, start) + value.slice(end);
        nextCaret = start;
        inputType = "deleteContentForward";
        handled = start !== end || nextValue !== value;
    } else if (textKey !== null) {
        data = textKey;
        const maxLength = typeof target.maxLength === "number" ? target.maxLength : -1;
        if (maxLength >= 0) {
            const room = maxLength - (value.length - (end - start));
            if (room <= 0) {
                return false;
            }
            data = data.slice(0, room);
        }
        if (!data) {
            return false;
        }
        nextValue = value.slice(0, start) + data + value.slice(end);
        nextCaret = start + data.length;
        inputType = "insertText";
        handled = true;
    } else if (event.key === "Enter" && target.tagName && target.tagName.toUpperCase() === "TEXTAREA") {
        data = "\n";
        nextValue = value.slice(0, start) + data + value.slice(end);
        nextCaret = start + data.length;
        inputType = "insertLineBreak";
        handled = true;
    }

    if (!handled) {
        return false;
    }

    if (!dispatchBeforeInput(target.ownerDocument, target, inputType, data)) {
        return false;
    }

    target.value = nextValue;
    if (typeof target.setSelectionRange === "function") {
        target.setSelectionRange(nextCaret, nextCaret);
    }
    dispatchInput(target.ownerDocument, target, inputType, data);
    return true;
}

function resolveEditableTarget(target) {
    if (isEditableTextField(target)) {
        return target;
    }

    const doc = target && target.ownerDocument ? target.ownerDocument : document;
    const active = doc && doc.activeElement ? doc.activeElement : null;
    return isEditableTextField(active) ? active : null;
}

function shouldShimTextKey(event, target) {
    if (!isEditableTextField(target) || event.defaultPrevented || event.isComposing || event.altKey || event.ctrlKey || event.metaKey) {
        return false;
    }

    if (event.key === "Backspace" || event.key === "Delete") {
        return true;
    }

    if (event.key === "Enter") {
        return !!(target.tagName && target.tagName.toUpperCase() === "TEXTAREA");
    }

    return normalizeTextKey(event) !== null;
}

function applyQuestManagerTextInputFallback(event) {
    const editableTarget = resolveEditableTarget(event.target);
    if (!editableTarget || !shouldShimTextKey(event, editableTarget)) {
        return false;
    }

    return applyTextControlEdit(editableTarget, event);
}

function normalizeBase(url) {
    if (!url || typeof url !== "string") {
        return DEFAULT_SERVER_BASE;
    }
    return url.replace(/\/+$/, "");
}

function setServerBase(url) {
    serverBase = normalizeBase(url);
    snqeSelf = `${serverBase}/ui/addons/snqe/index.php`;
    agent0Url = `${serverBase}/ui/addons/snqe/cmd/agent0.php`;
}

function getPrimaryEditableField() {
    const preferredIds = ["suggested", "userprompt"];
    for (const id of preferredIds) {
        const element = document.getElementById(id);
        if (element && !element.disabled && !element.readOnly) {
            return element;
        }
    }

    return document.querySelector("textarea:not([readonly]):not([disabled]), input:not([readonly]):not([disabled]):not([type='hidden'])");
}

function focusEditableField(reason) {
    const field = getPrimaryEditableField();
    if (!field) {
        return false;
    }

    try {
        window.focus();
    } catch (error) {
    }

    try {
        field.focus({ preventScroll: true });
    } catch (error) {
        try {
            field.focus();
        } catch (focusError) {
            return false;
        }
    }

    try {
        if (typeof field.value === "string" && typeof field.setSelectionRange === "function") {
            const cursorPos = field.value.length;
            field.setSelectionRange(cursorPos, cursorPos);
        }
    } catch (error) {
    }

    console.debug("[QuestManager] Focus request:", reason, "active=", document.activeElement && document.activeElement.id);
    return document.activeElement === field;
}

function requestQuestManagerFocus(reason) {
    if (focusRetryTimers.length > 0) {
        focusRetryTimers.forEach((timerId) => clearTimeout(timerId));
        focusRetryTimers = [];
    }

    focusEditableField(reason || "request");

    const retryDelays = [50, 150, 350];
    retryDelays.forEach((delay, index) => {
        const timerId = setTimeout(() => {
            focusEditableField(`${reason || "request"}_${delay}ms`);
            if (index === retryDelays.length - 1) {
                focusRetryTimers = [];
            }
        }, delay);
        focusRetryTimers.push(timerId);
    });
}

function installEditableInputGuards() {
    const form = document.getElementById("snqeForm");
    if (!form) {
        return;
    }

    const editableSelector = "textarea:not([readonly]), input:not([readonly]):not([disabled]):not([type='hidden'])";

    form.addEventListener("pointerdown", (event) => {
        if (event.target && event.target.closest(editableSelector)) {
            setTimeout(() => requestQuestManagerFocus("pointerdown"), 0);
        }
    }, true);

    form.addEventListener("focusin", (event) => {
        if (event.target && event.target.closest(editableSelector)) {
            requestQuestManagerFocus("focusin");
        }
    }, true);

    form.addEventListener("keydown", (event) => {
        if (event.target && event.target.closest(editableSelector)) {
            if (applyQuestManagerTextInputFallback(event)) {
                event.preventDefault();
                event.stopPropagation();
                return;
            }
            event.stopPropagation();
        }
    }, true);
}

function setLoading(message, active) {
    const loadingEl = document.getElementById("loading");
    if (!loadingEl) {
        return;
    }
    loadingEl.textContent = message || "Ready";
    loadingEl.style.opacity = active ? "1" : "0.85";
}

function askConfirm(text) {
    if (typeof window.chimQuestManagerCommand === "function") {
        // Prisma host dialogs are unreliable; treat confirmations as accepted.
        return true;
    }
    if (typeof window.confirm !== "function") {
        return true;
    }
    try {
        const result = window.confirm(text);
        return typeof result === "boolean" ? result : true;
    } catch (error) {
        return true;
    }
}

function safeAlert(text) {
    if (typeof window.alert !== "function") {
        return;
    }
    try {
        window.alert(text);
    } catch (error) {
    }
}

function escapeHtml(text) {
    const map = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;"
    };
    return String(text || "").replace(/[&<>"']/g, (m) => map[m]);
}

function formatTime(ts) {
    if (!ts) {
        return "N/A";
    }
    const d = new Date(ts);
    if (Number.isNaN(d.getTime())) {
        return ts;
    }
    return d.toLocaleTimeString("en-US", { hour12: false });
}

function updateSelectBox(elementId, items) {
    const select = document.getElementById(elementId);
    if (!select || !Array.isArray(items)) {
        return;
    }
    const existing = Array.from(select.options).map((o) => o.textContent);
    items.forEach((item, index) => {
        if (!existing.includes(item)) {
            const option = document.createElement("option");
            option.value = String(existing.length + index);
            option.textContent = item;
            option.selected = true;
            select.appendChild(option);
        }
    });
}

async function fetchJson(url, init) {
    const response = await fetch(url, init);
    if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
    }
    return response.json();
}

function applyStagedVisibility(stagedQuestTitle) {
    const hasStaged = stagedQuestTitle && stagedQuestTitle !== "No staged quest";
    const suggestedGroup = document.getElementById("suggestedGroup");
    const userpromptGroup = document.getElementById("userpromptGroup");
    if (suggestedGroup) {
        suggestedGroup.classList.toggle("hidden", !!hasStaged);
    }
    if (userpromptGroup) {
        userpromptGroup.classList.toggle("hidden", !!hasStaged);
    }
}

function updateQuestButtons(hasStagedQuest, hasRunningQuests) {
    const canPlayQuest = hasStagedQuest && !hasRunningQuests;
    const canRequestEnd = hasRunningQuests;
    const playQuestBtn = document.getElementById("playQuestBtn");
    const requestEndBtn = document.getElementById("requestEndBtn");
    if (playQuestBtn) {
        playQuestBtn.disabled = !canPlayQuest;
    }
    if (requestEndBtn) {
        requestEndBtn.disabled = !canRequestEnd;
    }
}

function renderRunningQuests(quests) {
    const container = document.getElementById("runningQuestsList");
    if (!container) {
        return;
    }
    if (!Array.isArray(quests) || quests.length === 0) {
        container.innerHTML = '<div class="no-quests">No running quests</div>';
        return;
    }

    container.innerHTML = quests.map((quest) => {
        const title = escapeHtml(quest.title || "Untitled Quest");
        const questId = escapeHtml((quest.quest_id || "").substring(0, 8));
        const stage = escapeHtml(quest.stage || "N/A");
        const updated = escapeHtml(formatTime(quest.updated_at));
        return `
            <div class="quest-item">
                <div class="quest-item-title">${title}</div>
                <div class="quest-item-id">ID: ${questId}...</div>
                <div class="quest-item-stage">Stage: ${stage}</div>
                <div class="quest-item-time">Updated: ${updated}</div>
            </div>
        `;
    }).join("");
}

async function refreshRunningQuests() {
    try {
        const data = await fetchJson(`${snqeSelf}?action=get_running_quests`);
        const quests = Array.isArray(data.quests) ? data.quests : [];
        const hasRunningQuests = quests.length > 0;
        const hasStagedQuest = !!(data.stagedQuestTitle && data.stagedQuestTitle !== "No staged quest");
        const hasPendingStep = !!(data.pendingStep && data.pendingStep !== "No pending step");
        const hasNextObjective = !!(data.nextObjective && data.nextObjective !== "");

        renderRunningQuests(quests);

        const stagedQuestTitleEl = document.getElementById("stagedQuestTitle");
        if (stagedQuestTitleEl) {
            stagedQuestTitleEl.textContent = data.stagedQuestTitle || "No staged quest";
        }
        applyStagedVisibility(data.stagedQuestTitle || "No staged quest");
        updateQuestButtons(hasStagedQuest, hasRunningQuests);

        const pendingContainer = document.getElementById("pendingStepContainer");
        const pendingValue = document.getElementById("pendingStepValue");
        if (pendingValue) {
            pendingValue.textContent = data.pendingStep || "No pending step";
        }
        if (pendingContainer) {
            pendingContainer.classList.toggle("hidden", !hasRunningQuests);
        }

        const nextContainer = document.getElementById("nextObjectiveContainer");
        const nextValue = document.getElementById("nextObjectiveValue");
        const showNextObjective = hasStagedQuest && !hasRunningQuests && !hasPendingStep && hasNextObjective;
        if (nextValue) {
            nextValue.textContent = data.nextObjective || "No objective";
        }
        if (nextContainer) {
            nextContainer.classList.toggle("hidden", !showNextObjective);
        }

        const involvedNpcEl = document.getElementById("involvedNPCs");
        if (involvedNpcEl && Array.isArray(data.involvedNPCs)) {
            involvedNpcEl.textContent = data.involvedNPCs.join(", ");
        }
    } catch (error) {
    }
}

async function refreshLogs() {
    try {
        const data = await fetchJson(`${snqeSelf}?action=get_logs`);
        const agentLogEl = document.getElementById("agentLog");
        const serviceLogEl = document.getElementById("serviceLog");
        if (agentLogEl && typeof data.agentLog === "string") {
            agentLogEl.textContent = data.agentLog;
            agentLogEl.scrollTop = agentLogEl.scrollHeight;
        }
        if (serviceLogEl && typeof data.serviceLog === "string") {
            serviceLogEl.textContent = data.serviceLog;
            serviceLogEl.scrollTop = serviceLogEl.scrollHeight;
        }
        const pendingValue = document.getElementById("pendingStepValue");
        if (pendingValue && typeof data.pendingStep === "string" && data.pendingStep !== "") {
            pendingValue.textContent = data.pendingStep;
        }
    } catch (error) {
    }
}

async function generateScenario() {
    const userprompt = document.getElementById("userprompt").value;
    const questTitle = document.getElementById("questtitle").value;
    const briefing = document.getElementById("briefing").value;
    const suggested = document.getElementById("suggested").value;

    setLoading("Generating scenario...", true);

    try {
        const data = await fetchJson(agent0Url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                prompt: userprompt,
                locationlist: [],
                npclist: [],
                spawneditemslist: [],
                journallist: [],
                rumorlist: [],
                nextlist: [],
                questtitle: questTitle,
                briefing: briefing,
                suggested: suggested
            })
        });

        document.getElementById("userprompt").value = data.response || "";
        if (data.briefing) {
            document.getElementById("briefing").value = data.briefing;
        }
        if (data.questtitle) {
            document.getElementById("questtitle").value = data.questtitle;
        }
        if (Array.isArray(data.locations)) {
            updateSelectBox("locationlist", data.locations);
        }
        setLoading("Scenario generated.", false);
    } catch (error) {
        setLoading("Failed to generate scenario.", false);
    }
}

async function submitFormData() {
    const userprompt = document.getElementById("userprompt").value;
    const questTitle = document.getElementById("questtitle").value;
    const briefing = document.getElementById("briefing").value;
    const suggested = document.getElementById("suggested").value;
    const locations = Array.from(document.getElementById("locationlist").options).map((o) => o.textContent);

    setLoading("Staging storyline...", true);

    const formData = new FormData();
    formData.append("action", "submit_form");
    formData.append("userprompt", userprompt);
    formData.append("questtitle", questTitle);
    formData.append("briefing", briefing);
    formData.append("suggested", suggested);
    formData.append("locationlist", JSON.stringify(locations));

    try {
        const data = await fetchJson(snqeSelf, { method: "POST", body: formData });
        if (data.status === "success") {
            localStorage.setItem("snqe_questtitle", questTitle);
            localStorage.setItem("snqe_briefing", briefing);
            setLoading("Storyline staged.", false);
            await refreshRunningQuests();
            return;
        }
        setLoading(`Stage failed: ${data.message || "Unknown error"}`, false);
    } catch (error) {
        setLoading("Failed to stage storyline.", false);
    }
}

function clearAllData() {
    if (!askConfirm("Clear local form data?")) {
        return;
    }

    localStorage.removeItem("snqe_questtitle");
    localStorage.removeItem("snqe_briefing");

    document.getElementById("userprompt").value = "";
    document.getElementById("questtitle").value = "";
    document.getElementById("briefing").value = "";
    document.getElementById("suggested").value = "";
    document.getElementById("involvedNPCs").textContent = "";

    const locationSelect = document.getElementById("locationlist");
    if (locationSelect) {
        while (locationSelect.options.length > 0) {
            locationSelect.remove(0);
        }
    }
    setLoading("Local form data cleared.", false);
}

async function postAction(action, confirmText, loadingText, successText, failureText) {
    if (confirmText && !askConfirm(confirmText)) {
        return;
    }

    setLoading(loadingText, true);
    const formData = new FormData();
    formData.append("action", action);

    try {
        const data = await fetchJson(snqeSelf, { method: "POST", body: formData });
        if (data.status === "success") {
            setLoading(`${successText} ${data.timestamp || ""}`.trim(), false);
            await refreshRunningQuests();
            await refreshLogs();
            return;
        }
        setLoading(`Error: ${data.message || failureText}`, false);
    } catch (error) {
        const reason = error && error.message ? ` (${error.message})` : "";
        setLoading(`${failureText}${reason}`, false);
    }
}

function startQuest() {
    postAction(
        "start_quest",
        "Start the quest now?",
        "Starting quest...",
        "Quest started.",
        "Failed to start quest."
    );
}

function requestEnd() {
    postAction(
        "request_end",
        "Stop quest now?",
        "Stopping quest...",
        "Quest stop requested.",
        "Failed to stop quest."
    );
}

function cleanAll() {
    postAction(
        "clean_all",
        "Clear running quests? This will remove running quests and state files.",
        "Clearing running quests...",
        "Clear running quests executed.",
        "Failed to clear running quests."
    );
}

function restoreLocalState() {
    const savedTitle = localStorage.getItem("snqe_questtitle");
    const savedBriefing = localStorage.getItem("snqe_briefing");
    if (savedTitle) {
        document.getElementById("questtitle").value = savedTitle;
    }
    if (savedBriefing) {
        document.getElementById("briefing").value = savedBriefing;
    }
}

function startAutoRefresh() {
    if (refreshTimer) {
        clearInterval(refreshTimer);
    }
    refreshTimer = setInterval(() => {
        refreshRunningQuests();
    }, 5000);
}

function closePanel() {
    if (window.chimQuestManagerCommand) {
        window.chimQuestManagerCommand("close");
    }
}

window.onQuestManagerFocused = function() {
    questManagerPanelFocused = true;
    requestQuestManagerFocus("onQuestManagerFocused");
};

window.onQuestManagerUnfocused = function() {
    questManagerPanelFocused = false;
};

window.focusFirstInput = function() {
    requestQuestManagerFocus("focusFirstInput");
};

window.requestQuestManagerFocus = function(reason) {
    requestQuestManagerFocus(reason || "native");
};

window.initQuestManager = function(serverUrl) {
    setServerBase(serverUrl);
    restoreLocalState();
    refreshRunningQuests();
    refreshLogs();
    startAutoRefresh();
    setLoading("Connected to CHIM server.", false);
    requestQuestManagerFocus("initQuestManager");
};

window.addEventListener("DOMContentLoaded", () => {
    if (window.chimQuestManagerCommand) {
        window.chimQuestManagerCommand("dom_ready");
    } else {
        console.warn("[QuestManager] chimQuestManagerCommand bridge is unavailable");
    }

    setServerBase(DEFAULT_SERVER_BASE);
    restoreLocalState();
    refreshRunningQuests();
    startAutoRefresh();
    installEditableInputGuards();
    requestQuestManagerFocus("dom_ready");
});

window.addEventListener("focus", () => {
    if (questManagerPanelFocused) {
        requestQuestManagerFocus("window_focus");
    }
});

document.addEventListener("visibilitychange", () => {
    if (questManagerPanelFocused && !document.hidden) {
        requestQuestManagerFocus("visibilitychange");
    }
});
