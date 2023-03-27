use Northwind
go
CREATE PROCEDURE SendMail @ID INT,@ToMail varchar(50)
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
'<html>
	    <body>
			<h3>Le mandamos un cordial saludo de parte del equipo de colaboradores de Northwind.</h3> 
			<h3>Los siguientes datos son los detalles de su factura</h3>		
		</body>
		<p><br></p>
	<table border="1" bordercolor="#000000" style="border-collapse: collapse; text-align: center; padding: 5px;">
		<caption>Factura</caption>
		<thead>
		<tr>
			<th style = "padding: 5px;">Fecha Orden</th>
			<th style = "padding: 5px;">No Orden</th>
			<th style = "padding: 5px;">Vendedor<br></th>
			<th style = "padding: 5px;">Nombre de envio</th>
		</tr>'
		+@header
		+'</thead>
	</table>
	<p><br></p>
	<table border="1" bordercolor="#000000" style="border-collapse: collapse; text-align: center; padding: 5px;">		
		<thead>
		<tr>
			<th style = "padding: 5px;">No Producto</th>
			<th style = "padding: 5px;">Producto</th>
			<th style = "padding: 5px;">Categoria<br></th>
			<th style = "padding: 5px;">Descripcion</th>
			<th style = "padding: 5px;">Cantidad</th>
			<th style = "padding: 5px;">Precio</th>
			<th style = "padding: 5px;">SubTotal (SIN IVA)</th>
		</tr>'
		+@center
		+'</thead>	   
	</table>
	<p><br></p>
	<table border="1" bordercolor="#000000" style="border-collapse: collapse; text-align: center; padding: 5px;">		
		<thead>
		<tr>
			<th style = "padding: 5px;">SubTotal (IVA)</th>		
		</tr>'
		+@down
		+'</thead>
	</table>
</html>'

	EXECUTE msdb.dbo.sp_send_dbmail
	@profile_name ='KevinPruebas', ---aqui pones tu perfil de correo que hiciste en sql
	@recipients = @ToMail,
	@body = @header,
	@body_format = 'HTML',
	@subject = 'Factura'
END