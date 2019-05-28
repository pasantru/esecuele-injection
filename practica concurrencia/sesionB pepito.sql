--Cambiamos el valor de una tupla y comprobamos que tiene el nuevo valor:
UPDATE CUENTA SET saldo = 9000 Where Numero = 11;
commit;


--3
update cuenta set numero = 13, saldo = 50 where numero =22;

--4
update cuenta set numero = 12, saldo = 45 where numero =11;

rollback;

--5
select * from cuenta;

update cuenta set numero = 12, saldo = 45 where numero =11;
INSERT INTO CUENTA VALUES (12,1000);

--6 
ALTER TABLE cuenta ADD columna2 VARCHAR(20) NULL;

--8
update cuenta set numero = 12, saldo = 45 where numero =11;

lock table cuenta in share mode;


--9
INSERT INTO CUENTA VALUES (23,25000, null, null);
COMMIT;