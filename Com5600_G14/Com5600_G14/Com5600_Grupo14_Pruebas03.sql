------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 14
--BASUALDO, NICOLÁS NAHUEL 44238788
--MARCONI, LUCAS MARTIN 45324860
--PARODI, FRANCISCO MAXILIANO 44669305
--RODRIGUEZ, MARCOS LEÓN 45040212
----------------------------------------------------------------

--Ejecutar primero las importaciones y luego los casos de prueba 
--Ejecutar los casos de exito en orden, Gracias
--Casos de pruebas de los procedures
USE Com5600G14

--SUCURSALES
--CASOS DE EXITO
EXEC Production.InsertSucursal 
    @Direccion = 'Av. Corrientes 1223', 
    @Ciudad = 'Buenos Aires', 
    @Provincia = 'Capital', 
    @Horario = 'L a J 8 a.m. – 9 p.m. S y D 9 a.m. - 8 p.m.', 
    @Telefono = '5655-8462';

EXEC Production.UpdateUbicacionSucursal 
    @IdSuc = 13, 
    @DireccionN = 'Av. Falsa 123', 
    @LocalidadN = 'Lomas del Mirador', 
    @ProvinciaN = 'Provincia';

EXEC Production.DeleteSucursal 
	@IdSuc = 13;

SELECT * FROM Production.Sucursal

--CASOS DE FALLO
EXEC Production.InsertSucursal --Error ya que la direccion ya esta registrada
    @Direccion = 'Av. Falsa 123', --DIRECCION DUPLICADA
    @Ciudad = 'Buenos Aires', 
    @Provincia = 'Capital', 
    @Horario = 'L a J 8 a.m. – 9 p.m. S y D 9 a.m. - 8 p.m.', 
    @Telefono = '5655-846';

EXEC Production.DeleteSucursal --Error ya que el ID de la sucursal no exite
	@IdSuc = 9999; --ID INEXISTENTE 

EXEC Production.UpdateUbicacionSucursal --Error ya que el ID de la sucursal no exite
    @IdSuc = 22, --ID INEXISTENTE 
    @DireccionN = 'Av. Falsa 123', 
    @LocalidadN = 'Lomas del Mirador', 
    @ProvinciaN = 'Provincia';

SELECT * FROM Production.Sucursal

--LINEA DE PROD
--CASOS DE EXITO
EXEC Production.InsertLineaProd 
	@Descripcion = 'Vegano';

EXEC Production.InsertLineaProd 
	@Descripcion = 'Juguetes';

EXEC Production.DeleteLineaProd
	@IdLin = 14;

EXEC Production.UpdateDescLinea
	@IdLin = 13,
	@DescN = 'Gamer';

SELECT * FROM Production.LineaProducto 

--CASOS DE FALLO
EXEC Production.InsertLineaProd --Error ya que es descripcion duplicada
	@Descripcion = 'BEBIDAS';

EXEC Production.DeleteLineaProd --Error ya que no existe el ID
	@IdLin = 99;

EXEC Production.UpdateDescLinea --Error ya que ya existe la categoria
	@IdLin = 13,
	@DescN = 'Gamer';

EXEC Production.UpdateDescLinea --Error ya que no existe el ID
	@IdLin = 34,
	@DescN = 'Niños';

SELECT * FROM Production.LineaProducto 

--PRODUCTOS
--CASOS DE EXITO
EXEC Production.InsertProd
	@NombreProd = 'Teclado',
	@Descripcion = 'Teclado Gamer con luces led',
	@CantIngreso = 20,
	@IdLinProd = 13,
	@Proveedor = 'Logitech',
	@PrecioUnit = 150.45;

EXEC Production.UpdatePriceProd 
	@IdProd = 2, 
	@PriceN = 30.56;	

EXEC Production.DeleteProd
	@IdProd = 4;

EXEC Production.UpdateCantIngresadaProd
	@IdProd = 1, 
	@CantIng = 15;

SELECT * FROM Production.Producto

--CASOS DE FALLO
EXEC Production.InsertProd
	@NombreProd = 'Teclado',
	@Descripcion = 'Teclado Gamer con luces led',
	@CantIngreso = 20,
	@IdLinProd = 23, --NO EXITE EL ID DE EL LINEA DE PROD
	@Proveedor = 'Logitech',
	@PrecioUnit = 150.45;

EXEC Production.InsertProd
	@NombreProd = 'Bebidas',
	@Descripcion = 'Licor Cloudberry', --PRODUCTO DUPLICADO
	@CantIngreso = 20,
	@IdLinProd = 1, 
	@Proveedor = 'The Coca-Cola Company',
	@PrecioUnit = 30;

EXEC Production.UpdatePriceProd 
	@IdProd = 787878, --NO EXITE EL ID DEL PROD
	@PriceN = 30.56;	

EXEC Production.DeleteProd
	@IdProd = 787878; --NO EXITE EL ID DEL PROD

EXEC Production.UpdateCantIngresadaProd
	@IdProd = 9999, --NO EXITE EL ID DEL PROD
	@CantIng = 15;

SELECT * FROM Production.Producto

--EMPLEADOS
--CASOS DE EXITO
EXEC Person.InsertEmp  
    @Legajo = 100420, 
    @IdSuc = 10, 
    @DNI = 45324860, 
    @Nombre = 'Edinson', 
    @Apellido = 'Cavani', 
    @EmailPersona = 'Cabj10@gmail.com', 
    @EmailEmpresarial = 'Ecavani@empresa.com', 
    @Cargo = 'SUPERVISOR', 
    @Turno = 'JC';

EXEC Person.InsertEmp 
    @Legajo = 100532, 
    @IdSuc = 10, 
    @DNI = 44568742, 
    @Nombre = 'Frank', 
    @Apellido = 'Fabra', 
    @EmailPersona = 'fabrigol@gmail.com', 
    @EmailEmpresarial = 'FrankF@empresa.com', 
    @Cargo = 'Defensa', 
    @Turno = 'TN';

EXEC Person.DeleteEmp 
	@Legajo = 100532; --DEN DE BAJA A FABRA POR FAVOR

SELECT * FROM Person.Empleado

--CASOS DE FALLO
EXEC Person.InsertEmp 
    @Legajo = 100532, --LEGAJO REPETIDO
    @IdSuc = 10, 
    @DNI = 44568742, 
    @Nombre = 'Frank', 
    @Apellido = 'Fabra', 
    @EmailPersona = 'fabrigol@gmail.com', 
    @EmailEmpresarial = 'FrankF@empresa.com', 
    @Cargo = 'Defensa', 
    @Turno = 'TN';

EXEC Person.InsertEmp 
    @Legajo = 502123,
    @IdSuc = 32, --NO EXISTE LA SUCURSAL
    @DNI = 44568742, 
    @Nombre = 'Pol', 
    @Apellido = 'Fernandez', 
    @EmailPersona = 'Polfer@gmail.com', 
    @EmailEmpresarial = 'FenandezPol@empresa.com', 
    @Cargo = 'central', 
    @Turno = 'TT';

EXEC Person.InsertEmp 
    @Legajo = 855622,
    @IdSuc = 12, 
    @DNI = 44568742, 
    @Nombre = 'Miguel', 
    @Apellido = 'Merentiel', 
    @EmailPersona = 'Labestia@gmail.com', 
    @EmailEmpresarial = 'Merentiel99@empresa.com', 
    @Cargo = 'Delantero', 
    @Turno = 'AS'; --TURNO NO VALIDO

EXEC Person.DeleteEmp
	@Legajo = 999999; --NO EXISTE EL ID

SELECT * FROM Person.Empleado

--TIPO DE CLIENTE
--CASOS EXITOSOS
EXEC Person.InsertTipoCli
	@Desc ='VIP';

EXEC Person.DeleteTipoCli 
	@IdTCli = 3;

SELECT * FROM Person.TipoCliente

--CASOS DE FALLO
EXEC Person.InsertTipoCli --ERROR POR DESCRIPCION DPLICADA
	@Desc ='Normal';

EXEC Person.DeleteTipoCli --ERROR POR ID INVALIDO
	@IdTCli = 23;

SELECT * FROM Person.TipoCliente

--CLIENTE
--CASOS DE EXITO
EXEC Person.InsertCliente
	@Nombre = 'Marcos Leon',
	@Apellido = 'Rodriguez',
	@DNI = 45358025,
	@TipoCli = 'Normal',
	@Genero ='Male';

EXEC Person.DeleteCliente
	@IdCliente = 1009;

SELECT * FROM Person.Cliente

--CASOSO DE FALLO
EXEC Person.InsertCliente --ERROR POR TIPO DE CLIENTE INVALIDO
	@Nombre = 'Marcos Leon',
	@Apellido = 'Rodriguez',
	@DNI = 45358025,
	@TipoCli = 'Basico',
	@Genero ='Male';

EXEC Person.InsertCliente --ERROR POR GENERO DEL CLIENTE, DEBE SER 'MALE' O 'FEMALE'
	@Nombre = 'Juan Roman',
	@Apellido = 'Riquelme',
	@DNI = 56254158,
	@TipoCli = 'Regular',
	@Genero ='No binario';

EXEC Person.DeleteCliente --ERROR POR ID DE CLIENTE INVALIDO
	@IdCliente = 2021;

SELECT * FROM Person.Cliente

--MEDIO DE PAGO
--CASOS DE EXITO
EXEC Sales.InsertMedPag
	@Desc = 'Bitcoin';

 EXEC Sales.DeleteMedPag
	@IdMedPag = 2;

SELECT * FROM Sales.Mediopago

--CASOS DE FALLO
EXEC Sales.InsertMedPag --ERROR POR DESCRIPCION DUPLICADA
	@Desc = 'Billetera Electronica'; --DEJA INGRESAR LA PRIMERA VEZ, A PESAR DE QUE YA ESTA EN LA TABLA

 EXEC Sales.DeleteMedPag --ERROR POR ID INVALIDO
	@IdMedPag = 22;

SELECT * FROM Sales.Mediopago

--TIPO DE FACTURA
--CASOS DE EXITO
EXEC Sales.InsertTipoFac 
	@TipFac = 'D',
	@Desc = 'Miembros';

EXEC Sales.DeleteTipoFac
	@IdTipFac = 4;

SELECT * FROM Sales.TipoFactura

--CASOS DE FALLO
EXEC Sales.InsertTipoFac  --ERROR POR TIPO DE FACTURA DUPLICADA
	@TipFac = 'A', --DEJA INGRESAR LA PRIMERA VEZ, A PESAR DE QUE YA ESTA EN LA TABLA
	@Desc = 'Responsable inscripto';

EXEC Sales.InsertTipoFac --NO HAY ERROR POR DESCRIPCION REPETIDA
	@TipFac = 'F',
	@Desc = 'Miembros';

EXEC Sales.DeleteTipoFac --ERROR POR ID DE TIPO DE FACTURA INVALIDA
	@IdTipFac = 12;

SELECT * FROM Sales.TipoFactura

--VENTA
--CASOS DE EXITO
EXEC Sales.InsertVenta
	@IdSuc = 10,
	@IdEmp = 5,
	@IdCli = 1002,
	@Fecha = '2024-11-08',
	@Hora ='14:30:00';

EXEC Sales.UpdateEstadoVenta
	@NroVenta = 1,
	@EstadoVenta= 'ANULADA';

SELECT * FROM Sales.Venta

--CASOS DE FALLO
EXEC Sales.InsertVenta
	@IdSuc = 3, --ID SUCURSAL INEXISTENTE
	@IdEmp = 5,
	@IdCli = 1002,
	@Fecha = '2024-11-08',
	@Hora ='14:30:00';

EXEC Sales.InsertVenta
	@IdSuc = 3, 
	@IdEmp = 25, --ID EMPLEADO INEXISTENTE
	@IdCli = 1002,
	@Fecha = '2024-11-08',
	@Hora ='14:30:00';

EXEC Sales.InsertVenta
	@IdSuc = 3, 
	@IdEmp = 12, 
	@IdCli = 1500, --ID CLIENTE INEXISTENTE
	@Fecha = '2024-11-08',
	@Hora ='14:30:00';

EXEC Sales.UpdateEstadoVenta --NRO DE VENTA INVALIDO
	@NroVenta = 2000,
	@EstadoVenta= 'ANULADA';

EXEC Sales.UpdateEstadoVenta --ESTADO INVALIDO
	@NroVenta = 10,
	@EstadoVenta= 'AJSLAFA';

SELECT * FROM Sales.Venta

--DETALLE DE VENTA
--CASOS DE EXITO
EXEC Sales.InsertDetalleVenta
	@CantCompra = 12,
	@NroVenta = 2,
	@IdProd =6428 ;

SELECT * FROM Sales.DetalleVenta

--CASOS DE FALLO
EXEC Sales.InsertDetalleVenta
	@CantCompra = 12,
	@NroVenta = 2000, --NRO DE VENTA NO EXISTE
	@IdProd =6440 ;

EXEC Sales.InsertDetalleVenta
	@CantCompra = 12,
	@NroVenta = 6440,
	@IdProd = 99999; --ID DE PROD INEXISTENTE

SELECT * FROM Sales.DetalleVenta

--FACTURA
--CASOS DE EXITO
EXEC Sales.InsertFactura	
    @NroFactura = '999-99-9999', 
    @IdTipoFac = 3, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 12;

SELECT * FROM Sales.Factura

--CASOS DE FALLO
EXEC Sales.InsertFactura	
    @NroFactura = '355-53-5943', --NRO FACTURA REPETIDO
    @IdTipoFac = 3, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 98;

EXEC Sales.InsertFactura	
    @NroFactura = '625-23-4568', 
    @IdTipoFac = 5, --NO EXISTE EL ID TIPO DE FACTURA
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 14;

EXEC Sales.InsertFactura	
    @NroFactura = '321-12-9329', 
    @IdTipoFac = 3, 
    @Fecha = '2024-10-10', 
    @Monto = 350.00, 
    @NroVent = 10002; --NO EXISTE NRO DE VENTA

SELECT * FROM Sales.Factura

--PAGO
--CASOS DE EXITO
EXEC Sales.InsertPago
	@NroPago = '5621-9999-5123-8725',
	@IdFact = 12,
	@Monto = 52.66,
	@MedPago = 2;

EXEC Sales.UpdateEstadoPago
	@IdPago = 1,
	@Estado = 'ANULADO';

SELECT * FROM Sales.Pago

--CASOS DE FALLO
EXEC Sales.InsertPago
	@NroPago = '4660-1046-8238-6585', --ERROR POR PAGO EXISTENTE
	@IdFact = 12,
	@Monto = 52.66,
	@MedPago = 2;

EXEC Sales.InsertPago
	@NroPago = '5621-9999-5123-8725',
	@IdFact = 12,
	@Monto = 52.66,
	@MedPago = 12; --ID MEDIO DE PAGO INVALIDO

EXEC Sales.InsertPago
	@NroPago = '5621-9999-5123-8725',
	@IdFact = 2390, --ID DE VENTA INVALIDO
	@Monto = 52.66,
	@MedPago = 2;

EXEC Sales.UpdateEstadoPago
	@IdPago = 99999, -- ID PAGO INVALIDO
	@Estado = 'ANULADO';

EXEC Sales.UpdateEstadoPago
	@IdPago = 12,
	@Estado = 'CAVANI'; -- ESTADO INVALIDO

--NOTA DE CREDITO
--CASOS DE EXITO
EXEC Sales.InsertNotaCredito 
    @NroFact = '877-22-3308',
    @IdProd = 681,
    @Motivo = 'Devolución de producto dañado';

--Se van a poder vere los cambios en las tablas para le idventa 66
SELECT * FROM Sales.NotaCredito
SELECT * FROM Sales.Factura
SELECT * FROM Sales.DetalleVenta
SELECT * FROM Sales.Venta
SELECT * FROM Production.Producto

--CASOS DE FALLO
EXEC Sales.InsertNotaCredito
    @NroFact = '999-99-9999', --ERROR POR FACTURA INEXISTENTE
    @IdProd = 6456,
    @Motivo = 'Devolución de producto vencido';

EXEC Sales.InsertNotaCredito
    @NroFact = '373-73-7910',
    @IdProd = 12, --ERROR POR PRODUCTO NO EXISTENTE
    @Motivo = 'Devolución de producto dañado';

SELECT * FROM Sales.NotaCredito