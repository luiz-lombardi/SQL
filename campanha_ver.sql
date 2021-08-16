accept V_LOJA   prompt 'Informe a LOJA: '
accept V_VEND   prompt 'Informe o VEND: '
accept V_DATA   prompt 'Informe a DATA: '
set verify off
SELECT c.ID_EMP,c.ID_EMP ID_EMP_NF,c.ID_VEN,c.DT_CUPOM,
       i.id_ipr ID_IPR,p.id_np1 ID_NP1,(i.qt_vendida) QT_PRO,
       0 VL_COM,
round(((i.vl_preco * i.qt_vendida) - i.vl_desconto)
   - ((c.vl_desconto / 100) * (((i.vl_preco * i.qt_vendida) - i.vl_desconto) /
      (c.vl_cupom) * 100)),2) VL_CUPOM
FROM cupom c, item_cupom i, promocao_cam_inc p
where c.id_unn = i.id_unn
  and c.id_emp = i.id_emp
  and i.id_emp = p.id_emp
  and c.dt_cupom = i.dt_cupom
  and c.nr_pdv = i.nr_pdv
  and c.nr_cupom = i.nr_cupom
  and i.id_ipr = p.id_pro
  and c.id_unn = 1
  and c.id_emp = &V_LOJA
  and c.id_ven = &V_VEND
  and c.dt_cupom = '&V_DATA'
  and c.status not in (0,1,9)
  and nvl(c.cd_modal_ent,' ') not in ('F','O')
  and i.status not in (1,9)
  and p.id_cam = (select id_cam from meta_oportunidade where id_emp = &V_LOJA and '&V_DATA' between dt_ini and dt_fim)
order by 1,2,3;
SELECT n.ID_EMP,n.ID_EMP_NF ID_EMP_NF,n.ID_VEN,n.DT_PAGTO DT_PEDIDO,
       i.id_ipr ID_IPR,p.id_np1 ID_NP1,i.qt_vendida QT_PRO,
       0 VL_COM,
round((i.VL_LIQ_IT * (i.qt_vendida)) *
     ((n.VL_TOTAL-nvl(n.VL_FRETE,0)-nvl(n.VL_DESPESAS,0)) / n.VL_MERCAD),2) VL_PEDIDO
FROM pedido_venda n, item_pedido_venda i, promocao_cam_inc p
where n.id_unn = i.id_unn
  and n.id_emp = i.id_emp
  and n.id_pvd = i.id_pvd
  and n.id_emp_nf  = p.id_emp  -- Alterado em 12/11 para considerar depositos
  and i.id_ipr = p.id_pro
  and n.id_unn = 1
  and n.id_emp = &V_LOJA
  and n.id_ven = &V_VEND
  and n.dt_pedido = '&V_DATA'
  and n.dt_pedido = n.dt_pagto
  and n.dt_pagto is not null
  and n.cd_tipo_ped = 2
  and n.cd_encomenda = 'N'
  and nvl(n.cd_modal_ent,' ') <> 'R'
  and n.ST_SIT_PED in (12,20,30,40,99)
  and p.id_cam = (select id_cam from meta_oportunidade where id_emp = &V_LOJA and '&V_DATA' between dt_ini and dt_fim)
UNION ALL
SELECT n.ID_EMP,n.ID_EMP_NF ID_EMP_NF,n.ID_VEN,n.DT_PAGTO DT_PEDIDO,
       i.id_ipr ID_IPR,p.id_np1 ID_NP1,i.qt_vendida QT_PRO,
       0 VL_COM,
round((i.VL_LIQ_IT * (i.qt_vendida)) *
     ((n.VL_TOTAL-nvl(n.VL_FRETE,0)-nvl(n.VL_DESPESAS,0)) / n.VL_MERCAD),2) VL_PEDIDO
FROM pedido_venda n, item_pedido_venda i, promocao_cam_inc p
where n.id_unn = i.id_unn
  and n.id_emp = i.id_emp
  and n.id_pvd = i.id_pvd
  and n.id_emp_nf  = p.id_emp   -- Alterado em 12/11 para considerar depositos
  and i.id_ipr = p.id_pro
  and n.id_unn = 1
  and n.id_emp = &V_LOJA
  and n.id_ven = &V_VEND
  and n.dt_pagto = '&V_DATA'
  and n.dt_pagto > n.dt_pedido
  and n.dt_pagto is not null
  and n.cd_tipo_ped = 2
  and n.cd_encomenda = 'N'
  and nvl(n.cd_modal_ent,' ') <> 'R'
  and n.ST_SIT_PED in (12,20,30,40,99)
  and p.id_cam = (select id_cam from meta_oportunidade where id_emp = &V_LOJA and '&V_DATA' between dt_ini and dt_fim)
order by 1,2,3;
SELECT d.ID_EMP_VD ID_EMP,d.ID_EMP ID_EMP_NF,d.ID_VEN,d.DT_EMISSAO DT_EMISSAO,
       i.id_ipr ID_IPR,p.id_np1 ID_NP1,i.qt_embal * (-1) QT_PRO,
       0 VL_COM,
   round(((i.vl_unitario * i.qt_embal) - ((i.vl_unitario * i.qt_embal) / 100 * nvl(i.pc_desc,0))) -
     ((nvl(n.vl_desconto,0) / 100) *
       ((((i.vl_unitario * i.qt_embal) -
         ((i.vl_unitario * i.qt_embal) / 100 * nvl(i.pc_desc,0)))
        / (n.vl_total + n.vl_desconto - n.vl_frete)) * 100)),2) * (-1) VL_DEVOL
FROM nf_entrada_cliente n, item_nfe_cliente i, devolucao_cliente d, promocao_cam_inc p
where n.id_unn = i.id_unn
  and n.id_unn = d.id_unn
  and n.id_emp = i.id_emp
  and n.id_emp = d.id_emp
  and n.id_emp = p.id_emp
  and n.id_nfe = i.id_nfe
  and n.id_serie = i.id_serie
  and n.id_dev = d.id_dev
  and n.id_unn = 1
  and n.id_emp = &V_LOJA
  and d.id_ven = &V_VEND
  and n.dt_emissao = '&V_DATA'
  and n.st_sit_nf = 20
  and i.id_ipr = p.id_pro
  and p.id_cam = (select id_cam from meta_oportunidade where id_emp = &V_LOJA and '&V_DATA' between dt_ini and dt_fim)
order by 1,2,3;
SELECT d.ID_EMP_VD ID_EMP,d.ID_EMP ID_EMP_NF,d.ID_VEN,d.DT_EMISSAO DT_EMISSAO,
       i.id_ipr ID_IPR,p.id_np1 ID_NP1,(i.qt_vendida - i.qt_ent_ret) * (-1) QT_PRO,
       0 VL_COM,
round((i.VL_LIQ_IT * (i.qt_vendida - i.qt_ent_ret)) *
     ((n.VL_TOTAL-nvl(n.VL_FRETE,0)-nvl(n.VL_DESPESAS,0)) / n.VL_MERCAD),2) * (-1) VL_ANULA
FROM devolucao_cliente d, pedido_venda n, item_pedido_venda i, promocao_cam_inc p
where d.id_unn = n.id_unn
  and d.id_unn = i.id_unn
  and d.id_emp = n.id_emp
  and d.id_emp = i.id_emp
  and d.id_emp = p.id_emp
  and d.id_emp_nf = p.id_emp  -- Alterado em 12/11 para considerar depositos
  and d.id_emp_nf = n.id_emp_nf
  and d.id_pvd = n.id_pvd
  and d.id_pvd = i.id_pvd
  and d.id_unn = 1
  and d.id_emp = &V_LOJA
  and d.id_ven = &V_VEND
  and d.dt_emissao = '&V_DATA'
  and d.id_ttr = 37
  and n.cd_tipo_ped = 2
  and n.dt_pagto is not null
  and nvl(n.cd_modal_ent,' ') <> 'R'
  and n.cd_encomenda = 'N'  -- Alterado em 13/10 para desconsiderar encomendas
  and n.ST_SIT_PED = 99
  and i.id_ipr = p.id_pro
  and (i.qt_vendida - i.qt_ent_ret) > 0
  and p.id_cam = (select id_cam from meta_oportunidade where id_emp = &V_LOJA and '&V_DATA' between dt_ini and dt_fim)
order by 1,2,3;