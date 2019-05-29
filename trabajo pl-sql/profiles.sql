-- grant create profile on mercoracle -- como system

create profile perf_administrativo limit
sessions_per_user 3
connect_time unlimited
idle_time 5
failed_login_attempts 3
password_life_time 90
password_grace_time 3;


create profile perf_empleado limit
sessions_per_user 4
connect_time unlimited
idle_time 5
failed_login_attempts 3
password_life_time 30
password_grace_time 3;