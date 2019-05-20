set serveroutput on;

/*
1.Cada empleado utilizara un usuario de Oracle distinto para conectarse a la base de datos.
Modificar el modelo (si es necesario) para almacenar dicho usuario .
Ademas habra que crear un role para las categorias de empleado:
Director, Supervisor y Cajero-Reponedor.
Los roles se llamaran R_DIRECTOR, R_SUPERVISOR, R_CAJERO.
*/
create role R_DIRECTOR;
create role R_SUPERVISOR;
create role R_CAJERO;

/*
2.Crear una tabla denominada REVISION con la fecha, código de barras del producto e id
 del pasillo. Necesitamos un procedimiento P_REVISA que cuando se ejecute compruebe si
  los productos con menor temperatura de conservación se encuentren en su
  localización determinada. De esta forma, insertará en REVISION aquellos
  productos para los que se conoce su atributo temperatura y NO cumplen que:

    1.Teniendo una temperatura menor de 0ºC no se encuentran en Congelados.
    2.Teniendo una temperatura entre 0ºC y 6ºC no se encuentran en Refrigerados.
    3.Crear vista denominada V_REVISION_HOY con los datos de REVISION correspondientes al día de hoy. Otorgar permiso a R_CAJERO para seleccionar de dicha vista.
    4.Dar permiso de ejecución sobre el procedimiento P_REVISA a R_SUPERVISOR

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
3.Necesitamos una vista denominada V_IVA_TRIMESTRE con los atributos AÑO, TRIMESTRE,
 IVA_TOTAL siendo trimestre un número de 1 a 4. El IVA_TOTAL es el IVA devengado
 (suma del IVA de los productos vendidos en ese trimestre). Dar permiso de selección
 a los supervisores y directores. Por simplicidad se utilizará el PRECIO_ACTUAL
  del PRODUCTO, no el HISTORICO_PRECIO

NO ESTA TERMINADA
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
4.Crear un paquete en PL/SQL de análisis de datos.
  1.La función F_Calcular_Estadisticas devolverá la media, mínimo y máximo precio
  de un producto determinado entre dos fechas.
  2.La función F_Calcular_Fluctuacion devolverá el mínimo y el máximo del producto que
  haya tenido mayor fluctuación porcentualmente en su precio de todos entre dos fechas.
  3.El procedimiento P_Reasignar_metros encuentra el producto más y menos vendido
  (en unidades) desde una fecha hasta hoy. Extrae 0.5 metros lineales del de menor
  ventas y se lo asigna al de mayor ventas si es posible. Si hay varios productos
  que se han vendido el mismo número de veces se obtendrá el de menor ventas y menos
  precio y se le asigna al de mayor ventas y mayor precio. La siguiente consulta
  muestra las ventas por producto y precio: select p.codigo_barras, p.precio_actual,
  nvl(sum(d.cantidad),0)
  from producto p left outer join detalle d on p.codigo_barras =d.producto left outer
  join ticket t on d.ticket = t.id
  4.(Nuevo) Crear un TRIGGER que cada vez que se modifique el precio de un producto
  almacene el precio anterior en HISTORICO_PRECIO, poniendo la fecha a sysdate -1
  (se supone que el atributo PRECIO de HISTORICO_PRECIO indica la fecha hasta la
  que es válido el precio del producto).

MIRAR 2 LA DE FLUCTUACION QUE NO ESTA BIEN
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
/*4.2.La función F_Calcular_Fluctuacion devolverá el mínimo y el máximo del producto
que haya tenido mayor fluctuación porcentualmente en su precio de todos entre
dos fechas.
*/
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
        -- TAREA: Se necesita implantaci�n para function PK_ANALISIS.F_Calcular_Fluctuacion
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
    -- TAREA: Se necesita implantacion para procedure PK_ANALISIS.p_reasignar_metros
    NULL;
  END p_reasignar_metros;

END PK_ANALISIS;
/

/* 4.4
(Nuevo) Crear un TRIGGER que cada vez que se modifique el precio de un producto almacene el precio anterior en HISTORICO_PRECIO,
poniendo la fecha a sysdate -1 (se supone que el atributo PRECIO de HISTORICO_PRECIO indica la fecha hasta la que es v�lido el precio
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
5.Modificar la tabla Ticket con el campo Total de tipo number. Crear un paquete en
PL/SQL de gestión de puntos de clientes fidelizados.
  1.El procedimiento P_Calcular_Puntos, tomará el ID de un ticket y un número de cliente
 fidelizado y calculará los puntos correspondientes a la compra (un punto por cada
 euro, pero usando la función TRUNC en el redondeo). El procedimiento siempre
 calculará el precio total de toda la compra y lo almacenará en el campo Total.
 También calcula y almacena el campo PUNTOS de ticket. Además, si el cliente existe
 (puede ser nulo o no estar en la tabla), actualizará el atributo Puntos_acumulados
 del cliente fidelizado.

2.El procedimiento P_Aplicar_puntos tomará el ID de un ticket y un número de
cliente fidelizado. Cada punto_acumulado es un céntimo de descuento. Calcular el
descuento teniendo en cuenta que no puede ser mayor que el precio total y actualizar
 el precio total y los puntos acumulados. Por ejemplo, si el precio total es 40 y
 tiene 90 puntos, el nuevo precio es  40-0,9=39,1 y los puntos pasan a ser cero.
 Si el precio es 10 y tiene 1500 puntos, el nuevo precio es 0 y le quedan 500 puntos.

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
        UPDATE TICKET SET PUNTOS = V_TOTAL WHERE ID = ID_TICKET; -- en puntos pon�a total
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
    -- TAREA: Se necesita implantaci�n para procedure PK_PUNTOS.P_Aplicar_Puntos
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
6.Crear un paquete en PL/SQL de gestión de empleados que incluya las operaciones para
crear, borrar y modificar los datos de un empleado. Hay que tener en cuenta que
algunos empleados tienen un usuario y, por tanto, al insertar o modificar un empleado,
si su usuario no es nulo, habrá que crear su usuario con el role que corresponda según
su categoría de empleado. Además, el paquete ofrecerá procedimientos para
bloquear/desbloquear cuentas de usuarios de modo individual.
También se debe disponer de una opción para bloquear y desbloquear todas las cuentas
de los empleados salvo las de tipo Director.

1.Habrá un procedimiento P_EmpleadoDelAño que aumentará el sueldo bruto en un 10%)
al empleado más eficiente en caja (que ha emitido un mayor número de tickets).
*/
CREATE PACKAGE PK_EMPLEADOS AS
    PROCEDURE P_ALTA (P_ID NUMBER, P_DNI VARCHAR2, P_NOMBRE VARCHAR2, P_APELLIDO1 VARCHAR2,
      P_APELLIDO2 VARCHAR2, P_DOMICILIO VARCHAR2, P_CODIGO_POSTAL NUMBER, P_TELEFONO VARCHAR2,
      P_EMAIL VARCHAR2, P_CAT_EMPLEADO NUMBER, P_FECHA_ALTA DATE,
      P_USUARIO VARCHAR2, CLAVE VARCHAR2) AS
    SENTENCIA VARCHAR2(500);
    BEGIN
    INSERT INTO EMPLEADO VALUES (P_ID, P_DNI, P_NOMBRE, P_APELLIDO1, P_APELLIDO2, P_DOMICILIO,
      P_CODIGO_POSTAL, P_TELEFONO, P_EMAIL, P_CAT_EMPLEADO, P_FECHA_ALTA, P_USUARIO);
    SENTENCIA := 'CREATE USER ' ||P_USUARIO || ' IDENTIFIED BY ' || CLAVE;
    DBMS_OUTPUT.PUT_LINE ('SENTENCIA');
    EXECUTE IMMEDIATE SENTENCIA;
    SENTENCIA := 'GRANT CONNECT, R_' || P_USUARIO || ' IDENTIFIED BY ' || CLAVE;
