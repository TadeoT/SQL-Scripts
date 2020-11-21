---EJERCICIO 2----
CREATE TRIGGER tr_ejercicio2
	ON authors2 
	FOR INSERT

	AS
		print 'Datos insertados en transaction log' 
		SELECT * FROM INSERTED
		
		
DELETE FROM authors2 WHERE au_id = '172-32-1176' or  au_id = '213-46-8915'

INSERT INTO authors2 SELECT '111-11-1111','Lynne','Jeff','415 658-9932', 'Galvez y Ochoa','Berkeley','CA','94705', 1

---EJERCICIO 3----
CREATE TRIGGER tr_ejercicio3
ON productos
FOR INSERT
AS
	DECLARE @stock INTEGER
	SELECT @stock = INSERTED.stock FROM INSERTED
	IF (@stock < 0 )
		BEGIN
			PRINT ('EL STOCK DEBE SER POSITIVO O CERO')
			ROLLBACK TRANSACTION
		END
		
--- EJERCICIO 4-------


CREATE TRIGGER tr_ejercicio4
ON titles
FOR INSERT
AS	
	DECLARE @id_pub CHAR(4)
	SELECT @id_pub = INSERTED.pub_id FROM INSERTED
	IF (@id_pub NOT IN  (SELECT p.pub_id FROM publishers p 
							INNER JOIN titles ON titles.pub_id = p.pub_id
							INNER JOIN sales ON sales.title_id = titles.title_id
							GROUP BY p.pub_id, p.pub_name
							HAVING 1800 < sum(sales.qty * titles.price)))
		BEGIN
			ROLLBACK TRANSACTION
		END

INSERT INTO titles  SELECT'PC4545','Prueba 1','trad_cook','1389',14.99, 8000.00, 10, 4095,'Prueba 1',CURRENT_TIMESTAMP
INSERT INTO titles  SELECT'PC4646','Prueba 2','trad_cook','0736',14.99, 8000.00, 10, 4095,'Prueba 1',CURRENT_TIMESTAMP

--- EJERCICIO 5-----

CREATE TRIGGER tr_ejercicio5
BEFORE
INSERT ON titles FOR EACH ROW
EXECUTE PROCEDURE testif();

CREATE FUNCTION testif()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$

BEGIN
	IF ( NEW.pub_id NOT IN (SELECT p.pub_id FROM publishers p 
							INNER JOIN titles ON titles.pub_id = p.pub_id
							INNER JOIN sales ON sales.title_id = titles.title_id
							GROUP BY p.pub_id, p.pub_name
							HAVING 1800 < sum(sales.qty * titles.price))) THEN
			RETURN NULL;
			RAISE notice 'CANCELADO';
		ELSE
			RAISE notice 'aceptado';
			RETURN NEW;
	END IF;
END
$$;


--- EJERCICIO 6 ----
CREATE TRIGGER tr_ejercicio6
BEFORE 
INSERT ON publishersv2
FOR EACH ROW
EXECUTE PROCEDURE agregarFechaYUsuario()

CREATE FUNCTION agregarFechaYUsuario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN	
	NEW.fechahoraalta := (SELECT CURRENT_TIMESTAMP);
	NEW.usuarioalta := SESSION_USER;

	RETURN NEW;

END
$$





