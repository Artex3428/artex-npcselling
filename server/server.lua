local function getItemPrice(itemName)
    for i, item in ipairs(Config.Items) do
        if item.name == itemName then
            return item.price
        end
    end
    return 100
end

ESX.RegisterServerCallback('artex-pedInteraction:sellItem', function(source, cb, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(itemName)

    if item.count > 0 then
        local price = getItemPrice(itemName)

        xPlayer.removeInventoryItem(itemName, 1)
        xPlayer.addMoney(price)

        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('artex-pedInteraction:Robbed', function(source, cb, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(itemName)

    if item.count > 0 then
        xPlayer.removeInventoryItem(itemName, 1)
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('artex-pedInteraction:GiveItem', function(source, cb, itemName)
    local success = exports.ox_inventory:AddItem(source, itemName, 1)

    cb(success)
end)
