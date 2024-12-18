------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 14
--BASUALDO, NICOLÁS NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LEÓN 45040212
----------------------------------------------------------------

USE Com5600G14
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
	@Telefono CHAR(10)
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
		RAISERROR('DIRECCIÓN DE SUCCURSAL DUPLICADA %s', 16, 1, @Direccion);
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
		RAISERROR('ID DE SUCURSAL INVÁLIDA %d', 16, 1, @IdSuc);
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
		RAISERROR('ID DE SUCURSAL INVÁLIDA %d', 16, 1, @IdSuc);
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
		RAISERROR('CATEGORÍA DUPLICADA %s', 16, 1, @Descripcion);
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
		RAISERROR('ID DE LÍNEA DE PRODUCTO INVÁLIDO %d', 16, 1, @IdLin);
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
			SET Descripcion = UPPER(@DescN)
			WHERE IdLinProd = @IdLin;

			EXEC ddbba.InsertReg @Mod='U', @Txt = N'ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO';
		END
		ELSE
		BEGIN
			EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN DESCRIPCIÓN PARA ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO';
			RAISERROR('CATEGORÍA EXISTENTE %s', 16, 1, @DescN);
		END
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN ID PARA ACTUALIZAR REGISTRO EN TABLA LINEA PRODUCTO';
		RAISERROR('ID DE LÍNEA DE PRODUCTO INVÁLIDO %d', 16, 1, @IdLin);
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
			INSERT INTO Production.Producto(CantIngresada, NomProd, Descripcion, IdLinProd, Proveedor, PrecioUnit) 
			VALUES(@CantIngreso, @NombreProd, @Descripcion, @IdLinProd, @Proveedor, @PrecioUnit);
	
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
		RAISERROR('LINEA DE PRODUCTO ERRÓNEA %d', 16, 1, @IdLinProd);
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
		SET CantIngresada = CantIngresada + @CantIng
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

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LÓGICO DE REGISTRO EN TABLA TIPO CLIENTE';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA TIPO CLIENTE';
		RAISERROR('ID TIPO CLIENTE INVÁLIDO %d', 16, 1, @IdTCli);
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
		RAISERROR('TIPO DE CLIENTE INVÁLIDO %s', 16, 1, @TipoCli);
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
		RAISERROR('ID CLIENTE INVÁLIDO %d', 16, 1, @IdCliente);
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
	@NroFactura CHAR(12),
	@IdTipoFac INT,
	@Fecha DATE,
	@Monto NUMERIC(7,2),
	@NroVent INT
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFactura) 
		AND EXISTS(SELECT 1 FROM Sales.TipoFactura WHERE IdTipoFac = @IdTipoFac)
		AND EXISTS(SELECT 1 FROM Sales.Venta WHERE IdVenta = @NroVent)
		BEGIN
			DECLARE @IdVent INT = (SELECT IdVenta FROM Sales.Venta WHERE IdVenta = @NroVent)
		
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

CREATE OR ALTER PROCEDURE Sales.CambiarEstadoFacturaPagada
	@NroFactura CHAR(12),
	@IdPago INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Sales.Pago WHERE IdPago = @IdPago AND Estado = 'ACREDITADO')
	BEGIN
		IF EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFactura)
		BEGIN
			UPDATE Sales.Factura
			SET Estado = 'PAGADA', FechaEstado = GETDATE()
			WHERE NroFact = @NroFactura

			EXEC ddbba.InsertReg @Mod='D', @Txt = 'CAMBIO DE ESTADO EN TABLA FACTURA';
		END
		ELSE
		BEGIN
			EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN CAMBIAR ESTADO EN TABLA TIPO FACTURA / NRO DE FACTURA ERRONEO'
			RAISERROR('NUMERO DE FACTURA INVALIDO %d', 16, 1, @NroFactura);
		END
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN CAMBIAR ESTADO EN TABLA TIPO FACTURA / NRO DE FACTURA ERRONEO'
		RAISERROR('NUMERO DE PAGO INVALIDO %d', 16, 1, @IdPago);
	END
END
GO


---PARA TABLA MEDIO DE PAGO---
CREATE OR ALTER PROCEDURE Sales.InsertMedPag
    @Desc CHAR(21)
AS
BEGIN
    SET @Desc = UPPER(@Desc);

    IF NOT EXISTS (SELECT 1 FROM Sales.Mediopago WHERE Descripcion = @Desc AND Baja IS NULL)
    BEGIN
        INSERT INTO Sales.Mediopago (Descripcion)
        VALUES (@Desc);

        EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA MEDIO DE PAGO';
    END
    ELSE
    BEGIN
        EXEC ddbba.InsertReg @Mod = 'I', @Txt = N'ERROR EN INSERTAR REGISTRO EN TABLA MEDIO DE PAGO / DESCRIPCIÓN DUPLICADA';
        RAISERROR('MEDIO DE PAGO REPETIDO %s', 16, 1, @Desc);
    END
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
		WHERE IdMedPago = @IdMedPag;

		EXEC ddbba.InsertReg @Mod='D', @Txt = N'BORRADO LÓGICO REGISTRO EN TABLA MEDIO DE PAGO';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod='D', @Txt = 'ERROR EN ID PARA ELIMINAR REGISTRO EN TABLA MEDIO DE PAGO';
		RAISERROR('ID MEDIO DE PAGO INVÁLIDO %d', 16, 1, @IdMedPag);
	END
END
GO


---PARA TABLA PAGO---
CREATE OR ALTER PROCEDURE Sales.InsertPago
	@NroPago VARCHAR(22),
	@IdFact INT, 
	@Monto NUMERIC(7,2),
	@MedPago INT
AS
BEGIN
	IF(@NroPago <> '--')
	BEGIN
		IF EXISTS (SELECT 1 FROM Sales.Mediopago WHERE IdMedPago = @MedPago)
		AND NOT EXISTS(SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)	--PAGO ELECTRÓNICO
		AND EXISTS (SELECT 1 FROM Sales.Factura WHERE IdFact = @IdFact AND Estado = 'NO PAGADA')
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)
			BEGIN
				INSERT INTO Sales.Pago (NroPago, Monto, IdMedPago, IdFactura)
				VALUES (@NroPago, @Monto, @MedPago, @IdFact);

				UPDATE Sales.Factura
				SET Estado = 'PAGADA'
				WHERE IdFact = @IdFact;

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
			RAISERROR('ID DE PAGO INVÁLIDO %d', 16, 1, @MedPago);
		END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM Sales.Mediopago WHERE IdMedPago = @MedPago)
		AND EXISTS (SELECT 1 FROM Sales.Factura WHERE IdFact = @IdFact AND Estado = 'NO PAGADA')
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM Sales.Pago WHERE NroPago = @NroPago)
			BEGIN
				INSERT INTO Sales.Pago (NroPago, Monto, IdMedPago, IdFactura)
				VALUES (@NroPago, @Monto, @MedPago, @IdFact);

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
			RAISERROR('ID DE PAGO INVÁLIDO %d', 16, 1, @MedPago);
		END
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
		EXEC ddbba.InsertReg @Mod='U', @Txt = N'ERROR EN ACTUALIZAR REGISTRO EN TABLA PAGO / ID INVÁLIDO';
		RAISERROR('ID PAGO INVÁLIDO %d', 16, 1, @IdPago);
	END
END
GO

---TABLA VENTA---
CREATE OR ALTER PROCEDURE Sales.InsertVenta
	@IdSuc INT,
	@IdEmp INT,
	@IdCli INT,
	@Fecha DATE,
	@Hora TIME
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Person.Empleado WHERE IdEmp = @IdEmp)
		AND EXISTS (SELECT 1 FROM Production.Sucursal WHERE IdSuc = @IdSuc)
		AND EXISTS (SELECT 1 FROM Person.Cliente WHERE IdCli = @IdCli)
	BEGIN
		INSERT INTO Sales.Venta (IdSuc, IdEmp, IdClI, Fecha, Hora)
		VALUES (@IdSuc, @IdEmp, @IdCli, @Fecha, @Hora)

		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'INSERTAR REGISTRO EN TABLA VENTA'
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INSERTAR REGISTRO EN TABLA VENTA';
		RAISERROR('PARAMETROS INEXISTENTES', 16, 1);
	END
END
GO

CREATE OR ALTER PROCEDURE Sales.UpdateEstadoVenta
	@NroVenta INT,
	@EstadoVenta CHAR(7)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Sales.Venta WHERE IdVenta = @NroVenta)
	BEGIN
		UPDATE Sales.Venta
		SET Estado = @EstadoVenta, FechaEstado = GETDATE()
		WHERE IdVenta = @NroVenta

		EXEC ddbba.InsertReg @Mod = 'U', @Txt = 'ACTUALIZAR ESTADO DE REGISTRO EN TABLA VENTA';
	END
	ELSE
	BEGIN
		EXEC ddbba.InsertReg @Mod = 'U', @Txt = 'ERROR EN ACTUALIZAR ESTADO DE REGISTRO EN TABLA VENTA';
		RAISERROR('NRO VENTA INVÁLIDO %d', 16, 1, @NroVenta);
	END
END
GO


--- TABLA DETALLE VENTA ---
CREATE OR ALTER PROCEDURE Sales.InsertDetalleVenta
    @CantCompra INT,
    @NroVenta INT,
    @IdProd INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Sales.Venta WHERE IdVenta = @NroVenta)
    BEGIN
        IF EXISTS (SELECT 1 FROM Production.Producto WHERE IdProd = @IdProd AND CantIngresada > @CantCompra)
        BEGIN
        DECLARE @PrecioUnit DECIMAL(7,2) = (SELECT PrecioUnit FROM Production.Producto WHERE IdProd = @IdProd)

        DECLARE @Subtotal DECIMAL(7,2) = @PrecioUnit * @CantCompra;

        INSERT INTO Sales.DetalleVenta (Cantidad, Subtotal, IdVenta, IdProd)
        VALUES (@CantCompra, @Subtotal, @NroVenta, @IdProd);

	UPDATE Production.Producto
	SET CantIngresada = CantIngresada - @CantCompra
	WHERE IdProd = @IdProd;

        EXEC ddbba.InsertReg @Mod='I', @Txt = 'INSERTAR REGISTRO EN TABLA DETALLEVENTA';
        END
        ELSE
        BEGIN
            RAISERROR('ID DE PRODUCTO NO VALIDO %d', 16, 1, @IdProd);
        END
    END
    ELSE
    BEGIN
        RAISERROR('ID DE VENTA NO VALIDO %d', 16, 1, @NroVenta);
    END
END
GO

--- TABLA NOTA DE CREDITO ---
CREATE OR ALTER PROCEDURE Sales.InsertNotaCredito
    @NroFact CHAR(12),
    @IdProd INT,
    @Motivo VARCHAR(255)
AS
BEGIN
	DECLARE @MontoTotalGastado DECIMAL(7,2) = (SELECT SUM(nc.Monto) 
												FROM Sales.NotaCredito nc
													INNER JOIN Sales.Factura f ON f.IdFact = nc.IdFac
												WHERE f.NroFact = @NroFact);

	DECLARE @Monto DECIMAL(7, 2) = (SELECT (dv.Subtotal/dv.Cantidad)
									FROM Sales.Factura f
										INNER JOIN Sales.DetalleVenta dv ON dv.IdVenta = f.IdVent
									WHERE dv.IdProd = @IdProd AND f.NroFact = @NroFact);

    -- Verificar si @Monto es NULL después de asignar, y si es así, devolver un error
    IF @Monto IS NULL
    BEGIN
        RAISERROR('El producto especificado no existe o no tiene un precio definido.', 16, 1);
        RETURN;
    END

    IF EXISTS(SELECT 1 FROM Sales.Factura WHERE NroFact = @NroFact AND Estado IN ('PAGADA', 'NC EMITIDA') AND Total >= @Monto)
    BEGIN
		IF @MontoTotalGastado IS NULL OR @MontoTotalGastado <= (SELECT Total FROM Sales.Factura WHERE NroFact = @NroFact)
		BEGIN
			DECLARE @IdFact INT = (SELECT MAX(IdFact) FROM Sales.Factura WHERE NroFact = @NroFact);
			DECLARE @IdVent INT = (SELECT IdVent FROM Sales.Factura WHERE IdFact = @IdFact);
			DECLARE @IdDetalle INT = (SELECT IdDetalle FROM Sales.DetalleVenta WHERE IdVenta = @IdVent AND IdProd = @IdProd);

			INSERT INTO Sales.NotaCredito(IdFac, IdProdNuevo, IdDet, Monto, FechaEmision, Motivo)
			VALUES (@IdFact, @IdProd, @IdDetalle, @Monto, GETDATE(), @Motivo);

			-- Actualizar la factura y la venta a estado CANCELADA
			IF @MontoTotalGastado = (SELECT Total FROM Sales.Factura WHERE IdFact = @IdFact)
			BEGIN
				UPDATE Sales.Factura
				SET Estado = 'CANCELADA', FechaEstado = GETDATE()
				WHERE IdFact = @IdFact;

				UPDATE Sales.Venta
				SET Estado = 'ANULADA', FechaEstado = GETDATE()
				WHERE IdVenta = @IdVent;
			END
			ELSE
			BEGIN
				UPDATE Sales.Factura
				SET Estado = 'NC EMITIDA', FechaEstado = GETDATE()
				WHERE IdFact = @IdFact;
				
				UPDATE Sales.Venta
				SET Estado = 'CANCELADA', FechaEstado = GETDATE()
				WHERE IdVenta = @IdVent;
			END

			-- Si se especificó un producto, ajustar el inventario
			IF @Motivo NOT LIKE '%NO FUNCIONA%' AND @Motivo NOT LIKE '%DEFECTUOSO%' AND @Motivo NOT LIKE '%DAÑADO%'
			BEGIN
				DECLARE @PrecioUnit DECIMAL(7,2) = (SELECT PrecioUnit FROM Production.Producto WHERE IdProd = @IdProd);
				DECLARE @CantidadComprada INT = CAST(@Monto / @PrecioUnit AS INT);

				UPDATE Production.Producto
				SET CantIngresada = CantIngresada + @CantidadComprada, 
					CantVendida = CantVendida - @CantidadComprada
				WHERE IdProd = @IdProd;
			END

			EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'INSERTAR REGISTRO DE TABLA NOTA DE CRÉDITO';
		END
		ELSE
		BEGIN
			EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INSERTAR REGISTRO DE TABLA NOTA DE CRÉDITO';
			RAISERROR('EL MONTO DE LA NC EXCEDE EL MONTO DE FACTURA.', 16, 1);
		END
    END
    ELSE
    BEGIN
        EXEC ddbba.InsertReg @Mod = 'I', @Txt = 'ERROR EN INSERTAR REGISTRO DE TABLA NOTA DE CRÉDITO';
        RAISERROR('EL MONTO DE LA NC EXCEDE EL MONTO DE FACTURA.', 16, 1);
    END
END;
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

CREATE NONCLUSTERED INDEX IX_NroFact
ON Sales.Factura (NroFact)
WITH (FILLFACTOR = 80);	-- NO HAY MUCHO CAMBIO EN LA TABLA

CREATE NONCLUSTERED INDEX IX_Descripcion_Prod
ON Production.Producto(Descripcion) INCLUDE (NomProd)
WITH (FILLFACTOR = 70); --HAY MAYOR CANTIDAD DE CAMBIOS

CREATE UNIQUE INDEX IDX_Unique_DNI	--PARA MANTENER LOS DNI DE LOS CLIENTES UNIQUE
ON Person.Cliente (DNI) WHERE DNI IS NOT NULL
WITH (FILLFACTOR = 70);	--HAY MAYOR CANTIDAD DE CAMBIOS

CREATE NONCLUSTERED INDEX IX_Pago_NroPago_Estado
ON Sales.Pago (NroPago) INCLUDE (Estado, FechaEstado)
WITH (FILLFACTOR = 70);	--HAY MAYOR CANTIDAD DE CAMBIOS
GO

-------------------------------------------------------
---------------- CREACIÓN DE FUCIONES -----------------
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
			@parte NVARCHAR(MAX) = '',--INICIALIZO LA PARTE EN VACÍO
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

		-- INSERTA EL REGISTRO QUE QUEDA AL FINAL (FECHA INGRESO) YA QUE NO LLEGA AL SEPARADOR PARA INSERTAR EN LA CONDICIÓN
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
            @parte NVARCHAR(MAX) = '',	--INICIALIZO LA PARTE EN VACÍO
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
        -- SI LA PRIMERA PARTE NO ES NÚMERICA O SÍ PERO CON UNIDAD DE PESO AL LADO, SIGNIFICA QUE LA CADENA ES UNA REFERENCIA SIN CANTIDAD
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


CREATE OR ALTER FUNCTION ddbba.NormalizarNroPago(@Nro VARCHAR(MAX))
RETURNS CHAR(22)
AS
BEGIN
	DECLARE @NroPagoNormalizado CHAR(22) = '';
	DECLARE @CharActual CHAR(1);
	DECLARE @PosActual INT = 1;

	WHILE(@PosActual <= LEN(@Nro))
	BEGIN
		SET @CharActual = SUBSTRING(REVERSE(@Nro), @PosActual, 1);

		IF PATINDEX('%[^0-9A-Za-z]%', @CharActual) = 0
        BEGIN
            SET @NroPagoNormalizado = @CharActual + @NroPagoNormalizado;
        END
		ELSE
		BEGIN
			IF @CharActual = '-'
			BEGIN
				SET @NroPagoNormalizado = @CharActual + @NroPagoNormalizado;
			END
		END

		SET @PosActual = @PosActual + 1;
	END

	RETURN @NroPagoNormalizado;
END
GO

CREATE OR ALTER PROCEDURE Person.ClienteRandom
	@cantidad INT
AS
BEGIN
	DECLARE @i INT = 0;

	WHILE(@i < @cantidad)
	BEGIN
		INSERT INTO Person.Cliente(DNI, Nombre, Apellido, IdTipoCli, Genero)
		SELECT
			(SELECT ABS(CHECKSUM(NEWID())) % 99999999 + 1000000) AS DNI,
			
			(SELECT TOP 1 n1.nombre + ' ' + n2.nombre
			FROM Person.NomYAp n1, Person.NomYAp n2
			WHERE n1.nombre != n2.nombre
			ORDER BY NEWID()) AS nombre,
		
			(SELECT TOP 1 ap.apellido
			FROM Person.NomYAp ap
			ORDER BY NEWID()) AS apellido,

			(SELECT TOP 1 tp.IdTipoCli
			FROM Person.TipoCliente tp
			ORDER BY NEWID()) AS TipoCli,

			(SELECT 
			CASE 
				WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Male'
				ELSE 'Female'
			END) AS Genero

		SET @i = @i+1
	END
END
GO
