local blipRadius
local jobCooldown = false
local targetSupplied = false

lib.locale()
local atmPoints = {}
local atmInteractions = 0
local hackedATMs = {}
local usedATMs = {}
local isHacking = false
local isInJob = false
local isFailed = false
local atmZone

function supplyTarget()
    exports.ox_target:addSphereZone({
        coords = Config.StartLocation,
        radius = 1,
        drawSprite = true,
        options = {
            {
                name = 'sphere',
                event = 'startJobEvent',
                icon = Config.StartIcon,
                label = locale('targetlabel'),
            }
        }
    })
end

RegisterNetEvent('startJobEvent')
AddEventHandler('startJobEvent', function()
    if jobCooldown then
        Notification("You cannot start a new job yet, please wait.", "error")
        return
    end
    
    if Config.UseItem then
        local hasitem = exports.ox_inventory:Search('count', Config.StartItem)
        if hasitem >= 1 then
            local success = StartJobHack()
            if success then
                isFailed = false
                isInJob = true
                giveATM()
                Notification(locale('starthackpassDesc'), "info") 
            else
                Notification(locale('starthackFailDesc'), "info") 
            end
        else
            Notification(locale('missingitem'), "info") 
        end
    else
        local success = StartJobHack()
        if success then
            giveATM()
            Notification(locale('starthackpassDesc'), "info") 
        else
            Notification(locale('starthackFailDesc'), "info") 
        end
    end
    
    jobCooldown = true
    Citizen.SetTimeout(math.random(180000, 300000), function()
        jobCooldown = false
    end)
end)

RegisterNetEvent('nexus_atmrobbery:syncATMCoords')
AddEventHandler('nexus_atmrobbery:syncATMCoords', function(coords)
    randomATM = coords
end)

function giveATM()
    if Config.ATMPoints then
        if atmInteractions >= 4 then
            isInJob = false
            Notification("You have finished the job.", "success")
            return
        end
        
        local availableATMs = {}
        for index, atm in ipairs(Config.ATMPoints) do
            if not usedATMs[index] then
                table.insert(availableATMs, atm)
            end
        end
        
        if #availableATMs == 0 then
            for k in pairs(usedATMs) do
                usedATMs[k] = nil
            end
        end
        
        local randomIndex = math.random(1, #availableATMs)
        local randomATM = availableATMs[randomIndex]
        local zoneID = "atm_" .. math.random(10000)
        local zoneString = zoneID
        
        blipRadius = AddBlipForRadius(randomATM.x, randomATM.y, randomATM.z, 100.0)
        if not blipRadius then 
            return 
        end
        SetBlipAlpha(blipRadius, 150)
        SetBlipHighDetail(blipRadius, true)
        SetBlipColour(blipRadius, 34)
        SetBlipAsShortRange(blipRadius, true)
        
        atmZone = exports.ox_target:addSphereZone({
            id = zoneString,
            coords = randomATM,
            radius = 1,
            drawSprite = true,
            options = {
                {
                    name = zoneString,
                    icon = Config.HackIcon,
                    label = locale('atmhack'),
                    canInteract = function()
                        return not hackedATMs[zoneString] and not isHacking and not isFailed
                    end,
                    onSelect = function()
                        isHacking = true
                     
                        local success = StartATMHack()
                        if success then
                            hackedATMs[zoneString] = true 
                            removeZone()
                            atmInteractions = atmInteractions + 1
                            if lib.progressBar({
                                duration = 20000,
                                label = 'Taking Money...',
                                useWhileDead = false,
                                canCancel = false,
                                anim = {
                                    dict = 'mp_prison_break',
                                    clip = 'hack_loop'
                                },
                                disable = {
                                    move = true,
                                    combat = true,
                                    sprint = true,
                                    car = true,
                                },
                            }) then 
                                TriggerServerEvent('nexus_atmrobbery:requestATMCoords', randomATM)
                           
                                if atmInteractions >= 4 then
                                    isInJob = false
                                    Notification("You have finished the job.", "success")
                                else
                                    Notification("Go to the next location.", "success")
                                    giveATM()
                                end
                            end
                        else
                            TriggerServerEvent("hg_audio:playOnRange", 'abyssAlarm', 0.2, randomATM, 10)
                            if lib.progressBar({
                                duration = 20000,
                                label = 'Processing...',
                                useWhileDead = false,
                                canCancel = false,
                                anim = {
                                    dict = 'mp_prison_break',
                                    clip = 'hack_loop'
                                },
                                disable = {
                                    move = true,
                                    combat = true,
                                    sprint = true,
                                    car = true,
                                },
                            }) then 
                    
                            isFailed = true
                            isInJob = false
                            removeZone()
                            Notification(locale('starthackFailDesc'), "info") 
                        end
                    end
                        isHacking = false
                    end
                }
            }
        })
        
        usedATMs[randomIndex] = true 
    end
end


function removeZone()
    RemoveBlip(blipRadius)
    exports.ox_target:removeZone(atmZone)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if not targetSupplied then
	supplyTarget()
    targetSupplied = true
    end
end)

-- AddEventHandler('onResourceStart', function(resourceName)
--     if (GetCurrentResourceName() ~= resourceName) then
--       return
--     end
--     supplyTarget()
--     print('Thank you for using ' .. resourceName .. ' it has successfully initialized!')
-- end)
