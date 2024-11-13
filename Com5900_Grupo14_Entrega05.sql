-------------------------------------------------------
------------------ CREACIÓN DE LOGIN ------------------
-------------------------------------------------------

USE [master]
GO

CREATE LOGIN supervisorMercado
	WITH PASSWORD = 'Sol2024*',
		CHECK_POLICY = ON,
		DEFAULT_DATABASE = [Com5600G14]
GO

CREATE LOGIN cajeroMercado
	WITH PASSWORD = 'Luna#4321',
		CHECK_POLICY = ON,
		DEFAULT_DATABASE = [Com5600G14]
GO


-------------------------------------------------------
----------------- CREACIÓN DE USUARIO -----------------
-------------------------------------------------------

USE [Com5600G14]
GO

CREATE USER supervisorMercado FOR LOGIN supervisorMercado WITH DEFAULT_SCHEMA = [Sales];
CREATE USER cajeroMercado FOR LOGIN cajeroMercado WITH DEFAULT_SCHEMA = [Sales];
GO


-------------------------------------------------------
------------------ CREACIÓN DE ROLES ------------------
-------------------------------------------------------

CREATE ROLE Supervisores AUTHORIZATION dbo;
CREATE ROLE Cajeros AUTHORIZATION dbo;
GO

-------------------------------------------------------
---------------- OBTENCION DE PERMISOS ----------------
--------------------- SUPERVISOR ----------------------
-------------------------------------------------------

--- NOTA DE CREDITO ---
GRANT EXECUTE ON OBJECT::Sales.InsertNotaCredito TO Supervisores;     

--- FACTURA ---
GRANT EXECUTE ON OBJECT::Sales.InsertFactura TO Supervisores; 
GRANT EXECUTE ON OBJECT::Sales.DeleteFactura TO Supervisores;

--- VENTA ---
GRANT EXECUTE ON OBJECT::Sales.InsertVenta TO Supervisores; 
GRANT EXECUTE ON OBJECT::Sales.UpdateEstadoVenta TO Supervisores; 

--- PAGO ---
GRANT EXECUTE ON OBJECT::Sales.InsertPago TO Supervisores;
GRANT EXECUTE ON OBJECT::Sales.UpdateEstadoPago TO Supervisores;  

--- PRODUCTO ---
GRANT EXECUTE ON OBJECT::Production.InsertProd TO Supervisores; 
GRANT EXECUTE ON OBJECT::Production.UpdateCantIngresadaProd TO Supervisores; 
GRANT EXECUTE ON OBJECT::Production.UpdatePriceProd TO Supervisores;

--- CLIENTE ---
GRANT EXECUTE ON OBJECT::Person.InsertCliente TO Supervisores;
GRANT EXECUTE ON OBJECT::Person.DeleteCliente TO Supervisores;
GO
-------------------------------------------------------
---------------- OBTENCION DE PERMISOS ----------------
----------------------- CAJERO ------------------------
-------------------------------------------------------

--- FACTURA ---
GRANT EXECUTE ON OBJECT::Sales.InsertFactura TO Supervisores; 

--- VENTA ---
GRANT EXECUTE ON OBJECT::Sales.InsertVenta TO Supervisores; 

--- PAGO ---
GRANT EXECUTE ON OBJECT::Sales.InsertPago TO Supervisores;
GO


-------------------------------------------------------
------------------ AÑADIR USUARIOS A ------------------
------------------------ ROLES ------------------------
-------------------------------------------------------

ALTER ROLE Supervisores ADD MEMBER supervisorMercado;
ALTER ROLE Cajeros ADD MEMBER cajeroMercado;
GO


-------------------------------------------------------
-------------------- ENCRIPTACIÓN ---------------------
-------------------------------------------------------

ALTER TABLE Person.Empleado
ADD DNI_encriptado VARBINARY(256),
	Direccion_encriptada VARBINARY(256),
	Localidad_encriptada VARBINARY(256),
	Provincia_encriptada VARBINARY(256),
	EmailPersona_encriptado VARBINARY(256)
GO

DECLARE @Contraseña NVARCHAR(16) = 'QuieroMiPanDanes';

UPDATE Person.Empleado
SET DNI_encriptado = ENCRYPTBYPASSPHRASE(@Contraseña, CAST(DNI AS CHAR(8)), 1, CAST(IdEmp AS VARBINARY(255))),
	Direccion_encriptada = ENCRYPTBYPASSPHRASE(@Contraseña, Direccion),
	Localidad_encriptada = ENCRYPTBYPASSPHRASE(@Contraseña, Localidad),
	Provincia_encriptada = ENCRYPTBYPASSPHRASE(@Contraseña, Provincia),
	EmailPersona_encriptado = ENCRYPTBYPASSPHRASE(@Contraseña, EmailPersona);
GO

ALTER TABLE Person.Empleado
DROP COLUMN DNI, Nombre, Apellido, Direccion, Localidad, Provincia, EmailPersona
GO

--- MOSTRAR LOS DATOS ENCRIPTADOS ---
DECLARE @Contraseña NVARCHAR(16) = 'QuieroMiPanDanes';
SELECT CAST(DECRYPTBYPASSPHRASE(@Contraseña, DNI_encriptado, 1, CAST(IdEmp AS VARBINARY(255))) AS CHAR(8)) AS DNI,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, Direccion_encriptada) AS VARCHAR(50)) AS Direccion,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, Localidad_encriptada) AS VARCHAR(40)) AS Localidad,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, Provincia_encriptada) AS VARCHAR(40)) AS Provincia,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, EmailPersona_encriptado) AS VARCHAR(100)) AS EmailPersonal
FROM Person.Empleado;
