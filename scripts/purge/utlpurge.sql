Rem
Rem NAME
REM    UTLPURGE.SQL
Rem  FUNCTION
Rem  NOTES
Rem  MODIFIED
Rem     jyoon      2012/11/26 - Added data looping detection logic
Rem     jyoon      2012/11/24 - Added span_tree_print & print_tree procedures
Rem     jyoon      2011/09/13 - Created
Rem
Rem  EXAMPLE
Rem     set line 180
Rem     set serverout on
Rem     /* To verify relationships and data volume before purge. */
Rem     exec utl_purge.print_tree('WHITNEY','PARTY','SELECT PARTY_KEY FROM WHITNEY.PARTY WHERE PARTY_ID = ''FCS300''');
Rem     
Rem     /* To purge data from a table including records from child tables */
Rem     exec utl_purge.purge_data_cascade('WHITNEY','PARTY','SELECT PARTY_KEY FROM WHITNEY.PARTY WHERE PARTY_ID = ''FCS300''');
Rem
Rem     /* To print logs */
Rem     exec utl_purge.print_log;
Rem

 
CREATE OR REPLACE package utl_purge as

    parallel_degree number  default 1;

    procedure initialize_env;

    procedure log_sql             ( p_caller varchar2 , p_sql_text varchar2 );

    procedure log_info            ( p_task              varchar2 default '', 
                                    p_caller            varchar2 default '', 
                                    p_message           varchar2 default '', 
                                    p_output            varchar2 default 'DB' );

    function get_tab_columns      ( p_owner varchar2, p_table_name varchar2 ) return varchar2;
    function get_ind_columns      ( p_owner varchar2 , p_index_name varchar2 ) return varchar2;

    procedure save_ind_ddl        ( p_owner varchar2 , p_table_name varchar2 );


    function get_cons_columns     ( p_owner varchar2 , p_constraint_name varchar2 ) return varchar2;

    procedure save_cons_ddl       ( p_owner             varchar2 , 
                                    p_table_name        varchar2 , 
                                    p_constraint_type   varchar2 default 'OTHERS');

    procedure print_tree          ( p_owner             varchar2 , 
                                    p_table_name        varchar2 , 
                                    p_query             varchar2 , 
                                    p_parallel_degree   number default 1,
                                    p_output            varchar2 default 'STDOUT' ) parallel_enable;

    procedure span_tree_print     ( p_owner             varchar2 , 
                                    p_table_name        varchar2 , 
                                    p_level             number    default 1 , 
                                    p_sequence          number    default 1 , 
                                    p_output            varchar2  default 'STDOUT') parallel_enable;

    procedure span_tree_remove    ( p_owner             varchar2 , 
                                    p_table_name        varchar2 , 
                                    p_level             number    default 1 , 
                                    p_sequence          number    default 1) parallel_enable;

    procedure purge_data_cascade  ( p_owner             varchar2 , 
                                    p_table_name        varchar2 , 
                                    p_query             varchar2 , 
                                    p_parallel_degree   number default 1) parallel_enable;


    procedure span_tree_remove_batch   ( p_owner             varchar2 ,
                                         p_table_name        varchar2 ,
                                         p_level             number    default 1 ,
                                         p_sequence          number    default 1) parallel_enable;

    procedure purge_data_cascade_batch ( p_owner             varchar2 ,
                                         p_table_name        varchar2 ,
                                         p_query             varchar2 ,
                                         p_parallel_degree   number default 1) parallel_enable;

    procedure trim_dead_branch ( p_owner           varchar2,
                                 p_fk_constraint   varchar2 , 
                                 p_parallel_degree number default 1 ) parallel_enable;

    procedure create_indexes;

    procedure create_constraints;

    procedure reorganize_obj        ( p_parallel_degree number default 1 );
 
end utl_purge;
/

CREATE OR REPLACE package body utl_purge
as

  procedure initialize_env
  is
  begin
      log_info ( 'INFO' , 'UTL_PURGE.INITIALIZE_ENV' , 'utl_purge.initialize_env' );


      execute immediate 'truncate table UTL$LIST_TREE_NODES';
      --execute immediate 'truncate table UTL$INDEXES';
      --execute immediate 'truncate table UTL$TABLES';
      --execute immediate 'truncate table UTL$CONSTRAINTS';

      for i in ( select tname from tab where tname like 'XXXX%' )
      loop
          execute immediate 'drop table '||i.tname||' purge';
      end loop;

  end;


  function get_constraint_columns ( p_owner varchar2 , p_constraint_name varchar2 )
  return varchar2
  as
  list_columns varchar2(4000);
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.GET_CONSTRAINT_COLUMNS' , 'utl_purge.get_constraint_columns('||p_owner||','||p_constraint_name||')' );

      -- select WHITNEY.GLOBAL_UTILITIES.to_string(cast(collect(column_name) as whitney.STRING_ARRAY_TYPE))  into list_columns
      --select wm_concat(column_name) into list_columns
      select listagg(column_name,',') within group (order by column_name) into list_columns
        from dba_cons_columns
       where constraint_name = p_constraint_name
         and owner = p_owner;

      return list_columns;
  end;


  function get_primarykey_columns ( p_owner varchar2 , p_table_name varchar2 )
  return varchar2
  as
  list_columns varchar2(4000) := null;
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.GET_PRIMARYKEY_COLUMNS' , 'utl_purge.get_primarykey_columns('||p_owner||','||p_table_name||')' );

      -- select nvl( WHITNEY.GLOBAL_UTILITIES.to_string(cast(collect(column_name) as whitney.STRING_ARRAY_TYPE)),'*') into list_columns
      --select nvl(wm_concat(column_name),'*') into list_columns
      select nvl(listagg(column_name,',') within group (order by column_name),'*') into list_columns
        from dba_constraints cons, dba_cons_columns cols
       where cols.table_name = p_table_name
         and cons.constraint_type = 'P'
         and cons.constraint_name = cols.constraint_name
         and cons.owner = cols.owner
         and cons.owner = p_owner;

      return list_columns;
  end;

  
  function get_tab_columns ( p_owner varchar2 , p_table_name varchar2 )
  return varchar2
  as
  list_columns varchar2(4000) := null;
  begin
      --select wm_concat(column_name) into list_columns
      select listagg(column_name,',') within group (order by column_name) into list_columns
        from (select column_name
                from dba_tab_columns
               where owner = p_owner
                 and table_name = p_table_name
               order by column_id);
     
      return list_columns;
  end;

  -- + ----------------------------------------------------------
  -- | Procedure : log_sql
  -- + ----------------------------------------------------------
  procedure log_sql ( p_caller varchar2 , p_sql_text varchar2 )
  as
  begin
      insert into utl$sql values ( seq_utl$sql.nextval, sysdate , p_caller, p_sql_text );
      commit;
  end log_sql;


  -- + ----------------------------------------------------------
  -- | Procedure : log_info
  -- + ----------------------------------------------------------
  procedure log_info ( p_task varchar2 default '', p_caller varchar2 default '', p_message varchar2 default '', p_output varchar2 default 'DB' )
  as
  pragma autonomous_transaction;
  begin

      case p_output
      when 'DB' then
          insert into utl$log values ( seq_utl$log.nextval , sysdate , p_task , p_caller , p_message );
      when 'STDOUT' then
          dbms_output.put_line( p_task||' '||p_caller||' '||p_message );
      when 'BOTH' then
           insert into utl$log values ( seq_utl$log.nextval , sysdate , p_task , p_caller , p_message );
           dbms_output.put_line( p_task||' '||p_caller||' '||p_message );
      end case;

      commit;

      -- mail.send( subject => 'Purge task progress report ( '||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS')||' )', message => p_message );
  end;


  -- + ----------------------------------------------------------------------------------------------------------------
  -- |  Procedure   : is_rows
  -- |  Description : this function returns total number of records after remove duplicated rows
  -- + -----------------------------------------------------------------------------------------------------------------
  function is_rows ( p_owner varchar2, p_table_name varchar2, p_primary_key_table varchar2 )
  return number
  parallel_enable
  as
    list_primarykey_columns varchar2(400);

    total number;
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.IS_ROWS' , 'utl_purge.is_rows' );

       list_primarykey_columns := get_primarykey_columns ( p_owner , p_table_name );


       -- Debugging only purpose 
       --execute immediate 'select count(*) from '||p_primary_key_table into total;
       --log_info('INFO','IS_ROWS', 'Number of records in '||p_primary_key_table||' table before removing duplicated rows : '||total||' row(s)');
       
 
       -- +------------------------------------------------
       -- Below routine removes potential looping data.
       -- +------------------------------------------------
       for i in (select primary_key_table 
                   from utl$list_tree_nodes
                  where (owner, table_name) in (select owner,table_name
                                                  from utl$list_tree_nodes
                                                 where primary_key_table = p_primary_key_table )
                    and primary_key_table <> p_primary_key_table)
       loop

           /* Commented on 2015/03/02
           log_sql('is_rows', 'delete from '||p_primary_key_table||' nologging '||
                                where ('||list_primarykey_columns||') in (select '||list_primarykey_columns||
                                                                          ' from '||i.primary_key_table||')');

           execute immediate 'delete from '||p_primary_key_table||' nologging '||
                                   'where ('||list_primarykey_columns||') in (select '||list_primarykey_columns||
                                                                              ' from '||i.primary_key_table||')';
           */
           /* Commented on 2015/03/02
           log_info ( 'INFO' , 'IS_ROWS' , SQL%ROWCOUNT||' duplicated rows deleted.');
           */


           execute immediate 'alter table '||p_primary_key_table||' rename to '||p_primary_key_table||'_tmp';

           execute immediate 'create table '||p_primary_key_table||' nologging '||
                             'as '||
                             'select * from '||p_primary_key_table||'_tmp'||
                             ' minus '||
                             'select * from '||i.primary_key_table;

           execute immediate 'drop table '||p_primary_key_table||'_tmp'; 

       end loop;


        
       -- +------------------------------------------------
       -- + Count rows after remove duplicated rows
       -- +------------------------------------------------
       execute immediate  'select rownum from '||p_primary_key_table||' where rownum = 1' into total;

       /* Commented on 2015/03/02
       log_info('INFO','IS_ROWS', p_primary_key_table||'before return ('||total||')');
       */
       return total;

  exception 
  when no_data_found then
       --log_info('INFO','IS_ROWS', p_primary_key_table||'before return (no data)');
       return 0;
  end;


--   function get_tab_columns(p_owner varchar2, p_table_name varchar2 )
--   return varchar2
--   as
--   list_columns varchar2(4000);
--   begin
--       --log_info ( 'INFO' , 'UTL_PURGE.GET_TAB_COLUMNS' , 'utl_purge.get_tab_columns('||p_owner||','||p_table_name||')' );
-- 
--       select wm_concat(column_name) into list_columns
--         from dba_tab_columns
--        where owner = p_owner
--          and table_name = p_table_name
--        order by column_id;
-- 
--       return list_columns;
--   end get_tab_columns;

  -- + ----------------------------------------------------------------------------------------------------------------
  -- |  Procedure   : add_node
  -- |  Description : Add a record in the mapping table(utl$list_tree_nodes) and create primary_key column based table 
  -- + -----------------------------------------------------------------------------------------------------------------
  procedure add_node ( p_owner varchar2 , p_table_name varchar2 , p_primary_key_table varchar2 , p_query varchar2 )
  parallel_enable
  as
  v_primarykey_columns  varchar2(400);
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.ADD_NODE' , 'utl_purge.add_node' );

      log_sql('add_node', 'insert into utl$list_tree_nodes '||
                          'values ( seq_utl$list_tree_nodes.nextval,'||p_owner||','||p_table_name||','||p_primary_key_table||')' );

      insert into utl$list_tree_nodes 
      values ( seq_utl$list_tree_nodes.nextval, p_owner , p_table_name , p_primary_key_table );


      v_primarykey_columns := get_primarykey_columns( p_owner, p_table_name );

     
      log_sql( 'add_node' , 'create table '||p_primary_key_table||' ('||v_primarykey_columns||
                           ', constraint pk_'||p_primary_key_table||' primary key('||v_primarykey_columns||'))'||
                           ' organization index pctfree 0 nologging parallel ( degree '||parallel_degree||' ) as '||p_query);
      
      execute immediate 'create table '||p_primary_key_table||' ('||v_primarykey_columns||
                        ', constraint pk_'||p_primary_key_table||' primary key('||v_primarykey_columns||'))'||
                        ' organization index pctfree 0 nologging parallel ( degree '||parallel_degree||' ) as '||p_query;

  /*
  exception when others then
    log_info ( p_message => SQLCODE ||' - '||SQLERRM );
    log_info ( p_message => dbms_utility.format_error_backtrace());
  */
  end;


  -- + ----------------------------------------------------------------------------------------------------------------------
  -- |  Procedure   : remove_node
  -- |  Description : Delete a record in the mapping table(utl$list_tree_nodes) and drop the primary_key column based table
  -- + ----------------------------------------------------------------------------------------------------------------------
  procedure remove_node ( p_primary_key_table varchar2 )
  as
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.REMOVE_NODE' , 'utl_purge.remove_node' );

      log_sql('remove_node', 'delete from utl$list_tree_nodes where primary_key_table = '''||p_primary_key_table||'''');
      log_sql('remove_node', 'drop table '||p_primary_key_table||' purge');

      delete from utl$list_tree_nodes where primary_key_table = p_primary_key_table;
      execute immediate 'drop table '||p_primary_key_table||' purge';
 
  /*
  exception when others then
    log_info ( p_message => SQLCODE ||' - '||SQLERRM );
    log_info ( p_message => dbms_utility.format_error_backtrace());
  */
  end;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : span_tree_print
  -- |  Parameter   : p_owner : table owner
  -- |                p_table_name : table_name
  -- |                p_query : sql statement that will narrow down candidate key
  -- |                ex) 'select party_key from party where terminated_date < sysdate - 7'
  -- |  Description : This procedure traverse the relationships between the tables and print the tables with tree structure
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure span_tree_print ( p_owner      varchar2 , 
                              p_table_name varchar2 , 
                              p_level      number   default 1 , 
                              p_sequence   number   default 1 , 
                              p_output     varchar2 default 'STDOUT' )
  parallel_enable
  as

  list_primarykey_columns varchar2(400);
  list_foreignkey_columns varchar2(400);
  list_parentskey_columns varchar2(400);
  v_sequence number := 1;

  error_code    number;
  error_msg     varchar2(250);
  rows_returned number;
  table_name    varchar2(400);

  begin
      --log_info ( 'INFO' , 'UTL_PURGE.SPAN_TREE_PRINT' , 'utl_purge.span_tree_print' );


      /* If there is no child records then return to upper level */
      if is_rows ( p_owner, p_table_name, 'XXXX_'||(p_level - 1)||'_'||p_sequence ) = 0 then
          return ;
      end if;


      for i in ( select owner,table_name,constraint_name
                   from all_constraints
                  where r_constraint_name = (select constraint_name from all_constraints
                                              where table_name = p_table_name
                                                and owner = p_owner
                                                and constraint_type = 'P' ))
      loop


          list_foreignkey_columns := get_constraint_columns ( i.owner, i.constraint_name );
          list_primarykey_columns := get_primarykey_columns ( i.owner , i.table_name );
          list_parentskey_columns := get_primarykey_columns ( p_owner , p_table_name );

         /* Add node */
         add_node(i.owner, i.table_name, 'XXXX_'||p_level||'_'||v_sequence , 
                  'select '||list_primarykey_columns||
                   ' from '||i.owner||'.'||i.table_name||
                  ' where ( '||list_foreignkey_columns||') in ( select '||list_parentskey_columns||
                                                                ' from XXXX_'||(p_level - 1)||'_'||p_sequence||')');


          /* Count rows */
          execute immediate 'select count(*) from '||'XXXX_'||p_level||'_'||v_sequence into rows_returned;

          table_name := i.owner||'.'||i.table_name||'('||rows_returned||')';
          log_info ( p_message => lpad(table_name, length(table_name) + p_level * 3 - 3, '-'), p_output => p_output );


          /* Traverse next level node */
          span_tree_print( i.owner , i.table_name , p_level + 1 , v_sequence , p_output );


          remove_node( 'XXXX_'||p_level||'_'||v_sequence );

          -- increase sequence(v_sequence represent child number )
          v_sequence := v_sequence + 1;

      end loop;

    exception when others then

    log_info ( p_message => SQLCODE ||' - '||SQLERRM , p_output => p_output );
    log_info ( p_message => dbms_utility.format_error_backtrace());

    commit;

  end span_tree_print;



  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : print_tree 
  -- |  Parameter   : p_owner      : table owner
  -- |                p_table_name : table_name
  -- |                p_query      : sql statement that will narrow down candidate key
  -- |                               ex) 'select party_key from party where terminated_date < sysdate - 7'
  -- |                p_parallel_degree :
  -- |                p_output     :
  -- |  Description : Calls span_tree_print procedure.
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure print_tree( p_owner           varchar2 , 
                        p_table_name      varchar2 ,
                        p_query           varchar2 , 
                        p_parallel_degree number default 1, 
                        p_output          varchar2  default 'STDOUT' )
  parallel_enable
  as
  list_primarykey_columns varchar2(400);
  rows_returned           number;
  table_name              varchar2(400);
  begin

      execute immediate 'alter session force parallel ddl';
      execute immediate 'alter session force parallel dml';

      parallel_degree := p_parallel_degree;



      --log_info ( 'INFO' , 'UTL_PURGE.PRINT_TREE' , 'utl_purge.print_tree' );

      initialize_env;


      /* Add root node */
      add_node ( p_owner , p_table_name , 'XXXX_1_1' , p_query );
 
      list_primarykey_columns := get_primarykey_columns ( p_owner , p_table_name );

      /* Count records */
      execute immediate 'select count(*) from XXXX_1_1' into rows_returned;
    
      table_name := p_owner||'.'||p_table_name||'('||rows_returned||')';
      log_info ( p_message => lpad(table_name, length(table_name), ' '), p_output => p_output );


      /* Traverse next level node */
      span_tree_print ( p_owner , p_table_name , 1 + 1 , 1 , p_output );


      /* Delete root node */
      remove_node( 'XXXX_1_1' );

  end print_tree;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : span_tree_remove
  -- |  Parameter   : p_owner      : table owner
  -- |                p_table_name : table_name
  -- |                p_query      : sql statement that will narrow down candidate key
  -- |                               ex) 'select party_key from party where terminated_date < sysdate - 7'
  -- |  Description : This procedure traverse the relationships between the tables and print the tables with tree structure
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure span_tree_remove ( p_owner           varchar2 , 
                              p_table_name      varchar2 , 
                              p_level number    default 1 , 
                              p_sequence number default 1 )
  parallel_enable
  as 

  child_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(child_exists, -2292);

  list_primarykey_columns varchar2(400);
  list_foreignkey_columns varchar2(400);
  list_parentskey_columns varchar2(400);
  v_sequence number := 1;

  error_code    number;
  error_msg     varchar2(250);
  rows_removed  number;
  owner         varchar2(30);
  table_name    varchar2(400);
  constraint_name varchar2(30);
  
  is_continue boolean := true;

  begin
      --log_info ( 'INFO' , 'UTL_PURGE.SPAN_TREE_REMOVE' , 'utl_purge.span_tree_remove' );
    
      /* If there is no child records then return to upper level */
      if is_rows ( p_owner, p_table_name, 'XXXX_'||(p_level - 1)||'_'||p_sequence ) = 0 then
          return;
      end if;


      /* Browser sibling node tables */
      /* Added decode to make self-reference constraints to be executed last */
      for i in ( select decode(table_name,p_table_name,1,0) no,owner,table_name,constraint_name, r_constraint_name
                   from all_constraints
                  where r_constraint_name = (select constraint_name from all_constraints
                                              where table_name = p_table_name
                                                and owner = p_owner
                                                and constraint_type = 'P' )
                  order by no)
      loop

          list_foreignkey_columns := get_constraint_columns ( i.owner, i.constraint_name );
          list_primarykey_columns := get_primarykey_columns ( i.owner , i.table_name );
          list_parentskey_columns := get_primarykey_columns ( p_owner , p_table_name );


          /* Add a node */
          add_node(i.owner, i.table_name, 'XXXX_'||p_level||'_'||v_sequence , 
                   'select '||list_primarykey_columns||
                    ' from '||i.owner||'.'||i.table_name||
                   ' where ( '||list_foreignkey_columns||') in ( select '||list_parentskey_columns||
                                                                 ' from XXXX_'||(p_level - 1)||'_'||p_sequence||')');

          /* Traverse next level node */
          span_tree_remove( i.owner , i.table_name , p_level + 1 , v_sequence );
 

       /*+ parallel delete 
           2013/04/09 jyoon - Disable and proceed if violate constraints
       */
       while is_continue
       loop 
         
          begin

              execute immediate 'delete /*+ parallel ( '||i.owner||'.'||i.table_name||' , '||parallel_degree||' ) */'||
                                 ' from '||i.owner||'.'||i.table_name||
                                ' where ('||list_foreignkey_columns||') in (select '||list_parentskey_columns||
                                                                            ' from XXXX_'||(p_level - 1)||'_'||p_sequence||')';

              is_continue := false;
          exception when child_exists then

              error_msg := SQLERRM;

              select owner,table_name, constraint_name into owner,table_name, constraint_name
                from dba_constraints
               where owner||'.'||constraint_name = regexp_substr( error_msg ,'([[:alpha:]]+\.[[:alnum:]\_?]+)');

              
              insert into utl$disabled_constraints 
              values ( owner, table_name, constraint_name );
          
               
              execute immediate 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name;


          end;
       end loop;

       is_continue := true;
 
          rows_removed := SQL%ROWCOUNT;
  
--          if rows_removed > 0 then
              table_name := i.owner||'.'||i.table_name||'('||rows_removed||' deleted)';
              log_info ( 'INFO' , 'UTL_PURGE' , lpad(table_name, length(table_name) + p_level * 3 - 3, '-'));
--          end if;
  
        
          /* Remove a node */
          remove_node( 'XXXX_'||p_level||'_'||v_sequence );


          /* increase sequence(v_sequence represent child number ) */
          v_sequence := v_sequence + 1;

      end loop;
 

  exception when others then
    log_info ( p_message => SQLCODE ||' - '||SQLERRM );
    log_info ( p_message => dbms_utility.format_error_backtrace());
  end span_tree_remove;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : purge_data_cascade
  -- |  Parameter   : p_owner      : table owner
  -- |                p_table_name : table_name
  -- |                p_query      : sql statement that will narrow down candidate key
  -- |                               ex) 'select party_key from party where terminated_date < sysdate - 7'
  -- |                p_isparallel : 
  -- |  Description :
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure purge_data_cascade ( p_owner      varchar2 , 
                                 p_table_name varchar2 , 
                                 p_query      varchar2 , 
                                 p_parallel_degree number  default 1)
  parallel_enable
  as 

  child_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(child_exists, -2292);

  list_primarykey_columns varchar2(400);
  rows_removed            number;

  begin

      execute immediate 'alter session force parallel ddl';
      execute immediate 'alter session force parallel dml';

      parallel_degree := p_parallel_degree;


      log_info ( 'INFO' , 'UTL_PURGE.PURGE_DATA_CASCADE' , 'utl_purge.purge_data_cascade' );

      initialize_env;

      /* Add root node */
      add_node ( p_owner , p_table_name , 'XXXX_1_1' , p_query );


      /* Traverse next level node */
      span_tree_remove ( p_owner , p_table_name , 1 + 1 , 1 );


      /* Get list of primarykey columns to generate delete statement */
      list_primarykey_columns := get_primarykey_columns ( p_owner , p_table_name );

 
      log_sql('purge_data_cascade', 'delete /*+ parallel ( '||p_owner||'.'||p_table_name||' , '||parallel_degree||' ) */'||
                                     ' from '||p_owner||'.'||p_table_name||
                                    ' where ('||list_primarykey_columns||') in (select '||list_primarykey_columns||' from XXXX_1_1)');

      execute immediate 'delete /*+ parallel ( '||p_owner||'.'||p_table_name||' , '||parallel_degree||' ) */'||
                         ' from '||p_owner||'.'||p_table_name||
                        ' where ('||list_primarykey_columns||') in (select '||list_primarykey_columns||' from XXXX_1_1)';


      rows_removed := SQL%ROWCOUNT;


      log_info ( 'INFO' , 'UTL_PURGE' , p_owner||'.'||p_table_name||'('||rows_removed||' deleted)');



      /* Delete root node */
      remove_node( 'XXXX_1_1' );


      /* Enable disabled constraints */
      for i in (select owner,table_name,constraint_name from utl$disabled_constraints)
      loop
          execute immediate 'alter table '||i.owner||'.'||i.table_name||' enable constraint '||i.constraint_name;
      end loop;

      execute immediate 'truncate table utl$disabled_constraints';
    
  end purge_data_cascade;



  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : get_temp_table
  -- |  Parameter   : p_owner             : table owner
  -- |              : p_table_name        : table name
  -- |  Description : return temp_table name if exists, if not then it create temp table and return it's name
  -- + ---------------------------------------------------------------------------------------------------------------------
  function get_temp_table ( p_owner varchar2 , p_table_name varchar2 )
  return varchar2
  as
  v_owner                    utl$tables.owner%type;
  v_table_name               utl$tables.table_name%type;
  v_temp_table_name          utl$tables.temp_table_name%type;
  v_tablespace_name          dba_tables.tablespace_name%type;
  v_list_primarykey_columns varchar2(400);
  begin
     --log_info ( 'INFO' , 'UTL_PURGE.GET_TEMP_TABLE' , 'utl_purge.get_temp_table('||p_owner||'.'||p_table_name||')' );

     select temp_table_name into v_temp_table_name
       from utl$tables
      where owner = p_owner
        and table_name = p_table_name;

      return v_temp_table_name;

  exception when no_data_found then

      return 'NA';
  end get_temp_table;   

  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : add_temp_table
  -- |  Parameter   : p_owner             : table owner
  -- |              : p_table_name        : table name
  -- |              : p_primary_key_table : primary key table
  -- |  Description : Create temp table that hold the data that we want to keep. If the table is already exists then it will
  -- |                just add addition records
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure add_temp_table ( p_owner varchar2 , p_table_name varchar2 , p_primary_key_table varchar2  )
  parallel_enable
  as
    list_primarykey_columns    varchar2(4000);
    list_tab_columns           varchar2(4000);
    v_owner                    utl$tables.owner%type;
    v_table_name               utl$tables.table_name%type;
    v_iot_type                 varchar2(12);
    v_temp_table_name          utl$tables.temp_table_name%type;
    v_tablespace_name          dba_tables.tablespace_name%type;

  begin
     --log_info ( 'INFO' , 'UTL_PURGE.ADD_TEMP_TABLE' , 'utl_purge.add_temp_table' );

     if ( is_rows( p_owner, p_table_name, p_primary_key_table ) = 1 ) then

         list_primarykey_columns := get_primarykey_columns ( p_owner , p_table_name );
         v_temp_table_name       := get_temp_table( p_owner , p_table_name ); 


         if ( v_temp_table_name = 'NA' ) then
             /* Add temporary table */
             select owner, table_name, nvl(iot_type,'NORMAL'), tablespace_name, 'XXXX_'||to_char(systimestamp,'yyyymmddhh24missff') 
               into v_owner, v_table_name, v_iot_type, v_tablespace_name, v_temp_table_name
               from dba_tables
              where owner = p_owner
                and table_name = p_table_name;

             insert into utl$tables ( owner, table_name, temp_table_name )
             values ( v_owner, v_table_name, v_temp_table_name );


             -- Logging 
             log_info ( 'INFO' , 'UTL_PURGE.ADD_TEMP_TABLE' , 
                                 'Creating temporary table '||v_temp_table_name||' from '||p_owner||'.'||p_table_name||' using '||p_primary_key_table||' table');

             if ( v_iot_type = 'NORMAL' ) then -- Normal tables


                 log_sql('add_temp_table', 'create table '||v_owner||'.'||v_temp_table_name||
                                           ' nologging parallel (degree '||parallel_degree||') tablespace '||nvl(v_tablespace_name,'CURRENEX_1')||
                                           ' as select /*+ full('||p_owner||'.'||p_table_name||') */ * from '||p_owner||'.'||p_table_name||
                                           ' where ('||list_primarykey_columns||') in (select /*+ full('||p_primary_key_table||') */ '||list_primarykey_columns||' from '||p_primary_key_table||')');

                 execute immediate 'create table '||v_owner||'.'||v_temp_table_name||
                                   ' nologging parallel (degree '||parallel_degree||') tablespace '||nvl(v_tablespace_name,'CURRENEX_1')||
                                   ' as select /*+ full('||p_owner||'.'||p_table_name||') */ * from '||p_owner||'.'||p_table_name||
                                   ' where ('||list_primarykey_columns||') in (select /*+ full('||p_primary_key_table||') */ '||list_primarykey_columns||' from '||p_primary_key_table||')';


                 log_sql('add_temp_table','create unique index '||v_owner||'.pk_'||v_temp_table_name||
                                          ' on '||v_owner||'.'||v_temp_table_name||'('||list_primarykey_columns||') nologging parallel '||parallel_degree);

                 execute immediate 'create unique index '||v_owner||'.pk_'||v_temp_table_name||
                                   ' on '||v_owner||'.'||v_temp_table_name||'('||list_primarykey_columns||') nologging parallel '||parallel_degree;



                 log_sql('add_temp_table','alter table '||v_owner||'.'||v_temp_table_name||
                                          ' add constraint pk_'||v_temp_table_name||' primary key ('||list_primarykey_columns||') using index'); 

                 execute immediate 'alter table '||v_owner||'.'||v_temp_table_name||
                                   ' add constraint pk_'||v_temp_table_name||' primary key ('||list_primarykey_columns||') using index'; 


             else -- IOT table

                 list_tab_columns := get_tab_columns ( p_owner , p_table_name );
 
                 log_sql('add_temp_table','create table '||v_owner||'.'||v_temp_table_name||
                                   ' ('||list_tab_columns||','||
                                   ' constraint pk_'||v_temp_table_name||' primary key ('||list_primarykey_columns||')) '||
                                   'organization index nologging '||
                                   'tablespace '||nvl(v_tablespace_name,'CURRENEX_1')||
                                   ' as select /*+ full('||p_owner||'.'||p_table_name||') */ * from '||p_owner||'.'||p_table_name||
                                   ' where ('||list_primarykey_columns||') in (select /*+ full('||p_primary_key_table||') */ '||list_primarykey_columns||' from '||p_primary_key_table||')');

                 execute immediate 'create table '||v_owner||'.'||v_temp_table_name||
                                   ' ('||list_tab_columns||','||
                                   ' constraint pk_'||v_temp_table_name||' primary key ('||list_primarykey_columns||')) '||
                                   'organization index nologging '||
                                   'tablespace '||nvl(v_tablespace_name,'CURRENEX_1')||
                                   ' as select /*+ full('||p_owner||'.'||p_table_name||') */ * from '||p_owner||'.'||p_table_name||
                                   ' where ('||list_primarykey_columns||') in (select /*+ full('||p_primary_key_table||') */ '||list_primarykey_columns||' from '||p_primary_key_table||')';

             end if;
         else
             /* Commented on 2015/03/02
             log_sql('add_temp_table', 'delete from '||p_primary_key_table||
                                       ' where ('||list_primarykey_columns||') in ( select '||list_primarykey_columns||
                                                                            ' from '||p_owner||'.'||v_temp_table_name||')');
 
             execute immediate 'delete from '||p_primary_key_table||
                               ' where ('||list_primarykey_columns||') in ( select '||list_primarykey_columns||
                                                                            ' from '||p_owner||'.'||v_temp_table_name||')';
             */

                            
             log_info('CRITICAL','UTL_PURGE.ADD_TEMP_TABLE',
                                 'Loading data into temp table '||v_temp_table_name||' from '||p_owner||'.'||p_table_name||' using '||p_primary_key_table);

             --log_sql('add_temp_table', 'insert /*+ append */ into '||p_owner||'.'||v_temp_table_name||' nologging'||
             --                         ' select /*+ parallel('||p_owner||'.'||p_table_name||' , '||parallel_degree||') */ *'||
             --                           ' from '||p_owner||'.'||p_table_name||
             --                          ' where ('||list_primarykey_columns||') in (select '||list_primarykey_columns||
             --                                                                      ' from '||p_primary_key_table||')');


             execute immediate 'insert /*+ append */ into '||p_owner||'.'||v_temp_table_name||' nologging'||
                              ' select /*+ parallel('||p_owner||'.'||p_table_name||' , '||parallel_degree||') */ *'||
                                ' from '||p_owner||'.'||p_table_name||
                               ' where ('||list_primarykey_columns||') in (select '||list_primarykey_columns||
                                                                           ' from sys.'||p_primary_key_table||
                                                                          ' minus '||
                                                                          'select '||list_primarykey_columns||
                                                                           ' from '||p_owner||'.'||v_temp_table_name||')';

             if ( SQL%ROWCOUNT > 0 ) then
                 log_info ( 'INFO' , 'UTL_PURGE.ADD_TEMP_TABLE' , SQL%ROWCOUNT||' rows loaded into temporary table '||v_temp_table_name||'.');
             end if;

             commit;
         end if;
     else
         -- p_primary_key_table has no rows
         log_info('INFO','UTL_PURGE.ADD_TEMP_TABLE','primary_key_table '||p_primary_key_table||' has no records.');
     end if; -- only when p_primary_key_table has row(s)
 
  /* Commented on 2014/03/02
  exception when others then
    log_info ( p_message => SQLCODE ||' - '||SQLERRM );
    log_info ( p_message => dbms_utility.format_error_backtrace());
  */
  end add_temp_table;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : get_ind_columns 
  -- |  Parameter   : p_owner             : table owner
  -- |              : p_table_name        : table name
  -- |  Description :
  -- + ---------------------------------------------------------------------------------------------------------------------
  function get_ind_columns ( p_owner varchar2 , p_index_name varchar2 )
  return varchar2
  as
  list_columns varchar2(4000);
  begin
     --log_info ( 'INFO' , 'UTL_PURGE.GET_IND_COLUMNS' , 'utl_purge.get_ind_columns('||p_owner||','||p_index_name||')' );

      --select wm_concat(column_name) into list_columns
      select listagg(column_name,',') within group (order by column_name) into list_columns
        from dba_ind_columns
       where index_owner = p_owner
         and index_name  = p_index_name
        order by column_position;

      return list_columns;
  end get_ind_columns;

  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : save_ind_ddl
  -- |  Parameter   : p_owner             : table owner
  -- |              : p_table_name        : table name
  -- |  Description : 
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure save_ind_ddl ( p_owner varchar2 , p_table_name varchar2 )
  is
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.SAVE_IND_DDL' , 'utl_purge.save_ind_ddl('||p_owner||','||p_table_name||')' );

      insert into utl$indexes
      select owner,index_name,index_type,table_owner,table_name,uniqueness,utl_purge.get_ind_columns(owner,index_name),tablespace_name
        from dba_indexes  e
       where owner = p_owner
         and table_name = p_table_name
         and index_type in ('NORMAL','IOT - TOP') 
         and not exists ( select 'x'
                            from utl$indexes i
                           where i.owner = e.owner
                             and i.index_name = e.index_name );

  end save_ind_ddl;

  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : get_cons_columns
  -- |  Parameter   : p_owner             : table owner
  -- |              : p_table_name        : table name
  -- |  Description : 
  -- + ---------------------------------------------------------------------------------------------------------------------
  function get_cons_columns ( p_owner varchar2 , p_constraint_name varchar2 )
  return varchar2
  as
  list_columns varchar2(4000);
  begin
      --log_info ( 'INFO' , 'UTL_PURGE.GET_CONS_COLUMNS' , 'utl_purge.get_cons_columns('||p_owner||','||p_constraint_name||')' );

      --select wm_concat(column_name) into list_columns
      select listagg(column_name,',') within group (order by column_name) into list_columns
        from dba_cons_columns
       where owner = p_owner
         and constraint_name = p_constraint_name
       order by position;

      return list_columns;
  end get_cons_columns;

  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : save_cons_ddl
  -- |  Parameter   : p_owner             : table owner
  -- |              : p_table_name        : table name
  -- |  Description :
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure save_cons_ddl ( p_owner varchar2 , p_table_name varchar2 , p_constraint_type varchar2 default 'OTHERS') 
  is
  begin
     --log_info ( 'INFO' , 'UTL_PURGE.GET_CONS_COLUMNS' , 'utl_purge.get_cons_columns('||p_owner||','||p_table_name||','||p_constraint_type||')' );

     if ( p_constraint_type = 'OTHERS' ) then
         for i in ( select owner,constraint_name,constraint_type,table_name,search_condition,r_owner,r_constraint_name
                      from dba_constraints e
                     where owner = p_owner 
                       and table_name = p_table_name
                       and constraint_type <> 'R'
                       and not exists ( select 'x'
                                          from utl$constraints i
                                         where i.owner = e.owner
                                           and i.constraint_name = e.constraint_name))
          loop
              if ( i.constraint_type = 'C' and (i.constraint_name like 'SYS_C%' and i.search_condition like '%NOT NULL')) then
                  null;
              else
                  insert into utl$constraints 
                  values ( i.owner, i.constraint_name, i.constraint_type, i.table_name, i.search_condition, i.r_owner, i.r_constraint_name,'',utl_purge.get_cons_columns(i.owner,i.constraint_name));
              end if;
          end loop;
     elsif ( p_constraint_type = 'REF' ) then
         for i in ( select e.owner,e.constraint_name,e.constraint_type,e.table_name,e.search_condition,e.r_owner,e.r_constraint_name,p.table_name as r_table_name
                      from dba_constraints e, dba_constraints p
                     where e.owner = p_owner
                       and e.table_name = p_table_name
                       and e.constraint_type = 'R'
                       and e.r_owner = p.owner
                       and e.r_constraint_name = p.constraint_name
                       and not exists ( select 'x'
                                          from utl$constraints i
                                         where i.owner = e.owner
                                           and i.constraint_name = e.constraint_name))
          loop

              insert into utl$constraints
              values ( i.owner, i.constraint_name, i.constraint_type, i.table_name, i.search_condition, i.r_owner, i.r_constraint_name, i.r_table_name, utl_purge.get_cons_columns(i.owner,i.constraint_name));
          end loop;
     end if;

     commit;

  end save_cons_ddl;

  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : span_tree_remove_batch
  -- |  Parameter   : p_owner           : table owner
  -- |                p_table_name      : table_name
  -- |                p_query           : sql statement that will narrow down candidate key
  -- |                                    ex) 'select party_key from party where terminated_date < sysdate - 7'
  -- |                p_parallel_degree :
  -- |  Description : This script can be used in case if one need to purge majority of data.
  -- |                For p_query, one need to provide query that he or she wants to keep instead of purge in other purge scripts.
  -- |                ex) if one want to purge data before January 1st, 2012. then p_query must be
  -- |                select trade_key from trade where trade_date >= '01-JAN-2012'
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure span_tree_remove_batch   ( p_owner             varchar2 ,
                                       p_table_name        varchar2 ,
                                       p_level             number    default 1 ,
                                       p_sequence          number    default 1) 
  parallel_enable
  as
  list_primarykey_columns varchar2(400);
  list_foreignkey_columns varchar2(400);
  list_parentskey_columns varchar2(400);
  v_sequence number := 1;

  error_code    number;
  error_msg     varchar2(250);
  rows_removed number;
  v_table_name    varchar2(400);

  begin

      save_cons_ddl ( p_owner , p_table_name , 'REF');

      /* If there is no child records then return to upper level */
      if is_rows ( p_owner, p_table_name, 'XXXX_'||(p_level - 1)||'_'||p_sequence ) = 0 then
          log_info ( 'INFO' , 'UTL_PURGE.SPAN_TREE_REMOVE_BATCH' , 
                              'utl_purge.span_tree_remove_batch('||p_owner||','||p_table_name||','||p_level||','||p_sequence||') has no child.');
          return ;
      end if;

      /* Browser sibling node tables */
      for i in ( select owner,table_name,constraint_name, r_constraint_name
                   from all_constraints
                  where r_constraint_name = (select constraint_name from all_constraints
                                              where table_name = p_table_name
                                                and owner = p_owner
                                                and constraint_type = 'P' ))
      loop

          list_foreignkey_columns := get_constraint_columns ( i.owner, i.constraint_name );
          list_primarykey_columns := get_primarykey_columns ( i.owner , i.table_name );
          list_parentskey_columns := get_primarykey_columns ( p_owner , p_table_name );


          /* This plsql block helps performance. It allows to scan temporary table instead of original table once it scanned 
             OWNER                          TABLE_NAME                     TEMP_TABLE_NAME
            ------------------------------ ------------------------------ ------------------------------
             WHITNEY                        TRADE                          XXXX_20121227034101781170
             WHITNEY                        TRADE_LINK                     XXXX_20121227080840590370   
          */ 
          
          /* 
             2015/02/24 - JYOON - Bug fix
          begin
              select temp_table_name into v_table_name
                from utl$tables
               where owner = i.owner
                 and table_name = i.table_name;

          exception when no_data_found then
              v_table_name := i.table_name;
          end; 
          */
 
         /* Add a node */ 
         -- 2015/02/24 - JYOON - Bug fix
         ---add_node(i.owner, i.table_name, 'XXXX_'||p_level||'_'||v_sequence , 'select '||list_primarykey_columns||' from '||i.owner||'.'||v_table_name||' where ( '||list_foreignkey_columns||') in ( select '||list_parentskey_columns||' from XXXX_'||(p_level - 1)||'_'||p_sequence||')');

         add_node(i.owner, i.table_name, 'XXXX_'||p_level||'_'||v_sequence , 'select '||list_primarykey_columns||' from '||i.owner||'.'||i.table_name||' where ( '||list_foreignkey_columns||') in ( select '||list_parentskey_columns||' from XXXX_'||(p_level - 1)||'_'||p_sequence||')');

          /* Add temp table */
          add_temp_table ( i.owner , i.table_name , 'XXXX_'||p_level||'_'||v_sequence );


          /* Save Index DDLs */
          save_ind_ddl ( i.owner, i.table_name );


          /* Save Table Constraints */
          save_cons_ddl ( i.owner , i.table_name , 'OTHERS');

          /* Traverse next level node */
          log_info ( 'INFO' , 'UTL_PURGE.SPAN_TREE_REMOVE_BATCH' , 'utl_purge.span_tree_remove_batch('||i.owner||','||i.table_name||','||p_level||' + 1,'||v_sequence||') calling.');
          span_tree_remove_batch ( i.owner , i.table_name , p_level + 1 , v_sequence );


          /* Remove a node */
          remove_node( 'XXXX_'||p_level||'_'||v_sequence );


          /* increase sequence(v_sequence represent child number ) */
          v_sequence := v_sequence + 1;

      end loop;

  exception when others then
    log_info ( p_message => SQLCODE ||' - '||SQLERRM );
    log_info ( p_message => dbms_utility.format_error_backtrace());

  end span_tree_remove_batch;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : purge_data_cascade_batch
  -- |  Parameter   : p_owner           : table owner
  -- |                p_table_name      : table_name
  -- |                p_query           : sql statement that will narrow down candidate key
  -- |                                    ex) 'select party_key from party where terminated_date < sysdate - 7'
  -- |                p_parallel_degree :
  -- |  Description : This script can be used in case if one need to purge majority of data.
  -- |                For p_query, one need to provide query that he or she wants to keep instead of purge in other purge scripts.
  -- |                ex) if one want to purge data before January 1st, 2012. then p_query must be
  -- |                select trade_key from trade where trade_date >= '01-JAN-2012' 
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure purge_data_cascade_batch ( p_owner             varchar2 ,
                                       p_table_name        varchar2 ,
                                       p_query             varchar2 ,
                                       p_parallel_degree   number default 1) 
  parallel_enable
  as
  list_primarykey_columns varchar2(400);
  rows_removed            number;
  begin

      execute immediate 'alter session force parallel ddl';
      execute immediate 'alter session force parallel dml';

      parallel_degree := p_parallel_degree;


      initialize_env;

      log_info ( 'INFO' , 'UTL_PURGE.PURGE_DATA_CASCADE_BATCH' , 'utl_purge.purge_data_cascade_batch('||p_owner||','||p_table_name||')');


      /* Add root node */
      add_node ( p_owner , p_table_name , 'XXXX_1_1' , p_query );


      /* Add temp table */
      add_temp_table ( p_owner , p_table_name , 'XXXX_1_1' );


      /* Save Index DDLs */
      save_ind_ddl ( p_owner, p_table_name );


      /* Save Table Constraints */
      save_cons_ddl ( p_owner , p_table_name , 'OTHERS');

      /* Traverse next level node */
      log_info ( 'INFO' , 'UTL_PURGE.SPAN_TREE_REMOVE_BATCH' , 'utl_purge.span_tree_remove_batch('||p_owner||','||p_table_name||', 1'||' + 1, 1 ) calling.');
      span_tree_remove_batch ( p_owner , p_table_name , 1 + 1 , 1 );


      /* Delete root node */
      remove_node( 'XXXX_1_1' );

      log_info ( 'INFO' , 'UTL_PURGE.PURGE_DATA_CASCADE_BATCH' , 'utl_purge.purge_data_cascade_batch finished.'||CHR(10));
  end purge_data_cascade_batch;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Name        : trim_dead_branch
  -- |  Parameter   : 
  -- |  Description : Remove violated records(Parent Not found) after purge_data_cascade_batch
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure trim_dead_branch ( p_owner           varchar2,
                               p_fk_constraint   varchar2 , 
                               p_parallel_degree number default 1 )
  as 
      v_sql varchar2(4000);   
  begin
      for i in ( select con.r_owner, (select table_name 
                                        from dba_constraints con1
                                        where con1.constraint_name = con.r_constraint_name) r_table_name, 
                        utl_purge.get_cons_columns( con.r_owner, con.r_constraint_name ) r_cons_columns,
                        col.owner, col.table_name, utl_purge.get_cons_columns( col.owner, col.constraint_name ) cons_columns,
                        utl_purge.get_cons_columns( col.owner, (select constraint_name 
                                                                  from dba_constraints con1
                                                                 where con1.owner = con.owner
                                                                   and con1.table_name = con.table_name
                                                                   and con1.constraint_type = 'P')) primary_key_columns 
                   from dba_constraints con, dba_cons_columns col
                  where con.owner = col.owner
                    and con.constraint_name = col.constraint_name
                    and con.owner = p_owner
                    and con.constraint_name = p_fk_constraint )
      loop
         v_sql := 'SELECT '||i.primary_key_columns||' FROM '||i.owner||'.'||i.table_name||
                  ' WHERE ('||i.cons_columns||') IN (SELECT ('||i.cons_columns||') FROM '||i.owner||'.'||i.table_name||
                                                    ' MINUS  '||
                                                    'SELECT ('||i.r_cons_columns||') FROM '||i.r_owner||'.'||i.r_table_name||')';
 
         --dbms_output.put_line('utl_purge.print_tree( '||i.owner||' , '||i.table_name||', '||v_sql||' , '||p_parallel_degree||' );');
         log_info('INFO', 'TRIM_DEAD_BRANCH', 'utl_purge.purge_data_cascade( '||i.owner||' , '||i.table_name||', '||v_sql||' , '||p_parallel_degree||' );');
         utl_purge.purge_data_cascade( i.owner , i.table_name, v_sql , p_parallel_degree );

         log_info('INFO', 'TRIM_DEAD_BRANCH', 'alter table '||i.owner||'.'||i.table_name||' modify constraint '||p_fk_constraint||' enable validate;');
         execute immediate 'alter table '||i.owner||'.'||i.table_name||' modify constraint '||p_fk_constraint||' enable validate';
      end loop;

  end trim_dead_branch;

  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : drop_fk_constraints
  -- |  Parameter   : 
  -- |  Description : Drops all fk constraint before drop by scanning utl$constraint table.
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure drop_fk_constraints
  as
  begin

      log_info ( 'INFO' , 'UTL_PURGE.DROP_FK_CONSTRAINTS' , 'utl_purge.drop_fk_constraints');

      for i in (select owner,constraint_name,table_name from utl$constraints where constraint_type = 'R')
      loop
          log_info ( 'INFO' , 'UTL_PURGE.DROP_FK_CONSTRAINTS' , 'Drop foreign key constraint '||i.constraint_name||' on '||i.owner||'.'||i.table_name||CHR(10));
          log_sql ( 'drop_fk_constraints', 'alter table '||i.owner||'.'||i.table_name||' drop constraint '||i.constraint_name);
          execute immediate 'alter table '||i.owner||'.'||i.table_name||' drop constraint '||i.constraint_name;
      end loop;
  end drop_fk_constraints;
 
  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : drop_org_tables
  -- |  Parameter   :
  -- |  Description : Drops all original transactional tables
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure drop_org_tables
  as
  begin
      log_info ( 'INFO' , 'UTL_PURGE.DROP_ORG_TABLES' , 'utl_purge.drop_org_tables');

      for i in (select owner,table_name,temp_table_name from utl$tables order by owner,table_name)
      loop
          -- Bug Fix: 2013/05/02 : JYOON
          --          Set default value on temporary table
          for j in (select column_name,data_default 
                      from dba_tab_columns 
                     where owner = i.owner 
                       and table_name = i.table_name
                       and data_default is not null)
          loop
              log_info('INFO','UTL_PURGE.DROP_ORG_TABLES', 'Set default value on '||i.owner||'.'||i.temp_table_name);
              log_sql('drop_org_tables',
                      'alter table '||i.owner||'.'||i.temp_table_name||' modify '||j.column_name||' default '||j.data_default);
              execute immediate 'alter table '||i.owner||'.'||i.temp_table_name||
                                ' modify '||j.column_name||' default '||j.data_default;

          end loop;


          log_info ( 'INFO' , 'UTL_PURGE.DROP_ORG_TABLES' , 'Drop table '||i.owner||'.'||i.table_name||CHR(10));
          log_sql ('drop_org_tables','drop table '||i.owner||'.'||i.table_name||' purge');
          execute immediate 'drop table '||i.owner||'.'||i.table_name||' purge';
      end loop;
  end drop_org_tables;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : rename_temp_to_org
  -- |  Parameter   :
  -- |  Description : Drops all original transactional tables
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure rename_temp_to_org
  as
  begin
      log_info ( 'INFO' , 'UTL_PURGE.RENAME_TEMP_TO_ORG' , 'utl_purge.rename_temp_to_org');

      for i in (select owner,table_name,temp_table_name from utl$tables order by owner,table_name)
      loop
          /* Drop temporary pk key on temporary table */
          begin
              execute immediate 'alter table '||i.owner||'.'||i.temp_table_name||' drop primary key drop index';

          exception when others then -- rename constraint in case if it's IOT
              execute immediate 'alter table '||i.owner||'.'||i.temp_table_name||' rename constraint pk_'||i.temp_table_name||' to pk_'||i.table_name;
          end;

          log_info ( 'INFO' , 'UTL_PURGE.RENAME_TEMP_TO_ORG' , 'Rename temp table '||i.owner||'.'||i.temp_table_name||' to '||i.owner||'.'||i.table_name||CHR(10));
          log_sql ('rename_temp_to_org','alter table '||i.owner||'.'||i.temp_table_name||' rename to '||i.table_name );
          execute immediate 'alter table '||i.owner||'.'||i.temp_table_name||' rename to '||i.table_name;
 
      end loop;
  end rename_temp_to_org;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : Create_indexes
  -- |  Parameter   :
  -- |  Description : Create indexes on a new tables
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure create_indexes
  as 
  begin
      log_info ( 'INFO' , 'UTL_PURGE.CREATE_INDEXES' , 'utl_purge.create_indexes');

      for i in (select owner,index_name,index_type,table_owner,table_name,decode(uniqueness,'UNIQUE',' unique ',' ') uniqueness,column_names,tablespace_name 
                  from utl$indexes
                 order by owner,table_name,index_name)
      loop
          -- Ignoring any duplicated indexes
          begin
          --if (i.index_type = 'NORMAL' ) then

              -- -----------------------------
              -- Changed to display only
              -- -----------------------------
              dbms_output.put_line('create'||i.uniqueness||'index '||i.owner||'.'||i.index_name||
                                   ' on '||i.table_owner||'.'||i.table_name||'('||i.column_names||')'||
                                   ' tablespace '||i.tablespace_name|| ' parallel '||parallel_degree||' nologging;');

              -- log_sql ('create_indexes','create'||i.uniqueness||'index '||i.owner||'.'||i.index_name||
              --               ' on '||i.table_owner||'.'||i.table_name||'('||i.column_names||') tablespace '||i.tablespace_name||
              --                          ' parallel '||parallel_degree||' nologging');

              --execute immediate 'create'||i.uniqueness||'index '||i.owner||'.'||i.index_name||
              --               ' on '||i.table_owner||'.'||i.table_name||'('||i.column_names||') tablespace '||i.tablespace_name||
              --                  ' parallel '||parallel_degree||' nologging';

          --end if;
          exception when others then
              log_info ( p_message => 'create'||i.uniqueness||'index '||i.owner||'.'||i.index_name||
                                        ' on '||i.table_owner||'.'||i.table_name||'('||i.column_names||') tablespace '||i.tablespace_name||
                                        ' parallel '||parallel_degree||' nologging');
              log_info ( p_message => SQLCODE ||' - '||SQLERRM );
              log_info ( p_message => dbms_utility.format_error_backtrace());
          end;

      end loop;
  end create_indexes;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : Create_constraints
  -- |  Parameter   :
  -- |  Description : Create constraints
  -- + ---------------------------------------------------------------------------------------------------------------------
  procedure create_constraints
  as
    v_iot_type varchar2(10);
  begin
      log_info ( 'INFO' , 'UTL_PURGE.CREATE_CONSTRAINTS' , 'utl_purge.create_constraints');

      /* Create Primary key */
      for i in (select owner, decode(constraint_type,'P',1,'U',2,'C',3,'R',4) constraint_type, constraint_name, table_name, column_names, 
                       search_condition, r_owner, r_table_name,
                       decode(constraint_type,'R',utl_purge.get_cons_columns(r_owner,r_constraint_name)) as r_column_names
                  from utl$constraints 
                 where constraint_type in ( 'P', 'U', 'R', 'C' )
                 order by owner, constraint_type, table_name, constraint_name)
      loop
          begin
              if ( i.constraint_type = '1' ) then  --// Primary Key

                  select nvl(iot_type,'NORMAL') into v_iot_type
                    from dba_tables
                   where owner = i.owner
                     and table_name = i.table_name
                     and iot_type is null; 

                  if v_iot_type = 'NORMAL' then
                      dbms_output.put_line('alter table '||i.owner||'.'||i.table_name||' add constraint '||i.constraint_name||
                                           ' primary key ('||i.column_names||') using index enable novalidate;');
                  end if;

              elsif ( i.constraint_type = '2' ) then  --// Unique Constraints 
                  dbms_output.put_line('alter table '||i.owner||'.'||i.table_name||' add constraint '||i.constraint_name||
                                       ' unique ('||i.column_names||') using index enable novalidate;');

              elsif ( i.constraint_type = '4' ) then  --// Foreign key Constraints
                  if i.r_column_names is null then
                      dbms_output.put_line('alter table '||i.owner||'.'||i.table_name||' add constraint '||i.constraint_name||
                                           ' foreign key ('||i.column_names||')'||
                                           ' references '||i.r_owner||'.'||i.r_table_name||' disable;'); 
                  else 
                      dbms_output.put_line('alter table '||i.owner||'.'||i.table_name||' add constraint '||i.constraint_name||
                                           ' foreign key ('||i.column_names||')'||
                                           ' references '||i.r_owner||'.'||i.r_table_name||'('||i.r_column_names||') disable;'); 

                  end if;

                  dbms_output.put_line('alter table '||i.owner||'.'||i.table_name||
                                       ' enable novalidate constraint '||i.constraint_name||';');

              else  --// Check Constraints 
                  log_sql('create_constraints', 'alter table '||i.owner||'.'||i.table_name||' add constraint '||i.constraint_name);
                  execute immediate 'alter table '||i.owner||'.'||i.table_name||
                                    ' add constraint '||i.constraint_name||
                                    ' check ('||i.search_condition||') enable novalidate';

              end if;
          exception when others then
              log_info ( p_message => SQLCODE ||' - '||SQLERRM );
              log_info ( p_message => dbms_utility.format_error_backtrace());
          end;
      end loop;

  end create_constraints;


  -- + ---------------------------------------------------------------------------------------------------------------------
  -- |  Package     : reorganize_obj
  -- |  Parameter   :
  -- |  Description : Reorganize objects
  -- + ---------------------------------------------------------------------------------------------------------------------

  procedure reorganize_obj ( p_parallel_degree number default 1 )
  as
  begin
      parallel_degree := p_parallel_degree;

      /* clean up conflict indexes */
      delete from utl$indexes
      where (owner,table_name) not in (select owner,table_name from utl$tables);

      /* clean up conflict constraints */
      delete from utl$constraints
      where constraint_type = 'R'
        and (owner,table_name) not in (select owner,table_name from utl$tables)
        and (r_owner,r_table_name) not in (select owner,table_name from utl$tables);
    
      delete from utl$constraints
      where constraint_type <> 'R'
        and (owner,table_name) not in (select owner,table_name from utl$tables);

      commit;

      /* drop all fk constraints */
      drop_fk_constraints;
 
      /* drop original tables */
      drop_org_tables;

      /* rename temp tables to original tables */
      rename_temp_to_org;

      /* create indexes */
      --create_indexes;

      /* create constraints */
      --create_constraints;      


  exception when others then
    log_info ( p_message => SQLCODE ||' - '||SQLERRM );
    log_info ( p_message => dbms_utility.format_error_backtrace());

  end reorganize_obj;

end utl_purge;
/





