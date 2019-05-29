-- P_ALTA
    DECLARE
      P_ID NUMBER;
      P_DNI VARCHAR2(200);
      P_NOMBRE VARCHAR2(200);
      P_APELLIDO1 VARCHAR2(200);
      P_APELLIDO2 VARCHAR2(200);
      P_DOMICILIO VARCHAR2(200);
      P_CODIGO_POSTAL NUMBER;
      P_TELEFONO VARCHAR2(200);
      P_EMAIL VARCHAR2(200);
      P_CAT_EMPLEADO NUMBER;
      P_FECHA_ALTA DATE;
      P_USUARIO VARCHAR2(200);
      CLAVE VARCHAR2(200);
    BEGIN
      P_ID := null;
      P_DNI := '1548796Y';
      P_NOMBRE := 'Fulanito';
      P_APELLIDO1 := 'apellido1';
      P_APELLIDO2 := NULL;
      P_DOMICILIO := 'aijgiaorjgio';
      P_CODIGO_POSTAL := '29011';
      P_TELEFONO := '952555555';
      P_EMAIL := 'jgijaiog@gqr.com';
      P_CAT_EMPLEADO := 2;
      P_FECHA_ALTA := sysdate;
      P_USUARIO :='user2345';
      CLAVE := 'bd';
    
      PK_EMPLEADOS.P_ALTA(
        P_ID => P_ID,
        P_DNI => P_DNI,
        P_NOMBRE => P_NOMBRE,
        P_APELLIDO1 => P_APELLIDO1,
        P_APELLIDO2 => P_APELLIDO2,
        P_DOMICILIO => P_DOMICILIO,
        P_CODIGO_POSTAL => P_CODIGO_POSTAL,
        P_TELEFONO => P_TELEFONO,
        P_EMAIL => P_EMAIL,
        P_CAT_EMPLEADO => P_CAT_EMPLEADO,
        P_FECHA_ALTA => P_FECHA_ALTA,
        P_USUARIO => P_USUARIO,
        CLAVE => CLAVE
      );
    --rollback; 
    END;
    /

-- P_Baja
    DECLARE
      P_DNI VARCHAR2(200);
    BEGIN
      P_DNI := '1548796X';
    
      PK_EMPLEADOS.P_BAJA(
        P_DNI => P_DNI
      );
    --rollback; 
    END;
    /

-- 

-- bloquear cuenta
    DECLARE
      P_USUARIO VARCHAR2(200);
    BEGIN
      P_USUARIO := 'user1234';
    
      PK_EMPLEADOS.P_BLOQ_CUENTA(
        P_USUARIO => P_USUARIO
      );
    --rollback; 
    END;
    /

-- desbloquear cuenta
    DECLARE
      P_USUARIO VARCHAR2(200);
    BEGIN
      P_USUARIO := 'user1234';
    
      PK_EMPLEADOS.P_DESBLOQ_CUENTA(
        P_USUARIO => P_USUARIO
      );
    --rollback; 
    END;
    /

--Bloquea todas
    BEGIN
      PK_EMPLEADOS.P_BLOQ_TODAS();
    --rollback; 
    END;
    /

-- Desbloquea todas
    BEGIN
      PK_EMPLEADOS.P_DESBLOQ_TODAS();
    --rollback; 
    END;
    /
    
-- BORRA USUARIO       
    DECLARE
      P_USUARIO VARCHAR2(200);
    BEGIN
      P_USUARIO := 'user2345';
    
      PK_EMPLEADOS.P_BORRAR_USUARIO(
        P_USUARIO => P_USUARIO
      );

    --rollback; 
    END;
    / 
    
-- crear usuario
    DECLARE
      P_USUARIO VARCHAR2(200);
      P_CLAVE VARCHAR2(200);
      P_CAT NUMBER;
    BEGIN
      P_USUARIO := 'pepillo4';
      P_CLAVE := 'bd';
      P_CAT := 1;
    
      PK_EMPLEADOS.P_CREAR_USUARIO(
        P_USUARIO => P_USUARIO,
        P_CLAVE => P_CLAVE,
        P_CAT => P_CAT
      );
    --rollback; 
    END;
    /
    
-- P_empleado del año
    BEGIN
      PK_EMPLEADOS.P_EMPLEADODELANO();
    --rollback; 
    END;
    /

-- P_MOD_CAT_EMPLEADO -- no funciona del todo
    DECLARE
      P_DNI VARCHAR2(200);
      P_NUEVA_CAT NUMBER;
    BEGIN
      P_DNI := '1548796P';
      P_NUEVA_CAT := 1;
    
      PK_EMPLEADOS.P_MOD_CAT_EMPLEADO(
        P_DNI => P_DNI,
        P_NUEVA_CAT => P_NUEVA_CAT
      );
    --rollback; 
    END;
    /

set serveroutput on;
set echo on;


CREATE USER usuario987 IDENTIFIED BY bd default tablespace TS_MERCORACLE
quota UNLIMITED on TS_MERCORACLE
profile perf_empleado;