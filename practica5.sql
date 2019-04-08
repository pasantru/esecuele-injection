/* TODO ESTO COMO SYS AS DBA:
--Para crear una tabla externa, primero hay que dar de alta un directorio en Oracle. Para ello vamos a buscar un directorio donde el usuario de Oracle tenga acceso. Por ejemplo, podemos usar el directorio:
--C:\Users\alumnos\Oracle

-- 1 Creamos en ese directorio el fichero clientes.txt con el siguiente contenido:
        --001,Hutt,Jabba,89674385A,jabba,jabba@thecompany.com,Palacio de Jabba-Tatooine, 99235
        --002,Simpson,Homer,38294738B,homer,homer@thecompany.com,Springfiled,98765
        --003,Kent,Clark,08273619C,superman,superman@thecompany.com,Metropolis, 99999
        --004,Kid,Billy,92874362D,billythkid,billythkid@thecompany.com,Fort Sumner, 44444
        --005,Stranger,Perfect,38920983E,nobody,nobody@thecompany.com,Nooneknows,11111
        --006,Zoidberg,Dr,09451028F,crustacean,crustacean@thecompany.com,Planet Express,10101
--  2. Nos conectamos con el usuario sys as sysdba.

--  3. Ejecutamos:
create or replace directory directorio_ext as 'C:\Users\alumnos\Oracle';

-- 4. Darle permiso al usuario MERCORACLE para leer y escribir en el directorio:
grant read, write on directory directorio_ext to mercoracle;




grant create materialized view to mercoracle;

grant create synonym to mercoracle;

*/

-- A PARTIR DE AHORA COMO USUARIO MERCORACLE:

--  6. Crear la tabla:
create table cliente_externo
        ( cliente_id varchar2(3),
          apellido varchar2(50),
          nombre varchar2(50),
          dni varchar2(9),
          usuario varchar2(20),
         email varchar2(100),
         direccion varchar2(100),
         codigo_postal number(5)
        )
        organization external
       ( default directory directorio_ext
         access parameters
         ( records delimited by newline
           fields terminated by ','
         )
         location ('clientes.txt')  
     );
     
-- 7. Desde el usuario MERCORACLE probar a ejecutar sentencias SQL para leer, modificar, insertar... Por ejemplo: SELECT * FROM CLIENTE_EXTERNO
SELECT * FROM CLIENTE_EXTERNO;
Insert into cliente_externo (cliente_id,apellido,nombre,dni,usuario,email,direccion,codigo_postal) values ('007','Gómez','Antonio','11111111A','user','jijij@jiji.com','Calle agraeg','11111');

-- 8. Añadir los datos a la tabla CLIENTE. Utilice INSERT INTO CLIENTE SELECT dni, nombre, apellido, null, direccion, codigo_postal FROM CLIENTE_EXTERNO;
-- Si se produce algún error porque faltan datos obligatorios modifique el fichero CSV y la definición de tabla externa borrándola y creándola de nuevo.
-- No olvides confirmar la transacción.
INSERT INTO CLIENTE SELECT dni, nombre, apellido, null, direccion, codigo_postal FROM CLIENTE_EXTERNO;
select * from cliente;
commit;

-- 9. Asegúrese de que la tabla CLIENTE tiene clave primaria. Además, hay que crear índices sobre los atributos más comunes para realizar consultas.
-- Uno de los índices debe ser sobre una función. Compruebe ahora los índices con USER_INDEXES.
select constraint_name, constraint_type from user_constraints where table_name='CLIENTE';

CREATE INDEX Cliente_idx1 ON Cliente (dni, UPPER(domicilio), codigo_postal);
CREATE INDEX Cliente_idx2 ON Cliente (dni, nombre, apellido1);
select * from user_indexes where index_name like 'CLIENTE_%';

-- 10. ¿En qué tablespace reside la tabla CLIENTE? ¿Y los índices?
select table_name, tablespace_name from user_tables where table_name like 'CLIENTE';
select index_name, tablespace_name from user_indexes where index_name like 'CLIENTE_%';


/*
11. Crea una Vista materializada con los datos de cada factura de 2019. La vista se debe refrescar cada dia (refresco forzado). La consulta de la vista es:

 select  c.dni, c.nombre, c.apellido1, f.num_factura, t.fecha_pedido, sum(d.cantidad* p.precio_actual) total
     from cliente c join factura f on c.dni = f.CLIENTE join ticket t on f.ID=t.id join detalle d on d.ticket = t.id join producto p on d.producto =p.codigo_barras
     where extract (year from t.fecha_pedido)=2019
     group by c.dni, c.nombre, c.apellido1, f.num_factura, t.fecha_pedido;
*/
CREATE MATERIALIZED VIEW vista_materializada_cada_factura
REFRESH Force NEXT SYSDATE + 1 AS
     select  c.dni, c.nombre, c.apellido1, f.num_factura, t.fecha_pedido, sum(d.cantidad* p.precio_actual) total
     from cliente c join factura f on c.dni = f.CLIENTE join ticket t on f.ID=t.id join detalle d on d.ticket = t.id join producto p on d.producto =p.codigo_barras
     where extract (year from t.fecha_pedido)=2019
     group by c.dni, c.nombre, c.apellido1, f.num_factura, t.fecha_pedido;
     
select * from vista_materializada_cada_factura;


-- 12. Crear un sinónimo público denominado VM_FACTURAS para el objeto creado en el apartado anterior 
create synonym vm_facturas for vista_materializada_cada_factura;

select * from vm_facturas;



