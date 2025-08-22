
local shopOpen = false
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


local function openShop(categories)
    if shopOpen then return end
    shopOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        categories = categories
    })
end


RegisterNetEvent('henny_ox_shop:open', function(shopCategories)
    if not LocalConfig then
        print("^1[henny_ox_shop] Error: Shop opened before config was loaded.")
        return
    end

    local categoriesData = {}
    local oxItems = exports.ox_inventory:Items()

    for _, categoryName in ipairs(shopCategories) do
        if LocalConfig.Categories[categoryName] then
            local categoryCopy = deepcopy(LocalConfig.Categories[categoryName])

            for _, item in ipairs(categoryCopy.items) do
                local oxItem = oxItems[item.name]
                if oxItem then
                    local filename = oxItem.image or (item.name .. '.png')
                    item.imageUrl = 'nui://ox_inventory/web/images/' .. filename
                else
                    item.imageUrl = 'https://placehold.co/80x80/2a2d34/f0f0f0?text=No+Img'
                    print("^1[henny_ox_shop] FAILED: Item '" .. item.name .. "' not found in ox_inventory.")
                end
            end
            categoriesData[categoryName] = categoryCopy
        end
    end

    openShop(categoriesData)
end)


local function InitializeShops()
    print("^2[henny_ox_shop] Config loaded. Initializing " .. #LocalConfig.Shops .. " shops.")
    for i, shop in ipairs(LocalConfig.Shops) do
        print("\n^5[henny_ox_shop] Initializing Shop #" .. i .. ":^7 " .. shop.name)

        -- Create blips
        if shop.blip then
            local mapBlip = AddBlipForCoord(shop.location.x, shop.location.y, shop.location.z)
            SetBlipSprite(mapBlip, shop.blip.sprite)
            SetBlipDisplay(mapBlip, shop.blip.display)
            SetBlipScale(mapBlip, shop.blip.scale)
            SetBlipColour(mapBlip, shop.blip.color)
            SetBlipAsShortRange(mapBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.name)
            EndTextCommandSetBlipName(mapBlip)
            print("  -> Blip created.")
        end


        exports.ox_target:addSphereZone({
            coords = vector3(shop.location.x, shop.location.y, shop.location.z),
            radius = 1.5,
            debug = false,
            options = {
                {
                    name = 'henny_ox_shop:shop_' .. i, 
                    icon = 'fas fa-shopping-cart',
                    label = 'Open ' .. shop.name,
                    onSelect = function()
                        TriggerEvent('henny_ox_shop:open', shop.categories)
                    end
                }
            }
        })
        print("  -> Target zone created.")


        if shop.ped then
            print("  -> Attempting to spawn ped: " .. shop.ped)
            local modelHash = GetHashKey(shop.ped)
            RequestModel(modelHash)


            local timeout = 5000 
            while not HasModelLoaded(modelHash) and timeout > 0 do
                Wait(100)
                timeout = timeout - 100
            end


            if HasModelLoaded(modelHash) then
                local ped = CreatePed(4, modelHash, shop.location.x, shop.location.y, shop.location.z - 1.0, shop.location.w, false, true)
                SetEntityAsMissionEntity(ped, true, true)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                BlockdecalsFromOwner(ped, true)
                if shop.scenario then
                    TaskStartScenarioInPlace(ped, shop.scenario, 0, true)
                end
                print("    --> ^2SUCCESS: Ped spawned successfully.^7")
            else

                print("    --> ^1ERROR: Failed to load ped model '" .. shop.ped .. "' within 5 seconds. Skipping ped spawn for this shop.^7")
            end
        end
        print("^2-> Finished processing shop:^7 " .. shop.name)
    end
    print("\n^2[henny_ox_shop] All shops initialized.^7")
end


CreateThread(function()
    while not LocalConfig do
        if _G.Config and _G.Config.Shops and #_G.Config.Shops > 0 then

            LocalConfig = deepcopy(_G.Config)
        end
        Wait(500)
    end

    print("^3[henny_ox_shop] Waiting for ox_target to load...")
    while exports.ox_target == nil do
        Wait(500)
    end
    print("^2[henny_ox_shop] ox_target loaded.")

    InitializeShops()
end)


RegisterNUICallback('close', function(_, cb)
    shopOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('purchase', function(data, cb)
    TriggerServerEvent('henny_ox_shop:server:purchase', data.cart, data.paymentMethod)
    cb('ok')
end)