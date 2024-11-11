------------------------------------------------------------------
--GRUPO: 14
--BASUALDO, NICOLÁS NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LEÓN 45040212
----------------------------------------------------------------

-------------------------------------------------------
------------------ CREACIÓN DE BBDD -------------------
-------------------------------------------------------
-- ENUNCIADO: Cree la base de datos --

CREATE DATABASE Com5600G14 COLLATE Latin1_General_CI_AS
GO

USE Com5600G14
GO

-------------------------------------------------------
---------------- CREACIÓN DE ESQUEMAS -----------------
-------------------------------------------------------
-- ENUNCIADO: Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto en la creación de objetos. NO use el esquema "dbo" --

CREATE SCHEMA ddbba;
GO
CREATE SCHEMA Production;
GO
CREATE SCHEMA Sales;
GO
CREATE SCHEMA Person;
GO

-------------------------------------------------------
----------------- CREACIÓN DE TABLAS ------------------
-------------------------------------------------------
-- ENUNCIADO: Cree entidades y relaciones. Incluya restricciones y claves. 

CREATE TABLE ddbba.Registro
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	FechaHora DATETIME DEFAULT GETDATE(),
	Texto VARCHAR(MAX),
	Modulo CHAR(1) NOT NULL,

	CONSTRAINT CK_Mod CHECK (Modulo IN ('I', 'D', 'U'))
);


CREATE TABLE Production.Sucursal
(
	IdSuc INT IDENTITY(10,1) PRIMARY KEY,
	Direccion VARCHAR(50),
	Localidad CHAR(20),
	Provincia VARCHAR(24),
	Horario VARCHAR(25),
	Telefono INT,
	CiudadOrig CHAR(10),
	Baja DATE DEFAULT NULL
);

CREATE TABLE Production.LineaProducto
(
	IdLinProd INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(36),
	Prod VARCHAR(40),
	Baja DATE DEFAULT NULL
);

CREATE TABLE Production.Producto
(
	IdProd INT IDENTITY(1,1) PRIMARY KEY,
	IdLinProd INT NOT NULL,
	CantIngresada INT,
	CantVendida INT DEFAULT 0,
	NomProd VARCHAR(40),
	Descripcion VARCHAR(90),
	Proveedor CHAR(40),
	PrecioUnit DECIMAL(7,2) NOT NULL,
	RefPrecio DECIMAL(7,2),
	RefPeso CHAR(20),
	FechaIng DATE,
	Baja DATE DEFAULT NULL,

	CONSTRAINT FK_Cat FOREIGN KEY (IdLinProd)
		REFERENCES Production.LineaProducto(IdLinProd)
);

CREATE TABLE Person.Empleado
(
	IdEmp INT IDENTITY(1,1) PRIMARY KEY,
	IdSuc INT NOT NULL,
	Legajo INT UNIQUE NOT NULL,
	DNI INT UNIQUE NOT NULL,
	Nombre CHAR(30) NOT NULL,
	Apellido CHAR(20) NOT NULL,
	Direccion VARCHAR(50),
	Localidad VARCHAR(40),
	Provincia VARCHAR(40),
	EmailPersona VARCHAR(100),
	EmailEmpresarial VARCHAR(100),
	Cargo VARCHAR(25),
	Turno CHAR(2),
	Baja DATE DEFAULT NULL,

	CONSTRAINT FK_IdSuc FOREIGN KEY (IdSuc)
		REFERENCES Production.Sucursal (IdSuc),
	CONSTRAINT CK_Legajo CHECK (Legajo BETWEEN 100000 AND 999999),	--VERIFICA QUE HAYA 6 DIGITOS
	CONSTRAINT CK_Turno CHECK (Turno IN ('TM', 'TT', 'TN', 'JC'))
);

CREATE TABLE Person.TipoCliente
(
	IdTipoCli INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion CHAR(10)
);

CREATE TABLE Sales.Mediopago
(
	IdMedPago INT IDENTITY(1,1) PRIMARY KEY,
	MedPagoAReemp CHAR(10),
	Descripcion CHAR(15),
	Vigencia DATE DEFAULT GETDATE(),
	Baja DATE DEFAULT NULL
);

CREATE TABLE Sales.Pago
(
	IdPago INT IDENTITY(1,1) PRIMARY KEY,
	NroPago VARCHAR(50) UNIQUE,	--0000003100099475144530
	IdMedPago INT NOT NULL,
	Monto NUMERIC(7,2) NOT NULL,
	Estado CHAR(10) DEFAULT 'ACREDITADO',
	FechaEstado DATE DEFAULT GETDATE(),
	
	CONSTRAINT FK_MedPag FOREIGN KEY (IdMedPago)
		REFERENCES Sales.Mediopago(IdMedPago),
	CONSTRAINT CK_EstadoPago CHECK (Estado IN ('ACREDITADO', 'ANULADO'))
);

CREATE TABLE Sales.Venta
(
	IdVenta INT IDENTITY(1,1) PRIMARY KEY,
	NroVenta INT UNIQUE,
	Fecha DATE NOT NULL,
	Hora TIME NOT NULL,
	IdSuc INT NOT NULL,
	IdEmp INT NOT NULL,
	IdPag INT NOT NULL,
	Estado CHAR(7) DEFAULT 'ACTIVA',
	FechaEstado DATE DEFAULT GETDATE(),
	IdTipoCli INT NOT NULL,
	GeneroCli CHAR(6) NOT NULL,

	CONSTRAINT FK_Suc FOREIGN KEY (IdSuc)
		REFERENCES Production.Sucursal (IdSuc),
	CONSTRAINT FK_Emp FOREIGN KEY (IdEmp)
		REFERENCES Person.Empleado (IdEmp),
	CONSTRAINT FK_Pag FOREIGN KEY (IdPag)
		REFERENCES Sales.Pago (IdPago),
	CONSTRAINT CK_EstadoVenta CHECK (Estado IN ('ACTIVA', 'ANULADA')),
	CONSTRAINT FK_TipoC FOREIGN KEY (IdTipoCli)
		REFERENCES Person.TipoCliente(IdTipoCli),
	CONSTRAINT CK_Gen CHECK (GeneroCli IN ('Female', 'Male'))
);

CREATE TABLE Sales.DetalleVenta
(
	IdDetalle INT IDENTITY(1,1) PRIMARY KEY,
	Cantidad INT,
	Subtotal NUMERIC(7,2),
	IdVenta INT NOT NULL,
	IdProd INT NOT NULL,

	CONSTRAINT FK_Venta FOREIGN KEY (IdVenta)
		REFERENCES Sales.Venta (IdVenta),
	CONSTRAINT FK_Prod FOREIGN KEY (IdProd)
		REFERENCES Production.Producto(IdProd)
);

CREATE TABLE Sales.TipoFactura
(
	IdTipoFac INT IDENTITY(1,1) PRIMARY KEY,
	TipoFac CHAR(1),
	Descripcion CHAR(10),
	Vigencia DATE DEFAULT GETDATE(),
	Baja DATE DEFAULT NULL
);

CREATE TABLE Sales.Factura
(
	IdFact INT IDENTITY(1,1) PRIMARY KEY,
	NroFact INT UNIQUE,
	IdTipoFac INT NOT NULL,
	FechaEmision DATE NOT NULL,
	Total NUMERIC(7,2),
	IdVent INT NOT NULL,
	Baja DATE DEFAULT NULL,

	CONSTRAINT CK_NFac CHECK(NroFact BETWEEN 100000000 AND 999999999), --PARA QUE VERIFIQUE QUE HAYA 9 DIGITOS
	CONSTRAINT FK_TipoF FOREIGN KEY (IdTipoFac)
		REFERENCES Sales.TipoFactura (IdTipoFac),
	CONSTRAINT FK_Vent FOREIGN KEY (IdVent)
		REFERENCES Sales.Venta (IdVenta)
);
GO

-------------------------------------------------------
------------- CREACION DE STORE PROCEDURE -------------
-------------------------------------------------------
-- ENUNCIADO: Genere store procedures para manejar la inserción, modificado, borrado de cada tabla. --


--- PARA TABLA REGISTRO ---
CREATE OR ALTER PROCEDURE ddbba.InsertReg 
	@Mod CHAR(1),
	@Txt VARCHAR(MAX)
AS
BEGIN
	IF(@Txt = '')
	BEGIN
		SET @Txt = 'N/A'
	END

	SET @Mod = UPPER(@Mod)

	INSERT INTO ddbba.Registro(Modulo, Texto)
	VALUES (@Mod, @Txt)
END
GO


--- PARA TABALA SUCURSAL ---
CREATE OR ALTER PROCEDURE Production.InsertSucursal
	@Direccion VARCHAR(40),
	@Ciudad CHAR(12),
	@Provincia VARCHAR(24),
	@Horario VARCHAR(25),
	@Telefono INT
AS
BEGIN
	INSERT INTO Production.Sucursal(Direccion, Localidad, Provincia, Horario, Telefono)
	VALUES(@Direccion, @Ciudad, @Provincia, @Horario, @Telefono)

	EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA SUCURSAL' 
END
GO

CREATE OR ALTER PROCEDURE Production.DeleteSucursal	-- BORRADO L?GICO
	@IdSuc INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		UPDATE Production.Sucursal
		SET Baja = GETDATE()
		WHERE IdSuc = @IdSuc

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO EN TABLA SUCURSAL'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA SUCURSAL' 
END
GO

CREATE OR ALTER PROCEDURE Production.UpdateUbicacionSucursal
	@IdSuc INT,
	@DireccionN VARCHAR(50),
	@LocalidadN VARCHAR(20),
	@ProvinciaN Varchar(24)

AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		UPDATE Production.Sucursal
		SET Provincia = @ProvinciaN, Localidad = @LocalidadN, Direccion = @DireccionN
		WHERE IdSuc = @IdSuc

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR REGISTRO EN TABLA SUCURSAL'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ERROR DE ID PARA ACTUALIZAR REGISTRO EN TABLA SUCURSAL' 
END
GO


---PARA TABLA LINEA PRODUCTO---
CREATE OR ALTER PROCEDURE Production.InsertLienaProd
	@Descripcion CHAR(20)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)

	IF NOT EXISTS (SELECT 1 FROM Production.LineaProducto WHERE Descripcion = @Descripcion)
	BEGIN
		INSERT INTO Production.LineaProducto (Descripcion)
		VALUES(@Descripcion)

		EXEC ddbba.InsertReg @Mod='I', @Txt = N'INSERTAR REGISTRO EN TABLA LINEA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='I', @Txt = N' ERROR EN INSERTAR REGISTRO EN TABLA LINEA PRODUCTO / CATEGORIA DUPLICADA'
END
GO

CREATE OR ALTER PROCEDURE Production.DeleteLienaProd	--BORRADO L?GICO
	@IdLin INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.LineaProducto WHERE IdLinProd = @IdLin)
	BEGIN
		UPDATE Production.LineaProducto
		SET Baja = GETDATE()
		WHERE IdLinProd = @IdLin

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO EN TABLA LINEA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = N'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA LINEA PRODUCTO' 
END
GO

CREATE OR ALTER PROCEDURE Production.UpdateDescLinea
	@IdLin INT,
	@DescN CHAR(20)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.LineaProducto WHERE IdLinProd = @IdLin)
	BEGIN
		UPDATE Production.LineaProducto
		SET Descripcion = @DescN
		WHERE IdLinProd = @IdLin

		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO' 
END
GO


--- PARA TABLA PRODUCTO ---
CREATE OR ALTER PROCEDURE Production.InsertProd
	@Descripcion CHAR(40),
	@CantIngreso INT,
	@IdLinProd INT,
	@Proveedor CHAR(40),
	@PrecioUnit DECIMAL(7,2)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)

	IF NOT EXISTS (SELECT 1 FROM Production.Producto WHERE Descripcion = @Descripcion) 
		AND EXISTS (SELECT 1 FROM Production.LineaProducto WHERE IdLinProd = @IdLinProd)
	BEGIN
		INSERT INTO Production.Producto(CantIngresada, Descripcion, IdLinProd, Proveedor, PrecioUnit) 
		VALUES(@CantIngreso, @Descripcion, @IdLinProd, @Proveedor, @PrecioUnit)
	
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA PRODUCTO'
END
GO

CREATE OR ALTER PROCEDURE Production.DeleteProd		--BORRADO L?GICO
	@IdProd INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Production.Producto WHERE IdProd = @IdProd)
	BEGIN
		UPDATE Production.Producto
		SET Baja = GETDATE()
		WHERE IdProd = @IdProd

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO REGISTRO EN TABLA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA PRODUCTO'
END
GO

CREATE OR ALTER PROCEDURE Production.UpdatePriceProd
	@IdProd INT,
	@PriceN DECIMAL(7,2)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Production.Producto WHERE IdProd = @IdProd)
	BEGIN
		UPDATE Production.Producto
		SET PrecioUnit = @PriceN
		WHERE IdProd = @IdProd

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR PRECIO DE REGISTRO EN TABLA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA PRODUCTO'
END
GO

CREATE OR ALTER PROCEDURE Production.UpdateCantIngresadaProd
	@IdProd INT,
	@CantIng INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Production.Producto WHERE IdProd = @IdProd)
	BEGIN
		UPDATE Production.Producto
		SET CantIngresada = @CantIng
		WHERE IdProd = @IdProd

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR CANTIDAD INGRESADA DE REGISTRO EN TABLA PRODUCTO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA PRODUCTO'
END
GO


--- PARA TABLA EMPLEADO ---
CREATE OR ALTER PROCEDURE Person.InsertEmp
	@Legajo INT,
	@IdSuc INT,
	@DNI INT,
	@Nombre CHAR(30),
	@Apellido CHAR(20),
	@EmailPersona VARCHAR(100),
	@EmailEmpresarial VARCHAR(100),
	@Cargo VARCHAR(25),
	@Turno CHAR(2)
AS
BEGIN
	IF (@Legajo >= 100000 AND @Legajo <= 999999) 
		AND NOT EXISTS (SELECT 1 FROM Person.Empleado WHERE Legajo = @Legajo)
		AND EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		INSERT INTO Person.Empleado (Legajo, IdSuc, DNI, Nombre, Apellido, EmailPersona, EmailEmpresarial, Cargo, Turno)
		VALUES(@Legajo, @IdSuc, @DNI, @Nombre, @Apellido, @EmailPersona, @EmailEmpresarial, @Cargo, @Turno)
	
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA EMPLEADO' 
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA EMPLEADO'
END
GO

CREATE OR ALTER PROCEDURE Person.DeleteEmp	--BORRADO L?GICO
	@Legajo INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Person.Empleado WHERE Legajo = @Legajo)
	BEGIN
		UPDATE Person.Empleado
		SET Baja = GETDATE()
		WHERE Legajo = @Legajo

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO EN REGISTRO EN TABLA EMPLEADO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA EMPLEADO'
END
GO


---PARA TABLA TIPO CLIENTE---
CREATE OR ALTER PROCEDURE Person.InsertTipoCli
	@Desc CHAR(10)
AS
BEGIN
	SET @Desc = UPPER(@Desc)
	
	IF NOT EXISTS (SELECT 1 FROM Person.TipoCliente WHERE Descripcion = @Desc)
	BEGIN
		INSERT INTO Person.TipoCliente (Descripcion)
		VALUES (@Desc)

 	EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA TIPO CLIENTE'
END
	ELSE
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TIPO CLIENTE / TIPO CLIENTE EXISTENTE'
END
GO

CREATE OR ALTER PROCEDURE Person.DeleteTipoCli	--BORRADO LOGICO
	@IdTCli INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Person.TipoCliente WHERE IdTipoCli = @IdTCli)	
	BEGIN
		UPDATE Person.Cliente
		SET Baja = GETDATE()
		WHERE IdTipoCli = @IdTCli
		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO DE REGISTRO EN TABLA TIPO CLIENTE'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA TIPO CLIENTE'
END
GO


--- TABLA TIPO DE FACTURA ---
CREATE OR ALTER PROCEDURE Sales.InsertTipoFac
	@TipFac CHAR(1),
	@Desc CHAR(10)
AS
BEGIN
	SET @TipFac = UPPER(@TipFac);
	SET @Desc = UPPER(@Desc);
	
	IF NOT EXISTS(SELECT 1 FROM Sales.TipoFactura WHERE TipoFac = @TipFac AND Descripcion = @Desc)	--VERIFICAR SI YA ESTA INSERTADO
	BEGIN
		INSERT INTO Sales.TipoFactura (TipoFac, Descripcion)
		VALUES (@TipFac, @Desc)

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA TIPO FACTURA'
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR A INSERTAR REGISTRO EN TABLA TIPO FACTURA / TIPO DE FACTURA REPETIDA'
	END
END
GO

CREATE OR ALTER PROCEDURE Sales.DeleteTipoFac
	@IdTipFac INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.TipoFactura WHERE IdTipoFac = @IdTipFac)
		BEGIN
			UPDATE Sales.TipoFactura
			SET Baja = GETDATE()
			WHERE IdTipoFac = @IdTipFac

			EXEC ddbba.InsertReg @Mod='D', @Txt = 'ELIMINAR REGISTRO EN TABLA TIPO FACTURA'
		END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ELIMINAR REGISTRO EN TABLA TIPO FACTURA / ID DE TIPO FACTURA ERRONEO'
END
GO

---TABLA FACTURA---
CREATE OR ALTER PROCEDURE Sales.InsertFactura
	@NroFactura INT,
	@TipoFac INT,
	@Fecha DATE,
	@Monto NUMERIC(7,2),
	@NroVent INT
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFactura) 
		AND EXISTS(SELECT 1 FROM Sales.TipoFactura WHERE IdTipoFac = @TipoFac)
		AND EXISTS(SELECT 1 FROM Sales.Venta WHERE NroVenta = @NroVent)
		BEGIN
			DECLARE @IdVent INT = (SELECT IdVenta FROM Sales.Venta WHERE NroVenta = @NroVent)
		
			INSERT INTO Sales.Factura (NroFact, IdTipoFac, FechaEmision, Total, IdVent)
			VALUES (@NroFactura, @TipoFac, @Fecha, @Monto, @IdVent)

			EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA FACTURA'
		END
	ELSE
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA FACTURA'
END
GO

CREATE OR ALTER PROCEDURE Sales.DeleteFactura	--BORRADO LÓGICO
	@NroFactura INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFactura)
	BEGIN
		UPDATE Sales.Factura
		SET Baja = GETDATE()
		WHERE NroFact = @NroFactura

		EXEC ddbba.InsertReg @Mod='D', @Txt = 'BORRADO LOGICO DE REGISTRO EN TABLA FACTURA'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN BORRAR REGISTRO EN TABLA TIPO FACTURA / NRO DE FACTURA ERRONEO'
END
GO


---PARA TABLA MEDIO DE PAGO---
CREATE OR ALTER PROCEDURE Sales.InsertMedPag
	@Desc CHAR(15)
AS
BEGIN
	SET @Desc = UPPER(@Desc);

	IF NOT EXISTS (SELECT 1 FROM Sales.Mediopago WHERE Descripcion = @Desc)
	BEGIN
		INSERT INTO Sales.Mediopago (Descripcion)
		VALUES (@Desc)

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA MEDIO DE PAGO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = N'ERROR EN INSERTAR REGISTRO EN TABLA MEDIO DE PAGO / DESCRIPCIÓN DUPLICADA'
END
GO

CREATE OR ALTER PROCEDURE Sales.DeleteMedPag	--BORRADO LÓGICO
	@IdMedPag INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.Mediopago WHERE IdMedPago = @IdMedPag)
	BEGIN
		UPDATE Sales.Mediopago
		SET Baja = GETDATE()
		WHERE IdMedPago = @IdMedPag

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LÓGICO REGISTRO EN TABLA MEDIO DE PAGO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA MEDIO DE PAGO'
END
GO


---PARA TABLA PAGO---
CREATE OR ALTER PROCEDURE Sales.InsertPago
	@NroPago BIGINT,
	@Monto NUMERIC(7,2),
	@MedPago INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Sales.Mediopago WHERE IdMedPago = @MedPago)
		AND NOT EXISTS(SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)
	BEGIN
		INSERT INTO Sales.Pago (NroPago, Monto, IdMedPago)
		VALUES (@NroPago, @Monto, @MedPago)

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA PAGO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA PAGO / ID DE MEDIO DE PAGO INVALIDO'
END
GO

CREATE OR ALTER PROCEDURE Sales.UpdateEstadoPago
	@IdPago INT,
	@Estado CHAR(10)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Sales.Pago WHERE IdPago = @IdPago) AND (@Estado IN ('ACREDITADO', 'ANULADO'))
	BEGIN
		UPDATE Sales.Pago
		SET Estado = @Estado, FechaEstado = GETDATE()
		WHERE IdPago = @IdPago

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR ESTADO DE REGISTRO EN TABLA PAGO'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN ACTUALIZAR REGISTRO EN TABLA PAGO / ID INVÁLIDO'
END
GO


---TABLA VENTA---
CREATE OR ALTER PROCEDURE Sales.InsertVenta
	@NroVenta INT,
	@IdSuc INT,
	@IdEmp INT,
	@NroPago INT,
	@TipoCli INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Sales.Venta WHERE NroVenta = @NroVenta)
		AND EXISTS (SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)
		AND EXISTS (SELECT 1 FROM Person.Empleado WHERE IdEmp = @IdEmp)
		AND EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		DECLARE @IdPag INT = (SELECT IdPago FROM Sales.Pago WHERE NroPago = @NroPago)

		INSERT INTO Sales.Venta (NroVenta, IdSuc, IdEmp, IdPag, IdTipoCli)
		VALUES (@NroVenta, @IdSuc, @IdEmp, @NroPago, @TipoCli)

		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'INSERTAR REGISTRO EN TABLA VENTA'
	END
	ELSE
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA VENTA'
END
GO

CREATE OR ALTER PROCEDURE Sales.UpdateEstadoVenta
	@NroVenta INT,
	@EstadoVenta CHAR(7)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Sales.Venta WHERE NroVenta = @NroVenta)
	BEGIN
		UPDATE Sales.Venta
		SET Estado = @EstadoVenta, FechaEstado = GETDATE()
		WHERE NroVenta = @NroVenta

		EXEC ddbba.InsertReg @Mod = 'U', @Txt = 'ACTUALIZAR ESTADO DE REGISTRO EN TABLA VENTA'

		DECLARE @EstadoPago CHAR(10);
		SET @EstadoPago =
			CASE
				WHEN @EstadoVenta = 'ANULADA' THEN 'ANULADO'
			END;

		--ACTUALIZACIÓN EN TABLA PAGO--
		DECLARE @IdPag INT = (SELECT IdPag FROM Sales.Venta WHERE NroVenta = @NroVenta);

		EXEC Sales.UpdateEstadoPago @IdPago = @IdPag, @Estado = @EstadoPago;

		--ELIMINAR FACTURA EN TABLA FACTURA--
		DECLARE @NroFact INT = (SELECT f.NroFact
								FROM Sales.Factura f
									INNER JOIN Sales.Venta v ON v.IdVenta = f.IdVent
								WHERE v.NroVenta = @NroVenta);
		
		EXEC Sales.DeleteFactura @NroFactura = @NroFact;
	END
	ELSE
		EXEC ddbba.InsertReg @Mod = 'U', @Txt = 'ERROR EN ACTUALIZAR ESTADO DE REGISTRO EN TABLA VENTA'
END
GO


--- TABLA DETALLE VENTA ---
CREATE OR ALTER PROCEDURE Sales.InsertDetVenta
	@CantCompra INT,
	@Subtotal NUMERIC(7,2),
	@NroVenta INT,
	@IdProd INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Sales.Venta WHERE NroVenta = @NroVenta)
		AND EXISTS (SELECT 1 FROM Production.Producto WHERE IdProd = @IdProd)
	BEGIN
		DECLARE @IdVenta INT = (SELECT IdVenta FROM Sales.Venta WHERE NroVenta = @NroVenta)

		INSERT INTO Sales.DetalleVenta (Cantidad, Subtotal, IdVenta, IdProd)
		VALUES (@CantCompra, @Subtotal, @IdVenta, @IdProd)

		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'INGRESAR REGISTRO EN TABLA DETALLE VENTA' 

		--ACTUALIZACIÓN EN TABLA PRODUCTO--
		UPDATE Production.Producto
		SET CantVendida = CantVendida + @CantCompra
		WHERE IdProd = @IdProd

		DECLARE @CADENA VARCHAR(MAX)
		SET @CADENA = (SELECT N'ACTUALIZACIÓN DE CANTIDAD DE PRODUCTO ' + CAST(IdProd AS VARCHAR(10)) FROM Production.Producto WHERE IdProd = @IdProd)

		EXEC ddbba.InsertReg @Mod='U', @Txt = @CADENA
	END
	ELSE
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INGRESAR REGISTRO EN TABLA DETALLE VENTA' 
END
GO

-------------------------------------------------------
----------------- CREACIÓN DE INDICES -----------------
-------------------------------------------------------
-- AYUDA A LOS UPDATE Y CONSULTAS DE LOS SP

CREATE NONCLUSTERED INDEX IX_Sucursal_Ubicacion_Estado
ON Production.Sucursal (Localidad) INCLUDE (Direccion, Provincia, Baja)
WITH (FILLFACTOR = 90);	-- NO HAY MUCHO CAMBIO EN LA TABLA

CREATE UNIQUE NONCLUSTERED INDEX IX_Empleado_NroEmp_Estado
ON Person.Empleado (Legajo) INCLUDE (Baja)
WITH (FILLFACTOR = 80);	-- NO HAY MUCHO CAMBIO EN LA TABLA

CREATE UNIQUE NONCLUSTERED INDEX IX_Factura_NroFact_Estado
ON Sales.Factura (NroFact) INCLUDE (Baja)
WITH (FILLFACTOR = 70);	--HAY MAYOR CANTIDAD DE CAMBIOS

CREATE UNIQUE NONCLUSTERED INDEX IX_Pago_NroPago_Estado
ON Sales.Pago (NroPago) INCLUDE (Estado, FechaEstado)
WITH (FILLFACTOR = 70);	--HAY MAYOR CANTIDAD DE CAMBIOS

CREATE UNIQUE NONCLUSTERED INDEX IX_Venta_NroVenta_Estado
ON Sales.Venta (NroVenta) INCLUDE (Estado, FechaEstado)
WITH (FILLFACTOR = 70);	--HAY MAYOR CANTIDAD DE CAMBIOS
GO

USE Com5600G14;

SELECT 
    f.NroFact AS "Factura ID",
    tf.TipoFac AS "Tipo de Factura",
    s.Localidad AS "Ciudad",
    tc.Descripcion AS "Tipo de Cliente",
    v.GeneroCli AS "Género",
    lp.Descripcion AS "Línea de Producto",
    p.NomProd AS "Producto",
    p.PrecioUnit AS "Precio Unitario",
    dv.Cantidad AS "Cantidad",
    v.Fecha AS "Fecha",
    v.Hora AS "Hora",
    mp.Descripcion AS "Medio de Pago",
    s.Direccion AS "Sucursal"
FROM Sales.Factura f
	JOIN Sales.TipoFactura tf ON f.IdTipoFac = tf.IdTipoFac
	JOIN Sales.Venta v ON f.IdVent = v.IdVenta
	JOIN Person.TipoCliente tc ON v.IdTipoCli = tc.IdTipoCli
	JOIN Production.Sucursal s ON v.IdSuc = s.IdSuc
	JOIN Sales.Pago pag ON v.IdPag = pag.IdPago
	JOIN Sales.Mediopago mp ON pag.IdMedPago = mp.IdMedPago
	JOIN Sales.DetalleVenta dv ON v.IdVenta = dv.IdVenta
	JOIN Production.Producto p ON dv.IdProd = p.IdProd
	JOIN Production.LineaProducto lp ON p.IdLinProd = lp.IdLinProd
WHERE v.Estado = 'ACTIVA' 
ORDER BY  v.Fecha, v.Hora;

--DROP DATABASE COM5600G14