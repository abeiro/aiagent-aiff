const DEFAULT_SERVER_BASE = "http://127.0.0.1:8081/HerikaServer";

let serverBase = DEFAULT_SERVER_BASE;
let snqeSelf = `${DEFAULT_SERVER_BASE}/ui/addons/snqe/index.php`;
let agent0Url = `${DEFAULT_SERVER_BASE}/ui/addons/snqe/cmd/agent0.php`;
let refreshTimer = null;

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
        "Request quest end now?",
        "Requesting quest end...",
        "Quest end requested.",
        "Failed to request quest end."
    );
}

function cleanAll() {
    postAction(
        "clean_all",
        "Clean all quest data? This will remove running quests and state files.",
        "Cleaning all data...",
        "Clean all executed.",
        "Failed to clean all data."
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

window.focusFirstInput = function() {
    const input = document.getElementById("suggested");
    if (input && !input.classList.contains("hidden")) {
        input.focus();
    }
};

window.initQuestManager = function(serverUrl) {
    setServerBase(serverUrl);
    restoreLocalState();
    refreshRunningQuests();
    refreshLogs();
    startAutoRefresh();
    setLoading("Connected to CHIM server.", false);
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
});
