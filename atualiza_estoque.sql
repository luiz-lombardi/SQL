declare
   l_envelope       VARCHAR2(32767);
   l_http_request   UTL_HTTP.req;
   l_http_response  UTL_HTTP.resp;
   v_nm_pro         varchar2(1000);
   v_descr_pro      varchar2(1000);
   v_cabecalho      clob;
   v_retorno        clob;
   bla              clob;
   env              clob;
   responsebody     clob;
   CURSOR C IS
      SELECT P.ID_PRO, P.NM_PRO_ECOMM, R.ID_NP1 
      from produto_interface_ecommerce p, produto r
      where p.id_pro = r.id_pro 
        and not exists
         (select 'x' from produto_empresa e
          where e.id_pro = p.id_pro
            and e.id_unn = 1
            and e.id_emp in (102,157)
         )
        and r.id_np1 > 9;
   V_C C%ROWTYPE;
   --
BEGIN
   OPEN C;
      LOOP
         FETCH C INTO V_C;
         EXIT WHEN C%NOTFOUND;
         --
         dbms_output.put_line('1');
         l_http_request := UTL_HTTP.begin_request('http://webservice-casashow.vtexcommerce.com.br/Service.svc', 'POST','HTTP/1.1');
         dbms_output.put_line('2');
         --
         bla := '<?xml version="1.0" encoding="utf-8"?>
                    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
                       <soapenv:Header/>
                          <soapenv:Body>
                           <tem:WareHouseIStockableUpdate>
                                 <tem:IdEstoque>2</tem:IdEstoque>
                                 <tem:IdSku>'||V_C.ID_PRO||'</tem:IdSku>
                                 <tem:Quantidade>0</tem:Quantidade>
                                 <tem:dateOfAvailability>9999-10-11T00:00:00.000Z</tem:dateOfAvailability>
                           </tem:WareHouseIStockableUpdate>
                          </soapenv:Body>
                    </soapenv:Envelope>';

         UTL_HTTP.SET_AUTHENTICATION(l_http_request, 'integracao', '123mudar');
         UTL_HTTP.set_header(l_http_request, 'Content-Type', 'text/xml'); -- text/xml
         UTL_HTTP.set_header(l_http_request, 'Content-Length', length(bla));
         UTL_HTTP.set_header(l_http_request, 'SOAPAction', 'http://tempuri.org/IService/WareHouseIStockableUpdate');
         UTL_HTTP.write_text(l_http_request, bla);
         l_http_response := UTL_HTTP.get_response(l_http_request);
         --UTL_HTTP.read_text(l_http_response, l_envelope);
         env := null;
         -- Trata retorno
         begin
            LOOP
               utl_http.read_text(l_http_response, responsebody, 1000);
               env := env || responsebody;
            END LOOP;
         exception
            WHEN utl_http.end_of_body THEN
               utl_http.end_response(l_http_response);
         END;
         ENV := replace(replace(ENV, chr(38) || 'lt' || chr(59), '<'), chr(38) || 'gt' || chr(59),'>');
---------------------------------------------------------------------------------------------------------------
--         begin
--            update produto_interface_ecommerce 
--               set cd_envio_ecomm = 'S',
--                   dt_envio_ecomm = trunc(sysdate),
--                   id_usu_liber_ecomm = user
--             where id_pro = v_c.id_pro;
--         end;
         --
--         commit;
      END LOOP;
   CLOSE C;
EXCEPTION WHEN UTL_HTTP.end_of_body THEN
  utl_http.end_response(l_http_response);
END;
/
