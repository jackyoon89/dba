set heading off

select decode(length(max(trade_id)),16,'Warning: trade_id=16 characters, buffer limit met','Trade_id length check okay.') 
from whitney.trade;

exit
