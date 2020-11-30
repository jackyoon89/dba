set verify off
set timing on

prompt WHITNEY.AUDIT_LOG:
DELETE WHITNEY.AUDIT_LOG          WHERE DATE_TIME       < ADD_MONTHS(SYSDATE, -&&1);

prompt WHITNEY.ORDER_HISTORY:
DELETE WHITNEY.ORDER_HISTORY      WHERE EVENT_DATE_TIME < ADD_MONTHS(SYSDATE, -&&1);

prompt WHITNEY.JOURNAL_ENTRY:
DELETE WHITNEY.JOURNAL_ENTRY      WHERE EFFECTIVE_DATE  < ADD_MONTHS(SYSDATE, -&&1);

prompt WHITNEY.BR_ACCOUNT_BALANCE:
DELETE WHITNEY.BR_ACCOUNT_BALANCE WHERE POST_DATE       < ADD_MONTHS(SYSDATE, -&&1);

exit;
