// Paste your Raw GitHub User Content URL here once you push the repo!
const LEDGER_URL =
  "https://raw.githubusercontent.com/veerendrasoni07/The-Truth/main/scraper/data/ledger.json";

async function initDashboard() {  const container = document.getElementById("app-container");
  try {
    const res = await fetch(LEDGER_URL);
    if (!res.ok) throw new Error("Ledger fetch failed");
    const ledger = await res.json();

    container.innerHTML = "";

    Object.values(ledger).forEach((project) => {
      const card = document.createElement("section");
      card.className =
        "border border-gray-200 bg-white p-6 rounded-none space-y-4 shadow-sm";

      card.innerHTML = `
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-2 pb-4 border-b border-gray-100">
          <div>
            <h2 class="text-base font-bold text-black uppercase tracking-tight">${project.title}</h2>
            <p class="text-xs text-gray-400 mt-0.5">ID: ${project.project_id}</p>
          </div>
          <span class="inline-block px-2 py-0.5 text-xs font-bold border border-black uppercase">${project.status}</span>
        </div>

        <div class="grid grid-cols-2 sm:grid-cols-3 gap-4 text-xs">
          <div>
            <div class="text-gray-400">BUDGET ENVELOPE</div>
            <div class="font-bold text-gray-900">₹${project.budget_crores} Crore</div>
          </div>
          <div>
            <div class="text-gray-400">EXPECTED COMPLETION</div>
            <div class="font-bold text-gray-900">${project.expected_completion}</div>
          </div>
        </div>

        <div class="pt-2">
          <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Verifiable Ledger History</h3>
          <div class="border-l border-black ml-1.5 space-y-6 pl-4 relative">
            ${project.timeline
              .map(
                (event) => `
              <div class="relative">
                <div class="absolute -left-[21px] top-1 w-2.5 h-2.5 bg-black rounded-none border border-white"></div>
                <div class="text-xs font-bold text-black">${event.date}</div>
                <div class="text-gray-600 mt-0.5">${event.event_description}</div>
              </div>
            `
              )
              .join("")}
          </div>
        </div>
      `;
      container.appendChild(card);
    });
  } catch (err) {
    container.innerHTML = `<div class="border border-red-200 bg-red-50 text-red-700 p-4 font-bold">CRITICAL LEDGER SYSTEM ERROR: ${err.message}</div>`;
  }
}

if (typeof document === "undefined") {
  console.error(
    "app.js is browser code — it cannot run with Node.js.\n" +
      "Open app/index.html in a browser, or serve the app folder:\n" +
      "  cd app\n" +
      "  python -m http.server 8080\n" +
      "Then visit http://localhost:8080"
  );
} else {
  initDashboard();
}