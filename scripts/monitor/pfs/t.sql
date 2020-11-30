alter session set current_schema=FIS;
rem alter session set optimizer_index_caching=100;
rem alter session set optimizer_index_cost_adj=1;


rem SELECT /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */ 
explain plan for
  SELECT 
          s.dt,
          s.idfo,
          f.udfo,
          f.szfonds,
          K.idtranche,
          tr.udtranche,
          tr.sztranche,
          f.idfodev,
          fd.uddev AS udfodev,
          K.idktodev,
          kd.uddev AS udktodev,
          s.idkto,
	ROUND (s.nzsaldo, kd.nzprecision) AS nzsaldo,
	ROUND (s.fcsaldo, fd.nzprecision) AS fcsald,
          K.idktokat,                              
          P.udkto,                                
          P.szkto,                                
          ROUND (K.nzvortrag, kd.nzprecision) AS nzvortrag,
          ROUND (K.fcvortrag, fd.nzprecision) AS fcvortrag,
          K.idland,
          l.udland,
          x.idperkat,
          x.szperkat
     FROM fvb_per_kat x,
          ft_ktostand s,
          fvb_kto K,
          fvb_fonds f,
          fvb_tranche tr,
          fvb_kto_plan P,
          ft_land l,
          ft_devise kd,
          ft_devise fd
    WHERE s.dt BETWEEN x.dtvon AND x.dtbis
          AND s.idkto = K.idkto
          AND s.idfo = K.idfo
          AND s.idfo = f.idfo
          AND P.idkto = K.idkto
          AND K.idtranche = tr.idtranche(+)
          AND K.idktodev = kd.iddev
          AND f.idfodev = fd.iddev
          AND K.idland = l.idland(+);
