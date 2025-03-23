SET SERVEROUTPUT ON
/
CREATE OR REPLACE PROCEDURE ROLE_CLEANUP_PROCEDURE AS
    CURSOR CUR_ROLES IS SELECT ROLE FROM DBA_ROLES WHERE ROLE LIKE 'ECOMM_%';
    CURSOR CUR_USERS IS SELECT USERNAME FROM DBA_USERS WHERE USERNAME LIKE 'ECOMM_%';
    CURSOR CUR_SESSIONS IS SELECT SID, SERIAL# FROM v$session WHERE USERNAME LIKE 'ECOMM_%';
BEGIN
    -- Kill active sessions
    FOR SESS IN CUR_SESSIONS LOOP
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || SESS.sid || ',' || SESS.serial# || ''' IMMEDIATE';
    END LOOP;

    -- Drop roles
    FOR ROL IN CUR_ROLES LOOP
        EXECUTE IMMEDIATE 'DROP ROLE ' || ROL.ROLE;
    END LOOP;

    -- Drop users
    FOR USR IN CUR_USERS LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || USR.USERNAME || ' CASCADE';
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Cleanup complete. Users and roles removed.');
END;
/
EXECUTE ROLE_CLEANUP_PROCEDURE;
/
