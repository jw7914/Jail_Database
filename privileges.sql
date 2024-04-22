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

CREATE USER 'public_user'@'localhost';

GRANT SELECT ON jail.* TO 'public_user'@'localhost';
GRANT INSERT ON jail.users TO 'public_user'@'localhost';
GRANT UPDATE ON jail.fine TO 'public_user'@'localhost';


-- Create officer view
-- No permission to view users
-- No permission to change tables only be able to view stuff

CREATE ROLE Officer_Role;

GRANT SELECT ON jail.* TO Officer_Role;

CREATE USER 'Officer_Role'@'localhost' IDENTIFIED BY 'password';
GRANT Officer_Role to 'Officer_Role'@'localhost';

-- Admin view = root user nothing to be done
-- Overall manager to manage officers and assign them to certain things