USE droppin_db;

INSERT INTO Users (user_id, fname, lname, email, pass_hash)
VALUES (1, 'Demo', 'User', 'demo@droppin.local', 'changeme')
ON DUPLICATE KEY UPDATE email = email;

INSERT INTO Categories (category_id, category_name, descript) VALUES
    (1, 'Community', 'Volunteer events, cleanups, fundraisers, and community gatherings'),
    (2, 'Music', 'Live performances, concerts, open mic nights, and jam sessions'),
    (3, 'Sports', 'Recreational and competitive sporting events and pickup games'),
    (4, 'Food', 'Food festivals, tastings, cookouts, and potlucks'),
    (5, 'Networking', 'Professional meetups, career fairs, and coffee chats'),
    (6, 'Arts', 'Art shows, gallery walks, craft workshops, and exhibitions')
    ON DUPLICATE KEY UPDATE category_name = VALUES(category_name);


INSERT INTO Cities (city_id, city_name, state, country) VALUES 
    (1, 'Pittsburgh', 'PA', 'USA')
    ON DUPLICATE KEY UPDATE city_name = city_name;


INSERT INTO Location (location_id, location_name, address, fk_city_id, zipcode, latitude, longitude) VALUES
    (1, 'Point State Park',  '601 Commonwealth Pl', 1, '15222', 40.4406000, -79.9959000),
    (2, 'Strip District',    '1600 Smallman St',    1, '15222', 40.4446000, -79.9990000),
    (3, 'South Side Slopes', 'Mission St',          1, '15203', 40.4380000, -79.9920000),
    (4, 'Hartwood Acres',    '200 Hartwood Acres',  1, '15238', 40.4500000, -79.9870000)
    ON DUPLICATE KEY UPDATE location_name = VALUES(location_name);

INSERT INTO Events 
(event_id, organizer_id, fk_location_id, fk_category_id, title, descript, start_time, end_time, capacity, status, visibility) VALUES
    (1, 1, 1, 1, 'Community Cleanup',
        'Help clean up Point State Park.',
        DATE_ADD(NOW(), INTERVAL 1 DAY),
        DATE_ADD(DATE_ADD(NOW(), INTERVAL 1 DAY), INTERVAL 2 HOUR),
        50, 'scheduled', 'public'),
    (2, 1, 2, 4, 'Farmers Market',
        'Weekly farmers market in the Strip.',
        DATE_ADD(NOW(), INTERVAL 3 DAY),
        DATE_ADD(DATE_ADD(NOW(), INTERVAL 3 DAY), INTERVAL 4 HOUR),
        NULL, 'scheduled', 'public'),
    (3, 1, 3, 1, 'Private Rooftop Hangout',
        'Invite-only hangout on the slopes.',
        DATE_ADD(NOW(), INTERVAL 2 DAY),
        DATE_ADD(DATE_ADD(NOW(), INTERVAL 2 DAY), INTERVAL 3 HOUR),
        15, 'scheduled', 'private'),
    (4, 1, 4, 3, 'Trail Run - Hartwood',
        'Easy 5k trail run at Hartwood Acres.',
        DATE_ADD(NOW(), INTERVAL 4 DAY),
        DATE_ADD(DATE_ADD(NOW(), INTERVAL 4 DAY), INTERVAL 1 HOUR),
        25, 'scheduled', 'public')
    ON DUPLICATE KEY UPDATE title = VALUES(title);