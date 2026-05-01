window.addEventListener("scroll", () => {
  const topbar = document.getElementById("topbar") || document.getElementById("topbar-main");
  if (topbar) {
    topbar.classList.toggle("visible", window.scrollY > 50);
  }
});

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
    lng: -79.999,
  },
  {
    id: 3,
    title: "Private Rooftop Hangout",
    type: "private",
    time: "Fri · 7:00 PM",
    lat: 40.438,
    lng: -79.992,
  },
  {
    id: 4,
    title: "Trail Run - Hartwood",
    type: "public",
    time: "Sun · 7:30 AM",
    lat: 40.45,
    lng: -79.987,
  },
];

function loadEventsFromServer() {
  fetch("http://localhost:5000/events")
    .then((res) => res.json())
    .then((data) => {
      if (data.status !== "ok") {
        console.error("Failed to load events:", data.message);
        return;
      }
      // Replace the in-memory events array with what the server returned
      events.length = 0;
      data.events.forEach((ev) => events.push(ev));
      refresh();
    })
    .catch((err) => console.error("Failed to fetch events:", err));
}

const chats = {
  jules: {
    eventId: 3,
    name: "jules.m",
    handle: "@julesm",
    subtitle: "Private Rooftop Hangout",
    avatar: "J",
    messages: [
      { sender: "other", text: "You still coming tonight?" },
      { sender: "me", text: "Yeah, I’m in. What time are you heading up?" },
      { sender: "other", text: "7 works. Bring a jacket, it gets windy." },
    ],
  },
  maya: {
    name: "maya.r",
    handle: "@mayar",
    subtitle: "Late night planning",
    avatar: "M",
    messages: [
      { sender: "other", text: "Want to make this one invite-only?" },
      { sender: "me", text: "Yeah, let’s keep it small." },
      { sender: "other", text: "Perfect. I’ll send over the list." },
    ],
  },
  leo: {
    name: "leo.k",
    handle: "@leok",
    subtitle: "Coffee after cleanup?",
    avatar: "L",
    messages: [
      { sender: "other", text: "You free after the cleanup?" },
      { sender: "me", text: "I should be. Thinking coffee?" },
      { sender: "other", text: "Exactly. There’s a spot two blocks away." },
    ],
  },
};

const chatsByEventId = Object.fromEntries(
  Object.entries(chats)
    .filter(([, chat]) => chat.eventId)
    .map(([chatId, chat]) => [chat.eventId, { chatId, ...chat }]),
);

const DEFAULT_CENTER = [40.4406, -79.9959];
const DEFAULT_ZOOM = 14;

const map = L.map("map").setView(DEFAULT_CENTER, DEFAULT_ZOOM);

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution:
    "© <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
  maxZoom: 19,
}).addTo(map);

function makeIcon(color = "#2a7de1") {
  return L.divIcon({
    className: "",
    html: `
      <svg xmlns="http://www.w3.org/2000/svg" width="28" height="36" viewBox="0 0 28 36">
        <path fill="${color}" stroke="#fff" stroke-width="1.5"
          d="M14 0C6.27 0 0 6.27 0 14c0 9.625 14 22 14 22S28 23.625 28 14C28 6.27 21.73 0 14 0z"/>
        <circle fill="#fff" cx="14" cy="14" r="5"/>
      </svg>`,
    iconSize: [28, 36],
    iconAnchor: [14, 36],
    popupAnchor: [0, -36],
  });
}

const markers = {};
let currentChatId = "jules";
let currentChat = chats[currentChatId];

function renderMarkers(filteredEvents) {
  Object.values(markers).forEach((marker) => map.removeLayer(marker));

  filteredEvents.forEach((ev) => {
    const color = ev.type === "private" ? "#ffb647" : "#3a7bfd";
    const marker = L.marker([ev.lat, ev.lng], { icon: makeIcon(color) })
      .addTo(map)
      .bindPopup(`<strong>${ev.title}</strong><br/><small>${ev.time}</small>`);

    marker.on("click", () => {
      highlightEvent(ev.id);
      if (ev.type === "private") {
        openChatForEvent(ev.id);
      }
    });

    markers[ev.id] = marker;
  });
}

function highlightEvent(eventId) {
  document.querySelectorAll(".event-item").forEach((el) => {
    el.classList.toggle("active", Number(el.dataset.id) === eventId);
  });
}

function renderList(filteredEvents) {
  const list = document.getElementById("event-list");
  if (!list) return;

  list.innerHTML = "";

  if (filteredEvents.length === 0) {
    list.innerHTML =
      '<p style="padding:16px; color:#75819a; font-size:13px;">No events found.</p>';
    return;
  }

  filteredEvents.forEach((ev) => {
    const item = document.createElement("div");
    item.className = "event-item";
    item.dataset.id = ev.id;
    item.innerHTML = `
      <div class="ev-title">${ev.title}</div>
      <div class="ev-meta">
        <span class="ev-badge ${ev.type === "private" ? "private" : ""}">
          ${ev.type === "private" ? "Private" : "Public"}
        </span>
        ${ev.time}
      </div>`;

    item.addEventListener("click", () => {
      highlightEvent(ev.id);

      const marker = markers[ev.id];
      if (marker) {
        map.setView([ev.lat, ev.lng], 15, { animate: true });
        marker.openPopup();
      }

      if (ev.type === "private") {
        openChatForEvent(ev.id);
      }
    });

    list.appendChild(item);
  });
}

let activeFilter = "all";
let searchQuery = "";

function getFiltered() {
  return events.filter((ev) => {
    const matchesFilter =
      activeFilter === "all"
        ? true
        : activeFilter === "public"
          ? ev.type === "public"
          : activeFilter === "today"
            ? ev.time.startsWith("Today")
            : activeFilter === "week"
              ? true
              : true;

    const matchesSearch =
      searchQuery === "" || ev.title.toLowerCase().includes(searchQuery.toLowerCase());

    return matchesFilter && matchesSearch;
  });
}

function refresh() {
  const filtered = getFiltered();
  renderList(filtered);
  renderMarkers(filtered);
}

document.querySelectorAll(".chip").forEach((chip) => {
  chip.addEventListener("click", () => {
    document.querySelectorAll(".chip").forEach((c) => c.classList.remove("active"));
    chip.classList.add("active");
    activeFilter = chip.dataset.filter;
    map.whenReady(refresh);
  });
});

const searchInput = document.getElementById("search-input");
if (searchInput) {
  searchInput.addEventListener("input", (e) => {
    searchQuery = e.target.value;
    refresh();
  });
}

let dropMode = false;
let pendingLatLng = null;

const fab = document.getElementById("fab");
if (fab) {
  fab.addEventListener("click", () => {
    dropMode = !dropMode;
    fab.style.background = dropMode
      ? "linear-gradient(135deg, #ff7a59, #ff4d6d)"
      : "";
    map.getContainer().style.cursor = dropMode ? "crosshair" : "";
  });
}

map.on("click", (e) => {
  if (!dropMode) return;

  pendingLatLng = e.latlng;

  document.getElementById("event-modal").style.display = "flex";
  document.body.style.overflow = "hidden";

});

// Cancel Event
const cancelButton = document.getElementById("cancel-button");
if (cancelButton) {
  cancelButton.addEventListener("click", () => {
    document.getElementById("event-modal").style.display = "none";
    document.body.style.overflow = "";
    dropMode = false;
    if (fab) fab.style.background = "";
    map.getContainer().style.cursor = "";
  });
}

// Create Event
const createButton = document.getElementById("create-button");
if (createButton) {
  createButton.addEventListener("click", () => {
    const title = document.getElementById("name-input").value.trim();
    const datetime = document.getElementById("date-input").value;
    const isPrivate = document.getElementById("private-input").checked;

    if (!title || !datetime || !pendingLatLng) return;

    document.getElementById("event-modal").style.display = "none";
    document.body.style.overflow = "";
    dropMode = false;

    const d = new Date(datetime);
    const weekday = d.toLocaleString([], { weekday: 'short' });
    const time = d.toLocaleString([], { hour: 'numeric', minute: '2-digit' });
    const date = d.toLocaleString([], { month: 'short', day: 'numeric' });
    const formatted = `${weekday}, ${date} · ${time}`;

    const newEvent = {
      id: Date.now(),
      title,
      type: isPrivate ? "private" : "public",
      time: formatted,
      lat: pendingLatLng.lat,
      lng: pendingLatLng.lng,
    };

    events.push(newEvent);
    if (fab) fab.style.background = "";
    map.getContainer().style.cursor = "";
    refresh();
  });
}

const newEventBtn = document.getElementById("new-event-btn");
if (newEventBtn) {
  newEventBtn.addEventListener("click", () => {
    dropMode = !dropMode;
    fab.style.background = dropMode ? "linear-gradient(135deg, #ff7a59, #ff4d6d)" : "";
    map.getContainer().style.cursor = dropMode ? "crosshair" : "";
  });
}

if (new URLSearchParams(window.location.search).get("newEvent") === "1") {
  dropMode = true;
  if (fab) {
    fab.style.background = "linear-gradient(135deg, #ff7a59, #ff4d6d)";
  }
  map.getContainer().style.cursor = "crosshair";
}

const chatPopup = document.getElementById("chat-popup");
const chatLauncher = document.getElementById("chat-launcher");
const chatClose = document.getElementById("chat-close");
const chatMinimize = document.getElementById("chat-minimize");
const chatSwitcherToggle = document.getElementById("chat-switcher-toggle");
const chatSwitcher = document.getElementById("chat-switcher");
const chatForm = document.getElementById("chat-form");
const chatMessages = document.getElementById("chat-messages");
const chatTextInput = document.getElementById("chat-text-input");
const chatTitle = document.getElementById("chat-title");
const chatSubtitle = document.getElementById("chat-subtitle");
const chatThreadName = document.getElementById("chat-thread-name");
const chatThreadHandle = document.getElementById("chat-thread-handle");
const chatAvatar = document.querySelector(".chat-avatar");
const chatThreadAvatar = document.querySelector(".chat-thread-avatar");
const chatSwitchItems = document.querySelectorAll(".chat-switch-item");

function setChatVisibility(isVisible) {
  if (!chatPopup || !chatLauncher) return;
  chatPopup.classList.toggle("hidden", !isVisible);
  chatLauncher.style.display = isVisible ? "none" : "inline-flex";
  if (!isVisible && chatSwitcher) {
    chatSwitcher.classList.add("hidden");
  }
}

function scrollChatToBottom() {
  if (chatMessages) {
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }
}

function renderChatMessages() {
  if (!chatMessages || !currentChat) return;

  chatMessages.innerHTML = "";

  currentChat.messages.forEach((entry) => {
    const row = document.createElement("div");
    row.className = `message-row ${entry.sender}`;

    const bubble = document.createElement("div");
    bubble.className = `message ${entry.sender}`;
    bubble.textContent = entry.text;

    row.appendChild(bubble);
    chatMessages.appendChild(row);
  });

  scrollChatToBottom();
}

function renderChatHeader() {
  if (!currentChat) return;

  if (chatTitle) chatTitle.textContent = currentChat.name;
  if (chatSubtitle) chatSubtitle.textContent = currentChat.subtitle;
  if (chatThreadName) chatThreadName.textContent = currentChat.name;
  if (chatThreadHandle) chatThreadHandle.textContent = currentChat.handle;
  if (chatAvatar) chatAvatar.textContent = currentChat.avatar;
  if (chatThreadAvatar) chatThreadAvatar.textContent = currentChat.avatar;
}

function renderChatSwitcher() {
  chatSwitchItems.forEach((item) => {
    item.classList.toggle("active", item.dataset.chatId === currentChatId);
  });
}

function openChatById(chatId) {
  const chatData = chats[chatId];
  if (!chatData) return;

  currentChatId = chatId;
  currentChat = chatData;
  renderChatHeader();
  renderChatMessages();
  renderChatSwitcher();
  setChatVisibility(true);
}

function openChatForEvent(eventId) {
  const chatData = chatsByEventId[eventId];
  if (!chatData) return;

  openChatById(chatData.chatId);
}

if (chatLauncher) {
  chatLauncher.addEventListener("click", () => {
    setChatVisibility(true);
    scrollChatToBottom();
    chatTextInput?.focus();
  });
}

if (chatClose) {
  chatClose.addEventListener("click", () => setChatVisibility(false));
}

if (chatMinimize) {
  chatMinimize.addEventListener("click", () => setChatVisibility(false));
}

if (chatSwitcherToggle && chatSwitcher) {
  chatSwitcherToggle.addEventListener("click", () => {
    chatSwitcher.classList.toggle("hidden");
  });
}

chatSwitchItems.forEach((item) => {
  item.addEventListener("click", () => {
    openChatById(item.dataset.chatId);
    chatSwitcher?.classList.add("hidden");
  });
});

if (chatForm && chatTextInput) {
  chatForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const text = chatTextInput.value.trim();
    if (!text || !currentChat) return;

    currentChat.messages.push({ sender: "me", text });
    renderChatMessages();
    chatTextInput.value = "";

    window.setTimeout(() => {
      currentChat.messages.push({
        sender: "other",
        text: "Perfect. I’ll message you when everyone gets there.",
      });
      renderChatMessages();
    }, 700);
  });
}

renderChatHeader();
renderChatMessages();
renderChatSwitcher();
refresh();
loadEventsFromServer();