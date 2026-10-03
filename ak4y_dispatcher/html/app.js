body {
    margin: 0;
    font-family: 'Segoe UI', sans-serif;
    background: rgba(6, 12, 20, 0.68);
    color: white;
}

.hidden { display: none; }

#app {
    width: 100vw;
    height: 100vh;
    display: flex;
    background: linear-gradient(135deg, rgba(8, 12, 18, 0.96), rgba(12, 19, 28, 0.95));
    border: 1px solid rgba(255,255,255,0.06);
}

.sidebar {
    width: 360px;
    background: rgba(15, 20, 28, 0.96);
    border-right: 1px solid rgba(255,255,255,0.08);
    padding: 18px 14px;
    box-sizing: border-box;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(255,255,255,0.08);
}

.header h1 {
    margin: 0;
    font-size: 2.1rem;
    color: #6cd3ff;
    letter-spacing: 0.08em;
}

.header span {
    color: #abcfe9;
    font-size: 0.72rem;
    text-transform: uppercase;
}

.toolbar {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
    margin-top: 14px;
}

button {
    border: 0;
    border-radius: 8px;
    padding: 10px 8px;
    background: rgba(108, 211, 255, 0.14);
    color: white;
    cursor: pointer;
    font-weight: 600;
}

button:hover { filter: brightness(1.08); }
button.primary { background: rgba(108, 211, 255, 0.22); }
button.danger { background: rgba(255, 86, 86, 0.18); }
button.panic {
    background: rgba(255, 73, 73, 0.18);
    color: #ffb0b0;
}
button.small {
    padding: 8px 10px;
    font-size: 0.75rem;
}

.quick-form {
    margin-top: 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.quick-form label {
    color: #aad6f6;
    font-size: 0.68rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
}

.quick-form select,
.quick-form input,
.quick-form textarea {
    width: 100%;
    box-sizing: border-box;
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.08);
    color: white;
    border-radius: 8px;
    padding: 10px 12px;
}

.quick-form textarea {
    min-height: 72px;
    resize: vertical;
}

.incident-list {
    margin-top: 18px;
    max-height: calc(100vh - 510px);
    overflow-y: auto;
    padding-right: 4px;
}

.incident-item {
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.06);
    border-left: 4px solid #5cc7ff;
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 10px;
    cursor: pointer;
}

.incident-item.active {
    border-color: #ffd166;
    background: rgba(255, 209, 102, 0.08);
}

.incident-item h4 {
    margin: 0 0 8px 0;
    font-size: 0.92rem;
}

.incident-meta {
    display: flex;
    justify-content: space-between;
    font-size: 0.7rem;
    color: #d1e7ff;
}

.priority-badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 999px;
    font-size: 0.66rem;
    font-weight: 700;
    text-transform: uppercase;
}

.priority-low { background: rgba(90, 210, 120, 0.18); color: #98edb0; }
.priority-medium { background: rgba(255, 198, 73, 0.18); color: #ffd66d; }
.priority-high { background: rgba(255, 95, 95, 0.18); color: #ffafaf; }

.content {
    flex: 1;
    padding: 18px 22px;
    box-sizing: border-box;
}

.top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 18px;
}

.top-bar h2 {
    margin: 0;
}

.top-bar p {
    margin: 6px 0 0 0;
    color: #afcfeb;
    font-size: 0.78rem;
}

.buttons {
    display: flex;
    gap: 8px;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 14px;
    margin-bottom: 18px;
}

.stat-card {
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 12px;
    padding: 14px 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.stat-card span {
    color: #abd7ff;
    font-size: 0.72rem;
    text-transform: uppercase;
}

.stat-card strong {
    font-size: 2rem;
}

.stat-card.yellow strong { color: #ffd166; }
.stat-card.red strong { color: #ff8b8b; }
.stat-card.green strong { color: #7fe5a0; }

.detail-panel {
    background: rgba(255,255,255,0.035);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 12px;
    min-height: 430px;
    padding: 20px;
    box-sizing: border-box;
}

.empty-state {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    height: 100%;
    color: #afc9e3;
}

.detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
}

.detail-header h3 {
    margin: 0;
    font-size: 1.4rem;
}

.detail-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-bottom: 18px;
}

.detail-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14px;
}

.detail-box {
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 10px;
    padding: 12px;
}

.detail-box h4 {
    margin: 0 0 10px 0;
    font-size: 0.72rem;
    color: #aee0ff;
    text-transform: uppercase;
}

.detail-box p {
    margin: 6px 0;
}

.statusSelect,
.prioritySelect {
    width: 200px;
    padding: 10px 12px;
    border-radius: 8px;
    border: 1px solid rgba(255,255,255,0.08);
    background: rgba(255,255,255,0.04);
    color: white;
}

.history-box {
    margin-top: 18px;
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 10px;
    padding: 12px;
}

.history-box h4 {
    margin-top: 0;
    color: #aee0ff;
    text-transform: uppercase;
    font-size: 0.72rem;
}

.history-list {
    margin: 0;
    padding-left: 18px;
    color: #dceeff;
    font-size: 0.78rem;
}

.history-list li {
    margin: 6px 0;
}

@media (max-width: 1000px) {
    .stats-grid, .detail-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media (max-width: 760px) {
    #app { flex-direction: column; }
    .sidebar { width: 100%; max-height: 52vh; }
    .stats-grid, .detail-grid { grid-template-columns: 1fr; }
}
