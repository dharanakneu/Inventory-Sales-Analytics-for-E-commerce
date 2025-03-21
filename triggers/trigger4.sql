
Prevent Deleting a Category if Products Exist in That Category
CREATE OR REPLACE TRIGGER prevent_delete_category
BEFORE DELETE ON Categories
FOR EACH ROW
DECLARE
  product_count INT;
BEGIN
  SELECT COUNT(*) INTO product_count FROM Products WHERE category_id = :OLD.category_id;
  IF product_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cannot delete category with associated products.');
  END IF;
END;
/
