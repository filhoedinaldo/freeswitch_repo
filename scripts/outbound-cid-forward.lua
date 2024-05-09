--outbound-cid-forward.lua
require "resources.functions.config"

src = session:getVariable("caller_id_number");
d_uuid = session:getVariable("domain_uuid");

c = string.sub(src, 0, 2);
if (c == "s-") then
        src = string.sub(src,3,6);
end
if (c == "w-") then
        src = string.sub(src,3,6);
end

session:consoleLog("info", "[UNITY] Set Outbound Caller ID Number " .. src .. "\n");
--connect to the database
        require "resources.functions.database_handle";
        dbh = database_handle('unity');
        if (d_uuid ~= nil) then
                my_query = "select outbound_caller_id_number from v_extensions where extension = '" .. src .."' AND domain_uuid  = '" .. d_uuid .."' AND excluido = false limit 1";

                session:consoleLog("info", "[UNITY DEBUG]" .. my_query);
                --session:consoleLog("info", "[UNITY DEBUG]" .. d_uuid);
                --session:setVariable("intersite","false");
                dbh:query(my_query, function(row)

                        session:consoleLog("info", "[UNITY DEBUG] Outbound Caller ID set... "..row.outbound_caller_id_number);
                        --session:setVariable("effective_caller_id_number",row.outbound_caller_id_number);
                        session:setVariable("outbound_caller_id_number",row.outbound_caller_id_number);
                end)
        end
