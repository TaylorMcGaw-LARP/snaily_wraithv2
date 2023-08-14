--[[
    Snaily CAD Plugins

    Plugin Name: wraithv2
    Creator: TaylorMcGaw-LARP
    Description: Implements plate auto-lookup for the wraithv2 plate reader by WolfKnight

    Put all server-side logic in this file.
]]

local pluginConfig = Config.GetPluginConfig("wraithv2")

if pluginConfig.enabled then

    function dump(o)
        if type(o) == 'table' then
           local s = '{ '
           for k,v in pairs(o) do
              if type(k) ~= 'number' then k = '"'..k..'"' end
              s = s .. '['..k..'] = ' .. dump(v) .. ','
           end
           return s .. '} '
        else
           return tostring(o)
        end
     end
    wraithLastPlates = { locked = nil, scanned = nil }

    exports('cadGetLastPlates', function() return wraithLastPlates end)

    RegisterNetEvent("wk:onPlateLocked")
    AddEventHandler("wk:onPlateLocked", function(cam, plate, index)
        debugLog(("plate lock: %s - %s - %s"):format(cam, plate, index))
        local source = source
        local ids = GetIdentifiers(source)
        plate = plate:match("^%s*(.-)%s*$")
        wraithLastPlates.locked = { cam = cam, plate = plate, index = index, vehicle = cam.vehicle }
        local platedata = {
            plateOrVin = plate
        }
      
        PerformHttpRequest(Config.apiURL .. "search/vehicle?includeMany=true", function(errorCode, result, resultHeaders)
            debugLog("Performed lookup")
            if cam == "front" then
                camCapitalized = "Front"
                camnum = 1
            elseif cam == "rear" then
                camCapitalized = "Rear"
              camnum = 2
            end
            
            local reg = false
            
                 reg = json.decode(result)[1]
                    
                
            
            if reg then
                TriggerEvent("snailyCAD::wraithv2:PlateLocked", source, reg, cam, plate, index)
                local plate = reg.plate
                local vin = reg.vinNumber
                local color = reg.color
                local registrationStatus = reg.registrationStatus.value
                local owner = ("%s %s"):format(reg.citizen.name, reg.citizen.name)
                local notify ={
                    id = 'platescan',
                    title = camCapitalized.." ALPR",
                    description = ("Plate: %s  \nStatus: %s  \nOwner: %s"):format(plate:upper(), registrationStatus, owner),
                    position = 'center-left',
                    duration = 30000,
                    type = 'inform'
                }
                TriggerClientEvent('ox_lib:notify', source, notify)
                
                
        PerformHttpRequest(Config.apiURL .. "bolos?query="..plate, function(errorCode, result, resultHeaders)
            if json.decode(result).totalCount == 1 then
               local bolos = json.decode(result).bolos[1]
        
               TriggerClientEvent('wk:togglePlateLock', -1, cam, true, true)
                   local notify ={
                    id = 'snanbolo',
                    title = "BOLO ALERT!",
                    description = ("Plate: %s  \nDescription: %s"):format(plate:upper(), bolos.description),
                    position = 'center-left',
                    duration = 30000,
                    type = 'warning'
                }
                TriggerClientEvent('ox_lib:notify', source, notify)
            end
            
        end, "GET",json.encode(platedata), {
            ["Content-Type"] = "application/json",
            ["snaily-cad-api-token"] = Config.apiKey
    
        })
     
            else
                local notify ={
                    id = 'scaninvalid',
                    title = camCapitalized.." ALPR",
                    description = ("Plate: %s  \nStatus: Not Registered"):format(plate:upper()),
                    position = 'center-left',
                    duration = 15000,
                    type = 'error'
                }
                TriggerClientEvent('ox_lib:notify', source, notify)
            end
        end, "POST",json.encode(platedata), {
            ["Content-Type"] = "application/json",
            ["snaily-cad-api-token"] = Config.apiKey
    
        })
     
    end)

    RegisterNetEvent("wk:onPlateScanned")
    AddEventHandler("wk:onPlateScanned", function(cam, plate, index)
        if cam == "front" then
            camCapitalized = "Front"
            camnum = 1
        elseif cam == "rear" then
            camCapitalized = "Rear"
            camnum = 2
        end
        
        debugLog(("plate scan: %s - %s - %s"):format(cam, plate, index))
        local source = source
        plate = plate:match("^%s*(.-)%s*$")
        wraithLastPlates.scanned = { cam = cam, plate = plate, index = index, vehicle = cam.vehicle }
        local platedata = {
            plateOrVin = plate
        }
      
        PerformHttpRequest(Config.apiURL .. "search/vehicle?includeMany=true", function(errorCode, result, resultHeaders)
            debugLog("Performed lookup")
            if cam == "front" then
                camCapitalized = "Front"
                camnum = 1
            elseif cam == "rear" then
                camCapitalized = "Rear"
              camnum = 2
            end
            
            local reg = false
            
                 reg = json.decode(result)[1]
                    
                
            
            if reg then
                TriggerEvent("snailyCAD::wraithv2:PlateLocked", source, reg, cam, plate, index)
                local plate = reg.plate
                local vin = reg.vinNumber
                local color = reg.color
                local registrationStatus = reg.registrationStatus.value
                local owner = ("%s %s"):format(reg.citizen.name, reg.citizen.name)
                local notify ={
                    id = 'platescan',
                    title = camCapitalized.." ALPR",
                    description = ("Plate: %s  \nStatus: %s  \nOwner: %s"):format(plate:upper(), registrationStatus, owner),
                    position = 'center-left',
                    duration = 30000,
                    type = 'inform'
                }
                TriggerClientEvent('ox_lib:notify', source, notify)
                
                
        PerformHttpRequest(Config.apiURL .. "bolos?query="..plate, function(errorCode, result, resultHeaders)
            if json.decode(result).totalCount == 1 then
               local bolos = json.decode(result).bolos[1]
             
               TriggerClientEvent('wk:togglePlateLock', -1, cam, true, true)
                   local notify ={
                    id = 'snanbolo',
                    title = "BOLO ALERT!",
                    description = ("Plate: %s  \nDescription: %s"):format(plate:upper(), bolos.description),
                    position = 'center-left',
                    duration = 30000,
                    type = 'warning'
                }
                TriggerClientEvent('ox_lib:notify', source, notify)
            end
            
        end, "GET",json.encode(platedata), {
            ["Content-Type"] = "application/json",
            ["snaily-cad-api-token"] = Config.apiKey
    
        })
     
            else
                local notify ={
                    id = 'scaninvalid',
                    title = camCapitalized.." ALPR",
                    description = ("Plate: %s  \nStatus: Not Registered"):format(plate:upper()),
                    position = 'center-left',
                    duration = 15000,
                    type = 'error'
                }
                TriggerClientEvent('ox_lib:notify', source, notify)
            end
        end, "POST",json.encode(platedata), {
            ["Content-Type"] = "application/json",
            ["snaily-cad-api-token"] = Config.apiKey
    
        })
     
    end)

end