use Northwind
go
alter procedure Create_Credentials(
@Name nvarchar(60),
@Lastname nvarchar(60),
@Mail nvarchar(60),
@Rol nvarchar(20)
)
AS
BEGIN
	DECLARE @Cadena NVARCHAR(4000)
	DECLARE @Output NVARCHAR(2000);
	DECLARE @Roll NVARCHAR(20);
	DECLARE @Numbers NVARCHAR(50);
	SET @Numbers = '0,1,2,3,4,5,6,7,8,9';
	SET @Cadena = @Name+' '+@Lastname
	SET @Cadena = RTRIM(LTRIM(@Cadena));
	SET @Output = LEFT(@Cadena,1);
 
	WHILE (CHARINDEX(' ',@Cadena,1) > 0)
	BEGIN
		SET @Cadena = LTRIM(RIGHT(@Cadena,LEN(@Cadena) - CHARINDEX(' ',@Cadena,1)));
		SET @Output += LEFT(@Cadena,1);
	END
	SET @Output += (SELECT case @Rol
    WHEN 'Administrador' THEN '.Adm'
    WHEN 'Empleado' THEN '.Emp'
    END)

	PRINT @Output
END
go
exec Create_Credentials 'Kevin Jair','Ortiz Galeano','asasas','Empleado'

 