------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	-----	INVENTARIO BRP		-----
------------------------------------------
--[[
addEventHandler("onClientResourceStart", root, function()
	txd_bag = engineLoadTXD("bag/bag.txd")
	engineImportTXD(txd_bag, 3102)
	dff_bag = engineLoadDFF("bag/bag.dff")
	engineReplaceModel(dff_bag, 3102)
	engineSetModelLODDistance(3102, 2000)
end)]]--


-------------------------------------------
-------------PAINEL INVENTARIO-------------
-------------------------------------------
local painel = false
local screenW, screenH = guiGetScreenSize()
local resW, resH = 1366,768
local x, y = (screenW/resW), (screenH/resH)

local CMR_Font_14 = dxCreateFont("font/font.ttf", x*14)
local CMR_Font_12 = dxCreateFont("font/font.ttf", x*12)
local CMR_Font_10 = dxCreateFont("font/font.ttf", x*10)
local CMR_FONT_8 = dxCreateFont("font/font.ttf", x*8)
local CMR_FONT_6 = dxCreateFont("font/font.ttf", x*6)

local ListItems = {}
local ItemClick = nil

local ItemEquipado = {}


local PosicaoItems = {
	---- Primeiro Slots
	{x*447, y*317, x*50, y*50},
	{x*447, y*375, x*50, y*50},
	{x*447, y*432, x*50, y*50},
	{x*447, y*489, x*50, y*50},
	---- Segundo Slots
	{x*506, y*317, x*50, y*50},
	{x*506, y*375, x*50, y*50},
	{x*506, y*432, x*50, y*50},
	{x*506, y*489, x*50, y*50},
	---- Terceiro Slots
	{x*564, y*317, x*50, y*50},
	{x*564, y*375, x*50, y*50},
	{x*564, y*432, x*50, y*50},
	{x*564, y*489, x*50, y*50},
	---- Quarto Slots
	{x*623, y*317, x*50, y*50},
	{x*623, y*375, x*50, y*50},
	{x*623, y*432, x*50, y*50},
	{x*623, y*489, x*50, y*50},
	---- Quinto Slots
	{x*682, y*317, x*50, y*50},
	{x*682, y*375, x*50, y*50},
	{x*682, y*432, x*50, y*50},
	{x*682, y*489, x*50, y*50},
	---- Sexto Slots
	{x*741, y*317, x*50, y*50},
	{x*741, y*375, x*50, y*50},
	{x*741, y*432, x*50, y*50},
	{x*741, y*489, x*50, y*50},
	---- Setimo Slots
	{x*799, y*317, x*50, y*50},
	{x*799, y*375, x*50, y*50},
	{x*799, y*432, x*50, y*50},
	{x*799, y*489, x*50, y*50},
	---- Oitavo Slots
	{x*858, y*317, x*50, y*50},
	{x*858, y*375, x*50, y*50},
	{x*858, y*432, x*50, y*50},
	{x*858, y*489, x*50, y*50},
}
-----------------QUANTIDADE ITEM-----------------------
QuantidadeItem = createElement("CMR:Edit_QuantidadeItem")

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

function CMR_Inv()
	--exports.Blur:dxDrawBluredRectangle(x*0, y*0, x*1366, y*768, tocolor(255, 255, 255, 255))
	dxDrawImage(x*340, y*200, x*600, y*400, "Img/VisualInvInicial.png", 0, 0, 0)
	dxDrawImage(x*332, y*132, x*600, y*400, "Img/bag.png", 0, 0, 0)
	dxDrawImage(x*332, y*139, x*600, y*400, "Img/key.png", 0, 0, 0)
	dxDrawImage(x*332, y*146, x*600, y*400, "Img/cards.png", 0, 0, 0)
	for ia, item in ipairs(ListItems) do
		for i, itemLocal in ipairs(PosicaoItems) do
			if i == tonumber(item["posicao"]) then
				dxDrawImage(itemLocal[1], itemLocal[2], itemLocal[3], itemLocal[4], "Img/items/"..item["iditem"]..".png", 0, 0, 0)
				dxDrawText(tostring(item["quantidade"]), itemLocal[1]*2.065, itemLocal[2]*1.02, itemLocal[3], itemLocal[4], tocolor(255, 255, 255, 255), 1.00, CMR_FONT_6, "center", "top", false, false, false, false, false)
			end
		end
	end
	for b, data in ipairs(ListItems) do
		for a, Equipado in ipairs(ItemEquipado) do
			if tonumber(data["iditem"]) == tonumber(Equipado["iditem"]) then
				for i, itemLocal in ipairs(PosicaoItems) do
					if i == tonumber(data["posicao"]) then
						dxDrawImage(itemLocal[1], itemLocal[2], itemLocal[3], itemLocal[4], "Img/ActiveInv.png", 0, 0, 0)
					end
				end
			end
		end
	end

	if ItemClick then
		for i, itemLocal in ipairs(PosicaoItems) do
			if i == tonumber(ItemClick["posicao"]) then
				dxDrawImage(itemLocal[1], itemLocal[2], itemLocal[3], itemLocal[4], "Img/ActiveInv.png", 0, 0, 0)
			end
		end
		dxDrawImage(x*932, x*200, x*250, y*400, "Img/TelaInv2.png", 0, 0, 0)
		dxDrawImage(x*1030, y*292, x*50, y*50, "Img/items/"..ItemClick["iditem"]..".png", 0, 0, 0)
		dxDrawText("Inventário", x*2080, y*218, x*30, y*400, tocolor(255, 255, 255, 255), 1.00, CMR_Font_12, "center", "top", false, false, false, false, false)
		dxDrawEditBox("Quantidade", x*1020, y*385, x*80, y*20, false, 8, QuantidadeItem)
		if ItemClick["tipo"] == "Utensilhos" then
			dxDrawText("Equipar", x*2080, y*468, x*30, y*400, tocolor(255, 255, 255, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
		else
			dxDrawText("Usar", x*2080, y*468, x*30, y*400, tocolor(255, 255, 255, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
		end
		dxDrawText("Enviar", x*2080, y*510, x*30, y*400, tocolor(255, 255, 255, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
		dxDrawText("Fechar", x*2080, y*550, x*30, y*400, tocolor(255, 255, 255, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
	end

	dxDrawText("BRP - Inventário", x*1220, y*280, x*80, y*20, tocolor(255, 255, 255, 255), 1.00, CMR_Font_14, "center", "top", false, false, false, false, false)
end


function CMR_InvAbrir()
	if not painel then
		addEventHandler("onClientRender", root, CMR_Inv)
		ItemClick = nil
		CMR_InvCarregarItems()
		painel = true
	else
		removeEventHandler("onClientRender", root, CMR_Inv)
		painel = false
		setElementData(QuantidadeItem, "TextoElement", nil)
	end
end
addEvent("CMR:InvAbrir", true)
addEventHandler("CMR:InvAbrir", root, CMR_InvAbrir)

function CMR_InvCarregarItems()
	triggerServerEvent("CMR:InvCarregarItemsEquipado", localPlayer, localPlayer)
	triggerServerEvent("CMR:InvCarregarItems", localPlayer, localPlayer)
end

function CMR_InvAddItems(List)
	if List then
		ListItems = List
	end
end
addEvent("CMR:InvAddItems", true)
addEventHandler("CMR:InvAddItems", root, CMR_InvAddItems)

function CMR_InvCarregarItemsEquipado(List)
	if List then
		ItemEquipado = List
	end
end
addEvent("CMR:InvCarregarItemsEquipado", true)
addEventHandler("CMR:InvCarregarItemsEquipado", root, CMR_InvCarregarItemsEquipado)


function CMR_InvCarregarChaves()
	triggerServerEvent("CMR:InvCarregarChaves", localPlayer, localPlayer)
end

function CMR_InvCarregarDocumentos()
	triggerServerEvent("CMR:InvCarregarDocumentos", localPlayer, localPlayer)
end

function CMR_InvClick(_, state)
	if isEventHandlerAdded("onClientRender", root, CMR_Inv) then
		if state == "down" then
			if painel then
				if ItemClick then
					if isCursor(x*932, x*200, x*250, y*400) then
						-- Usar
						if isCursor(x*980, y*462, x*150, y*30) then
							playSoundFrontEnd(43)
							if ItemClick["tipo"] == "Utensilhos" then
								triggerServerEvent("CMR:InvEquiparItem", localPlayer, localPlayer, ItemClick, getElementData(QuantidadeItem, "TextoElement") or 0)
								ItemClick = nil
							else
								triggerServerEvent("CMR:InvUsarItem", localPlayer, localPlayer, ItemClick, getElementData(QuantidadeItem, "TextoElement") or 0)
							end
						end

						-- Enviar
						if isCursor(x*980, y*504, x*150, y*30) then
							playSoundFrontEnd(43)
							triggerServerEvent("CMR:InvEnviarItem", localPlayer, localPlayer, ItemClick, getElementData(QuantidadeItem, "TextoElement") or 0)
						end

						-- Fechar
						if isCursor(x*980, y*546, x*150, y*30) then
							playSoundFrontEnd(43)
							ItemClick = nil
						end
					else
						ItemClick = nil
					end
				end
				-- Mochila
				if isCursor(x*372, y*305, x*30, y*30) then
					CMR_InvCarregarItems()
					playSoundFrontEnd(43)
				end
				-- Chave
				if isCursor(x*372, y*350, x*30, y*30) then
					CMR_InvCarregarChaves()
					playSoundFrontEnd(43)
				end
				-- Carteira
				if isCursor(x*372, y*400, x*30, y*30) then
					CMR_InvCarregarDocumentos()
					playSoundFrontEnd(43)
				end

				-- Click em items
				for i, v in ipairs(PosicaoItems) do
					if isCursor(v[1], v[2], v[3], v[4]) then
						for ia, Item in ipairs(ListItems) do
							if i == tonumber(Item["posicao"]) then
								if Item["tipo"] == "Chave" then
									playSoundFrontEnd(43)
								elseif Item["tipo"] == "Documento" then
									playSoundFrontEnd(43)
								else
									ItemClick = Item
									for a, b in ipairs(ItemEquipado) do
										if tonumber(b["iditem"]) == tonumber(ItemClick["iditem"]) then
											triggerServerEvent("CMR:InvEquiparItem", localPlayer, localPlayer, ItemClick, 1)
											ItemClick = nil
											return
										end
									end
									playSoundFrontEnd(43)
								end
							end
						end
					end
				end

			end
		end
	end
end
addEventHandler("onClientClick", root, CMR_InvClick)


function isCursor(x,y,w,h)
	local mx,my = getCursorPosition()
	if mx and my then
		local fullx,fully = guiGetScreenSize()
		
		cursorx, cursory = mx*fullx,my*fully
		
		if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
			return true
		else
			return false
		end
	end
end