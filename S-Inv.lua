------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	-----	INVENTARIO BRP		-----
------------------------------------------


local itemObjs = {}
local bag = {}
local timer = {}

function CMR_S_Abrir(source, key, _)
	acc = getPlayerAccount(source)
	if not isGuestAccount(acc) then
		triggerClientEvent(source, "CMR:InvAbrir", source)
	end
end
---------------------------------------------
------------FUNÇÃO DO INVENTARIO-------------
---------------------------------------------

function CMR_InvCarregarItems(player)
	acc = getAccountName(getPlayerAccount(player))
	ListItems = CMR_InvCarregarItemsDB(acc)
	if ListItems then
		triggerClientEvent(player, "CMR:InvAddItems", player, ListItems)
	else
		return
	end
end
addEvent("CMR:InvCarregarItems", true)
addEventHandler("CMR:InvCarregarItems", root, CMR_InvCarregarItems)


function CMR_InvCarregarChaves(player)
	acc = getAccountName(getPlayerAccount(player))
	ListItems = CMR_InvCarregarChaveDB(acc)
	if ListItems then
		triggerClientEvent(player, "CMR:InvAddItems", player, ListItems)
	else
		return
	end
end
addEvent("CMR:InvCarregarChaves", true)
addEventHandler("CMR:InvCarregarChaves", root, CMR_InvCarregarChaves)

function CMR_InvCarregarDocumentos(player)
	acc = getAccountName(getPlayerAccount(player))
	ListItems = CMR_InvCarregarDocumentosDB(acc)
	if ListItems then
		triggerClientEvent(player, "CMR:InvAddItems", player, ListItems)
	else
		return
	end
end
addEvent("CMR:InvCarregarDocumentos", true)
addEventHandler("CMR:InvCarregarDocumentos", root, CMR_InvCarregarDocumentos)

function CMR_InvCarregarItemsEquipado(player)
	if isElement(player) then
		ItemEquipadoCliente = CMR_InvSearchItemsStatusDB(getAccountName(getPlayerAccount(player)), "Equipado")
		triggerClientEvent(player, "CMR:InvCarregarItemsEquipado", player, ItemEquipadoCliente)
	end
end
addEvent("CMR:InvCarregarItemsEquipado", true)
addEventHandler("CMR:InvCarregarItemsEquipado", root, CMR_InvCarregarItemsEquipado)

function CMR_PerderItemsAllMorrer()
	if isElement(source) then
		if isGuestAccount(getPlayerAccount(source)) then
			return
		end
		local acc = getAccountName(getPlayerAccount(source))
		CMR_DBExecutDel("cmr_status WHERE user = '"..acc.."'")
		CMR_DBExecutDel("cmr_items WHERE user = '"..acc.."'")
	end
end
addEventHandler("onPlayerWasted", root, CMR_PerderItemsAllMorrer)

function CMR_UpdateBalasUse(player, armaId)
	if player and armaId then
		if isGuestAccount(getPlayerAccount(player)) then
			return
		end
		local ArmaIDItem = nil
		for i, item  in ipairs(items) do
			if item[2] == armaId then
				ArmaIDItem = item
			end
		end
		if not ArmaIDItem then
			return
		end
		local balaID
		for a, data in ipairs(ArmasAndBalas) do
			if data[1] == tonumber(ArmaIDItem[3]) then
				balaID = tostring(data[2])
			end
		end
		local SearchBala = CMR_InvSearchStatusDB(balaID, getAccountName(getPlayerAccount(player)))
		if SearchBala then
			for a, b in ipairs(SearchBala) do
				if b["iditem"] then
					local QuantidadeBalas = CMR_InvProcurarItem(getAccountName(getPlayerAccount(player)), b["iditem"])
					if QuantidadeBalas then
						for v, h in ipairs(QuantidadeBalas) do
							if tonumber(h["quantidade"])-1 < 1 then
								CMR_InvDeleteStatusDB(h["iditem"], getAccountName(getPlayerAccount(player)))
								for slot = 0, 12 do
									local Armas = getPedWeapon(player, slot)
									local Municao = getPedTotalAmmo(player, slot)
									if Armas > 0 then
										if Municao > 0 then
											takeWeapon(player, Armas)
										end
									end
								end
								CMR_InvUpdStatusDB(ArmaIDItem[3], "Guardado", getAccountName(getPlayerAccount(player)))
								CMR_DBExecutDel("cmr_items WHERE iditem = '"..h["iditem"].."' and user = '"..getAccountName(getPlayerAccount(player)).."'")
							else
								CMR_DBExecutUpdate("cmr_items SET quantidade='"..tostring(tonumber(h["quantidade"])-1).."' WHERE user='"..getAccountName(getPlayerAccount(player)).."' and iditem = '"..h["iditem"].."'")
							end
						end
					end
				end
			end
		end
		return
	end
end
addEvent("CMR:UpdateBalasUse", true)
addEventHandler("CMR:UpdateBalasUse", root, CMR_UpdateBalasUse)


addEventHandler("onPlayerWeaponFire", root, function(weapon)
	CMR_UpdateBalasUse(source, weapon)
end)

function CMR_InvUsarItem(player, item, quantidade)
	if item then
		if not quantidade then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if quantidade == 0 then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if not tonumber(quantidade) then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if tonumber(item["quantidade"] or 0) < tonumber(quantidade) then
			exports.cmr_dxmessages:outputDx(player, "Você não tem essa quantidade!", "error")
			return
		end


		if tostring(item["funcao"]) == "Comer" then
			if isPedInVehicle(player) then
				exports.cmr_dxmessages:outputDx(player, "Você não pode comer dentro do veículo!", "error")
				return
			end
			if tonumber(getElementData(player, "hunger") or 0) >= 100 then
				exports.cmr_dxmessages:outputDx(player, "Você já está satisfeito!", "error")
				return
			else
				CMR_InvComerItem(player, item, quantidade)
				triggerClientEvent(player, "CMR:InvAbrir", player)
				return
			end
		end


		if tostring(item["funcao"]) == "Beber" then
			if isPedInVehicle(player) then
				exports.cmr_dxmessages:outputDx(player, "Você não pode beber dentro do veículo!", "error")
				return
			end
			CMR_InvBeberItem(player, item, quantidade)
			triggerClientEvent(player, "CMR:InvAbrir", player)
			return
		end

	else
		exports.cmr_dxmessages:outputDx(player, "Item selecionado não e valído!", "error")
	end
end
addEvent("CMR:InvUsarItem", true)
addEventHandler("CMR:InvUsarItem", root, CMR_InvUsarItem)

function CMR_InvEquiparItem(player, item, quantidade)
	if item then
		if not quantidade then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if quantidade == 0 then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if not tonumber(quantidade) then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end

		-- Denominar Função de Alguns items

		if tonumber(item["iditem"]) == 16 then
			if tonumber(quantidade) > 1 then
				exports.cmr_dxmessages:outputDx(player, "Você só pode usar um item por vez!", "error")
				return
			end
			local vehicle = getPedOccupiedVehicle(player)
			if not vehicle then
				exports.cmr_dxmessages:outputDx(player, "Entre dentro do veículo para poder usar esse item!", "error")
				return
			end
			setElementData(vehicle, "veh:fuel", 100)
			CMR_RemoveMochilaItem(player, item, quantidade)
			exports.cmr_dxmessages:outputDx(player, "Veículo abastecido com sucesso!", "success")
			triggerClientEvent(player, "CMR:InvAbrir", player)
			return
		end
		if tonumber(item["iditem"]) == 66 then
			if tonumber(quantidade) > 1 then
				exports.cmr_dxmessages:outputDx(player, "Você só pode usar um item por vez!", "error")
				return
			end
			local vehicle = getPedOccupiedVehicle(player)
			if not vehicle then
				exports.cmr_dxmessages:outputDx(player, "Entre dentro do veículo para poder usar esse item!", "error")
				return
			end
			fixVehicle(vehicle)
			CMR_RemoveMochilaItem(player, item, quantidade)
			exports.cmr_dxmessages:outputDx(player, "Veículo reparado com sucesso!", "success")
			triggerClientEvent(player, "CMR:InvAbrir", player)
			return
		end


		if item["funcao"] == "Armas" then
			if tonumber(quantidade) > 1 then
				exports.cmr_dxmessages:outputDx(player, "Você não pode equipar mais de um item!", "error")
				return
			end
			if tonumber(item["quantidade"] or 0) < tonumber(quantidade) then
				exports.cmr_dxmessages:outputDx(player, "Você não tem essa quantidade!", "error")
				return
			end
			local balaID
			for a, data in ipairs(ArmasAndBalas) do
				if tonumber(data[1]) == tonumber(item["iditem"]) then
					balaID = tostring(data[2])
				end
			end
			local dataInfEquipado = CMR_InvSearchItemsStatusDB(getAccountName(getPlayerAccount(player)), "Equipado")
			if dataInfEquipado then
				for i, dat in ipairs(dataInfEquipado) do
					if dat["iditem"] == item["iditem"] then
						if item["funcao"] == "Armas" then
							local SearchBala = CMR_InvSearchStatusDB(balaID, getAccountName(getPlayerAccount(player)))
							if SearchBala then
								for i, b in ipairs(SearchBala) do
									if tonumber(balaID) then
										CMR_InvUpdStatusDB(b["iditem"], "Guardado", getAccountName(getPlayerAccount(player)))
									end
								end
							end
							CMR_InvUpdStatusDB(dat["iditem"], "Guardado", getAccountName(getPlayerAccount(player)))
							CMR_InvCarregarItemsEquipado(player)
							for slot = 0, 12 do
								local Armas = getPedWeapon(player, slot)
								local Municao = getPedTotalAmmo(player, slot)
								if Armas > 0 then
									if Municao > 0 then
										takeWeapon(player, Armas)
									end
								end
							end
							return
						end
						return
					end
					if tostring(balaID) ~= dat["iditem"] then
						if dat["iditem"] ~= item["iditem"] then
							exports.cmr_dxmessages:outputDx(player, "Você já tem uma arma equipada!", "error")
							return
						end
					end
				end
			end
			local SearchBala = CMR_InvSearchDB(balaID, getAccountName(getPlayerAccount(player)))
			if SearchBala then
				for i, b in ipairs(SearchBala) do
					if b["iditem"] then
						CMR_InvUpdStatusDB(b["iditem"], "Equipado", getAccountName(getPlayerAccount(player)))
						CMR_InvUpdStatusDB(item["iditem"], "Equipado", getAccountName(getPlayerAccount(player)))
						CMR_InvCarregarItemsEquipado(player)
						giveWeapon(player, tonumber(item["valor"]), 999999)
						exports.cmr_dxmessages:outputDx(player, "Arma equipada com sucesso!", "success")
						return
					end
				end
				exports.cmr_dxmessages:outputDx(player, "Você não tem balas para equipar a arma!", "error")
				return
			else
				exports.cmr_dxmessages:outputDx(player, "Você não tem balas para equipar a arma!", "error")
				return
			end
		end
	end
end
addEvent("CMR:InvEquiparItem", true)
addEventHandler("CMR:InvEquiparItem", root, CMR_InvEquiparItem)

function CMR_InvEnviarItem(player, item, quantidade)
	if item then
		if not quantidade then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if quantidade == 0 then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if tonumber(quantidade) <= 0 then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if not tonumber(quantidade) then
			exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
			return
		end
		if tonumber(item["quantidade"] or 0) < tonumber(quantidade) then
			exports.cmr_dxmessages:outputDx(player, "Você não tem essa quantidade!", "error")
			return
		end


		if tostring(item["tipo"]) == "Comida" then
			if isPedInVehicle(player) then
				exports.cmr_dxmessages:outputDx(player, "Você não pode enviar do veículo!", "error")
				return
			end
			local px, py, pz = getElementPosition(player)
			local enviarPara = nil
			for i, a in ipairs(getElementsByType("player")) do
				if not isGuestAccount(getPlayerAccount(a)) then
					if player ~= a then
						local ax, ay, az = getElementPosition(a)
						if getDistanceBetweenPoints3D(ax, ay, az, px, py, pz) <= 1.7 then
							enviarPara = a
							break
						end
					end
				end
			end

			if not isElement(enviarPara) then
				exports.cmr_dxmessages:outputDx(player, "Chegue mais perto!", "error")
				return
			end
			CMR_EnviarItemInv(player, item, quantidade, enviarPara)
			triggerClientEvent(player, "CMR:InvAbrir", player)
			return
		end

		if tostring(item["tipo"]) == "Utensilhos" then
			if isPedInVehicle(player) then
				exports.cmr_dxmessages:outputDx(player, "Você não pode enviar do veículo!", "error")
				return
			end
			local px, py, pz = getElementPosition(player)
			local enviarPara = nil
			for i, a in ipairs(getElementsByType("player")) do
				if not isGuestAccount(getPlayerAccount(a)) then
					if player ~= a then
						local ax, ay, az = getElementPosition(a)
						if getDistanceBetweenPoints3D(ax, ay, az, px, py, pz) <= 1.7 then
							enviarPara = a
							break
						end
					end
				end
			end

			if not isElement(enviarPara) then
				exports.cmr_dxmessages:outputDx(player, "Chegue mais perto!", "error")
				return
			end
			for i, b in ipairs(CMR_InvSearchItemsStatusDB(getAccountName(getPlayerAccount(player)), "Equipado")) do
				CMR_InvUpdStatusDB(b["iditem"], "Guardado", getAccountName(getPlayerAccount(player)))
			end
			for slot = 0, 12 do
				local Armas = getPedWeapon(player, slot)
				local Municao = getPedTotalAmmo(player, slot)
				if Armas > 0 then
					if Municao > 0 then
						takeWeapon(player, Armas)
					end
				end
			end
			CMR_EnviarItemInv(player, item, quantidade, enviarPara)
			triggerClientEvent(player, "CMR:InvAbrir", player)
			return
		end

	else
		exports.cmr_dxmessages:outputDx(player, "Item selecionado não e valído!", "error")
	end
end
addEvent("CMR:InvEnviarItem", true)
addEventHandler("CMR:InvEnviarItem", root, CMR_InvEnviarItem)

function CMR_EnviarItemInv(player, item, quantidade, enviarPara)
	setPedAnimation(player,"DEALER","DEALER_DEAL",3000,false,false,false,false)
	setPedAnimation(enviarPara,"DEALER","DEALER_DEAL",3000,false,false,false,false)
	local IdShop = item["iditem"]
	local ValorUseItem = item["valor"]
	local tipo = item["tipo"]
	local funcao = item["funcao"]
	local position = 0
	if tonumber(quantidade) <= 0 then
		exports.cmr_dxmessages:outputDx(player, "Você precisa colocar a quantidade!", "error")
		return
	end

	local verificarItem = CMR_InvProcurarItem(getAccountName(getPlayerAccount(enviarPara)), IdShop)
	if verificarItem then
		if #verificarItem > 0 then
			for i, row in ipairs(verificarItem) do
				CMR_InvUpdItemsDB(tonumber(tonumber(row["quantidade"]) + tonumber(quantidade)), getAccountName(getPlayerAccount(enviarPara)), IdShop)
				exports.cmr_dxmessages:outputDx(enviarPara, "Você recebeu algum item!", "info")
				exports.cmr_dxmessages:outputDx(player, "Você enviou algum item!", "info")
				if tipo == "Utensilhos" then
					CMR_InvUpdStatusDB(IdShop, "Guardado", getAccountName(getPlayerAccount(enviarPara)))
				end
				CMR_RemoveMochilaItem(player, item, quantidade)
				CMR_InvCarregarItemsEquipado(player)
				CMR_InvCarregarItems(player)
				CMR_InvCarregarItemsEquipado(enviarPara)
				CMR_InvCarregarItems(enviarPara)
				return
			end
		end
	end
	local UltItemDados = CMR_InvUltItem(getAccountName(getPlayerAccount(enviarPara)))
	if UltItemDados then
		if #UltItemDados > 0 then
			for i, row in ipairs(UltItemDados) do
				if tonumber(row["posicao"]) > 32 then
					exports.cmr_dxmessages:outputDx(enviarPara, "Seu inventario esta cheio!", "error")
					return
				end
			end
		end
		for i, row in ipairs(UltItemDados) do
			position = tonumber(row["posicao"])
		end
	end
	CMR_InvAddItemsDB(tonumber(quantidade), ValorUseItem, getAccountName(getPlayerAccount(enviarPara)), IdShop, tipo, funcao, position)
	exports.cmr_dxmessages:outputDx(enviarPara, "Você recebeu algum item!", "info")
	exports.cmr_dxmessages:outputDx(player, "Você enviou algum item!", "info")
	CMR_RemoveMochilaItem(player, item, quantidade)
	CMR_InvCarregarItemsEquipado(player)
	CMR_InvCarregarItems(player)
	CMR_InvCarregarItemsEquipado(enviarPara)
	CMR_InvCarregarItems(enviarPara)
	if tipo == "Utensilhos" then
		CMR_InvUpdStatusDB(IdShop, "Guardado", getAccountName(getPlayerAccount(enviarPara)))
	end
	return
end

function CMR_InvComerItem(player, item, quantidade)
	for i, item_Edit in ipairs(items) do
		if tonumber(item_Edit[3]) == tonumber(item["iditem"]) then
			CMR_RemoveMochilaItem(player, item, quantidade)
			CMR_attachItemPlayer(player, 2703)
			setPedAnimation(player, "food", "eat_burger", 4000, false, false, false, false)
			hunger = getElementData(player, "hunger") or 0
			addHunger = tonumber(item["valor"]) * tonumber(quantidade)
			tmp = tonumber(3000)
			if addHunger+hunger > 100 then
				TotalHunger =  100
			else
				TotalHunger = addHunger+hunger
			end
			setTimer(CMR_detachItemPlayer, 4000, 1, player)
			setTimer(setElementData, tmp, 1, player, "hunger", TotalHunger)
		end
	end
end

function CMR_InvBeberItem(player, item, quantidade)
	for i, item_Edit in ipairs(items) do
		if tonumber(item_Edit[3]) == tonumber(item["iditem"]) then
			CMR_RemoveMochilaItem(player, item, quantidade)
			CMR_attachItemPlayer(player, 1546)
			setPedAnimation(player, "VENDING", "vend_drink2_p", 4000,false,false,false,false)
			sede = getElementData(player, "sede") or 0
			addsede = tonumber(item["valor"]) * tonumber(quantidade)
			tmp = tonumber(3000)
			if addsede+sede > 100 then
				TotalSede =  100
			else
				TotalSede = addsede+sede
			end
			setTimer(CMR_detachItemPlayer, 4000, 1, player)
			setTimer(setElementData, tmp, 1, player, "sede", TotalSede)
		end
	end
end

function CMR_RemoveMochilaItem(source, item, quantidade)
	if item["quantidade"] == quantidade then
		CMR_DBExecutDel("cmr_items WHERE iditem = '"..item["iditem"].."' AND user = '"..getAccountName(getPlayerAccount(source)).."' ")
		if item["tipo"] == "Utensilhos" then
			CMR_InvDeleteStatusDB(item["iditem"], getAccountName(getPlayerAccount(source)))
		end
		CMR_DBAtualizaLocalItens(getAccountName(getPlayerAccount(source)))
	else
		CMR_DBExecutUpdate("cmr_items SET quantidade='"..tostring(tonumber(item["quantidade"] - quantidade)).."' WHERE user='"..getAccountName(getPlayerAccount(source)).."' and iditem = '"..item["iditem"].."'")
	end
end
addEvent("CMR:RemoveMochilaItem", true)
addEventHandler("CMR:RemoveMochilaItem", root, CMR_RemoveMochilaItem)

function CMR_TirarItemInv(source, item, quantidade)
	local itemInfoData = CMR_InvProcurarItem(getAccountName(getPlayerAccount(source)), item)
	if not itemInfoData then
		return
	end

	for a, itemInfo in ipairs(itemInfoData) do
		if itemInfo["quantidade"] == quantidade then
			CMR_DBExecutDel("cmr_items WHERE iditem = '"..itemInfo["iditem"].."' AND user = '"..getAccountName(getPlayerAccount(source)).."' ")
			if itemInfo["tipo"] == "Utensilhos" then
				CMR_InvDeleteStatusDB(item, getAccountName(getPlayerAccount(source)))
			end
			CMR_DBAtualizaLocalItens(getAccountName(getPlayerAccount(source)))
		else
			CMR_DBExecutUpdate("cmr_items SET quantidade='"..tostring(tonumber(itemInfo["quantidade"] - quantidade)).."' WHERE user='"..getAccountName(getPlayerAccount(source)).."' and iditem = '"..itemInfo["iditem"].."'")
		end
	end
end
addEvent("CMR:TirarItemInv", true)
addEventHandler("CMR:TirarItemInv", root, CMR_TirarItemInv)

function CMR_GiveItemVehicle(player, item, quantidade)
	local IdShop = item["iditem"]
	local ValorUseItem = item["valor"]
	local tipo = item["tipo"]
	local funcao = item["funcao"]
	local position

	verificarItem = CMR_InvProcurarItem( getAccountName(getPlayerAccount(player)), IdShop)
	if #verificarItem > 0 then
		for i, row in ipairs(verificarItem) do
			CMR_InvUpdItemsDB(tonumber(tonumber(row["quantidade"]) + tonumber(quantidade)),  getAccountName(getPlayerAccount(player)), IdShop)
			exports.cmr_dxmessages:outputDx(player, "Item retirado com sucesso!", "success")
			return
		end
	else
		UltItemDados = CMR_InvUltItem(getAccountName(getPlayerAccount(player)))
		if #UltItemDados > 0 then
			for i, row in ipairs(UltItemDados) do
				if tonumber(row["posicao"]) > 32 then
					exports.cmr_dxmessages:outputDx(player, "Seu inventario esta cheio!", "error")
					return
				end
			end
		end
		position = 0
		for i, row in ipairs(UltItemDados) do
			position = tonumber(row["posicao"])
		end
		CMR_InvAddItemsDB(tonumber(quantidade), ValorUseItem,  getAccountName(getPlayerAccount(player)), IdShop, tipo, funcao, position)
		exports.cmr_dxmessages:outputDx(player, "Item retirado com sucesso!", "success")
		return
	end

end
addEvent("CMR:GiveItemVehicle", true)
addEventHandler("CMR:GiveItemVehicle", root, CMR_GiveItemVehicle)

--------------------------------------------
----------------BONE ATTACH-----------------
--------------------------------------------

function CMR_attachItemPlayer(playerSource, objID)
	itemObjs[playerSource] = createObject(objID,0,0,0)
	if objID == 2703 then
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,12,0,0.08,0.08,180,0)
	elseif objID == 2769 then
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,12,0,0.05,0.08,0,0)
	elseif objID == 2702 then
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,12,0,0.12,0.08,180,90,180)
	elseif objID == 1546 then
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,11,0,0.05,0.08,90,0,90)
	elseif objID == 2647 then
		setObjectScale(itemObjs[playerSource],0.6)
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,11,0,0.05,0.08,90,0,90)
	elseif objID == 1509 then
		setObjectScale(itemObjs[playerSource],0.8)
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,11,0,0.05,0.08,90,0,90)
	elseif objID == 1664 then
		exports.bone_attach:attachElementToBone(itemObjs[playerSource],playerSource,11,0,0.05,0.08,90,0,90)
	end
end
addEvent("CMR:attachItemPlayer",true)
addEventHandler("CMR:attachItemPlayer", root, CMR_attachItemPlayer)



function CMR_detachItemPlayer(playerSource)
	exports.bone_attach:detachElementFromBone(itemObjs[playerSource])
	destroyElement(itemObjs[playerSource])
	itemObjs[playerSource] = false
end
addEvent("CMR:detachItemPlayer", true)
addEventHandler("CMR:detachItemPlayer", root, CMR_detachItemPlayer)


function CMR_Bag_Carrega_all(res)
	if res == getThisResource() then
		--setTimer(CMR_Bag_Atualiza, 1000, 0)
	end
end
addEventHandler("onResourceStart", root, CMR_Bag_Carrega_all)


function CMR_BagDestroy(res)
	if res == getThisResource() then
		--setTimer(CMR_Bag_Atualiza, 1000, 0)
	end
end

function CMR_Bag_Atualiza()
	for i, a in ipairs(getElementsByType("player")) do
		local verifiGuest =  getPlayerAccount(a)
		if not isGuestAccount(verifiGuest) then
			acc = getAccountName(getPlayerAccount(a))
			ListItems = CMR_InvCarregarUtensilhosDB(acc)
			if #ListItems >= 1 then
				CMR_Bag_Carrega_User(a)
			else
				CMR_Bag_Destroy(a)
			end
		end
	end
end


function CMR_Bag_Carrega_User(player)
	if not isElement(bag[player]) then
		acc = getAccountName(getPlayerAccount(player))
		ListItems = CMR_InvCarregarItemsDB(acc)
		--[[if #ListItems >= 1 then
			bag[player] = createObject(3102, 0, 0, 0)
			exports.pattach:attach(bag[player],player, "backpack", 0, -0.16, 0.07, 90, 0, 0)
		end]]--
	end
end

function CMR_Bag_Carrega()
	if not isElement(bag[source]) then
		acc = getAccountName(getPlayerAccount(source))
		ListItems = CMR_InvCarregarItemsDB(acc)
		--[[if #ListItems >= 1 then
			bag[source] = createObject(3102, 0, 0, 0)
			exports.pattach:attach(bag[source],source, "backpack", 0, -0.16, 0.07, 90, 0, 0)
		end]]--
	end
end
addEventHandler("onPlayerJoin", root, CMR_Bag_Carrega)

function CMR_Bag_Destroy(player)
	if isElement(bag[player]) then
		destroyElement(bag[player])
		if isTimer(timer[player]) then
			killTimer(timer[player])
		end
	end
end

function CMR_Bag_Destroy0()
	if isElement(bag[source]) then
		destroyElement(bag[source])
		if isTimer(timer[source]) then
			killTimer(timer[source])
		end
	end
end
addEventHandler("onPlayerQuit", root, CMR_Bag_Destroy0)

--------------------------------------------
addEventHandler("onPlayerJoin", getRootElement(), function()
	bindKey(source, "b", "down", CMR_S_Abrir)
end)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function() 
	for index,player in pairs(getElementsByType("player")) do 
		bindKey(player, "b", "down", CMR_S_Abrir)
	end
end)

