const PlayerDetailsUI = (() => {
  const elements = {
    title: document.getElementById("detailTitle"),
    summary: document.getElementById("detailSummary"),
    identifiers: document.getElementById("detailIdentifiers"),
    vehicles: document.getElementById("detailVehicles"),
    properties: document.getElementById("detailProperties"),
    playerId: document.getElementById("detailPlayerId"),
    actionStatus: document.getElementById("actionStatus")
  };

  let playerId = null;
  let frozen = false;

  const escapeHtml = (value) => String(value ?? "").replace(/[&<>'"]/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "'": "&#39;",
    "\"": "&quot;"
  }[character]));

  const money = (value) => typeof value === "number" ? `$${value.toLocaleString("en-US")}` : "Restricted";

  const empty = (message) => `<p class="text-white/35">${escapeHtml(message)}</p>`;

  const summaryCard = (label, value) => `<div class="rounded-2xl border border-white/10 bg-panel/90 p-4"><p class="text-[10px] uppercase tracking-wider text-white/35">${label}</p><p class="mt-2 text-sm font-semibold text-white">${escapeHtml(value)}</p></div>`;

  const render = (data) => {
    playerId = Number(data.id);
    frozen = false;
    elements.title.textContent = data.name || "Player details";
    elements.playerId.textContent = `Server ID #${data.id}`;
    elements.summary.innerHTML = [
      summaryCard("Cash", money(data.cash)),
      summaryCard("Bank", money(data.bank)),
      summaryCard("Black money", typeof data.blackMoney === "number" ? data.blackMoney.toLocaleString("en-US") : "Restricted"),
      summaryCard("Job / gang", `${data.job || "Unknown"} · ${data.gang || "None"}`)
    ].join("");
    elements.identifiers.innerHTML = [
      `<p><span class="text-white/35">Citizen ID:</span> ${escapeHtml(data.cid)}</p>`,
      `<p><span class="text-white/35">License:</span> ${escapeHtml(data.license)}</p>`,
      `<p><span class="text-white/35">Discord:</span> ${escapeHtml(data.discord)}</p>`,
      `<p><span class="text-white/35">Steam:</span> ${escapeHtml(data.steam)}</p>`,
      `<p><span class="text-white/35">Phone:</span> ${escapeHtml(data.phone)}</p>`
    ].join("");
    const vehicles = Array.isArray(data.vehicles) ? data.vehicles : [];
    elements.vehicles.innerHTML = vehicles.length ? vehicles.map((vehicle) => `<p class="rounded-lg border border-white/5 bg-white/5 px-3 py-2"><span class="font-semibold text-white">${escapeHtml(vehicle.vehicle)}</span> · ${escapeHtml(vehicle.plate)} · ${escapeHtml(vehicle.garage || "No garage")}</p>`).join("") : empty("No owned cars found.");
    const properties = Array.isArray(data.properties) ? data.properties : [];
    elements.properties.innerHTML = properties.length ? properties.map((property) => `<p class="rounded-lg border border-white/5 bg-white/5 px-3 py-2">#${escapeHtml(property.id)} · ${escapeHtml(property.property_name)}</p>`).join("") : empty("No owned properties found.");
    const actionsAllowed = DashboardUI.isAbilityAllowed("playerActions");
    elements.actionStatus.textContent = actionsAllowed ? "Server-authorized controls ready" : "Player actions are locked for your role";
    document.querySelectorAll("[data-player-action]").forEach((button) => {
      button.disabled = !actionsAllowed;
      button.classList.toggle("opacity-40", !actionsAllowed);
      button.classList.toggle("cursor-not-allowed", !actionsAllowed);
      if (button.dataset.playerAction === "freeze") button.textContent = actionsAllowed ? "Freeze" : "Role locked";
    });
    DashboardUI.showDetails();
  };

  const showError = (message) => {
    elements.actionStatus.textContent = message;
  };

  const setBusy = (busy) => {
    document.querySelectorAll("[data-player-action]").forEach((button) => {
      button.disabled = busy;
      button.classList.toggle("opacity-40", busy);
      button.classList.toggle("cursor-not-allowed", busy);
    });
  };

  const open = async (id) => {
    const result = await postNui("action", { name: "lookupPlayer", playerId: id });
    if (!result || !result.ok) {
      DashboardUI.handleResult("lookupPlayer", result);
      return;
    }
    render(result.data);
  };

  const action = async (name) => {
    if (playerId === null) return;
    setBusy(true);
    const result = await postNui("action", { name: "playerAction", playerId, playerAction: name });
    if (!result || !result.ok) {
      showError(result && result.error ? result.error : "The server refused that action.");
      setBusy(false);
      return;
    }
    if (result.data) render(result.data);
    if (name === "freeze") {
      frozen = result.frozen === true;
      const button = document.querySelector('[data-player-action="freeze"]');
      if (button) button.textContent = frozen ? "Unfreeze" : "Freeze";
    }
    elements.actionStatus.textContent = `${name} confirmed by server`;
    setBusy(false);
  };

  return { open, action };
})();