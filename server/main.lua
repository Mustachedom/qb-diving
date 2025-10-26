local Items = {
    {item = "dendrogyra_coral", min = 1, max = 5},
    {item = "antipatharia_coral", min = 2, max = 7},
}

local Blips = {
    vector3(-2838.8, -376.1, 3.55),
    vector3(-3288.2, -67.58, 2.79),
    vector3(-3367.24, 1617.89, 1.39),
    vector3(3002.5, -1538.28, -27.36),
    vector3(3421.58, 1975.68, 0.86),
    vector3(2720.14, -2136.28, 0.74),
    vector3(536.69, 7253.75, 1.69),
}

local Blip = Blips[math.random(1, #Blips)]
local corals = {
    {coords = vector3(-2849.25, -377.58, -40.23),    busy = false, PickedUp = false},
    {coords = vector3(-2838.43, -363.63, -39.45),    busy = false, PickedUp = false},
    {coords = vector3(-2887.04, -394.87, -40.91),    busy = false, PickedUp = false},
    {coords = vector3(-2808.99, -385.56, -39.32),    busy = false, PickedUp = false},
    {coords = vector3(-3275.03, -38.58, -19.21),     busy = false, PickedUp = false},
    {coords = vector3(-3273.73, -76.0, -26.81),      busy = false, PickedUp = false},
    {coords = vector3(-3346.53, -50.4, -35.84),      busy = false, PickedUp = false},
    {coords = vector3(-3388.01, 1635.88, -39.41),    busy = false, PickedUp = false},
    {coords = vector3(-3354.19, 1549.3, -38.21),     busy = false, PickedUp = false},
    {coords = vector3(-3320.72, 1620.12, -40.11),    busy = false, PickedUp = false},
    {coords = vector3(-3326.04, 1636.43, -40.98),    busy = false, PickedUp = false},
    {coords = vector3(2978.05, -1509.07, -24.96),    busy = false, PickedUp = false},
    {coords = vector3(3004.42, -1576.95, -29.36),    busy = false, PickedUp = false},
    {coords = vector3(2951.65, -1560.69, -28.36),    busy = false, PickedUp = false},
    {coords = vector3(3421.69, 1976.54, -50.64),     busy = false, PickedUp = false},
    {coords = vector3(3424.07, 1957.46, -53.04),     busy = false, PickedUp = false},
    {coords = vector3(3424.07, 1957.46, -53.04),     busy = false, PickedUp = false},
    {coords = vector3(3434.65, 1993.73, -49.84),     busy = false, PickedUp = false},
    {coords = vector3(3415.42, 1965.25, -52.04),     busy = false, PickedUp = false},
    {coords = vector3(2724.0, -2134.95, -19.33),     busy = false, PickedUp = false},
    {coords = vector3(2710.68, -2156.06, -18.63),    busy = false, PickedUp = false},
    {coords = vector3(2702.84, -2139.29, -18.51),    busy = false, PickedUp = false},
    {coords = vector3(542.31, 7245.37, -30.01),      busy = false, PickedUp = false},
    {coords = vector3(528.21, 7223.26, -29.51),      busy = false, PickedUp = false},
    {coords = vector3(510.36, 7254.97, -32.11),      busy = false, PickedUp = false},
    {coords = vector3(525.37, 7259.12, -30.51),      busy = false, PickedUp = false},
}
GlobalState.QBDiving = corals

local function busyState(num)
    corals[num].PickedUp = true
    GlobalState.QBDiving = corals
    CreateThread(function()
        Wait(Config.RespawnTime * 60000)
        corals[num].PickedUp = false
        GlobalState.QBDiving = corals
    end)
end

local prices = {
    dendrogyra_coral = math.random(70, 100),
    antipatharia_coral = math.random(50, 70),
}

local drops = {}
local function failDistance(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if drops[Player.PlayerData.citizenid] then
        drops[Player.PlayerData.citizenid] = drops[Player.PlayerData.citizenid] + 1
        print(Lang:t('failedDist.warn', {citizenid = Player.PlayerData.citizenid, current = drops[Player.PlayerData.citizenid]}))
        if drops[Player.PlayerData.citizenid] >= 3 then
            DropPlayer(src, Lang:t('failedDist.kicked'))
        end
    else
        print(Lang:t('failedDist.warn', {citizenid = Player.PlayerData.citizenid, current = 1}))
        drops[Player.PlayerData.citizenid] = 1
    end
end

local function checkDistance(src, loc, dist)
    local distance = #(GetEntityCoords(GetPlayerPed(src)) - vector3(loc.x, loc.y, loc.z))
    if distance <= dist then
        return true
    else
        failDistance(src)
        return false
    end
end

RegisterNetEvent('qb-diving:server:CallCops', function(coords)
    for _, Player in pairs(QBCore.Functions.GetQBPlayers()) do
        if Player then
            if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
                local msg = Lang:t('info.cop_msg')
                TriggerClientEvent('qb-diving:client:CallCops', Player.PlayerData.source, coords, msg)
                local alertData = {
                    title = Lang:t('info.cop_title'),
                    coords = coords,
                    description = msg
                }
                TriggerClientEvent('qb-phone:client:addPoliceAlert', -1, alertData)
            end
        end
    end
end)


RegisterNetEvent('qb-diving:server:TakeCoral', function(coral)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not checkDistance(src, corals[coral].coords, 8.0) then return end

    if corals[coral].PickedUp then
        return
    end

    if not corals[coral].busy then
        return
    end

    corals[coral].busy = false
    busyState(coral)

    local type = Items[math.random(1, #Items)]
    local itemName, amount = type.item, math.random(type.min, type.max)
    exports['qb-inventory']:AddItem(src, itemName, amount, false, false, 'qb-diving:server:TakeCoral')
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add', amount)
end)

RegisterNetEvent('qb-diving:server:sellCorals', function(location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not checkDistance(src, Config.SellLocations[location].coords, 5.0) then return end

    local totalCoral, price = 0, 0
    for k, v in pairs(prices) do
        local itemData = Player.Functions.GetItemByName(k)
        if itemData and itemData.name == 'dendrogyra_coral' then
            if exports['qb-inventory']:RemoveItem(src, 'dendrogyra_coral', itemData.amount, false, 'qb-diving:server:sellCorals') then
                price = price + (itemData.amount * prices['dendrogyra_coral'])
                totalCoral = totalCoral + itemData.amount
                TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['dendrogyra_coral'], 'remove', itemData.amount)
            end
        elseif itemData and itemData.name == 'antipatharia_coral' then
            if exports['qb-inventory']:RemoveItem(src, 'antipatharia_coral', itemData.amount, false, 'qb-diving:server:sellCorals') then
                price = price + (itemData.amount * prices['antipatharia_coral'])
                totalCoral = totalCoral + itemData.amount
                TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['antipatharia_coral'], 'remove', itemData.amount)
            end
        end
    end
    if price > 0 then
        Player.Functions.AddMoney('cash', price, 'sold-corals')
        QBCore.Functions.Notify(src, Lang:t('sold', {amount = totalCoral, price = price}), 'success')
    else
        QBCore.Functions.Notify(src, Lang:t('error.no_coral'), 'error')
    end
end)

RegisterNetEvent('qb-diving:server:busy', function(coral)
    local src = source
    if not checkDistance(src, corals[coral].coords, 5.0) then return end
    corals[coral].busy = true
    GlobalState.QBDiving = corals
end)

RegisterNetEvent('qb-diving:server:notBusy', function(coral)
    local src = source
    if not checkDistance(src, corals[coral].coords, 5.0) then return end
    corals[coral].busy = false
    GlobalState.QBDiving = corals
end)


RegisterNetEvent('qb-diving:server:removeItemAfterFill', function()
    local src = source
    exports['qb-inventory']:RemoveItem(src, 'diving_fill', 1, false, 'qb-diving:server:removeItemAfterFill')
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['diving_fill'], 'remove')
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-diving:server:GetDivingConfig', function(_, cb)
    cb(Blip)
end)

-- Items

QBCore.Functions.CreateUseableItem('diving_gear', function(source)
    TriggerClientEvent('qb-diving:client:UseGear', source)
end)

QBCore.Functions.CreateUseableItem('diving_fill', function(source)
    TriggerClientEvent('qb-diving:client:SetOxygenLevel', source)
end)