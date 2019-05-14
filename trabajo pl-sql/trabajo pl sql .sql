set serveroutput on;

/*
1.Cada empleado utilizará un usuario de Oracle distinto para conectarse a la base de datos. Modificar el modelo (si es necesario) para almacenar dicho usuario . Además habrá que crear un role para las categorías de empleado: Director, Supervisor y Cajero-Reponedor. Los roles se llamarán R_DIRECTOR, R_SUPERVISOR, R_CAJERO. 
*/
create role R_DIRECTOR;
create role R_SUPERVISOR;
create role R_CAJERO;

/*
2.
*/
CREATE TABLE "REVISION" 
   (	"FECHA" DATE, 
	"CODIGO_BARRAS" NUMBER, 
	"PASILLO" NUMBER
   ) ;

CREATE OR REPLACE PROCEDURE "P_REVISA" as
begin
   insert into revision 
   select sysdate, codigo_barras, pa.id from producto p join pasillo pa on(p.pasillo = pa.id)  
   where (temperatura <0 and upper (pa.descripcion) != 'CONGELADOS') OR 
   (temperatura between 0 and 6 and upper(pa.descripcion) != 'REFRIGERADOS');
end;
/

create view V_REVISION_HOY as (
    select * from revision where FECHA = sysdate 
);

grant select on MERCORACLE.V_REVISION_HOY to r_cajero;

grant execute on MERCORACLE.p_revisa to r_supervisor;

/*
3. NO ESTÁ TERMINADA
*/
CREATE OR REPLACE VIEW V_IVA_TRIMESTRE AS
SELECT TO_NUMBER(TO_CHAR(T.FECHA_PEDIDO, 'YYYY')) "AÑO" ,TRUNC(TO_NUMBER (TO_CHAR (T.FECHA_PEDIDO, 'MM') - 1) / 3) + 1 "TRIMESTRE",
SUM(I.PORCENTAJE) "IVA_TOTAL" FROM IVA I JOIN 
CATEGORIA C ON (I.TIPO_IVA = C.IVA) JOIN 
PRODUCTO P ON (P.CATEGORIA = C.ID) JOIN
DETALLE D ON (D.PRODUCTO = P.CODIGO_BARRAS) JOIN
TICKET T ON (T.ID = D.TICKET)
GROUP BY TO_NUMBER(TO_CHAR(T.FECHA_PEDIDO, 'YYYY')) ,TRUNC(TO_NUMBER (TO_CHAR (T.FECHA_PEDIDO, 'MM') - 1) / 3) + 1
ORDER BY "AÑO", "TRIMESTRE";

grant select on  V_IVA_TRIMESTRE to R_Supervisor, R_Director;

/*
4. MIRAR LA DE FLUCTUACION QUE NO ESTA BIEN
*/
-- cabecera
create or replace package PK_ANALISIS as
    type t_valores_producto is record(
        maximo number,
        minimo number,
        media number
    );
    type t_valores_fluctuacion is record(
        producto number,
        maximo number,
        minimo number
    );

    function F_Calcular_Estadisticas(p_producto number, desde date, hasta date) return t_valores_producto;
        
    function F_Calcular_Fluctuacion(p_producto number, desde date, hasta date) return t_valores_fluctuacion;
    procedure p_reasignar_metros(desde date);

end pk_analisis;
/

-- cuerpo
CREATE OR REPLACE PACKAGE BODY PK_ANALISIS AS

  function F_Calcular_Estadisticas(p_producto number, desde date, hasta date) return t_valores_producto
   is
            error_en_fechas exception;
            resultado t_valores_producto;
        begin
            if desde>hasta then
                raise error_en_fechas;
            else
                select max(precio),min(precio),avg(precio) into resultado from historico_precio where p_producto=producto and fecha between desde and hasta;
                return resultado;
            end if;
            
        end F_Calcular_Estadisticas;

  function F_Calcular_Fluctuacion(p_producto number, desde date, hasta date) return t_valores_fluctuacion
    is
        error_en_fechas exception;
        fila t_valores_fluctuacion;
        resultado t_valores_fluctuacion;
        fluctuacion number;
        mayor_fluc number;
        
        cursor c_prod is (
--            select p.codigo_barras, (max(h.precio)-min(h.precio))/min(h.precio) "fluctuacion"
--            from producto p join historico_precio h on (p.codigo_barras=h.producto)
--            where h.fecha between  desde and hasta
--            group by producto
            
            select p.codigo_barras, max(h.precio), min(precio)
            from producto p join historico_precio h on (p.codigo_barras=h.producto)
            where h.fecha between  desde and hasta
            group by producto
        );
        
      BEGIN
        -- TAREA: Se necesita implantación para function PK_ANALISIS.F_Calcular_Fluctuacion
        if desde>hasta then
            raise error_en_fechas;
        else 
            open c_prod;
            fetch c_prod into fila;
            fluctuacion := abs(fila.maximo - fila.minimo);
            mayor_fluc := fluctuacion;
            fetch c_prod into fila;
            while c_prod%found loop
                fluctuacion := abs(fila.maximo - fila.minimo)/fila.minimo;
                if fluctuacion > mayor_fluc then
                    mayor_fluc := fluctuacion;
                    resultado := fila;
                end if;
                fetch c_prod into fila;
            end loop;
            close c_prod;
            return resultado;
        end if;
    end F_Calcular_Fluctuacion;
    
    
--        (
            
--        )


  procedure p_reasignar_metros(desde date) AS
  BEGIN
    -- TAREA: Se necesita implantación para procedure PK_ANALISIS.p_reasignar_metros
    NULL;
  END p_reasignar_metros;

END PK_ANALISIS;
/

/* 4.4
(Nuevo) Crear un TRIGGER que cada vez que se modifique el precio de un producto almacene el precio anterior en HISTORICO_PRECIO, 
poniendo la fecha a sysdate -1 (se supone que el atributo PRECIO de HISTORICO_PRECIO indica la fecha hasta la que es válido el precio
del producto).
*/
create or replace TRIGGER HISTORICO_PRECIO_TRIGGER 
after UPDATE OF PRECIO_ACTUAL ON PRODUCTO 
for each row
BEGIN
    INSERT INTO HISTORICO_PRECIO(PRODUCTO,FECHA,PRECIO) VALUES (:new.codigo_barras, SYSDATE-1,:old.precio_actual); 
END;
/

/*
5
*/

-- cabecera
CREATE OR REPLACE 
PACKAGE PK_PUNTOS AS 
   -- TOTAL NUMBER;
    procedure P_Calcular_Puntos(id_ticket number, cliente varchar2);
    procedure P_Aplicar_Puntos(id_ticket number, cliente varchar2);
    
END PK_PUNTOS;
/

-- cuerpo
CREATE OR REPLACE
PACKAGE BODY PK_PUNTOS AS

  procedure P_Calcular_Puntos(id_ticket number, cliente varchar2) AS
  V_TOTAL NUMBER;
    BEGIN
        SELECT SUM(P.PRECIO_ACTUAL * D.CANTIDAD) INTO V_TOTAL FROM TICKET T 
        JOIN DETALLE D ON D.TICKET = T.ID
        JOIN PRODUCTO P ON P.CODIGO_BARRAS = D.PRODUCTO
        WHERE T.ID = ID_TICKET;
        UPDATE TICKET SET PUNTOS = V_TOTAL WHERE ID = ID_TICKET; -- en puntos ponía total
        IF CLIENTE IS NOT NULL THEN
            UPDATE TICKET SET FIDELIZADO = CLIENTE, PUNTOS = TRUNC (V_TOTAL / 10) WHERE ID = ID_TICKET;
            UPDATE FIDELIZADO SET PUNTOS_ACUMULADOS = PUNTOS_ACUMULADOS + TRUNC(V_TOTAL / 10) WHERE DNI = CLIENTE;
        END IF;
  END P_Calcular_Puntos;

  procedure P_Aplicar_Puntos(id_ticket number, cliente varchar2) AS
  /*  v_total number;
    v_puntos_cliente number;
    v_nuevos_puntos number;
    v_nuevo_total number;*/
  BEGIN/*
    -- TAREA: Se necesita implantación para procedure PK_PUNTOS.P_Aplicar_Puntos
    select puntos_acumulados into v_puntos_cliente from fidelizado where dni=cliente;
    select total into v_total from ticket where id_ticket=id;
    if v_puntos_cliente / 100 <= v_total then
        v_nuevos_puntos := 0;
        v_nuevos_total := v_total - trunc(v_puntos_cliente /100);
    else
        v_nuevo_total := 0;
        v_nuevos_puntos := v_puntos_cliente - (v_total*100);
    */
    NULL;
  END P_Aplicar_Puntos;

END PK_PUNTOS;
/

/*
6
*/

create package pk_empleados as
procedure p_alta_(p_id number, p_dni varchar2, p_nombre varchar2, p_apellido varchar2, p_usuario varchar2, clave varchar2) as
sentencia varchar2(500);
begin
    insert into empleado values(p_id, p_dni, p_nombre, p_apellido, p_usuario, clave);
    sentencia:= 'create user '||p_usuario||' identify by '|| clave;
    dbms_output.putline(sentencia);
    execute immediate sentencia;
    sentencia:='grant
