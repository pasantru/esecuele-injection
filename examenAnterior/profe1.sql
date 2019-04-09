-- 3. Cree una tabla denominada TABLA1 en el esquema PROFE1 con los campos CODIGO number clave primaria, USUARIO varchar2(20), DESCRIPCION varchar2 (50).
    create table TABLA1 (codigo number, usuario varchar2(50), descripcion varchar2(50), primary key(codigo));
    
-- Cree una tabla denominada TABLA2 en el mismo esquema con los campos CODIGO number, USUARIO varchar2(20). El campo usuario de la TABLA2 será único.
    create table TABLA2 (codigo number, usuario varchar2(20), unique(usuario));
    
    
    -- 6. Queremos que ALUMNO1 pueda leer los atributos CODIGO y DESCRIPCION de la TABLA1 pero no USUARIO. Además, sólo podrá modificar el atributo DESCRIPCION de dicha tabla. Escriba las instrucciones necesarias.

    create view v_tabla1 as (
        select codigo, descripcion from tabla1
    );
    
    create view v2_tabla1 as (
        select descripcion from tabla1
    );
    
-- 7. Cree un sinónimo público para la TABLA1.
    create public synonym syn_tabla1 for tabla1;
    
-- 8. Se ha comprobado que el usuario EXAMEN2 realiza muchas búsquedas en la TABLA1 por el campo USUARIO. Además, existen pocos valores distintos que se repiten muchas veces. Cree índices adecuados para "agilizar" la consulta.
    create index tabla1_ind1 on tabla1 (codigo, usuario);
    create index tabla1_ind2 on tabla1 (usuario);