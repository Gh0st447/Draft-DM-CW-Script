local screenWidth, screenHeight = guiGetScreenSize()
DGS = exports.dgs
local draft = {}
draft.font = dxCreateFont("font.ttf", 10)
draft.markerCounterFont = dxCreateFont("font.ttf", 15)
draft.loadedMarkers = {}
draft.totalMarkerCount = 0
draft.hitMarkers = 0
draft.draftState = "free"
draft.visbleGUI = false

function draft.setPlayerScore()
	setElementData(localPlayer, "draftPlayerScore", 0)
end
addEventHandler("onClientResourceStart", resourceRoot, draft.setPlayerScore)

function draft.createScoreMenu(cmd)
	if not draft.scoreMenu then
		-- Create the main score menu
		draft.scoreMenuWidth = 220
		draft.scoreMenuHeight = 20
		draft.scoreMenuX = screenWidth - draft.scoreMenuWidth
		draft.scoreMenuY = screenHeight/2 - draft.scoreMenuHeight
		draft.scoreMenu = DGS:dgsCreateGridList (draft.scoreMenuX, draft.scoreMenuY, draft.scoreMenuWidth, draft.scoreMenuHeight, false )
		draft.scoreMenuState = DGS:dgsGridListAddColumn(draft.scoreMenu, "#FFFFFFFree", 0.78)
		draft.scoreMenuRounds = DGS:dgsGridListAddColumn(draft.scoreMenu, "#FFFFFF0#FF8C00/#FFFFFF20", 0.2)
		DGS:dgsSetProperty(draft.scoreMenu, "colorCoded", true)
		DGS:dgsSetFont(draft.scoreMenu, draft.font)
		DGS:dgsSetProperty(draft.scoreMenu, "columnColor", tocolor(255, 255, 0, 70))
		-- Create team one table
		draft.teamOneTableWidth = draft.scoreMenuWidth
		draft.teamOneTableHeight = 20
		draft.teamOneTableX = draft.scoreMenuX
		draft.teamOneTableY = draft.scoreMenuY + draft.scoreMenuHeight
		draft.teamOneTable = DGS:dgsCreateGridList(draft.teamOneTableX, draft.teamOneTableY, draft.teamOneTableWidth, draft.teamOneTableHeight, false )
		DGS:dgsSetProperty(draft.teamOneTable, "colorCoded", true)
		draft.teamOnePlayersColumn = DGS:dgsGridListAddColumn(draft.teamOneTable, "#FFFFFFT1", 0.85)
		draft.teamOnePlayersScore = DGS:dgsGridListAddColumn(draft.teamOneTable, "0", 0.15)
		DGS:dgsSetFont(draft.teamOneTable, draft.font)
		DGS:dgsSetProperty(draft.teamOneTable, "columnColor", tocolor(255, 0, 0, 70))
		DGS:dgsSetProperty(draft.teamOneTable, "bgColor", tocolor(0, 0, 0, 0))
		DGS:dgsSetProperty(draft.teamOneTable, "rowColor", {tocolor(0, 0, 0, 70)})
		-- Create team two table
		draft.teamTwoTableWidth = draft.teamOneTableWidth
		draft.teamTwoTableHeight = 20
		draft.teamTwoTableX = draft.scoreMenuX
		draft.teamTwoTableY = draft.teamOneTableY + draft.scoreMenuHeight
		draft.teamTwoTable = DGS:dgsCreateGridList(draft.teamTwoTableX, draft.teamTwoTableY, draft.teamTwoTableWidth, draft.teamTwoTableHeight, false )
		DGS:dgsSetProperty(draft.teamTwoTable, "colorCoded", true)
		draft.teamTwoPlayersColumn = DGS:dgsGridListAddColumn(draft.teamTwoTable, "#FFFFFFT2", 0.85)
		draft.teamTwoPlayersScore = DGS:dgsGridListAddColumn(draft.teamTwoTable, "0", 0.15)
		DGS:dgsSetFont(draft.teamTwoTable, draft.font)
		DGS:dgsSetProperty(draft.teamTwoTable, "columnColor", tocolor(0, 0, 255, 70))
		DGS:dgsSetProperty(draft.teamTwoTable, "bgColor", tocolor(0, 0, 0, 0))
		DGS:dgsSetProperty(draft.teamTwoTable, "rowColor", {tocolor(0, 0, 0, 70)})
		--Map markers counter
		draft.mapMarkerCounterWidth = 60
		draft.mapMarkerCounterHeight = 20
		draft.mapMarkerCounterX = screenWidth/2 - 20
		draft.mapMarkerCounterY = screenHeight - screenHeight
		draft.mapMarkerCounter = DGS:dgsCreateGridList (draft.mapMarkerCounterX, draft.mapMarkerCounterY, draft.mapMarkerCounterWidth, draft.mapMarkerCounterHeight, false )
		draft.mapMarkerCounterCount = DGS:dgsGridListAddColumn(draft.mapMarkerCounter, "#FFFFFF0#FF8C00/#FFFFFF0", 1)
		DGS:dgsSetProperty(draft.mapMarkerCounter, "colorCoded", true)
		DGS:dgsSetProperty(draft.mapMarkerCounter, "columnColor", tocolor(0, 0, 0, 0))
		DGS:dgsSetFont(draft.mapMarkerCounter, draft.markerCounterFont)
	end
	--Handel table differences for new joined players
	draft.updateTeamTableContent()
	draft.updateTeamTablesGUI()
end
addEventHandler("onClientResourceStart", root, draft.createScoreMenu)

function draft.updateTeamTablesGUI()
	local GUI = {}
	local teamElements = getElementsByType("team")
	--Team one always under main score menu
	GUI.scoreMenuX, GUI.scoreMenuY = DGS:dgsGetPosition(draft.scoreMenu, false)
	GUI.scoreMenuWidth, GUI.scoreMenuHeight = DGS:dgsGetSize(draft.scoreMenu, false)
	DGS:dgsSetPosition(draft.teamOneTable, GUI.scoreMenuX, GUI.scoreMenuY + GUI.scoreMenuHeight)
	-- Adjust team one table height according to the number of player in team
	local playerNumInTeamOne = 0
	for i, team in ipairs(teamElements) do
		if isElement(team) and getTeamName(team) == "T1" then
			playerNumInTeamOne = countPlayersInTeam(team)
		end
	end
	DGS:dgsSetSize(draft.teamOneTable, GUI.scoreMenuWidth, draft.teamOneTableHeight + 15 * playerNumInTeamOne)
	--Team two always under team one table
	GUI.teamOneTableX, GUI.teamOneTableY = DGS:dgsGetPosition(draft.teamOneTable, false)
	GUI.teamOneTableWidth, GUI.teamOneTableHeight = DGS:dgsGetSize(draft.teamOneTable, false)
	DGS:dgsSetPosition(draft.teamTwoTable, GUI.teamOneTableX, GUI.teamOneTableY + GUI.teamOneTableHeight)
	-- Adjust team two table height according to the number of player in team
	local playerNumInTeamTwo = 0
	for i, team in ipairs(teamElements) do
		if isElement(team) and getTeamName(team) == "T2" then
			playerNumInTeamTwo = countPlayersInTeam(team)
		end
	end
	DGS:dgsSetSize(draft.teamTwoTable, GUI.scoreMenuWidth, draft.teamTwoTableHeight + 15 * playerNumInTeamTwo)
end

function draft.updateTeamTableContent()
	--Check players in team and gui, add/remove
	DGS:dgsGridListClear(draft.teamOneTable)
	DGS:dgsGridListClear(draft.teamTwoTable)
	
	for id, player in ipairs(getElementsByType("player")) do
		local playerTeam = getPlayerTeam(player)
		if playerTeam and getTeamName(playerTeam) == "T1" then
			draft.teamOnePlayerRow = DGS:dgsGridListAddRow(draft.teamOneTable)
			DGS:dgsGridListSetItemText(draft.teamOneTable, draft.teamOnePlayerRow, draft.teamOnePlayersColumn, getPlayerName(player))
			DGS:dgsGridListSetItemText(draft.teamOneTable, draft.teamOnePlayerRow, draft.teamOnePlayersScore, getElementData(player, "draftPlayerScore"))
			DGS:dgsGridListSetColumnTitle(draft.teamOneTable, 2, tostring(getElementData(playerTeam, "draftTeamScore")))
			--[[if isPedDead(player) then
				DGS:dgsGridListSetItemColor(draft.teamOneTable, draft.teamOnePlayerRow, draft.teamOnePlayersColumn, 0, 0, 0, 40)
			end]]
		elseif playerTeam and getTeamName(playerTeam) == "T2" then
			draft.teamTwoPlayerRow = DGS:dgsGridListAddRow(draft.teamTwoTable)
			DGS:dgsGridListSetItemText(draft.teamTwoTable, draft.teamTwoPlayerRow, draft.teamTwoPlayersColumn, getPlayerName(player))
			DGS:dgsGridListSetItemText(draft.teamTwoTable, draft.teamTwoPlayerRow, draft.teamTwoPlayersScore, getElementData(player, "draftPlayerScore"))
			DGS:dgsGridListSetColumnTitle(draft.teamTwoTable, 2, tostring(getElementData(playerTeam, "draftTeamScore")))
			--[[if isPedDead(player) then
				DGS:dgsGridListSetItemColor(draft.teamTwoTable, draft.teamTwoPlayerRow, draft.teamTwoPlayersColumn, 0, 0, 0, 40)
			end]]
		end
	end
	--update GUI after updating tables content
	draft.updateTeamTablesGUI()
end
addEvent("onDraftTableUpdate", true)
addEventHandler("onDraftTableUpdate", root, draft.updateTeamTableContent)

function draft.loadMarkers(mapName)
	draft.destroyLoadedMarkers()
	local mapName = ((mapName:gsub("%s", "")):gsub("%[", "")):gsub("%]", "")
	local markersXML = xmlLoadFile("markers.xml")
	local mapNode = xmlFindChild(markersXML, mapName, 0)
	for i, marker in ipairs(xmlNodeGetChildren(mapNode)) do
		local posX = tonumber(xmlNodeGetAttribute(marker, "posX"))
		local posY = tonumber(xmlNodeGetAttribute(marker, "posY"))
		local posZ = tonumber(xmlNodeGetAttribute(marker, "posZ"))
		local markerType = "corona"
		local size = 5.0
		local r, g, b, a = 255, 255, 255, 100
		draft.loadedMarkers[i] = createMarker(posX, posY, posZ, markerType, size, r, g, b, a)
		draft.totalMarkerCount = draft.totalMarkerCount + 1
		addEventHandler("onClientMarkerHit", draft.loadedMarkers[i], draft.playerMarkerHits)
	end
	xmlUnloadFile(markersXML)
	draft.updateMarkerCounterContent()
end
addEvent("onServerMapStarting", true)
addEventHandler("onServerMapStarting", root, draft.loadMarkers)

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function draft.destroyLoadedMarkers()
	for i, marker in pairs(draft.loadedMarkers) do
		if isElement(marker) then
			if isEventHandlerAdded("onClientMarkerHit", marker, draft.playerMarkerHits) then
				removeEventHandler("onClientMarkerHit", marker, draft.playerMarkerHits)
			end
			destroyElement(marker)
		end
	end
	draft.totalMarkerCount = 0
	draft.hitMarkers = 0
	draft.loadedMarkers = {}
end

function draft.playerMarkerHits(player)
	if draft.draftState ~= "live" then return end
	if isElement(source) and getElementType(source) == "marker" then
		if player == localPlayer then
			draft.hitMarkers = draft.hitMarkers + 1
			draft.updateMarkerCounterContent()
			triggerServerEvent("onServerScoreUpdate", player, localPlayer)
			removeEventHandler("onClientMarkerHit", source, draft.playerMarkerHits)
		end
	end
end

function draft.updateMarkerCounterContent()
	DGS:dgsGridListSetColumnTitle(draft.mapMarkerCounter, 1, "#FFFFFF"..tostring(draft.hitMarkers).."#FF8C00/#FFFFFF"..tostring(draft.totalMarkerCount))
end

function draft.updateRoundsCounter(currentRound, roundsNum)
	DGS:dgsGridListSetColumnTitle(draft.scoreMenu, 2, "#FFFFFF"..tostring(currentRound).."#FF8C00/#FFFFFF"..tostring(roundsNum))
end
addEvent("onRoundsCounterUpdate", true)
addEventHandler("onRoundsCounterUpdate", root, draft.updateRoundsCounter)


function draft.draftStateClient()
	local teamElements = getElementsByType("team")
	if not isElement(teamElements[1]) and not isElement(teamElements[2]) then return end
	local teamOneState = getElementData(teamElements[1], "state")
	local teamTwoState = getElementData(teamElements[2], "state")
	if teamOneState == teamTwoState and teamOneState == "live" then
		draft.draftState = "live"
		DGS:dgsGridListSetColumnTitle(draft.scoreMenu, 1, "#FFFFFFLive")
		DGS:dgsSetProperty(draft.scoreMenu, "columnColor", tocolor(50, 205, 50, 70))
	elseif teamOneState == teamTwoState and teamOneState == "free" then
		draft.draftState = "free"
		DGS:dgsGridListSetColumnTitle(draft.scoreMenu, 1, "#FFFFFFFree")
		DGS:dgsSetProperty(draft.scoreMenu, "columnColor", tocolor(255, 255, 50, 70))
	elseif teamOneState == teamTwoState and teamOneState == "end" then
		draft.draftState = "end"
		DGS:dgsGridListSetColumnTitle(draft.scoreMenu, 1, "#FFFFFFEnded")
		DGS:dgsSetProperty(draft.scoreMenu, "columnColor", tocolor(255, 0, 0, 70))
	end
end
addEvent("onClientDraftStateChange", true)
addEventHandler("onClientDraftStateChange", root, draft.draftStateClient)

--[[function draft.killSpectatorsClient()
	triggerServerEvent("onKillSpectators", localPlayer, localPlayer)
end
addEventHandler("onClientRender", root, draft.killSpectatorsClient)]]


function draft.hideGUI()
	if not draft.visbleGUI then
		DGS:dgsSetAlpha(draft.scoreMenu, 0)
		DGS:dgsSetAlpha(draft.teamOneTable, 0)
		DGS:dgsSetAlpha(draft.teamTwoTable, 0)
		draft.visbleGUI = true
	elseif draft.visbleGUI then
		DGS:dgsSetAlpha(draft.scoreMenu, 1)
		DGS:dgsSetAlpha(draft.teamOneTable, 1)
		DGS:dgsSetAlpha(draft.teamTwoTable, 1)
		draft.visbleGUI = false
	end
end
bindKey("u", "down", draft.hideGUI)