

--EJEMPLO DE EXAMEN DE OTRO AÑO (ESTE NO ES EL DE 2019)
--
--
--
--Escriba la respuesta a los siguientes ejercicios, poniendo entre /* */ el enunciado y a continuación la solución o, caso de ser una orden SQL, las instrucciones necesarias con sintaxis correcta.
--Puede utilizar la máquina virtual si la necesita. La entrega debe ser un fichero .sql.
--
-- 1. Un usuario de una base de datos Oracle ha creado una sesión que se ha quedado en un bucle infinito. Su identificador es ABDSEP01.
-- Escriba la sentencia para obtener las sesiones de ese usuario y cómo haría para matar una de ellas. 
select * from V$SESSION where schemaname like 'SYSTEM';
alter system kill session '27,42243'; -- los numeros que sean

-- 2. Escriba las instrucciones SQL para realizar lo siguiente:
--      2.1 Cree una tablespace denominado TS_Examen_SEP  8 MB de tamaño y que aumente de tamaño en incrementos de 2MB hasta un máximo de 32 MB.
        create tablespace TS_Examen_SEP datafile 'ts_examen_sep.dbf' size 8M autoextend on next 2M MAXSIZE 32M;
        
--      2.2 Se desea crear 2 tipos de usuarios PROFESOR y ALUMNO. Ambos tendrán 3 intentos para introducir la password antes de que se bloquee la cuenta y, además, la sesión de los ALUMNOS no podrá durar más de 120 minutos
        CREATE PROFILE PROFESOR LIMIT
            FAILED_LOGIN_ATTEMPTS 3;
        
        CREATE PROFILE ALUMNO LIMIT
            FAILED_LOGIN_ATTEMPTS 3
            CONNECT_TIME 120;
            
--      2.3 Cree un usuario de cada tipo (PROFE1 y ALUMNO1) y asigne a ambos usuarios por defecto el tablespace TS_Examen_SEP con QUOTA de 2 MB.
        CREATE USER PROFE1 IDENTIFIED BY bd
            DEFAULT TABLESPACE TS_Examen_SEP
            QUOTA 2M ON TS_Examen_SEP
            PROFILE PROFESOR;
            
        CREATE USER ALUMNO1 IDENTIFIED BY bd
            DEFAULT TABLESPACE TS_Examen_SEP
            QUOTA 2M ON TS_Examen_SEP
            PROFILE ALUMNO;
        
--      2.4 Otórguele permisos para conectarse a ambos usuarios y, sólo al PROFESOR, para crear tablas, crear vistas, crear vistas materializadas, seleccionar y alterar el esquema de cualquier tabla del sistema.
        grant connect to alumno1;
        
        grant connect to profe1;
        grant create table to profe1;
        grant create view to profe1;
        grant create materialized view to profe1;
        grant select any table to profe1;
        grant alter any table to profe1;
        
-- 3. Cree una tabla denominada TABLA1 en el esquema PROFE1 con los campos CODIGO number clave primaria, USUARIO varchar2(20), DESCRIPCION varchar2 (50). 
    /*
	--EJECUTAR COMO PROFE1
	    create table TABLA1 (codigo number, usuario varchar2(50), descripcion varchar2(50), primary key(codigo));

	*/
-- Cree una tabla denominada TABLA2 en el mismo esquema con los campos CODIGO number, USUARIO varchar2(20). El campo usuario de la TABLA2 será único.
    
-- 4. Suponiendo que estamos conectamos con SYSTEM, escriba la instrucción para saber en que fichero se localizan los datos de la TABLA1.
   /* select * from all_tables where table_name like 'TABLA1';
    
    select * from v$datafile;
    
    select * from v$tablespace;
    */
    
    SELECT U.TABLE_NAME, D.NAME "Fichero", T.NAME "tablespace"
    FROM ALL_TABLES U, V$TABLESPACE T join V$DATAFILE D on (D.TS#=T.TS#)
    WHERE (U.TABLESPACE_NAME = T.NAME) AND (U.OWNER = 'PROFE1') AND (U.TABLE_NAME = 'TABLA1');
    
-- 5. Se necesita crear un ROLE, denominado "ROLE_SEP" con los permisos necesarios para leer todos los atributos de la tabla TABLA2 así como insertar datos nuevos en ella. 
-- Escriba las instrucciones necesarias para crear el Role y concederle los permisos del Role al usuario ALUMNO1 y que, además, este usuario pueda otorgárselos a otro usuario.
    CREATE ROLE ROLE_SEP;
    grant select on profe1.tabla2 to role_sep;
    grant insert on profe1.tabla2 to role_sep;
    
    grant role_sep to alumno1 with admin option;
    
-- 6. Queremos que ALUMNO1 pueda leer los atributos CODIGO y DESCRIPCION de la TABLA1 pero no USUARIO. Además, sólo podrá modificar el atributo DESCRIPCION de dicha tabla. Escriba las instrucciones necesarias.
    
    /* 
    -- EJECUTAR ESTO EN EL USUARIO PROFE1:
    
    create view v_tabla1 as (
        select codigo, descripcion from tabla1
    );
    
    create view v2_tabla1 as (
        select descripcion from tabla1
    );
    */
    
    
    grant select on profe1.v_tabla1 to alumno1;
    grant select, insert on profe1.v2_tabla1 to alumno1;
    
-- 7. Cree un sinónimo público para la TABLA1.
    grant create public synonym to profe1;
    
    -- EJECUTAR ESTO COMO PROFE1
    -- create public synonym syn_tabla1 for tabla1;
    
-- 8. Se ha comprobado que el usuario EXAMEN2 realiza muchas búsquedas en la TABLA1 por el campo USUARIO. Además, existen pocos valores distintos que se repiten muchas veces. Cree índices adecuados para "agilizar" la consulta.
    /*
    -- EJECUTAR ESTO COMO PROFE1
    create index tabla1_ind1 on tabla1 (codigo, usuario);
    create index tabla1_ind2 on tabla1 (usuario);
    */