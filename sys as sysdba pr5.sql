--Para crear una tabla externa, primero hay que dar de alta un directorio en Oracle. Para ello vamos a buscar un directorio donde el usuario de Oracle tenga acceso. Por ejemplo, podemos usar el directorio:
--C:\Users\alumnos\Oracle

-- 1 Creamos en ese directorio el fichero clientes.txt con el siguiente contenido:
        --001,Hutt,Jabba,89674385A,jabba,jabba@thecompany.com,Palacio de Jabba-Tatooine, 99235
        --002,Simpson,Homer,38294738B,homer,homer@thecompany.com,Springfiled,98765
        --003,Kent,Clark,08273619C,superman,superman@thecompany.com,Metropolis, 99999
        --004,Kid,Billy,92874362D,billythkid,billythkid@thecompany.com,Fort Sumner, 44444
        --005,Stranger,Perfect,38920983E,nobody,nobody@thecompany.com,Nooneknows,11111
        --006,Zoidberg,Dr,09451028F,crustacean,crustacean@thecompany.com,Planet Express,10101
--  2. Nos conectamos con el usuario sys as sysdba.

--  3. Ejecutamos:
create or replace directory directorio_ext as 'C:\Users\alumnos\Oracle';

-- 4. Darle permiso al usuario MERCORACLE para leer y escribir en el directorio:
grant read, write on directory directorio_ext to mercoracle;




grant create materialized view to mercoracle;

grant create synonym to mercoracle;