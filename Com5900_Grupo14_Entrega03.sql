------------------------------------------------------------------
--GRUPO: 14
--BASUALDO, NICOL�S NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LE�N 45040212
----------------------------------------------------------------

-------------------------------------------------------
------------------ CREACI�N DE BBDD -------------------
-------------------------------------------------------
-- ENUNCIADO: Cree la base de datos --

CREATE DATABASE Com5600G14 COLLATE Latin1_General_CI_AS
GO

USE Com5600G14
GO


-------------------------------------------------------
---------------- CREACI�N DE ESQUEMAS -----------------
-------------------------------------------------------
-- ENUNCIADO: Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto en la creaci�n de objetos. NO use el esquema "dbo" --

IF SCHEMA_ID('ddbba') IS NULL
	EXEC('CREATE SCHEMA ddbba');
GO

IF SCHEMA_ID('Production') IS NULL
	EXEC('CREATE SCHEMA Production');
GO

IF SCHEMA_ID('Sales') IS NULL
	EXEC('CREATE SCHEMA Sales');
GO

IF SCHEMA_ID('Person') IS NULL
	EXEC('CREATE SCHEMA Person');
GO

-------------------------------------------------------
----------------- CREACI�N DE TABLAS ------------------
-------------------------------------------------------
-- ENUNCIADO: Cree entidades y relaciones. Incluya restricciones y claves. 

IF OBJECT_ID('ddbba.Registro', 'U') IS NULL
BEGIN
	CREATE TABLE ddbba.Registro
	(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		FechaHora DATETIME DEFAULT GETDATE(),
		Texto VARCHAR(MAX),
		Modulo CHAR(1) NOT NULL,

		CONSTRAINT CK_Mod CHECK (Modulo IN ('I', 'D', 'U'))
	);
END

IF OBJECT_ID('Production.Sucursal', 'U') IS NULL
BEGIN
	CREATE TABLE Production.Sucursal
	(
		IdSuc INT IDENTITY(10,1) PRIMARY KEY,
		Direccion VARCHAR(50) NOT NULL,
		Localidad CHAR(20),
		Provincia VARCHAR(24),
		Horario VARCHAR(25),
		Telefono INT,
		CiudadOrig CHAR(10),
		Baja DATE DEFAULT NULL
	);
END

IF OBJECT_ID('Production.LineaProducto', 'U') IS NULL
BEGIN
	CREATE TABLE Production.LineaProducto
	(
		IdLinProd INT IDENTITY(1,1) PRIMARY KEY,
		Descripcion VARCHAR(36) NOT NULL,
		Vigencia DATE DEFAULT GETDATE(),
		Baja DATE DEFAULT NULL
	);
END

IF OBJECT_ID('Production.Producto', 'U') IS NULL
BEGIN
	CREATE TABLE Production.Producto
	(
		IdProd INT IDENTITY(1,1) PRIMARY KEY,
		IdLinProd INT NOT NULL,
		CantIngresada INT NOT NULL,
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
END

IF OBJECT_ID('Person.Empleado', 'U') IS NULL
BEGIN
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
END

IF OBJECT_ID('Person.TipoCliente', 'U') IS NULL
BEGIN
	CREATE TABLE Person.TipoCliente
	(
		IdTipoCli INT IDENTITY(1,1) PRIMARY KEY,
		Descripcion CHAR(10),
		Vigencia DATE DEFAULT GETDATE(),
		Baja DATE DEFAULT NULL
	);
END

IF OBJECT_ID('Person.Cliente', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Cliente
	(
		IdCli INT IDENTITY(1000,1) PRIMARY KEY,
		IdTipoCli INT NOT NULL,
		Nombre VARCHAR(30),
		Apellido VARCHAR(30),
		DNI INT,
		Genero CHAR(6) NOT NULL,
		FechaReg DATE DEFAULT GETDATE(),
		Baja DATE DEFAULT NULL,

		CONSTRAINT FK_TipoC FOREIGN KEY (IdTipoCli)
			REFERENCES Person.TipoCliente(IdTipoCli),

		CONSTRAINT CK_Gen CHECK (Genero IN ('Female', 'Male'))
	);
END

IF OBJECT_ID('Sales.Mediopago', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.Mediopago
	(
		IdMedPago INT IDENTITY(1,1) PRIMARY KEY,
		MedPagoAReemp CHAR(10),
		Descripcion CHAR(15),
		Vigencia DATE DEFAULT GETDATE(),
		Baja DATE DEFAULT NULL
	);
END

IF OBJECT_ID('Sales.Pago', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.Pago
	(
		IdPago INT IDENTITY(1,1) PRIMARY KEY,
		NroPago VARCHAR(23) UNIQUE,	--0000003100099475144530
		IdMedPago INT NOT NULL,
		Monto NUMERIC(7,2) NOT NULL,
		Estado CHAR(10) DEFAULT 'ACREDITADO',
		FechaEstado DATE DEFAULT GETDATE(),
	
		CONSTRAINT FK_MedPag FOREIGN KEY (IdMedPago)
			REFERENCES Sales.Mediopago(IdMedPago),
		CONSTRAINT CK_EstadoPago CHECK (Estado IN ('ACREDITADO', 'ANULADO'))
	);
END

IF OBJECT_ID('Sales.Venta', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.Venta
	(
		IdVenta INT IDENTITY(1,1) PRIMARY KEY,
		NroVenta INT UNIQUE,
		Fecha DATE NOT NULL,
		Hora TIME NOT NULL,
		IdSuc INT NOT NULL,
		IdEmp INT NOT NULL,
		IdPag INT NOT NULL,
		IdCli INT NOT NULL,
		Estado CHAR(7) DEFAULT 'ACTIVA',
		FechaEstado DATE DEFAULT GETDATE(),

		CONSTRAINT FK_Suc FOREIGN KEY (IdSuc)
			REFERENCES Production.Sucursal (IdSuc),
		CONSTRAINT FK_Emp FOREIGN KEY (IdEmp)
			REFERENCES Person.Empleado (IdEmp),
		CONSTRAINT FK_Pag FOREIGN KEY (IdPag)
			REFERENCES Sales.Pago (IdPago),
		CONSTRAINT FK_Cli FOREIGN KEY (IdCli)
			REFERENCES Person.Cliente (IdCli),
		CONSTRAINT CK_EstadoVenta CHECK (Estado IN ('ACTIVA', 'ANULADA'))
	);
END

IF OBJECT_ID('Sales.DetalleVenta', 'U') IS NULL
BEGIN
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
END

IF OBJECT_ID('Sales.TipoFactura', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.TipoFactura
	(
		IdTipoFac INT IDENTITY(1,1) PRIMARY KEY,
		TipoFac CHAR(1),
		Descripcion CHAR(10),
		Vigencia DATE DEFAULT GETDATE(),
		Baja DATE DEFAULT NULL
	);
END

IF OBJECT_ID('Sales.Factura', 'U') IS NULL
BEGIN
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
END

IF OBJECT_ID('Sales.NotaCredito', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.NotaCredito
	(
		IdNotaCredito INT IDENTITY(1,1) PRIMARY KEY,
		IdFac INT NOT NULL,
		IdProdNuevo INT,
		Monto DECIMAL(18, 2) NOT NULL,
		FechaEmision DATE NOT NULL,
		Motivo VARCHAR(255),
		Baja DATE DEFAULT NULL,

		CONSTRAINT FK_IdFact FOREIGN KEY (IdFac) 
			REFERENCES Sales.Factura(IdFact)
	);
END
GO

-------------------------------------------------------
------------- CREACION DE STORE PROCEDURE -------------
-------------------------------------------------------
-- ENUNCIADO: Genere store procedures para manejar la inserci�n, modificado, borrado de cada tabla. --


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
	IF NOT EXISTS(SELECT 1 FROM Production.Sucursal WHERE Direccion = @Direccion)
	BEGIN
		INSERT INTO Production.Sucursal(Direccion, Localidad, Provincia, Horario, Telefono)
		VALUES(@Direccion, @Ciudad, @Provincia, @Horario, @Telefono);

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA SUCURSAL';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA SUCURSAL';
		RAISERROR('DIRECCI�N DE SUCCURSAL DUPLICADA %s', 16, 1, @Direccion);
	END
	
END
GO

CREATE OR ALTER PROCEDURE Production.DeleteSucursal	-- BORRADO LOGICO
	@IdSuc INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		UPDATE Production.Sucursal
		SET Baja = GETDATE()
		WHERE IdSuc = @IdSuc AND Baja IS NULL;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO EN TABLA SUCURSAL';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA SUCURSAL';
		RAISERROR('ID DE SUCURSAL INV�LIDA %d', 16, 1, @IdSuc);
	END
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

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR REGISTRO EN TABLA SUCURSAL';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ERROR DE ID PARA ACTUALIZAR REGISTRO EN TABLA SUCURSAL';
		RAISERROR('ID DE SUCURSAL INV�LIDA %d', 16, 1, @IdSuc);
	END
END
GO


---PARA TABLA LINEA PRODUCTO---
CREATE OR ALTER PROCEDURE Production.InsertLineaProd
	@Descripcion CHAR(20)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)

	IF NOT EXISTS (SELECT 1 FROM Production.LineaProducto WHERE Descripcion = @Descripcion)
	BEGIN
		INSERT INTO Production.LineaProducto (Descripcion)
		VALUES(@Descripcion)

		EXEC ddbba.InsertReg @Mod='I', @Txt = N'INSERTAR REGISTRO EN TABLA LINEA PRODUCTO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = N'ERROR EN INSERTAR REGISTRO EN TABLA LINEA PRODUCTO / CATEGORIA DUPLICADA';
		RAISERROR('CATEGOR�A DUPLICADA %s', 16, 1, @Descripcion);
	END
END
GO

CREATE OR ALTER PROCEDURE Production.DeleteLineaProd	--BORRADO L?GICO
	@IdLin INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.LineaProducto WHERE IdLinProd = @IdLin)
	BEGIN
		UPDATE Production.LineaProducto
		SET Baja = GETDATE()
		WHERE IdLinProd = @IdLin AND Baja IS NULL;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO EN TABLA LINEA PRODUCTO'
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = N'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA LINEA PRODUCTO';
		RAISERROR('ID DE L�NEA DE PRODUCTO INV�LIDO %d', 16, 1, @IdLin);
	END
END
GO

CREATE OR ALTER PROCEDURE Production.UpdateDescLinea
	@IdLin INT,
	@DescN CHAR(20)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Production.LineaProducto WHERE IdLinProd = @IdLin)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Production.LineaProducto WHERE Descripcion = @DescN)
		BEGIN
			UPDATE Production.LineaProducto
			SET Descripcion = @DescN
			WHERE IdLinProd = @IdLin;

			EXEC ddbba.InsertReg @Mod='U', @Txt = N'ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO';
		END
		ELSE
		BEGIN
			EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN DESCRIPCI�N PARA ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO';
			RAISERROR('CATEGOR�A EXISTENTE %s', 16, 1, @DescN);
		END
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO';
		RAISERROR('ID DE L�NEA DE PRODUCTO INV�LIDO %d', 16, 1, @IdLin);
	END
END
GO


--- PARA TABLA PRODUCTO ---
CREATE OR ALTER PROCEDURE Production.InsertProd
	@NombreProd VARCHAR(40),
	@Descripcion VARCHAR(90),
	@CantIngreso INT,
	@IdLinProd INT,
	@Proveedor CHAR(40),
	@PrecioUnit DECIMAL(7,2)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)

	IF EXISTS (SELECT 1 FROM Production.LineaProducto WHERE IdLinProd = @IdLinProd)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Production.Producto WHERE Descripcion = @Descripcion AND NomProd = @NombreProd)
		BEGIN
			INSERT INTO Production.Producto(CantVendida, NomProd, Descripcion, IdLinProd, Proveedor, PrecioUnit) 
			VALUES(@CantIngreso, @Descripcion, @NombreProd, @IdLinProd, @Proveedor, @PrecioUnit);
	
			EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA PRODUCTO';
		END
		ELSE
		BEGIN
			EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA PRODUCTO';
			RAISERROR('PRODUCTO DUPLICADO %s | %s', 16, 1, @NombreProd, @Descripcion);
		END
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA PRODUCTO';
		RAISERROR('LINEA DE PRODUCTO ERR�NEA %d', 16, 1, @IdLinProd);
	END

	
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
		WHERE IdProd = @IdProd AND Baja IS NULL;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO REGISTRO EN TABLA PRODUCTO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA PRODUCTO';
		RAISERROR('ID DE PRODUCTO ERRONEO %d', 16, 1, @IdProd);
	END
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
		WHERE IdProd = @IdProd;

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR PRECIO DE REGISTRO EN TABLA PRODUCTO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA PRODUCTO';
		RAISERROR('ID DE PRODUCTO ERRONEO %d', 16, 1, @IdProd);
	END
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
		WHERE IdProd = @IdProd;

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR CANTIDAD INGRESADA DE REGISTRO EN TABLA PRODUCTO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA PRODUCTO';
		RAISERROR('ID DE PRODUCTO ERRONEO %d', 16, 1, @IdProd);
	END
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
	IF EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Person.Empleado WHERE Legajo = @Legajo)
		BEGIN
			INSERT INTO Person.Empleado (Legajo, IdSuc, DNI, Nombre, Apellido, EmailPersona, EmailEmpresarial, Cargo, Turno)
			VALUES(@Legajo, @IdSuc, @DNI, @Nombre, @Apellido, @EmailPersona, @EmailEmpresarial, @Cargo, @Turno);
	
			EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA EMPLEADO';
		END
		ELSE
		BEGIN	
			EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA EMPLEADO';
			RAISERROR('LEGAJO REPETIDO %d', 16, 1, @Legajo);
		END
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA EMPLEADO';
		RAISERROR('ID SUCURSAL INEXISTENTE %d', 16, 1, @IdSuc);
	END
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
		WHERE Legajo = @Legajo AND Baja IS NULL;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LOGICO EN REGISTRO EN TABLA EMPLEADO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA EMPLEADO';
		RAISERROR('EMPLEADO INEXISTENTE %d', 16, 1, @Legajo);
	END
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
		VALUES (@Desc);

 	EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA TIPO CLIENTE';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TIPO CLIENTE / TIPO CLIENTE EXISTENTE';
		RAISERROR('TIPO CLIENTE DUPLICADO %s', 16, 1, @Desc);
	END
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
		WHERE IdTipoCli = @IdTCli;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO L�GICO DE REGISTRO EN TABLA TIPO CLIENTE';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA TIPO CLIENTE';
		RAISERROR('ID TIPO CLIENTE INV�LIDO %d', 16, 1, @IdTCli);
	END
END
GO

---PARA TABLA CLIENTE---
CREATE OR ALTER PROCEDURE Person.InsertCliente
	@Nombre VARCHAR(30),
	@Apellido VARCHAR(30),
	@DNI INT,
	@TipoCli CHAR(10),
	@Genero CHAR(6)
AS
BEGIN
	SET @TipoCli = UPPER(@TipoCli);
	
	IF EXISTS (SELECT 1 FROM Person.TipoCliente WHERE Descripcion = @TipoCli)
	BEGIN
		DECLARE @IdTipoCli INT = (SELECT IdTipoCli FROM Person.TipoCliente WHERE Descripcion = @TipoCli);

		INSERT INTO Person.Cliente(IdTipoCli, Nombre, Apellido, DNI, Genero)
		VALUES(@IdTipoCli, @Nombre, @Apellido, @DNI, @Genero);

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA CLIENTE';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA CLIENTE';
		RAISERROR('TIPO DE CLIENTE INV�LIDO %s', 16, 1, @TipoCli);
	END
END
GO

CREATE OR ALTER PROCEDURE Person.DeleteCliente
	@IdCliente INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Person.Cliente WHERE IdCli = @IdCliente)
	BEGIN
		UPDATE Person.Cliente
		SET Baja = GETDATE()
		WHERE IdCli = @IdCliente;

		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ELIMINAR REGISTRO EN TABLA CLIENTE';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA CLIENTE';
		RAISERROR('ID CLIENTE INV�LIDO %d', 16, 1, @IdCliente);
	END
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
		VALUES (@TipFac, @Desc);

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA TIPO FACTURA';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR A INSERTAR REGISTRO EN TABLA TIPO FACTURA / TIPO DE FACTURA REPETIDA';
		RAISERROR('TIPO DE FACTURA REPETIDA %s | %s', 16, 1, @TipFac, @Desc);
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
			WHERE IdTipoFac = @IdTipFac;

			EXEC ddbba.InsertReg @Mod='D', @Txt = 'ELIMINAR REGISTRO EN TABLA TIPO FACTURA';
		END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ELIMINAR REGISTRO EN TABLA TIPO FACTURA / ID DE TIPO FACTURA ERRONEO';
		RAISERROR('ID TIPO DE FACTURA INVALIDA %d', 16, 1, @IdTipFac);
	END
END
GO

---TABLA FACTURA---
CREATE OR ALTER PROCEDURE Sales.InsertFactura
	@NroFactura INT,
	@IdTipoFac INT,
	@Fecha DATE,
	@Monto NUMERIC(7,2),
	@NroVent INT
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFactura) 
		AND EXISTS(SELECT 1 FROM Sales.TipoFactura WHERE IdTipoFac = @IdTipoFac)
		AND EXISTS(SELECT 1 FROM Sales.Venta WHERE NroVenta = @NroVent)
		BEGIN
			DECLARE @IdVent INT = (SELECT IdVenta FROM Sales.Venta WHERE NroVenta = @NroVent)
		
			INSERT INTO Sales.Factura (NroFact, IdTipoFac, FechaEmision, Total, IdVent)
			VALUES (@NroFactura, @IdTipoFac, @Fecha, @Monto, @IdVent);

			EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA FACTURA';
		END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA FACTURA';
		RAISERROR('FACTURA REPETIDA %d | %d | %d', 16, 1, @NroFactura, @IdTipoFac, @NroVent);
	END
END
GO

CREATE OR ALTER PROCEDURE Sales.DeleteFactura	--BORRADO L�GICO
	@NroFactura INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFactura)
	BEGIN
		UPDATE Sales.Factura
		SET Baja = GETDATE()
		WHERE NroFact = @NroFactura

		EXEC ddbba.InsertReg @Mod='D', @Txt = 'BORRADO LOGICO DE REGISTRO EN TABLA FACTURA';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN BORRAR REGISTRO EN TABLA TIPO FACTURA / NRO DE FACTURA ERRONEO'
		RAISERROR('NUMERO DE FACTURA INVALIDO %d', 16, 1, @NroFactura);
	END
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
		VALUES (@Desc);

		EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA MEDIO DE PAGO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = N'ERROR EN INSERTAR REGISTRO EN TABLA MEDIO DE PAGO / DESCRIPCI�N DUPLICADA';
		RAISERROR('MEDIO DE PAGO REPETIDO %s', 16, 1, @Desc);
	END
END
GO

CREATE OR ALTER PROCEDURE Sales.DeleteMedPag	--BORRADO L�GICO
	@IdMedPag INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.Mediopago WHERE IdMedPago = @IdMedPag)
	BEGIN
		UPDATE Sales.Mediopago
		SET Baja = GETDATE()
		WHERE IdMedPago = @IdMedPag;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO L�GICO REGISTRO EN TABLA MEDIO DE PAGO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA MEDIO DE PAGO';
		RAISERROR('ID MEDIO DE PAGO INV�LIDO %d', 16, 1, @IdMedPag);
	END
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
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)
		BEGIN
			INSERT INTO Sales.Pago (NroPago, Monto, IdMedPago)
			VALUES (@NroPago, @Monto, @MedPago);

			EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA PAGO';
		END
		ELSE
		BEGIN
			EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA PAGO';
			RAISERROR('PAGO EXISTENTE %d', 16, 1, @NroPago);
		END
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='I', @Txt = 'ERROR PARA INSERTAR REGISTRO EN TABLA PAGO';
		RAISERROR('ID DE PAGO INV�LIDO %d', 16, 1, @MedPago);
	END
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
		WHERE IdPago = @IdPago;

		EXEC ddbba.InsertReg @Mod='U', @Txt = 'ACTUALIZAR ESTADO DE REGISTRO EN TABLA PAGO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN ACTUALIZAR REGISTRO EN TABLA PAGO / ID INV�LIDO';
		RAISERROR('ID PAGO INV�LIDO %d', 16, 1, @IdPago);
	END
END
GO


---TABLA VENTA---
CREATE OR ALTER PROCEDURE Sales.InsertVenta
	@NroVenta INT,
	@IdSuc INT,
	@IdEmp INT,
	@NroPago INT,
	@IdCli INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Sales.Venta WHERE NroVenta = @NroVenta)
		AND EXISTS (SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)
		AND EXISTS (SELECT 1 FROM Person.Empleado WHERE IdEmp = @IdEmp)
		AND EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
	BEGIN
		DECLARE @IdPag INT = (SELECT IdPago FROM Sales.Pago WHERE NroPago = @NroPago)

		INSERT INTO Sales.Venta (NroVenta, IdSuc, IdEmp, IdPag, IdClI)
		VALUES (@NroVenta, @IdSuc, @IdEmp, @NroPago, @IdCli)

		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'INSERTAR REGISTRO EN TABLA VENTA'
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA VENTA';
		RAISERROR('NRO VENTA EXISTENTE %d', 16, 1, @NroVenta);
	END
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

		--ACTUALIZACI�N EN TABLA PAGO--
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
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'U', @Txt = 'ERROR EN ACTUALIZAR ESTADO DE REGISTRO EN TABLA VENTA';
		RAISERROR('NRO VENTA INV�LIDO %d', 16, 1, @NroVenta);
	END
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

		--ACTUALIZACI�N EN TABLA PRODUCTO--
		UPDATE Production.Producto
		SET CantVendida = CantVendida + @CantCompra
		WHERE IdProd = @IdProd

		DECLARE @CADENA VARCHAR(MAX)
		SET @CADENA = (SELECT N'ACTUALIZACI�N DE CANTIDAD DE PRODUCTO ' + CAST(IdProd AS VARCHAR(10)) FROM Production.Producto WHERE IdProd = @IdProd)

		EXEC ddbba.InsertReg @Mod='U', @Txt = @CADENA
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INGRESAR REGISTRO EN TABLA DETALLE VENTA';
		RAISERROR('NRO VENTA INV�LIDO %d', 16, 1, @NroVenta);
	END
END
GO

--- TABLA NOTA DE CREDITO ---
CREATE OR ALTER PROCEDURE Sales.InsertNotaCredito
    @NroFact INT,
	@Producto VARCHAR(40),
    @Monto DECIMAL(18, 2),
	@Motivo VARCHAR(255)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFact AND Total >= @Monto)
    BEGIN
		DECLARE @IdProd INT;

		IF @Producto IS NULL OR @Producto = ''
			SET @IdProd = NULL;
		ELSE
		BEGIN
			SET @IdProd = (SELECT IdProd FROM Production.Producto WHERE NomProd = @Producto);
			SET @Monto = (SELECT PrecioUnit FROM Production.Producto WHERE IdProd = @IdProd);
		END
		
		DECLARE @IdFact INT = (SELECT IdFact FROM Sales.Factura WHERE NroFact = @NroFact);
		DECLARE @IdVent INT = (SELECT IdVent FROM Sales.Factura WHERE IdFact = @IdFact);
		
		INSERT INTO Sales.NotaCredito(IdFac, IdProdNuevo, Monto, FechaEmision, Motivo)
        VALUES (@IdFact, @IdProd, @Monto, GETDATE(), @Motivo);

        -- ACTUALIZAR FACTURA
        UPDATE Sales.Factura
        SET Baja = GETDATE()
        WHERE IdFact = @IdFact;

		UPDATE Sales.Venta
		SET Estado = 'CANCELADA', FechaEstado = GETDATE()
		WHERE IdVenta = @IdVent;

		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'INSERTAR REGISTRO DE TABLA NOTA DE CR�DITO';
    END
    ELSE
    BEGIN
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INSERTAR REGISTRO DE TABLA NOTA DE CR�DITO';
        RAISERROR('EL MONTO DE LA NC EXCEDE EL MONTO DE FACTURA.', 16, 1);
    END
END;
GO


CREATE OR ALTER PROCEDURE Sales.DeleteNotaCredito	--BORRADO L�GICO
	@IdNotaCredito INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.NotaCredito WHERE IdNotaCredito = @IdNotaCredito)
	BEGIN
		UPDATE Sales.NotaCredito
		SET Baja = GETDATE()
		WHERE IdNotaCredito = @IdNotaCredito;

		EXEC ddbba.InsertReg @Mod = 'D', @Txt = 'ELIMINAR REGISTRO DE TABLA NOTA DE CR�DITO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'D', @Txt = 'ERROR EN BORRAR REGISTRO DE TABLA NOTA DE CR�DITO';
        RAISERROR('EL MONTO DE LA NC EXCEDE EL MONTO DE FACTURA.', 16, 1);
	END
END

-------------------------------------------------------
----------------- CREACI�N DE INDICES -----------------
-------------------------------------------------------
-- AYUDA A LOS UPDATE Y CONSULTAS DE LOS SP

CREATE NONCLUSTERED INDEX IX_Sucursal_Ubicacion_Estado
ON Production.Sucursal (Localidad) INCLUDE (Direccion, Provincia, Baja)
WITH (FILLFACTOR = 90);	-- NO HAY MUCHO CAMBIO EN LA TABLA

CREATE UNIQUE NONCLUSTERED INDEX IX_Empleado_NroEmp_Estado
ON Person.Empleado (Legajo) INCLUDE (Baja)
WITH (FILLFACTOR = 80);	-- NO HAY MUCHO CAMBIO EN LA TABLA

CREATE UNIQUE INDEX IDX_Unique_DNI
ON Person.Cliente (DNI) WHERE DNI IS NOT NULL
WITH (FILLFACTOR = 70);	--HAY MAYOR CANTIDAD DE CAMBIOS

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


-------------------------------------------------------
---------------- CREACI�N DE FUCIONES -----------------
-------------------------------------------------------
----------- UTILIZADAS EN LAS IMPOTACIONES ------------

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