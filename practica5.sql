

-- como usuario mercoracle

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
     
SELECT * FROM CLIENTE_EXTERNO;
Insert into cliente_externo (cliente_id,apellido,nombre,dni,usuario,email,direccion,codigo_postal) values ('007','Gómez','Antonio','11111111A','user','jijij@jiji.com','Calle agraeg','11111');

INSERT INTO CLIENTE SELECT dni, nombre, apellido, null, direccion, codigo_postal FROM CLIENTE_EXTERNO;
select * from cliente;
commit;

select constraint_name, constraint_type from user_constraints where table_name='CLIENTE';

CREATE INDEX Cliente_idx1 ON Cliente (dni, UPPER(domicilio), codigo_postal);
CREATE INDEX Cliente_idx2 ON Cliente (dni, nombre, apellido1);
select * from user_indexes where index_name like 'CLIENTE_%';


select table_name, tablespace_name from user_tables where table_name like 'CLIENTE';
select index_name, tablespace_name from user_indexes where index_name like 'CLIENTE_%';


CREATE MATERIALIZED VIEW vista_materializada_cada_factura
REFRESH Force NEXT SYSDATE + 1 AS
     select  c.dni, c.nombre, c.apellido1, f.num_factura, t.fecha_pedido, sum(d.cantidad* p.precio_actual) total
     from cliente c join factura f on c.dni = f.CLIENTE join ticket t on f.ID=t.id join detalle d on d.ticket = t.id join producto p on d.producto =p.codigo_barras
     where extract (year from t.fecha_pedido)=2019
     group by c.dni, c.nombre, c.apellido1, f.num_factura, t.fecha_pedido;



