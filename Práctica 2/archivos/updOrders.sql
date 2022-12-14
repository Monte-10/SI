CREATE OR REPLACE FUNCTION updOrders ()
    RETURNS TRIGGER
    AS $$
DECLARE
    aux_price numeric;
    aux_id integer;
BEGIN
    --calcula el precio
    IF (TG_OP = 'INSERT') THEN
        aux_price = NEW.quantity * NEW.price;
        aux_id = NEW.orderid;
    ELSIF (TG_OP = 'UPDATE') THEN
        aux_price = (NEW.quantity * NEW.price) - (OLD.quantity * OLD.price);
        aux_id = NEW.orderid;
    ELSIF (TG_OP = 'DELETE') THEN
        aux_price = 0 - (OLD.quantity * OLD.price);--para que reste cuando actualice en vez de sumar
        aux_id = OLD.orderid;
    END IF;
    --actualiza los valores
    UPDATE
        orders
    SET
        netamount = netamount + aux_price
    WHERE
        orderid = aux_id;
    UPDATE
        orders
    SET
        totalamount = netamount * (1 + tax * 0.01) 
    WHERE
        orderid = aux_id;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql
STRICT;

DROP TRIGGER IF EXISTS updOrders ON orderdetail;

CREATE TRIGGER updOrders
    AFTER DELETE OR INSERT OR UPDATE ON orderdetail
    FOR EACH ROW
    EXECUTE PROCEDURE updOrders ();