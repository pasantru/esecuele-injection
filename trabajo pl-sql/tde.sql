-- como system

ALTER SYSTEM SET "WALLET_ROOT"='C:\Users\alumnos\Oracle\Wallet' scope=SPFILE;

ALTER SYSTEM SET TDE_CONFIGURATION="KEYSTORE_CONFIGURATION=FILE" scope=both; -- hay que reiniciar la instancia como sys

-- con sqlplus como (sys as syskm)
-- ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY bd;  
-- ADMINISTER KEY MANAGEMENT CREATE AUTO_LOGIN KEYSTORE FROM KEYSTORE IDENTIFIED BY bd;
-- ADMINISTER KEY MANAGEMENT SET KEYSTORE open IDENTIFIED BY bd;
-- ADMINISTER KEY MANAGEMENT SET KEY identified by bd with backup;

alter table mercoracle.cliente 
modify nombre VARCHAR2(128) ENCRYPT;

alter table mercoracle.cliente 
modify apellido1 VARCHAR2(128) ENCRYPT;

alter table mercoracle.cliente 
modify apellido2 VARCHAR2(128) ENCRYPT;

alter table mercoracle.cliente 
modify domicilio VARCHAR2(128) ENCRYPT;

alter table mercoracle.cliente 
modify codigo_postal number ENCRYPT;


alter table MERCORACLE.FIDELIZADO
modify telefono VARCHAR2(128) ENCRYPT;

alter table MERCORACLE.FIDELIZADO
modify email VARCHAR2(128) ENCRYPT;


alter table MERCORACLE.empleado
modify nombre VARCHAR2(128) ENCRYPT;

alter table mercoracle.empleado
modify apellido1 VARCHAR2(128) ENCRYPT;

alter table mercoracle.empleado 
modify apellido2 VARCHAR2(128) ENCRYPT;

alter table mercoracle.empleado
modify domicilio VARCHAR2(128) ENCRYPT;

alter table mercoracle.empleado
modify codigo_postal number ENCRYPT;

alter table mercoracle.empleado
modify telefono VARCHAR2(128) ENCRYPT;

alter table mercoracle.empleado 
modify email VARCHAR2(128) ENCRYPT;

alter table mercoracle.empleado 
modify fecha_alta date ENCRYPT;


alter table mercoracle.nomina
modify importe_neto number ENCRYPT;

alter table mercoracle.nomina
modify importe_bruto number ENCRYPT;