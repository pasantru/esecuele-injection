-- Cree las siguientes tablas

create table usuarios (Id Number primary key,

Nombre VARCHAR2(50) not null,

Apellidos VARCHAR2(50) not null,

Usuario_Oracle VARCHAR2(12));


create table preguntas (Id Number primary key,

enunciado  VARCHAR2(100) not null);


create table respuestas (Id Number primary key,

id_pregunta number references preguntas (id),

id_usuario references usuarios (id),

respuesta  VARCHAR2(100) , constraint uk_pregunta_usuario unique (id_pregunta, id_usuario));


-- Cree la siguiente Vista:

CREATE OR REPLACE VIEW V_RESPUESTAS(id_pregunta,enunciado,respuesta) AS 

SELECT p.Id, p.Enunciado, null respuesta

from preguntas p where p.id not in 

(select r.id_pregunta from respuestas r join usuarios u on u.id = r.id_usuario

where user  = u.usuario_oracle) --preguntas no contestadas por el user

union 

(SELECT p.Id, p.Enunciado, r.respuesta 

from preguntas p  join respuestas r on r.id_pregunta = p.id 

 join usuarios u on u.id = r.id_usuario where user = u.usuario_oracle); --si contestadas
 
 
 
 
 
/*
Realice los siguientes pasos (1 punto):

    Cree una secuencia SEC_RESPUESTAS que comience en 1 y avance de 1 en 1*/
create sequence seq_respuestas start with 1 increment by 1;
/*
    Cree un trigger TR_RESPUESTAS que cada vez que se modifique V_RESPUESTAS compruebe si el usuario ya ha contestado a la pregunta. Si no la hecho, debe insertar una fila en la tabla RESPUESTAS utilizando como id_respuestas el siguiente valor de SEC_RESPUESTAS. Si ya lo había hecho, debe modificar la respuesta.*/
create or replace trigger tr_respuestas instead of
update on v_respuestas
for each row
declare
    v_respuesta varchar2(100);
    v_id_usuario number;
    v_numero number;
begin
    select id into v_id_usuario from usuarios where usuario_oracle= user;
    
    select count(*) into v_numero from respuestas r where id_pregunta = :old.id_pregunta and id_usuario =v_id_usuario;
   
        
  /*  select respuesta into v_respuesta
    from respuestas r join usuarios u on (r.id_usuario = u.dni)
    where id_pregunta = :old.id_pregunta and u.usuario_oracle = user;*/

    if v_numero =0 then
        insert into respuestas values (seq_respuestas.nextval, :old.id_pregunta, :new.respuesta);
    else
        update respuestas
        set respuesta = :new.respuesta
        where id_pregunta = :old.id_pregunta and id_usuario = v_id_usuario;
    end if;
end;
/
--Un ejemplo de actualización de la vista sería, 
/*
update v_respuestas set respuesta ='Mi respuesta' where id_pregunta =1;

y el trigger tendría que insertar la fila nueva en RESPUESTAS (si no existe) o modificar la fila correspondiente.

Si el usuario que está intentando hacer la modificación no existe en la tabla usuarios, se debe elevar una excepción.

Crea una tabla llamada ERRORES con los atributos usuario VARCHAR2(50) y descripcion VARCHAR2(100)*/
create table errores (usuario varchar2(50)--

/*Cree el siguiente procedimiento (1 Punto):
    PR_CREA_VISTAS_RESPUESTAS que crea una vista a cada usuario con el formato V_USUARIO_RESPUESTA */
create procedure pr_crea_vistas_respuestas as
    cursor c_usu is select usuario_oracle from usuarios; 
    sentencia varchar2(2000); -- 4000 es el maximo
begin
    for fila in c_usu loop
        sentencia := 'CREATE VIEW V_'||FILA.USUARIO_ORACLE||'_RESPUESTA AS SELECT P.ID..., FROM PREGUNTAS P LEFT OUTER JOIN RESPUESTAS R' -- FALTAN COSAS!!!
        DBMS_OUTPUT.PUT_LINE(SENTENCIA);
        BEGIN
            EXECUTE IMMEDIATE SENTENCIA;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM,1,100));
            INSERT INTO ERRORES VALUES(FILA.USUARIO_ORALE.SBSTR(SQLERRM,1,100));
        END;
    END LOOP;
END;
/
-- HA
/*
El procedimiento recorre la tabla usuarios y crea una vista para cada uno con la sentencia: SELECT p.Id, p.Enunciado, r.Respuesta from preguntas p left outer join respuestas r on r.id_pregunta = p.id where r.id_usuario = ID_USUARIO

Es decir, si en la tabla hay 2 filas con los usuarios ESC, con id 1 y  PEPE, con id 2, crearía 2 vistas:

V_ESC_RESPUESTA AS  SELECT p.Id, p.Enunciado, r.Respuesta from preguntas p left outer join respuestas r on r.id_pregunta = p.id where r.id_usuario = 1.

y 

V_PEPE_RESPUESTA AS SELECT p.Id, p.Enunciado, r.Respuesta from preguntas p left outer join respuestas r on r.id_pregunta = p.id where r.id_usuario = 2.


Si la vista no se puede crear, se inserta en errores el usuario de la fila correspondiente, y el mensaje de Oracle (SQLERRM), pero se sigue procesando el cursor.
*/


/*SOLUCION DEL CAMPUS

TRIGGER:

create or replace trigger tr_respuestas

instead of update on v_respuestas 

for each row

declare

  num_respuesta number;

  id_u number;

begin

  select id into id_u from usuarios where usuario_oracle =user; -- ID del usuario de la tabla usuarios. Si no existe se captura la excepción

  begin

      select id into num_respuesta from respuestas where 

      id_usuario = (id_u) and id_pregunta = :old.id_pregunta;  -- ID de la respuesta

      update respuestas set respuesta =:new.respuesta  where id =num_respuesta;

    exception when no_data_found then

      insert into respuestas values (sec_respuestas.nextval, :old.id_pregunta, 

        (id_u),:new.respuesta);

  end;

  exception when no_data_found then

     raise_application_error (-20001,'USUARIO no encontrado');

end;


PROCEDURE:

create or replace procedure pr_respuestas is

cursor c_usuarios is select * from usuarios;

sentencia varchar2(200);

err_msg varchar2(100);

err_code number;

begin

for un_usuario in c_usuarios loop

  sentencia := 'CREATE OR REPLACE VIEW V_'||un_usuario.usuario_oracle||

  '_RESPUESTAS AS SELECT p.Id, p.Enunciado, r.Respuesta from preguntas p left outer join respuestas r on r.id_pregunta = p.id where r.id_usuario = '||un_usuario.id;

  dbms_output.put_line (sentencia);

  begin

    execute immediate sentencia;

  exception when others then

      err_code := SQLCODE;

      err_msg := SUBSTR(SQLERRM, 1, 100);

     insert into errores values (un_usuario.usuario_oracle,err_msg);

  end;

end loop;

end;

*/