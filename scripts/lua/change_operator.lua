--change_operator.lua
--Troca automatica da operadora

require "resources.functions.config"
require "resources.functions.database_handle";

--dbh_core = database_handle('system');
dbh = database_handle('unity');
api = unity.API();

src = session:getVariable("caller_id_number");
domain_name = session:getVariable("domain_name");
domain_uuid = session:getVariable("domain_uuid");

destination_number = session:getVariable("destination_number");


sql = [[select rcs.codigo_operadora from roteamento_chamada_saida rcs inner join v_domains d on (rcs.domain_uuid = d.domain_uuid) where d.domain_uuid = ']] .. domain_uuid ..[[']];
unity.consoleLog("info", "========== UNITY - DESTINATION NUMBER "..destination_number);
unity.consoleLog("info", "========== UNITY - OPERADORA DDD "..sql);
dbh:query(sql, function(row)
        operadora = row["codigo_operadora"];
end);

if (operadora ~=nil and operadora ~= "") then
        new_destination = operadora..string.sub(destination_number, 4, string.len(destination_number));
        unity.consoleLog("info", "========== UNITY - OPERADORA DDD "..new_destination);
        session:setVariable("destination_number",new_destination);
end
