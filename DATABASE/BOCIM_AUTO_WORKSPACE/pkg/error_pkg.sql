 /*===============================================
  常用报错工具包
  ================================================*/
CREATE OR REPLACE  PACKAGE ERROR_PKG AS 
      execute_task exception;
      PRAGMA EXCEPTION_INIT(execute_task,-6550);
      invalid_table_name exception;
      PRAGMA EXCEPTION_INIT(invalid_table_name,-903);
END ERROR_PKG;