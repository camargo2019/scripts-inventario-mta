------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	   -----	LOJA BRP		-----
------------------------------------------


function CMR_ComprarItem(item, quantidade, LojaC)
	if not quantidade then
		exports.cmr_dxmessages:outputDx(source, "Você precisa colocar a quantidade!", "error")
		return
	end
	if quantidade == 0 then
		exports.cmr_dxmessages:outputDx(source, "Você precisa colocar a quantidade!", "error")
		return
	end
	if not tonumber(quantidade) then
		exports.cmr_dxmessages:outputDx(source, "Você precisa colocar a quantidade!", "error")
		return
	end
	if tonumber(quantidade) <= 0 then
		exports.cmr_dxmessages:outputDx(source, "Você precisa colocar a quantidade!", "error")
		return
	end

	local ValorPlayer = getPlayerMoney(source)
	local IdShop
	local NomeItem
	local ValorItem
	local ValorUseItem
	local tipo
	local funcao
	local position

	for i, shop in ipairs(Lojas) do
		if LojasTipo[LojaC[4]] then
			for o, itemS in ipairs(LojasTipo[LojaC[4]]) do
				for a, itemShop in ipairs(items) do
					if o == item then
						if itemS[1] == itemShop[3] then
							IdShop = tonumber(itemShop[3])
							NomeItem = tonumber(itemShop[1])
							ValorUseItem = tonumber(itemShop[2])
							ValorItem = tonumber(itemS[2])
							tipo = tostring(itemShop[4])
							funcao = tostring(itemShop[5])
						end
					end
				end
			end
		end 
	end

	if tonumber(tonumber(ValorItem) * tonumber(quantidade)) > ValorPlayer then
		exports.cmr_dxmessages:outputDx(source, "Você não tem dinheiro suficiente!", "error")
		return
	end
	verificarItem = CMR_InvProcurarItem(getAccountName(getPlayerAccount(source)), IdShop)
	if #verificarItem > 0 then
		for i, row in ipairs(verificarItem) do
			takePlayerMoney(source, tonumber(tonumber(ValorItem) * tonumber(quantidade)))
			CMR_InvUpdItemsDB(tonumber(tonumber(row["quantidade"]) + tonumber(quantidade)), getAccountName(getPlayerAccount(source)), IdShop)
			--if tipo == "Utensilhos" then
			--	CMR_InvUpdStatusDB(IdShop, "Guardado", getAccountName(getPlayerAccount(source)))
			--end
			exports.cmr_dxmessages:outputDx(source, "Item adquirido com sucesso!", "success")
			triggerClientEvent(source, "CMR:LojaAbrir", source)
			return
		end
	else
		UltItemDados = CMR_InvUltItem(getAccountName(getPlayerAccount(source)))
		if #UltItemDados > 0 then
			for i, row in ipairs(UltItemDados) do
				if tonumber(row["posicao"]) > 32 then
					exports.cmr_dxmessages:outputDx(source, "Seu inventario esta cheio!", "error")
					return
				end
			end
		end
		position = 0
		for i, row in ipairs(UltItemDados) do
			position = tonumber(row["posicao"])
		end
		--if tipo == "Utensilhos" then
		--	CMR_InvUpdStatusDB(IdShop, "Guardado", getAccountName(getPlayerAccount(source)))
		--end
		takePlayerMoney(source, tonumber(tonumber(ValorItem) * tonumber(quantidade)))
		CMR_InvAddItemsDB(tonumber(quantidade), ValorUseItem, getAccountName(getPlayerAccount(source)), IdShop, tipo, funcao, position)
		exports.cmr_dxmessages:outputDx(source, "Item adquirido com sucesso!", "success")
		triggerClientEvent(source, "CMR:LojaAbrir", source)
		return
	end

end
addEvent("CMR:ComprarItem", true)
addEventHandler("CMR:ComprarItem", root, CMR_ComprarItem)
