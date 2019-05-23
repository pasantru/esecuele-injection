create or replace TRIGGER Auto_Incrementar_ID_Empleado_TRIGGER
after insert ON empleado
FOR EACH ROW
BEGIN
    
    update empleado
    set id = (select max(id)+1 from empleado)
    where id = :old.id;
    
END;
/