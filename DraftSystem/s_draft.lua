local draft = {}
draft.runningMap = nil
draft.loadedMarkers = {}
draft.draftRoundsCount = 0
draft.draftSetRoundsCount = 20
draft.setLiveNextMap = false

function draft.createTeams()
	--Create draft teams
	draft.teamOne = createTeam("T1" ,255,0,0)
	draft.teamTwo = createTeam("T2" ,0,0,255)
	outputChatBox ( "#ED6B5A[Draft] #FFFFFFDraft teams T1 & T2 has been created.", nil, nil, nil, nil, true)
	setElementData(draft.teamOne, "state", "free")
	setElementData(draft.teamTwo, "state", "free")
	setElementData(draft.teamOne, "draftTeamScore", 0)
	setElementData(draft.teamTwo, "draftTeamScore", 0)
	setElementData(draft.teamOne, "draftSetRoundsCount", 20)
	setElementData(draft.teamTwo, "draftSetRoundsCount", 20)
	return draft.teamOne, draft.teamTwo
end
draft.teamOne, draft.teamTwo = draft.createTeams()

function draft.addPlayerToTeam(source, command, teamNum)
	local teamNum = tonumber(teamNum)
	if isElement(source) and getElementType(source) == "player" then
		local isPlayerInTeam = getPlayerTeam(source)
		local addedPlayer = getPlayerName(source)
		if teamNum == 1 then
			if isPlayerInTeam then
				if getTeamName(isPlayerInTeam) == "T1" then return end
			end
			setPlayerTeam(source, draft.teamOne)
			outputChatBox("#ED6B5A[Draft] "..addedPlayer.." #FFFFFFjoined #FF0000T1", nil, nil, nil, nil, true)
		elseif teamNum == 2 then
			if isPlayerInTeam then
				if getTeamName(isPlayerInTeam) == "T2" then return end
			end
			setPlayerTeam(source, draft.teamTwo)
			outputChatBox("#ED6B5A[Draft] "..addedPlayer.." #FFFFFFjoined #0000FFT2", nil, nil, nil, nil, true)
		end
		triggerClientEvent("onDraftTableUpdate", source)
	end
end
addCommandHandler("join", draft.addPlayerToTeam)

function draft.addPlayerToSpectators(source, command)
	local isPlayerInTeam = getPlayerTeam(source)
	if isElement(source) and getElementType(source) == "player" and isPlayerInTeam then
		local addedPlayer = getPlayerName(source)
		setPlayerTeam(source, nil)
		outputChatBox("#ED6B5A[Draft] "..addedPlayer.." #FFFFFFjoined Spectators.", nil, nil, nil, nil, true)
		setTimer(function()
			killPed(source)
		end, 500, 1)
		triggerClientEvent("onDraftTableUpdate", source)
	end
end
addCommandHandler("spec", draft.addPlayerToSpectators)

function draft.onPlayerLeave()
	-- Update tables on player leaving the server
	setPlayerTeam(source, nil)
	for id, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			triggerClientEvent(player, "onDraftTableUpdate", source)
		end
	end
end
addEventHandler("onPlayerQuit", root, draft.onPlayerLeave)

function draft.checkRunningMap()
	if draft.setLiveNextMap then
		draft.draftRoundsCount = draft.draftRoundsCount + 1
		setElementData(draft.teamOne, "state", "live")
		setElementData(draft.teamTwo, "state", "live")
		for id, player in ipairs(getElementsByType("player")) do
			if isElement(player) then
			triggerClientEvent(player, "onClientDraftStateChange", source)
			triggerClientEvent(player, "onRoundsCounterUpdate", source, draft.draftRoundsCount, draft.draftSetRoundsCount)
			end
		end
	end
	draft.endDraft(source, nil)
    local mapName = getMapName()
	if mapName and mapName ~= "None" then
        draft.runningMap = mapName
		for id, player in ipairs(getElementsByType("player")) do
			if isElement(player) then
				triggerClientEvent(player, "onServerMapStarting", source, mapName)
			end
		end
    end
end
addEventHandler("onMapStarting", root, draft.checkRunningMap)

function draft.updateScore(source)
	if isElement(source) and getElementType(source) == "player" then
		local playerTeam = getPlayerTeam(source)
		local teamScore = tonumber(getElementData(playerTeam, "draftTeamScore"))
		local playerScore = tonumber(getElementData(source, "draftPlayerScore"))
		setElementData(source, "draftPlayerScore", playerScore + 1)
		setElementData(playerTeam, "draftTeamScore", teamScore + 1)
		for id, player in ipairs(getElementsByType("player")) do
			if isElement(player) then
				triggerClientEvent(player, "onDraftTableUpdate", source)
			end
		end
	end
end
addEvent("onServerScoreUpdate",true)
addEventHandler("onServerScoreUpdate", root, draft.updateScore)

function draft.updateTableDeathsAndAlives()
	for id, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			triggerClientEvent(player, "onDraftTableUpdate", source)
		end
	end
end
addEventHandler("onPlayerWasted", root, draft.updateTableDeathsAndAlives)
--addEventHandler("onPlayerVehicleEnter", root, draft.updateTableDeathsAndAlives)

function draft.draftStateServer(source, command)
	if command == "free" then
		outputChatBox("#ED6B5A[Draft] #FFFFFFDraft is in #FFFF00Free #FFFFFFstate.", nil, nil, nil, nil, true)
		setElementData(draft.teamOne, "state", "free")
		setElementData(draft.teamTwo, "state", "free")
		draft.setLiveNextMap = false
	elseif command == "live" then
		outputChatBox("#ED6B5A[Draft] #FFFFFFDraft will be in #32CD32Live #FFFFFFstate next round.", nil, nil, nil, nil, true)
		draft.setLiveNextMap = true
	elseif command == "end" then
		outputChatBox("#ED6B5A[Draft] #FFFFFFDraft has #FF0000Ended#FFFFFF.", nil, nil, nil, nil, true)
		setElementData(draft.teamOne, "state", "end")
		setElementData(draft.teamTwo, "state", "end")
		draft.setLiveNextMap = false
		draft.endDraft(source, true)
	end
	for id, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			triggerClientEvent(player, "onClientDraftStateChange", source)
		end
	end
end
addCommandHandler("free", draft.draftStateServer)
addCommandHandler("live", draft.draftStateServer)
addCommandHandler("end", draft.draftStateServer)

function draft.killSpectators(newState, oldState)
	if newState == "Running" then
		for id, player in ipairs(getElementsByType("player")) do
			if isElement(player) then
				local playerTeam = getPlayerTeam(player)
				local playerTeamName = nil
				if playerTeam then
					playerTeamName = getTeamName(playerTeam)
				end
				if isElement(player) and playerTeamName ~= "T1" and playerTeamName ~= "T2" then
					setTimer(function()
						killPed(player)
					end, 500, 1) -- if no delay is set to kill ped race states will bug and map wont change
				end
			end
		end
	end
end
addEventHandler("onRaceStateChanging", resourceRoot, draft.killSpectators)

function draft.endDraft(source, forced)
	if draft.draftRoundsCount > draft.draftSetRoundsCount or forced then
		draft.draftRoundsCount = draft.draftRoundsCount - 1
		outputChatBox("#ED6B5A[Draft] #FFFFFFDraft has #FF0000Ended#FFFFFF.", nil, nil, nil, nil, true)
		setElementData(draft.teamOne, "state", "end")
		setElementData(draft.teamTwo, "state", "end")
		draft.setLiveNextMap = false
		for id, player in ipairs(getElementsByType("player")) do
			if isElement(player) then
				triggerClientEvent(player, "onClientDraftStateChange", source)
				triggerClientEvent(player, "onRoundsCounterUpdate", source, draft.draftRoundsCount, draft.draftSetRoundsCount)
			end
		end
		if getElementData(draft.teamOne, "draftTeamScore") > getElementData(draft.teamTwo, "draftTeamScore") then
			outputChatBox("#ED6B5A[Draft] #FF0000T1 #FFFFFFhas won the CW.", nil, nil, nil, nil, true)
		elseif getElementData(draft.teamOne, "draftTeamScore") < getElementData(draft.teamTwo, "draftTeamScore") then
			outputChatBox("#ED6B5A[Draft] #0000FFT2 #FFFFFFhas won the CW.", nil, nil, nil, nil, true)
		elseif getElementData(draft.teamOne, "draftTeamScore") == getElementData(draft.teamTwo, "draftTeamScore") then
			outputChatBox("#ED6B5A[Draft] #FFFFFFCW has ended in a draw.", nil, nil, nil, nil, true)
		end
		
		local mvpPlayer = nil
		local mvpPlayerScore = 0
		for id, player in ipairs(getElementsByType("player")) do
			if isElement(player) then
				local playerScore = getElementData(player, "draftPlayerScore")
				if playerScore > mvpPlayerScore then
					mvpPlayer = getPlayerName(player)
					mvpPlayerScore = getElementData(player, "draftPlayerScore")
				elseif playerScore == mvpPlayerScore then
					mvpPlayer = "none"
				end
			end
		end
		outputChatBox("#ED6B5A[Draft] #FFFFFFMVP: "..tostring(mvpPlayer)..".", nil, nil, nil, nil, true)
	end
end

function draft.resetDraft()
	local DraftSystem = getThisResource()
	restartResource(DraftSystem)
end
addCommandHandler("reset", draft.resetDraft)

function draft.setRounds(source, command, num)
	local roundsNum = tonumber(num)
	if roundsNum < draft.draftRoundsCount then return end
	draft.draftSetRoundsCount = roundsNum
	for id, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			triggerClientEvent(player, "onRoundsCounterUpdate", source, draft.draftRoundsCount, draft.draftSetRoundsCount)
		end
	end
	outputChatBox("#ED6B5A[Draft] #FFFFFFTotal CW rounds has been set to "..tostring(num)..".", nil, nil, nil, nil, true)
end
addCommandHandler("rounds", draft.setRounds)

function draft.setCurrentRound(source, command, num)
	local nowNum = tonumber(num)
	if nowNum > draft.draftSetRoundsCount then return end
	draft.draftRoundsCount = nowNum
	for id, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			triggerClientEvent(player, "onRoundsCounterUpdate", source, draft.draftRoundsCount, draft.draftSetRoundsCount)
		end
	end
	outputChatBox("#ED6B5A[Draft] #FFFFFFCW current round has been set to "..tostring(num)..".", nil, nil, nil, nil, true)
end
addCommandHandler("now", draft.setCurrentRound)
