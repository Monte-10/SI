-- Sabiendo que los precios de las películas se han ido incrementando un 2% anualmente, elaborar la consulta setPrice.sql que complete la columna 'price' de la tabla 'orderdetail', sabiendo que el precio actual es el de la tabla 'products'.
UPDATE orderdetail
SET price = products.price * (1 + 0.02 * EXTRACT(YEAR FROM orderdetail.orderdate - current_date))
FROM products
WHERE orderdetail.productid = products.productid;