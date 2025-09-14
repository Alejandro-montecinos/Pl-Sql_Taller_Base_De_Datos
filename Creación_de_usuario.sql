alter SESSION set "_oracle_script"=TRUE

-- crear el usuario y los permisos

CREATE USER contaminacion IDENTIFIED BY "contaminacion.1234"
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";
ALTER USER contaminacion QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION TO contaminacion;
GRANT "RESOURCE" TO contaminacion;
ALTER USER contaminacion DEFAULT ROLE "RESOURCE";