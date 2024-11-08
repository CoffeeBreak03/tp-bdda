USE Com5600G14
GO

-------------------------------------------------------
---------------- IMPORTACI�N DE DATOS -----------------
-------------------------------------------------------

--- ARCHIVO CATALOGO.CSV ---
CREATE OR ALTER FUNCTION ddbba.ParseLineaCSV(@linea NVARCHAR(MAX), @separador CHAR(1))
RETURNS @TablaDiv TABLE (
	Parte NVARCHAR(MAX),
	NumParte INT
	)
AS
BEGIN
		DECLARE @actPos INT = 1,
				@parte NVARCHAR(MAX) = '',--INICIALIZO LA PARTE EN VAC�O
				@Comillas BIT = 0,
				@NumParte INT = 1;

	WHILE @actPos <= LEN(@linea)
	BEGIN
		DECLARE @actualLetra CHAR(1) = SUBSTRING(@linea, @actPos, 1);

		-- CAMBIO EL ESTADO DE @Comillas CUANDO ENCUENTRA UNA COMILLA DOBLE
		IF @actualLetra = '"'
		BEGIN
			SET @Comillas = ~@Comillas; -- ALTERNA ENTRO DENTRO Y FUERA DE COMILLAS.
		END
		ELSE 
		BEGIN
			IF @actualLetra = '_'
			BEGIN
				SET @actualLetra = REPLACE(@actualLetra, '_', '  ');
				SET @parte = @parte + @actualLetra;-- CONCATENO LA LETRA A LA PARTE
			END
			ELSE
			BEGIN
				IF @actualLetra = @separador AND @Comillas = 0
				BEGIN
	-- AL ENCONTRAR EL SEPARADOR FUERA DE COMILLAS EMPIEZA NUEVO CAMPO (PARTE)
					INSERT INTO @TablaDiv (Parte, NumParte) 
					VALUES (LTRIM(RTRIM(@parte)), @NumParte);
					SET @parte = ''; -- REINICIO @parte
					SET @NumParte = @NumParte + 1; -- INCREMENTO EL NUMERO DE PARTE
				END
				ELSE
				BEGIN
				-- CONCATENO LA LETRA A LA PARTE
					SET @parte = @parte + @actualLetra;
				END
			END
		END
			SET @actPos = @actPos + 1;
	END

		-- INSERTA EL REGISTRO QUE QUEDA AL FINAL (FECHA INGRESO) YA QUE NO LLEGA AL SEPARADOR PARA INSERTAR EN LA CONDICI�N
	IF LEN(@parte) > 0 OR @actualLetra = @separador
		INSERT INTO @TablaDiv (Parte, NumParte) VALUES (LTRIM(RTRIM(@parte)), @NumParte);
	RETURN;
END;
GO

CREATE OR ALTER PROCEDURE Production.ImportCatalogo
AS
BEGIN
	CREATE TABLE #TmpCatalogo
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	BULK INSERT #TmpCatalogo
	FROM 'E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Productos\catalogo.csv'
	WITH(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		CODEPAGE = '65001',
		FIRSTROW = 2
	);

	WITH TabResultante AS(
		SELECT MAX(CASE WHEN NumParte = 1 THEN Parte END) AS LinProd
		FROM #TmpCatalogo
		CROSS APPLY ddbba.ParseLineaCSV(TEXTO, ',')
		GROUP BY ID
	)
	INSERT INTO Production.LineaProducto(Descripcion)
	SELECT DISTINCT(LinProd)
	FROM TabResultante
	WHERE NOT EXISTS(SELECT 1 FROM Production.LineaProducto WHERE Descripcion = LinProd);

	WITH TablaParseada AS(
		SELECT ID, Parte, NumParte
		FROM #TmpCatalogo
		CROSS APPLY ddbba.ParseLineaCSV(TEXTO, ',')
	),
	DetProd AS(
		SELECT 
			MAX(CASE WHEN tp.NumParte = 1 THEN lp.IdLinProd END) AS LinProd,
			MAX(CASE WHEN tp.NumParte = 2 THEN tp.Parte END) AS Descripcion,
			MAX(CASE WHEN tp.NumParte = 3 THEN TRY_CAST(tp.Parte AS NUMERIC(7,2)) END) AS Precio,
			MAX(CASE WHEN tp.NumParte = 4 THEN TRY_CAST(tp.Parte AS NUMERIC(7,2)) END) AS RefPrecio,
			MAX(CASE WHEN tp.NumParte = 5 THEN tp.Parte END) AS RefPeso,
			MAX(CASE WHEN tp.NumParte = 6 THEN TRY_CAST(tp.Parte AS DATE) END) AS FechaIng
		FROM TablaParseada tp
			LEFT JOIN Production.LineaProducto lp ON tp.Parte = lp.Descripcion
		GROUP BY ID
	)
	INSERT INTO Production.Producto (IdLinProd, CantIngresada, CantVendida, Descripcion, Proveedor, PrecioUnit, RefPrecio, RefPeso, FechaIng)
	SELECT LinProd, 0, 0, Descripcion, 'No especificado', Precio, RefPrecio, RefPeso, FechaIng
	FROM DetProd

	DROP TABLE #TmpCatalogo;
	
	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE CATALOGO.CSV'
END
GO
--EXEC Production.ImportCatalogo
--SELECT * FROM Production.Producto


--- ARCHIVO Electronic accessories.xsls ---
CREATE OR ALTER PROCEDURE Production.ImportElectrodomesticos
AS
BEGIN
	DECLARE @DescCategoria CHAR(16) = 'Electrodom�stico'

	EXEC Production.InsertLienaProd @Descripcion = @DescCategoria;	-- SOLO LO INSERTO LA PRIMERA VEZ

	DECLARE @IdCat INT = (SELECT IdLinProd FROM Production.LineaProducto WHERE Descripcion = @DescCategoria);

	INSERT INTO Production.Producto (IdLinProd, CantIngresada, CantVendida, Descripcion, Proveedor, PrecioUnit, RefPrecio, RefPeso, FechaIng)
	SELECT @IdCat, 0, 0, "Product", 'No especificado', "Precio Unitario en Dolares", 0, 0, GETDATE()
	FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Productos\Electronic accessories.xlsx;HDR=YES;', 'SELECT * FROM [Sheet1$]')

	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE ELECTRONI ASCCESSORIES.XLSX'
END
GO

--EXEC Production.ImportElectrodomesticos
--SELECT * FROM Production.Producto WHERE IdLinProd IN (SELECT IdLinProd FROM Production.LineaProducto WHERE Descripcion = 'Electrodom�stico')


--- ARCHIVO Electronic accessories.xsls ---

CREATE OR ALTER FUNCTION ddbba.ParseExcelReg(@Cadena NVARCHAR(MAX))
	RETURNS @TablaDiv TABLE (
		Parte NVARCHAR(MAX),
		NumParte INT
	)
AS
BEGIN
	DECLARE @actPos INT = 1,
            @parte NVARCHAR(MAX) = '',	--INICIALIZO LA PARTE EN VAC�O
            @NumParte INT = 1;
	
	WHILE @actPos <= LEN(@Cadena)
    BEGIN
		DECLARE @actualLetra CHAR(1) = SUBSTRING(@Cadena, @actPos, 1);
		
		IF @actualLetra = '|'
		BEGIN
			INSERT INTO @TablaDiv (Parte, NumParte)
			VALUES (@parte, @NumParte);

			SET @parte = '';
			SET @NumParte = @NumParte + 1;
		END
		ELSE
		BEGIN
			SET @parte = @parte + @actualLetra;
		END

		SET @actPos = @actPos + 1;
	END

	IF LEN(@parte) > 0 OR @actualLetra = '|'
        INSERT INTO @TablaDiv (Parte, NumParte) VALUES (LTRIM(RTRIM(@parte)), @NumParte);
    RETURN;
END;
GO

CREATE OR ALTER FUNCTION ddbba.SepararCantidadReferenciaXLSX (@Cadena VARCHAR(30))
RETURNS @TablaRes TABLE (Cant INT, Ref VARCHAR(20))
AS
BEGIN
    DECLARE @Cantidad INT = NULL
    DECLARE @Referencia NVARCHAR(20)
    DECLARE @PrimeraParte NVARCHAR(50)
	DECLARE @Unidad VARCHAR(20)

    -- EXTRAIGO LA PRIMERA PARTE ANTES DEL ESPACIO Y LO QUE SIGUE
    SET @PrimeraParte = LEFT(@Cadena, CHARINDEX(' ', @Cadena + ' ') - 1);
	SET @Unidad = LTRIM(SUBSTRING(@Cadena, CHARINDEX(' ', @Cadena + ' ') + 1, LEN(@Cadena)))
    
    -- SI MI PRIMERA PARTE ES NUMERO Y LA SEGUNDA PARTE NO ES UNA UNIDAD DE PESO, ENTONCES LO GUARDO COMO CANTIDAD Y REFERENCIA
    IF ISNUMERIC(@PrimeraParte) = 1 AND LEFT(@Unidad, 1) <> 'g' AND LEFT(@Unidad, 2) <> 'kg' AND LEFT(@Unidad, 2) <> 'ml' AND LEFT(@Unidad, 2) <> 'cc' AND LEFT(@Unidad, 1) <> 'l'
    BEGIN
        SET @Cantidad = CAST(@PrimeraParte AS INT)
        
		IF SUBSTRING(@Unidad, 1, 1) = '-'
		BEGIN
			SET @Unidad = LTRIM(RTRIM( STUFF(@Unidad, 1, 1, ' ')))
		END
		
		SET @Referencia = @Unidad
    END
    ELSE
    BEGIN
        -- SI LA PRIMERA PARTE NO ES N�MERICA O S� PERO CON UNIDAD DE PESO AL LADO, SIGNIFICA QUE LA CADENA ES UNA REFERENCIA SIN CANTIDAD
        SET @Cantidad = 1
        SET @Referencia = @Cadena 
    END

    -- INSERTO LOS RESULTADOS
    INSERT INTO @TablaRes (Cant, Ref)
    VALUES (@Cantidad, @Referencia)
    
    RETURN
END
GO


--- ARCHIVO PRODUCTOS IMPORTADOS.XLSX ---
CREATE OR ALTER PROCEDURE Production.ImportProductosImportados
AS
BEGIN
	CREATE TABLE #TempProdImport
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	INSERT INTO #TempProdImport(TEXTO)
	SELECT NombreProducto + '|' + Proveedor + '|' + Categor�a + '|' + CantidadPorUnidad + '|' + TRY_CAST(PrecioUnidad  AS VARCHAR(10))
	FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Productos\Productos_importados.xlsx;HDR=YES;IMEX=1', 'SELECT * FROM [Listado de Productos$]');

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

--EXEC Production.ImportCatalogo
--EXEC Production.ImportElectrodomesticos
--EXEC Production.ImportProductosImportados

--SELECT * FROM Production.Producto

--DROP DATABASE Com5600G14


--- ARCHIVO INFORMACION COMPLEMETARIA.XLSX ---
--"E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Informacion_complementaria.xlsx"

CREATE OR ALTER FUNCTION ddbba.ParseUbicacion(@TEXTO VARCHAR(MAX))
RETURNS @TABLADIR TABLE (Direccion VARCHAR(50),
							Localidad VARCHAR(40),
							Provincia VARCHAR(40))
AS
BEGIN
	INSERT INTO @TABLADIR (Direccion, Localidad, Provincia)
	SELECT 
    LTRIM(RTRIM(SUBSTRING(@TEXTO, 1, CHARINDEX(',', @TEXTO) - 1))) AS DIRECCION_RESULTANTE,
    LTRIM(RTRIM(SUBSTRING(
        @TEXTO, 
        CHARINDEX(',', @TEXTO) + 1, 
        CHARINDEX(',', @TEXTO, CHARINDEX(',', @TEXTO) + 1) - CHARINDEX(',', @TEXTO) - 1
    ))) AS LOCALIDAD_RESULTANTE,
    LTRIM(RTRIM(SUBSTRING(
        @TEXTO, 
        CHARINDEX(',', @TEXTO, CHARINDEX(',', @TEXTO) + 1) + 1, 
        LEN(@TEXTO) - CHARINDEX(',', @TEXTO, CHARINDEX(',', @TEXTO) + 1)
    ))) AS PROVINCIA_RESULTANTE;

	RETURN;
END
GO

CREATE OR ALTER PROCEDURE Production.ImportInfoComp
AS
BEGIN
	CREATE TABLE #TempInfoCompImport
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		TEXTO NVARCHAR(MAX)
	);

	INSERT INTO #TempInfoCompImport(TEXTO)
	SELECT CIUDAD + '|' + "REEMPLAZAR POR" + '|' + DIRECCION + '|' + HORARIO + '|' + TRY_CAST(TELEFONO AS VARCHAR(10))
	FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'SELECT * FROM [sucursal$]');


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


	INSERT INTO #TempInfoCompImport(TEXTO)
	SELECT TRY_CAST("LEGAJO/ID" AS CHAR(6)) + '|' + NOMBRE + '|' + APELLIDO + '|' + TRY_CAST(TRY_CAST(DNI AS NUMERIC(8,0)) AS VARCHAR(8)) + '|' + DIRECCION + '|' + "EMAIL PERSONAL" + '|' + "EMAIL EMPRESA" + '|' + CARGO + '|' + SUCURSAL + '|' + TURNO
	FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'SELECT * FROM [Empleados$A1:K17];');

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

	INSERT INTO Sales.Mediopago(MedPagoAReemp, Descripcion)
	SELECT F2, F3
	FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'SELECT * FROM [medios de pago$];');


	INSERT INTO Production.LineaProducto (Descripcion, Prod)
	SELECT "L�NEA DE PRODUCTO", PRODUCTO
	FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'SELECT * FROM [Clasificacion productos$];'); 

	EXEC ddbba.InsertReg @Mod='I', @Txt = 'IMPOTAR PRODUCTOS DE INFORMACION_COMPLEMENTARIA.XLSX'
END
GO
--drop database com5600g14


--- ARCHIVO INFORMACION VENTAS_REGISTRADAS.CSV ---
CREATE OR ALTER PROCEDURE Production.ImportVentas
AS
BEGIN
	CREATE TABLE #TmpVentasIntermedio
	(
		TEXTO NVARCHAR(MAX)
	);

	BULK INSERT #TmpVentasIntermedio
	FROM 'E:\UNIVERSIDAD\BBDDAplicada\TP final\TP_integrador_Archivos\Ventas_registradas.csv' --CAMBIAR PATH POR PROPIO
	WITH(
		FIELDTERMINATOR = ';',
		ROWTERMINATOR = '0x0A',
		CODEPAGE = '65001',
		FIRSTROW = 2
	);

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

	INSERT INTO Sales.Venta(Fecha, Hora, IdSuc, IdEmp, IdPag, IdTipoCli, GeneroCli)
	SELECT v.Fecha, v.Hora, ts.IdSuc, te.IdEmp, tp.IdPago, tc.IdTipoCli, v.Genero
	FROM @TabPartesPorVenta v
		INNER JOIN Production.Sucursal ts ON v.Ciudad = ts.CiudadOrig
		INNER JOIN Person.Empleado te ON v.Empl = te.Legajo
		INNER JOIN Sales.Pago tp ON v.IdPago = tp.NroPago
		INNER JOIN Person.TipoCliente tc ON tc.Descripcion = v.TipoClien
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

