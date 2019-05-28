/*
-- En system
create tablespace ts_pepito datafile 'pepito.dbf' size 20M autoextend on next 2M;

create user pepito identified by bd default tablespace ts_pepito quota unlimited on ts_pepito;

grant connect, resource to pepito;
*/

--En la sesión "A":
--Creamos la tabla cuenta
CREATE TABLE CUENTA (numero number primary key, saldo number);

--Insertamos un par de tuplas.
INSERT INTO CUENTA VALUES (11,1000);
INSERT INTO CUENTA VALUES (22,2000);
COMMIT;

-- En la sesión "A":
-- Comprobamos si podemos ver el nuevo valor de la tupla:
SELECT SALDO FROM CUENTA WHERE NUMERO = 11;
/*¿Qué valor aparecerá? 1000
¿Qué valor aparecerá si detrás del UPDATE, en la sesión B, hacemos COMMIT? 9000
¿Qué efecto se ha producido en la transacción A?
 -> a) Doble Lectura
    b) Lectura Errónea
    c) Lectura Fantasma     
*/


-- 2. En la sesión "A" ejecutamos lo siguiente:

UPDATE CUENTA SET saldo = 90 Where Numero = 11;
SELECT SALDO FROM CUENTA WHERE NUMERO = 11;
ROLLBACK;
SELECT SALDO FROM CUENTA WHERE NUMERO = 11;
--¿Qué valores obtendremos?
-- Primero 90 y luego 9000


/* 3. En la sesión "A" modificar el valor de una tupla:*/
update cuenta set numero = 12, saldo = 45 where numero =22;/*
Pasar a la sesión "B" y realizar otra modificación de la misma fila.
¿Qué ocurre? Si es necesario, cancele la actualización de la sesión B.

Se queda bloqueada la sesión B,  a la espera del commit de A*/
rollback;
select * from cuenta;

/*4. En la sesión "A" modificar el valor de una tupla:*/
update cuenta set numero = 12, saldo = 45 where numero =22;/*
Pasar a la sesión "B" y realizar otra modificación sobre una tupla distinta.
¿Qué ocurre? Si es necesario, cancele la actualización de la sesión B.

Se vuelve a bloquear. Se bloquea la tabla entera, hasta que la sesión A haga un commit*/

rollback;

/*5. En la sesión "A":
Bloquee la tabla en modo exclusivo:*/
lock table cuenta in exclusive mode;/*
¿Podemos leer sus contenidos desde la sesión "B"?
Sí.

¿Podemos actualizar sus contenidos desde la sesión "B"?
No, se queda bloqueada la tarea.
*/



/*6. En la sesión "A":
Bloquee la tabla en modo Row Share:*/
lock table cuenta in row share mode;/*
¿Podemos leer/actualizar sus contenidos desde la sesión "B"?
Leer sí, actualizar no.

¿Se puede ejecutar alguna sentencia DDL sobre cuenta desde la sesion B?
Sí
¿Y desde A?
También*/
ALTER TABLE cuenta ADD columna1 VARCHAR(20) NULL;



/*7. ¿Cómo se desbloquea la tabla desde la sesión A?
Cerrando la sesión.
*/

/*¿Y desde B?
A menos de que no seamos administradores no podemos, ya que tendríamos que matar la sesión de A*/


/*8. Bloquear la tabla en modo SHARE desde la sesión A. */
lock table cuenta in share mode;

/*Intentar modificar sus datos desde B.
No se puede.

¿Se puede bloquear desde B también en modo SHARE?
Sí.

Con estos dos bloqueos, ¿Qué instrucciones de modificación se pueden utilizar en ambas sesiones de forma cocurrente?
Lecturas, así como otros bloqueos del mismo tipo S, o de tipo RS.
*/




/* 9. Cambiar el nivel de aislamiento en A a SERIALIZABLE.*/
alter session set isolation_level = serializable;
/*
Insertar una fila desde B y hacer commit. Volver a la sesión A y seleccionar todas las filas.*/
select * from cuenta;
/*
    ¿Se obtiene la nueva fila?
        No
    
    Si se obtuviese, ¿qué efecto se está dando?
        a) Doble Lectura
        b) Lectura Errónea
     -> c) Lectura Fantasma
     
    Si no se obtuviese, ¿que hay que hacer en la sesión A para obtener la fila nueva?
        Volver al nivel de aislamiento por defecto:*/
        alter session set isolation_level = read committed;
        
        
/* 10. [Sólo se puede realizar si has hecho la práctica en la mv]. 
Realiza una copia de seguridad con la utilidad externa Data Pump Export (expdp) de todo el esquema del usuario "pepito", incluyendo los datos existentes.
NOTA: El usuario no debe tener privilegios para un export total de la base de datos. 
Recuerda que deberás crear un objeto directorio de ORACLE antes de poder realizar la exportación y que el usuario deberá tener permisos de lectura y escritura sobre el mismo.

/*
-- como system
CREATE DIRECTORY  exp_pepito  AS  'C:\Users\alumnos\Oracle\PracticaConcurrenciaPepito';
GRANT read, write ON DIRECTORY  exp_pepito  TO  pepito;
GRANT DATAPUMP_EXP_FULL_DATABASE TO pepito;

-- Ejecutar esto en el cmd:
-- expdp pepito/pepito@ORCL  DIRECTORY = exp_pepito  DUMPFILE =exp_schm_pepito.dmp  LOGFILE=pepito_lg.log SCHEMAS = pepito
*/
