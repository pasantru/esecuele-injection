set serveroutput on;
DECLARE
  P_PRODUCTO NUMBER;
  DESDE DATE;
  HASTA DATE;
  v_Return MERCORACLE.PK_ANALISIS.T_VALORES_PRODUCTO;
BEGIN
  P_PRODUCTO := 3;
  DESDE := sysdate-1000;
  HASTA := sysdate;

  v_Return := PK_ANALISIS.F_CALCULAR_ESTADISTICAS(
    P_PRODUCTO => P_PRODUCTO,
    DESDE => DESDE,
    HASTA => HASTA
  );

DBMS_OUTPUT.PUT_LINE('v_Return = Maximo -> ' || v_Return.maximo ||'; Minimo -> ' || v_Return.minimo ||'; Media -> ' || v_Return.media;

  --:v_Return := v_Return;
--rollback; 
END;