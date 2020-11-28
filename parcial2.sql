SELECT titles.title_id FROM Publishers 
											INNER JOIN titles ON titles.pub_id = publishers.pub_id
											WHERE publishers.pub_id = '0736'
											ORDER BY titles.price ASC
											LIMIT 1
SELECT titles.title_id FROM Publishers 
											INNER JOIN titles ON titles.pub_id = publishers.pub_id
											WHERE publishers.pub_id = '0736'
											ORDER BY titles.price DESC
											LIMIT 1

SELECT SUM(sales.qty * titles.price)  FROM Publishers 
		INNER JOIN titles ON titles.pub_id = publishers.pub_id
		INNER JOIN sales ON sales.title_id = titles.title_id
		WHERE publishers.pub_id = '0736'
		GROUP BY publishers.pub_id


SELECT count(*)  FROM Publishers 
		INNER JOIN titles ON titles.pub_id = publishers.pub_id
		INNER JOIN sales ON sales.title_id = titles.title_id
		WHERE publishers.pub_id = '0736'
											
CREATE TYPE publisherResp AS (pub_id CHAR(4),
                            mintitle numeric,
                            maxtitle numeric,
                             totalPrice numeric ); 

CREATE OR REPLACE FUNCTION ejercicio1()
    RETURNS void
    language plpgsql
    AS 
    $$
    DECLARE  cursorE RECORD;
    BEGIN

        FOR cursorE IN SELECT Select publishers.pub_id from publishers LOOP
            print SELECT titles.title_id FROM Publishers 
											INNER JOIN titles ON titles.pub_id = publishers.pub_id
											WHERE publishers.pub_id = cursorE.pub_id
											ORDER BY titles.price ASC
											LIMIT 1
            print SELECT titles.title_id FROM Publishers 
											INNER JOIN titles ON titles.pub_id = publishers.pub_id
											WHERE publishers.pub_id = cursorE.pub_id
											ORDER BY titles.price DESC
											LIMIT 1

            print ((SELECT SUM(sales.qty * titles.price)  FROM Publishers 
                    INNER JOIN titles ON titles.pub_id = publishers.pub_id
                    INNER JOIN sales ON sales.title_id = titles.title_id
                    WHERE publishers.pub_id = cursorE.pub_id
                    GROUP BY publishers.pub_id )
                    /
            (SELECT count(*)  FROM Publishers 
                    INNER JOIN titles ON titles.pub_id = publishers.pub_id
                    INNER JOIN sales ON sales.title_id = titles.title_id
                    WHERE publishers.pub_id = cursorE.pub_id))
                        
        END LOOP;
    END;
    $$



    create TYPE publisherResp AS (pub_id CHAR(4),
                            mintitle varchar(6),
                            maxtitle varchar(6),
                             totalPrice numeric ); 

CREATE OR REPLACE FUNCTION ejercicio1()
    RETURNS setof publisherResp
    language plpgsql
    AS 
    $$
    DECLARE  cursorE RECORD;
	DECLARE fila publisherResp%rowtype;
    BEGIN
        FOR cursorE IN SELECT publishers.pub_id from publishers LOOP
			fila.pub_id = cursorE.pub_id
             fila.mintitle = SELECT titles.title_id FROM publishers 
											INNER JOIN titles ON titles.pub_id = publishers.pub_id
											WHERE publishers.pub_id = cursorE.pub_id
											ORDER BY titles.price ASC
											LIMIT 1
             fila.maxtitle = SELECT titles.title_id FROM Publishers 
											INNER JOIN titles ON titles.pub_id = publishers.pub_id
											WHERE publishers.pub_id = cursorE.pub_id
											ORDER BY titles.price DESC
											LIMIT 1

             fila.totalPrice = ((SELECT SUM(sales.qty * titles.price)  FROM Publishers 
                    INNER JOIN titles ON titles.pub_id = publishers.pub_id
                    INNER JOIN sales ON sales.title_id = titles.title_id
                    WHERE publishers.pub_id = cursorE.pub_id
                    GROUP BY publishers.pub_id )
                    /
            (SELECT count(*)  FROM Publishers 
                    INNER JOIN titles ON titles.pub_id = publishers.pub_id
                    INNER JOIN sales ON sales.title_id = titles.title_id
                    WHERE publishers.pub_id = cursorE.pub_id))
        RETURN NEXT fila;
        END LOOP;
    END;
    $$







CREATE PROCEDURE buscarPrecio(
	@codigo_producto int,
	@precio_producto float OUTPUT
	)
	AS
	
	select @precio_producto = productos.precUnit from productos where productos.codProd = @codigo_producto
	return
	
DECLARE @precio_obtenido FLOAT
EXECUTE buscarPrecio 10 , @precio_obtenido OUTPUT
SELECT 'El precio del producto es ' + CONVERT(VARCHAR,@precio_obtenido)

DROP PROCEDURE insertarDetalle
CREATE PROCEDURE insertarDetalle(
	@codigo_detalle int,
	@numero_pedido int,
	@codigo_producto int,
	@cantidad int
	)
	AS
	DECLARE @precio_producto FLOAT
	EXECUTE buscarprecio @codigo_producto, @precio_producto OUTPUT
	
	
		INSERT detalle VALUES (@codigo_detalle,@numero_pedido,@codigo_producto,@cantidad,@cantidad*@precio_producto)
		if @@RowCount = 1
			PRINT 'Se inserto una Fila '
		RETURN
		

CREATE PROCEDURE actualizarStock(
    @stor_id char(4),
    @ord_num varchar(20),
    @ord_date datetime,
    @cantidad integer,
    @payments varchar(12)
    @codigo_titulo varchar(6),

    AS
    IF select stock FROM titles where titles.title_id = @codigo_titulo <= @cantidad
        RETURN -1
    ELSE 
        BEGIN TRANSACTION 

        UPDATE titles  set (stock := stock-@cantidad) where titles.title_id = @codigo_titulo
        BEGIN TRY 
            INSERT Sales VALUES (   @stor_id char(4),
                                    ord_num varchar(20),
                                    ord_date datetime,
                                    @cantidad integer,
                                    @payments varchar(12)
                                    @codigo_titulo
                                    )
        END TRY


        BEGIN CATCH
			EXECUTE	usp_GetErrorInfo
			RETURN -1
            rollback TRANSACTION
		END CATCH
        commit TRANSACTION                                
)


select longitud*longitud from lado 
                inner join triangulo on triangulo.idtriangulo = lado.idtriangulo
                order by longitud 
                limit 1

select SUM(lado) from lado 
                inner join triangulo on triangulo.idtriangulo= lado1.idtriangulo
                order by longitud DESC
                
                limit 2