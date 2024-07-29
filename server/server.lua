RegisterNetEvent('nexus_atmrobbery:requestATMCoords')
AddEventHandler('nexus_atmrobbery:requestATMCoords', function(requestedCoords)
    local src = source
    local ped = GetPlayerPed(src)
    local position = GetEntityCoords(ped)
    TriggerClientEvent('nexus_atmrobbery:syncATMCoords', src, requestedCoords)
    if #(position - requestedCoords) >= 10 then return 
    else
        exports.ox_inventory:AddItem(src, Config.RewardItem, Config.RewardAmount)
    end
end)
