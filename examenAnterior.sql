

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
alter system kill session '27,42243';

-- 2. Escriba las instrucciones SQL para realizar lo siguiente:
--      2.1 Cree una tablespace denominado TS_Examen_SEP  8 MB de tamaño y que aumente de tamaño en incrementos de 2MB hasta un máximo de 32 MB.
        create tablespace TS_Examen_SEP datafile 'ts_examen_sep.dbf' size 8M autoextend on ;
--Se desea crear 2 tipos de usuarios PROFESOR y ALUMNO. Ambos tendrán 3 intentos para introducir la password antes de que se bloquee la cuenta y, además, la sesión de los ALUMNOS no podrá durar más de 120 minutos
--Cree un usuario de cada tipo (PROFE1 y ALUMNO1) y asigne a ambos usuarios por defecto el tablespace TS_Examen_SEP con QUOTA de 2 MB.
--Otórguele permisos para conectarse a ambos usuarios y, sólo al PROFESOR, para crear tablas, crear vistas, crear vistas materializadas, seleccionar y alterar el esquema de cualquier tabla del sistema.
--Cree una tabla denominada TABLA1 en el esquema PROFE1 con los campos CODIGO number clave primaria, USUARIO varchar2(20), DESCRIPCION varchar2 (50). Cree una tabla denominada TABLA2 en el mismo esquema con los campos CODIGO number, USUARIO varchar2(20). El campo usuario de la TABLA2 será único.
--Suponiendo que estamos conectamos con SYSTEM, escriba la instrucción para saber en que fichero se localizan los datos de la TABLA1.
--Se necesita crear un ROLE, denominado "ROLE_SEP" con los permisos necesarios para leer todos los atributos de la tabla TABLA2 así como insertar datos nuevos en ella. Escriba las instrucciones necesarias para crear el Role y concederle los permisos del Role al usuario ALUMNO1 y que, además, este usuario pueda otorgárselos a otro usuario.
--Queremos que ALUMNO1 pueda leer los atributos CODIGO y DESCRIPCION de la TABLA1 pero no USUARIO. Además, sólo podrá modificar el atributo DESCRIPCION de dicha tabla. Escriba las instrucciones necesarias.
--Cree un sinónimo público para la TABLA1.
--Se ha comprobado que el usuario EXAMEN2 realiza muchas búsquedas en la TABLA1 por el campo USUARIO. Además, existen pocos valores distintos que se repiten muchas veces. Cree índices adecuados para "agilizar" la consulta.