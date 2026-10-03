const state = {
    incidents: [],
    selectedId: null,
    history: [],
    blockedAreas: [],
};

function post(action, payload = {}) {
    $.post(`https://${GetParentResourceName()}/${action}`, JSON.stringify(payload));
}

function priorityClass(priority) {
    if (priority === 'low') return 'priority-low';
    if (priority === 'high') return 'priority-high';
    return 'priority-medium';
}

function renderList() {
    const list = document.getElementById('incidentList');
    list.innerHTML = '';

    if (!state.incidents || state.incidents.length === 0) {
        list.innerHTML = '<div class="incident-item"><h4>Žádná upozornění</h4><div class="incident-meta"><span>Vše čisté</span></div></div>';
        return;
    }

    state.incidents.forEach((incident) => {
        const item = document.createElement('div');
        item.className = 'incident-item' + (incident.id === state.selectedId ? ' active' : '');
        item.innerHTML = `
            <h4>${incident.title}</h4>
            <div class="incident-meta">
                <span>${incident.type}</span>
                <span class="priority-badge ${priorityClass(incident.priority)}">${incident.priority}</span>
            </div>
            <div class="incident-meta" style="margin-top:6px;">
                <span>${incident.status}</span>
                <span>${incident.createdAt}</span>
            </div>
        `;

        item.addEventListener('click', () => {
            state.selectedId = incident.id;
            renderList();
            renderDetail();
        });

        list.appendChild(item);
    });
}

function renderDetail() {
    const panel = document.getElementById('detailPanel');
    const incident = state.incidents.find((entry) => entry.id === state.selectedId);

    if (!incident) {
        panel.innerHTML = `
            <div class="empty-state">
                <h3>Vyberte upozornění</h3>
                <p>Detail operace se zobrazí zde.</p>
            </div>
        `;
        return;
    }

    const statusOptions = ['open', 'inprogress', 'closed', 'solved'];
    const priorityOptions = ['low', 'medium', 'high'];

    panel.innerHTML = `
        <div class="detail-header">
            <h3>${incident.title}</h3>
            <span class="priority-badge ${priorityClass(incident.priority)}">${incident.priority}</span>
        </div>

        <div class="detail-actions">
            <select class="statusSelect" id="statusSelect">
                ${statusOptions.map((status) => `<option value="${status}" ${incident.status === status ? 'selected' : ''}>${status}</option>`).join('')}
            </select>
            <button id="statusBtn">Uložit stav</button>
            <button id="backupBtn">Žádost o zálohu</button>
            <button id="waypointBtn">Waypoint</button>
            <button id="respondBtn">Připojit se</button>
            <button id="panicBtnDetail" class="panic">PANIC</button>
        </div>

        <div class="detail-grid">
            <div class="detail-box">
                <h4>Informace</h4>
                <p><strong>Typ:</strong> ${incident.type}</p>
                <p><strong>Vytvořil:</strong> ${incident.createdBy || 'Neznámý'}</p>
                <p><strong>Datum:</strong> ${incident.createdAt}</p>
                <p><strong>Priorita:</strong> ${incident.priority}</p>
            </div>

            <div class="detail-box">
                <h4>Poloha</h4>
                <p>x: ${incident.coords ? incident.coords.x.toFixed(2) : '0.00'}</p>
                <p>y: ${incident.coords ? incident.coords.y.toFixed(2) : '0.00'}</p>
                <p>z: ${incident.coords ? incident.coords.z.toFixed(2) : '0.00'}</p>
            </div>

            <div class="detail-box">
                <h4>Priorita</h4>
                <select class="prioritySelect" id="prioritySelect">
                    ${priorityOptions.map((priority) => `<option value="${priority}" ${incident.priority === priority ? 'selected' : ''}>${priority}</option>`).join('')}
                </select>
                <button id="priorityBtn" style="margin-top:8px;">Uložit prioritu</button>
            </div>

            <div class="detail-box">
                <h4>Rozšířené akce</h4>
                <button id="clearHistoryBtn">Vymazat historii</button>
                <button id="removeBtn" style="margin-top:8px;">Smazat incident</button>
            </div>
        </div>

        <div class="history-box">
            <h4>Historie</h4>
            <ul class="history-list">
                ${(state.history || []).slice(0, 8).map((entry) => `<li>${entry.time} — ${entry.text}</li>`).join('') || '<li>Žádná historie.</li>'}
            </ul>
        </div>
    `;

    document.getElementById('statusBtn').addEventListener('click', () => {
        post('setStatus', { id: incident.id, status: document.getElementById('statusSelect').value });
    });

    document.getElementById('priorityBtn').addEventListener('click', () => {
        post('setPriority', { id: incident.id, priority: document.getElementById('prioritySelect').value });
    });

    document.getElementById('backupBtn').addEventListener('click', () => {
        post('requestBackup', { id: incident.id, backupType: 'Záloha' });
    });

    document.getElementById('waypointBtn').addEventListener('click', () => {
        post('setWaypoint', { id: incident.id });
    });

    document.getElementById('respondBtn').addEventListener('click', () => {
        post('registerResponder', { id: incident.id });
    });

    document.getElementById('panicBtnDetail').addEventListener('click', () => {
        post('panicButton', {});
    });

    document.getElementById('clearHistoryBtn').addEventListener('click', () => {
        post('clearHistory', {});
    });

    document.getElementById('removeBtn').addEventListener('click', () => {
        post('removeIncident', { id: incident.id });
    });
}

function updateStats() {
    const total = state.incidents.length;
    const open = state.incidents.filter((incident) => incident.status === 'open').length;
    const inProgress = state.incidents.filter((incident) => incident.status === 'inprogress').length;
    const solved = state.incidents.filter((incident) => incident.status === 'solved' || incident.status === 'closed').length;

    document.getElementById('totalCount').textContent = total;
    document.getElementById('openCount').textContent = open;
    document.getElementById('inProgressCount').textContent = inProgress;
    document.getElementById('solvedCount').textContent = solved;
}

function bindActions() {
    document.getElementById('newIncidentBtn').addEventListener('click', () => {
        document.getElementById('incidentTitle').focus();
    });

    document.getElementById('createIncidentBtn').addEventListener('click', () => {
        const title = document.getElementById('incidentTitle').value.trim();
        const type = document.getElementById('incidentType').value;
        const priority = document.getElementById('incidentPriority').value;
        const notes = document.getElementById('incidentNotes').value.trim();

        if (!title) {
            alert('Zadej název upozornění.');
            return;
        }

        post('createIncident', {
            title, type, priority, notes, emergency: false,
        });

        document.getElementByById('incidentTitle').value = '';
        document.getElementById('incidentNotes').value = '';
    });

    document.getElementById('backupBtn').addEventListener('click', () => {
        if (!state.selectedId) return;
        post('requestBackup', { id: state.selectedId, backupType: 'Záloha' });
    });

    document.getElementById('panicBtn').addEventListener('click', () => {
        post('panicButton', {});
    });

    document.getElementById('refreshBtn').addEventListener('click', () => {
        post('requestSync', {});
    });

    document.getElementById('closeBtn').addEventListener('click', () => {
        post('close', {});
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'open') {
        document.getElementById('app').classList.remove('hidden');
    }

    if (data.type === 'sync') {
        const payload = data.data || {};
        state.incidents = payload.incidents || [];
        state.history = payload.history || [];
        state.blockedAreas = payload.blockedAreas || [];

        if (!state.selectedId && state.incidents.length > 0) {
            state.selectedId = state.incidents[0].id;
        }

        renderList();
        renderDetail();
        updateStats();
    }
});

bindActions();
