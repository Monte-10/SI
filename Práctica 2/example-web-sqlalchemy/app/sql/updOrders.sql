CREATE OR REPLACE FUNCTION public.updOrders() RETURNS trigger LANGUAGE 'plpgsql' AS $BODY$
BEGIN
    UPDATE public.orders SET netamount = (SELECT SUM(orderdetail.quantity * products.price) FROM public.orderdetail INNER JOIN public.products ON products.prod_id = orderdetail.prod_id WHERE orderdetail.order_id = orders.order_id);
    UPDATE public.orders SET totalamount = (netamount * 1.21)::float;
    RETURN NULL;
END;$BODY$;

CREATE TRIGGER updOrder AFTER INSERT OR UPDATE OR DELETE ON public.orderdetail FOR EACH ROW EXECUTE PROCEDURE public.updOrders();