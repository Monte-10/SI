UPDATE 
  orderdetail 
SET 
  price = products.price / POW(
    1.02, 
    (
      DATE_PART('year', CURRENT_DATE) - DATE_PART('year', orders.orderdate)
    )
  ) 
FROM 
  products, 
  orders 
WHERE 
  orderdetail.orderid = orders.orderid 
  AND orderdetail.prod_id = products.prod_id;
