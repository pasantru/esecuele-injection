create tablespace ts_pepito datafile 'pepito.dbf' size 20M autoextend on next 2M;

create user pepito identified by bd default tablespace ts_pepito quota unlimited on ts_pepito;

grant connect, resource to pepito;



CREATE DIRECTORY  exp_pepito  AS  'C:\Users\alumnos\Oracle\PracticaConcurrenciaPepito';
GRANT read, write ON DIRECTORY  exp_pepito  TO  pepito;
GRANT DATAPUMP_EXP_FULL_DATABASE TO pepito;

-- Ejecutar esto en el cmd:
-- expdp pepito/pepito@ORCL  DIRECTORY = exp_pepito  DUMPFILE =exp_schm_pepito.dmp  LOGFILE=pepito_lg.log SCHEMAS = pepito