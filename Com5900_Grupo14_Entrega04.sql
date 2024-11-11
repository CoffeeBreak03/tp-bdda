USE Com5600G14
GO

-------------------------------------------------------
---------------- IMPORTACIÓN DE DATOS -----------------
-------------------------------------------------------

--- ARCHIVO CATALOGO.CSV ---
CREATE OR ALTER PROCEDURE Production.ImportCatalogo
	@NomArchCat NVARCHAR(255), -- Parámetro para el nombre del archivo
	@NomArchLineaProd NVARCHAR(255)
AS
BEGIN
	CREATE TABLE #TmpCatalogo
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	CREATE TABLE #TempCategoria
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Descripcion VARCHAR(36),
		NomProd VARCHAR(40)
	);

	CREATE TABLE #TempProductos
	(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		LinProd INT,
		NomProd VARCHAR(40),
		Descripcion VARCHAR(90),
		Precio NUMERIC(7,2),
		RefPrecio NUMERIC(7,2),
		RefPeso CHAR(20),
		FechaIng DATE
	);

	-- Usar el parámetro @NomArch en el BULK INSERT
	EXEC('
		BULK INSERT #TmpCatalogo
		FROM ''' + @NomArchCat + '''
		WITH (
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''0x0A'',
			CODEPAGE = ''65001'',
			FIRSTROW = 2
		)
	');

	-- Usar el parametro @NomArchLineaProd en OPENROWSET e insertar en la tabla #TempCategoria
	EXEC('INSERT INTO #TempCategoria (Descripcion, NomProd) ' +
    'SELECT [LÍNEA DE PRODUCTO], PRODUCTO ' +
    'FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', ' +
    '''Excel 12.0;Database=' + @NomArchLineaProd + ';HDR=YES'', ' +
    '''SELECT * FROM [Clasificacion productos$]'')');


	WITH TablaParseada AS(
		SELECT ID, Parte, NumParte
		FROM #TmpCatalogo
		CROSS APPLY ddbba.ParseLineaCSV(TEXTO, ',')
	),
	TabTempParCat AS(
		SELECT ID, Parte, LP.Descripcion
		FROM #TempCategoria TEMCAT
		INNER JOIN Production.LineaProducto lp ON TEMCAT.Descripcion = lp.Descripcion COLLATE Latin1_General_CI_AS 
		CROSS APPLY ddbba.ParseLineaCSV(NomProd, ',')

	),
	DetProd AS(
		SELECT 
			MAX(lp.IdLinProd) LinProd,
			MAX(CASE WHEN tp.NumParte = 1 THEN tp.Parte END) AS NomProd,
			MAX(CASE WHEN tp.NumParte = 2 THEN tp.Parte END) AS Descripcion,
			MAX(CASE WHEN tp.NumParte = 3 THEN TRY_CAST(tp.Parte AS NUMERIC(7,2)) END) AS Precio,
			MAX(CASE WHEN tp.NumParte = 4 THEN TRY_CAST(tp.Parte AS NUMERIC(7,2)) END) AS RefPrecio,
			MAX(CASE WHEN tp.NumParte = 5 THEN tp.Parte END) AS RefPeso,
			MAX(CASE WHEN tp.NumParte = 6 THEN TRY_CAST(tp.Parte AS DATE) END) AS FechaIng
		FROM TablaParseada tp
			LEFT JOIN TabTempParCat tc ON tc.Parte = tp.Parte
			LEFT JOIN Production.LineaProducto lp ON tc.Descripcion = lp.Descripcion
		GROUP BY tp.ID
	)
	INSERT INTO #TempProductos (LinProd, NomProd, Descripcion, Precio, RefPrecio, RefPeso, FechaIng)
	SELECT LinProd, NomProd, Descripcion, Precio, RefPrecio, RefPeso, FechaIng
	FROM DetProd;

	MERGE INTO Production.Producto AS dest
	USING #TempProductos AS orig
	ON dest.NomProd COLLATE Latin1_General_CI_AS = orig.NomProd COLLATE Latin1_General_CI_AS
		AND dest.Descripcion COLLATE Latin1_General_CI_AS = orig.Descripcion COLLATE Latin1_General_CI_AS
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (IdLinProd, NomProd, CantIngresada, CantVendida, Descripcion, Proveedor, PrecioUnit, RefPrecio, RefPeso, FechaIng)
			VALUES (orig.LinProd, UPPER(orig.NomProd), 1, 0, orig.Descripcion, 'No especificado', orig.Precio, orig.RefPrecio, orig.RefPeso, orig.FechaIng)
	WHEN MATCHED
		THEN
			UPDATE SET dest.CantIngresada = dest.CantIngresada + 1;
	
	DROP TABLE #TmpCatalogo;
	DROP TABLE #TempCategoria;
	
	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE CATALOGO.CSV'
END
GO


--- ARCHIVO Electronic accessories.xsls ---
CREATE OR ALTER PROCEDURE Production.ImportElectrodomesticos
	@NomArch VARCHAR(255)
AS
BEGIN
	DECLARE @DescCategoria CHAR(16) = 'ELECTRODOMÉSTICO';

	IF NOT EXISTS(SELECT 1 FROM Production.LineaProducto WHERE Descripcion = @DescCategoria)	-- SOLO LO INSERTO LA PRIMERA VEZ
		EXEC Production.InsertLineaProd @Descripcion = @DescCategoria;

	DECLARE @IdCat INT = (SELECT IdLinProd FROM Production.LineaProducto WHERE Descripcion = @DescCategoria);

	EXEC('INSERT INTO Production.Producto (IdLinProd, CantIngresada, CantVendida, Descripcion, Proveedor, PrecioUnit, RefPrecio, RefPeso, FechaIng)
    SELECT @IdCat, 1, 0, ''Product'', ''No especificado'', ''Precio Unitario en Dolares'', 0, 0, GETDATE()
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
                     ''Excel 12.0;Database=' + @NomArch + ';HDR=YES;'', 
                     ''SELECT * FROM [Sheet1$]'')');

	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE ELECTRONI ASCCESSORIES.XLSX';
END
GO


--- ARCHIVO PRODUCTOS IMPORTADOS.XLSX ---
CREATE OR ALTER PROCEDURE Production.ImportProductosImportados
	@NomArch VARCHAR(255)
AS
BEGIN
	CREATE TABLE #TempProdImport
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	EXEC('INSERT INTO #TempProdImport(TEXTO)
    SELECT NombreProducto + ''|'' + Proveedor + ''|'' + Categoría + ''|'' + CantidadPorUnidad + ''|'' + TRY_CAST(PrecioUnidad AS VARCHAR(10))
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
                     ''Excel 12.0;Database=' + @NomArch + ';HDR=YES;IMEX=1'', 
                     ''SELECT * FROM [Listado de Productos$]'')');

	WITH TabParseada AS(
		SELECT 
			ID AS ID_TAB_PARS,
			NumParte,
			Parte
		FROM #TempProdImport
		CROSS APPLY ddbba.ParseExcelReg(TEXTO)
	),
	DetalleProd AS(
		SELECT
			tp.ID_TAB_PARS AS ID_DETALLE_PROD,
			MAX(CASE WHEN tp.NumParte = 1 THEN tp.Parte END) AS DESCRIPCION,
			MAX(CASE WHEN tp.NumParte = 2 THEN tp.Parte END) AS PROVEEDOR,
			MAX(CASE WHEN tp.NumParte = 3 THEN tp.Parte END) AS NOM_PRODUCTO,
			MAX(CASE WHEN tp.NumParte = 4 THEN tp.Parte END) AS CANTIDAD_TEMPORAL,
			MAX(CASE WHEN tp.NumParte = 5 THEN TRY_CAST(tp.Parte AS NUMERIC(7,2)) END) AS PRECIO
		FROM TabParseada tp
		GROUP BY tp.ID_TAB_PARS
	),
	TabCantRef AS(
		SELECT 
			dp.ID_DETALLE_PROD AS ID_TAB_CANT_REF, 
			MAX(Cant) AS CANTIDAD, 
			MAX(Ref) AS REF_PESO
		FROM DetalleProd dp
		CROSS APPLY ddbba.SepararCantidadReferenciaXLSX(CANTIDAD_TEMPORAL)
		GROUP BY dp.ID_DETALLE_PROD
	)
	INSERT INTO Production.Producto (IdLinProd, NomProd, CantIngresada, CantVendida, Descripcion, Proveedor, PrecioUnit, RefPrecio, RefPeso, FechaIng)
	SELECT lp.IdLinProd, dp.NOM_PRODUCTO, tc.CANTIDAD, 0, dp.DESCRIPCION, dp.PROVEEDOR, dp.PRECIO, 0, tc.REF_PESO, GETDATE()
	FROM DetalleProd dp
		INNER JOIN TabCantRef tc ON dp.ID_DETALLE_PROD = tc.ID_TAB_CANT_REF
		INNER JOIN Production.LineaProducto lp ON lp.Prod = NOM_PRODUCTO;

	DROP TABLE #TempProdImport;
	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE PRODUCTOS IMPORTADOS.XLSX';
END
GO


--- ARCHIVO INFORMACION COMPLEMETARIA.XLSX ---

CREATE OR ALTER PROCEDURE Production.ImportInfoComp
	@NomArch VARCHAR(255)
AS
BEGIN
	CREATE TABLE #TempInfoCompImport
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	EXEC('INSERT INTO #TempInfoCompImport(TEXTO)
		SELECT CIUDAD + ''|'' + ''REEMPLAZAR POR'' + ''|'' + DIRECCION + ''|'' + HORARIO + ''|'' + TRY_CAST(TELEFONO AS VARCHAR(10))
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
						 ''Excel 12.0;Database=' + @NomArch + ''', 
						 ''SELECT * FROM [sucursal$]'')');

	WITH TabParse AS(
		SELECT ID, Parte, NumParte
		FROM #TempInfoCompImport
		CROSS APPLY ddbba.ParseExcelReg(TEXTO)
	),
	DetalleSuc AS(
		SELECT
			ID,
			MAX(CASE WHEN NumParte = 1 THEN Parte END) AS CIUDAD,
			MAX(CASE WHEN NumParte = 2 THEN Parte END) AS CIUDAD_REMPLAZAR,
			MAX(CASE WHEN NumParte = 3 THEN Parte END) AS DIRECCION_SUC,
			MAX(CASE WHEN NumParte = 4 THEN Parte END) AS HORARIO,
			MAX(CASE WHEN NumParte = 5 THEN Parte END) AS TELEFONO
		FROM TabParse
		GROUP BY ID
	),
	DetalleDir AS(
		SELECT ID, Direccion AS DIRECCION, Localidad AS LOCALIDAD, Provincia AS PROVINCIA
		FROM DetalleSuc
		CROSS APPLY ddbba.ParseUbicacion(DIRECCION_SUC)
	)
	INSERT INTO Production.Sucursal(CiudadOrig, Localidad, Direccion, Provincia, Horario, Telefono)
	SELECT ds.CIUDAD, ds.CIUDAD_REMPLAZAR, dd.DIRECCION, dd.PROVINCIA, ds.HORARIO, ds.TELEFONO
	FROM DetalleSuc ds
		INNER JOIN DetalleDir dd ON ds.ID = dd.ID;


	DELETE FROM #TempInfoCompImport;


	EXEC('INSERT INTO #TempInfoCompImport(TEXTO)
		SELECT TRY_CAST([LEGAJO/ID] AS CHAR(6)) + ''|'' + NOMBRE + ''|'' + APELLIDO + ''|'' + TRY_CAST(TRY_CAST(DNI AS NUMERIC(8,0)) AS VARCHAR(8)) + ''|'' + DIRECCION + ''|'' + [EMAIL PERSONAL] + ''|'' + [EMAIL EMPRESA] + ''|'' + CARGO + ''|'' + SUCURSAL + ''|'' + TURNO
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
						 ''Excel 12.0;Database=' + @NomArch + ''', 
						 ''SELECT * FROM [Empleados$A1:K17]'')');

	WITH TablaParse AS(
		SELECT ID, Parte, NumParte
		FROM #TempInfoCompImport
		CROSS APPLY ddbba.ParseExcelReg(TEXTO)
	),
	DetalleEmp AS(
		SELECT
			ID,
			MAX(CASE WHEN NumParte = 1 THEN Parte END) AS LEGAJO,
			MAX(CASE WHEN NumParte = 2 THEN Parte END) AS NOMBRE,
			MAX(CASE WHEN NumParte = 3 THEN Parte END) AS APELLIDO,
			MAX(CASE WHEN NumParte = 4 THEN Parte END) AS DNI,
			MAX(CASE WHEN NumParte = 5 THEN Parte END) AS DIRECCION_EMP,
			MAX(CASE WHEN NumParte = 6 THEN Parte END) AS EMAIL_PERSONAL,
			MAX(CASE WHEN NumParte = 7 THEN Parte END) AS EMAIL_EMPRESA,
			MAX(CASE WHEN NumParte = 8 THEN Parte END) AS CARGO,
			MAX(CASE WHEN NumParte = 9 THEN Parte END) AS SUCURSAL,
			MAX(CASE WHEN NumParte = 10 THEN Parte END) AS TURNO
		FROM TablaParse
		GROUP BY ID
	),
	DetalleDir AS(
		SELECT ID, Direccion AS DIRECCION, Localidad AS LOCALIDAD, Provincia AS PROVINCIA
		FROM DetalleEmp
		CROSS APPLY ddbba.ParseUbicacion(DIRECCION_EMP)
	)
	INSERT INTO Person.Empleado(Legajo, Nombre, Apellido, DNI, Direccion, Localidad, Provincia, EmailPersona, EmailEmpresarial, Cargo, IdSuc, Turno)
	SELECT de.LEGAJO, de.NOMBRE, de.APELLIDO, de.DNI, dd.DIRECCION, dd.LOCALIDAD, dd.PROVINCIA, de.EMAIL_PERSONAL, de.EMAIL_EMPRESA, de.CARGO, s.IdSuc, 
			CASE 
				WHEN TURNO LIKE 'Jornada completa' THEN 'JC'
				ELSE TURNO
			END
	FROM DetalleEmp de
		INNER JOIN DetalleDir dd ON de.ID = dd.ID
		INNER JOIN Production.Sucursal s ON s.Localidad = de.SUCURSAL;


	DROP TABLE #TempInfoCompImport;

	EXEC('INSERT INTO Sales.Mediopago(MedPagoAReemp, Descripcion)
		SELECT F2, F3
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
						 ''Excel 12.0;Database=' + @NomArch + ''', 
						 ''SELECT * FROM [medios de pago$]'')');


	EXEC('INSERT INTO Production.LineaProducto (Descripcion, Prod)
		SELECT [LÍNEA DE PRODUCTO], PRODUCTO
		FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
						 ''Excel 12.0;Database=' + @NomArch + ''', 
						 ''SELECT * FROM [Clasificacion productos$]'')');

	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE INFORMACION_COMPLEMENTARIA.XLSX'
END
GO


--- ARCHIVO INFORMACION VENTAS_REGISTRADAS.CSV ---
CREATE OR ALTER PROCEDURE Production.ImportVentas
	@NomArch VARCHAR(255)
AS
BEGIN
	CREATE TABLE #TmpVentasIntermedio
	(
		TEXTO NVARCHAR(MAX)
	);

	EXEC('BULK INSERT #TmpVentasIntermedio
		FROM ''' + @NomArch + '''
		WITH(
			FIELDTERMINATOR = '';'',
			ROWTERMINATOR = ''0x0A'',
			CODEPAGE = ''65001'',
			FIRSTROW = 2
		);');

	CREATE TABLE #TmpVentas
	(
		ID INT IDENTITY PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	INSERT INTO #TmpVentas (TEXTO) SELECT TEXTO FROM #TmpVentasIntermedio
	--Hago esto porque si no me tira error por el campo ID
	DROP TABLE #TmpVentasIntermedio

	DECLARE @TabPartesPorVenta TABLE (
		ID INT,
		IdFact VARCHAR(15),
		TipoFact CHAR(1),
		Ciudad NVARCHAR(20),
		TipoClien CHAR(10),
		Genero CHAR(6),
		Prod NVARCHAR(90),
		PrecUni DECIMAL(10,2),
		Cant INT,
		Fecha DATE,
		Hora TIME,
		MedPago VARCHAR(15),
		Empl CHAR(6),
		IdPago VARCHAR(50)
	);

	WITH TabParseada AS(
		SELECT ID, Parte, NumParte
		FROM #TmpVentas
		CROSS APPLY ddbba.ParseLineaCSV(TEXTO, ';')
	)

	INSERT INTO @TabPartesPorVenta 
	SELECT ID,
		 MAX(CASE WHEN NumParte = 1 THEN Parte END) AS IdFact,
		 MAX(CASE WHEN NumParte = 2 THEN Parte END) AS TipoFact,
		 MAX(CASE WHEN NumParte = 3 THEN Parte END) AS Ciudad,
		 MAX(CASE WHEN NumParte = 4 THEN Parte END) AS TipoClien,
		 MAX(CASE WHEN NumParte = 5 THEN Parte END) AS Genero,
		 MAX(CASE WHEN NumParte = 6 THEN Parte END) AS Prod,
		 MAX(CASE WHEN NumParte = 7 THEN Parte END) AS PrecUni,
		 MAX(CASE WHEN NumParte = 8 THEN Parte END) AS Cant,
		 MAX(CASE WHEN NumParte = 9 THEN Parte END) AS Fecha,
		 MAX(CASE WHEN NumParte = 10 THEN Parte END) AS Hora,
		 MAX(CASE WHEN NumParte = 11 THEN Parte END) AS MedPago,
		 MAX(CASE WHEN NumParte = 12 THEN Parte END) AS Empl,
		 MAX(CASE WHEN NumParte = 13 THEN Parte END) AS IdPago
	FROM TabParseada
	GROUP BY ID

	DROP TABLE #TmpVentas

	INSERT INTO Person.TipoCliente(Descripcion)
	SELECT DISTINCT (TipoClien)
	FROM @TabPartesPorVenta
	WHERE NOT EXISTS(SELECT 1 FROM Person.TipoCliente WHERE Descripcion = TipoClien)

	INSERT INTO Sales.TipoFactura(TipoFac)
	SELECT DISTINCT(TipoFact)
	FROM @TabPartesPorVenta
	WHERE NOT EXISTS(SELECT 1 FROM Sales.TipoFactura WHERE TipoFac = TipoFact);

	INSERT INTO Sales.Pago(NroPago, Monto, IdMedPago)
	SELECT v.IdPago, Cant*PrecUni, mp.IdMedPago
	FROM @TabPartesPorVenta v 
		INNER JOIN Sales.Mediopago mp ON v.MedPago = mp.MedPagoAReemp
	WHERE NOT EXISTS(SELECT 1 FROM Sales.Pago WHERE NroPago = v.IdPago)

	INSERT INTO Sales.Venta(Fecha, Hora, IdSuc, IdEmp, IdPag, IdCli)
	SELECT v.Fecha, v.Hora, ts.IdSuc, te.IdEmp, tp.IdPago, c.IdCli
	FROM @TabPartesPorVenta v
		INNER JOIN Production.Sucursal ts ON v.Ciudad = ts.CiudadOrig
		INNER JOIN Person.Empleado te ON v.Empl = te.Legajo
		INNER JOIN Sales.Pago tp ON v.IdPago = tp.NroPago
		INNER JOIN Person.TipoCliente tc ON tc.Descripcion = v.TipoClien
		INNER JOIN Person.Cliente c ON c.IdTipoCli = tc.IdTipoCli
	WHERE NOT EXISTS(SELECT 1 FROM Sales.Venta WHERE NroVenta = v.IdPago)
	
	INSERT INTO Sales.Factura(NroFact, IdTipoFac, FechaEmision, Total, IdVent)
	SELECT IdFact, tf.IdTipoFac, v.Fecha, Cant*PrecUni, tv.IdVenta
	FROM @TabPartesPorVenta v 
		INNER JOIN Sales.TipoFactura tf ON v.TipoFact = tf.TipoFac 
		INNER JOIN Sales.Venta tv ON v.ID = tv.IdVenta
	WHERE NOT EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = IdFact)

	INSERT INTO Sales.DetalleVenta(Cantidad, Subtotal, IdVenta, IdProd)
	SELECT Cant, Cant*PrecUni, tv.IdVenta, tp.IdProd
	FROM @TabPartesPorVenta v JOIN Production.Producto tp ON v.Prod = tp.Descripcion
		JOIN Sales.Venta tv ON v.ID = tv.IdVenta 

	UPDATE pd
	SET pd.CantVendida =  pd.CantVendida + dv.Cantidad
	FROM Production.Producto pd
	INNER JOIN sales.detalleVenta dv ON pd.IdProd = dv.IdProd 

	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPORTAR PRODUCTOS DE VENTAS_REGISTRADAS.CSV'
END
GO