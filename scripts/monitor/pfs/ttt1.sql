rem    SELECT /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */

rem ALTER SESSION SET "_always_star_transformation"= TRUE;

explain plan for
  SELECT  /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */
          K.IDFO,
          K.IDTRANCHE,
          (SELECT t.udtranche
             FROM fis.ft_tranche t
            WHERE t.idtranche = k.idtranche)
             AS UDTRANCHE,
          K.IDKTO,
          P.UDKTO,
          K.IDKTOKAT,
          K.idkTO,
          K.NZVORTRAG, 
          K.FCVORTRAG, 
          K.IDKTODEV,
          K.IDLand,
          K.NZSALDO, 
          K.FCSALDO,
          F.IDFODEV
     FROM fis.FT_KTO K, fis.FT_KTOPLAN P, fis.FT_FONDS F, dvs.SV_READ_NS Y
    WHERE K.IDKTO = P.IDKTO AND F.IDFO = K.IDFO
      AND K.IDNS = P.IDNS
      AND K.IDNS = Y.IDNS
      AND P.IDNS = Y.IDNS
      AND Y.idSCHEMA = 17;

