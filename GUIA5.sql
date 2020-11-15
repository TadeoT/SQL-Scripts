

---EJERCICIO 1---

DECLARE cursorT CURSOR 
        FOR 
            SELECT titles.price, titles.pub_id FROM titles WHERE titles.pub_id = '0736'
        FOR UPDATE

DECLARE @precioTitulo float,
        @idTitulo char(4);

OPEN cursorT

FETCH NEXT
    FROM cursorT
    INTO @precioTitulo,@idTitulo

WHILE @@fetch_status = 0
    BEGIN 
    IF @precioTitulo < 10
        UPDATE titles
            SET price = price*1.25
            WHERE CURRENT OF cursorT
    ELSE
        UPDATE titles
            SET price = price*0.75
            WHERE CURRENT OF cursorT
    FETCH NEXT
        FROM cursorT
        INTO @precioTitulo,@idTitulo
END
CLOSE cursorT
DEALLOCATE cursorT


--- EJERCICIO 2  ----

CREATE OR REPLACE FUNCTION aumentar_precios()
    RETURNS void
    language plpgsql
    AS 
    $$
    DECLARE  cursorT RECORD;
    BEGIN

        FOR cursorT IN SELECT price, pub_id, title_id FROM titles WHERE pub_id = '0736' LOOP
            IF cursorT.price < 10 THEN 
                UPDATE titles
                    SET price = price * 1.25
                    WHERE cursorT.title_id = title_id;
            END IF;
            IF cursorT.price > 10 THEN 
                UPDATE titles
                    SET price = price * 0.75
                    WHERE cursorT.title_id = title_id;
            END IF;
        END LOOP;
    END;
    $$

--- EJERCICIO 3---
DECLARE cursorTipos CURSOR 
    FOR 
        SELECT DISTINCT  type FROM titles 

DECLARE @tipo char(12);
		

OPEN cursorTipos

FETCH NEXT
    FROM cursorTipos
    INTO @tipo

WHILE @@fetch_status = 0
    BEGIN 
		print 'Publicaciones más caras de tipo ' + @tipo
        SELECT TOP 3 titles.price  FROM titles WHERE titles.type = @tipo ORDER BY price DESC

        FETCH NEXT
        FROM cursorTipos
        INTO @tipo
    
END
CLOSE cursorTipos
DEALLOCATE cursorTipos

--- EJERCICIO 4 ---

DECLARE cursorA CURSOR
    FOR 
	SELECT a.au_id,a.au_lname,a.city FROM authors a;

DECLARE @idAutor varchar(11),
        @nombreAutor char(120),
        @cuidadAutor char(20);

OPEN cursorA

FETCH NEXT  
    FROM cursorA
    INTO @idAutor, @nombreAutor, @cuidadAutor
WHILE @@fetch_status = 0
    BEGIN
        IF @cuidadAutor IN (SELECT authors.au_id, publishers.city FROM authors 
                            INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
                            INNER JOIN titles ON titleauthor.title_id = titles.title_id
                            INNER JOIN publishers ON titles.pub_id = publishers.pub_id
	                        WHERE authors.au_id = @idAutor)
            print 'El Autor '+ @nombreAutor + ' Vive en la misma Cuidad que publican sus Publicaciones'
        FETCH NEXT  
        FROM cursorA
        INTO @idAutor, @nombreAutor, @cuidadAutor
    END
CLOSE cursorA
DEALLOCATE cursorA



