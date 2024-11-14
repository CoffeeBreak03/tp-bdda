-------------------------------------------------------
------------------ CREACIÓN DE LOGIN ------------------
-------------------------------------------------------

USE [master]
GO

IF SUSER_ID('gerenteMercado') IS NULL
BEGIN
    CREATE LOGIN gerenteMercado
		WITH PASSWORD = 'GatoWiWi#123',
		CHECK_POLICY = ON,
		DEFAULT_DATABASE = [Com5600G14];
END
GO

IF SUSER_ID('supervisorMercado') IS NULL
BEGIN
    CREATE LOGIN supervisorMercado
		WITH PASSWORD = 'Sol2024*',
		CHECK_POLICY = ON,
		DEFAULT_DATABASE = [Com5600G14];
END
GO


IF SUSER_ID('cajeroMercado') IS NULL
BEGIN
    CREATE LOGIN cajeroMercado
		WITH PASSWORD = 'Luna#4321',
		CHECK_POLICY = ON,
		DEFAULT_DATABASE = [Com5600G14];
END
GO


-------------------------------------------------------
----------------- CREACIÓN DE USUARIO -----------------
-------------------------------------------------------

USE [Com5600G14]
GO

IF DATABASE_PRINCIPAL_ID('gerenteMercado') IS NULL
	CREATE USER gerenteMercado FOR LOGIN gerenteMercado WITH DEFAULT_SCHEMA = [Person];
GO

IF DATABASE_PRINCIPAL_ID('supervisorMercado') IS NULL
	CREATE USER supervisorMercado FOR LOGIN supervisorMercado WITH DEFAULT_SCHEMA = [Sales];
GO

IF DATABASE_PRINCIPAL_ID('cajeroMercado') IS NULL
	CREATE USER cajeroMercado FOR LOGIN cajeroMercado WITH DEFAULT_SCHEMA = [Sales];
GO


-------------------------------------------------------
------------------ CREACIÓN DE ROLES ------------------
-------------------------------------------------------

IF DATABASE_PRINCIPAL_ID('Gerentes') IS NULL
	CREATE ROLE Gerentes AUTHORIZATION dbo;
GO

IF DATABASE_PRINCIPAL_ID('Supervisores') IS NULL
	CREATE ROLE Supervisores AUTHORIZATION dbo;
GO

IF DATABASE_PRINCIPAL_ID('Cajeros') IS NULL
	CREATE ROLE Cajeros AUTHORIZATION dbo;
GO


-------------------------------------------------------
---------------- OBTENCION DE PERMISOS ----------------
----------------------- GERENTE -----------------------
-------------------------------------------------------

--- SCHEMA SALES ---
GRANT SELECT ON SCHEMA::Sales TO [Gerentes];

--- SCHEMA PRODUCTION ---
GRANT SELECT ON SCHEMA::Production TO [Gerentes];

--- SCHEMA PERSON ---
GRANT SELECT ON SCHEMA::Person TO [Gerentes];

--- NOTA DE CREDITO ---
GRANT EXECUTE ON OBJECT::Sales.InsertNotaCredito TO [Gerentes];

--- TIPO FACTURA ---
GRANT EXECUTE ON OBJECT::Sales.InsertTipoFac TO [Gerentes];
GRANT EXECUTE ON OBJECT::Sales.DeleteTipoFac TO [Gerentes];

--- FACTURA ---
GRANT EXECUTE ON OBJECT::Sales.InsertFactura TO [Gerentes];
GRANT EXECUTE ON OBJECT::Sales.CambiarEstadoFacturaPagada TO [Gerentes];

--- VENTA ---
GRANT EXECUTE ON OBJECT::Sales.InsertVenta TO [Gerentes]; 
GRANT EXECUTE ON OBJECT::Sales.UpdateEstadoVenta TO [Gerentes]; 

--- MEDIO DE PAGO ---
GRANT EXECUTE ON OBJECT::Sales.InsertMedPag TO [Gerentes]; 
GRANT EXECUTE ON OBJECT::Sales.DeleteMedPag TO [Gerentes];

--- PAGO ---
GRANT EXECUTE ON OBJECT::Sales.InsertPago TO [Gerentes];
GRANT EXECUTE ON OBJECT::Sales.UpdateEstadoPago TO [Gerentes];

--- LINEA PRODUCTO ---
GRANT EXECUTE ON OBJECT::Production.InsertLineaProd TO [Gerentes];
GRANT EXECUTE ON OBJECT::Production.DeleteLineaProd TO [Gerentes];
GRANT EXECUTE ON OBJECT::Production.UpdateDescLinea TO [Gerentes];

--- PRODUCTO ---
GRANT EXECUTE ON OBJECT::Production.InsertProd TO [Gerentes]; 
GRANT EXECUTE ON OBJECT::Production.UpdateCantIngresadaProd TO [Gerentes]; 
GRANT EXECUTE ON OBJECT::Production.UpdatePriceProd TO [Gerentes];

--- SUCURSAL ---
GRANT EXECUTE ON OBJECT::Production.InsertSucursal TO [Gerentes];
GRANT EXECUTE ON OBJECT::Production.DeleteSucursal TO [Gerentes];
GRANT EXECUTE ON OBJECT::Production.UpdateUbicacionSucursal TO [Gerentes];

--- CLIENTE ---
GRANT EXECUTE ON OBJECT::Person.InsertCliente TO [Gerentes];
GRANT EXECUTE ON OBJECT::Person.DeleteCliente TO [Gerentes];

--- EMPLEADO ---
GRANT EXECUTE ON OBJECT::Person.InsertEmp TO [Gerentes];
GRANT EXECUTE ON OBJECT::Person.DeleteEmp TO [Gerentes];
GO


-------------------------------------------------------
---------------- OBTENCION DE PERMISOS ----------------
--------------------- SUPERVISOR ----------------------
-------------------------------------------------------

--- SCHEMA SALES ---
GRANT SELECT ON SCHEMA::Sales TO [Supervisores];

--- SCHEMA PRODUCTION ---
GRANT SELECT ON SCHEMA::Production TO [Supervisores];
DENY SELECT ON Production.Sucursal TO [Supervisores];

--- SCHEMA PERSON ---
GRANT SELECT ON SCHEMA::Person TO [Supervisores];
DENY SELECT ON Person.Empleado TO [Supervisores];

--- NOTA DE CREDITO ---
GRANT EXECUTE ON OBJECT::Sales.InsertNotaCredito TO [Supervisores];     

--- FACTURA ---
GRANT EXECUTE ON OBJECT::Sales.InsertFactura TO [Supervisores];
GRANT EXECUTE ON OBJECT::Sales.CambiarEstadoFacturaPagada TO [Supervisores];

--- VENTA ---
GRANT EXECUTE ON OBJECT::Sales.InsertVenta TO [Supervisores]; 
GRANT EXECUTE ON OBJECT::Sales.UpdateEstadoVenta TO [Supervisores]; 

--- PAGO ---
GRANT EXECUTE ON OBJECT::Sales.InsertPago TO [Supervisores];
GRANT EXECUTE ON OBJECT::Sales.UpdateEstadoPago TO [Supervisores];  

--- PRODUCTO ---
GRANT EXECUTE ON OBJECT::Production.InsertProd TO [Supervisores]; 
GRANT EXECUTE ON OBJECT::Production.UpdateCantIngresadaProd TO [Supervisores]; 
GRANT EXECUTE ON OBJECT::Production.UpdatePriceProd TO [Supervisores];

--- CLIENTE ---
GRANT EXECUTE ON OBJECT::Person.InsertCliente TO [Supervisores];
GRANT EXECUTE ON OBJECT::Person.DeleteCliente TO [Supervisores];
GO
-------------------------------------------------------
---------------- OBTENCION DE PERMISOS ----------------
----------------------- CAJERO ------------------------
-------------------------------------------------------

--- TABLA PRODUCTO ---
GRANT SELECT ON Production.Producto TO [Cajeros];

--- FACTURA ---
GRANT EXECUTE ON OBJECT::Sales.InsertFactura TO [Cajeros]; 

--- VENTA ---
GRANT EXECUTE ON OBJECT::Sales.InsertVenta TO [Cajeros]; 

--- PAGO ---
GRANT EXECUTE ON OBJECT::Sales.InsertPago TO [Cajeros];
GO


-------------------------------------------------------
------------------ AÑADIR USUARIOS A ------------------
------------------------ ROLES ------------------------
-------------------------------------------------------

ALTER ROLE Gerentes ADD MEMBER gerenteMercado;
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
DROP COLUMN DNI, Direccion, Localidad, Provincia, EmailPersona
GO

EXEC sp_rename 'Person.Empleado.DNI_encriptado', 'DNI', 'COLUMN';
EXEC sp_rename 'Person.Empleado.Direccion_encriptada', 'Direccion', 'COLUMN';
EXEC sp_rename 'Person.Empleado.Localidad_encriptada', 'Localidad', 'COLUMN';
EXEC sp_rename 'Person.Empleado.Provincia_encriptada', 'Provincia', 'COLUMN';
EXEC sp_rename 'Person.Empleado.EmailPersona_encriptado', 'EmailPersona', 'COLUMN';
GO

