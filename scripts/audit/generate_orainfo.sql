
Set echo off

/***********************************************************************************************************************************/
/* SQL Statements to be run for Audit*/
/* Please run for the specific production databases to be tested */
/* Please edit the spool file name to include the name the database */
/* Please make sure you run the SET and alter session statements at the beginning of this script file */
/* Please deliver a copy of the spool files created to the Audit team */
/***********************************************************************************************************************************/

/* For use with Oracle 8i - 10g */

/***********************************************************************************************************************************/
/* Revision History */
/***********************************************************************************************************************************/

/***********************************************************************************************************************************/
/* V 1 - 6 - Various revisions to accomodate new DBA_ and V$_ views for Oracle Versions                                            */
/*                                                                                                                                 */
/* V 7 - Changed line size to 1000 to force a wrap at the max available in Monarch v7                                              */
/*                                                                                                                                 */
/* V 7.1 - 8-July-2008 - Added describe of v$ parameter 2, changed order of line count select statements, added                    */
/* explnatory comment about describe statements                                                                                    */
/*                                                                                                                                 */
/* v 7.2 - added select * from v$database to script - gives data on archive log mode - other info may be useful.                   */ 
/* Also added describe of v&database and select count(*)of view for check total                                                    */
/*                                                                                                                                 */
/* v 7.3 - 15-July-2009 Changed source of dbname to instance_name parameter - specifies unique name for                            */ 
/* RAC nodes.  Moved product_component_version to top of file so output is more user friendly.                                     */ 
/*                                                                                                                                 */
/* v 7.4 - 31-Aug-2009                                                                                                             */
/* re-arranged and added 'set echo . . .' statements to clean up output some.  Used 'column ...                                    */
/* syntax to force EXTERNAL_NAME column in DBA_USERS view to 100 chars.                                                            */
/* Moved select * from product_component_version to top of file for ease of access                                                 */
/*                                                                                                                                 */
/* v 7.5 - 09-Nov-2009                                                                                                             */
/* Updated spool file default name and added app switch to spool command to help prevent inadvertant                               */
/* overwrite when running in multiple DBs.                                                                                         */
/*                                                                                                                                 */
/* v 7.6 - 19-May-2010                                                                                                             */
/* Changed sort order on DBA_TAB_PRIVS to make raw output more useful.                                                             */
/*                                                                                                                                 */                   
/* Fixed Syntax of Alter Session command and column format commands by adding semicolon.                                           */
/*                                                                                                                                 */
/* limiting length of some views using column commands to wrap output at 50 or 100 chars to accomodate Monarch                     */
/* width limitations.                                                                                                              */
/*                                                                                                                                 */
/* dba_users                                                                                                                       */
/* v$parameter                                                                                                                     */
/* v$parameter2                                                                                                                    */
/* v$database                                                                                                                      */
/* dba_db_links                                                                                                                    */
/*                                                                                                                                 */
/* Added Select sysdate line at top to help identify appended sections of files.                                                   */
/*                                                                                                                                 */
/* Added Set Echo on/off statements to make output more clean.                                                                     */
/*                                                                                                                                 */
/* v 7.6.1 - 24-Jun-2010                                                                                                           */
/*                                                                                                                                 */
/* Moved terminal set up statements to after the initial select of Instance Name and product component version                     */
/* to make output more readable.                                                                                                   */
/*                                                                                                                                 */
/* Added column statement to force OBJECT_TYPE in DBA_OBJECTS Output to correct width for 10g template in Oracle 8i                */
/*                                                                                                                                 */
/* v 7.7 - 30-Jul-2010                                                                                                      */
/*                                                                                                                                 */
/* Additional clean up of script structure for readability.                                                                        */
/*                                                                                                                                 */
/* Add statement to extract password verify function text if password verify function is in use.                                   */
/*                                                                                                                                 */
/*                                                                                                                                 */
/*                                                                                                                                 */
/*                                                                                                                                 */
/*                                                                                                                                 */
/***********************************************************************************************************************************/

/***********************************************************************************************************************************/
/* ****************************in progress not complete******************************************/
/*  */
/*  */
/* THERE ARE SUB-VERSIONS OF LATEST MAJOR RELEASE - INCORPORATE THEM INTO THIS */
/*  */
/*  */
/* prepend instance name to output using context function.  */
/*  */
/* Automate output file name creation.  Include section to select the current date/time into a variable and embed into the output file name to make unique  */
/* in order to prevent inadvertant overwrite.  Put a standard destination for the file   ?????? create a separate Unix version?  */
/*  */
/* Work on setting column names on/off to clean up output */
/*  */
/* look at using sys_context() to prepend instance name to all tables */
/* also consider generating keys in output. */
/*  */
/* consider prepending view name to select output lines to make more Monarch friendly.   */
/* Long term may be able to do general select as .csv file with table names prepended and do separation in Access????? */
/*  */
/* Can also add select from dual to add table name between each group of output.  */
/*  */
/*  */
/*  */
/*  */
/*  */
/*  */
/*  */
/* ****************************in progress not complete******************************************/
/***********************************************************************************************************************************/

/***********************************************************************************************************************************/
/***************************************************** MAIN SCRIPT STARTS HERE *****************************************************/
/***********************************************************************************************************************************/

/***********************************************************************************************************************************/
/* PLEASE EDIT THE SPOOL FILE NAME BELOW TO INCLUDE THE NAME OF THE DATABASE */
/***********************************************************************************************************************************/

Spool C:\output\db_output.txt

/* Set up terminal session so that output is formatted correctly */

Set linesize 1000
Set pagesize 9999
Set trimspool on

col global_name format a40
col dbname format a40
col sysdate format a40

select * from global_name;
select value dbname from v$parameter where name = 'instance_name';
select to_char(sysdate, 'MM-DD-YYYY HH24:MI:SS') "Information As Of" from dual;

Set echo on

select * from product_component_version;

Set echo off

/* Set Date Format to US Standard */ 

Set echo on

alter session set nls_date_format = "MM/DD/YYYY";      

Set echo off

/* Limit External_Name column width to 100 chars and wrap lines - this is usually unused at SSC */

column EXTERNAL_NAME format a100 wrapped;                 

Set echo on

select * from sys.dba_users order by username;

select * from sys.dba_roles order by role;

select * from sys.dba_role_privs order by granted_role;

select * from sys.dba_col_privs;

select * from sys.dba_sys_privs order by PRIVILEGE;

select * from sys.dba_tab_privs order by GRANTEE,TABLE_NAME,PRIVILEGE;

set echo off

spool off
