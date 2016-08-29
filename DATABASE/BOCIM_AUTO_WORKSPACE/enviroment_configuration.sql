----all design by  surpremeliu

1、用dba权限执行下面的脚本


-----------------------------------建立自动任务跑批基础表空间task_space-------------------------------------------------------
 
CREATE TABLESPACE task_space DATAFILE 'task_space.dat' SIZE 40M ONLINE; 
-----建立批处理任务用户task_admin_role
-- USER SQL
CREATE USER task_admin IDENTIFIED BY task_admin ;
-- QUOTAS
ALTER USER task_admin QUOTA UNLIMITED ON TASK_SPACE;
ALTER  USER   task_admin   default TABLESPACE   task_space   ; 


-----------------------------------建立自动跑批任务的授权角色task_admin_role--------------------------------------------------
CREATE ROLE  task_admin_role ;
--授予全部权限于task_admin角色
-- ROLES
GRANT "SELECT_CATALOG_ROLE" TO task_admin_role ;
GRANT "CONNECT" TO task_admin_role ;
-- SYSTEM PRIVILEGES
GRANT CREATE JOB TO task_admin_role ;
GRANT ALTER ANY INDEX TO task_admin_role ;
GRANT CREATE ROLE TO task_admin_role ;
GRANT CREATE TRIGGER TO task_admin_role ;
GRANT ALTER ANY PROCEDURE TO task_admin_role ;
GRANT DEBUG CONNECT SESSION TO task_admin_role ;
GRANT CREATE ANY MINING MODEL TO task_admin_role ;
GRANT ALTER SESSION TO task_admin_role ;
GRANT CREATE MATERIALIZED VIEW TO task_admin_role ;
GRANT CREATE ANY INDEX TO task_admin_role ;
GRANT ALTER ANY MATERIALIZED VIEW TO task_admin_role ;
GRANT DEBUG ANY PROCEDURE TO task_admin_role ;
GRANT CREATE ANY MEASURE FOLDER TO task_admin_role ;
GRANT CREATE VIEW TO task_admin_role ;
GRANT CREATE SESSION TO task_admin_role ;
GRANT CREATE TABLE TO task_admin_role ;
GRANT CREATE TYPE TO task_admin_role ;
GRANT CREATE TABLESPACE TO task_admin_role ;
GRANT CREATE PUBLIC DATABASE LINK TO task_admin_role ;
GRANT CREATE ANY JOB TO task_admin_role ;
GRANT CREATE PUBLIC SYNONYM TO task_admin_role ;
GRANT CREATE ANY SYNONYM TO task_admin_role ;
GRANT EXECUTE ANY PROCEDURE TO task_admin_role ;
GRANT EXECUTE ANY PROGRAM TO task_admin_role ;
GRANT CREATE SEQUENCE TO task_admin_role ;
GRANT CREATE ANY INDEXTYPE TO task_admin_role ;
GRANT CREATE ANY MATERIALIZED VIEW TO task_admin_role ;
GRANT CREATE ANY LIBRARY TO task_admin_role ;
GRANT CREATE PROCEDURE TO task_admin_role ;
-----把task_role这个角色授予用户task_admin
grant  task_admin_role to   task_admin   ; 

-----------------------------------创建一个序列--------------------------------------------------
CREATE SEQUENCE batch_no
INCREMENT BY 1 -- 每次加几个
START WITH 1 -- 从1开始计数
NOMAXvalue -- 不设置最大值
NOCYCLE -- 一直累加，不循环
NOCACHE  ; --设置缓存cache个序列，如果系统down掉了或者其它情况将会导致序列不连续

