const appState = {
    incidents: [],
    selectedId: null,
};

function post(data) {
    $.post(`https://${GetParentResourceName()}/${data.action}`, JSON.stringify(data.payload || {}));
}

function getPriorityClass(priority) {
    if (priority === 'low') return 'priority-low';
    if (priority === 'high') return 'priority-high';
    return 'priority-medium';
}

function renderList() {
    const list = document.getElementById('incidentList');
    list.innerHTML = '';

    if (!appState.incidents || appState.incidents.length === 0) {
        list.innerHTML = '<div class="incident-item"><h4>Žádná upozornění</h4><div class="incident-meta"><span>Vše čisté</span></div></div>';
        return;
    }

    appState.incidents.forEach((incident) => {
        const item = document.createElement('div');
        item.className = 'incident-item' + (incident.id === appState.selectedId ? ' active' : '');
        item.dataset.id = incident.id;
        item.innerHTML = `
            <h4>${incident.title}</h4>
            <div class="incident-meta">
                <span>${incident.type}</span>
                <span class="priority-badge ${getPriorityClass(incident.priority)}">${incident.priority}</span>
            </div>
            <div class="incident-meta" style="margin-top:6px;">
                <span>${incident.status}</span>
                <span>${incident.createdAt || 'Neznámé'}</span>
            </div>
        `;

        item.addEventListener('click', () => {
            appState.selectedId = incident.id;
            renderList();
            renderDetail();
        });

        list.appendChild(item);
    });
}

function renderDetail() {
    const detail = document.getElementById('detailPanel');
    const incident = appState.incidents.find((entry) => entry.id === appState.selectedId);

    if (!incident) {
        detail.innerHTML = `
            <div class="empty-state">
                <h3>Vyberte upozornění</h3>
                <p>Detail operace se zobrazí zde.</p>
            </div>
        `;
        return;
    }

    const priorityOptions = ['low', 'medium', 'high'];
    const statusOptions = ['open', 'inprogress', 'closed', 'solved'];

    detail.innerHTML = `
        <div class="detail-header">
            <h3>${incident.title}</h3>
            <span class="priority-badge ${getPriorityClass(incident.priority)}">${incident.priority}</span>
        </div>

        <div class="detail-actions">
            <select class="statusSelect" id="statusSelect">
                ${statusOptions.map((status) => `<option value="${status}" ${incident.status === status ? 'selected' : ''}>${status}</option>`).join('')}
            </select>
            <button id="statusBtn">Uložit stav</button>
            <button id="backupBtn">Žádost o zálohu</button>
            <button id="panicBtnDetail">PANIC</button>
        </div>

        <div class="detail-grid">
            <div class="detail-box">
                <h4>Informace</h4>
                <p><strong>Typ:</strong> ${incident.type}</p>
                <p><strong>Vytvořil:</strong> ${incident.createdBy || 'Neznámý'}</p>
                <p><strong>Datum:</strong> ${incident.createdAt || 'Neznámé'}</p>
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
                <select id="prioritySelect">
                    ${priorityOptions.map((priority) => `<option value="${priority}" ${incident.priority === priority ? 'selected' : ''}>${priority}</option>`).join('')}
                </select>
                <button id="priorityBtn" style="margin-top:8px;">Uložit prioritu</button>
            </div>

            <div class="detail-box">
                <h4>Rozšířené akce</h4>
                <button id="blockAreaBtn">Zablokovat oblast</button>
                <button id="clearHistoryBtn" style="margin-top:8px;">Vymazat historii</button>
            </div>
        </div>
    `;

    document.getElementById('statusBtn').addEventListener('click', () => {
        const status = document.getElementById('statusSelect').value;
        post({ action: 'setStatus', payload: { id: incident.id, status } });
    });

    document.getElementById('priorityBtn').addEventListener('click', () => {
        const priority = document.getElementById('prioritySelect').value;
        post({ action: 'setPriority', payload: { id: incident.id, priority } });
    });

    document.getElementById('backupBtn').addEventListener('click', () => {
        post({ action: 'requestBackup', payload: { id: incident.id, backupType: 'Záloha' } });
    });

    document.getElementById('panicBtnDetail').addEventListener('click', () => {
        post({ action: 'panicButton', payload: {} });
    });

    document.getElementById('blockAreaBtn').addEventListener('click', () => {
        post({ action: 'blockArea', payload: { radius: 100.0 } });
    });

    document.getElementById('clearHistoryBtn').addEventListener('click', () => {
        post({ action: 'clearHistory', payload: {} });
    });
}

function updateStats() {
    const total = appState.incidents.length;
    const open = appState.incidents.filter((incident) => incident.status === 'open').length;
    const inProgress = appState.incidents.filter((incident) => incident.status === 'inprogress').length;
    const solved = appState.incidents.filter((incident) => incident.status === 'solved' || incident.status === 'closed').length;

    document.getElementById('totalCount').textContent = total;
    document.getElementById('openCount').textContent = open;
    document.getElementById('inProgressCount').textContent = inProgress;
    document.getElementById('solvedCount').textContent = solved;
}

function bindActions() {
    document.getElementById('newIncidentBtn').addEventListener('click', () => {
        const title = prompt('Název upozornění:', 'Nová operace');
        if (!title) return;

        const type = document.getElementById('incidentType').value;
        const priority = document.getElementById('priority').value;

        post({
            action: 'createIncident',
            payload: {
                title,
                type,
                priority,
                notes: '',
                emergency: false,
            }
        });
    });

    document.getElementById('requestBackupBtn').addEventListener('click', () => {
        if (!appState.selectedId) return;
        post({ action: 'requestBackup', payload: { id: appState.selectedId, backupType: 'Záloha' } });
    });

    document.getElementById('panicBtn').addEventListener('click', () => {
        post({ action: 'panicButton', payload: {} });
    });

    document.getElementById('refreshBtn').addEventListener('click', () => {
        post({ action: 'requestSync', payload: {} });
    });

    document.getElementById('closeBtn').addEventListener('click', () => {
        post({ action: 'close', payload: {} });
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'open') {
        document.getElementById('app').classList.remove('hidden');
    }

    if (data.type === 'sync') {
        appState.incidents = data.incidents || [];
        if (!appState.selectedId && appState.incidents.length > 0) {
            appState.selectedId = appState.incidents[0].id;
        }

        renderList();
        renderDetail();
        updateStats();
    }
});

bindActions();
