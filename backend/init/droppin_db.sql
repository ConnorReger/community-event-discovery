DROP TABLE IF EXISTS User_Interests;
DROP TABLE IF EXISTS RSVPs;
DROP TABLE IF EXISTS Invitations;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Messages;
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS Event_Updates;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Cities;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Users;

-- Ensure database exists and select it
CREATE DATABASE IF NOT EXISTS droppin_db;
USE droppin_db;

CREATE TABLE IF NOT EXISTS Users
(
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  fname VARCHAR(50) NOT NULL,
  lname VARCHAR(50) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  pass_hash VARCHAR(255) NOT NULL,
  pfp_link VARCHAR(255),
  acc_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Cities
(
  city_id INT AUTO_INCREMENT PRIMARY KEY,
  city_name VARCHAR(100) NOT NULL,
  state VARCHAR(50) NOT NULL,
  country VARCHAR(50) NOT NULL DEFAULT 'USA',
  UNIQUE KEY unique_city (city_name, state, country)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Location
(
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  location_name VARCHAR(255),
  address VARCHAR(255) NOT NULL,
  fk_city_id INT NOT NULL,
  zipcode VARCHAR(50) NOT NULL,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  FOREIGN KEY (fk_city_id) REFERENCES Cities(city_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Categories
(
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  descript TEXT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Events
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
  status ENUM('draft','scheduled','active','cancelled','completed') NOT NULL DEFAULT 'draft',
  visibility ENUM('public','private') NOT NULL,
  FOREIGN KEY (organizer_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_location_id) REFERENCES Location(location_id),
  FOREIGN KEY (fk_category_id) REFERENCES Categories(category_id),
  CONSTRAINT capacity_check CHECK (capacity IS NULL OR capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Event_Updates
(
  update_id INT AUTO_INCREMENT PRIMARY KEY,
  fk_event_id INT NOT NULL,
  update_title VARCHAR(255) NOT NULL,
  update_message TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  FOREIGN KEY (fk_event_id) REFERENCES Events(event_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Notifications
(
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  fk_user_id INT NOT NULL,
  fk_event_id INT NOT NULL,
  noti_type ENUM('event_update','rsvp_confirmed','invitation_received','invitation_accepted','invitation_rejected','new_comment','new_message','event_cancelled') NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS RSVPs
(
  rsvp_id INT AUTO_INCREMENT PRIMARY KEY,
  fk_user_id INT NOT NULL,
  fk_event_id INT NOT NULL,
  rsvp_status ENUM('Attending','Interested') NOT NULL,
  rsvp_visibility BOOLEAN NOT NULL,
  rsvp_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_event_id) REFERENCES Events(event_id),
  CONSTRAINT one_rsvp UNIQUE (fk_user_id, fk_event_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Invitations
(
  invitation_id INT AUTO_INCREMENT PRIMARY KEY,
  inviter_id INT NOT NULL,
  invited_id INT NOT NULL,
  fk_event_id INT NOT NULL,
  status ENUM('accepted','rejected','pending','unsure') NOT NULL DEFAULT 'pending',
  sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (inviter_id) REFERENCES Users(user_id),
  FOREIGN KEY (invited_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_event_id) REFERENCES Events(event_id),
  CONSTRAINT one_invite UNIQUE (inviter_id, invited_id, fk_event_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Comments
(
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  fk_user_id INT NOT NULL,
  fk_event_id INT NOT NULL,
  comment_msg TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Messages
(
  message_id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  fk_event_id INT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  time_sent DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES Users(user_id),
  FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_event_id) REFERENCES Events(event_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS User_Interests
(
  fk_user_id INT NOT NULL,
  fk_category_id INT NOT NULL,
  PRIMARY KEY (fk_user_id, fk_category_id),
  FOREIGN KEY (fk_user_id) REFERENCES Users(user_id),
  FOREIGN KEY (fk_category_id) REFERENCES Categories(category_id)
) ENGINE=InnoDB;

-- Indexes
CREATE INDEX idx_events_visibility ON Events(visibility);
CREATE INDEX idx_location_city ON Location(fk_city_id);
CREATE INDEX idx_rsvps_event ON RSVPs(fk_event_id);
CREATE INDEX idx_events_category ON Events(fk_category_id);
CREATE INDEX idx_users_email ON Users(email);

-- Views
CREATE VIEW Upcoming_Events AS
SELECT
  e.event_id,
  e.title,
  e.descript,
  e.start_time,
  e.end_time,
  e.capacity,
  e.status,
  e.visibility,
  CONCAT(u.fname, ' ', u.lname) AS organizer_name,
  u.email AS organizer_email,
  l.location_name,
  l.address,
  c.city_name,
  c.state,
  cat.category_name
FROM Events e
JOIN Users u ON e.organizer_id = u.user_id
JOIN Location l ON e.fk_location_id = l.location_id
JOIN Cities c ON l.fk_city_id = c.city_id
JOIN Categories cat ON e.fk_category_id = cat.category_id
WHERE e.start_time > NOW() AND e.status IN ('scheduled','active');

CREATE VIEW Trending_Categories AS
SELECT
  c.category_id,
  c.category_name,
  COUNT(DISTINCT e.event_id) AS event_count,
  COUNT(r.rsvp_id) AS total_rsvps,
  COUNT(DISTINCT ui.fk_user_id) AS users_interested
FROM Categories c LEFT JOIN Events e ON c.category_id = e.fk_category_id
LEFT JOIN RSVPs r ON e.event_id = r.fk_event_id
LEFT JOIN User_Interests ui ON c.category_id = ui.fk_category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_rsvps DESC;

-- Procedure: robustly accept invitations
DELIMITER $$
CREATE PROCEDURE accepting_invitation
(IN p_invitation_id INT,
 OUT p_transaction_status VARCHAR(200))
BEGIN
  DECLARE t_invited_id INT;
  DECLARE t_event_id INT;
  DECLARE t_current_status VARCHAR(200);
  DECLARE do_rollback INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
     ROLLBACK;
     SET p_transaction_status = 'ERROR: Unexpected database error';
  END;

  SET autocommit = 0;
  START TRANSACTION;

  SELECT invited_id, fk_event_id, status
  INTO t_invited_id, t_event_id, t_current_status
  FROM Invitations
  WHERE invitation_id = p_invitation_id
  FOR UPDATE;

  IF t_invited_id IS NULL THEN
     SET do_rollback = 1;
     SET p_transaction_status = 'ERROR: Invitation does not exist';
  ELSEIF LOWER(t_current_status) <> 'pending' THEN
     SET do_rollback = 1;
     SET p_transaction_status = CONCAT('ERROR: Invitation already ', t_current_status);
  ELSE
     UPDATE Invitations
     SET status = 'accepted'
     WHERE invitation_id = p_invitation_id;

     INSERT INTO RSVPs (fk_user_id, fk_event_id, rsvp_status, rsvp_visibility, rsvp_date)
     VALUES (t_invited_id, t_event_id, 'Attending', TRUE, NOW());

     SET p_transaction_status = 'Success: invitation accepted and RSVP created';
  END IF;

  IF do_rollback = 1 THEN
     ROLLBACK;
  ELSE
     COMMIT;
  END IF;
END $$
DELIMITER ;
