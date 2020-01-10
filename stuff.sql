select value
from V$PARAMETER
where name = 'audit_trail';

-- enable audit
alter system set audit_trail=db,extended scope = spfile;


select *
from DBA_AUDIT_TRAIL;
select *
from dba_AUDIT_TRAIL;


select *
from dual;
select *
from ALL_POLICIES;


select *
from new_table;

select *
from sys.AUD$;


audit table by system;

select *
from ALL_TRIGGERS;

select user
from dual;

SELECT banner
FROM v$version
WHERE ROWNUM = 1;

select * from dba_users;

SELECT substr(grantee,1,20) grantee, owner, substr(table_name,1,15) table_name, grantor,privilege
FROM DBA_TAB_PRIVS;