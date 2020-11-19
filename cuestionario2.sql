

--- QUE TENGAN PUBLICACIONES
SELECT authors.au_id, authors.au_fname, authors.au_lname FROM authors 
        WHERE authors.au_id IN (SELECT titleauthor.au_id FROM titleauthor)

--- QUE TENGAN PUBLICACIONES EN 1993 - 1994
SELECT A.au_id, A.au_fname, A.au_lname from authors A
	where EXISTS (SELECT * from sales INNER JOIN titles ON titles.title_id = sales.title_id
									 INNER JOIN titleauthor TA ON titles.title_id = TA.title_id
									 WHERE YEAR(ord_date) IN (1993,1994) AND  A.au_id = TA.au_id)

--- QUE NO SEAN COAUTORES
SELECT author.au_id, author.au_fname, author.au_lname from authors
    WHERE NOT EXISTS (SELECT * FROM titlesauthor WHERE titleauthor.royaltyper <> 100 AND titleauthor.au_id = author.au_id )
									 
--- QUE TENGAN MENOS DE 25 VENTAS 
SELECT authors.au_id , authors.au_fname, authors.au_lname from authors
    WHERE 25 > ALL (SELECT SUM(sales.qty) FROM sales 
                INNER JOIN titles ON titles.title_id = sales.title_id
                INNER JOIN titleauthor ON titleauthor.title_id = titles.title_id 
                WHERE titleauthor.au_id = authors.au_id AND sales.ord_date BETWEEN  '1993-1-1'  AND  '1994-12-31'
                GROUP BY titles.title_id )

---- 

--- QUERY PARA EL CURSOR (LO AUTHORES QUE TENGO QUE BORRAR)

SELECT A1.au_id , A1.au_fname, A1.au_lname from authors A1
    WHERE --- QUE TENGAN PUBLICACIONES
            A1.au_id IN (SELECT T1.au_id FROM titleauthor T1)
            
            AND
            --- QUE TENGAN PUBLICACIONES EN 1993 - 1994
            EXISTS (SELECT * from sales INNER JOIN titles ON titles.title_id = sales.title_id
                                                INNER JOIN titleauthor TA ON titles.title_id = TA.title_id
                                                WHERE YEAR(ord_date) IN (1993,1994) AND  A1.au_id = TA.au_id)

            AND
            --- QUE NO SEAN COAUTORES
            NOT EXISTS (SELECT * FROM titleauthor T2 WHERE T2.royaltyper <> 100 AND T2.au_id = A1.au_id )

            AND                                 
            --- QUE TENGAN MENOS DE 25 VENTAS 
            25 > ALL (SELECT SUM(S3.qty) FROM sales S3
                            INNER JOIN titles T3 ON T3.title_id = S3.title_id
                            INNER JOIN titleauthor TA3 ON TA3.title_id = T3.title_id 
                            WHERE TA3.au_id = A1.au_id AND S3.ord_date BETWEEN  '1993-1-1'  AND  '1994-12-31'
                            GROUP BY T3.title_id )

--- PROCEDURES DE ELIMINACION 
CREATE PROCEDURE EliminarPublicacion(
	@id_title varchar(6)
)
AS	
	BEGIN TRY
		--DELETE sales WHERE title_id = @id_title
		--DELETE roysched WHERE title_id = @id_title
		--DELETE titleauthor WHERE title_id = @id_title
		--DELETE titles WHERE title_id = @id_title
		RETURN 0
	END TRY
	BEGIN CATCH 
		EXECUTE usp_GetErrorInfo
		RETURN @@Error
	END CATCH
	

CREATE PROCEDURE EliminarAutor(
    @id_autor varchar(12)
)
AS 
    BEGIN TRY 
        --DELETE Author WHERE Author.au_id = @id_autor
        RETURN 0 
    END TRY

    BEGIN CATCH
        EXECUTE usp_GetErrorInfo
        RETURN @@Error
    END CATCH


------------------------------ BATCH PRINCIPAL  --------------------------------------------------


DECLARE cursorAutores CURSOR 
    FOR SELECT A1.au_id , A1.au_fname, A1.au_lname from authors A1
        WHERE --- QUE TENGAN PUBLICACIONES
            A1.au_id IN (SELECT T1.au_id FROM titleauthor T1)
            
            AND
            --- QUE TENGAN PUBLICACIONES EN 1993 - 1994
            EXISTS (SELECT * from sales INNER JOIN titles ON titles.title_id = sales.title_id
                                                INNER JOIN titleauthor TA ON titles.title_id = TA.title_id
                                                WHERE YEAR(ord_date) IN (1993,1994) AND  A1.au_id = TA.au_id)

            AND
            --- QUE NO SEAN COAUTORES
            NOT EXISTS (SELECT * FROM titleauthor T2 WHERE T2.royaltyper <> 100 AND T2.au_id = A1.au_id )

            AND                                 
            --- QUE TENGAN MENOS DE 25 VENTAS 
            25 > ALL (SELECT SUM(S3.qty) FROM sales S3
                            INNER JOIN titles T3 ON T3.title_id = S3.title_id
                            INNER JOIN titleauthor TA3 ON TA3.title_id = T3.title_id 
                            WHERE TA3.au_id = A1.au_id AND S3.ord_date BETWEEN  '1993-1-1'  AND  '1994-12-31'
                            GROUP BY T3.title_id )
    
    DECLARE @id_autor varchar(11),
            @nombre_autor varchar (40),
            @apellido_autor varchar (20);
    
    OPEN cursorAutores
    
    FETCH NEXT
        FROM cursorAutores
        INTO @id_autor, @nombre_autor, @apellido_autor

    BEGIN TRANSACTION 
    WHILE @@fetch_status = 0
    BEGIN
        print 'procesando el autor ' + @id_autor + @nombre_autor + @apellido_autor

            ----------------------- CURSOR DE PUBLICACIONES------------------------ 
            DECLARE cursorPublicaciones CURSOR
                FOR SELECT T4.title_id  FROM titles T4
                                            INNER JOIN titleauthor TA4 ON T4.title_id = TA4.title_id 
                                            INNER JOIN authors A4 ON TA4.au_id = A4.au_id
                    WHERE A4.au_id = @id_autor

                DECLARE @id_publicacion varchar(6);

                OPEN cursorPublicaciones

                FETCH NEXT
                FROM cursorPublicaciones
                INTO @id_publicacion

                WHILE @@fetch_status = 0
                BEGIN
                    print 'procesando publicacion ' + @id_publicacion

                    DECLARE @retorno int
                    EXECUTE @retorno = EliminarPublicacion @id_publicacion
                    print 'Eliminacion publicacion ' + CONVERT (VARCHAR, @retorno)
                    IF @retorno != 0
                        BEGIN
                            RAISERROR ('Error no se pudo eliminar la publicacion o sus dependencias',15 , 0)
                            ROLLBACK TRANSACTION
                            RETURN 
                        END



                    FETCH NEXT
                    FROM cursorPublicaciones
                    INTO @id_publicacion

                END
                CLOSE cursorPublicaciones
                DEALLOCATE cursorPublicaciones

            ---------------- FIN CURSOR --------------------------------------
        EXECUTE @retorno = EliminarAutor @id_autor
        print 'Eliminacion del Autor valor de retorno ' + CONVERT (VARCHAR, @retorno)
        IF @retorno != 0
            BEGIN
                RAISERROR('Error al eliminar el Autor ', 15 , 0)
                ROLLBACK TRANSACTION
                RETURN 
            END 
        FETCH NEXT
        FROM cursorAutores
        INTO @id_autor, @nombre_autor, @apellido_autor
    
        END
    COMMIT TRANSACTION
    CLOSE cursorAutores
    DEALLOCATE cursorAutores





CREATE PROCEDURE obtenerID
	@nombreTabla varchar (20)
	AS 
		DECLARE @Ultimo int
		BEGIN TRY
			SELECT @Ultimo = Ultimo FROM Setup WHERE Tabla = @nombreTabla
			UPDATE setup set Ultimo = @Ultimo + 1
		END TRY
		BEGIN CATCH
			EXECUTE	usp_GetErrorInfo
			RETURN -100
		END CATCH
		
		RETURN @Ultimo
		

CREATE TRIGGER InsertarBadSeller
    on Authors
    AFTER DELETE
    AS 
        DECLARE @ultimo Integer , @au_idOLD varchar (12), @au_lname varchar (40), @au_fname varchar (20)
        EXECUTE @ultimo = obtenerID 'AutoresBadSeller'

        IF @ultimo != 100 
            BEGIN 
                SELECT @au_idOLD = au_id, @au_fname = au_fname ,@au_lname = au_lname FROM DELETED 
                
                BEGIN TRY
                    INSERT AutoresBadSeller (IDAutor, au_idViejo, au_fname, au_lname)
                    VALUES (@ultimo, @au_idOLD, @au_fname, @au_lname)
                END TRY
                
                BEGIN CATCH
                    EXECUTE usp_GetErrorInfo
                    ROLLBACK TRANSACTION
                    RETURN
                END CATCH
            
            END
        ELSE 
            BEGIN
                RAISERROR ('Error en recuperacion de ULTIMO ID ',15 , 0)
                ROLLBACK TRANSACTION 
            END










------------------------------------ PRIMER CURSOR ----------------------------------
--- ESTE CURSOR SE ME OCURRIO AL PRINCIPIO ANTES DE VER LA CLASE DEL MARTES, EN EL CUAL INTENTABA ENCONTRAR POR CADA 
-- AUTOR TODAS SUS PUBLICACIONES Y VERIFICABA SI SUS VENTAS ERAN MAYOR O MENOR A 25 ( MI IDEA PRINCIPAL FUE HACER ESO 
--- Y POSTERIORMENTE IBA A RECORRER CADA AUTOR Y HACER LAS CORRESPONDIENTES VALIDACIONES), DEJO EVIDENCIA DE MI ERROR.
CREATE PROCEDURE consultaEliminacion (
    @id_autor varchar(11)
)

AS
    DECLARE cursorT CURSOR 
            FOR SELECT titles.title_id FROM titleauthor
								   INNER JOIN titles ON titleauthor.title_id = titles.title_id WHERE  titleauthor.au_id = @id_autor

    DECLARE @id_titulo varchar(6);
            @cantidad int;
    
    OPEN cursorT 

    FETCH NEXT 
        FROM cursorT
        INTO @id_titulo

    WHILE @@fetch_status = 0 
        BEGIN 
            set @cantidad = (SELECT SUM(sales.qty) FROM titles 
                INNER JOIN sales ON sales.title_id = titles.title_id 
                where titles.title_id = @id_titulo AND sales.ord_date BETWEEN  '1993-1-1'  and  '1994-12-31'  )
            
            IF @cantidad NOT NULL and @cantidad< 25

                print 'el titulo vendio menos de 25 ' + @id_titulo
            ELSE 
                print 'el titulo vendio MAS de 25 ' + @id_titulo
                
        FETCH NEXT 
        FROM cursorT
        INTO @id_titulo
        
        END
    CLOSE cursorT
    DEALLOCATE cursorT


