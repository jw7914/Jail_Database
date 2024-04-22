-- Create public view
-- Allows: 
    -- criminal info - personal, 
    -- crime_code (charge), 
    -- appeal status (appeal),
    -- fines (all), 
    -- date charged and hearing date (hearing),
    -- sentence id, start/end dates sen_type (sentencing)
-- No permissions to change table aka  INSERT, UPDATE, DELETE
-- Only insert, update permission to update fines
CREATE VIEW civ_inmate_view AS
SELECT criminal_id, criminal_first, criminal_last, violent_offender_stat, probation_status, alias
FROM Criminal;

CREATE VIEW civ_appeal_view AS
SELECT appeal_status
FROM APPEAL;

CREATE VIEW civ_charge_view AS
SELECT crime_code
FROM CHARGE;

CREATE VIEW civ_sentence_view AS
SELECT hearing_date, starting_date, end_date, sentence_type
FROM SENTENCING;

CREATE ROLE Civilian;

REVOKE ALL ON jail.* FROM Civilian;

GRANT SELECT ON jail.civ_inmate_view TO PUBLIC;
GRANT SELECT ON jail.civ_appeal_view TO PUBLIC;
GRANT SELECT ON jail.civ_charge_view TO PUBLIC;
GRANT SELECT ON jail.civ_sentence_view TO PUBLIC;



-- -- Create officer view
-- -- No permission to view users
-- -- No permission to change tables only be able to view stuff

CREATE ROLE Officer_Role;

REVOKE ALL ON jail.USERS FROM Officer_Role;
CREATE USER 'officer'@'localhost' IDENTIFIED BY 'password';
GRANT Officer to 'officer'

-- -- Admin view = root user nothing to be done
-- -- Overall manager to manage officers and assign them to certain things