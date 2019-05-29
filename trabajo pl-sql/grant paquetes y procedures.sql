-- todo como system

grant execute on pk_analisis to r_director;
grant execute on pk_empleados to r_director, r_supervisor;
grant execute on pk_puntos to r_director, r_supervisor;
grant execute on p_revisa to r_cajero;

grant create profile to mercoracle;
grant create user to mercoracle;

grant connect to mercoracle with admin option;
grant R_Director to mercoracle with admin option;
grant R_Supervisor to mercoracle with admin option;
grant R_Cajero to mercoracle with admin option;
grant alter user to mercoracle;
grant drop user to mercoracle;