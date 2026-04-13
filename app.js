// ── Sample event data ──────────────────────────────────────────────
const events = [
  {
    id: 1,
    title: "Community Cleanup",
    type: "public",
    time: "Today · 10:00 AM",
    lat: 40.4406,
    lng: -79.9959,
  },
  {
    id: 2,
    title: "Farmers Market",
    type: "public",
    time: "Sat · 8:00 AM",
    lat: 40.4446,
    lng: -79.9990,
  },
  {
    id: 3,
    title: "Private Rooftop Hangout",
    type: "private",
    time: "Fri · 7:00 PM",
    lat: 40.4380,
    lng: -79.9920,
  },
  {
    id: 4,
    title: "Trail Run — Hartwood",
    type: "public",
    time: "Sun · 7:30 AM",
    lat: 40.4500,
    lng: -79.9870,
  },
];

// ── Map setup ─────────────────────────────────────────────────────
// TODO: Replace the coordinates below with your desired default center
const DEFAULT_CENTER = [40.4406, -79.9959];
const DEFAULT_ZOOM   = 14;

const map = L.map("map").setView(DEFAULT_CENTER, DEFAULT_ZOOM);

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution: "© <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
  maxZoom: 19,
}).addTo(map);

// ── Custom pin icon ───────────────────────────────────────────────
function makeIcon(color = "#2a7de1") {
  return L.divIcon({
    className: "",
    html: `
      <svg xmlns="http://www.w3.org/2000/svg" width="28" height="36" viewBox="0 0 28 36">
        <path fill="${color}" stroke="#fff" stroke-width="1.5"
          d="M14 0C6.27 0 0 6.27 0 14c0 9.625 14 22 14 22S28 23.625 28 14C28 6.27 21.73 0 14 0z"/>
        <circle fill="#fff" cx="14" cy="14" r="5"/>
      </svg>`,
    iconSize:   [28, 36],
    iconAnchor: [14, 36],
    popupAnchor:[0, -36],
  });
}

// ── Render markers from event data ────────────────────────────────
const markers = {};

function renderMarkers(filteredEvents) {
  // Remove existing markers
  Object.values(markers).forEach((m) => map.removeLayer(m));

  filteredEvents.forEach((ev) => {
    const color  = ev.type === "private" ? "#e8a020" : "#2a7de1";
    const marker = L.marker([ev.lat, ev.lng], { icon: makeIcon(color) })
      .addTo(map)
      .bindPopup(`<strong>${ev.title}</strong><br/><small>${ev.time}</small>`);

    markers[ev.id] = marker;
  });
}

// ── Render sidebar event list ─────────────────────────────────────
function renderList(filteredEvents) {
  const list = document.getElementById("event-list");
  list.innerHTML = "";

  if (filteredEvents.length === 0) {
    list.innerHTML = `<p style="padding:16px; color:#888; font-size:13px;">No events found.</p>`;
    return;
  }

  filteredEvents.forEach((ev) => {
    const item = document.createElement("div");
    item.className = "event-item";
    item.dataset.id = ev.id;
    item.innerHTML = `
      <div class="ev-title">${ev.title}</div>
      <div class="ev-meta">
        <span class="ev-badge ${ev.type === "private" ? "private" : ""}">${ev.type === "private" ? "Private" : "Public"}</span>
        ${ev.time}
      </div>`;

    // Clicking a list item opens its popup on the map
    item.addEventListener("click", () => {
      document.querySelectorAll(".event-item").forEach((el) => el.classList.remove("active"));
      item.classList.add("active");

      const marker = markers[ev.id];
      if (marker) {
        map.setView([ev.lat, ev.lng], 15, { animate: true });
        marker.openPopup();
      }
    });

    list.appendChild(item);
  });
}

// ── Filter logic ──────────────────────────────────────────────────
let activeFilter = "all";
let searchQuery  = "";

function getFiltered() {
  return events.filter((ev) => {
    const matchesFilter =
      activeFilter === "all"    ? true :
      activeFilter === "public" ? ev.type === "public" :
      activeFilter === "today"  ? ev.time.startsWith("Today") :
      activeFilter === "week"   ? true : true;

    const matchesSearch =
      searchQuery === "" ||
      ev.title.toLowerCase().includes(searchQuery.toLowerCase());

    return matchesFilter && matchesSearch;
  });
}

function refresh() {
  const filtered = getFiltered();
  renderList(filtered);
  renderMarkers(filtered);
}

// ── Filter chip clicks ────────────────────────────────────────────
document.querySelectorAll(".chip").forEach((chip) => {
  chip.addEventListener("click", () => {
    document.querySelectorAll(".chip").forEach((c) => c.classList.remove("active"));
    chip.classList.add("active");
    activeFilter = chip.dataset.filter;
    refresh();
  });
});

// ── Search input ──────────────────────────────────────────────────
document.getElementById("search-input").addEventListener("input", (e) => {
  searchQuery = e.target.value;
  refresh();
});

// ── FAB: drop a new pin on map click ─────────────────────────────
// Clicking the FAB activates "drop mode" — the next map click places a pin
let dropMode = false;

document.getElementById("fab").addEventListener("click", () => {
  dropMode = !dropMode;
  document.getElementById("fab").style.background = dropMode ? "#e24b4a" : "";
  map.getContainer().style.cursor = dropMode ? "crosshair" : "";
});

map.on("click", (e) => {
  if (!dropMode) return;

  const title = prompt("Event name:");
  if (!title) { dropMode = false; map.getContainer().style.cursor = ""; return; }

  const newEvent = {
    id:    Date.now(),
    title,
    type:  "public",
    time:  "Just added",
    lat:   e.latlng.lat,
    lng:   e.latlng.lng,
  };

  events.push(newEvent);
  dropMode = false;
  document.getElementById("fab").style.background = "";
  map.getContainer().style.cursor = "";
  refresh();
});

// ── New Event button ──────────────────────────────────────────────
// TODO: hook this up to a proper event creation form/modal
document.getElementById("new-event-btn").addEventListener("click", () => {
  alert("TODO: open new event creation modal");
});

// ── Initial render ────────────────────────────────────────────────
refresh();
