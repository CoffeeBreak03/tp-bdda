------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 14
--BASUALDO, NICOL�S NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LE�N 45040212
----------------------------------------------------------------
/*
ENUNCIADO:

El sistema debe ofrecer los siguientes reportes en xml.
Mensual: ingresando un mes y a�o determinado mostrar el total facturado por d�as de
la semana, incluyendo s�bado y domingo.
Trimestral: mostrar el total facturado por turnos de trabajo por mes.
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a
menor.
Mostrar los 5 productos m�s vendidos en un mes, por semana
Mostrar los 5 productos menos vendidos en el mes.
Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha
y sucursal particulares
*/

USE [Com5600G14]
GO

----------------------------------------------
------------------ REPORTES ------------------
----------------------------------------------

CREATE OR ALTER PROCEDURE Reporte.TotalFacturadoPorDia(@mes SMALLINT, @a�o INT)
AS
BEGIN
	WITH VentasPorDiaDeSemana(Dia, Monto) as (
		SELECT DATENAME(WEEKDAY, v.Fecha), d.Subtotal
		FROM Sales.Venta v JOIN Sales.DetalleVenta d on v.IdVenta = d.IdVenta
		WHERE MONTH(v.Fecha) = @mes AND YEAR(v.Fecha) = @a�o
		AND v.Estado = 'ACTIVA'
	)

	SELECT Dia, SUM(Monto) as Monto FROM VentasPorDiaDeSemana
	GROUP BY Dia
	FOR XML raw, elements, root('TotalFacturadoPorDia')
END
GO 

CREATE OR ALTER PROCEDURE Reporte.TotalFacturadoPorTurnoPorMes
AS
BEGIN
	SELECT e.Turno ,DATENAME(MONTH, v.Fecha) as Mes, SUM(dv.Subtotal) as Monto
	FROM Sales.Venta v JOIN Sales.DetalleVenta dv on v.IdVenta = dv.IdVenta
		JOIN Production.Sucursal s on v.IdSuc = s.IdSuc
		JOIN Person.Empleado e on s.IdSuc = e.IdSuc
	WHERE v.Estado = 'ACTIVA' AND s.Baja = NULL AND e.Baja = NULL
	GROUP BY e.Turno, DATENAME(MONTH, v.Fecha)
	ORDER BY e.Turno, Mes
	FOR XML raw, elements, root('TotalFacturadoPorTurnoPorMes')
END
GO

CREATE OR ALTER PROCEDURE Reporte.CantidadProdVendidosEnRangoFecha(@fechaIni date, @fechaFin date)
AS
BEGIN
	SELECT v.Fecha, SUM(dv.Cantidad) as Cantidad
	FROM Sales.Venta v JOIN Sales.DetalleVenta dv on v.IdVenta = dv.IdVenta
	WHERE v.Fecha >= @fechaIni AND v.Fecha <= @fechaFin
	AND v.Estado = 'ACTIVA'
	GROUP BY v.Fecha
	ORDER BY SUM(dv.Cantidad) DESC
	FOR XML raw, elements, root('CantidadProdVendidosEnRangoFecha')
END
GO

CREATE OR ALTER PROCEDURE Reporte.CantidadProdVendidosPorSucursalEnRangoFecha(@fechaIni date, @fechaFin date)
AS
BEGIN
	SELECT v.Fecha, s.Localidad as Sucursal, SUM(dv.Cantidad) as Cantidad
	FROM Sales.Venta v JOIN Sales.DetalleVenta dv on v.IdVenta = dv.IdVenta
		JOIN Production.Sucursal s on v.IdSuc = S.IdSuc
	WHERE v.Fecha >= @fechaIni AND v.Fecha <= @fechaFin
	AND v.Estado = 'ACTIVA' AND s.Baja = NULL
	GROUP BY v.Fecha, s.Localidad 
	ORDER BY SUM(dv.Cantidad) DESC
	FOR XML raw, elements, root('CantidadProdVendidosPorSucursalEnRangoFecha')
END
GO

CREATE OR ALTER PROCEDURE Reporte.ProductosMasVendidosEnMes(@mes SMALLINT)
AS
BEGIN
	WITH ProdsVendidosSemana (Semana, Producto, Cantidad) AS (
		SELECT DATEPART(WEEK, v.Fecha) - DATEPART(WEEK, DATETRUNC(MONTH, v.Fecha)) + 1, p.Descripcion, SUM(dv.Cantidad)
		FROM Sales.Venta v JOIN Sales.DetalleVenta dv on v.IdVenta = dv.IdVenta
		JOIN Production.Producto p on dv.IdProd = p.IdProd
		WHERE MONTH(v.Fecha) = @mes
		AND v.Estado = 'ACTIVA' AND p.Baja = NULL
		GROUP BY DATEPART(WEEK, v.Fecha) - DATEPART(WEEK, DATETRUNC(MONTH, v.Fecha)) + 1, p.Descripcion
		)

	SELECT Semana, Producto, Cantidad
	FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY Semana ORDER BY Cantidad DESC) as Fila FROM ProdsVendidosSemana) as t
	WHERE Fila <= 5
	FOR XML raw, elements, root('ProductosMasVendidosEnMes')
END
GO

CREATE OR ALTER PROCEDURE Reporte.ProductosMenosVendidosEnMes(@mes SMALLINT)
AS
BEGIN
	WITH ProdsVendidosMes (Producto, Cantidad) AS (
		SELECT p.Descripcion, SUM(dv.Cantidad)
		FROM Sales.Venta v JOIN Sales.DetalleVenta dv on v.IdVenta = dv.IdVenta
		JOIN Production.Producto p on dv.IdProd = p.IdProd
		WHERE MONTH(v.Fecha) = @mes
		AND v.Estado = 'ACTIVA' AND p.Baja = NULL
		GROUP BY p.Descripcion
		)

	SELECT TOP(5) *
	FROM ProdsVendidosMes
	ORDER BY Cantidad ASC
	FOR XML raw, elements, root('ProductosMenosVendidosEnMes')
END
GO

CREATE OR ALTER PROCEDURE Reporte.AcumuladoVentasParaFechaYSucursal(@fecha DATE, @sucursal CHAR(20))
AS
BEGIN
	SELECT v.Fecha, s.Localidad as Sucursal, dv.Cantidad, dv.Subtotal
	FROM Sales.Venta v JOIN Sales.DetalleVenta dv on v.IdVenta = dv.IdVenta
		JOIN Production.Sucursal s on v.IdSuc = S.IdSuc
	WHERE v.Fecha = @fecha AND s.Localidad = @sucursal
	AND v.Estado = 'ACTIVA' AND s.Baja = NULL
	FOR XML raw, elements, root('AcumuladoVentasParaFechaYSucursal')
END
GO
