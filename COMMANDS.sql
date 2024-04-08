-- CREATING TABLES
CREATE TABLE CRIMINAL (
    criminal_id INT,
    criminal_first VARCHAR(40),
    criminal_last VARCHAR (40),
    criminal_address VARCHAR(150),
    criminal_phonenum VARCHAR(12),
    violent_offender_stat BOOLEAN,
    probation_status BOOLEAN,
    alias VARCHAR(20),
    PRIMARY KEY (criminal_id)
);

CREATE TABLE CHARGE (
    date_charged DATE,
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    crime_code CHAR(10) REFERENCES CRIME(crime_code),
    PRIMARY KEY(date_charged, criminal_id, crime_code)
);

CREATE TABLE CRIME (
    crime_code CHAR(10),
    classification VARCHAR(40),
    crime_description VARCHAR(255),
    PRIMARY KEY(crime_code)
);

CREATE TABLE CRIME_CASE (
    case_id INT,
    appeal_id VARCHAR(20) REFERENCES APPEAL(appeal_id),
    date_charged DATE REFERENCES CHARGE(date_charged),
    sentence_id INT REFERENCES SENTENCING(sentence_id),
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    num_appeal_remaining INT,
    charge_status VARCHAR(10),
    PRIMARY KEY(case_id)
);

CREATE TABLE APPEAL (
    appeal_id INT,
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    case_id INT REFERENCES CRIME_CASE(case_id),
    num_appeal_remaining INT REFERENCES CRIME_CASE(num_appeal_remaining),
    appeal_file_date DATE,
    appeal_hearing_date DATE,
    appeal_status VARCHAR(20),
    PRIMARY KEY(appeal_id, case_id)
);

CREATE TABLE FINE (
    case_id INT REFERENCES CRIME_CASE(case_id),
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    fine_amount FLOAT,
    court_fee FLOAT,
    paid_amount FLOAT,
    payment_due_date DATE,
    PRIMARY KEY(case_id)
);

CREATE TABLE OFFICER (
    badge_number INT,
    office_first VARCHAR(40),
    officer_last VARCHAR(40),
    precinct VARCHAR(40),
    officer_phonenum VARCHAR(12),
    activity_status VARCHAR(20),
    officer_type VARCHAR(20),
    officer_address VARCHAR(150),
    PRIMARY KEY(badge_number)
);

CREATE TABLE ARREST (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    badge_number INT REFERENCES OFFICER(badge_number),
    crime_code CHAR(10) REFERENCES CRIME(crime_code),
    arrest_date DATE,
    PRIMARY KEY(criminal_id, badge_number, arrest_date)
);

CREATE TABLE PROBATION (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    badge_number INT REFERENCES OFFICER(badge_number),
    case_id INT REFERENCES CRIME_CASE(case_id),
    PRIMARY KEY(criminal_id, badge_number, case_id)
);

CREATE TABLE HEARING (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    case_id INT REFERENCES CRIME_CASE(case_id),
    hearing_date DATE,
    date_charged DATE REFERENCES CRIME_CASE(date_charged),
    PRIMARY KEY (criminal_id, hearing_date)
);

CREATE TABLE SENTENCING (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    violation_code CHAR(10) REFERENCES VIOLATION(violation_code),
    hearing_date DATE REFERENCES HEARING(hearing_date),
    sentence_id INT,
    starting_date DATE,
    end_date DATE,
    num_violations INT,
    sentence_type VARCHAR(40),
    PRIMARY KEY(sentence_id)
);

CREATE TABLE VIOLATION (
    violation_code CHAR(10),
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    violation_description VARCHAR(200),
    PRIMARY KEY(violation_code, criminal_id)
);

-- INSERT STATEMENTS
-- CRIMINAL table entries
INSERT INTO CRIMINAL (criminal_id, criminal_first, criminal_last, criminal_address, criminal_phonenum, violent_offender_stat, probation_status, alias)
(1, 'John', 'Doe', '123 Main St, City, USA', '123-123-4567', FALSE, TRUE, 'JD'),
(2, 'Alice', 'Smith', '456 Elm St, Town, USA', '531-987-6543', TRUE, FALSE, 'AS'),
(3, 'Michael', 'Johnson', '789 Oak St, Village, USA', '541-111-2222', TRUE, TRUE, 'MJ'),
(4, 'Emily', 'Brown', '101 Pine St, City, USA', '432-222-3333', FALSE, FALSE, 'EB'),
(5, 'Robert', 'Williams', '202 Cedar St, Town, USA', '541-333-4444', TRUE, TRUE, 'RW'),
(6, 'Jennifer', 'Garcia', '303 Maple St, Village, USA', '555-444-5555', FALSE, TRUE, 'JG'),
(7, 'David', 'Martinez', '404 Birch St, City, USA', '321-555-6666', TRUE, FALSE, 'DM'),
(8, 'Jessica', 'Lopez', '505 Spruce St, Town, USA', '114-666-7777', FALSE, TRUE, 'JL'),
(9, 'Daniel', 'Gonzalez', '606 Pine St, Village, USA', '122-777-8888', TRUE, FALSE, 'DG'),
(10, 'Sarah', 'Rodriguez', '707 Oak St, City, USA', '675-888-9999', FALSE, TRUE, 'SR'),
(11, 'Christopher', 'Hernandez', '808 Cedar St, Town, USA', '124-999-0000', TRUE, FALSE, 'CH'),
(12, 'Ashley', 'Nguyen', '909 Maple St, Village, USA', '125-111-2222', FALSE, TRUE, 'AN'),
(13, 'Matthew', 'Walker', '010 Birch St, City, USA', '234-222-3333', TRUE, FALSE, 'MW'),
(14, 'Amanda', 'Perez', '111 Spruce St, Town, USA', '223-333-4444', FALSE, TRUE, 'AP'),
(15, 'Joshua', 'Taylor', '212 Pine St, Village, USA', '778-444-5555', TRUE, FALSE, 'JT'),
(16, 'Rachel', 'Clark', '404 Chestnut St, City, USA', '555-123-4567', FALSE, TRUE, 'RC'),
(17, 'Brian', 'Young', '505 Walnut St, Town, USA', '575-987-6543', TRUE, FALSE, 'BY'),
(18, 'Olivia', 'Hall', '606 Pine St, Village, USA', '666-111-2222', TRUE, FALSE, 'OH'),
(19, 'Steven', 'Wright', '707 Oak St, City, USA', '999-222-3333', FALSE, FALSE, 'SW'),
(20, 'Natalie', 'King', '808 Cedar St, Town, USA', '888-333-4444', TRUE, FALSE, 'NK');

-- CHARGE table entries
INSERT INTO CHARGE (date_charged, criminal_id, crime_code) --
VALUES 
('2023-01-15', 1, 'CC12345'),
('2023-02-20', 2, 'CC23456'),
('2023-03-25', 3, 'CC34567'),
('2023-04-30', 4, 'CC45678'),
('2023-05-05', 5, 'CC56789'),
('2023-06-10', 6, 'CC67890'),
('2023-07-15', 7, 'CC78901'),
('2023-08-20', 8, 'CC89012'),
('2023-09-25', 9, 'CC90123'),
('2023-10-30', 10, 'CC01234'),
('2023-11-05', 11, 'CC66778'),
('2023-12-10', 12, 'CC11227'),
('2024-01-15', 13, 'CC88990'),
('2024-02-20', 14, 'CC99001'),
('2024-03-25', 15, 'CC42556'),
('2024-04-01', 16, 'CC00112'),
('2024-04-02', 17, 'CC29334'),
('2024-04-03', 18, 'CC77889'),
('2024-04-04', 19, 'CC55667'),
('2024-04-05', 20, 'CC22334');

-- APPEAL table entries
INSERT INTO APPEAL (appeal_id, criminal_id, case_id, num_appeal_remaining, appeal_file_date, appeal_hearing_date, appeal_status) 
VALUES
(1, 1, 1, 0, '2023-02-01', '2023-04-15', 'Pending'),
(2, 2, 2, 2, '2023-03-10', '2023-05-20', 'Granted'),
(3, 3, 3, 0, '2023-04-15', '2023-06-25', 'Denied'),
(4, 4, 4, 2, '2023-05-20', '2023-07-30', 'Pending'),
(5, 5, 5, 0, '2023-06-25', '2023-08-10', 'Granted'),
(6, 6, 6, 1, '2023-07-30', '2023-09-15', 'Pending'),
(7, 7, 7, 0, '2023-08-10', '2023-10-25', 'Denied'),
(8, 8, 8, 0, '2023-09-15', '2023-11-05', 'Granted'),
(9, 9, 9, 0, '2023-10-25', '2023-12-15', 'Pending'),
(10, 10, 10, 3, '2023-11-05', '2024-01-10', 'Pending'),
(11, 11, 11, 1, '2023-12-15', '2024-02-20', 'Granted'),
(12, 12, 12, 0, '2024-01-10', '2024-03-30', 'Pending'),
(13, 13, 13, 2, '2024-02-20', '2024-04-05', 'Denied'),
(14, 14, 14, 0, '2024-03-30', '2024-05-15', 'Pending'),
(15, 15, 15, 0, '2024-04-05', '2024-06-20', 'Granted'),
(16, 16, 16, 3, '2024-07-05', '2024-09-20', 'Pending'),
(17, 17, 17, 2, '2024-06-03', '2024-08-20', 'Pending'),
(18, 18, 18, 0, '2024-04-11', '2024-06-30', 'Pending'),
(19, 19, 19, 3, '2024-04-13', '2024-06-23', 'Pending'),
(20, 20, 20, 3, '2024-05-05', '2024-07-20', 'Pending');

-- CRIME_CASE table entries
INSERT INTO CRIME_CASE (case_id, appeal_id, date_charged, sentence_id, criminal_id, num_appeal_remaining, charge_status) 
VALUES
(1, 1, '2023-01-15', 1, 1, 0, 'Pending'),
(2, 2, '2023-02-20', 2, 2, 2, 'Closed'),
(3, 3, '2023-03-25', 3, 3, 0, 'Open'),
(4, 4, '2023-04-30', 4, 4, 2, 'Closed'),
(5, 5, '2023-05-05', 5, 5, 0, 'Pending'),
(6, 6, '2023-06-10', 6, 6, 1, 'Closed'),
(7, 7, '2023-07-15', 7, 7, 0, 'Open'),
(8, 8, '2023-08-20', 8, 8, 0, 'Closed'),
(9, 9, '2023-09-25', 9, 9, 0, 'Open'),
(10, 10, '2023-10-30', 10, 10, 3, 'Closed'),
(11, 11, '2023-11-05', 11, 11, 1, 'Pending'),
(12, 12, '2023-12-10', 12, 12, 0, 'Closed'),
(13, 13, '2024-01-15', 13, 13, 2, 'Open'),
(14, 14, '2024-02-20', 14, 14, 0, 'Closed'),
(15, 15, '2024-03-25', 15, 15, 0, 'Pending'),
(16, 16, '2024-04-01', 16, 16, 3, 'Pending'),
(17, 17, '2024-04-02', 17, 17, 2, 'Pending'),
(18, 18, '2024-04-03', 18, 18, 0, 'Closed'),
(19, 19, '2024-04-04', 19, 19, 3, 'Open'),
(20, 20, '2024-04-05', 20, 20, 3, 'Open');

-- FINE table entries
INSERT INTO FINE (case_id, criminal_id, fine_amount, court_fee, paid_amount, payment_due_date) 
VALUES
(1, 1, 1500.00, 200.00, 0.00, '2023-03-01'),
(2, 2, 1000.00, 150.00, 250.00, '2023-04-01'),
(3, 3, 2000.00, 300.00, 0.00, '2023-05-01'),
(4, 4, 500.00, 100.00, 0.00, '2023-06-01'),
(5, 5, 2500.00, 400.00, 500.00, '2023-07-01'),
(6, 6, 300.00, 50.00, 50.00, '2023-08-01'),
(7, 7, 5000.00, 800.00, 0.00, '2023-09-01'),
(8, 8, 700.00, 100.00, 100.00, '2023-10-01'),
(9, 9, 1000.00, 200.00, 0.00, '2023-11-01'),
(10, 10, 1200.00, 300.00, 0.00, '2023-12-01'),
(11, 11, 2000.00, 400.00, 200.00, '2024-01-01'),
(12, 12, 150.00, 50.00, 0.00, '2024-02-01'),
(13, 13, 3000.00, 500.00, 0.00, '2024-03-01'),
(14, 14, 250.00, 50.00, 0.00, '2024-04-01'),
(15, 15, 600.00, 250.00, 0.00, '2024-05-01'),
(16, 16, 2000.00, 250.00, 0.00, '2024-06-01'),
(17, 17, 1850.00, 250.00, 0.00, '2024-05-04'),
(18, 18, 1700.00, 250.00, 0.00, '2024-05-09'),
(19, 19, 800.00, 250.00, 0.00, '2024-07-01'),
(20, 20, 2800.00, 250.00, 0.00, '2024-04-22');

-- OFFICER table entries
INSERT INTO OFFICER (badge_number, office_first, officer_last, precinct, officer_phonenum, activity_status, officer_type, officer_address) 
VALUES
(1001, 'Michael', 'Brown', 'Precinct 1', '565-111-2232', 'Active', 'Arrest', '123 Elm St, City, USA'),
(1002, 'Jennifer', 'Davis', 'Precinct 2', '998-222-3333', 'Active', 'Arrest', '456 Oak St, Town, USA'),
(1003, 'William', 'Wilson', 'Precinct 1', '679-333-4444', 'Active', 'Arrest', '789 Maple St, Village, USA'),
(1004, 'Jessica', 'Taylor', 'Precinct 4', '650-444-5555', 'Active', 'Probation', '101 Cedar St, City, USA'),
(1005, 'David', 'Miller', 'Precinct 5', '657-555-6666', 'Active', 'Probation', '202 Pine St, Town, USA'),
(1006, 'Sarah', 'Anderson', 'Precinct 6', '898-666-7777', 'Active', 'Arrest', '303 Elm St, Village, USA'),
(1007, 'Matthew', 'Thomas', 'Precinct 7', '999-777-8888', 'Active', 'Probation', '404 Oak St, City, USA'),
(1008, 'Emily', 'Jackson', 'Precinct 5', '469-888-9999', 'Active', 'Probation', '505 Maple St, Town, USA'),
(1009, 'Daniel', 'White', 'Precinct 9', '996-999-0000', 'Active', 'Arrest', '606 Cedar St, Village, USA'),
(1010, 'Amanda', 'Harris', 'Precinct 10', '659-000-1111', 'Active', 'Probation', '707 Elm St, City, USA'),
(1011, 'Christopher', 'Young', 'Precinct 11', '567-111-2222', 'Active', 'Probation', '808 Oak St, Town, USA'),
(1012, 'Ashley', 'King', 'Precinct 12', '979-222-3333', 'Active', 'Arrest', '909 Maple St, Village, USA'),
(1013, 'Jason', 'Wu', 'Precinct 13', '932-333-4444', 'Active', 'Probation', '010 Cedar St, City, USA'),
(1014, 'Nicole', 'Scott', 'Precinct 12', '627-444-5555', 'Active', 'Arrest', '111 Elm St, Town, USA'),
(1015, 'Justin', 'Green', 'Precinct 12', '980-555-6666', 'Active', 'Probation', '212 Oak St, Village, USA'),
(1016, 'Emily', 'Garcia', 'Precinct 15', '555-111-2222', 'Active', 'Arrest', '313 Elm St, City, USA'),
(1017, 'Daniel', 'Martinez', 'Precinct 9', '667-222-3333', 'Active', 'Probation', '717 Oak St, Town, USA'),
(1018, 'Ashley', 'Hernandez', 'Precinct 11', '222-333-4444', 'Active', 'Arrest', '818 Maple St, Village, USA'),
(1019, 'Alex', 'Tang', 'Precinct 10', '333-444-5555', 'Active', 'Probation', '919 Cedar St, City, USA'),
(1020, 'Rielle', 'Lim', 'Precinct 10', '444-555-6666', 'Active', 'Arrest', '020 Pine St, Town, USA');

-- ARREST table entries
INSERT INTO ARREST (criminal_id, badge_number, crime_code, arrest_date) 
VALUES
(2, 1001, 'CC12345', '2023-01-15'),
(4, 1002, 'CC23456', '2023-02-20'),
(7, 1003, 'CC34567', '2023-03-25'),
(9, 1006, 'CC45678', '2023-04-30'),
(13, 1009, 'CC56789', '2023-05-05'),
(15, 1012, 'CC67890', '2023-06-10'),
(17, 1014, 'CC78901', '2023-07-15'),
(18, 1016, 'CC89012', '2023-08-20'),
(19, 1018, 'CC90123', '2023-09-25'),
(20, 1020, 'CC01234', '2023-10-30');

-- PROBATION table entries
INSERT INTO PROBATION (criminal_id, badge_number, case_id) 
VALUES
(1, 1004, 1),
(3, 1005, 2),
(5, 1008, 3),
(6, 1007, 4),
(8, 1019, 5),
(10, 1017, 6),
(11, 1010, 7),
(12, 1011, 8),
(14, 1013, 9),
(16, 1015, 10);

-- CRIME table entries
INSERT INTO CRIME (crime_code, classification, crime_description) 
VALUES 
('CC12345', 'Felony', 'Theft'),
('CC23456', 'Misdemeanor', 'Assault'),
('CC34567', 'Felony', 'Burglary'),
('CC45678', 'Misdemeanor', 'Vandalism'),
('CC56789', 'Felony', 'Robbery'),
('CC67890', 'Misdemeanor', 'Drug Possession'),
('CC78901', 'Felony', 'Homicide'),
('CC89012', 'Misdemeanor', 'DUI'),
('CC90123', 'Felony', 'Kidnapping'),
('CC01234', 'Misdemeanor', 'Disorderly Conduct'),
('CC11223', 'Felony', 'Arson'),
('CC22334', 'Misdemeanor', 'Trespassing'),
('CC33945', 'Felony', 'Identity Theft'),
('CC44526', 'Misdemeanor', 'Public Intoxication'),
('CC55667', 'Felony', 'Fraud'),
('CC66778', 'Misdemeanor', 'Shoplifting'),
('CC77889', 'Felony', 'Assault with Deadly Weapon'),
('CC88990', 'Misdemeanor', 'Criminal Mischief'),
('CC99001', 'Felony', 'Forgery'),
('CC00112', 'Misdemeanor', 'Reckless Driving'),
('CC11227', 'Felony', 'Money Laundering'),
('CC29334', 'Misdemeanor', 'Simple Assault'),
('CC33465', 'Felony', 'Embezzlement'),
('CC44556', 'Misdemeanor', 'Harassment'),
('CC42556', 'Misdemeanor', 'Battery');

-- HEARING table entries
INSERT INTO HEARING (criminal_id, case_id, hearing_date, date_charged) 
VALUES
(1, 1, '2023-03-01', '2023-01-15'),
(2, 2, '2023-04-05', '2023-02-20'),
(3, 3, '2023-05-10', '2023-03-25'),
(4, 4, '2023-06-15', '2023-04-30'),
(5, 5, '2023-07-20', '2023-05-05'),
(6, 6, '2023-08-25', '2023-06-10'),
(7, 7, '2023-09-30', '2023-07-15'),
(8, 8, '2023-10-05', '2023-08-20'),
(9, 9, '2023-11-10', '2023-09-25'),
(10, 10, '2023-12-15', '2023-10-30'),
(11, 11, '2024-01-20', '2023-11-05'),
(12, 12, '2024-02-25', '2023-12-10'),
(13, 13, '2024-03-05', '2024-01-15'),
(14, 14, '2024-04-10', '2024-02-20'),
(15, 15, '2024-05-15', '2024-03-25'),
(16, 16, '2024-06-15', '2024-04-01'),
(17, 17, '2024-06-16', '2024-04-02'),
(18, 18, '2024-06-17', '2024-04-03'),
(19, 19, '2024-06-18', '2024-04-04'),
(20, 20, '2024-06-19', '2024-04-05');

-- SENTENCING table entries
INSERT INTO SENTENCING (criminal_id, violation_code, hearing_date, sentence_id, starting_date, end_date, num_violations, sentence_type)
VALUES
(1, 'VC12325', '2023-03-01', 1, '2023-03-01', '2024-07-01', 1, 'Jail'),
(2, 'VC23456', '2023-04-05', 2, '2023-04-05', '2024-08-05', 1, 'Fine'),
(3, 'VC34567', '2023-05-10', 3, '2023-05-10', '2024-09-10', 1, 'Probation'),
(4, 'VC45678', '2023-06-15', 4, '2023-06-15', '2024-10-15', 1, 'Jail'),
(5, 'VC56789', '2023-07-20', 5, '2023-07-20', '2024-11-20', 1, 'Community Service'),
(6, 'VC67890', '2023-08-25', 6, '2023-08-25', '2024-12-25', 1, 'Parole'),
(7, 'VC78901', '2023-09-30', 7, '2023-09-30', '2025-01-30', 1, 'Restitution'),
(8, 'VC89012', '2023-10-05', 8, '2023-10-05', '2025-01-05', 1, 'Probation'),
(9, 'VC90123', '2023-11-10', 9, '2023-11-10', '2025-04-10', 1, 'Jail'),
(10, 'VC01234', '2023-12-15', 10, '2023-12-15', '2025-04-15', 1, 'Community Service'),
(11, 'VC11223', '2024-01-20', 11, '2024-01-20', '2025-05-20', 1, 'Fine'),
(12, 'VC22334', '2024-02-25', 12, '2024-02-25', '2025-06-25', 1, 'Probation'),
(13, 'VC33445', '2024-03-05', 13, '2024-03-05', '2025-07-05', 1, 'Probation'),
(14, 'VC44556', '2024-04-10', 14, '2024-04-10', '2025-08-10', 1, 'Probation'),
(15, 'VC44556', '2024-05-15', 15, '2024-05-15', '2025-09-15', 1, 'Probation'),
(16, 'VC11223', '2024-06-15', 16, '2024-06-15','2025-10-15', 1, 'Parole'),
(17, 'VC89012', '2024-06-16', 17,'2024-06-16', '2024-10-16', 1, 'Parole'),
(18, 'VC90123', '2024-06-17', 18, '2024-06-17', '2024-10-16', 1, 'Jail'),
(19, 'VC78901', '2024-06-18', 19, '2024-06-18', '2024-10-16', 1, 'Jail'),
(20, 'VC12345', '2024-06-19', 20, '2024-06-19', '2024-10-16', 1, 'Community Service');

-- VIOLATION table entries
INSERT INTO VIOLATION (violation_code, criminal_id, violation_description) 
VALUES
('VC12345', 1, 'Theft violation'),
('VC23456', 2, 'Assault violation'),
('VC34567', 3, 'Burglary violation'),
('VC45678', 4, 'Vandalism violation'),
('VC56789', 5, 'Robbery violation'),
('VC67890', 6, 'Drug Possession violation'),
('VC78901', 7, 'Homicide violation'),
('VC89012', 8, 'DUI violation'),
('VC90123', 9, 'Kidnapping violation'),
('VC01234', 10, 'Disorderly Conduct violation'),
('VC11223', 11, 'Public Intoxication violation'),
('VC22334', 12, 'Reckless Driving violation'),
('VC33445', 13, 'Simple Assault violation'),
('VC44556', 14, 'Battery violation'),
('VC44556', 15, 'Battery violation'),
('VC11223', 16, 'Public Intoxication violation'),
('VC89012', 17, 'DUI violation'),
('VC90123', 18, 'Kidnapping violation'),
('VC78901', 19, 'Homicide violation'),
('VC12345', 20, 'Theft violation');
-- SQL CODE
DELIMITER //
-- SEARCHES/INFO DISPLAY (No triggers needed)
-- 3 MODES OF CRIMINAL SEARCH --> redirects to search result page
DROP PROCEDURE IF EXISTS find_inmate_alias //
CREATE PROCEDURE find_inmate_alias(in alias VARCHAR(50), out matches INT)
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.alias LIKE alias;

    SELECT COUNT(DISTINCT criminal.criminal_id) INTO matches
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.alias LIKE alias;
end //

DROP PROCEDURE IF EXISTS find_inmate_fullname //
CREATE PROCEDURE find_inmate_fullname(in first VARCHAR(20), in last VARCHAR(20), out matches INT)
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.first_name LIKE first AND criminal.last_name LIKE last;

    SELECT COUNT(DISTINCT criminal.criminal_id) INTO matches
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.first_name LIKE first AND criminal.last_name LIKE last;
end //

DROP PROCEDURE IF EXISTS find_inmate_firstname //
CREATE PROCEDURE find_inmate_firstname(in first VARCHAR(20), out matches INT)
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.first_name LIKE first;

    SELECT COUNT(DISTINCT criminal.criminal_id) INTO matches
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.first_name LIKE first;
end //

DROP PROCEDURE IF EXISTS find_inmate_lastname //
CREATE PROCEDURE find_inmate_lastname(in last VARCHAR(20), out matches INT)
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.last_name LIKE last;

    SELECT COUNT(DISTINCT criminal.criminal_id) INTO matches
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.last_name LIKE last;
end //

DROP PROCEDURE IF EXISTS find_inmate_casenum //
CREATE PROCEDURE find_inmate_casenum(in case_id INT, out matches INT)
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE hearing.case_id LIKE case_id;

    SELECT COUNT(DISTINCT criminal.criminal_id) INTO matches
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE hearing.case_id LIKE case_id;
end //

-- 2 MODES OF OFFICER SEARCH and 2 Types of officers --> redirects to search result page
DROP PROCEDURE IF EXISTS find_po_badge //
CREATE PROCEDURE find_po_badge(in badge_num INT, out matches INT)
begin
    SELECT CONCAT(officer.officer_first, ' ', officer.officer_last) as officer_name, officer.officer_type, officer.activity_status
    FROM officer
    WHERE officer.badge_number = badge_num AND officer.type LIKE 'probation';

    SELECT COUNT(DISTINCT officer.badge_number) INTO matches
    FROM officer
    WHERE officer.badge_number = badge_num AND officer.type LIKE 'probation';
end //

DROP PROCEDURE IF EXISTS find_ao_badge //
CREATE PROCEDURE find_ao_badge(in badge_num INT, out matches INT)
begin
    SELECT CONCAT(officer.officer_first, ' ', officer.officer_last) as officer_name, officer.officer_type, officer.activity_status
    FROM officer
    WHERE officer.badge_number = badge_num AND officer.type LIKE 'arresting';

    SELECT COUNT(DISTINCT officer.badge_number) INTO matches
    FROM officer
    WHERE officer.badge_number = badge_num AND officer.type LIKE 'arresting';
end //

DROP PROCEDURE IF EXISTS find_po_name //
CREATE PROCEDURE find_po_name(in first VARCHAR(20), in last VARCHAR(20), out matches INT)
begin
    SELECT CONCAT(officer.officer_first, ' ', officer.officer_last) as officer_name, officer.officer_type, officer.activity_status
    FROM officer
    WHERE officer.officer_first LIKE first AND officer.officer_last LIKE last AND officer.type LIKE 'probation';

    SELECT COUNT(DISTINCT officer.badge_number) INTO matches
    FROM officer
    WHERE officer.officer_first LIKE first AND officer.officer_last LIKE last AND officer.type LIKE 'probation';
end //

DROP PROCEDURE IF EXISTS find_po_name //
CREATE PROCEDURE find_po_name(in first VARCHAR(20), in last VARCHAR(20), out matches INT)
begin
    SELECT CONCAT(officer.officer_first, ' ', officer.officer_last) as officer_name, officer.officer_type, officer.activity_status
    FROM officer
    WHERE officer.officer_first LIKE first AND officer.officer_last LIKE last AND officer.type LIKE 'arresting';

    SELECT COUNT(DISTINCT officer.badge_number) INTO matches
    FROM officer
    WHERE officer.officer_first LIKE first AND officer.officer_last LIKE last AND officer.type LIKE 'arresting';
end //

-- Display info for all types of crimes
SELECT crime.crime_code, crime.classification, crime.crime_description
FROM crime

-- FUNCTIONS/TRIGGERS
-- Make payments: Function
CREATE FUNCTION make_payment(IN payment FLOAT, IN case INT) returns FLOAT DETERMINISTIC
begin
    DECLARE amt_owed FLOAT;

    SET amt_owed = amt_owed + fine.fine_amount + fine.court_fee;
    UPDATE fine SET paid_amount = payment
    RETURN amt_owed;
end //

CREATE FUNCTION new_appeal(IN caseId INT, IN crim_id)
begin
    DECLARE new_app_ID INT;
    SET new_app_ID = SELECT COUNT(DISTINCT appeal.appeal_id);
    IF num_appeals_remaining > 0 AND caseId IS NOT NULL then
        UPDATE appeal SET num_appeals_remaining = num_appeals_remaining - 1
        WHERE appeal.case_id = caseId;

        SET new_app_ID = new_app_ID + 1;
        INSERT INTO appeal VALUES(new_app_ID, crim_id, caseId, num_appeals_remaining);
    END IF;
end //