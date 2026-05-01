const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

let favorites = [];

// Get all favorites
function getFavorites() {
  return favorites;
}

// Check if favorite exists
function isFavorite(id) {
  return favorites.some((e) => e.id == id);
}

// Add favorite
function addFavorite(event) {
  if (!isFavorite(event.id)) {
    favorites.push(event);
  }
  return favorites;
}

// Remove favorite
function removeFavorite(id) {
  favorites = favorites.filter((e) => e.id != id);
  return favorites;
}

// Toggle favorite
function toggleFavorite(event) {
  if (isFavorite(event.id)) {
    return removeFavorite(event.id);
  } else {
    return addFavorite(event);
  }
}

// GET all favorites
app.get("/favorites", (req, res) => {
  res.json(getFavorites());
});

// ADD favorite
app.post("/favorites", (req, res) => {
  const updated = addFavorite(req.body);
  res.json(updated);
});

// REMOVE favorite
app.delete("/favorites/:id", (req, res) => {
  const updated = removeFavorite(req.params.id);
  res.json(updated);
});

// TOGGLE favorite (optional)
app.post("/favorites/toggle", (req, res) => {
  const updated = toggleFavorite(req.body);
  res.json(updated);
});
const PORT = 3001;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
