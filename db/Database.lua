------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	-----	INVENTARIO BRP		-----
------------------------------------------

function CMR_Connect(res)
	if res == getThisResource() then
	    DBConnection = dbConnect("sqlite", "sqlite.db")
	    if (not DBConnection) then
	        outputDebugString("Error: Falha ao se conectar com banco de dados - Inventario")
	    else
	        outputDebugString("Success: Banco de Dados Conectado com Sucesso - Inventario")
	    end
	end
end
addEventHandler("onResourceStart", root, CMR_Connect)

function CMR_InvCarregarItemsDB(acc)
	if acc then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE user='"..acc.."' and tipo='Comida' or user='"..acc.."'  and tipo='Utensilhos'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvCarregarUtensilhosDB(acc)
	if acc then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE user='"..acc.."' and tipo='Utensilhos'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvCarregarChaveDB(acc)
	if acc then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE user='"..acc.."' and tipo='Chave'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvCarregarDocumentosDB(acc)
	if acc then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE user='"..acc.."' and tipo='Documento'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvUltItem(acc)
	if acc then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE user='"..acc.."' and tipo='Comida' or user='"..acc.."'  and tipo='Utensilhos' ORDER BY id DESC LIMIT 1")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvProcurarItem(acc, idItem)
	if acc and idItem then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE user='"..acc.."' and iditem='"..idItem.."' ORDER BY id DESC LIMIT 1")
		return dbPoll(Items, -1)
	end
end

function CMR_InvAddItemsDB(quantidade, ValorUseItem, acc, IdShop, tipo, funcao, pos)
	if quantidade and ValorUseItem and acc and IdShop and tipo and funcao and pos then
		dbExec(DBConnection, "INSERT INTO cmr_items VALUES (NULL, '"..tostring(tonumber(pos+1)).."', '"..tostring(quantidade).."', '"..ValorUseItem.."', '"..acc.."', '"..IdShop.."', '"..tipo.."', '"..funcao.."')")
		return
	end
end

function CMR_InvUpdItemsDB(quantidade, acc, IdShops)
	if quantidade and acc and IdShops then
		dbExec(DBConnection, "UPDATE cmr_items SET quantidade='"..tostring(quantidade).."', iditem='"..tostring(IdShops).."' WHERE iditem='"..tostring(IdShops).."' and user='"..tostring(acc).."'")
		return
	end
end

function CMR_DBExecutDel(funcao)
	if funcao then
		dbExec(DBConnection, "DELETE FROM "..funcao)
	end
end

function CMR_DBExecutUpdate(funcao)
	if funcao then
		dbExec(DBConnection, "UPDATE "..funcao)
	end
end

function CMR_DBAtualizaLocalItens(acc)
	if acc then
		List = CMR_InvCarregarItemsDB(acc)
		for i, row in ipairs(List) do
			if i ~= row["posicao"] then
				dbExec(DBConnection, "UPDATE cmr_items SET posicao='"..tostring(i).."' WHERE iditem = '"..row["iditem"].."' AND user = '"..acc.."'")
			end
		end

	end
end

function CMR_InvSearchItemsStatusDB(user, status)
	if user and status then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_status WHERE user = '"..user.."' and status = '"..status.."'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvSearchDB(idItem, user)
	if idItem and user then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_items WHERE iditem='"..idItem.."' and user = '"..user.."'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvSearchStatusDB(idItem, user)
	if idItem and user then
		Items = dbQuery(DBConnection, "SELECT * FROM cmr_status WHERE iditem='"..idItem.."' and user = '"..user.."'")
		return dbPoll(Items, -1)
	end 
end

function CMR_InvUpdStatusDB(idItem, status, user)
	if idItem and status and user then
		local VerificarExistente = CMR_InvSearchStatusDB(tonumber(idItem), user)
		if #VerificarExistente > 0 then
			dbExec(DBConnection, "UPDATE cmr_status SET status='"..tostring(status).."' WHERE iditem = '"..idItem.."' AND user = '"..user.."'")
			return
		else
			dbExec(DBConnection, "INSERT INTO cmr_status VALUES (NULL, '"..idItem.."', '"..status.."', '"..user.."')")
			return
		end
	end
end

function CMR_InvDeleteStatusDB(idItem, user)
	if idItem and user then
		dbExec(DBConnection, "DELETE FROM cmr_status WHERE iditem='"..idItem.."' and user = '"..user.."'")
		return
	end
end