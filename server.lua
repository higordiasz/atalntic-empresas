local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRP._prepare("creative/update_dono","UPDATE atlantic_empresas SET user_id = @ped, last = @last WHERE id = @id")
vRP._prepare("creative/update_last","UPDATE atlantic_empresas SET last = @last WHERE id = @id AND user_id = @user_id")
vRP._prepare("creative/get_dono", "SELECT user_id FROM atlantic_empresas WHERE id = @id")
vRP._prepare("creative/check_dono", "SELECET * FROM atlantic_empresas WHERE id = @id AND user_id = @user")
vRP._prepare("creative/get_last", "SELECT last, rendimento, max FROM atlantic_empresas WHERE id = @id AND user_id = @user")

vRPex = {}
Tunnel.bindInterface("atlantic_empresas", vRPex)

local webhookEmpresas = ""

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

function vRPex.checarSeTemDono (id) 
    local src = source
    local user_id = vRP.getUserId(src)
    if user_id then
        local query = vRP.execute("creative/get_dono", {id = id})
        if query and query[1] and query[1].user_id > 0 then
            local identity = vRP.getUserIdentity(query[1].user_id)
            return identity
        else
            return ""
        end
    end
end

function vRPex.CheckDono(id)
    local src = source
    local user_id = vRP.getUserId(src)
    if user_id then
        local query = vRP.execute("creative/check_dono", {id = id, user = user_id})
        if query and query[1] then
            return true
        else
            return false
        end
    else
        return false
    end 
end

function vRPex.comprarLoja (id)
    local src = source
    local user_id = vRP.getUserId(src)
    if user_id then
        local query = vRP.execute("creative/get_dono", {id = id})
        if query and query[1] then
            local playerBalance = vRP.getBankMoney(user_id)
            if tonumber(query[1]) < playerBalance then
                vRP.setBankMoney(user_id, tonumber(playerBalance - tonumber(query[1])))
                vRP.execute("creative/update_dono", {id = id, ped = user_id, last = tonumber(os.time())})
                return true
            else
                TriggerClientEvent("Notify",source,"negado","Você não possui saldo suficiente.",10000);
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function vRPex.cehckBalance (id)
    local src = source
    local user_id = vRP.getUserId(src)
    local time = tonumber(os.time())
    if user_id then
        local query = vRP.execute("creative/get_last", {id = id, user = user_id})
        if query and query[1] then
            local ant = tonumber(query[1].last)
            local dif = time - ant
            local trend = 1800 -- tempo em segundos entre cada rendimento
            if dif > trend then
                local r = math.floor(dif / trend)
                if r > 0 then
                    local rendimentos = r * tonumber(query[1].rendimento)
                    if rendimentos > tonumber(query[1].max) then
                        return query[1].max
                    else
                        return rendimentos
                    end
                else
                    return 0
                end
            else
                return 0
            end
        else
            return 0
        end
    else
        return 0
    end
end

function vRPex.sacarGrana (id)
    local src = source
    local user_id = vRP.getUserId(src)
    if user_id then
        local query = vRP.execute("creative/get_last", {id = id, user = user_id})
        if query and query[1] then
            local ant = tonumber(query[1].last)
            local dif = time - ant
            local trend = 1800
            if dif > trend then
                local r = math.floor(dif / trend)
                if r > 0 then
                    local rendimentos = r * tonumber(query[1].rendimento)
                    if rendimentos > tonumber(query[1].max) then
                        local banco = vRP.getBankMoney(user_id)
                        vRP.setBankMoney(user_id, tonumber(banco) + tonumber(query[1].max))
                        TriggerClientEvent("Notify",source,"sucesso","Foi retirado ~r~"..query[1].max.."~r~ do cofre do estabelecimento",10000);
                        vRP.execute("creative/update_last", {last = tonumber(os.time()), id = id, user_id = user_id})
                    else
                        local banco = vRP.getBankMoney(user_id)
                        vRP.setBankMoney(user_id, tonumber(banco) + rendimentos)
                        TriggerClientEvent("Notify",source,"sucesso","Foi retirado ~r~"..rendimentos.."~r~ do cofre do estabelecimento",10000);
                        vRP.execute("creative/update_last", {last = tonumber(os.time()), id = id, user_id = user_id})
                    end
                else
                    return
                end
            else
                return
            end
        else
            return
        end
    end
end