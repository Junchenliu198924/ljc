/*===============================================
|1|创建跑批任务主表
================================================*/
CREATE TABLE TASK_PROCESS 
(
  TASK_ID NUMBER NOT NULL 
, TASK_NAME VARCHAR2(60 BYTE) 
, PROCESS_NO NUMBER NOT NULL 
, PROCESS_CONTENT VARCHAR2(1000 BYTE) 
, PROCESS_REMARK VARCHAR2(200 BYTE) 
, CREATE_DATE DATE DEFAULT sysdate 
, PROCESS_TYPE VARCHAR2(50 BYTE) 
, B_COL2 VARCHAR2(50 BYTE) 
, B_COL3 VARCHAR2(50 BYTE) 
) 
LOGGING 
TABLESPACE TASK_SPACE 
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOCOMPRESS 
NOPARALLEL;

COMMENT ON TABLE TASK_PROCESS IS '跑批任务主表';

COMMENT ON COLUMN TASK_PROCESS.TASK_ID IS '任务id';

COMMENT ON COLUMN TASK_PROCESS.TASK_NAME IS '任务名称';

COMMENT ON COLUMN TASK_PROCESS.PROCESS_NO IS '步骤序号id';

COMMENT ON COLUMN TASK_PROCESS.PROCESS_CONTENT IS '执行跑批内容';

COMMENT ON COLUMN TASK_PROCESS.PROCESS_REMARK IS '跑批内容说明';

COMMENT ON COLUMN TASK_PROCESS.CREATE_DATE IS '建立日期';

COMMENT ON COLUMN TASK_PROCESS.PROCESS_TYPE IS '跑批内容种类-1为sql-2为存储过程-3为其他';

COMMENT ON COLUMN TASK_PROCESS.B_COL2 IS '备用2';

COMMENT ON COLUMN TASK_PROCESS.B_COL3 IS '备用3';




/*===============================================
|2|
================================================*/