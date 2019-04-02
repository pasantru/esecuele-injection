select * from v$datafile;

CREATE tablespace TS_MERCORACLE datafile 'mercoracle2.dbf' size 16M autoextend on next 200K MAXSIZE 160M;

drop user mercoracle cascade;

create user MERCORACLE identified by bd
default tablespace TS_MERCORACLE;
-- quota unlimited on MERCORACLE;

grant connect to mercoracle;
grant resource to mercoracle;
alter user mercoracle quota 10M on ts_mercoracle;

