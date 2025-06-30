PedsSoldTo = {}

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function DoHandshakeWithPed(ped)
    local playerPed = PlayerPedId()

    TaskTurnPedToFaceEntity(playerPed, ped, 1000)
    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
    Wait(500)

    LoadAnimDict('mp_ped_interaction')

    TaskPlayAnim(playerPed, 'mp_ped_interaction', 'handshake_guy_a', 8.0, -8.0, 2000, 0, 0, false, false, false)
    TaskPlayAnim(ped, 'mp_ped_interaction', 'handshake_guy_b', 8.0, -8.0, 2000, 0, 0, false, false, false)
end

function GetItemConfig(itemName)
    for i, item in ipairs(Config.Items) do
        if item.name == itemName then
            print("Works 1")
            return item.legal
        end
    end
    return nil
end

for i, item in ipairs(Config.Items) do
    exports.ox_target:addGlobalPed({
        {
            name = item.name.."SellOption",
            icon = "fas fa-money",
            label = "Sell "..item.name,
            distance = 2.5,
            items = item.name,
            onSelect = function(data)
                TriggerEvent("artex-npcInteraction:sell"..item.name, data.entity)
            end,
            canInteract = function(entity)
                return not IsPedDeadOrDying(entity, true)
            end,
        },
    })

    AddEventHandler("artex-npcInteraction:sell"..item.name, function(ped)
        TrySellItem(item.name, ped)
    end)
end

AddEventHandler("artex-npcInteraction:takeBackItemOption", function(itemName, netId)
    ESX.TriggerServerCallback('artex-pedInteraction:GiveItem', function(success)
        if success then
            exports.ox_target:removeEntity(netId, "takeBackItemOption")
        end
    end, itemName)
end)

function TrySellItem(itemName, ped)
    local playerPed = PlayerPedId()
    local targetDistance = 0.7
    local pedCoords = GetEntityCoords(ped)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(pedCoords - playerCoords)

    ClearPedTasks(ped)

    if distance > targetDistance then
        TaskGoToEntity(ped, playerPed, -1, targetDistance, 2.0, 1073741824, 0)
        while #(GetEntityCoords(ped) - GetEntityCoords(playerPed)) > targetDistance do
            Wait(100)
        end
        ClearPedTasks(ped)
    end

    TaskTurnPedToFaceEntity(playerPed, ped, 1000)
    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
    Wait(500)
    TaskStandStill(ped, 30000)

    if Config.UseClientNpcSpeech then
        PlayAmbientSpeech1(ped, "GENERIC_HI", "SPEECH_PARAMS_FORCE_NORMAL")
    end

    local roll = math.random(1, 100)

    local netId = NetworkGetNetworkIdFromEntity(ped)

    for k, v in ipairs(PedsSoldTo) do
        if v == netId then
            lib.notify({
                title = 'Interaction',
                description = 'You have already sold to me!',
                showDuration = true,
                position = 'top-right',
            })
            ClearPedTasks(ped)
            TaskWanderStandard(ped, 10.0, 10)
            if Config.UseClientNpcSpeech then
                PlayAmbientSpeech1(ped, "GENERIC_NO", "SPEECH_PARAMS_FORCE_NORMAL")
            end
            return
        end
    end

    local success = lib.skillCheck({'easy', {areaSize = 80, speedMultiplier = 1.01}, 'hard'}, {'w'})

    if success then
        local itemConfig = GetItemConfig(itemName)
        print(itemConfig)
        if roll <= Config.CallPoliceChance and itemConfig then
            print("Test")
            ClearPedTasks(ped)
            TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1)
            table.insert(PedsSoldTo, netId)
            TriggerServerEvent('Opto_dispatch:Server:SendAlert', "police", "Selling illegal stuff", "Someone tried to sell something illegal here.", GetEntityCoords(PlayerPedId()), false, 1)
            RequestAnimDict('cellphone@')
            while not HasAnimDictLoaded('cellphone@') do
                Wait(10)
            end
            TaskPlayAnim(ped, 'cellphone@', 'cellphone_call_listen_base', 8.0, -8.0, -1, 49, 0, false, false, false)
            if Config.UseClientNpcSpeech then
                PlayAmbientSpeech1(ped, "GENERIC_CALL_POLICE", "SPEECH_PARAMS_FORCE_NORMAL")
            end
        elseif roll <= Config.RobbedChance then
            ESX.TriggerServerCallback('artex-pedInteraction:Robbed', function(robbed)
                if robbed then
                    ClearPedTasks(ped)
                    TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1)
                    table.insert(PedsSoldTo, netId)
                    lib.notify({
                        title = 'Interaction',
                        description = 'You just got robbed idiot!',
                        showDuration = true,
                        position = 'top-right',
                    })
                    exports.ox_target:addEntity(netId, {
                        name = "takeBackItemOption",
                        icon = "fas fa-money",
                        label = "Take back your stuff",
                        distance = 2.5,
                        onSelect = function()
                            TriggerEvent("artex-npcInteraction:takeBackItemOption", itemName, netId)
                        end,
                    })
                    if Config.UseClientNpcSpeech then
                        PlayAmbientSpeech1(ped, "GENERIC_INSULT", "SPEECH_PARAMS_FORCE_NORMAL")
                    end
                else
                    lib.notify({
                        title = 'Interaction',
                        description = 'Bye!',
                        showDuration = true,
                        position = 'top-right',
                    })
                    table.insert(PedsSoldTo, netId)
                    ClearPedTasks(ped)
                    TaskWanderStandard(ped, 10.0, 10)
                    if Config.UseClientNpcSpeech then
                        PlayAmbientSpeech1(ped, "GENERIC_BYE", "SPEECH_PARAMS_FORCE_NORMAL")
                    end
                end
            end, itemName)
        else
            ESX.TriggerServerCallback('artex-pedInteraction:sellItem', function(sold)
                if sold then
                    DoHandshakeWithPed(ped)
                    DoHandshakeWithPed(PlayerPedId())
                    table.insert(PedsSoldTo, netId)
                    Wait(1000)
                    ClearPedTasks(ped)
                    TaskWanderStandard(ped, 10.0, 10)
                    if Config.UseClientNpcSpeech then
                        PlayAmbientSpeech1(ped, "GENERIC_THANKS", "SPEECH_PARAMS_FORCE_NORMAL")
                    end
                else
                    lib.notify({
                        title = 'Interaction',
                        description = 'You do not have anything to sell!',
                        showDuration = true,
                        position = 'top-right',
                    })
                    table.insert(PedsSoldTo, netId)
                    ClearPedTasks(ped)
                    TaskWanderStandard(ped, 10.0, 10)
                    if Config.UseClientNpcSpeech then
                        PlayAmbientSpeech1(ped, "GENERIC_SORRY", "SPEECH_PARAMS_FORCE_NORMAL")
                    end
                end
            end, itemName)
        end
    end
end
