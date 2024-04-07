-- CREATING TABLES
CREATE TABLE CRIMINAL (
    criminal_id INT,
    criminal_name VARCHAR(40),
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
    PRIMARY KEY(date_charged, criminal_id, crime_code, classification)
);

CREATE TABLE CRIME (
    crime_code CHAR(10),
    classification VARCHAR(40),
    crime_description VARCHAR(MAX),
    PRIMARY KEY(crime_code)
);

CREATE TABLE CRIME_CASE (
    case_id INT,
    appeal_status VARCHAR(20) REFERENCES APPEAL(appeal_status),
    date_charged DATE REFERENCES CHARGE(date_charged),
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
    PRIMARY KEY(appeal_id, criminal_id, case_id)
);

CREATE TABLE FINE (
    case_id INT REFERENCES CRIME_CASE(case_id),
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    fine_amount FLOAT,
    court_fee FLOAT,
    paid_amount FLOAT,
    payment_due_date DATE,
    PRIMARY KEY(case_id, criminal_id)
);

CREATE TABLE OFFICER (
    badge_number INT,
    officer_name VARCHAR(40),
    precinct VARCHAR(40),
    officer_phonenum VARCHAR(12),
    activity_status VARCHAR(20),
    officer_type VARCHAR(20),
    PRIMARY KEY(badge_number)
);

CREATE TABLE ARREST (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    badge_number INT REFERENCES OFFICER(badge_number),
    crime_code INT REFERENCES CRIME(crime_code),
    arrest_date DATE,
    PRIMARY KEY(criminal_id, badge_number, crime_code, arrest_date)
);

CREATE TABLE HEARING (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    case_id INT REFERENCES CRIME_CASE(case_id),
    hearing_date DATE,
    date_charged DATE REFERENCES CRIME_CASE(date_charged),
    PRIMARY KEY (criminal_id, case_id, hearing_date)
);

CREATE TABLE SENTENCING (
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    hearing_date DATE REFERENCES HEARING(hearing_date),
    sentence_id INT,
    starting_date DATE,
    end_date DATE,
    num_violations INT,
    sentence_type VARCHAR(40),
    PRIMARY KEY(criminal_id, hearing_date, sentence_id)
);

CREATE TABLE VIOLATION (
    violation_code CHAR(10),
    criminal_id INT REFERENCES CRIMINAL(riminal_id),
    badge_number INT REFERENCES OFFICER(badge_number),
    violaion_description VARCHAR(200),
    PRIMARY KEY(violation_code, criminal_id, badge_number)
);

-- INSERT STATEMENTS 10 VALUES PER TABLE
-- Entries for CRIMINAL table
-- Entries for CRIMINAL table
-- CRIMINAL table entries
INSERT INTO CRIMINAL (criminal_id, criminal_name, criminal_address, criminal_phonenum, violent_offender_stat, probation_status, alias)
VALUES
(1, 'John Doe', '123 Main St, City, State', '123-456-7890', FALSE, TRUE, 'JD'),
(2, 'Jane Smith', '456 Elm St, City, State', '987-654-3210', TRUE, FALSE, 'JS'),
(3, 'Michael Johnson', '789 Oak St, City, State', '456-789-0123', FALSE, FALSE, 'MJ'),
(4, 'Emily Brown', '321 Pine St, City, State', '789-012-3456', TRUE, TRUE, 'EB'),
(5, 'David Wilson', '654 Maple St, City, State', '234-567-8901', TRUE, TRUE, 'DW'),
(6, 'Sarah Adams', '789 Cedar St, City, State', '345-678-9012', TRUE, FALSE, 'SA'),
(7, 'Robert Garcia', '901 Birch St, City, State', '567-890-1234', FALSE, TRUE, 'RG'),
(8, 'Jennifer Martinez', '234 Walnut St, City, State', '678-901-2345', TRUE, FALSE, 'JM'),
(9, 'Daniel Thompson', '567 Pineapple St, City, State', '890-123-4567', FALSE, TRUE, 'DT'),
(10, 'Lisa Clark', '890 Cherry St, City, State', '012-345-6789', TRUE, TRUE, 'LC'),
(11, 'Matthew Lee', '123 Lemon St, City, State', '321-654-9870', TRUE, TRUE, 'ML'),
(12, 'Amanda Rodriguez', '456 Grape St, City, State', '543-876-1098', FALSE, FALSE, 'AR'),
(13, 'Kevin Harris', '789 Orange St, City, State', '765-098-3210', TRUE, TRUE, 'KH'),
(14, 'Michelle King', '234 Banana St, City, State', '987-210-5436', FALSE, TRUE, 'MK'),
(15, 'Ryan Wright', '567 Peach St, City, State', '876-543-2109', TRUE, FALSE, 'RW');

-- CHARGE table entries
INSERT INTO CHARGE (date_charged, criminal_id, crime_code)
VALUES
('2023-05-10', 1, 'ABC123'),
('2023-06-15', 2, 'DEF456'),
('2023-07-20', 3, 'GHI789'),
('2023-08-25', 4, 'JKL012'),
('2023-09-30', 5, 'MNO345'),
('2023-10-05', 6, 'PQR678'),
('2023-11-15', 7, 'STU901'),
('2023-12-20', 8, 'VWX234'),
('2024-01-25', 9, 'YZA567'),
('2024-02-28', 10, 'BCD890'),
('2024-03-10', 11, 'EFG123'),
('2024-04-15', 12, 'HIJ456'),
('2024-05-20', 13, 'KLM789'),
('2024-06-25', 14, 'NOP012'),
('2024-07-30', 15, 'QRS345');

-- CRIME table entries
INSERT INTO CRIME (crime_code, classification, crime_description)
VALUES
('ABC123', 'Theft', 'Theft of property.'),
('DEF456', 'Assault', 'Physical attack on another person.'),
('GHI789', 'Burglary', 'Breaking into a building to commit a crime.'),
('JKL012', 'Fraud', 'Deception for financial gain.'),
('MNO345', 'Drug Possession', 'Illegal possession of controlled substances.'),
('PQR678', 'Robbery', 'Theft by force or threat.'),
('STU901', 'Vandalism', 'Damage to property.'),
('VWX234', 'Forgery', 'Making false documents.'),
('YZA567', 'Arson', 'Intentional setting of fires.'),
('BCD890', 'Homicide', 'Murder or manslaughter.'),
('EFG123', 'Kidnapping', 'Illegal abduction of a person.'),
('HIJ456', 'Extortion', 'Coercion for money or property.'),
('KLM789', 'Sexual Assault', 'Non-consensual sexual activity.'),
('NOP012', 'Embezzlement', 'Misappropriation of funds.'),
('QRS345', 'Stalking', 'Persistent harassment or surveillance.');

-- CRIME_CASE table entries
INSERT INTO CRIME_CASE (case_id, appeal_status, date_charged, num_appeal, charge_status)
VALUES
(1, 'Pending', '2023-05-10', 0, 'Open'),
(2, 'Denied', '2023-06-15', 1, 'Closed'),
(3, 'Approved', '2023-07-20', 2, 'Closed'),
(4, 'Pending', '2023-08-25', 0, 'Open'),
(5, 'Pending', '2023-09-30', 0, 'Open'),
(6, 'Approved', '2023-10-05', 1, 'Closed'),
(7, 'Pending', '2023-11-15', 0, 'Open'),
(8, 'Denied', '2023-12-20', 1, 'Closed'),
(9, 'Pending', '2024-01-25', 0, 'Open'),
(10, 'Pending', '2024-02-28', 0, 'Open'),
(11, 'Approved', '2024-03-10', 2, 'Closed'),
(12, 'Pending', '2024-04-15', 0, 'Open'),
(13, 'Denied', '2024-05-20', 1, 'Closed'),
(14, 'Pending', '2024-06-25', 0, 'Open'),
(15, 'Pending', '2024-07-30', 0, 'Open');

-- APPEAL table entries
INSERT INTO APPEAL (appeal_id, criminal_id, case_id, num_appeal, appeal_file_date, appeal_hearing_date, appeal_status)
VALUES
(1, 1, 1, 1, '2023-06-01', '2023-06-30', 'Denied'),
(2, 2, 2, 0, '2023-07-18', '2023-08-10', 'Approved'),
(3, 3, 3, 0, '2023-08-01', '2023-08-25', 'Approved'),
(4, 4, 4, 1, '2023-09-10', '2023-10-05', 'Pending'),
(5, 5, 5, 2, '2023-10-01', '2023-10-20', 'Pending'),
(6, 6, 6, 0, '2023-10-10', '2023-11-05', 'Approved'),
(7, 7, 7, 1, '2023-11-25', '2023-12-15', 'Pending'),
(8, 8, 8, 0, '2024-01-30', '2024-02-20', 'Denied'),
(9, 9, 9, 1, '2024-02-25', '2024-03-20', 'Pending'),
(10, 10, 10, 0, '2024-03-30', '2024-04-15', 'Pending'),
(11, 11, 11, 2, '2024-04-20', '2024-05-10', 'Approved'),
(12, 12, 12, 0, '2024-05-30', '2024-06-20', 'Pending'),
(13, 13, 13, 1, '2024-06-30', '2024-07-20', 'Denied'),
(14, 14, 14, 0, '2024-07-31', '2024-08-15', 'Pending'),
(15, 15, 15, 0, '2024-08-25', '2024-09-10', 'Pending');

-- FINE table entries
INSERT INTO FINE (case_id, criminal_id, fine_amount, court_fee, paid_amount, payment_due_date)
VALUES
(1, 1, 500.00, 50.00, 0.00, '2023-07-30'),
(2, 2, 1000.00, 100.00, 1100.00, '2023-09-01'),
(3, 3, 750.00, 75.00, 825.00, '2023-09-10'),
(4, 4, 2000.00, 200.00, 0.00, '2023-10-15'),
(5, 5, 1500.00, 150.00, 0.00, '2023-11-01'),
(6, 6, 800.00, 80.00, 880.00, '2023-12-05'),
(7, 7, 1200.00, 120.00, 0.00, '2024-01-10'),
(8, 8, 600.00, 60.00, 0.00, '2024-02-25'),
(9, 9, 1000.00, 100.00, 0.00, '2024-03-30'),
(10, 10, 900.00, 90.00, 0.00, '2024-04-15'),
(11, 11, 2500.00, 250.00, 2700.00, '2024-05-20'),
(12, 12, 700.00, 70.00, 0.00, '2024-06-25'),
(13, 13, 1800.00, 180.00, 0.00, '2024-07-30'),
(14, 14, 300.00, 30.00, 0.00, '2024-08-15'),
(15, 15, 400.00, 40.00, 0.00, '2024-09-20');

-- OFFICER table entries
INSERT INTO OFFICER (badge_number, officer_name, precinct, officer_phonenum, activity_status, officer_type)
VALUES
(101, 'Officer Smith', 'Central', '111-222-3333', 'Active', 'Arresting'),
(102, 'Officer Johnson', 'East', '222-333-4444', 'Active', 'Probation'),
(103, 'Officer Williams', 'West', '333-444-5555', 'Active', 'Arresting'),
(104, 'Officer Brown', 'North', '444-555-6666', 'Active', 'Probation'),
(105, 'Officer Davis', 'South', '555-666-7777', 'Active', 'Arresting'),
(106, 'Officer Wilson', 'Central', '666-777-8888', 'Active', 'Probation'),
(107, 'Officer Taylor', 'East', '777-888-9999', 'Active', 'Arresting'),
(108, 'Officer Martinez', 'West', '888-999-0000', 'Active', 'Probation'),
(109, 'Officer Anderson', 'North', '999-000-1111', 'Active', 'Arresting'),
(110, 'Officer Garcia', 'South', '000-111-2222', 'Active', 'Probation'),
(111, 'Officer Lee', 'Central', '111-222-3333', 'Active', 'Arresting'),
(112, 'Officer Rodriguez', 'East', '222-333-4444', 'Active', 'Probation'),
(113, 'Officer Hernandez', 'West', '333-444-5555', 'Active', 'Arresting'),
(114, 'Officer Gonzalez', 'North', '444-555-6666', 'Active', 'Probation'),
(115, 'Officer Moore', 'South', '555-666-7777', 'Active', 'Arresting');

-- ARREST table entries
INSERT INTO ARREST (criminal_id, badge_number, crime_code, arrest_date)
VALUES
(1, 101, 'ABC123', '2023-05-10'),
(2, 102, 'DEF456', '2023-06-15'),
(3, 103, 'GHI789', '2023-07-20'),
(4, 104, 'JKL012', '2023-08-25'),
(5, 105, 'MNO345', '2023-09-30'),
(6, 106, 'PQR678', '2023-10-05'),
(7, 107, 'STU901', '2023-11-15'),
(8, 108, 'VWX234', '2023-12-20'),
(9, 109, 'YZA567', '2024-01-25'),
(10, 110, 'BCD890', '2024-02-28'),
(11, 111, 'EFG123', '2024-03-10'),
(12, 112, 'HIJ456', '2024-04-15'),
(13, 113, 'KLM789', '2024-05-20'),
(14, 114, 'NOP012', '2024-06-25'),
(15, 115, 'QRS345', '2024-07-30');

-- HEARING table entries
INSERT INTO HEARING (criminal_id, case_id, hearing_date, date_charged)
VALUES
(1, 1, '2023-06-30', '2023-05-10'),
(2, 2, '2023-08-10', '2023-06-15'),
(3, 3, '2023-08-25', '2023-07-20'),
(4, 4, '2023-10-05', '2023-08-25'),
(5, 5, '2023-10-20', '2023-09-30'),
(6, 6, '2023-11-10', '2023-10-05'),
(7, 7, '2023-12-20', '2023-11-15'),
(8, 8, '2024-01-25', '2023-12-20'),
(9, 9, '2024-02-28', '2024-01-25'),
(10, 10, '2024-03-10', '2024-02-28'),
(11, 11, '2024-04-15', '2024-03-10'),
(12, 12, '2024-05-20', '2024-04-15'),
(13, 13, '2024-06-25', '2024-05-20'),
(14, 14, '2024-07-30', '2024-06-25'),
(15, 15, '2024-08-25', '2024-07-30');

-- SENTENCING table entries
INSERT INTO SENTENCING (criminal_id, hearing_date, sentence_id, starting_date, end_date, num_violations, sentence_type)
VALUES
(1, '2023-06-30', 1, '2023-07-01', '2023-12-31', 0, 'Probation'),
(2, '2023-08-10', 1, '2023-08-11', '2024-08-10', 1, 'Prison'),
(3, '2023-08-25', 1, '2023-08-26', '2024-08-25', 0, 'Probation'),
(4, '2023-10-05', 1, '2023-10-06', '2023-12-31', 0, 'Probation'),
(5, '2023-10-20', 1, '2023-10-21', '2024-04-20', 0, 'Probation'),
(6, '2023-11-10', 1, '2023-11-11', '2024-05-10', 0, 'Probation'),
(7, '2023-12-20', 1, '2023-12-21', '2024-06-20', 0, 'Probation'),
(8, '2024-01-25', 1, '2024-01-26', '2024-07-25', 0, 'Probation'),
(9, '2024-02-28', 1, '2024-02-29', '2024-08-28', 0, 'Probation'),
(10, '2024-03-10', 1, '2024-03-11', '2024-09-10', 0, 'Probation'),
(11, '2024-04-15', 1, '2024-04-16', '2024-10-15', 0, 'Probation'),
(12, '2024-05-20', 1, '2024-05-21', '2024-11-20', 0, 'Probation'),
(13, '2024-06-25', 1, '2024-06-26', '2024-12-25', 0, 'Probation'),
(14, '2024-07-30', 1, '2024-07-31', '2025-01-30', 0, 'Probation'),
(15, '2024-08-25', 1, '2024-08-26', '2025-02-25', 0, 'Probation');

-- VIOLATION table entries
INSERT INTO VIOLATION (violation_code, criminal_id, badge_number, violation_description)
VALUES
('VIOL001', 1, 101, 'Assault on a civilian.'),
('VIOL002', 2, 102, 'Resisting arrest.'),
('VIOL003', 3, 103, 'Breaking and entering.'),
('VIOL004', 4, 104, 'Fraudulent activities.'),
('VIOL005', 5, 105, 'Drug possession and distribution.'),
('VIOL006', 6, 106, 'Robbery with deadly weapon.'),
('VIOL007', 7, 107, 'Vandalism of public property.'),
('VIOL008', 8, 108, 'Forgery of official documents.'),
('VIOL009', 9, 109, 'Arson of commercial building.'),
('VIOL010', 10, 110, 'Homicide of a family member.'),
('VIOL011', 11, 111, 'Kidnapping for ransom.'),
('VIOL012', 12, 112, 'Extortion of local businesses.'),
('VIOL013', 13, 113, 'Sexual assault on a minor.'),
('VIOL014', 14, 114, 'Embezzlement of company funds.'),
('VIOL015', 15, 115, 'Stalking and harassment.');
