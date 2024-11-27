------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 14
--BASUALDO, NICOLÁS NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LEÓN 45040212
----------------------------------------------------------------

------------------------------------------
--------- PRUEBA DE ENCRIPTACION ---------
------------------------------------------
USE [Com5600G14]
GO

--- MOSTRAR LOS DATOS ENCRIPTADOS SIN CONTRASEÑA---
SELECT IdEmp AS NroEmp,
		Nombre,
		Apellido,
		EmailEmpresarial,
		Turno,
		Cargo,
		DNI,
		Direccion,
		Localidad,
		Provincia,
		EmailPersona
FROM Person.Empleado;
GO

--- MOSTRAR LOS DATOS ENCRIPTADOS CON CONTRASEÑA---
DECLARE @Contraseña NVARCHAR(16) = 'QuieroMiPanDanes';
SELECT IdEmp AS NroEmp,
		Nombre,
		Apellido,
		EmailEmpresarial,
		Turno,
		Cargo,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, DNI, 1, CAST(IdEmp AS VARBINARY(255))) AS CHAR(8)) AS DNI,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, Direccion) AS VARCHAR(50)) AS Direccion,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, Localidad) AS VARCHAR(40)) AS Localidad,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, Provincia) AS VARCHAR(40)) AS Provincia,
		CAST(DECRYPTBYPASSPHRASE(@Contraseña, EmailPersona) AS VARCHAR(100)) AS EmailPersonal
FROM Person.Empleado;
GO


------------------------------------------
----------- PRUEBA DE PERMISOS -----------
------------------------------------------

--- PROBAR PERMISOS DE GERENTE ---
USE [Com5600G14]
GO

EXECUTE AS LOGIN = 'gerenteMercado';
GO

SELECT CURRENT_USER
GO

--- EXEC SOBRE SP DE INSERT SUCURSAL ---
--- ESPERADO: INSERT EXITOSO
EXEC Production.InsertSucursal 'Calle Falsa 123', 'Springfield', 'Massachusetts', 'Lunes A lunes - 9AM a 18PM', '1122875921';
GO


--- EXEC SOBRE SP DE INSERT SUCURSAL ---
--- ESPERADO: PERMISO DENEGADO AL OBJETO InsertRegistro
EXEC ddbba.InsertReg 'I', 'PRUEBA DE PERMISOS';
GO


--- SELECT SOBRE TABLA EMPLEADO ---
--- ESPERADO: MOSTRAR RESULTADO DE LA TABLA Person.Empleado
SELECT *
FROM Person.Empleado;
GO

--- SELECT SOBRE TABLA EMPLEADO ---
--- ESPERADO: PERMISO DENEGADO AL OBJETO ddbba.Registro
SELECT *
FROM ddbba.Registro;
GO


-----------------------------
--- CAMBIAR CONEXION A sa ---
-----------------------------

--- PROBAR PERMISOS DE SUPERVISOR ---

USE [Com5600G14]
GO

EXECUTE AS LOGIN = 'supervisorMercado';
GO

SELECT CURRENT_USER
GO


--- EXEC SOBRE SP DE INSERT NOTA DE CREDITO ---
--- ESPERADO: INSERT EXITOSO
EXEC Sales.InsertNotaCredito '448-34-8700', 1894, '';
GO


--- EXEC SOBRE SP DE INSERT SUCURSAL ---
--- ESPERADO: PERMISO DENEGADO AL OBJETO InsertSucursal
EXEC Production.InsertSucursal 'Calle Falsa 123', 'Springfield', 'Massachusetts', 'Lunes A lunes - 9AM a 18PM', '1122875921';
GO


--- SELECT SOBRE TABLA EMPLEADO ---
--- ESPERADO: PERMISO DENEGADO AL OBJETO Person.Empleado
SELECT *
FROM Person.Empleado;
GO


--- SELECT SOBRE TABLA LINEA PRODUCTO ---
--- ESPERADO: RESULTADO DE LA TBLA LINEA PRODUCTO
SELECT *
FROM Production.LineaProducto
GO


-----------------------------
--- CAMBIAR CONEXION A sa ---
-----------------------------

--- PROBAR PERMISOS DE CAJERO ---
USE [Com5600G14]
GO

EXECUTE AS LOGIN = 'cajeroMercado'
GO

SELECT CURRENT_USER
GO

--- EXEC SOBRE SP DE INSERT VENTA ---
--- ESPERADO: INSERT EXITOSO
EXEC Sales.InsertVenta 10, 2, 1000

--- EXEC SOBRE SP DE INSERT LINEA DE PRODUCTO ---
--- ESPERADO: PERMISO DENEGADO AL OBJETO InsertNotaCredito
EXEC Sales.InsertNotaCredito '448-34-8700', 0, 82.25, '';
GO


--- SELECT SOBRE TABLA PRODUCTO ---
--- ESPERADO: RESULTADO DE LA TABLA PRODUCTO
SELECT *
FROM Production.Producto;
GO


--- SELECT SOBRE TABLA EMPLEADO ---
--- ESPERADO: PERMISO DENEGADO AL OBJETO Sales.Venta
SELECT *
FROM Sales.Venta;
GO
