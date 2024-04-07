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
    classification VARCHAR(40) REFERENCES CRIME(classification),
    PRIMARY KEY(date_charged, criminal_id, crime_code, classification)
);

CREATE TABLE CRIME (
    crime_code CHAR(10),
    classification VARCHAR(40),
    PRIMARY KEY(crime_code, classification)
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
    criminal_id INT REFERENCES CRIMINAL(criminal_id),
    badge_number INT REFERENCES OFFICER(badge_number),
    violaion_description VARCHAR(200),
    PRIMARY KEY(violation_code, criminal_id, badge_number)
);

-- INSERT STATEMENTS 10 VALUES PER TABLE