local vcf_files = {
	"FBI3.xml",
}

vehicleInfoTable = {}

local function processXml(el)
    local v = {}
    local text

    for _,kid in ipairs(el.kids) do
        if kid.type == 'text' then
            text = kid.value
        elseif kid.type == 'element' then
            if not v[kid.name] then
                v[kid.name] = {}
            end

            table.insert(v[kid.name], processXml(kid))
        end
    end

    v._ = el.attr

    if #el.attr == 0 and #el.el == 0 then
        v = text
    end

    return v
end

function parseVehData(xml, fileName)

    local a = {}
    fileName = string.sub(fileName, 1, -5)

    a = {}
    a.extras = {}

    for i=1,#xml.root.el do
    	if(xml.root.el[i].name == "EOVERRIDE") then
    		a.advisor = false
    		for ex=1,#xml.root.el[i].kids do
    			if(string.upper(string.sub(xml.root.el[i].kids[ex].name, 1, -3)) == "EXTRA") then
    				local elem = xml.root.el[i].kids[ex]
	    			local extra = tonumber(string.sub(elem.name, -2))
	    			a.extras[extra] = {}
	    			if elem.attr['IsElsControlled'] == "true" then
	    				a.extras[extra].enabled = true
	    			else
	    				a.extras[extra].enabled = false
	    			end

	    			if not a.advisor then
	    				if(elem.attr['TrafficAdvisor'] ~= nil) then
	    					print("Vehicle has Traffic Advisor")
	    					a.advisor = elem.attr['TrafficAdvisor']
	    				end
	    			end

	    			if(elem.attr['AllowEnvLight']) then
	    				a.extras[extra].env_light = true
	    				a.extras[extra].env_pos = {}
	    				a.extras[extra].env_pos['x'] = tonumber(elem.attr['OffsetX'])
	    				a.extras[extra].env_pos['y'] = tonumber(elem.attr['OffsetY'])
	    				a.extras[extra].env_pos['z'] = tonumber(elem.attr['OffsetZ'])
	    				a.extras[extra].env_color = {}

	    				if string.upper(elem.attr['Color']) == "RED" then
		                    a.extras[extra].env_color['r'] = 255
		                    a.extras[extra].env_color['g'] = 0
		                    a.extras[extra].env_color['b'] = 0
		                elseif string.upper(elem.attr['Color']) == "BLUE" then
		                    a.extras[extra].env_color['r'] = 0
		                    a.extras[extra].env_color['g'] = 0
		                    a.extras[extra].env_color['b'] = 255
		                elseif string.upper(elem.attr['Color']) == "AMBER" then
		                    a.extras[extra].env_color['r'] = 255
		                    a.extras[extra].env_color['g'] = 194
		                    a.extras[extra].env_color['b'] = 0
		                elseif string.upper(elem.attr['Color']) == "WHITE" then
		                    a.extras[extra].env_color['r'] = 255
		                    a.extras[extra].env_color['g'] = 255
		                    a.extras[extra].env_color['b'] = 255
		                end
	    			end
    			end

    		end
    	end
    end

    vehicleInfoTable[fileName] = a

    print("Done with vehicle: " .. fileName)
end

function parseObjSet(data, fileName)
    local xml = SLAXML:dom(data)

    if xml and xml.root then
        if xml.root.name == "vcfroot" then
            parseVehData(xml, fileName)
        end

    end
end

AddEventHandler('onResourceStart', function(name)
    for i=1,#vcf_files do
    	local data = LoadResourceFile(GetCurrentResourceName(), "vcf/" .. vcf_files[i])

	    if data then
	        parseObjSet(data, vcf_files[i])
	    end
    end
end)

RegisterServerEvent("els:requestVehiclesUpdate")
AddEventHandler('els:requestVehiclesUpdate', function()
	print("Sending player (" .. source .. ") vehicle data")
	TriggerClientEvent("els:updateElsVehicles", source, vehicleInfoTable)
end)

RegisterServerEvent("els:changeLightStage_s")
AddEventHandler("els:changeLightStage_s", function(state, advisor, prim, sec)
	TriggerClientEvent("els:changeLightStage_c", -1, source, state, advisor, prim, sec)
end)

RegisterServerEvent("els:changeAdvisorPattern_s")
AddEventHandler("els:changeAdvisorPattern_s", function(pat)
	TriggerClientEvent("els:changeAdvisorPattern_c", -1, source, pat)
end)

RegisterServerEvent("els:changeSecondaryPattern_s")
AddEventHandler("els:changeSecondaryPattern_s", function(pat)
	TriggerClientEvent("els:changeSecondaryPattern_c", -1, source, pat)
end)

RegisterServerEvent("els:changePrimaryPattern_s")
AddEventHandler("els:changePrimaryPattern_s", function(pat)
	TriggerClientEvent("els:changePrimaryPattern_c", -1, source, pat)
end)

RegisterServerEvent("els:toggleDfltSirenMute_s")
AddEventHandler("els:toggleDfltSirenMute_s", function(toggle)
	TriggerClientEvent("els:toggleDfltSirenMute_s", -1, source, toggle)
end)

RegisterServerEvent("els:setSirenState_s")
AddEventHandler("els:setSirenState_s", function(newstate)
	TriggerClientEvent("els:setSirenState_c", -1, source, newstate)
end)

RegisterServerEvent("els:setDualSirenState_s")
AddEventHandler("els:setDualSirenState_s", function(newstate)
	TriggerClientEvent("els:setDualSirenState_c", -1, source, newstate)
end)

RegisterServerEvent("els:setDualSiren_s")
AddEventHandler("els:setDualSiren_s", function(newstate)
	TriggerClientEvent("els:setDualSiren_c", -1, source, newstate)
end)

RegisterServerEvent("els:setHornState_s")
AddEventHandler("els:setHornState_s", function(state)
	TriggerClientEvent("els:setHornState_c", -1, source, state)
end)

RegisterServerEvent("els:setTakedownState_s")
AddEventHandler("els:setTakedownState_s", function(state)
	TriggerClientEvent("els:setTakedownState_c", -1, source, state)
end)