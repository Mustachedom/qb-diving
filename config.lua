Config = Config or {}
QBCore = exports['qb-core']:GetCoreObject()

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)
Config.PoliceCall = 50 -- The chance of the cops getting called when a coral gets picked up, this ranges from 0 - 100 (0 = never, 100 = always)
Config.OxygenLevel = 200 -- this is oxygen level you can change this number as you like
Config.RemoveDivingGear = false -- Whether or not to remove the diving gear when empty

Config.ZoneSizes = {
    coralLength = 4.0,
    coralWidth = 4.0,

}

Config.SellLocations = {
    {coords = vector4(-1684.13, -1068.91, 13.15, 100.0), model = 'a_m_m_salton_01'}
}