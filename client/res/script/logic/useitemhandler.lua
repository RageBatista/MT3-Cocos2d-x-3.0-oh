require "utils.log"
require "logic.workshop.workshoplabel"
require "logic.pet.petlabel"
UseItemHandler = {}

local function IsQhMaterial(itembaseid)
	if itembaseid == 38006 or itembaseid == 38007 or itembaseid == 38008 then
		return true
	end
	if itembaseid == 37172 or itembaseid == 37173 or itembaseid == 37174 then
		return true
	end
	return false
end

local function useMsItem()
	local curMapid = gGetScene():GetMapInfo()
	if curMapid ~= 1401 then
		UseItemHandler.useMsItemCo = coroutine.create(function()
			local NPCID = 12014
			local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(NPCID);
	    	if not npcConfig then
	       	 	return false
	       	end
			GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, NPCID)
		end)
		return true
	else 
		UseItemHandler.useMsItemCo = nil
		local NPCID = 12014
		local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(NPCID);
    	if not npcConfig then
       	 	return false
       	end
		GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, NPCID)
		return true
	end
	return false
end

function UseItemHandler.useFunctionItems(itemid)
  return nil
end

function UseItemHandler.useItem(bagid, itemkey)
	LogInsane(string.format("bagid=%d, itemkey=%d", bagid, itemkey))
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:FindItemByBagAndThisID(itemkey, bagid)
	if item == nil then
		return false
	end
	local itembaseid = item:GetBaseObject().id
	local firsttype = item:GetBaseObject().itemtypeid%16
	LogInsane("type"..item:GetBaseObject().itemtypeid.."first type="..firsttype)
	
	if itembaseid >= 37511 and itembaseid <= 37516 then
	  require "protodef.fire.pb.marry.cringinfo"
    local p = CRingInfo.Create()
    require "manager.luaprotocolmanager":send(p)
	 return true
	end
	
	--special use function items
	local spItem = UseItemHandler.useFunctionItems(itembaseid)
	if spItem ~= nil then
		if spItem.type == 0 then
			GetCTipsManager():AddMessageTip(spItem.prompt);
		end
		if spItem.type == 1 then
			if GetTeamManager() and not GetTeamManager():CanIMove() then
				if GetChatManager() then GetChatManager():AddTipsMsg(150030) end --处于组队状态，无法传送
				return true
			end
			local cmd = fire.pb.mission.CReqGoto(spItem.mapID, spItem.PosX, spItem.PosZ);
			gGetNetConnection():send(cmd);
		end
		return true
	end
	
	if item:GetBaseObject().itemtypeid == 2198 then
		GetCTipsManager():AddMessageTipById(144920);
	end

	if firsttype == 5 then
        WorkshopLabel.Show(2)
		return true
	elseif item:GetBaseObject().itemtypeid%0x100 == 0x87 then
		local childtype = math.floor(item:GetBaseObject().itemtypeid/0x100)%0x10
		if childtype == 1 or childtype == 2 then
			return true
		elseif childtype == 3 then
			return true
		end
	elseif itembaseid == 35195 or itembaseid == 35196 or itembaseid == 35197 then
        WorkshopLabel.Show(2)
		return true
	elseif IsQhMaterial(itembaseid) then
		WorkshopLabel.Show(1)
		return true
	elseif itembaseid == 38005 then
		PetLabel.Show(3)
		return true
	elseif itembaseid == 50002 or itembaseid == 50015 then
		local NPCID = 10271
		local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(NPCID);
    	if not npcConfig then
       	 	return false
       	end
    	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, NPCID)
    	return true
    elseif itembaseid == 38609 then
   		return useMsItem()
	elseif itembaseid == 50312 then

	end
	LogInsane("Not handlered")
	return false
end

return UseItemHandler
