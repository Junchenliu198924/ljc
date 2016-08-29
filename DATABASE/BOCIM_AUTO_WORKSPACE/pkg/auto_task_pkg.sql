
 /*===============================================
  跑批主包
  ================================================*/
create or replace PACKAGE AUTO_TASK_PKG
AS
type array_content      is table  of   varchar2(1000);
  /*===============================================
  主任务跑批过程
  ================================================*/
  PROCEDURE execute_task(
      p_task_id IN NUMBER ) ;
  /*===============================================
  处理用户输入的执行内容,返回一个可行的字符串数组
  ================================================*/
FUNCTION convert_string_usable(
     -- user_string_in IN task_process.process_content%type ) RETURN array_content;
      user_string_in IN  varchar2) RETURN array_content;

END AUTO_TASK_PKG;


create or replace PACKAGE BODY AUTO_TASK_PKG AS
PROCEDURE  execute_task(p_task_id   in  number  )  AS
      current_type        task_process.process_type%TYPE    ; 
      current_content     task_process.process_content%type   ; 
      ---需要执行的命令序列组
      current_content_array  array_content:=array_content();
      cursor   process_content_cur  
        is 
        SELECT     task_id ,
        task_name ,
        process_no ,
        process_content ,
        process_remark ,
        create_date ,
        process_type ,
        b_col2 ,
        b_col3    FROM task_process   WHERE  task_id = p_task_id ORDER BY   process_no asc   ; 
      process_content_rec   process_content_cur%ROWTYPE;
      task_index    integer:=0;
      process_index integer:=0;
      task_content  task_process.process_content%type ; 
  BEGIN
    --读取任务表中的对应任务的执行步骤一次进行执行
    open  process_content_cur   ; 
    LOOP
    FETCH    process_content_cur   into   process_content_rec  ;
    EXIT WHEN   process_content_cur%NOTFOUND  ;
    --计入当前的处理步骤
    process_index:=process_content_rec.process_no;
    
    ---条件为sql的执行条件    
    if       process_content_rec.process_type ='1'
    then 
    
      current_content := process_content_rec.process_content ; 
      ---得到执行内容数组
      current_content_array := convert_string_usable(current_content);
      ---循环进行执行
      if(current_content_array.count>0)
        then 
          WHILE task_index <current_content_array.count
                  LOOP
                    task_index   :=task_index+1;
                    task_content :=current_content_array(task_index);
                    EXECUTE immediate 'begin  '||task_content||'  END;';
                    dbms_output.put_line('执行步骤'||process_index||'的第'||task_index||'任务完成!内容为'||task_content);

                  END LOOP;
        end if ; 
    ---条件为存储过程的执行条件
    elsif   process_content_rec.process_type = '2' 
    then 
      current_content := process_content_rec.process_content ; 
      ---得到执行内容数组
      current_content_array := convert_string_usable(current_content);
      ---循环进行执行
      if(current_content_array.count>0)
        then 
          task_index:=task_index+1;
          task_content :=current_content_array(task_index);
          execute immediate  'begin  '||task_content||'  END;';
          
        end if ; 
    end if ;
    END LOOP;
    CLOSE process_content_cur;
    dbms_output.put_line('task-end');
    exception
      when error_pkg.invalid_table_name then
        dbms_output.put_line('执行步骤'||process_index||'的第'||task_index||'任务时执行出错跳出!内容为'||task_content);
      when error_pkg.execute_task then
        
        dbms_output.put_line('执行步骤'||process_index||'的第'||task_index||'任务时执行出错内容为'||task_content);
    
    END execute_task;

FUNCTION convert_string_usable(
      ---传入跑批的sql语句内容
      ---user_string_in IN task_process.process_content%type ) RETURN  array_content
      user_string_in IN  varchar2) RETURN array_content
      is 
        processed_string   varchar2(1000) ;  
        previous_location   number :=0 ;
        content_location   number :=0  ; 
        result_array  array_content:=array_content();
        array_index number :=0;
        begin 
        --判断最后一个字符是否是;
        if(regexp_like(trim(user_string_in),'([a-z A-Z]*;){1}$'))
        then 
        processed_string :=  trim(user_string_in);
        else 
         processed_string :=  trim(user_string_in||';');
         end if ;
        --判断是否是多指令输入
        if(regexp_like(processed_string , '^(.*;)+(.*;){1}$'))
          then
            loop
              content_location :=instr(processed_string,';',content_location+1);
              exit when content_location =0;
              array_index := array_index+1;
              result_array.extend;
              dbms_output.put_line(substr(processed_string,previous_location+1,content_location-previous_location));
              result_array(array_index) :=substr(processed_string,previous_location+1,content_location-previous_location);
              previous_location:=content_location;
              end loop;
        else
          result_array.extend;
          array_index := array_index+1;
          result_array(array_index):=processed_string;
          dbms_output.put_line(processed_string);
        end if  ;
        return result_array ; 
         
   end convert_string_usable;
      
      
      
END AUTO_TASK_PKG;