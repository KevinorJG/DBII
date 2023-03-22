use Northwind
go
select * from Employees
select * from [Order Details]
select * from Orders
select * from Products
select * from Customers

ALTER PROCEDURE SendMail @Input_Query varchar(50),@ToMail varchar(50)
AS
BEGIN
EXECUTE msdb.dbo.sp_send_dbmail
	@profile_name = 'KevinPruebas',
	@recipients = @ToMail,
	@body = '<!DOCTYPE html>
			 <style>
				body {
					background-image: url("https://thumbs.dreamstime.com/z/icono-del-vector-de-la-factura-aislado-en-el-fondo-transparente-linear-yo-130113641.jpg");
					background-repeat: no-repeat;
					background-size: cover;
					}
			 </style>
				<body>
					<h1>Le mandamos un cordial saludo de parte del equipo de colaboradores de Northwind</h1> 
					<h1>este archivo le damos a conocer su factua de compra</h1> 
				</body>
			</html>',
	@body_format = 'HTML',
	@subject = 'Factura',
	@file_attachments = 'C:\Clientes.txt'	
END
	

CREATE PROCEDURE FacturaCliente @ID INT,@Mail VARCHAR(50)
AS
IF(@ID != 0 OR @ID != -1)
	BEGIN
		DECLARE @InputData VARCHAR(50)

		SELECT DISTINCT 
			FORMAT(O.OrderDate, 'dd/MM/yyyy') AS FechaOrden,
			OrderID AS NoOrden
		FROM Orders	AS O
		WHERE OrderID = @ID
		
		SELECT	OD.ProductID AS NoProducto,
				P.ProductName AS Producto,
				C.CategoryName AS Categoria,
				CAST(C.Description AS varchar(50)) AS Descripcion,
				OD.Quantity AS Cantidad,
				OD.UnitPrice AS Precio,
				SUM(OD.Quantity*OD.UnitPrice) AS SubTotal
		FROM [Order Details] AS OD 
		INNER JOIN Products AS P ON OD.ProductID = P.ProductID
		INNER JOIN Categories AS C ON P.CategoryID = C.CategoryID
		WHERE OD.OrderID = @ID
		GROUP BY OD.ProductID,P.ProductName,C.CategoryName,CAST(C.Description AS varchar(50)),OD.Quantity,OD.UnitPrice
	
		SELECT CAST(SUM((OD.Quantity*OD.UnitPrice)*1.15)AS SMALLMONEY) AS 'SubTotal (IVA)' from [Order Details] AS OD
		WHERE OD.OrderID = @ID

	SET @InputData = 'EXECUTE Factura '+CAST(@ID AS VARCHAR(20))
	EXECUTE SendMail
	@Input_Query = @InputData,
	@ToMail = @Mail	
	END

	--------------------------------------------------------------------------
	EXECUTE FacturaCliente 10248,'kevingaleano2017010@gmail.com'
	
	EXECUTE SendMail @Input_Query = 'SELECT *
		FROM Northwind.dbo.Orders	AS O
		WHERE OrderID = 10248',@ToMail = 'kevingaleano2017010@gmail.com'

		 EXEC xp_cmdshell 'bcp -q"SELECT *
		FROM Orders	AS O
		WHERE OrderID = 10248" queryout D:\SOQueryOut.txt -T –c'

		exec msdb.dbo.sysmail_help_queue_sp 'Mail'

		select * from Hotel.dbo.Factura 
		SELECT *
		FROM Northwind.dbo.Orders	AS O
		WHERE OrderID = 10248