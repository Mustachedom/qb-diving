local isWearingSuit = false
local OxygenLevel = 0
local CurrentGear = {
    mask = 0,
    tank = 0,
    oxygen = 0,
    enabled = false
}
local p = nil
local function progressbar(text, time, anim)
    p = promise:new()
    QBCore.Functions.Progressbar("diving_action", text, time, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, anim or {}, {}, {}, function()
        p:resolve(true)
        p = nil
    end, function()
        p:resolve(false)
        p = nil
    end)
    return Citizen.Await(p)
end
-- Functions
local function callCops()
    local call = math.random(1, 100)
    if  call < Config.PoliceCall then
        TriggerServerEvent('qb-diving:server:CallCops', GetEntityCoords(PlayerPedId()))
    end
end

local function deleteGear()
	if CurrentGear.mask ~= 0 then
        DetachEntity(CurrentGear.mask, false, true)
        DeleteEntity(CurrentGear.mask)
		CurrentGear.mask = 0
    end
	if CurrentGear.tank ~= 0 then
        DetachEntity(CurrentGear.tank, false, true)
        DeleteEntity(CurrentGear.tank)
		CurrentGear.tank = 0
	end
end

local function gearAnim()
    RequestAnimDict("clothingshirt")
    while not HasAnimDictLoaded("clothingshirt") do
        Wait(0)
    end
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end


local currentBlip = {}

local function addBlip(divingLocation)
    if currentBlip.radius then
        RemoveBlip(currentBlip.radius)
        currentBlip.radius = nil
    end
    if currentBlip.label then
        RemoveBlip(currentBlip.label)
        currentBlip.label = nil
    end
    currentBlip.radius = AddBlipForRadius(divingLocation, 100.0)
    SetBlipRotation(currentBlip.radius, 0)
    SetBlipColour(currentBlip.radius, 47)
    currentBlip.label = AddBlipForCoord(divingLocation)
    SetBlipSprite(currentBlip.label, 597)
    SetBlipDisplay(currentBlip.label, 4)
    SetBlipScale(currentBlip.label, 0.7)
    SetBlipColour(currentBlip.label, 0)
    SetBlipAsShortRange(currentBlip.label, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Lang:t("info.diving_area"))
    EndTextCommandSetBlipName(currentBlip.label)
end

local peds = {}
local function init()
    QBCore.Functions.TriggerCallback('qb-diving:server:GetDivingConfig', function(Blip)
        addBlip(Blip)
    end)
    for k, v in pairs (GlobalState.QBDiving) do
        local options = {
            {
                icon = "fas fa-fish",
                label = Lang:t("info.collect_coral"),
                action = function()
                    callCops()
                    if not GlobalState.QBDiving[k].PickedUp or not GlobalState.QBDiving[k].busy then
                        TriggerServerEvent('qb-diving:server:busy', k)
                        if not progressbar(Lang:t("info.collecting_coral"), 5000, {animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", anim = "plant_floor",flags = 16}) then
                            TriggerServerEvent('qb-diving:server:notBusy', k)
                            return
                        end
                        TriggerServerEvent('qb-diving:server:pickUpCoral', k)
                    end
                end,
                canInteract = function()
                    if GlobalState.QBDiving[k].PickedUp or GlobalState.QBDiving[k].busy then
                        return false
                    end
                    return true
                end
            }
        }
        if Config.UseTarget then
            exports['qb-target']:AddBoxZone("DivingCoral"..k, vector3(v.coords.x, v.coords.y, v.coords.z), Config.ZoneSizes.coralLength, Config.ZoneSizes.coralWidth, {
                name = "DivingCoral"..k,
                heading = 0,
                debugPoly = false,
                minZ = v.coords.z - 2,
                maxZ = v.coords.z + 2,
            }, {
                options = options,
                distance = 3.0
            })
        else
            exports['qb-interact']:addInteractZone({
                name = "DivingCoral"..k,
                coords = vector3(v.coords.x, v.coords.y, v.coords.z),
                length = Config.ZoneSizes.coralLength,
                width = Config.ZoneSizes.coralWidth,
                height = 4.0,
                options = options,
                debugPoly = false,
            })
        end
    end
    for k, v in pairs (Config.SellLocations) do
        local options = {
            {
                icon = "fas fa-donate",
                label = Lang:t("info.sell_coral"),
                action = function()
                    TriggerServerEvent('qb-diving:server:sellCorals', k)
                end,
            }
        }
        RequestModel(GetHashKey(v.model))
        while not HasModelLoaded(GetHashKey(v.model)) do
            Wait(1)
        end
        peds[#peds+1] = CreatePed(4, v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w, false, true)
        SetEntityInvincible(peds[#peds], true)
        FreezeEntityPosition(peds[#peds], true)
        SetBlockingOfNonTemporaryEvents(peds[#peds], true)
        if Config.UseTarget then
            exports['qb-target']:AddTargetEntity(peds[#peds], {
                options = options,
                distance = 3.0
            })
        else
            exports['qb-interact']:addEntityZone(peds[#peds], {
                options = options,
            })
        end
    end
end

init()

RegisterNetEvent('qb-diving:client:CallCops', function(coords, msg)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    TriggerEvent("chatMessage", Lang:t("error.911_chatmessage"), "error", msg)
    local transG = 100
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
    SetBlipSprite(blip, 9)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, transG)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Lang:t("info.blip_text"))
    EndTextCommandSetBlipName(blip)
    while transG ~= 0 do
        Wait(180 * 4)
        transG = transG - 1
        SetBlipAlpha(blip, transG)
        if transG == 0 then
            SetBlipSprite(blip, 2)
            RemoveBlip(blip)
            return
        end
    end
end)

RegisterNetEvent("qb-diving:client:SetOxygenLevel", function()
    if OxygenLevel == 0 then
       OxygenLevel = Config.OxygenLevel -- oxygenlevel
       QBCore.Functions.Notify(Lang:t("success.tube_filled"), 'success')
       TriggerServerEvent('qb-diving:server:removeItemAfterFill')
    else
        QBCore.Functions.Notify(Lang:t("error.oxygenlevel", {oxygenlevel = OxygenLevel}), 'error')
    end
end)

RegisterNetEvent('qb-diving:client:UseGear', function()
    local ped = PlayerPedId()
    if isWearingSuit == false then
        if OxygenLevel > 0 then
            isWearingSuit = true
            if not IsPedSwimming(ped) and not IsPedInAnyVehicle(ped, false) then
                gearAnim()
                QBCore.Functions.Progressbar("equip_gear", Lang:t("info.put_suit"), 5000, false, true, {}, {}, {}, {},
                    function() -- Done
                        deleteGear()
                        local maskModel = `p_d_scuba_mask_s`
                        local tankModel = `p_s_scuba_tank_s`
                        RequestModel(tankModel)
                        while not HasModelLoaded(tankModel) do
                            Wait(0)
                        end
                        CurrentGear.tank = CreateObject(tankModel, 1.0, 1.0, 1.0, 1, 1, 0)
                        local bone1 = GetPedBoneIndex(ped, 24818)
                        AttachEntityToEntity(CurrentGear.tank, ped, bone1, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)

                        RequestModel(maskModel)
                        while not HasModelLoaded(maskModel) do
                            Wait(0)
                        end
                        CurrentGear.mask = CreateObject(maskModel, 1.0, 1.0, 1.0, 1, 1, 0)
                        local bone2 = GetPedBoneIndex(ped, 12844)
                        AttachEntityToEntity(CurrentGear.mask, ped, bone2, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)
                        SetEnableScuba(ped, true)
                        SetPedMaxTimeUnderwater(ped, 2000.00)
                        CurrentGear.enabled = true
                        ClearPedTasks(ped)
                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                        OxygenLevel = OxygenLevel
                        CreateThread(function()
                            while CurrentGear.enabled do
                                if IsPedSwimmingUnderWater(PlayerPedId()) then
                                    OxygenLevel = OxygenLevel - 1

                                    if OxygenLevel % 10 == 0 and OxygenLevel <= 90 and OxygenLevel > 0 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif OxygenLevel == 0 then
                                        if Config.RemoveDivingGear then deleteGear() end
                                        SetEnableScuba(ped, false)
                                        SetPedMaxTimeUnderwater(ped, 1.00)
                                        CurrentGear.enabled = false
                                        isWearingSuit = false
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", nil, 0.25)
                                        return
                                    end
                                end
                                Wait(1000)
                                exports['qb-core']:DrawText(OxygenLevel..'⏱', 'left')
                            end
                        end)
                    end)
            else
                QBCore.Functions.Notify(Lang:t("error.not_standing_up"), 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t("error.need_otube"), 'error')
        end
    elseif isWearingSuit == true then
        gearAnim()
        QBCore.Functions.Progressbar("remove_gear", Lang:t("info.pullout_suit"), 5000, false, true, {}, {}, {}, {}, function() -- Done
            SetEnableScuba(ped, false)
            SetPedMaxTimeUnderwater(ped, 50.00)
            CurrentGear.enabled = false
            ClearPedTasks(ped)
            deleteGear()
            QBCore.Functions.Notify(Lang:t("success.took_out"))
            TriggerServerEvent("InteractSound_SV:PlayOnSource", nil, 0.25)
            isWearingSuit = false
            OxygenLevel = OxygenLevel
            exports['qb-core']:HideText()
        end)
    end
end)
