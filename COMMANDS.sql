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
    num_appeal INT,
    charge_status VARCHAR(10),
    PRIMARY KEY(case_id)
);

CREATE TABLE APPEAL (
    appeal_id INT,
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    case_id INT REFERENCES CRIME_CASE(case_id),
    num_appeal INT REFERENCES CRIME_CASE(num_appeal),
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

-- INSERT STATEMENTS 10 VALUES PER TABLE
INSERT INTO CRIMINAL (criminal_id, criminal_first, criminal_last, criminal_address, criminal_phonenum, violent_offender_stat, probation_status, alias) 
VALUES 
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
(15, 'Joshua', 'Taylor', '212 Pine St, Village, USA', '778-444-5555', TRUE, FALSE, 'JT');

-- CHARGE table entries
INSERT INTO CHARGE (date_charged, criminal_id, crime_code) 
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
('2023-11-05', 11, 'CC12345'),
('2023-12-10', 12, 'CC23456'),
('2024-01-15', 13, 'CC34567'),
('2024-02-20', 14, 'CC45678'),
('2024-03-25', 15, 'CC56789');

-- APPEAL table entries
INSERT INTO APPEAL (appeal_id, criminal_id, case_id, num_appeal, appeal_file_date, appeal_hearing_date, appeal_status)
VALUES
(1, 1, 1, 1, '2023-02-01', '2023-04-15', 'Pending'),
(2, 2, 2, 1, '2023-03-10', '2023-05-20', 'Granted'),
(3, 3, 3, 1, '2023-04-15', '2023-06-25', 'Denied'),
(4, 4, 4, 1, '2023-05-20', '2023-07-30', 'Pending'),
(5, 5, 5, 1, '2023-06-25', '2023-08-10', 'Granted'),
(6, 6, 6, 1, '2023-07-30', '2023-09-15', 'Pending'),
(7, 7, 7, 1, '2023-08-10', '2023-10-25', 'Denied'),
(8, 8, 8, 1, '2023-09-15', '2023-11-05', 'Granted'),
(9, 9, 9, 1, '2023-10-25', '2023-12-15', 'Pending'),
(10, 10, 10, 1, '2023-11-05', '2024-01-10', 'Pending'),
(11, 11, 11, 1, '2023-12-15', '2024-02-20', 'Granted'),
(12, 12, 12, 1, '2024-01-10', '2024-03-30', 'Pending'),
(13, 13, 13, 1, '2024-02-20', '2024-04-05', 'Denied'),
(14, 14, 14, 1, '2024-03-30', '2024-05-15', 'Pending'),
(15, 15, 15, 1, '2024-04-05', '2024-06-20', 'Granted');

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
(15, 15, 1800.00, 250.00, 0.00, '2024-05-01');

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
(1015, 'Justin', 'Green', 'Precinct 12', '980-555-6666', 'Active', 'Probation', '212 Oak St, Village, USA');

-- ARREST table entries
INSERT INTO ARREST (criminal_id, badge_number, crime_code, arrest_date)
VALUES
(1, 1001, 'CC12345', '2023-01-15'),
(2, 1002, 'CC23456', '2023-02-20'),
(3, 1003, 'CC34567', '2023-03-25'),
(4, 1004, 'CC45678', '2023-04-30'),
(5, 1005, 'CC56789', '2023-05-05'),
(6, 1006, 'CC67890', '2023-06-10'),
(7, 1007, 'CC78901', '2023-07-15'),
(8, 1008, 'CC89012', '2023-08-20'),
(9, 1009, 'CC90123', '2023-09-25'),
(10, 1010, 'CC01234', '2023-10-30'),
(11, 1011, 'CC12345', '2023-11-05'),
(12, 1012, 'CC23456', '2023-12-10'),
(13, 1013, 'CC34567', '2024-01-15'),
(14, 1014, 'CC45678', '2024-02-20'),
(15, 1015, 'CC56789', '2024-03-25');

-- PROBATION table entries
INSERT INTO PROBATION (criminal_id, badge_number, case_id)
VALUES
(1, 1001, 1),
(2, 1002, 2),
(3, 1003, 3),
(4, 1004, 4),
(5, 1005, 5),
(6, 1006, 6),
(7, 1007, 7),
(8, 1008, 8),
(9, 1009, 9),
(10, 1010, 10),
(11, 1011, 11),
(12, 1012, 12),
(13, 1013, 13),
(14, 1014, 14),
(15, 1015, 15);

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
('CC44556', 'Misdemeanor', 'Harassment');
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
(15, 15, '2024-05-15', '2024-03-25');

-- SENTENCING table entries
INSERT INTO SENTENCING (criminal_id, violation_code, hearing_date, sentence_id, starting_date, end_date, num_violations, sentence_type)
VALUES
(1, 'VC12345', '2023-03-01', 1, '2023-03-01', '2024-03-01', 1, 'Probation'),
(2, 'VC23456', '2023-04-05', 2, '2023-04-05', '2024-04-05', 1, 'Probation'),
(3, 'VC34567', '2023-05-10', 3, '2023-05-10', '2024-05-10', 1, 'Probation'),
(4, 'VC45678', '2023-06-15', 4, '2023-06-15', '2024-06-15', 1, 'Probation'),
(5, 'VC56789', '2023-07-20', 5, '2023-07-20', '2024-07-20', 1, 'Probation'),
(6, 'VC67890', '2023-08-25', 6, '2023-08-25', '2024-08-25', 1, 'Probation'),
(7, 'VC78901', '2023-09-30', 7, '2023-09-30', '2024-09-30', 1, 'Probation'),
(8, 'VC89012', '2023-10-05', 8, '2023-10-05', '2024-10-05', 1, 'Probation'),
(9, 'VC90123', '2023-11-10', 9, '2023-11-10', '2024-11-10', 1, 'Probation'),
(10, 'VC01234', '2023-12-15', 10, '2023-12-15', '2024-12-15', 1, 'Probation'),
(11, 'VC12345', '2024-01-20', 11, '2024-01-20', '2025-01-20', 1, 'Probation'),
(12, 'VC23456', '2024-02-25', 12, '2024-02-25', '2025-02-25', 1, 'Probation'),
(13, 'VC34567', '2024-03-05', 13, '2024-03-05', '2025-03-05', 1, 'Probation'),
(14, 'VC45678', '2024-04-10', 14, '2024-04-10', '2025-04-10', 1, 'Probation'),
(15, 'VC56789', '2024-05-15', 15, '2024-05-15', '2025-05-15', 1, 'Probation');

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
('VC11223', 11, 'Probation violation'),
('VC22334', 12, 'Probation violation'),
('VC33445', 13, 'Probation violation'),
('VC44556', 14, 'Probation violation'),
('VC55667', 15, 'Probation violation');
--SQL CODE

-- 3 MODES OF CRIMINAL SEARCH --> redirects to search result page
CREATE PROCEDURE find_inmate_FN(in first VARCHAR(20))
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.alias LIKE <ALIAS>;
end //

CREATE PROCEDURE find_inmate_FN(in first VARCHAR(20))
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE criminal.first_name LIKE <FIRST NAME> AND criminal.last_name LIKE <LAST NAME>
end //

CREATE PROCEDURE find_inmate_FN(in first VARCHAR(20))
begin
    SELECT criminal.criminal_first, criminal.criminal_last, criminal.alias, criminal.criminal_id, criminal.probation_status, sentencing.ending_date as release_date, hearing.hearing_date as next_hearing
    FROM criminal INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
    INNER JOIN sentencing ON hearing.hearing_date = sentencing.hearing_date
    WHERE hearing.case_id LIKE <CASE NUMBER>
end //

-- To get the number of matching results, we simply do:
SELECT COUNT(DISTINCT criminal_id)
FROM <SUBQUERY LISTED ABOVE>

-- 2 MODES OF OFFICER SEARCH and 2 Types of officers --> redirects to search result page
SELECT officer.officer_first, officer.officer_last, officer.probation_status officer.badge_number,  officer.activity_status
FROM officer
WHERE officer.badge_number LIKE <ID> AND officer.type LIKE 'probation'

SELECT officer.officer_first, officer.officer_last, officer.probation_status officer.badge_number,  officer.activity_status
FROM officer
WHERE officer.badge_number LIKE <ID> AND officer.type LIKE 'arresting'

SELECT officer.officer_first, officer.officer_last, officer.probation_status officer.badge_number,  officer.activity_status
FROM officer
WHERE officer.first_name LIKE <FIRST_NAME> AND officer.last_name LIKE <LAST_NAME> AND officer.type LIKE 'probation'

SELECT officer.officer_first, officer.officer_last, officer.probation_status officer.badge_number,  officer.activity_status
FROM officer
WHERE officer.first_name LIKE <FIRST_NAME> AND officer.last_name LIKE <LAST_NAME> AND officer.type LIKE 'arresting'


-- Display info for all types of crimes
SELECT crime.crime_code, crime.classification, crime.crime_description
FROM crime


-- Inmate Details Public Access
-- Inmate Details
SELECT criminal.name, criminal.criminal_id, criminal.alias, criminal.probation_status, criminal.violent_offender_stat, officer.officer_name
FROM criminal INNER JOIN arrest ON criminal.criminal_id = arrest.criminal_id
INNER JOIN officer ON arrest.badge_number = officer.badge_number
WHERE criminal.crimimal_id = <INPUT>

-- Crime cases
SELECT crime.crime_code, crime.classification, charge.date_charged, crime_case.appeal_status, hearing.hearing_date, appeal.appeal_status
FROM charge INNER JOIN criminal ON charge.criminal_id = criminal.criminal_id
INNER JOIN hearing ON criminal.criminal_id = hearing.criminal_id
INNER JOIN sentencing ON hearing.criminal_id = sentencing.criminal_id AND hearing.hearing_date = sentencing.hearing_date
INNER JOIN crime_case ON sentecing.sentence_id = crime_case.sentence_id
INNER JOIN appeal ON crime_case.appeal_id = appeal.appeal_id
WHERE criminal_id = <INPUT>

-- Sentences
SELECT sentence.sentence_id, sentence.sentence_type, sentence.starting_date, sentence.ending_date, sentence.num_violations
FROM sentence
WHERE sentence.criminal_id = <INPUT>

-- Fines and Fees
SELECT crime_case.case_id, fine.fine_amount, fine.paid_amount, fine.payment_due_date
FROM crime_case INNER JOIN fine ON crime.case_id = fine.case_id
WHERE fine.criminal_id = <INPUT>


-- Inmate Details Private Access
-- Inmate Details (This is the only different part)
-- Inmate Details
SELECT criminal.name, criminal.criminal_id, criminal.alias, criminal.probation_status, criminal.violent_offender_stat, officer.officer_name, criminal.criminal_address, criminal.criminal_phonenum
FROM criminal INNER JOIN arrest ON criminal.criminal_id = arrest.criminal_id
INNER JOIN officer ON arrest.badge_number = officer.badge_number
WHERE criminal.crimimal_id = <INPUT>


-- Officer Page
-- Officer Details (same for probation/arrest)
SELECT officer.name, officer.badge_number, officer.precinct, officer.officer_address, officer.officer_phonenum
FROM officer
WHERE officer.badge_number = <INPUT>

-- Probationaries
SELECT criminal.name, criminal.criminal_id
FROM criminal INNER JOIN probation ON criminal.criminal_id = probation.criminal_id
INNER JOIN officer ON probation.badge_number = officer.badge_number
WHERE officer.badge_number = <INPUT>

-- Arrests Made
SELECT criminal.name, criminal.criminal_id, arrest.arrest_date, arrest.crime_code
FROM criminal INNER JOIN arrest ON criminal.criminal_id = arrest.criminal_id
INNER JOIN officer ON arrest.badge_number = officer.badge_number
WHERE officer.badge_number = <INPUT>



-- PLSQL STATEMENTS
DELIMITER //
-- Procedure for Track/Find Inmate


-- Procedure to Track/Find Officer
CREATE PROCEDURE find_officer()

-- Procedure to get probation/arrest officers using officer_type attribute
CREATE PROCEDURE show_officer_type()
-- Function to show number of criminals shown
-- Make payments: Function AND trigger
-- Trigger to Get appeal_num for checking if appeals are over 3 aka MAX
-- Procedure to get probation/arrest officers using officer_type attribute