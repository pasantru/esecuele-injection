--https://stackoverflow.com/questions/34108560/oracle-11g-sql-group-by-quarter

--NO TERMINADO
SELECT TO_NUMBER(TO_CHAR(T.FECHA_PEDIDO, 'YYYY')) "A�O" ,TRUNC(TO_NUMBER (TO_CHAR (T.FECHA_PEDIDO, 'MM') - 1) / 3) + 1 "TRIMESTRE", COUNT(*) FROM TICKET T 
GROUP BY TO_NUMBER(TO_CHAR(T.FECHA_PEDIDO, 'YYYY')) ,TRUNC(TO_NUMBER (TO_CHAR (T.FECHA_PEDIDO, 'MM') - 1) / 3) + 1
ORDER BY "A�O", "TRIMESTRE";