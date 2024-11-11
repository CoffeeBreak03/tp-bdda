--Casos de pruebas de los procedures
USE Com5600G14

--Sucursales
EXEC Production.InsertSucursal 
    @Direccion = 'Av. Siempre Viva 123', 
    @Ciudad = 'Springfield', 
    @Provincia = 'Capital', 
    @Horario = '18:00', 
    @Telefono = 123456789;

EXEC Production.DeleteSucursal 
	@IdSuc = 9999;

EXEC Production.UpdateUbicacionSucursal 
    @IdSuc = 12, 
    @DireccionN = 'Av. Falsa 123', 
    @LocalidadN = 'Lomas del Mirador', 
    @ProvinciaN = 'Capital';

SELECT * FROM Production.Sucursal

--Liena de Prod
EXEC Production.InsertLienaProd 
	@Descripcion = 'Lacteos';

EXEC Production.DeleteLienaProd
	@IdLin = 1;

SELECT * FROM Production.LineaProducto 

--Prodructos
EXEC Production.InsertProd
	@Descripcion = 'Fanta',
	@CantIngreso = 44,
	@IdLinProd = 1,
	@Proveedor = 'Coca Cola Inc',
	@PrecioUnit = 20.45;

EXEC Production.UpdatePriceProd 
	@IdProd = 1, 
	@PriceN = 18.75;	

-- Caso de Error: Producto no existente
EXEC Production.UpdatePriceProd 
	@IdProd = 9999999, 
	@PriceN = 18.75;

EXEC Production.DeleteProd
	@IdProd = 1;

SELECT * FROM Production.Producto

--Empleados
EXEC Person.InsertEmp  
    @Legajo = 100124, 
    @IdSuc = 10, 
    @DNI = 45324860, 
    @Nombre = 'Edinson', 
    @Apellido = 'Cavani', 
    @EmailPersona = 'Cabj10@gmail.com', 
    @EmailEmpresarial = 'Ecavani@empresa.com', 
    @Cargo = 'Delantero', 
    @Turno = 'JC';


EXEC Person.InsertEmp 
    @Legajo = 100124, 
    @IdSuc = 10, 
    @DNI = 44568742, 
    @Nombre = 'Frank', 
    @Apellido = 'Fabra', 
    @EmailPersona = 'fabrigol@gmail.com', 
    @EmailEmpresarial = 'FrankF@empresa.com', 
    @Cargo = 'Extremo', 
    @Turno = 'TN';

EXEC Person.DeleteEmp 
	@Legajo = 123456;

EXEC Person.DeleteEmp
	@Legajo = 999999;

SELECT * FROM Person.Empleado

--Factura
EXEC Sales.InsertFactura	--NO SE POR QUE NO FUNCIONA
    @NroFactura = 1001, 
    @TipoFac = 1, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 1;

EXEC Sales.InsertFactura 
    @NroFactura = 1001, 
    @TipoFac = 2, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 1;

EXEC Sales.DeleteFactura	
	@NroFactura = 1001;

EXEC Sales.DeleteFactura	
	@NroFactura = 9999;

SELECT * FROM Sales.Factura