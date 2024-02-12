ESX	= nil
local SecRemaining = 0
local RankStart = false
local MenuEnable = false
local isDead = false
local isPicking = false
-- local Kill = {}
local flagData = {}
local Blips = {}
local BlipR = {}
local Blipt = {}
local FlagMain = {}
local airdrops = {}
local TeamData = {
	['white'] = {
		teamName = nil,
		teamLabel = nil,
		score = 0,
		coords = nil,
		times = 0,
		cooldown= false
	},
	['black'] = {
		teamName = nil,
		teamLabel = nil,
		score = 0,
		coords = nil,
		times = 0,
		cooldown= false
	}
}
local Myteam = nil
local requiredModels = "mmairdrop"
local requiredFlag = "mmdekpredflag"
local ClearCarAirdrop = 16
local ClearCarFlag = 16
local ClearCarBase = 16

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	TriggerServerEvent('miami_rank:GetRankState')
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
	ESX.PlayerData.job = job
	if RankStart then
		RankStart = false
		ResetClient()
	end
	Citizen.Wait(2000)
	TriggerServerEvent('miami_rank:GetRankState')
end)

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang)
	ESX.PlayerData.gang = gang
	if RankStart then
		RankStart = false
		ResetClient()
	end
	Citizen.Wait(2000)
	TriggerServerEvent('miami_rank:GetRankState')
end)

function ResetClient()
	TriggerEvent('miami_logs:rankstatus', false)
	SecRemaining = 0
	if MenuEnable then
		SendNUIMessage({
			hidemenu = true
		})
		MenuEnable = false
	end
	for k, v in pairs(Blips) do
		RemoveBlip(v) 
		Blips[k] = nil
	end
	for k, v in pairs(Blipt) do
		RemoveBlip(v) 
		Blipt[k] = nil
	end
	for k, v in pairs(BlipR) do
		RemoveBlip(v) 
		BlipR[k] = nil
	end
	Myteam = nil
	flagData = {}
	TeamData = {
		['white'] = {
			teamName = nil,
			teamLabel = nil,
			score = 0,
			coords = nil,
			times = 0,
			cooldown= false
		},
		['black'] = {
			teamName = nil,
			teamLabel = nil,
			score = 0,
			coords = nil,
			times = 0,
			cooldown= false
		}
	}
	for k,v in pairs(airdrops) do
		DeleteEntity(v.crate)
		airdrops[k] = nil
	end
	for k,v in pairs(FlagMain) do
		DeleteEntity(v)
		FlagMain[k] = nil
	end
	SetModelAsNoLongerNeeded(GetHashKey(requiredModels))
	SetModelAsNoLongerNeeded(GetHashKey(requiredFlag))
end

RegisterNetEvent('miami_rank:StartRank')
AddEventHandler('miami_rank:StartRank', function(_Remaining, _TeamData, _flagData, _MVP)
	TeamData = _TeamData
	flagData = _flagData
	SecRemaining = _Remaining
	if ESX.PlayerData.gang.name == TeamData['white'].teamName then
		Myteam = 'white'
	elseif ESX.PlayerData.gang.name == TeamData['black'].teamName then
		Myteam = 'black'
	end
	SendNUIMessage({
		uppoint = true,
		wpoint = TeamData['white'].score,
		bpoint = TeamData['black'].score,
	})
	Citizen.Wait(500)
	RankStart = true
	StartRank()
	SendNUIMessage({
		showmenu = true,
		team1 = TeamData['white'].teamName,
		team1l = TeamData['white'].teamLabel,
		team2 = TeamData['black'].teamName,
		team2l = TeamData['black'].teamLabel,
		sec = disp_time(SecRemaining),
		upflag = true,
		flaga = flagData['A'].holderTeam,
		flagb = flagData['B'].holderTeam,
		mvp = true,
		m1 = _MVP.MVP,
		m2 = _MVP.MVP2,
		m3 = _MVP.MVP3,
		pk1 = _MVP.MVPkill,
		pk2 = _MVP.MVPkill2,
		pk3 = _MVP.MVPkill3,
		pd1 = _MVP.MVPdead,
		pd2 = _MVP.MVPdead2,
		pd3 = _MVP.MVPdead3,
		t1 = _MVP.T1,
		t2 = _MVP.T2,
		t3 = _MVP.T3,
	})
	MenuEnable = true
	TriggerEvent('miami_logs:rankstatus', RankStart)
end)

RegisterNetEvent('miami_rank:StopRank')
AddEventHandler('miami_rank:StopRank', function(data)
	SecRemaining = 0
	SendNUIMessage({
		uptime = true,
		sec = "Time out"
	})
	RankStart = false
	TeamData['white'].score = data.w
	TeamData['black'].score = data.b
	SendNUIMessage({
		uppoint = true,
		wpoint = TeamData['white'].score,
		bpoint = TeamData['black'].score,
	})
	Citizen.Wait(15000)
	if MenuEnable then
		SendNUIMessage({
			hidemenu = true
		})
		MenuEnable = false
	end
	for k, v in pairs(Blips) do
		RemoveBlip(v) 
		Blips[k] = nil
	end
	for k, v in pairs(Blipt) do
		RemoveBlip(v) 
		Blipt[k] = nil
	end
	for k, v in pairs(BlipR) do
		RemoveBlip(v) 
		BlipR[k] = nil
	end
	Myteam = nil
	TeamData = {
		['white'] = {
			teamName = nil,
			teamLabel = nil,
			score = 0,
			coords = nil,
			times = 0,
			cooldown= false
		},
		['black'] = {
			teamName = nil,
			teamLabel = nil,
			score = 0,
			coords = nil,
			times = 0,
			cooldown= false
		}
	}
	flagData = {}
	TriggerEvent('miami_logs:rankstatus', RankStart)
	for k,v in pairs(airdrops) do
		DeleteEntity(v.crate)
		airdrops[k] = nil
	end
	for k,v in pairs(FlagMain) do
		DeleteEntity(v)
		FlagMain[k] = nil
	end
	SetModelAsNoLongerNeeded(GetHashKey(requiredModels))
	SetModelAsNoLongerNeeded(GetHashKey(requiredFlag))
end)

RegisterNetEvent('miami_rank:Updatetime')
AddEventHandler('miami_rank:Updatetime', function(data)
	if RankStart then
		SecRemaining = data.t
		TeamData['white'].score = data.w
		TeamData['black'].score = data.b
		SendNUIMessage({
			uppoint = true,
			wpoint = TeamData['white'].score,
			bpoint = TeamData['black'].score,
		})
	end
end)

RegisterNetEvent('miami_rank:UpdateFlag')
AddEventHandler('miami_rank:UpdateFlag', function(data)
	if RankStart then
		local feed = data.p..' seized the <span style="color:red;"> flag '..data.z..'</span>'
		flagData[data.z].holderTeam = data.t
		flagData[data.z].holderTeamL = data.f
		flagData[data.z].colorCode = Config.ColorCode[data.t]
		flagData[data.z].holded = true
		flagData[data.z].canseize = true
		TeamData['white'].score = data.w
		TeamData['black'].score = data.b
		SendNUIMessage({
			upflag = true,
			flaga = flagData['A'].holderTeam,
			flagb = flagData['B'].holderTeam,
			flagfeed = feed,
			uppoint = true,
			wpoint = TeamData['white'].score,
			bpoint = TeamData['black'].score
		})
		TriggerEvent('InteractSound_CL:PlayOnOne','flagrank',0.5)
	end
end)

function StartRank()
	for zone, data in pairs(Config.FlagZone) do 
        local blip = AddBlipForCoord(data.coords)

        SetBlipSprite(blip, 468)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Flag Zone ".. zone)
        EndTextCommandSetBlipName(blip) 
		local BlipRadius = AddBlipForRadius(data.coords,100.0)
		SetBlipColour(BlipRadius,38)
		SetBlipAlpha(BlipRadius,60)
		Blips[zone] = blip
		BlipR[zone] = BlipRadius
		
		Citizen.CreateThread(function()
			RequestModel(GetHashKey(requiredFlag))
			while not HasModelLoaded(GetHashKey(requiredFlag)) do
				Citizen.Wait(0)
			end
			local flag = CreateObject(GetHashKey(requiredFlag), data.coords, false, false, true)
			SetEntityCoords(flag, data.coords.x, data.coords.y, data.coords.z)
			PlaceObjectOnGroundProperly(flag)
			SetEntityInvincible(flag, true)
			FreezeEntityPosition(flag, true)
			FlagMain[zone] = flag
		end)
    end

	for zone, data in pairs(TeamData) do
		local blip = AddBlipForCoord(data.coords)
        SetBlipSprite(blip, 464)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Stealth Zone ".. data.teamLabel)
        EndTextCommandSetBlipName(blip)
		Blipt[zone] = blip
	end
	
	Citizen.CreateThread(function()
		while RankStart do
			if next(flagData) ~= nil then
				local ped = PlayerPedId()
				local pedCoords = GetEntityCoords(ped)
				for zone, data in pairs(Config.FlagZone) do
					if (GetDistanceBetweenCoords(pedCoords, data.coords, true) < 200.0) then
						DrawMarker(1, data.coords.x, data.coords.y, data.coords.z -20, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 70.0, 70.0, 50.0, flagData[zone].colorCode.r, flagData[zone].colorCode.g, flagData[zone].colorCode.b, 120, false, true, 2, false, false, false, false)
						DrawMarker(0, data.coords.x , data.coords.y, data.coords.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.5, 0.5, 0.5, flagData[zone].colorCode.r, flagData[zone].colorCode.g, flagData[zone].colorCode.b, 100, true, true, 2, false, false, false, false)
						if (GetDistanceBetweenCoords(pedCoords, data.coords, false) < 36.0) then
							if IsPedInAnyVehicle(ped, false) then
								local veh = GetVehiclePedIsIn(ped, false)
								if GetPedInVehicleSeat(veh, -1) == ped then
									if DoesEntityExist(veh) and NetworkHasControlOfEntity(veh) then
										ESX.Game.DeleteVehicle(veh)
									end
								end
							end
							if ClearCarFlag <= 0 then
								local vehicles = ESX.Game.GetVehiclesInArea(data.coords, 33.0)
								for k,entity in ipairs(vehicles) do
									local attempt = 0
									while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
										Citizen.Wait(100)
										NetworkRequestControlOfEntity(entity)
										attempt = attempt + 1
									end
									if (not IsPedAPlayer(GetPedInVehicleSeat(entity, -1))) then
										if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
											ESX.Game.DeleteVehicle(entity)
										end
									end
								end
								ClearCarFlag = 16
							end
							if (GetDistanceBetweenCoords(pedCoords, data.coords.x , data.coords.y, data.coords.z, true) < 2) and not IsPedInAnyVehicle(ped, false) and IsPedOnFoot(ped) and Myteam then
								if (not flagData[zone].holded) then
									DrawText3D(data.coords.x , data.coords.y, data.coords.z + 1, ('[E] ~y~Hold Flag (Zone:'..zone..')'))
									if (IsControlJustReleased(0, 38)) then
										isPicking = true
										exports["mythic_progbar"]:Progress(
										{
											name = "unique_action_name",
											duration = 40000,
											label = "Seize The Flag",
											useWhileDead = false,
											canCancel = false,
											controlDisables = {
												disableMovement = true,
												disableCarMovement = true,
												disableMouse = false,
												disableCombat = true
											},
											animation = {
												animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
												anim = "machinic_loop_mechandplayer",
												flags = 49,
											},
										}, function(status)
											if not status then
												if GetDistanceBetweenCoords(GetEntityCoords(ped), data.coords.x , data.coords.y, data.coords.z, true) < 2.0 then
													TriggerServerEvent('miami_rank:holderFlag', zone, Myteam, true)
													Citizen.Wait(500)
												else
													TriggerEvent("pNotify:SendNotification", {text = "too far", type = "error"})
												end
												isPicking = false
											else
												isPicking = false
											end
										end)
									end
								elseif flagData[zone].canseize then
									if (Myteam ~= flagData[zone].holderTeam) then
										local fzname = flagData[zone].holderTeamL
										DrawText3D(data.coords.x , data.coords.y, data.coords.z + 1, ('[E] ~y~Seize Flag From Team '.. Config.TeamLabel[fzname].name))
										if (IsControlJustReleased(0, 38)) then
											isPicking = true
											exports["mythic_progbar"]:Progress(
											{
												name = "unique_action_name",
												duration = 40000,
												label = "Seize The Flag",
												useWhileDead = false,
												canCancel = false,
												controlDisables = {
													disableMovement = true,
													disableCarMovement = true,
													disableMouse = false,
													disableCombat = true
												},
												animation = {
													animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
													anim = "machinic_loop_mechandplayer",
													flags = 49,
												},
											}, function(status)
												if not status then
													if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), data.coords.x , data.coords.y, data.coords.z, true) < 2.0 then
														TriggerServerEvent('miami_rank:holderFlag', zone, Myteam, false)
														Citizen.Wait(500)
													else
														TriggerEvent("pNotify:SendNotification", {text = "too far", type = "error"})
													end
													isPicking = false
												else
													isPicking = false
												end
											end)
										end
									else
										DrawText3D(data.coords.x , data.coords.y, data.coords.z + 1, ('~r~Flag has been holded'))
									end
								else
									DrawText3D(data.coords.x , data.coords.y, data.coords.z + 1, ('~r~Flag is cooldown'))
								end
							end
						end
					end
				end
				for zone, data in pairs(TeamData) do
					if (GetDistanceBetweenCoords(pedCoords, data.coords, true) < 200.0) then
						DrawMarker(1, data.coords.x, data.coords.y, data.coords.z -20, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 70.0, 70.0, 50.0, Config.ColorCode[zone].r, Config.ColorCode[zone].g, Config.ColorCode[zone].b, 120, false, true, 2, false, false, false, false)
						DrawMarker(0, data.coords.x , data.coords.y, data.coords.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.5, 0.5, 0.5, Config.ColorCode[zone].r, Config.ColorCode[zone].g, Config.ColorCode[zone].b, 100, true, true, 2, false, false, false, false)
						if (GetDistanceBetweenCoords(pedCoords, data.coords, false) < 36.0) then
							if IsPedInAnyVehicle(ped, false) then
								local veh = GetVehiclePedIsIn(ped, false)
								if GetPedInVehicleSeat(veh, -1) == ped then
									if DoesEntityExist(veh) and NetworkHasControlOfEntity(veh) then
										ESX.Game.DeleteVehicle(veh)
									end
								end
							end
							if ClearCarBase <= 0 then
								local vehicles = ESX.Game.GetVehiclesInArea(data.coords, 33.0)
								for k,entity in ipairs(vehicles) do
									local attempt = 0
									while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
										Citizen.Wait(100)
										NetworkRequestControlOfEntity(entity)
										attempt = attempt + 1
									end
									if (not IsPedAPlayer(GetPedInVehicleSeat(entity, -1))) then
										if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
											ESX.Game.DeleteVehicle(entity)
										end
									end
								end
								ClearCarBase = 16
							end
							if (GetDistanceBetweenCoords(pedCoords, data.coords.x , data.coords.y, data.coords.z, true) < 1.0) and not isPicking and not isDead and not IsPedInAnyVehicle(ped, false) and IsPedOnFoot(ped) then
								if Myteam ~= zone then
									if not data.cooldown and data.score > 0 then
										DrawText3D(data.coords.x , data.coords.y, data.coords.z + 0.5, ('[E] ~y~Stealth Point From Team '.. data.teamLabel))
										if (IsControlJustReleased(0, 38)) then
											isPicking = true
											exports["mythic_progbar"]:Progress(
											{
												name = "unique_action_name",
												duration = 40000,
												label = "Loading",
												useWhileDead = false,
												canCancel = false,
												controlDisables = {
													disableMovement = true,
													disableCarMovement = true,
													disableMouse = false,
													disableCombat = true
												},
												animation = {
													animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
													anim = "machinic_loop_mechandplayer",
													flags = 49,
												},
											}, function(status)
												if not status then
													if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), data.coords.x , data.coords.y, data.coords.z, true) < 1.5 then
														TriggerServerEvent('miami_rank:Stealthpoints', zone, Myteam)
														Citizen.Wait(500)
													else
														TriggerEvent("pNotify:SendNotification", {text = "too far", type = "error"})
													end
													isPicking = false
												else
													isPicking = false
												end
											end)
										end
									else
										DrawText3D(data.coords.x , data.coords.y, data.coords.z + 0.5, ("~r~Point not to stealth"))
									end
								end
							end
						end
					end
				end
			end
			Citizen.Wait(1)
		end
	end)

	Citizen.CreateThread(function()
		while RankStart do
			Citizen.Wait(1000)
			if SecRemaining > 0 then
				SecRemaining = SecRemaining - 1
				if MenuEnable then
					SendNUIMessage({
						uptime = true,
						sec = disp_time(SecRemaining),
						uppoint = true,
						wpoint = TeamData['white'].score,
						bpoint = TeamData['black'].score
					})
				end
				if ClearCarAirdrop > 0 then
					ClearCarAirdrop = ClearCarAirdrop - 1
				end
				if ClearCarFlag > 0 then
					ClearCarFlag = ClearCarFlag - 1
				end
				if ClearCarBase > 0 then
					ClearCarBase = ClearCarBase - 1
				end
			end
		end
	end)
	Citizen.CreateThread(function()
		while RankStart do
			local found = false
			local player = PlayerPedId()
			local pos = GetEntityCoords(player)
			if next(airdrops) then
				found = true
				for k,v in pairs(airdrops) do
					local crate_pos = GetEntityCoords(v.crate)
					if (GetDistanceBetweenCoords(pos, crate_pos, true) < 200.0) then
						DrawMarker(1, crate_pos.x, crate_pos.y, crate_pos.z -20, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 70.0, 70.0, 50.0, 200, 0, 0, 75, false, true, 2, false, false, false, false)
						if (GetDistanceBetweenCoords(pos, crate_pos, false) < 36.0) then
							if IsPedInAnyVehicle(player, false) then
								local veh = GetVehiclePedIsIn(player, false)
								if GetPedInVehicleSeat(veh, -1) == player then
									if DoesEntityExist(veh) and NetworkHasControlOfEntity(veh) then
										ESX.Game.DeleteVehicle(veh)
									end
								end
							end
							if ClearCarAirdrop <= 0 then
								local vehicles = ESX.Game.GetVehiclesInArea(crate_pos, 33.0)
								for k,entity in ipairs(vehicles) do
									local attempt = 0
									while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
										Citizen.Wait(100)
										NetworkRequestControlOfEntity(entity)
										attempt = attempt + 1
									end
									if (not IsPedAPlayer(GetPedInVehicleSeat(entity, -1))) then
										if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
											ESX.Game.DeleteVehicle(entity)
										end
									end
								end
								ClearCarAirdrop = 16
							end
							if GetDistanceBetweenCoords(pos, crate_pos, true) < 2.0 and not isPicking and not IsPedInAnyVehicle(player, false) and IsPedOnFoot(player) and Myteam then
								if v.available and v.available < GetGameTimer() then
									ESX.Game.Utils.DrawText3D({x = crate_pos.x, y = crate_pos.y, z = crate_pos.z + 1}, 'Press [E] to pick', 0.8)
									if IsControlJustReleased(0, 38) then
										isPicking = true
										exports["mythic_progbar"]:Progress(
										{
											name = "unique_action_name",
											duration = 40000,
											label = "Pickup..",
											useWhileDead = false,
											canCancel = false,
											controlDisables = {
												disableMovement = true,
												disableCarMovement = true,
												disableMouse = false,
												disableCombat = true
											},
											animation = {
												animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
												anim = "machinic_loop_mechandplayer",
												flags = 49,
											},
										}, function(status)
											if not status then
												if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), crate_pos, true) < 2.0 then
													TriggerServerEvent('miami_rank:PickCrate', k, Myteam)
													Citizen.Wait(500)
												else
													TriggerEvent("pNotify:SendNotification", {text = "too far", type = "error"})
												end
												isPicking = false
											else
												isPicking = false
											end
										end)
									end
								end
							end
						end
					end
				end
			end
			if not found then
				Citizen.Wait(1000)
			else
				Citizen.Wait(5)
			end
		end
	end)
	Citizen.CreateThread(function()
		while RankStart do
			Citizen.Wait(0)
			if isPicking == true then
				DisableControlAction(0, 29, true) -- B
				DisableControlAction(0, 73, true) -- X
				DisableControlAction(0, 323, true) -- X
				--DisableControlAction(0, 245, true) -- T
				DisableControlAction(0, 246, true) -- Y
				DisableControlAction(0, 289, true) -- F2
				DisableControlAction(0, 74, true) -- H
				DisableControlAction(0, 22, true) -- SPACEBAR
				DisableControlAction(0, 30, true) -- disable left/right
				DisableControlAction(0, 31, true) -- disable forward/back
				DisableControlAction(0, 36, true) -- INPUT_DUCK
				DisableControlAction(0, 23, true) -- disable f
				DisableControlAction(0, 21, true) -- disable sprint
				DisableControlAction(0, 44, true) -- Cover
				DisableControlAction(0, 18, true) -- Enter
				DisableControlAction(0, 176, true) -- Enter
				DisableControlAction(0, 201, true) -- Enter
				DisableControlAction(0, 170, true) -- F3
				DisableControlAction(0, 166, true) -- F5
				DisableControlAction(0, 167, true) -- F6
				DisableControlAction(0, 56, true) -- F9
			end
		end
	end)
end

function getStatusRank()
	if RankStart and SecRemaining > 0 then
		return true
	end
	return false
end

RegisterNetEvent('miami_rank:killfeedCL')
AddEventHandler('miami_rank:killfeedCL', function(data)
	if RankStart and SecRemaining > 0 then
		if MenuEnable then
			SendNUIMessage({
				show = true,
				killer1 = data.p1,
				kteam1 = data.p1t,
				killer2 = data.p2,
				kteam2 = data.p2t,
				weapon = data.w,
			})
			if data.w == "point" then
				SendNUIMessage({
					uppoint = true,
					wpoint = TeamData['white'].score,
					bpoint = TeamData['black'].score,
				})
			end
		end
	end
end)

RegisterNetEvent('miami_rank:UpdateMVP')
AddEventHandler('miami_rank:UpdateMVP', function(data)
	if RankStart and SecRemaining > 0 then
		SendNUIMessage({
			mvp = true,
			m1 = data.MVP,
			m2 = data.MVP2,
			m3 = data.MVP3,
			pk1 = data.MVPkill,
			pk2 = data.MVPkill2,
			pk3 = data.MVPkill3,
			pd1 = data.MVPdead,
			pd2 = data.MVPdead2,
			pd3 = data.MVPdead3,
			t1 = data.T1,
			t2 = data.T2,
			t3 = data.T3,
		})
	end
end)

RegisterNetEvent('miami_rank:setup_airdrop')
AddEventHandler('miami_rank:setup_airdrop', function(ident, pos)
	if RankStart and SecRemaining > 0 then
		TriggerEvent("chat:addMessage", { args = { "Ranking crate", "ขณะนี้ Point crate ได้ปรากฏออกมาแล้ว" }, color = { 157, 0, 225 } })
		local blip = AddBlipForRadius(pos,70.0)
		SetBlipColour(blip, 5)
		SetBlipAlpha(blip, 60)
		airdrops[ident] = {
			blip = blip,
			available = GetGameTimer() + (40 * 1000)
		}
		Citizen.CreateThread(function()
			RequestModel(GetHashKey(requiredModels))
			while not HasModelLoaded(GetHashKey(requiredModels)) do
				Citizen.Wait(0)
			end
			airdrops[ident].crate = CreateObject(GetHashKey(requiredModels), pos, false, false, true)
			SetEntityCoords(airdrops[ident].crate, pos.x, pos.y, pos.z-1.0)
			PlaceObjectOnGroundProperly(airdrops[ident].crate)
			SetEntityInvincible(airdrops[ident].crate, true)
			FreezeEntityPosition(airdrops[ident].crate, true)
			local blip = AddBlipForEntity(airdrops[ident].crate)
			SetBlipSprite(blip, 466)
			SetBlipColour(blip, 1)
			SetBlipScale(blip, 0.7)
			SetBlipAsShortRange(blip, true)
			SetBlipDisplay(blip, 4)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Ranking Crate")
			EndTextCommandSetBlipName(blip)
			SetModelAsNoLongerNeeded(GetHashKey(requiredModels))
		end)
	end
end)

RegisterNetEvent('miami_rank:UpdateCrate')
AddEventHandler('miami_rank:UpdateCrate', function(data)
	if airdrops[data.ident] then
		DeleteObject(airdrops[data.ident].crate)
		RemoveBlip(airdrops[data.ident].blip)
		airdrops[data.ident] = nil
		if RankStart then
			if MenuEnable then
				local feed = data.p..' Get pointcrate | Team '..data.f..' <span style="color:red;">+10</span>'
				TeamData['white'].score = data.w
				TeamData['black'].score = data.b
				SendNUIMessage({
					upcrate = true,
					cratefeed = feed,
					uppoint = true,
					wpoint = TeamData['white'].score,
					bpoint = TeamData['black'].score
				})
			end
		end
	end
end)

RegisterNetEvent('miami_rank:setStealth')
AddEventHandler('miami_rank:setStealth', function(data)
	if RankStart then
		TeamData['white'].cooldown = data.w
		TeamData['black'].cooldown = data.b
	end
end)

RegisterNetEvent('miami_rank:UpdateStealth')
AddEventHandler('miami_rank:UpdateStealth', function(data)
	TeamData[data.z].cooldown = data.s
	TeamData[data.z].score = data.zs
	TeamData[data.t].score = data.ts
	if MenuEnable then
		local feed = data.n..' Stealth points from <span style="color:red;"> Team '..TeamData[data.z].teamLabel..' </span>'
		SendNUIMessage({
			upcrate	= true,
			cratefeed = feed,
			uppoint	= true,
			wpoint = TeamData['white'].score,
			bpoint = TeamData['black'].score
		})
	end
end)

RegisterCommand("rshow", function(source, args, raw) --change command here
	if RankStart then
		if not MenuEnable then
			SendNUIMessage({
				showmenu = true,
				team1 = TeamData['white'].teamName,
				team1l = TeamData['white'].teamLabel,
				team2 = TeamData['black'].teamName,
				team2l = TeamData['black'].teamLabel,
				sec = disp_time(SecRemaining)
			})
			MenuEnable = true
		end
	end
end, false)

RegisterCommand("rclose", function(source, args, raw) --change command here
	if RankStart then
		if MenuEnable then
			SendNUIMessage({
				hidemenu = true
			})
			MenuEnable = false
		end
	end
end, false)

local fontID = nil
Citizen.CreateThread(function()
	while fontID == nil do
		Citizen.Wait(5000)
		fontID = exports["base_font"]:GetFontId("srbn")
	end
end)

function DrawText3D(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.45, 0.45)
    SetTextFont(fontID)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

AddEventHandler("esx:onPlayerDeath", function()
    isDead = true
	isPicking = false
end)

AddEventHandler("esx:onPlayerSpawn", function()
    isDead = false
end)

function disp_time(time)
	local minutes = math.floor(time/60)
	local seconds = math.floor(math.fmod(time,60))
	local text = ""
	if minutes > 0 then
		text = text..""..minutes.." minute "
	end
	text = text..""..seconds.." seconds"
	return text
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
		for k,v in pairs(airdrops) do
			DeleteEntity(v.crate)
		end
		for k,v in pairs(FlagMain) do
			DeleteEntity(v)
		end
		SetModelAsNoLongerNeeded(GetHashKey(requiredModels))
		SetModelAsNoLongerNeeded(GetHashKey(requiredFlag))
    end
end)