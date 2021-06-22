local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPex = Tunnel.getInterface("atlantic_empresas")

local lojas = {
    [1] = {
        ['id'] = 1,
        ['x'] = 119.10,
        ['y'] = -883.70,
        ['z'] = 31.12,
        ['valor'] = 200000,
        ['rendimento'] = 1500
    }
}

Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local coordsx, coordsy, coordsz = table.unpack(GetEntityCoords(ped))
        for i = 1, 1 do
            local disblip =
                GetDistanceBetweenCoords(coordsx, coordsy, coordsz, lojas[i].x, lojas[i].y, lojas[i].z, true)
            if disblip < 70 then
                local dono = vRPex.checarSeTemDono(i)
                if dono == "" then
                    Opacidade = math.floor(255 - (disblip * 10))
                    TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 0.4, "APERTE ~r~[ E ]~w~ PARA COMPRAR O ESTABELECIMENTO", Opacidade, 0.54, 0.54)
                    DrawMarker(27, lojas[i].x, lojas[i].y, lojas[i].z - 0.5, 0, 0, 0, 0, 0, 0, 1.501, 1.5001, 0.5001, 255, 0, 0, 155, 0, 0, 0, 1)
                    TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 1, '~r~VALOR: '..lojas[i].valor..'', Opacidade, 0.54, 0.54)
                    TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 0.7, '~r~RENDIMENTO: '..lojas[i].rendimento..'', Opacidade, 0.54, 0.54)
                    if disblip < 1.5 then
                        if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                            --Função de compra
                            if vRPex.comprarLoja(i) then
                                TriggerEvent("Notify","sucesso","Estabelecimento comprado com sucesso.",10000)
                            end
                        end
                    end
                else
                    if vRPex.CheckDono(i) then 
                        Opacidade = math.floor(255 - (disblip * 10))
                        TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 0.4, "APERTE ~r~[ E ]~w~ PARA SACAR O DINEHRI", Opacidade, 0.54, 0.54)
                        DrawMarker(27, lojas[i].x, lojas[i].y, lojas[i].z - 0.5, 0, 0, 0, 0, 0, 0, 1.501, 1.5001, 0.5001, 255, 0, 0, 155, 0, 0, 0, 1)
                        TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 0.7, '~r~CAIXA: '..vRPex.cehckBalance(i)..'', Opacidade, 0.54, 0.54)
                        if disblip < 1.5 then
                            if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                                --Função de sacar
                                vRPex.sacarGrana(i)
                            end
                        end
                    else
                        Opacidade = math.floor(255 - (disblip * 10))
                        TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 0.4, "DONO DO ESTABELICIMENTO: ~r~"..dono.."~w~", Opacidade, 0.54, 0.54)
                        DrawMarker(27, lojas[i].x, lojas[i].y, lojas[i].z - 0.5, 0, 0, 0, 0, 0, 0, 1.501, 1.5001, 0.5001, 255, 0, 0, 155, 0, 0, 0, 1)
                        TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 1, '~r~VALOR: '..lojas[i].valor..'', Opacidade, 0.54, 0.54)
                        TextoMarker(lojas[i].x, lojas[i].y, lojas[i].z + 0.7, '~r~RENDIMENTO: '..lojas[i].rendimento..'', Opacidade, 0.54, 0.54)
                    end
                end
            end
        end
    end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
    SetTextFont(font)
    SetTextScale(scale,scale)
    SetTextColour(r,g,b,a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT
-----------------------------------------------------------------------------------------------------------------------------------------
function drawText(text,font,x,y,scale,r,g,b,a)
    SetTextFont(font)
    SetTextScale(scale,scale)
    SetTextColour(r,g,b,a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end

function loadModel(model)
    Citizen.CreateThread(function()
        while not HasModelLoaded(model) do
            RequestModel(model)
          Citizen.Wait(1)
        end
    end)
end

function TextoMarker(x,y,z, text, Opacidade, s1, s2)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())    
    if onScreen then 
        SetTextScale(s1, s2)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, Opacidade)
        SetTextDropshadow(0, 0, 0, 0, Opacidade)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end