Create database BDRepositorio
go
Use BDRepositorio
go
select * from BDRepositorio.dbo.Recaudacion
Create table Recaudacion
(IdRecaudacion int primary key identity (1,1),
Fecha date,
BD varchar(50),
Año int,
Mes int,
Monto float,
Descuento float,
MontoFinal float,
cantidadOrdenes int,
[Cantidad de ordenes con descuento] int,
[Empleados que antendieron] int)
go
Create table Detalle_Recaudacion
(IdDetalleRecaudacion int primary key identity (1,1),
IdRecaudacion int,
IdEmpleado int,
Monto float,
Descuento float,
MontoFinal float,
CantidadOrdenes int,
CantidadDescuento int,
CantidadClientes int
)
go
Alter Table Detalle_Recaudacion
add foreign key (IdRecaudacion) references Recaudacion(IdRecaudacion)

Insert into BDRepositorio.dbo.Recaudacion
Select
      cast(Getdate() as Date) as Fecha,
	  'Northwind' as BD,
	  (Select distinct year(Orderdate) from Northwind.dbo.orders where year(Orderdate) = year(getdate()) and month(Orderdate) = month(getdate())) as Año,
	  (Select distinct month(Orderdate) from Northwind.dbo.orders where year(Orderdate) = year(getdate()) and month(Orderdate) = month(getdate())) as Mes,
	  round(sum(od.UnitPrice * od.Quantity ),2) as Monto,
	  round(sum(od.UnitPrice * od.Quantity * od.Discount ),2) as Descuento,
	  round(sum((od.UnitPrice * od.Quantity) * (1 - od.Discount )),2) as MontoTotal,
	  count(distinct o.orderID) as CantidadOrdenes,
	  (Select count(*) from Northwind.dbo.[Order Details] ordt INNER JOIN Northwind.dbo.Orders ord on ord.OrderID = ordt.OrderID
	  where year(ord.Orderdate) = year(getdate()) and month(ord.Orderdate) = month(getdate()) and ordt.Discount > 0) as [Cantidad de ordenes con descuento], 
	  count(distinct O.CustomerID ) as [Cantidad de empleados que atendieron ]
from Northwind.dbo.[Order Details] od
inner join Northwind.dbo.Orders O on od.OrderID = O.OrderID
where 
year(Orderdate) = year(getdate())
and
month(Orderdate) = month(getdate())

--2

Insert into BDRepositorio.dbo.Recaudacion
Select 
	cast(GETDATE() as date) as 'Fecha',
	'Adventure' as 'BD',
	YEAR(GETDATE()) as Año,
	MONTH(GETDATE()) as Mes,
	SUM(sod.OrderQty * sod.UnitPrice) as Monto,
	SUM(sod.UnitPriceDiscount * sod.OrderQty * sod.UnitPrice) as Descuento, 
	Sum(soh.TotalDue) - SUM(soh.TotalDue * sod.UnitPriceDiscount) as 'Monto Total',
	COUNT(distinct soh.SalesOrderID) as 'Cantidad de Ordenes',
	(Select count(saled.SalesOrderID) from Adventure.Sales.SalesOrderDetail saled INNER JOIN Adventure.Sales.SalesOrderHeader saleh on saleh.SalesOrderID = saled.SalesOrderID 
	where Month(saleh.OrderDate) = 3 and Year(saleh.OrderDate) = 2008 and saled.UnitPriceDiscount > 0) as 'Cantidad de ordenes con descuento',
	Count(distinct soh.CustomerID) as 'Cantidad de clientes'
From Adventure.Sales.SalesOrderHeader SOH 
INNER JOIN Adventure.Sales.SalesOrderDetail SOD on soh.SalesOrderID = SOD.SalesOrderID
where YEAR(SOH.OrderDate) = 2008 and MONTH(SOH.OrderDate) = 3

--3

SELECT 
	R.RegionDescription, 
	round(sum(OD.UnitPrice * OD.Quantity ),2) as Monto,
	round(sum(OD.UnitPrice * OD.Quantity * OD.Discount ),2) as Descuento,
	round(sum((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount )),2) as MontoTotal
FROM Northwind.dbo.Region R 
INNER JOIN Northwind.dbo.Territories T on T.RegionID = R.RegionID
INNER JOIN Northwind.dbo.EmployeeTerritories ET on ET.TerritoryID = T.TerritoryID
INNER JOIN Northwind.dbo.Employees E on E.EmployeeID = ET.EmployeeID
INNER JOIN Northwind.dbo.Orders O on O.EmployeeID = O.EmployeeID
INNER JOIN Northwind.dbo.[Order Details] OD on OD.OrderID = O.OrderID
GROUP BY R.RegionDescription


--4

CREATE PROCEDURE SendMail @ToMail varchar(50)
AS
BEGIN
DECLARE @html NVARCHAR(MAX) = N''
DECLARE @htmlRegion NVARCHAR(MAX) = N''
DECLARE @htmlDetails NVARCHAR(MAX) = N''

	SELECT @html = @html + '<tr><td>' 
				+ CAST(R.Fecha AS VARCHAR(50)) + '</td><td>'
				+ CAST(R.BD AS VARCHAR(30)) + '</td><td>'
				+ CAST(R.Año AS VARCHAR(5)) + '</td><td>'
				+ CAST(R.Mes AS VARCHAR(5)) + '</td><td>'
				+ CAST(R.Monto AS VARCHAR(50)) + '</td><td>'
				+ CAST(R.Descuento AS VARCHAR(50)) + '</td><td>'
				+ CAST(R.MontoFinal AS VARCHAR(50)) + '</td><td>'
				+ CAST(R.cantidadOrdenes AS VARCHAR(20)) + '</td><td>'
				+ CAST(R.[Cantidad de ordenes con descuento] AS VARCHAR(20)) + '</td><td>'
				+ CAST(R.[Empleados que antendieron] AS VARCHAR(20)) + '</td></tr>'
	FROM BDRepositorio.dbo.Recaudacion AS R

	SELECT @htmlRegion = @htmlRegion + '<tr><td>'+
					  + CAST(R.RegionDescription AS VARCHAR(20)) + '</td><td>'
					  + CAST(ROUND(SUM(od.UnitPrice * od.Quantity ),2) AS VARCHAR(50)) + '</td><td>'
					  + CAST(ROUND(SUM(od.UnitPrice * od.Quantity * od.Discount ),2) AS VARCHAR(50)) + '</td><td>'
					  + CAST(ROUND(SUM((od.UnitPrice * od.Quantity) * (1 - od.Discount )),2) AS VARCHAR(50)) + '</td></tr>'
	FROM Northwind.dbo.Region R 
	INNER JOIN Northwind.dbo.Territories T on T.RegionID = R.RegionID
	INNER JOIN Northwind.dbo.EmployeeTerritories ET on ET.TerritoryID = T.TerritoryID
	INNER JOIN Northwind.dbo.Employees E on E.EmployeeID = ET.EmployeeID
	INNER JOIN Northwind.dbo.Orders O on O.EmployeeID = O.EmployeeID
	INNER JOIN Northwind.dbo.[Order Details] OD on OD.OrderID = O.OrderID
	GROUP BY R.RegionDescription

	SELECT @htmlDetails = @htmlDetails + '<tr><td>'+
						+ CAST(DR.IdDetalleRecaudacion AS VARCHAR(10)) + '</td><td>'
						+ CAST(DR.IdRecaudacion AS VARCHAR(20)) + '</td><td>'
						+ CAST(DR.IdEmpleado AS VARCHAR(20)) + '</td><td>'
						+ CAST(DR.Descuento AS VARCHAR(20)) + '</td><td>'
						+ CAST(DR.MontoFinal AS VARCHAR(20)) + '</td><td>'
						+ CAST(DR.CantidadOrdenes AS VARCHAR(20)) + '</td><td>'
						+ CAST(DR.CantidadDescuento AS VARCHAR(20)) + '</td><td>'
						+ CAST(DR.CantidadClientes AS VARCHAR(20)) + '</td></tr>'
	FROM [BDRepositorio].[dbo].[Detalle_Recaudacion] AS DR

SELECT @html =
'<html>
	    <body>
			<h3>La siguiente informacion muestra un resumen de recaudaciones</h3> 				
		</body>
		<p><br></p>
	<table border="1" bordercolor="#000000" style="border-collapse: collapse; text-align: center; padding: 5px; ">
		<caption>Recaudaciones</caption>
		<thead>
		<tr>
			<th style = "padding: 5px;">Fecha</th>
			<th style = "padding: 5px;">Base de datos</th>
			<th style = "padding: 5px;">Año</th>
			<th style = "padding: 5px;">Mes</th>
			<th style = "padding: 5px;">Monto</th>
			<th style = "padding: 5px;">Descuento</th>
			<th style = "padding: 5px;">Monto Final</th>
			<th style = "padding: 5px;">Cantidad de Ordenes</th>
			<th style = "padding: 5px;">Ordenes con Descuento</th>
			<th style = "padding: 5px;">Empleados que atendieron</th>
		</tr>'
		+@html+
		'</thead>
	</table>
	<p><br></p>
	<table border="1" bordercolor="#000000" style="border-collapse: collapse; text-align: center; padding: 5px;">		
		<thead>
		<tr>
			<th style = "padding: 5px;">No Registro</th>		
			<th style = "padding: 5px;">No Recaudacion</th>
			<th style = "padding: 5px;">No Empleado</th>
			<th style = "padding: 5px;">Monto</th>
			<th style = "padding: 5px;">Descuento</th>
			<th style = "padding: 5px;">Monto Final</th>
			<th style = "padding: 5px;">Cantidad de ordenes</th>
			<th style = "padding: 5px;">Cantidad con Descuento</th>
			<th style = "padding: 5px;">Cantidad de Clientes</th>
		</tr>'
		+@htmlDetails+
		'</thead>
	</table>
	<p><br></p>
	<table border="1" bordercolor="#000000" style="border-collapse: collapse; text-align: center; padding: 5px;">
	<caption>Recaudaciones por regiones</caption>
		<thead>
		<tr>
			<th style = "padding: 5px;">Region</th>
			<th style = "padding: 5px;">Monto</th>
			<th style = "padding: 5px;">Descuento</th>
			<th style = "padding: 5px;">Monto Total</th>
		</tr>'
		+@htmlRegion+
		'</thead>	   
	</table>
</html>'

	EXECUTE msdb.dbo.sp_send_dbmail
	@profile_name ='KevinPruebas',
	@recipients = @ToMail,
	@body = @html,
	@body_format = 'HTML',
	@subject = 'Informe mensual'
END

EXECUTE BDRepositorio.dbo.SendMail 'kevinjair2003@gmail.com'


