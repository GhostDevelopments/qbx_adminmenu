const DashboardUI = (() => {
  const elements = {
    playerRows: document.getElementById("playerRows"),
    adminRows: document.getElementById("adminRows"),
    playerCount: document.getElementById("playerCount"),
    balanceNotice: document.getElementById("balanceNotice"),
    updatedAt: document.getElementById("updatedAt"),
    statusMessage: document.getElementById("statusMessage")
  };

  const escapeHtml = (value) => String(value ?? "").replace(/[&<>'"]/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "'": "&#39;",
    "\"": "&quot;"
  }[character]));

  const money = (value) => typeof value === "number" ? `$${value.toLocaleString("en-US")}` : "—";

  const playerRow = (player) => {
    const statusClass = player.adminDuty ? "text-mint" : "text-white/35";
    const statusText = player.adminRole ? `${player.adminRole} · ${player.adminDuty ? "on duty" : "off duty"}` : "Player";
    return `<article class="grid grid-cols-2 md:grid-cols-[60px_1.5fr_1fr_100px_100px_110px] gap-3 items-center px-4 py-3 hover:bg-white/[0.03]">
      <span class="text-xs text-white/45">${escapeHtml(player.id)}</span>
      <div><p class="text-sm font-semibold text-white">${escapeHtml(player.name)}</p><p class="text-xs text-white/35">${escapeHtml(player.serverName)}</p></div>
      <div><p class="text-xs ${statusClass}">${escapeHtml(statusText)}</p><p class="text-xs text-white/35">${escapeHtml(player.job)}${player.jobOnDuty ? " · duty" : ""}</p></div>
      <div class="text-xs text-white/70"><span class="md:hidden text-white/35">Cash </span>${money(player.cash)}</div>
      <div class="text-xs text-white/70"><span class="md:hidden text-white/35">Bank </span>${money(player.bank)}</div>
      <div class="text-xs text-white/70"><span class="md:hidden text-white/35">Dirty </span>${typeof player.dirtyMoney === "number" ? player.dirtyMoney.toLocaleString("en-US") : "—"}</div>
    </article>`;
  };

  const adminCard = (admin) => {
    const onDutyClass = admin.onDuty ? "border-mint/30 bg-mint/10" : "border-white/10 bg-white/[0.03]";
    const onDutyText = admin.onDuty ? "ON DUTY" : "OFF DUTY";
    const onDutyTextClass = admin.onDuty ? "text-mint" : "text-white/40";
    return `<article class="rounded-2xl border ${onDutyClass} p-4 flex items-center justify-between gap-4">
      <div><p class="text-sm font-semibold">${escapeHtml(admin.name)} <span class="text-white/35">#${escapeHtml(admin.id)}</span></p><p class="mt-1 text-xs text-white/45">${escapeHtml(admin.role)} · ${escapeHtml(admin.job)}</p></div>
      <span class="shrink-0 text-[10px] font-bold tracking-widest ${onDutyTextClass}">${onDutyText}</span>
    </article>`;
  };

  const showError = (message) => {
    elements.statusMessage.textContent = message;
    elements.statusMessage.classList.remove("hidden");
  };

  const clearError = () => {
    elements.statusMessage.textContent = "";
    elements.statusMessage.classList.add("hidden");
  };

  const render = (data) => {
    const players = Array.isArray(data.players) ? data.players : [];
    const abilities = data.abilities || {};
    document.querySelectorAll("#actionGrid [data-action]").forEach((button) => {
      const allowed = abilities[button.dataset.action] !== false;
      button.disabled = !allowed;
      button.classList.toggle("opacity-40", !allowed);
      button.classList.toggle("cursor-not-allowed", !allowed);
      const description = button.querySelector("span:last-child");
      if (!allowed && description) description.textContent = "Role locked";
    });
    const admins = Array.isArray(data.admins) ? data.admins : [];
    elements.playerRows.innerHTML = players.length ? players.map(playerRow).join("") : `<p class="px-4 py-8 text-center text-sm text-white/40">No online players.</p>`;
    elements.adminRows.innerHTML = admins.length ? admins.map(adminCard).join("") : `<p class="rounded-2xl border border-white/10 bg-white/[0.03] px-4 py-8 text-center text-sm text-white/40">No configured admins online.</p>`;
    elements.playerCount.textContent = `${players.length} player${players.length === 1 ? "" : "s"}`;
    elements.updatedAt.textContent = `Secure snapshot · ${escapeHtml(data.generatedAt || "now")}`;
    elements.balanceNotice.textContent = data.balancesVisible ? `Dirty money items: ${(data.dirtyMoneyItems || []).join(", ")}` : "Cash, bank and dirty money are restricted to the configured balance role.";
    clearError();
  };

  const open = (data) => {
    render(data);
    document.body.classList.remove("opacity-0", "pointer-events-none");
    document.body.classList.add("opacity-100", "pointer-events-auto");
  };

  const close = () => {
    document.body.classList.add("opacity-0", "pointer-events-none");
    document.body.classList.remove("opacity-100", "pointer-events-auto");
  };

  const handleResult = (name, result) => {
    if (!result || !result.ok) {
      showError(result && result.error ? result.error : "The server refused that action.");
      return;
    }
    if (result.data) {
      render(result.data);
    }
    if (typeof result.enabled === "boolean") {
      const button = document.querySelector(`[data-action="${name}"]`);
      if (button) {
        button.classList.toggle("border-mint/40", result.enabled);
        button.classList.toggle("bg-mint/10", result.enabled);
        const description = button.querySelector("span:last-child");
        if (description) description.textContent = result.enabled ? "Active · click to stop" : button.dataset.action === "entityView" ? "Inspect target" : "Toggle mode";
      }
    }
  };

  return { open, close, render, handleResult };
})();
