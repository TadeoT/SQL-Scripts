
---EJERCICIO 1---
DROP FUNCTION obtenerPrecio(varchar(6))
CREATE OR REPLACE FUNCTION obtenerPrecio (
    IN id_title varchar(6)

)
RETURNS setof  titles.price%TYPE

LANGUAGE plpgsql

AS

$$
BEGIN
	RETURN QUERY 
	SELECT titles.price
                    FROM titles 
                    WHERE titles.title_id = id_title;
END;
$$;     


SELECT obtenerPrecio('PS1372');

-------------------------------------------------------------

DROP PROCEDURE buscarPrecio
ALTER PROCEDURE buscarPrecio (
	@codigo_title char(6),
	@precio_title float OUTPUT
)
AS
	SELECT @precio_title = titles.price FROM titles WHERE titles.title_id = @codigo_title

	IF @@ROWCOUNT = 0
		RETURN 70
	IF @precio_title IS NULL
		RETURN 71
	RETURN 0
	
DECLARE @precio float
EXECUTE buscarPrecio  'PS1372', @precio OUTPUT
SELECT CONVERT(varchar, @precio)


---EJERCICIO 2---

DROP FUNCTION fecha_venta(char, varchar)
CREATE OR REPLACE FUNCTION fecha_venta (
    IN v_stor_id sales.stor_id%TYPE,
    IN v_ord_num sales.ord_num%TYPE
)
    RETURNS setof sales
    LANGUAGE plpgsql

AS

$$
BEGIN
    RETURN QUERY
    SELECT * FROM sales WHERE sales.stor_id = v_stor_id AND sales.ord_num = v_ord_num;

END;
$$;

SELECT fecha_venta ('7067','P2121')


---EJERCICIO 3---
DROP PROCEDURE buscarPrecio
CREATE PROCEDURE buscarPrecio(
	@codigo_producto int,
	@precio_producto float OUTPUT
	)
	AS
	
	select @precio_producto = productos.precUnit from productos where productos.codProd = @codigo_producto
	if @@RowCount = 0
		begin 
			print 'no se encontro producto para el id ' + CONVERT(varchar,@codigo_producto)
			return 1
		END
	if @precio_producto = NULL
		begin 
			print 'el producto '+ @codigo_producto + ' no tiene precio'
			return 2
		END
	return 0
	
DECLARE @precio_obtenido FLOAT
EXECUTE buscarPrecio 10 , @precio_obtenido OUTPUT
SELECT 'El precio del producto es ' + CONVERT(VARCHAR,@precio_obtenido)

DROP PROCEDURE insertarDetalle
ALTER PROCEDURE insertarDetalle(
	@codigo_detalle int,
	@numero_pedido int,
	@codigo_producto int,
	@cantidad int
	)
	AS
	DECLARE @precio_producto FLOAT,
			@retorno int
	EXECUTE @retorno = buscarprecio @codigo_producto, @precio_producto OUTPUT

		if @retorno = 1
			begin
				print 'retorno 1'
				return
			END
		if @retorno = 2
			begin
				print 'retorno 2'
				return
			END
		if @retorno = 0
			begin 
				declare @stockViejo int,
						@stockNuevo int
				select @stockViejo = productos.stock FROM productos where productos.codProd = @codigo_producto
				set @stockNuevo = (@stockViejo - @cantidad)
				PRINT 'stock viejo '+ CONVERT(VARCHAR,@stockViejo) + ', el stock nuevo es ' +CONVERT(VARCHAR,@stockNuevo)
				BEGIN TRY
					BEGIN TRANSACTION 
						UPDATE productos set productos.stock = @stockNuevo where productos.codProd = @codigo_producto
						INSERT detalle VALUES (@codigo_detalle,@numero_pedido,@codigo_producto,@cantidad,@cantidad*@precio_producto)
					COMMIT TRANSACTION 
				END TRY
				BEGIN CATCH 
					PRINT 'NO SE PUDO REALIZAR LA OPERACION'
					ROLLBACK TRANSACTION 
					RETURN
				END CATCH
				if @@RowCount = 1
					PRINT 'Se inserto una Fila '
				RETURN
				end
select * from detalle
EXECUTE insertarDetalle 1540, 120, 10, 2
