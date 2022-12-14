CREATE 
OR REPLACE FUNCTION updInventoryAndCustomerAlert () RETURNS TRIGGER AS $$ BEGIN INSERT INTO alerts (prod_id, date_time) 
SELECT 
  inventory.prod_id, 
  CURRENT_TIMESTAMP 
FROM 
  inventory 
WHERE 
  inventory.stock = 0 
  AND inventory.prod_id = NEW.prod_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql STRICT;
DROP 
  TRIGGER IF EXISTS updInventoryAndCustomerAlert ON inventory;
CREATE TRIGGER updInventoryAndCustomerAlert 
AFTER 
UPDATE 
  ON inventory FOR EACH ROW EXECUTE PROCEDURE updInventoryAndCustomerAlert ();
--NUEVO CUSTOMER. CREAR NUEVO CARRITO VACIO PARA EL NUEVO CUSTOMER
CREATE 
OR REPLACE FUNCTION updInventoryAndCustomerNewCustomer () RETURNS TRIGGER AS $$ BEGIN INSERT INTO orders (
  orderdate, customerid, netamount, 
  tax, totalamount, status
) 
VALUES 
  (
    CURRENT_DATE, NEW.customerid, 0, 15, 
    0, NULL
  );
RETURN NEW;
END;
$$ LANGUAGE plpgsql STRICT;
DROP 
  TRIGGER IF EXISTS updInventoryAndCustomerNewCustomer ON customers;
CREATE TRIGGER updInventoryAndCustomerNewCustomer 
AFTER 
  INSERT ON customers FOR EACH ROW EXECUTE PROCEDURE updInventoryAndCustomerNewCustomer ();
--CUANDO SE HACE INSERT/UPDATE/DELETE EN ORDERDETAILS, INVENTORY TIENE QUE SER MODIFICADO
CREATE 
OR REPLACE FUNCTION updInventoryAndCustomerInventory () RETURNS TRIGGER AS $$ BEGIN IF (TG_OP = 'INSERT') THEN 
UPDATE 
  inventory 
SET 
  stock = stock - NEW.quantity 
WHERE 
  inventory.prod_id = NEW.prod_id;
RETURN NEW;
ELSIF (TG_OP = 'UPDATE') THEN 
UPDATE 
  inventory 
SET 
  stock = stock + OLD.quantity - NEW.quantity 
WHERE 
  inventory.prod_id = OLD.prod_id 
  AND inventory.prod_id = NEW.prod_id;
RETURN NEW;
ELSIF (TG_OP = 'DELETE') THEN 
UPDATE 
  inventory 
SET 
  stock = stock + OLD.quantity 
WHERE 
  inventory.prod_id = OLD.prod_id;
RETURN NEW;
ELSE RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql STRICT;
DROP 
  TRIGGER IF EXISTS updInventoryAndCustomerInventory ON orderdetail;
CREATE TRIGGER updInventoryAndCustomerInventory 
AFTER 
  DELETE 
  OR INSERT 
  OR 
UPDATE 
  ON orderdetail FOR EACH ROW EXECUTE PROCEDURE updInventoryAndCustomerInventory ();
--ACTUALIZAR SALES DE INVENTORY CUANDO SE COMPRA UN ORDER
CREATE 
OR REPLACE FUNCTION updInventoryAndCustomerSales () RETURNS TRIGGER AS $$ DECLARE rcord RECORD;
BEGIN FOR rcord IN 
SELECT 
  prod_id, 
  quantity 
FROM 
  orderdetail 
WHERE 
  OLD.orderid = orderdetail.orderid LOOP 
UPDATE 
  inventory 
SET 
  sales = sales + rcord.quantity 
WHERE 
  prod_id = rcord.prod_id 
  AND NEW.status = 'Paid';
END LOOP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql STRICT;
DROP 
  TRIGGER IF EXISTS updInventoryAndCustomerSales ON orders;
CREATE TRIGGER updInventoryAndCustomerSales 
AFTER 
UPDATE 
  ON orders FOR EACH ROW EXECUTE PROCEDURE updInventoryAndCustomerSales ();
--ACTUALIZAR LOS NUEVOS PUNTOS DE LOYALTY AL CUSTOMER CUANDO SE PAGA UNA ORDER
CREATE 
OR REPLACE FUNCTION updInventoryAndCustomerLoyalty () RETURNS TRIGGER AS $$ BEGIN 
UPDATE 
  customers 
SET 
  loyalty = loyalty + FLOOR(NEW.totalamount * 0.05) 
WHERE 
  customers.customerid = NEW.customerid 
  AND NEW.status = 'Paid';
RETURN NEW;
END;
$$ LANGUAGE plpgsql STRICT;
DROP 
  TRIGGER IF EXISTS updInventoryAndCustomerLoyalty ON orders;
CREATE TRIGGER updInventoryAndCustomerLoyalty 
AFTER 
UPDATE 
  ON orders FOR EACH ROW EXECUTE PROCEDURE updInventoryAndCustomerLoyalty ();
--RECUCIR EL BALANCE DEL CUSTOMER CUADNO COMPRA
CREATE 
OR REPLACE FUNCTION updInventoryAndCustomerBalance () RETURNS TRIGGER AS $$ BEGIN 
UPDATE 
  customers 
SET 
  balance = balance - NEW.totalamount 
WHERE 
  customers.customerid = NEW.customerid 
  AND NEW.status = 'Paid';
RETURN NEW;
END;
$$ LANGUAGE plpgsql STRICT;
DROP 
  TRIGGER IF EXISTS updInventoryAndCustomerBalance ON orders;
CREATE TRIGGER updInventoryAndCustomerBalance 
AFTER 
UPDATE 
  ON orders FOR EACH ROW EXECUTE PROCEDURE updInventoryAndCustomerBalance ();