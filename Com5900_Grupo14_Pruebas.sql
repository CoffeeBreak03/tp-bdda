--Casos de pruebas de los procedures
USE Com5600G14

--Sucursales
EXEC Production.InsertSucursal 
    @Direccion = 'Av. Corrientes 1223', 
    @Ciudad = 'Buenos Aires', 
    @Provincia = 'Capital', 
    @Horario = '9:00', 
    @Telefono = 56558462;

EXEC Production.DeleteSucursal 
	@IdSuc = 9999;

EXEC Production.UpdateUbicacionSucursal 
    @IdSuc = 10, 
    @DireccionN = 'Av. Falsa 123', 
    @LocalidadN = 'Lomas del Mirador', 
    @ProvinciaN = 'Provincia';

SELECT * FROM Production.Sucursal

--Liena de Prod
EXEC Production.InsertLienaProd 
	@Descripcion = 'BEBIDAS';

EXEC Production.DeleteLienaProd
	@IdLin = 1;

SELECT * FROM Production.LineaProducto 

--Prodructos
EXEC Production.InsertProd
	@Descripcion = 'Teclado Gamer con luces led',
	@CantIngreso = 20,
	@IdLinProd = 2,
	@Proveedor = 'Logitech',
	@PrecioUnit = 150.45;

EXEC Production.UpdatePriceProd 
	@IdProd = 2, 
	@PriceN = 180.75;	

EXEC Production.DeleteProd
	@IdProd = 1;

SELECT * FROM Production.Producto

--Empleados
EXEC Person.InsertEmp  
    @Legajo = 100420, 
    @IdSuc = 10, 
    @DNI = 45324860, 
    @Nombre = 'Edinson', 
    @Apellido = 'Cavani', 
    @EmailPersona = 'Cabj10@gmail.com', 
    @EmailEmpresarial = 'Ecavani@empresa.com', 
    @Cargo = 'Delantero', 
    @Turno = 'JC';

EXEC Person.InsertEmp 
    @Legajo = 100420, 
    @IdSuc = 10, 
    @DNI = 44568742, 
    @Nombre = 'Frank', 
    @Apellido = 'Fabra', 
    @EmailPersona = 'fabrigol@gmail.com', 
    @EmailEmpresarial = 'FrankF@empresa.com', 
    @Cargo = 'Extremo', 
    @Turno = 'TN';

EXEC Person.DeleteEmp 
	@Legajo = 100420;

EXEC Person.DeleteEmp
	@Legajo = 999999;

SELECT * FROM Person.Empleado

--Tipo Cliente
EXEC Person.InsertTipoCli
	@Desc ='REGULAR';

EXEC Person.DeleteTipoCli --ERROR NO EXITE LA TABLA PERSON.CLIENTE
	@IdTCli = 2;

SELECT * FROM Person.TipoCliente

--Medio de Pago
EXEC Sales.InsertMedPag
	@Desc = 'Tarjeta de credito';

 EXEC Sales.DeleteMedPag
	@IdMedPag = 2;

SELECT * FROM Sales.Mediopago

--Pago
EXEC Sales.InsertPago
	@NroPago = 123,
	@Monto = 52.66,
	@MedPago = 1;

EXEC Sales.UpdateEstadoPago
	@IdPago = 1,
	@Estado = 'ACREDITADO';

SELECT * FROM Sales.Pago

--Ventas
EXEC Sales.InsertVenta --DA ERROR YA QUE NO SE AGREGA EL GENERO DEL CLIENTE
	@NroVenta = 1,
	@IdSuc = 10,
	@IdEmp = 1,
	@NroPago = 123,
	@TipoCli = 1;

EXEC Sales.UpdateEstadoVenta
	@NroVenta = 1,
	@EstadoVenta= 'ANULADA';

SELECT * FROM Sales.Venta

--Detalle ventas
EXEC Sales.InsertDetVenta
	@CantCompra = 12,
	@Subtotal = 45.23,
	@NroVenta = 1,
	@IdProd =2 ;

--Tipo Factura
EXEC Sales.InsertTipoFac 
	@TipFac = 'A',
	@Desc = 'CONSUMIDOR';

EXEC Sales.DeleteTipoFac
	@IdTipFac = 1;

SELECT * FROM Sales.TipoFactura

--Factura
EXEC Sales.InsertFactura	
    @NroFactura = 1001, 
    @TipoFac = 1, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 1;

EXEC Sales.DeleteFactura	
	@NroFactura = 1001;

SELECT * FROM Sales.Factura