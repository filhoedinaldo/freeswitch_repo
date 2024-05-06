-- callcenter-announce-wait-time.lua
-- callcenter_announce_wait_time.lua
-- Announce avg wait time of the queue.

require "resources.functions.config"
require "resources.functions.database_handle";

dbh = database_handle('log');
api = unity.API();


-- Arguments are, in order: caller uuid, queue_name, interval (in milliseconds).
api = unity.API()
caller_uuid = argv[1]
queue_name = argv[2]
mseconds = argv[3]
path_sound="/opt/digivox/unity/unity-sip-server/share/unity/sounds/pt/BR/karina/time/"


sql = [[select CEIL(AVG(tempo_espera) / 60) as espera from summary_v_call_center_ligacao where inicio between CURRENT_DATE and CURRENT_TIMESTAMP and queue = ']] .. queue_name ..[[']];
if caller_uuid == nil or queue_name == nil or mseconds == nil then
    return
end
while (true) do
    -- Pause between announcements
    unity.msleep(mseconds)
    unity.consoleLog("info", "========== CC QUEUE SQL "..sql);

    dbh:query(sql, function(row)
           espera = string.lower(row["espera"]);
    end);

    members = api:executeString("callcenter_config queue list members "..queue_name)
--    pos = 1
    exists = false
    for line in members:gmatch("[^\r\n]+") do
        if (string.find(line, "Trying") ~= nil or string.find(line, "Waiting") ~= nil) then
            -- Members have a position when their state is Waiting or Trying
            if string.find(line, caller_uuid, 1, true) ~= nil then
                -- Member still in queue, so script must continue
                exists = true
                api:executeString("uuid_broadcast "..caller_uuid.." " .. path_sound .. "voce_sera_atendido_em_ate.wav aleg")
                unity.consoleLog("info", "========== ESPERA "..espera);
                api:executeString("uuid_broadcast "..caller_uuid.." 'say::pt number pronounced "..espera.."' aleg")
               if  espera == "1"  then
                        api:executeString("uuid_broadcast "..caller_uuid.." " .. path_sound .. "8000/minute.wav aleg")
               else        
                        api:executeString("uuid_broadcast "..caller_uuid.." " .. path_sound .. "8000/minutes.wav aleg")
               end


            end
--            pos = pos+1
        end
    end
    -- If member was not found in queue, or it's status is Aborted - terminate script
    if exists == false then
        return
    end
end