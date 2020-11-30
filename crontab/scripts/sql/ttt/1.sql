col segment_name format a30

select owner, segment_name, bytes, blocks from dba_segments where segment_name = 'STP_EVENT';

