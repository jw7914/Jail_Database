

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