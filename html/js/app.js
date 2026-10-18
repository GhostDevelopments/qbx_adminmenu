const RESOURCE_NAME = GetParentResourceName();

const postNui = async (endpoint, data = {}) => {
  try {
    const response = await fetch(`https://${RESOURCE_NAME}/${endpoint}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data)
    });
    return await response.json();
  } catch (error) {
    return { ok: false, error: "The dashboard connection failed. Try again." };
  }
};

const closeUI = async () => {
  await postNui("close");
  DashboardUI.close();
};

window.addEventListener("message", (event) => {
  const { action, data } = event.data;
  if (action === "open") DashboardUI.open(data);
  if (action === "close") DashboardUI.close();
});

document.addEventListener("click", async (event) => {
  const actionButton = event.target.closest("[data-action]");
  if (actionButton) {
    const name = actionButton.dataset.action;
    actionButton.disabled = true;
    const result = await postNui("action", { name });
    DashboardUI.handleResult(name, result);
    actionButton.disabled = false;
    return;
  }

  const playerRow = event.target.closest("[data-player-id]");
  if (playerRow) {
    await PlayerDetailsUI.open(Number(playerRow.dataset.playerId));
    return;
  }

  const playerAction = event.target.closest("[data-player-action]");
  if (playerAction) {
    await PlayerDetailsUI.action(playerAction.dataset.playerAction);
    return;
  }

  if (event.target.closest("#closeDetails")) {
    DashboardUI.showLedger();
    return;
  }

  if (event.target.closest("#closeButton")) {
    await closeUI();
  }
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") closeUI();
});
