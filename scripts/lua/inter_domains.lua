-- Unity Smartspace
-- inter_domains
-- Version: 6.0
-- Date: 16/10/2024
-- Edinaldo Lima <edinaldo.lima@smartspace.us>

-- The Initial Developer of the Original Code is
-- Edinaldo Lima <edinaldo.lima@smartspace.us>
-- Portions created by the Initial Developer are Copyright (C) 2014-2020
-- the Initial Developer. All Rights Reserved.

-- Funções gerais
require "resources.functions.config"
require "resources.functions.explode"
-- require "resources.functions.file_exists"
require "resources.functions.database_handle"

-- Função para realizar o transfer para o dominio de destino.
local function execute_query(dbh, query, destination_number, empresa)
    local has_result = false
    local len_extension = tonumber(session:getVariable("len_extension")) or 4  -- Tamando de digitos dos ramais

    dbh:query(query, function(row)
        if row then
            has_result = true
            local domain_name = row.domain_name
            local domain_description = row.domain_description
            local prefix = row.u_codigo
            local numero_inicio = row.numero_inicio
            local numero_fim = row.numero_fim

            local ramal = string.sub(destination_number, -len_extension)

            unity.consoleLog("INFO", "========== INTER DOMAINS TRANSFERENCIA ENTRE DOMINIOS COM SUCESSO! \n")
            unity.consoleLog("INFO", "========== INTER DOMAINS EMPRESA: " .. empresa .."\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS NOME UNIDADE: " .. domain_description .."\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS DOMAIN NAME: " .. domain_name .."\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS PREFIX UNIDADE: " .. prefix .. "\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS TAMANHO DIGITOS RAMAL: " .. tostring(len_extension) .. "\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS NUMERO DISCADO: " .. destination_number .. "\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS RAMAL DESTINO: " .. ramal .."\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS NUMERO INICIAL: " .. numero_inicio .."\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS NUMERO FINAL: " .. numero_fim .."\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS Transferindo para a unidade: " .. domain_description .. "\n")
            
            session:setVariable("destination_number", ramal)
            session:execute("transfer", ramal .. " XML " .. domain_name)

        end
    end)

    if not has_result then
        unity.consoleLog("INFO", "========== INTER DOMAINS O numero " .. destination_number .. " não foi encontrado em Cadastro de Numeros, nos dominios da Empresa ".. empresa .."\n")
        unity.consoleLog("INFO", "========== INTER DOMAINS FIM DO SCRIPT INTER DOMAINS \n")
    end
end

-- Função para obter a empresa com base no domain_name de origem
local function get_empresa_by_domain_name(dbh, domain_name)
    local empresa = nil
    local query = string.format([[
        SELECT empresa
        FROM v_domains
        WHERE domain_name = '%s'
    ]], domain_name)

    dbh:query(query, function(row)
        if row then
            empresa = row.empresa
            unity.consoleLog("INFO", "========== INTER DOMAINS Query para pesquisar o nome da empresa no dominio " .. domain_name .. "\n" .. query .. "\n")
            unity.consoleLog("INFO", "========== INTER DOMAINS RESULTADO Query empresa: " .. empresa .. "\n")
        end
    end)

    return empresa
end

-- Função para procurar nos dominios, que tem o nome de empresa igual, o numero discado em Cadastro de Numeros.
local function process_transfer_without_domain(dbh, destination_number, empresa)
    local query = string.format([[
        SELECT 
            d.domain_uuid, 
            d.domain_name, 
            d.domain_description, 
            d.u_codigo, 
            n.numero_inicio, 
            n.numero_fim
        FROM v_domains d
        LEFT JOIN numeros_dominio n 
            ON d.domain_uuid = n.domain_uuid
        WHERE 
            d.empresa = '%s'
            AND '%s' BETWEEN n.numero_inicio AND n.numero_fim
    ]], empresa, destination_number)
    unity.consoleLog("INFO", "========== INTER DOMAINS Query para pesquisar o numero " .. destination_number .. " em Cadastro de Numeros, nos dominios com empresa de nome " .. empresa .. ". \n" .. query .. "\n")

    execute_query(dbh, query, destination_number, empresa)
end

-- Obter o número discado e o domínio
local destination_number = session:getVariable("destination_number_inter_domains")
local domain_name = session:getVariable("domain_name")  -- Usando a variável 'domain_name' para buscar 'empresa'

-- Conectar ao banco de dados PostgreSQL
local dbh = database_handle('unity')

-- Verificar se a conexão foi estabelecida
if not dbh:connected() then
    unity.consoleLog("ERRO", "========== INTER DOMAINS Erro ao conectar ao banco de dados.\n")
    unity.consoleLog("INFO", "========== INTER DOMAINS FIM DO SCRIPT INTER DOMAINS \n")
    return
end

-- Obter o valor da empresa com base no domain_name
local empresa = get_empresa_by_domain_name(dbh, domain_name)

if empresa then
    -- Passar a variável empresa para a função
    process_transfer_without_domain(dbh, destination_number, empresa)
else
    unity.consoleLog("INFO", "========== INTER DOMAINS Nenhuma empresa encontrada para o domain_name: " .. domain_name .. "\n")
    unity.consoleLog("INFO", "========== INTER DOMAINS FIM DO SCRIPT INTER DOMAINS \n")
end
