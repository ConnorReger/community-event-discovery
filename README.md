# Community Event Discovery Website

**Team:** Fuhuhluhtoogans
**Members:** Connor Reger, Pearl Singer, Margo Brown, Huy (Will) Huynh, Aiden Nemeroff, Hailey Lisak

## Project Overview
Between the news, word of mouth, and the multitude of social media apps, it can be difficult and overwhelming to effectively find and share information regarding local events. This project is a client-server web application designed to solve this problem, allowing students and local community groups/members to reliably discover, organize, and RSVP to relevant events happening at the time.

## Tech Stack
* **Frontend:** HTML, CSS, Javascript
* **Backend:** Python
* **Database:** MySQL
* **APIs:** Leaflet (for MapView integration)

## Installation and Setup (Local Development)
To run this project locally, ensure you have Python 3, Git, and Docker Desktop installed.

1. **Clone the repository:**
   `git clone https://github.com/ConnorReger/community-event-map.git`
   `cd community-event-map`

2. **Initialize the Database:**
   Navigate to the database directory and start the MySQL Docker container:
   `cd database`
   `docker-compose up -d`

3. **Install Backend Dependencies:**
   Open a new terminal window, navigate to the backend directory, and install the required Python packages:
   `cd backend`
   `pip install -r requirements.txt`

## Running the Application
1. **Start the Backend Server:** In your terminal, ensure you are in the `backend` folder and start the Python server:
   `python server.py` (or `python3 server.py` on Mac/Linux)
2. **Launch the Frontend:** Open the `frontend` directory in your file explorer and open `index.html` in your web browser.
3. **Navigate the App:** Create an account, log in, or continue as a guest to access the landing page. Click the "Full Screen Map" or "Create Event" buttons to interact with the core system.

## Branching Conventions
* **'main' branch:** ONLY for production code. NEVER commit changes directly to the main branch
* **'dev' branch:** The primary branch for development. Feature branches will come off of the 'dev' branch
* **Feature branches:** All features and contributions should be done on a feature branch created off of the 'dev' branch
* **Branch Naming:** All feature branches should be named: 'feature/feature-name' (e.g., 'feature/project-skeleton')

## Workflow
1. Run 'git pull origin dev' before starting on a new feature
2. Create local branch
3. Commit frequently with meaningful messages
4. Push and make a pull request