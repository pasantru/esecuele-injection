-- 2
password;
-- 3
select * from DBA_tablespaces;
CREATE tablespace MERCORACLE datafile 'mercoracle.dbf' size 10M autoextend on;

-- 4
create profile perf_administrativo limit
sessions_per_user 3
connect_time unlimited
idle_time 5
failed_login_attempts 3
password_life_time 90
password_grace_time 3;

-- 5
create profile perf_empleado limit
sessions_per_user 4
connect_time unlimited
idle_time 5
failed_login_attempts 3
password_life_time 30
password_grace_time 3;

-- 6
show parameter resource_limit;

--7
create role R_ADMINISTRADOR_SUPER;
grant connect to R_ADMINISTRADOR_SUPER;
grant create session to R_ADMINISTRADOR_SUPER;
grant create any TABLE to R_ADMINISTRADOR_SUPER;

-- 8
create user USUARIO1 identified by usuario
default tablespace MERCORACLE
quota 1M on MERCORACLE
profile perf_administrativo;

create user USUARIO2 identified by usuario
default tablespace MERCORACLE
quota 1M on MERCORACLE
profile perf_administrativo;

grant R_ADMINISTRADOR_SUPER to USUARIO1;
grant R_ADMINISTRADOR_SUPER to USUARIO2;

-- 9
create table USUARIO1.TABLA2
( CODIGO NUMBER );

create table USUARIO2.TABLA2
( CODIGO NUMBER );

-- 10
CREATE OR REPLACE PROCEDURE USUARIO1.PR_INSERTA_TABLA2(
    P_CODIGO IN NUMBER)AS
   BEGIN
      INSERT INTO TABLA2 VALUES (P_CODIGO);
   END PR_INSERTA_TABLA2;
/
   
-- 11 Haciendo login en el USUARIO1:
EXEC PR_INSERTA_TABLA2(10);
-- Funciona

-- 12
grant execute ON USUARIO1.PR_INSERTA_TABLA2 TO USUARIO2;

-- 13 Haciendo login en el USUARIO1:
exec USUARIO1.PR_INSERTA_TABLA2(11);
SELECT * FROM TABLA2;
-- Hay que hacer un commit tras ejecutarlo.

-- 14
-- Se guarda en la de USUARIO1, ya que se el procedimiento está en el esquema del USUARIO1.

-- 15
CREATE OR REPLACE PROCEDURE USUARIO1.PR_INSERTA_TABLA2(
    P_CODIGO IN NUMBER)AS
   BEGIN
    execute immediate 'INSERT INTO TABLA2 VALUES ('||P_CODIGO||')';
   END PR_INSERTA_TABLA2;
/

-- 16 y 17
-- En ambos casos funciona.

-- 18
CREATE OR REPLACE PROCEDURE USUARIO1.PR_CREA_TABLA(
    P_TABLA IN VARCHAR2, P_ATRIBUTO IN VARCHAR2)AS
   BEGIN
    execute immediate 'CREATE TABLE '||P_TABLA||'('||P_ATRIBUTO||' NUMBER(9))';
   END PR_CREA_TABLA;
/

-- 19
-- No, hay que asignarle permisos.

-- 20
grant create table to USUASRIO1;
grant execute ON USUARIO1.PR_CREA_TABLA TO USUARIO2;

-- 21 SI.