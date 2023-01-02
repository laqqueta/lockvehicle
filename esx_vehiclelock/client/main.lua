ESX = nil

local isRunningWorkaround = false


function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -1, duration, 48, 1, false, false, false)
	RemoveAnimDict(animDict)
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)




function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true

	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	isRunningWorkaround = false
end

function ToggleVehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	

	Citizen.CreateThread(function()
		StartWorkaroundTask()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	ESX.TriggerServerCallback('esx_vehiclelock:requestPlayerCars', function(isOwnedVehicle)
	
	

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then -- unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				SetVehicleDoorShut(vehicle, 0)
				SetVehicleDoorShut(vehicle, 1)
				exports['mythic_notify']:DoHudText('Inform', 'Locked')
				SetVehicleLights(vehicle, 2)
				Wait (200)
				SetVehicleLights(vehicle, 0)
				Wait (200)
				SetVehicleLights(vehicle, 2)
				Wait (400)
				SetVehicleLights(vehicle, 0)
				TriggerServerEvent("Carlock:sound", GetEntityCoords(vehicle), "unlock-outside", 0.5)
				

			elseif lockStatus == 2 then -- locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				exports['mythic_notify']:DoHudText('Inform', 'Unlocked')
				SetVehicleLights(vehicle, 2)
				Wait (200)
				SetVehicleLights(vehicle, 0)
				Wait (200)
				SetVehicleLights(vehicle, 2)
				Wait (400)
				SetVehicleLights(vehicle, 0)
				TriggerServerEvent("Carlock:sound", GetEntityCoords(vehicle), "lock-outside", 0.5)
				
				
				
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end





Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 303) and IsInputDisabled(0) then
			exports['progressBars'] :startUI(800, "Locked/Unlocked")
			playAnim('anim@mp_player_intmenu@key_fob@', 'fob_click', 800)
			Citizen.Wait(800)
			ToggleVehicleLock()
			Citizen.Wait(300)
	
		-- D-pad down on controllers works, too!
		elseif IsControlJustReleased(0, 173) and not IsInputDisabled(0) then
			ToggleVehicleLock()
			Citizen.Wait(300)
		end
	end
end)
