--Casos de Prueba para los Stored Procedures--

-- Casos de Prueba para InsertSucursal
-- Caso de �xito
EXEC Production.InsertSucursal
    @Direccion = 'Av. Corrientes 1234', 
    @Ciudad = 'CABA', 
    @Provincia = 'Buenos Aires', 
    @Horario = '9 a 18', 
    @Telefono = 12345678;

-- Caso de Error: Falta de campo requerido
EXEC Production.InsertSucursal 
    @Direccion = NULL, 
    @Ciudad = 'CABA', 
    @Provincia = 'Buenos Aires', 
    @Horario = '9 a 18', 
    @Telefono = 12345678;

-- Casos de Prueba para DeleteSucursal
-- Caso de �xito
EXEC Production.DeleteSucursal 
	@IdSuc = 5;

-- Caso de Error: Sucursal no existente
EXEC Production.DeleteSucursal 
	@IdSuc = 999;

-- Casos de Prueba para InsertLienaProd
-- Caso de �xito
EXEC Production.InsertLienaProd
	@Descripcion = 'Accesorios';

-- Caso de Error: Descripci�n duplicada
EXEC Production.InsertLienaProd 
	@Descripcion = 'Accesorios';

-- Casos de Prueba para DeleteLienaProd
-- Caso de �xito
EXEC Production.DeleteLienaProd 
	@IdLin = 3;

-- Caso de Error: L�nea de producto no existente
EXEC Production.DeleteLienaProd 
	@IdLin = 100;

-- Casos de Prueba para InsertProd
-- Caso de �xito
EXEC Production.InsertProd 
    @Descripcion = 'Mouse Inal�mbrico', 
    @CantIngreso = 20, 
    @IdLinProd = 1, 
    @Proveedor = 'TechSuppliers', 
    @PrecioUnit = 15.50;

-- Caso de Error: Producto duplicado
EXEC Production.InsertProd 
    @Descripcion = 'Mouse Inal�mbrico', 
    @CantIngreso = 20, 
    @IdLinProd = 1, 
    @Proveedor = 'TechSuppliers', 
    @PrecioUnit = 15.50;

-- Casos de Prueba para UpdatePriceProd
-- Caso de �xito
EXEC Production.UpdatePriceProd @IdProd = 4, @PriceN = 18.75;

-- Caso de Error: Producto no existente
EXEC Production.UpdatePriceProd @IdProd = 999, @PriceN = 18.75;

-- Casos de Prueba para InsertEmp
-- Caso de �xito
EXEC Person.InsertEmp 
    @Legajo = 123456, 
    @IdSuc = 1, 
    @DNI = 12345678, 
    @Nombre = 'Edinson', 
    @Apellido = 'Cavani', 
    @EmailPersona = 'Cabj10@gmail.com', 
    @EmailEmpresarial = 'Ecavani@empresa.com', 
    @Cargo = 'Vendedor', 
    @Turno = 'A';

-- Caso de Error: Legajo duplicado
EXEC Person.InsertEmp 
    @Legajo = 123456, 
    @IdSuc = 1, 
    @DNI = 12345678, 
    @Nombre = 'Frank', 
    @Apellido = 'Fabra', 
    @EmailPersona = 'fabrigol@gmail.com', 
    @EmailEmpresarial = 'FrankF@empresa.com', 
    @Cargo = 'Vendedor', 
    @Turno = 'A';

-- Casos de Prueba para DeleteEmp
-- Caso de �xito
EXEC Person.DeleteEmp 
	@Legajo = 123456;

-- Caso de Error: Empleado no existente
EXEC Person.DeleteEmp 
	@Legajo = 999999;

-- Casos de Prueba para InsertFactura
-- Caso de �xito
EXEC Sales.InsertFactura 
    @NroFactura = 1001, 
    @TipoFac = 1, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 1;

-- Caso de Error: Factura duplicada
EXEC Sales.InsertFactura 
    @NroFactura = 1001, 
    @TipoFac = 1, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 1;

-- Casos de Prueba para DeleteFactura
-- Caso de �xito
EXEC Sales.DeleteFactura 
	@NroFactura = 1001;

-- Caso de Error: Factura no existente
EXEC Sales.DeleteFactura 
	@NroFactura = 9999;
