------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 14
--BASUALDO, NICOLÁS NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LEÓN 45040212
----------------------------------------------------------------

------------------------------------
--PRUEBA DE IMPORTACION Y REPORTES--
------------------------------------

--ORDEN DE EJECUCION DE LOS SP PARA IMPORTAR:
--1.Production.ImportInfoComp
--2.Production.ImportCatalogo
--3.Production.ImportElectrodomesticos
--4.Production.ImporteProductosImportados
--5.ImportVentas

USE Com5600G14;

----- PARA USO DE ENTORNO DE PRUEBAS -----
----- CREACION DE PERSONAS -----
IF OBJECT_ID('Person.NomYAp', 'U') IS NULL
BEGIN
	CREATE TABLE Person.NomYAp
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Nombre VARCHAR(30),
		Apellido VARCHAR(30)
	);
END
GO

INSERT INTO Person.NomYAp
VALUES('Mateo', 'González'),
('Sofía', 'Rodríguez'),
('Santiago', 'Pérez'),
('Camila', 'Fernández'),
('Martín', 'López'),
('Valentina', 'Gómez'),
('Lucas', 'Martínez'),
('Catalina', 'Díaz'),
('Joaquín', 'Sánchez'),
('Lucía', 'Torres'),
('Benjamín', 'Ramírez'),
('Emilia', 'Flores'),
('Tomás', 'Romero'),
('Julieta', 'Acosta'),
('Facundo', 'Álvarez'),
('Mía', 'Herrera'),
('Ignacio', 'Aguirre'),
('Lola', 'Pereyra'),
('Francisco', 'Castro')
GO

--Con esto verificamos que las tablas antes de la importacion estan vacias
/* 
SELECT * FROM Person.Cliente
SELECT * FROM Person.Empleado
SELECT * FROM Person.NomYAp
SELECT * FROM Person.TipoCliente
SELECT * FROM Production.LineaProducto
SELECT * FROM Production.Producto
SELECT * FROM Production.Sucursal
SELECT * FROM Sales.DetalleVenta 
SELECT * FROM Sales.Factura
SELECT * FROM Sales.Mediopago
SELECT * FROM Sales.Pago
SELECT * FROM Sales.TipoFactura
SELECT * FROM Sales.Venta
*/

--- ARCHIVO INFORMACION COMPLEMETARIA.XLSX ---
EXEC Production.ImportInfoComp 
	@NomArch = 'D:\TP_integrador_Archivos\Informacion_complementaria.xlsx';

--- ARCHIVO CATALOGO.CSV ---
EXEC Production.ImportCatalogo 
	@NomArchCat = 'D:\TP_integrador_Archivos\Productos\catalogo.csv', 
	@NomArchLineaProd = 'D:\TP_integrador_Archivos\Informacion_complementaria.xlsx';

--- ARCHIVO Electronic accessories.xsls ---
EXEC Production.ImportElectrodomesticos 
	@NomArch = 'D:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';

--- ARCHIVO PRODUCTOS IMPORTADOS.XLSX ---
EXEC Production.ImportProductosImportados 
	@NomArch = 'D:\TP_integrador_Archivos\Productos\Productos_importados.xlsx';

--- ARCHIVO INFORMACION VENTAS_REGISTRADAS.CSV ---
EXEC Production.ImportVentas 
	@NomArch = 'D:\TP_integrador_Archivos\Ventas_registradas.csv';

--Verificamos el contenido de las tablas, que se llenen adecuadamente
/* 
SELECT * FROM Person.Cliente
SELECT * FROM Person.Empleado
SELECT * FROM Person.NomYAp
SELECT * FROM Person.TipoCliente
SELECT * FROM Production.LineaProducto
SELECT * FROM Production.Producto
SELECT * FROM Production.Sucursal
SELECT * FROM Sales.DetalleVenta 
SELECT * FROM Sales.Factura
SELECT * FROM Sales.Mediopago
SELECT * FROM Sales.Pago
SELECT * FROM Sales.TipoFactura
SELECT * FROM Sales.Venta
*/

--Contamos la cantidad de registros
SELECT COUNT(*) AS TotalRegistros_Cli
FROM Person.Cliente;

SELECT COUNT(*) AS TotalRegistros_Emp
FROM Person.Empleado;

SELECT COUNT(*) AS TotalRegistros_Nyp
FROM Person.NomYAp;

SELECT COUNT(*) AS TotalRegistros_TipoCli
FROM Person.TipoCliente;

SELECT COUNT(*) AS TotalRegistros_LineProd
FROM Production.LineaProducto;

SELECT COUNT(*) AS TotalRegistros_Prod
FROM Production.Producto;

SELECT COUNT(*) AS TotalRegistros_Suc
FROM Production.Sucursal;

SELECT COUNT(*) AS TotalRegistros_Detalle
FROM Sales.DetalleVenta;

SELECT COUNT(*) AS TotalRegistros_Fac
FROM Sales.Factura;

SELECT COUNT(*) AS TotalRegistros_MedPago
FROM Sales.Mediopago;

SELECT COUNT(*) AS TotalRegistros_Pago
FROM Sales.Pago;

SELECT COUNT(*) AS TotalRegistros_TipoFac
FROM Sales.TipoFactura;

SELECT COUNT(*) AS TotalRegistros_Venta
FROM Sales.Venta;

--VOLVEMOS IMPORTAR PARA VERIFICAR SI ENTRAN LOS DUPLICADOS POR IMPORTACION
--- ARCHIVO INFORMACION COMPLEMETARIA.XLSX ---
EXEC Production.ImportInfoComp 
	@NomArch = 'D:\TP_integrador_Archivos\Informacion_complementaria.xlsx';

--- ARCHIVO CATALOGO.CSV ---
EXEC Production.ImportCatalogo 
	@NomArchCat = 'D:\TP_integrador_Archivos\Productos\catalogo.csv', 
	@NomArchLineaProd = 'D:\TP_integrador_Archivos\Informacion_complementaria.xlsx';

--- ARCHIVO Electronic accessories.xsls ---
EXEC Production.ImportElectrodomesticos 
	@NomArch = 'D:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';

--- ARCHIVO PRODUCTOS IMPORTADOS.XLSX ---
EXEC Production.ImportProductosImportados 
	@NomArch = 'D:\TP_integrador_Archivos\Productos\Productos_importados.xlsx';

--- ARCHIVO INFORMACION VENTAS_REGISTRADAS.CSV ---
EXEC Production.ImportVentas 
	@NomArch = 'D:\TP_integrador_Archivos\Ventas_registradas.csv';

--Contamos la cantidad de registro para verificar que no se ingresen duplicados
SELECT COUNT(*) AS TotalRegistros_Cli
FROM Person.Cliente;

SELECT COUNT(*) AS TotalRegistros_Emp
FROM Person.Empleado;

SELECT COUNT(*) AS TotalRegistros_Nyp
FROM Person.NomYAp;

SELECT COUNT(*) AS TotalRegistros_TipoCli
FROM Person.TipoCliente;

SELECT COUNT(*) AS TotalRegistros_LineProd
FROM Production.LineaProducto;

SELECT COUNT(*) AS TotalRegistros_Prod
FROM Production.Producto;

SELECT COUNT(*) AS TotalRegistros_Suc
FROM Production.Sucursal;

SELECT COUNT(*) AS TotalRegistros_Detalle
FROM Sales.DetalleVenta;

SELECT COUNT(*) AS TotalRegistros_Fac
FROM Sales.Factura;

SELECT COUNT(*) AS TotalRegistros_MedPago
FROM Sales.Mediopago;

SELECT COUNT(*) AS TotalRegistros_Pago
FROM Sales.Pago;

SELECT COUNT(*) AS TotalRegistros_TipoFac
FROM Sales.TipoFactura;

SELECT COUNT(*) AS TotalRegistros_Venta
FROM Sales.Venta;


EXEC Reporte.TotalFacturadoPorDia
	@mes = 02, 
	@año = 2019;

EXEC Reporte.TotalFacturadoPorTurnoPorMes

EXEC Reporte.CantidadProdVendidosEnRangoFecha
	@fechaIni = '2019-01-26', 
	@fechaFin= '2019-03-14';

EXEC Reporte.CantidadProdVendidosPorSucursalEnRangoFecha
	@fechaIni = '2019-01-26', 
	@fechaFin= '2019-03-14';

EXEC Reporte.ProductosMasVendidosEnMes
	@mes = 03;

EXEC Reporte.ProductosMenosVendidosEnMes
	@mes = 03;

EXEC Reporte.AcumuladoVentasParaFechaYSucursal
	@fecha = '2019-01-26', 
	@sucursal = 'San Justo';
