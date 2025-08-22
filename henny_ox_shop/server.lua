local LocalConfig = nil 


local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end


CreateThread(function()
    while not Config or not Config.Categories do Wait(200) end
    LocalConfig = deepcopy(Config)
    print("^2[henny_ox_shop] [SERVER] Config loaded and secured.")
end)

local function getPlayer(source)
    if GetResourceState('es_extended') == 'started' then
        return exports.es_extended:getSharedObject().GetPlayerFromId(source)
    elseif GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
    end
    return nil
end

RegisterNetEvent('henny_ox_shop:server:getShopCategories', function(categories)
    TriggerClientEvent('henny_ox_shop:open', source, categories)
end)

RegisterNetEvent('henny_ox_shop:server:purchase', function(cart, paymentMethod)
    if not LocalConfig then
        print("^1[henny_ox_shop] [SERVER] ERROR: Purchase attempted before server config was loaded.")
        return
    end

    local src = source
    local player = getPlayer(src)
    local totalCost = 0
    local itemsToGive = {}


    for _, cartItem in ipairs(cart) do
        local foundItem = false
        for categoryName, categoryData in pairs(LocalConfig.Categories) do
            for _, shopItem in ipairs(categoryData.items) do
                if shopItem.name == cartItem.name then
                    totalCost = totalCost + (shopItem.price * cartItem.quantity)
                    table.insert(itemsToGive, {
                        name = cartItem.name,
                        quantity = cartItem.quantity
                    })
                    foundItem = true
                    break 
                end
            end
            if foundItem then
                break 
            end
        end
    end

    if totalCost == 0 then return end

    local canPay = false
    if paymentMethod == 'cash' then
        -- Standalone ox_inventory money item
        if exports.ox_inventory:GetItem(src, 'money') and exports.ox_inventory:GetItem(src, 'money').count >= totalCost then
            canPay = true
            exports.ox_inventory:RemoveItem(src, 'money', totalCost)
        -- ESX cash
        elseif player and player.getMoney and player.getMoney() >= totalCost then
            canPay = true
            player.removeMoney(totalCost)
        -- QB-Core cash
        elseif player and player.Functions and player.Functions.GetMoney('cash') >= totalCost then
            canPay = true
            player.Functions.RemoveMoney('cash', totalCost)
        end
    elseif paymentMethod == 'card' then
        -- ESX bank
        if player and player.getAccount and player.getAccount('bank').money >= totalCost then
            canPay = true
            player.removeAccountMoney('bank', totalCost)
        -- QB-Core bank
        elseif player and player.Functions and player.Functions.GetMoney('bank') >= totalCost then
            canPay = true
            player.Functions.RemoveMoney('bank', totalCost)
        end
    end

    if canPay then
        for _, item in ipairs(itemsToGive) do
            exports.ox_inventory:AddItem(src, item.name, item.quantity)
        end
        TriggerClientEvent('ox_lib:notify', src, {title = 'Purchase Successful', description = 'You have received your items.', type = 'success'})
    else

        TriggerClientEvent('ox_lib:notify', src, {title = 'Payment Failed', description = 'You do not have enough money.', type = 'error'})
    end
end)
