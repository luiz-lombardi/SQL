select ef.id_gre,
       ef.id_ipr,
       substr(fnct_pro001(ef.id_ipr),0,25),
       ef.qt_fis,
       ef.vl_custo_real / ef.qt_fis VL_CUST_UNIT,
       max(ef.dt_confer),
   sum(ef.VL_CUSTO_REAL) VL_CUST_TOT
from estoque_faixa_regiao ef,
     estoque e
where ef.id_unn = e.id_unn
  and ef.id_unn = 1
  and e.id_emp  = decode(ef.id_gre, 1,62, 1,56, 1,58, 1,59, 2,54, 2,55, 3,52, 4,51, 5,50, 5,60, 7,61, 6,57)
  and ef.id_ipr = e.id_ipr
--   and ef.id_gre   in ($Regiao)
  and nvl(ef.dt_confer,'01/06/2000') between '01/06/2000' and sysdate - 90
  and ((ef.qt_fis / (case when ef.nr_mdv = 0 then 0.001 else ef.nr_mdv end)) =0 or
       (ef.qt_fis / (case when ef.nr_mdv = 0 then 0.001 else ef.nr_mdv end)) > 180)
  and ef.id_for = 2127
group by ef.id_gre,ef.id_ipr,ef.qt_fis,ef.vl_custo_real
order by 6 desc,ef.id_gre,ef.id_ipr
/
