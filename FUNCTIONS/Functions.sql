CREATE OR REPLACE FUNCTION Is_Valid_Status_Transition (
    p_old_status IN VARCHAR2,
    p_new_status IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
    IF p_old_status = 'Pending' AND p_new_status IN ('Shipped', 'Cancelled') THEN
        RETURN TRUE;
    ELSIF p_old_status = 'Shipped' AND p_new_status = 'Delivered' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
/