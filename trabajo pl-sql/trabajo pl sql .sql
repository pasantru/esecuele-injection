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
CREATE OR REPLACE TRIGGER Control_Empleados
AFTER INSERT OR DELETE OR UPDATE ON Empleados
BEGIN
    IF INSERTING THEN
        INSERT INTO Ctrl_Empleados ( Tabla,Usuario,Fecha,Oper )
            VALUES (' Empleados ', USER, SYSDATE,'INSERT'); 
    ELSIF DELETING THEN
        INSERT INTO Ctrl_Empleados ( Tabla,Usuario,Fecha,Oper )
            VALUES (' Empleados ', USER, SYSDATE,'DELETE'); 
    ELSE
        INSERT INTO Ctrl_Empleados ( Tabla,Usuario,Fecha,Oper )
            VALUES (' Empleados ', USER, SYSDATE,'UPDATE '); 
    END IF;

END Control_Empleados ;
/
