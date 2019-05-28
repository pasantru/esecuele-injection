/*
-- En system
create tablespace ts_pepito datafile 'pepito.dbf' size 20M autoextend on next 2M;

create user pepito identified by bd default tablespace ts_pepito quota unlimited on ts_pepito;

grant connect, resource to pepito;
*/

--En la sesi�n "A":
--Creamos la tabla cuenta
CREATE TABLE CUENTA (numero number primary key, saldo number);

--Insertamos un par de tuplas.
INSERT INTO CUENTA VALUES (11,1000);
INSERT INTO CUENTA VALUES (22,2000);
COMMIT;

-- En la sesi�n "A":
-- Comprobamos si podemos ver el nuevo valor de la tupla:
SELECT SALDO FROM CUENTA WHERE NUMERO = 11;
/*�Qu� valor aparecer�? 1000
�Qu� valor aparecer� si detr�s del UPDATE, en la sesi�n B, hacemos COMMIT? 9000
�Qu� efecto se ha producido en la transacci�n A?
 -> a) Doble Lectura
    b) Lectura Err�nea
    c) Lectura Fantasma     
*/


-- 2. En la sesi�n "A" ejecutamos lo siguiente:

UPDATE CUENTA SET saldo = 90 Where Numero = 11;
SELECT SALDO FROM CUENTA WHERE NUMERO = 11;
ROLLBACK;
SELECT SALDO FROM CUENTA WHERE NUMERO = 11;
--�Qu� valores obtendremos?
-- Primero 90 y luego 9000


/* 3. En la sesi�n "A" modificar el valor de una tupla:*/
update cuenta set numero = 12, saldo = 45 where numero =22;/*
Pasar a la sesi�n "B" y realizar otra modificaci�n de la misma fila.
�Qu� ocurre? Si es necesario, cancele la actualizaci�n de la sesi�n B.

Se queda bloqueada la sesi�n B,  a la espera del commit de A*/
rollback;
select * from cuenta;

/*4. En la sesi�n "A" modificar el valor de una tupla:*/
update cuenta set numero = 12, saldo = 45 where numero =22;/*
Pasar a la sesi�n "B" y realizar otra modificaci�n sobre una tupla distinta.
�Qu� ocurre? Si es necesario, cancele la actualizaci�n de la sesi�n B.

Se vuelve a bloquear. Se bloquea la tabla entera, hasta que la sesi�n A haga un commit*/

rollback;

/*5. En la sesi�n "A":
Bloquee la tabla en modo exclusivo:*/
lock table cuenta in exclusive mode;/*
�Podemos leer sus contenidos desde la sesi�n "B"?
S�.

�Podemos actualizar sus contenidos desde la sesi�n "B"?
No, se queda bloqueada la tarea.
*/



/*6. En la sesi�n "A":
Bloquee la tabla en modo Row Share:*/
lock table cuenta in row share mode;/*
�Podemos leer/actualizar sus contenidos desde la sesi�n "B"?
Leer s�, actualizar no.

�Se puede ejecutar alguna sentencia DDL sobre cuenta desde la sesion B?
S�
�Y desde A?
Tambi�n*/
ALTER TABLE cuenta ADD columna1 VARCHAR(20) NULL;



/*7. �C�mo se desbloquea la tabla desde la sesi�n A?
Cerrando la sesi�n.
*/

/*�Y desde B?
A menos de que no seamos administradores no podemos, ya que tendr�amos que matar la sesi�n de A*/


/*8. Bloquear la tabla en modo SHARE desde la sesi�n A. */
lock table cuenta in share mode;

/*Intentar modificar sus datos desde B.
No se puede.

�Se puede bloquear desde B tambi�n en modo SHARE?
S�.

Con estos dos bloqueos, �Qu� instrucciones de modificaci�n se pueden utilizar en ambas sesiones de forma cocurrente?
Lecturas, as� como otros bloqueos del mismo tipo S, o de tipo RS.
*/




/* 9. Cambiar el nivel de aislamiento en A a SERIALIZABLE.*/
alter session set isolation_level = serializable;
/*
Insertar una fila desde B y hacer commit. Volver a la sesi�n A y seleccionar todas las filas.*/
select * from cuenta;
/*
    �Se obtiene la nueva fila?
        No
    
    Si se obtuviese, �qu� efecto se est� dando?
        a) Doble Lectura
        b) Lectura Err�nea
     -> c) Lectura Fantasma
     
    Si no se obtuviese, �que hay que hacer en la sesi�n A para obtener la fila nueva?
        Volver al nivel de aislamiento por defecto:*/
        alter session set isolation_level = read committed;
        
        
/* 10. [S�lo se puede realizar si has hecho la pr�ctica en la mv]. 
Realiza una copia de seguridad con la utilidad externa Data Pump Export (expdp) de todo el esquema del usuario "pepito", incluyendo los datos existentes.
NOTA: El usuario no debe tener privilegios para un export total de la base de datos. 
Recuerda que deber�s crear un objeto directorio de ORACLE antes de poder realizar la exportaci�n y que el usuario deber� tener permisos de lectura y escritura sobre el mismo.

/*
-- como system
CREATE DIRECTORY  exp_pepito  AS  'C:\Users\alumnos\Oracle\PracticaConcurrenciaPepito';
GRANT read, write ON DIRECTORY  exp_pepito  TO  pepito;
GRANT DATAPUMP_EXP_FULL_DATABASE TO pepito;

-- Ejecutar esto en el cmd:
-- expdp pepito/pepito@ORCL  DIRECTORY = exp_pepito  DUMPFILE =exp_schm_pepito.dmp  LOGFILE=pepito_lg.log SCHEMAS = pepito
*/
