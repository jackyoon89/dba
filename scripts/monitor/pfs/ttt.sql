rem   SELECT /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */
explain plan for
   SELECT /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */
          T.IDFO,
          T.UDFO,
          T.SZKBEZ,
          T.SZBEZ,
          T.DTFWEM,
          T.UTFOT,
          T.IDFODEV,
          T.IDOCDEV,
          T.IDREFO,
          T.IDEM,
          T.UTIVG,
          T.IDIVG,
          T.DTSTART,
          T.DTULTIMO,
          T.DTEURO,
          T.DTGJPLANSTART,
          T.UTBZFWEM,
          T.ISETKBESTAND,
          T.UTOP,
          T.ISPOOL,
          T.NZGJMONAT,
          T.DTGJSTART,
          T.IDPARFO,
          T.DTSTOP,
          T.ISTRANCHE,
          T.ISLAUFZEIT,
          T.IDDBK,
          T.IDLAND,
          T.IDUMBRELLA,
          T.IDNS,
          T.DTUPDATE,
          T.IDDSN
     FROM FIS.FT_FONDS T, DVS.SV_READ_FO S
    WHERE     EXISTS
                 (SELECT 1
                    FROM DVS.SV_READ_NS Y
                   WHERE Y.idNS = T.idNS AND Y.idSCHEMA = 17)
       AND S.IDFO = T.IDFO;
/
