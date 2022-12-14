CREATE OR REPLACE FUNCTION public.updInventoryAndCustomer() RETURNS trigger LANGUAGE 'plpgsql' AS $BODY$
BEGIN
  UPDATE public.inventory SET stock = (SELECT stock - orderdetail.quantity FROM public.orderdetail WHERE orderdetail.prod_id = inventory.prod_id),
  sales = (SELECT sales + orderdetail.quantity FROM public.orderdetail WHERE orderdetail.prod_id = inventory.prod_id);
  UPDATE public.customers SET balance = (SELECT balance - orders.totalamount FROM public.orders WHERE orders.customerid = customers.customerid);

  RETURN NULL;
END;$BODY$;

CREATE TRIGGER updInventoryAndCustomer AFTER UPDATE ON public.orders FOR EACH ROW WHEN (NEW.status = 'Paid') EXECUTE PROCEDURE public.updInventoryAndCustomer();