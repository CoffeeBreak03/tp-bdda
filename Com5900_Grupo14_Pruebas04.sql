USE Com5600G14;

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

--- ARCHIVO INFORMACION COMPLEMETARIA.XLSX ---
EXEC Production.ImportInfoComp 
	@NomArch = 'D:\TP_integrador_Archivos\Informacion_complementaria.xlsx';

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

--- ARCHIVO INFORMACION COMPLEMETARIA.XLSX ---
EXEC Production.ImportInfoComp 
	@NomArch = 'D:\TP_integrador_Archivos\Informacion_complementaria.xlsx';

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


EXEC ddbba.TotalFacturadoPorDia
	@mes = 02, 
	@año = 2019;

EXEC ddbba.TotalFacturadoPorTurnoPorMes

EXEC ddbba.CantidadProdVendidosEnRangoFecha
	@fechaIni = '2019-01-26', 
	@fechaFin= '2019-03-14';

EXEC ddbba.CantidadProdVendidosPorSucursalEnRangoFecha
	@fechaIni = '2019-01-26', 
	@fechaFin= '2019-03-14';

EXEC ddbba.ProductosMasVendidosEnMes
	@mes = 03;

EXEC ddbba.ProductosMenosVendidosEnMes
	@mes = 03;

EXEC ddbba.AcumuladoVentasParaFechaYSucursal
	@fecha = '2019-01-26', 
	@sucursal = 'San Justo';
