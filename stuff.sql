-- enable audit
ALTER SYSTEM SET audit_trail=db,extended SCOPE = SPFILE;

SELECT value
FROM v$parameter
WHERE name = 'audit_trail';

-- -- sql+
-- sqlplus / as sysdba
-- shutdown immediate
-- sqlplus / as sysdba
-- startup


SELECT *
FROM dba_audit_trail;

ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE;
CREATE USER matei_admin IDENTIFIED BY password_test;
GRANT CREATE SESSION TO matei_admin;
GRANT CREATE TABLE TO matei_admin;
GRANT CREATE VIEW TO matei_admin;
GRANT CREATE SEQUENCE TO matei_admin;
GRANT UNLIMITED TABLESPACE TO matei_admin;
GRANT CREATE PROCEDURE TO matei_admin;
GRANT EXECUTE ANY PROCEDURE TO matei_admin;
GRANT CREATE TRIGGER TO matei_admin;



SELECT *
FROM sys.dba_users;


AUDIT TABLE BY matei_admin;