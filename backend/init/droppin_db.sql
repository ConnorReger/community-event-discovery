DROP TABLE IF EXISTS User_Interests;
DROP TABLE IF EXISTS RSVPs;
DROP TABLE IF EXISTS Invitations;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Messages;
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS Event_Updates;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Users;

CREATE TABLE Users
(
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    pass VARCHAR(100) NOT NULL,
    pfp_link VARCHAR(255),
    acc_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Location
(
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(255),
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zipcode VARCHAR(50) NOT NULL,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7)
) ENGINE=InnoDB;

CREATE TABLE Categories
(
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    descript TEXT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Events
(
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    organizer_id INT NOT NULL,
    fk_location_id INT NOT NULL,
    fk_category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    descript TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    capacity INT,
    status ENUM('draft', 'scheduled', 'active', 'cancelled', 'completed') NOT NULL DEFAULT 'draft',
    visibility ENUM('public', 'private') NOT NULL DEFAULT 'private',

    FOREIGN KEY (organizer_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_location_id) REFERENCES Location(location_id),
    FOREIGN KEY (fk_category_id) REFERENCES Categories(category_id)
) ENGINE=InnoDB;

CREATE TABLE Event_Updates
(
    update_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_event_id INT NOT NULL,
    update_title VARCHAR(255) NOT NULL,
    update_message TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE Notifications
(
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_user_id INT NOT NULL,
    fk_event_id INT NOT NULL,
    noti_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE Messages
(
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    fk_event_id INT,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    time_sent DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE Comments
(
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_user_id INT NOT NULL,
    fk_event_id INT NOT NULL,
    comment_msg TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE Invitations
(
    invitation_id INT AUTO_INCREMENT PRIMARY KEY,
    inviter_id INT NOT NULL,
    invited_id INT NOT NULL,
    fk_event_id INT NOT NULL,
    status ENUM('Accepted', 'Rejected', 'Pending', 'Unsure') NOT NULL DEFAULT 'Pending',
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (inviter_id) REFERENCES Users(user_id),
    FOREIGN KEY (invited_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE RSVPs
(
    rsvp_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_user_id INT NOT NULL,
    fk_event_id INT NOT NULL,
    rsvp_status ENUM('Attending', 'Interested'),
    rsvp_visibility BOOLEAN NOT NULL DEFAULT TRUE,
    rsvp_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY unique_user_event_rsvp (fk_user_id, fk_event_id),
    FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE User_Interests
(
    fk_user_id INT NOT NULL,
    fk_category_id INT NOT NULL,
    PRIMARY KEY (fk_user_id, fk_category_id),

    FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (fk_category_id) REFERENCES Categories(category_id)
) ENGINE=InnoDB;

#indexes
CREATE INDEX idx_events_visibility ON Events(visibility);
CREATE INDEX idx_location_city ON Location(city);
CREATE INDEX idx_rsvps_event ON RSVPs(fk_event_id);
CREATE INDEX idx_events_category ON Events(fk_category_id);
CREATE INDEX idx_users_email ON Users(email);

#sample Data
INSERT INTO Users (fname, lname, email, pass, pfp_link, acc_date) VALUES
('Connor', 'Reger', 'connor.reger@email.com', 'password_1', 'https://example.com/pfp/connor.jpg', '2025-09-01 10:00:00'),
('Katherine', 'Lin', 'katherine.lin@email.com', 'password_2', 'https://example.com/pfp/katherine.jpg', '2025-09-15 14:30:00'),
('Huy', 'Huynh', 'huy.huynh@email.com', 'password_3', NULL, '2025-10-02 09:00:00'),
('Sanah', 'Singh', 'sanah.singh@email.com', 'password_4', 'https://example.com/pfp/sanah.jpg', '2025-10-20 11:15:00'),
('Kelsey', 'Hall', 'kelsey.hall@email.com', 'password_5', NULL, '2025-11-05 16:45:00');

INSERT INTO Location (location_name, address, city, state, zipcode, latitude, longitude) VALUES
('PPG Paints Arena', '1001 Fifth Ave', 'Pittsburgh', 'PA', '15219', 40.4395000, -79.9890000),
('Stage AE', '400 N Shore Dr', 'Pittsburgh', 'PA', '15212', 40.4468000, -80.0157000),
('Cathedral of Learning', '4200 Fifth Ave', 'Pittsburgh', 'PA', '15260', 40.4443000, -79.9532000),
('Schenley Park', '4100 Forbes Ave', 'Pittsburgh', 'PA', '15213', 40.4352000, -79.9412000),
('Carnegie Library of Pittsburgh - Oakland', '4400 Forbes Ave', 'Pittsburgh', 'PA', '15213', 40.4443000, -79.9505000);

INSERT INTO Categories (category_name, descript) VALUES
('Music', 'Live performances, concerts, open mic nights, and jam sessions'),
('Sports', 'Recreational and competitive sporting events and pickup games'),
('Food', 'Food festivals, tastings, cookouts, and potlucks'),
('Networking', 'Professional meetups, career fairs, and coffee chats'),
('Arts', 'Art shows, gallery walks, craft workshops, and exhibitions'),
('Community', 'Volunteer events, cleanups, fundraisers, and community gatherings');

INSERT INTO Events (organizer_id, fk_location_id, fk_category_id, title, descript, start_time, end_time, capacity, status, visibility) VALUES
(3, 1, 2, 'Penguins Watch Party', 'Group outing to watch the Pittsburgh Penguins play at PPG Paints Arena. Lets go Pens!', '2026-05-10 19:00:00', '2026-05-10 22:00:00', 10, 'scheduled', 'private'),
(2, 2, 1, 'Wallows at Stage AE', 'Going to see Wallows perform at Stage AE.', '2026-05-14 18:30:00', '2026-05-14 22:00:00', 8, 'scheduled', 'public'),
(4, 3, 4, 'Finals Study Group', 'Open study session on the first floor of the Cathedral of Learning.', '2026-05-08 14:00:00', '2026-05-08 18:00:00', 30, 'scheduled', 'public'),
(1, 4, 2, 'Group Jog at Schenley', 'Casual group jog around the Schenley Park loop.', '2026-05-11 08:00:00', '2026-05-11 09:30:00', 15, 'scheduled', 'public'),
(5, 5, 5, 'Atwood House Book Club', 'This month we are reading Dune. Meet in the main reading room at Carnegie Library.', '2026-05-16 18:00:00', '2026-05-16 20:00:00', 15, 'draft', 'private');

INSERT INTO Event_Updates (fk_event_id, update_title, update_message, created_at) VALUES
(1, 'Tickets Secured', 'Got 10 tickets in Section 108. Venmo Huy for your share.', '2026-05-01 12:00:00'),
(1, 'Meetup Spot', 'Meet at the main entrance on Fifth Ave at 6:30 PM.', '2026-05-05 09:00:00'),
(2, 'Doors and Openers', 'Doors open at 6 PM. There is an opener before Wallows goes on at 8.', '2026-05-07 10:00:00'),
(3, 'Snacks Provided', 'Sanah is bringing coffee and snacks for everyone studying.', '2026-05-06 15:00:00'),
(4, 'Route Update', 'We will be doing the Schenley Park loop trail starting near Phipps.', '2026-05-09 08:00:00');

INSERT INTO Notifications (fk_user_id, fk_event_id, noti_type, message, is_read, created_at) VALUES
(1, 1, 'event_update', 'Penguins Watch Party has a new update: Tickets Secured', TRUE, '2026-05-01 12:00:00'),
(2, 1, 'event_update', 'Penguins Watch Party has a new update: Tickets Secured', FALSE, '2026-05-01 12:00:00'),
(4, 1, 'event_update', 'Penguins Watch Party has a new update: Meetup Spot', FALSE, '2026-05-05 09:00:00'),
(1, 2, 'event_update', 'Wallows at Stage AE has a new update: Doors and Openers', TRUE, '2026-05-07 10:00:00'),
(1, 4, 'rsvp_confirmed', 'Kelsey Hall has RSVPed to Group Jog at Schenley', FALSE, '2026-05-10 07:00:00');

INSERT INTO Messages (sender_id, receiver_id, fk_event_id, message, is_read, time_sent) VALUES
(1, 3, 1, 'Hey Huy how much are the tickets?', TRUE, '2026-05-02 10:00:00'),
(3, 1, 1, 'They were student getgo tickets so they were just 28 bucks each. Just Venmo me whenever.', FALSE, '2026-05-02 10:15:00'),
(5, 2, 2, 'Is there a parking lot at Stage AE Kat?', TRUE, '2026-05-08 11:00:00'),
(2, 5, 2, 'Yes there is a lot right next to the venue but it fills up fast so come quick.', TRUE, '2026-05-08 11:30:00'),
(2, 4, 3, 'Will there be whiteboards available at the Cathedral?', TRUE, '2026-05-07 09:00:00'),
(4, 2, 3, 'No all the white boards are currently taken already', FALSE, '2026-05-07 09:45:00');

INSERT INTO Comments (fk_user_id, fk_event_id, comment_msg, created_at) VALUES
(1, 1, 'Lets gooo! Are we getting food at the arena too?', '2026-05-02 13:00:00'),
(3, 1, 'For sure, we can grab stuff inside. They have Chickies and Petes.', '2026-05-02 13:30:00'),
(4, 2, 'Is this all ages or 21+?', '2026-05-08 08:00:00'),
(2, 2, 'All ages', '2026-05-08 08:30:00'),
(5, 4, 'What pace are we thinking? I am a slow jogger.', '2026-05-10 07:00:00');

INSERT INTO Invitations (inviter_id, invited_id, fk_event_id, status, sent_at) VALUES
(3, 1, 1, 'Accepted', '2026-04-28 10:00:00'),
(3, 2, 1, 'Pending', '2026-04-28 10:00:00'),
(3, 4, 1, 'Unsure', '2026-04-28 10:00:00'),
(5, 2, 5, 'Accepted', '2026-05-10 12:00:00'),
(5, 4, 5, 'Rejected', '2026-05-10 12:00:00');

INSERT INTO RSVPs (fk_user_id, fk_event_id, rsvp_status, rsvp_visibility, rsvp_date) VALUES
(1, 1, 'Attending', TRUE, '2026-05-02 08:00:00'),
(2, 1, 'Attending', TRUE, '2026-05-03 12:00:00'),
(4, 1, 'Attending', FALSE, '2026-05-04 09:00:00'),
(1, 2, 'Attending', TRUE, '2026-05-08 07:00:00'),
(5, 4, 'Attending', TRUE, '2026-05-10 06:00:00'),
(2, 3, 'Attending', TRUE, '2026-05-07 10:00:00'),
(3, 4, 'Attending', TRUE, '2026-05-10 08:00:00');

INSERT INTO User_Interests (fk_user_id, fk_category_id) VALUES
(1, 2), (1, 3),
(2, 1), (2, 4),
(3, 2), (3, 3),
(4, 4), (4, 2),
(5, 5);