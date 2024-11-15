------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
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

IF SCHEMA_ID('Reporte') IS NULL
	EXEC('CREATE SCHEMA Reporte');
GO

-------------------------------------------------------
----------------- CREACIÓN DE TABLAS ------------------
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
		Provincia VARCHAR(26),
		Horario VARCHAR(44),
		Telefono CHAR(10),
		CiudadOrig CHAR(10),
		CUIT INT DEFAULT 0,
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
		DNI INT NOT NULL,
		CUIL INT DEFAULT 0,
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

IF OBJECT_ID('Sales.Venta', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.Venta
	(
		IdVenta INT IDENTITY(1,1) PRIMARY KEY,
		Fecha DATE NOT NULL,
		Hora TIME NOT NULL,
		IdSuc INT NOT NULL,
		IdEmp INT NOT NULL,
		IdCli INT NOT NULL,
		Estado CHAR(9) DEFAULT 'ACTIVA',
		FechaEstado DATE DEFAULT GETDATE(),

		CONSTRAINT FK_Suc FOREIGN KEY (IdSuc)
			REFERENCES Production.Sucursal (IdSuc),
		CONSTRAINT FK_Emp FOREIGN KEY (IdEmp)
			REFERENCES Person.Empleado (IdEmp),
		CONSTRAINT FK_Cli FOREIGN KEY (IdCli)
			REFERENCES Person.Cliente (IdCli),
		CONSTRAINT CK_EstadoVenta CHECK (Estado IN ('ACTIVA', 'ANULADA', 'CANCELADA'))
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

IF OBJECT_ID('Sales.Mediopago', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.Mediopago
	(
		IdMedPago INT IDENTITY(1,1) PRIMARY KEY,
		MedPagoAReemp CHAR(11),
		Descripcion CHAR(21),
		Vigencia DATE DEFAULT GETDATE(),
		Baja DATE DEFAULT NULL
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
		NroFact CHAR(12),
		IdTipoFac INT NOT NULL,
		FechaEmision DATE NOT NULL,
		Total NUMERIC(7,2),
		IdVent INT NOT NULL,
		Estado CHAR(9) DEFAULT 'NO PAGADA',
		FechaEstado DATE DEFAULT GETDATE(),

		CONSTRAINT FK_TipoF FOREIGN KEY (IdTipoFac)
			REFERENCES Sales.TipoFactura (IdTipoFac),
		CONSTRAINT FK_VentFac FOREIGN KEY (IdVent)
			REFERENCES Sales.Venta (IdVenta),
		CONSTRAINT CK_EstadoFact CHECK (Estado IN ('PAGADA', 'NO PAGADA', 'CANCELADA'))
	);
END

IF OBJECT_ID('Sales.Pago', 'U') IS NULL
BEGIN
	CREATE TABLE Sales.Pago
	(
		IdPago INT IDENTITY(1,1) PRIMARY KEY,
		NroPago CHAR(22),	--0000003100099475144530
		IdFactura INT NOT NULL,
		IdMedPago INT NOT NULL,
		Monto NUMERIC(7,2) NOT NULL,
		Estado CHAR(10) DEFAULT 'ACREDITADO',
		FechaEstado DATE DEFAULT GETDATE(),
	
		CONSTRAINT FK_Factura FOREIGN KEY (IdFactura)
			REFERENCES Sales.Factura(IdFact),
		CONSTRAINT FK_MedPag FOREIGN KEY (IdMedPago)
			REFERENCES Sales.Mediopago(IdMedPago),
		CONSTRAINT CK_EstadoPago CHECK (Estado IN ('ACREDITADO', 'ANULADO'))
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
		Motivo VARCHAR(255)

		CONSTRAINT FK_IdFact FOREIGN KEY (IdFac) 
			REFERENCES Sales.Factura(IdFact)
	);
END
GO

