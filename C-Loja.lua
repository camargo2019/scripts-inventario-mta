------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	   -----	LOJA BRP		-----
------------------------------------------
local painel = false
local screenW, screenH = guiGetScreenSize()
local resW, resH = 1366,768
local x, y = (screenW/resW), (screenH/resH)

local CMR_Font_14 = dxCreateFont("font/font.ttf", x*14)
local CMR_Font_12 = dxCreateFont("font/font.ttf", x*12)
local CMR_Font_10 = dxCreateFont("font/font.ttf", x*10)
local CMR_Font_8 = dxCreateFont("font/font.ttf", x*8)
local CMR_Font_7 = dxCreateFont("font/font.ttf", x*7)
local CMR_Font_6 = dxCreateFont("font/font.ttf", x*6)

QuantidadeItem2 = createElement("CMR:Edit_QuantidadeItem")

local IdItemShop
local IdShop
local NomeItem
local ValorItem

local LojaC

local PedLoja = {}
local BlipsLoja = {}

function CMR_InitLoja(res)
	if res == getThisResource() then
		for i, v in ipairs(Lojas) do
			PedLoja[i] = createPed(v[8], v[1], v[2], v[3], v[6])
			setElementFrozen(PedLoja[i], true)
			setElementData(PedLoja[i], "CMR:PedName", v[7])
			if not v[5] then
				BlipsLoja[i] = createBlipAttachedTo(PedLoja[i], v[5])
			end
		end
	end
end
addEventHandler("onClientResourceStart", root, CMR_InitLoja)

function CMR_RenderClick()
	if not isEventHandlerAdded("onClientRender", root, CMR_LojaDX) then
		for ia, v in ipairs(Lojas) do
			for i, ped in ipairs(PedLoja) do
						if ia == i then
							local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
							local px, py, pz = getCameraMatrix()
							local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz)
							local tx, ty, tz = getElementPosition(localPlayer) 
							local rx, ry, rz = getElementPosition(PedLoja[i]) 
							local distancia = getDistanceBetweenPoints3D(tx, ty, tz, rx, ry, rz) 
							if (distancia < 5)  then 
								if hit then
								if elementHit == PedLoja[i] then
								triggerEvent("CMR:LojaAbrir", localPlayer, v)
							end
						end
					end 
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, CMR_RenderClick)

function CMR_CancelPed(attacker)
	cancelEvent()
end
addEventHandler("onClientPedDamage", getRootElement(), CMR_CancelPed)

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if 
		type( sEventName ) == 'string' and 
		isElement( pElementAttachedTo ) and 
		type( func ) == 'function' 
	then
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

function CMR_PedName()
	for i, a in ipairs(PedLoja) do
		local pedX, pedY, pedZ = getElementPosition(PedLoja[i])
		local sx, sy = getScreenFromWorldPosition(pedX,pedY,pedZ +1)
		local cameraX, cameraY, cameraZ = getCameraMatrix()
		local screenWidth, screenHeight = guiGetScreenSize() 
		if sx then
			if getDistanceBetweenPoints3D(cameraX,cameraY,cameraZ,pedX,pedY,pedZ) <= 9 then 
				if not getElementData(localPlayer, "CMR:ShowBlur") then
					dxDrawText(getElementData(a, "CMR:PedName")..'(#00ff00NPC#ffffff)',sx - 100,sy + 80, screenWidth, screenHeight, tocolor ( 255, 255, 255, 230 ), 1,CMR_Font_10, "left", "top", false, false, false, true, false) 
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, CMR_PedName)

function CMR_LojaDX()
	exports.Blur:dxDrawBluredRectangle(x*0, y*0, x*1366, y*768, tocolor(255, 255, 255, 255))
	dxDrawImage(x*558, y*234, x*250, y*300, "Img/LojaVisual.png", 0, 0, 0)

	if IdShop and NomeItem and ValorItem then
		dxDrawImage(x*655, y*290, x*50, y*50, "Img/items/"..IdShop..".png", 0, 0, 0)
		dxDrawText("Nome: "..tostring(NomeItem), x*1280, y*390, x*80, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_8, "center", "top", false, false, false, false, false)
		dxDrawText("Valor: R$ "..tostring(ValorItem).." (Unidade)", x*1280, y*410, x*80, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_8, "center", "top", false, false, false, false, false)
	end

	dxDrawEditBox("Quantidade", x*643, y*440, x*80, y*20, false, 8, QuantidadeItem2)
	dxDrawText("Comprar", x*1280, y*480, x*80, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_12, "center", "top", false, false, false, false, false)
end

function CMR_LojaAbrir(loja)
	if not painel then
		LojaC = loja
		addEventHandler("onClientRender", root, CMR_LojaDX)
		painel = true
		showCursor(true)
		CMR_CarregarItem()
	else
		removeEventHandler("onClientRender", root, CMR_LojaDX)
		painel = false
		showCursor(false)
		setElementData(QuantidadeItem2, "TextoElement", nil)
	end
end
addEvent("CMR:LojaAbrir", true)
addEventHandler("CMR:LojaAbrir", root, CMR_LojaAbrir)

function CMR_CarregarItem()
	for i, shop in ipairs(Lojas) do
		if LojasTipo[LojaC[4]] then
			for o, item in ipairs(LojasTipo[LojaC[4]]) do
				for a, itemShop in ipairs(items) do
					if o == 1 then
						if item[1] == itemShop[3] then
							IdItemShop = o
							IdShop = itemShop[3]

							NomeItem = itemShop[1]
							ValorItem = item[2]
							return
						end
					end
				end
			end
		end 
	end
end

function CMR_LojaClick(_, state)
	if isEventHandlerAdded("onClientRender", root, CMR_LojaDX) then
		if state == "down" then
			if painel then
				if isCursor(x*765, y*240, x*30, y*30) then
					playSoundFrontEnd(43)
					CMR_LojaAbrir()
				end

				-- Proximo
				if isCursor(x*730, y*295, x*30, y*30) then
					playSoundFrontEnd(43)
					for i, shop in ipairs(Lojas) do
						if LojasTipo[LojaC[4]] then
							for o, item in ipairs(LojasTipo[LojaC[4]]) do
								for a, itemShop in ipairs(items) do
									if IdItemShop >= #LojasTipo[LojaC[4]] then
										if o == 1 then
											if item[1] == itemShop[3] then
												IdItemShop = o
												IdShop = itemShop[3]

												NomeItem = itemShop[1]
												ValorItem = item[2]
												return
											end
										end
									else
										if (o == (IdItemShop+1)) then
											if item[1] == itemShop[3] then
												IdItemShop = o
												IdShop = itemShop[3]

												NomeItem = itemShop[1]
												ValorItem = item[2]
												return
											end
										end
									end
								end
							end
						end 
					end

				end

				-- Voltar
				if isCursor(x*600, y*295, x*30, y*30) then
					playSoundFrontEnd(43)

					for i, shop in ipairs(Lojas) do
						if LojasTipo[LojaC[4]] then
							for o, item in ipairs(LojasTipo[LojaC[4]]) do
								for a, itemShop in ipairs(items) do
									if IdItemShop <= 1 then
										if o == #LojasTipo[LojaC[4]] then
											if item[1] == itemShop[3] then

												IdItemShop = o
												IdShop = itemShop[3]

												NomeItem = itemShop[1]
												ValorItem = item[2]
												return
											end
										end
									else
										if (o == (IdItemShop-1)) then
											if item[1] == itemShop[3] then
												IdItemShop = o
												IdShop = itemShop[3]

												NomeItem = itemShop[1]
												ValorItem = item[2]
												return
											end
										end
									end
								end
							end
						end 
					end

				end

				-- Comprar
				if isCursor(x*610, y*458, x*140, y*40) then
					playSoundFrontEnd(43)
					triggerServerEvent("CMR:ComprarItem", localPlayer, IdItemShop, getElementData(QuantidadeItem2, "TextoElement") or 0, LojaC)
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, CMR_LojaClick)
