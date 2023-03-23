use Northwind
go


ALTER PROCEDURE SendMail @ID INT,@ToMail varchar(50)
AS
BEGIN
DECLARE @header NVARCHAR(MAX) = N''
DECLARE @center NVARCHAR(MAX) = N''
DECLARE @down NVARCHAR(MAX) = N''

SELECT @header = @header + '<tr><td>' + CAST(O.OrderDate AS varchar(12)) + '</td><td>' 
				+ CAST(O.OrderID AS varchar(10)) + '</td><td>'
				+E.FirstName+' '+E.LastName+'</td><td>'
				+C.CompanyName+'</td></tr>' FROM Orders	AS O
		INNER JOIN Customers AS C ON C.CustomerID = O.CustomerID
		INNER JOIN Employees AS E ON E.EmployeeID = O.EmployeeID
		WHERE O.OrderID = @ID

SELECT @center = @center + '<tr><td>' + CAST(OD.ProductID AS varchar(50)) + '</td><td>' 
				+ P.ProductName + '</td><td>'
				+ C.CategoryName + '</td><td>'
				+ CAST(CAST(C.Description AS varchar(50)) AS VARCHAR(50)) + '</td><td>'
				+ CAST(CAST(OD.Quantity  AS SMALLMONEY) AS VARCHAR(10))+ '</td><td>'
				+ CAST(CAST(OD.UnitPrice  AS SMALLMONEY) AS VARCHAR(10))+ '</td><td>'
				+ CAST(CAST(SUM(OD.Quantity*OD.UnitPrice) AS SMALLMONEY) AS VARCHAR(10))+'</td></tr>' 
		FROM [Order Details] AS OD 
		INNER JOIN Products AS P ON OD.ProductID = P.ProductID
		INNER JOIN Categories AS C ON P.CategoryID = C.CategoryID
		WHERE OD.OrderID = @ID
		GROUP BY OD.ProductID,P.ProductName,C.CategoryName,CAST(C.Description AS varchar(50)),OD.Quantity,OD.UnitPrice

SELECT @down = @down + '<tr><td>' +  CAST(CAST(SUM((OD.Quantity*OD.UnitPrice)*1.15)AS smallmoney) AS VARCHAR(10)) +'</td></tr>' 
FROM [Order Details] AS OD
		WHERE OD.OrderID = @ID

SELECT @header = 
	'<style>
		.demo {
			border:1px solid black;
			border-collapse: collapse;
		}
		.demo th {
			border:1px solid #000000;
			padding:5px;
			background:#F0F0F0;
		}
		.demo td {
			border:1px solid #000000;	
		}
	</style>
	    <body>
			<h3>Le mandamos un cordial saludo de parte del equipo de colaboradores de Northwind.</h3> 
			<h3>Los siguientes datos son los detalles de su factura</h3>		
		</body>

	<table class="demo">
		<caption>Factura</caption>
		<thead>
		<tr>
			<th>Fecha Orden</th>
			<th>No Orden</th>
			<th>Vendedor<br></th>
			<th>Nombre de envio</th>
		</tr>'
		+@header
		+'</thead>
	    <tbody>

		</tbody>
	</table>
	<table class="demo">		
		<thead>
		<tr>
			<th>No Producto</th>
			<th>Producto</th>
			<th>Categoria<br></th>
			<th>Descripcion</th>
			<th>Cantidad</th>
			<th>Precio</th>
			<th>SubTotal (SIN IVA)</th>
		</tr>'
		+@center
		+'</thead>
	    <tbody>

		</tbody>
	</table>
	<table class="demo">		
		<thead>
		<tr>
			<th>SubTotal (IVA)</th>		
		</tr>'
		+@down
		+'</thead>
	    <tbody>

		</tbody>
	</table>'

	EXECUTE msdb.dbo.sp_send_dbmail
	@profile_name ='KevinPruebas',
	@recipients = @ToMail,
	@body = @header,
	@body_format = 'HTML',
	@subject = 'Factura'
END
	

CREATE PROCEDURE Factura @ID INT,@Mail VARCHAR(50)
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

	
	END

	--------------------------------------------------------------------------
	EXECUTE SendMail 10251,'kevinjair2003@gmail.com'
	
	

		