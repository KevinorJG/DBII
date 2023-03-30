---Creacion de certificados--
Use master
--Se necesita crear una llave para encriptar
CREATE MASTER KEY ENCRYPTION BY PASSWORD ='kevinadmin'
go
--Se procede a crear el certificado
CREATE CERTIFICATE CertificadoBD
WITH SUBJECT = 'Certificado para backups',
EXPIRY_DATE = '20230405'

--Se hace el backup del certificado
BACKUP CERTIFICATE CertificadoBD
TO FILE = 'D:\tmp\BKCERT.cer'
WITH PRIVATE KEY (FILE = 'D:\tmp\BK_Key.pvk',
ENCRYPTION BY PASSWORD ='1234')

--Se hace un backup de una BD encriptada con certificado
Backup Database [Northwind]
TO DISK = 'D:\Northwind-Encrypti.bak'
WITH INIT,
ENCRYPTION
(
ALGORITHM = AES_256,
SERVER CERTIFICATE = CertificadoBD),
COMPRESSION,
FORMAT,
STATS = 10


--\Nota si el restore de la base de datos da error, quiere decir que el certificado no esta instalado oh no lo encuentra en este caso
--Se procede a los siguiente

CREATE CERTIFICATE CertificadoBD
FROM FILE = 'D:\tmp\BKCERT.cer'
WITH PRIVATE KEY (FILE = 'D:\tmp\BK_Key.pvk',
DECRYPTION BY PASSWORD = '1234')



---Visualiza a detalle el tipo de backup y otros detalles
restore headeronly from disk = 'D:\Adventure.bak'

--Muestra una lista de todos los backup dentro del archivo y que tipo son
Restore FileListOnly from disk = 'D:\Northwind.bak'


