CREATE 
OR REPLACE FUNCTION setOrderAmount () RETURNS void AS $$ BEGIN WITH total AS (

  SELECT 
    orders.orderid AS o_id, 
    SUM(products.price) AS sum_price 
  FROM 
    orders 
    JOIN orderdetail ON orders.orderid = orderdetail.orderid 
    JOIN products ON products.prod_id = orderdetail.prod_id 
  GROUP BY 
    orders.orderid
) 
UPDATE 
  orders 
SET 
  netamount = total.sum_price, 
  totalamount = total.sum_price * (1 + tax * 0.01) 
FROM 
  total
WHERE 
  orders.orderid = total.o_id 
  AND orders.netamount IS NULL 
  AND orders.totalamount IS NULL;
END;
$$ LANGUAGE plpgsql STRICT;
