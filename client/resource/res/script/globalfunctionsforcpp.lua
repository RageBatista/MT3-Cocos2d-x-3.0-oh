local JEWELRY = 6
local TEAMGUIDE = 0
local ISLOCK = 0
local function add_element(tab, k, v)
	tab[k] = tab[k] and tab[k] + v or v
end
local function GetScoreConfigIndex(equiptype)
    if equiptype >= 0 and equiptype <= JEWELRY then
        return equiptype
    end
    return -1
end

local function GetSecondType(typeid)
	local n = math.floor(typeid / 0x10)
	return n % 0x10
end

local function GetWeight(effectid, secondtype, weightid) 
--    assert(weightid >= 0);
--    local scoreConfig = GameTable.item.GetCEquipScoreConfigTableInstance():getRecorder(effectid)
--    if scoreConfig.id == -1 then
--        return 0
--    end
--    local idx = GetScoreConfigIndex(secondtype);
--    if idx == -1 or idx >= scoreConfig.effectscore:size() then
--        return 0
--    end
--    local weights = scoreConfig.effectscore[secondtype]
--    for i = 1, weightid do
--    	local startIdx = string.find(weights, ";")
--    	assert(startIdx)
--    	weights = string.sub(weights, startIdx + 1)
--    end
--    local endIdx = string.find(weights, ";")
--    return tonumber(endIdx and string.sub(weights, 0, endIdx - 1) or weights)
    return 0
end
local function getResult(cfg, type)
	if not cfg then
		return
	end
	if type == 0 then
		return cfg.wuqi
	elseif type == 1 then
		return cfg.huwan
	elseif type == 2 then
		return cfg.xianglian
	elseif type == 3 then
		return cfg.yifu
	elseif type == 4 then
		return cfg.yaodai
	elseif type == 5 then
		return cfg.xiezi
	end
end

local function GetSchoolBuff(attrid, schoolid)
--	local schoolid = schoolid or gGetDataManager():GetMainCharacterSchoolID()
--	local cfg = GameTable.item.GetCjewelryshuxingbuffTableInstance():getRecorder( attrid)
--	if not cfg then
--		return 1
--	end
--	if schoolid == 11 then
--		return cfg.gumu / 100
--	elseif schoolid == 12 then
--		return cfg.gaibang / 100
--	elseif schoolid == 14 then
--		return cfg.baituo / 100
--	elseif schoolid == 15 then
--		return cfg.dali / 100
--	elseif schoolid == 17 then
--		return cfg.taohua / 100
--	end
	return 1
end

local function GetJewelryEquipScore(itemid, pobj, schoolid)
	local score = 0
--	for i = 1, #pobj.props do
--		local dvalue = pobj.props[i]
--		local cfg = GameTable.item.GetCjewelryshuxingTableInstance():getRecorder( dvalue.propkey)
--    	if cfg then
--    		local value = cfg.value[dvalue.level - 1]
--    		value = value * GetSchoolBuff(dvalue.propkey, schoolid)
--            if cfg.baifenbi == 1 then
--                value = value / 10000
--            end
--    		score = score + value * GetWeight(dvalue.propkey, JEWELRY, 3)
--    	end
--	end
	score = math.floor(score/100)
	return score
end

function GetLuaEquipScore(itemid, pobj, secondtype, schoolid)
	if secondtype == JEWELRY then
    	return GetJewelryEquipScore(itemid, pobj, schoolid)
    end
	local score = 0
	local equipColor = 0
    local equipConfig = GameTable.item.GetCEquipEffectTableInstance():getRecorder(itemid)
    if equipConfig.id ~= -1 then
        equipColor = equipConfig.equipcolor;
    end
    local realattr = {}
    -- cal baseeffect
    local equip = GameTable.item.GetCEquipEffectTableInstance():getRecorder(itemid)
	for i = 0, equip.baseEffect:size() - 1 do
		add_element(realattr, equip.baseEffectType[i], equip.baseEffect[i])
	end
    -- cal diamonds
    local gemlist = pobj.gemlist
    for i = 1, #gemlist do
    	local gemid = gemlist[i]
    	local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(gemid)
		if gemconfig then
			for j= 0, gemconfig.effecttype:size() - 1 do
				add_element(realattr, gemconfig.effecttype[j], gemconfig.effect[j])
			end
		end
    end

	for k, v in pairs(realattr) do
		score = score + v * GetWeight(k, secondtype, 0)
		score = score + (equipColor + 1) * v  * GetWeight(k, secondtype, 1)/100;
	end
	score = math.floor(score / 100)
	return score
end
function GetEquipScore(bagid, itemkey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(itemkey, bagid)
	if not pItem then
		return 0
	end
	if pItem:GetItemTypeID() % 0x10 ~= eItemType_EQUIP then
		return 0
	end
	
	local itemid = pItem:GetBaseObject().id
    return GetLuaEquipScore(itemid, pobj, GetSecondType(pItem:GetItemTypeID()))
end




--@return 1表示脚本已处理，不再在c++里发送试用协议，返回0则c++继续处理
function _HandleUseItem(bagid, typeid, itemid, itemkey)
	if bagid == fire.pb.item.BagTypes.BAG or bagid==8 then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local pItem = roleItemManager:FindItemByBagAndThisID(itemkey, bagid)
		--宠物护身符
		if typeid == 161 then
			local petnum = MainPetDataManager.getInstance():GetPetNum()
			if petnum == 0 then 
				GetCTipsManager():AddMessageTipById(143586) --你当前没有设定参战宠物，无法使用该宠物道具。
				return 1
			end
			return 1
		end
	end
	return 0
end

--@return 1表示脚本已处理，不再在c++里发送试用协议
function LuaUseItem(itemid, typeid, bagid, itemkey, nouse)
	print("LuaUseItem "..tostring(itemid).." "..tostring(typeid))
	if bagid == fire.pb.item.BagTypes.BAG or bagid==8 then
		local ret = _HandleUseItem(bagid, typeid, itemid, itemkey)
		--坐骑道具
		if typeid == ITEM_TYPE.HORSE and ret == 0 then
			local mainPack = CMainPackDlg:GetSingleton()
			if mainPack then
				mainPack:DestroyDialog()
			else
				local depot = require("logic.item.depot"):getInstanceOrNot()
				if depot then
					depot:DestroyDialog()
				end
			end
		end
        if typeid>=501 and typeid<=506 then
            local destpos= typeid-479
            require "protodef.fire.pb.item.cputonequip"
            local equipement = CPutOnEquip.Create()
            equipement.packkey = itemkey
            equipement.dstpos =destpos
            LuaProtocolManager.getInstance():send(equipement)
        end
		return ret
	end
   
	return 0
end

function LuaAddSenceNpc(npcbaseid, npcid)
	if npcbaseid == 12198 or npcbaseid == 12199 or npcbaseid == 12448 then
		local CShouxiShape = require "protodef.fire.pb.school.cshouxishape"
		local req = CShouxiShape.Create()
		req.shouxikey = npcid
		LuaProtocolManager.getInstance():send(req)
	end
end

function QuickBagFunction()
  local p = require "protodef.fire.pb.item.copenpack".new()
  p.packid = fire.pb.item.BagTypes.BAG
  require "manager.luaprotocolmanager":send(p)
  --local dlg = require "logic.item.depot":GetSingletonDialogAndShowIt()
end
local function GetQuickBagBtn()
  local winMgr = CEGUI.WindowManager:getSingleton()
  if winMgr:isWindowPresent("MainPackDlg/tidy3") then
    return CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy3"))
  end
end
function LuaNotifyMainPackDlgCreated()
  local btn = GetQuickBagBtn()
  if btn then
    btn:subscribeEvent("Clicked", QuickBagFunction)
  end

  require("logic.item.mainpackhelper").OnCreateEnd()
end

function LuaNotifyMainPackDlgDestory()
  --local btn = GetQuickBagBtn()

  require("logic.item.mainpackhelper").DestroyEnd()
end

--//bag call 
function LuaShowItemTip(nBagId, nItemKey,nCellPosX,nCellPosY)
	LogInfo("LuaShowItemTip(pItem,nItemId,nCellPosX,nCellPosY)")

	local nLuaHandle = 1
	local nCHandle = 0
	
	
	local bLuaHandleSuccess =  require "logic.tips.commontipdlg".LuaShowItemTip(nBagId,nItemKey,nCellPosX,nCellPosY)
	if bLuaHandleSuccess then
		return nLuaHandle
	end
	
	
	return nCHandle
end


function  LuaShowItemTipWithBaseId(nItemId,nCellPosX,nCellPosY,nParam)
   require "logic.tips.commontipdlg".LuaShowItemTipWithBaseId(nItemId,nCellPosX,nCellPosY)
end

function LuaRecvPetTipsData(pet, tipstype)
	local petData = pet
	if tipstype == PETTIPS_T.STALL_DOWN_SHELF then
		local dlg = require("logic.shop.stallpetupshelf").getInstanceNotCreate()
		if dlg then
			dlg:refreshPetData(petData)
		end
		
	elseif tipstype == PETTIPS_T.STALL_PET_TIP then
		local dlg = require("logic.shop.stallpettip").getInstanceNotCreate()
		if dlg then
			dlg:refreshPetData(petData)
		end
		
	elseif tipstype == PETTIPS_T.PET_DETAIL then
		local dlg = require("logic.pet.petdetaildlg").getInstanceNotCreate()
		if dlg and ((dlg.tmpKey and dlg.tmpKey == petData.key) or not dlg.tmpKey) then
			dlg:refreshPetData(petData)
		end
		
	elseif tipstype == 5 then --为了稳定先暂时用这个协议，不加新协议了过24号要改下 by changhao
	
		local dlg = require("logic.pet.petdetaildlg").getInstanceAndShow()
		if dlg then
			dlg.petKey = petData.key;
			dlg:refreshPetData(petData)
			dlg.ShowPetDlg(petData.baseid, dlg.petKey, petData.ownerid);
		end	
	
	end
end

function getVisitNpcDis(nParam1,nParam2,nParam3,nParam4)

    local nRand = 3 + math.random(0,3)
    return nRand
end

function setItemCellBind(itemCell,nBind,nParam3,nParam4)
    if not itemCell then
        return
    end
    itemCell = CEGUI.toItemCell(itemCell)
    --itemCell:SetCornerImageAtPos("","", 1, 0.5,7,7)
    if nBind==1 then
        itemCell:SetCornerImageAtPos("ccui", "tm", 1, 0.5,7,7)----绑定
    else
       itemCell:SetCornerImageAtPos(nil, 1, 0.5)
    end

end

function setItemCellFrame(itemCell,nBagId,nItemKey,nItemId)
    if not itemCell then
        return
    end
    itemCell = CEGUI.toItemCell(itemCell)
    --local 
    local nQuality = 0
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemTable then
        nQuality = itemTable.nquality
    end

    SetItemCellBoundColorByQulityItem(itemCell, nQuality)
    --refreshItemCellBind(itemCell,nBagId,nItemKey)
   
end

--enum eNpcType
function CanBeVisited(nNpcType,nParam2,nParam3,nParam4)
    if nNpcType == 1 or 
       nNpcType == 2 or
       nNpcType == 3 or
       nNpcType == 4 or
       nNpcType == 7 or
       nNpcType == 8 or
       nNpcType == 12 or
       nNpcType == 16 or
       nNpcType == 17 or
       nNpcType == 28 or
       nNpcType == 29

    then
        return 1
    end
    return 0
end

--重连成功后刷新数据
local _needRefreshDlgs = {
	"logic.shop.stalldlg",					--摆摊
	"logic.shop.commerceselldlg",			--商会出售
	"logic.item.depot",						--仓库
	"logic.task.renwulistdialog",			--主界面任务追踪
	"logic.team.teamdialognew",				--队伍
	"logic.chargedialog",					--充值
	"logic.skill.gonghuiskilldlg",			--公会技能界面
    "logic.family.familyfightmanager",		--公会战
    "logic.team.teamrollmelondialog"  --roll点
}

--重连成功后通知在 _needRefreshDlgs 里注册的脚本处理一下
--注册的脚本需要实现 onInternetReconnected() 方法
function OnInternetReconnected()
	for _,v in pairs(_needRefreshDlgs) do
		local t = require(v)
		if t and t.onInternetReconnected then
			t.onInternetReconnected()
		end
	end
end

function getJingji1v1Group(nMapId)
    local nGroup=1
    if nMapId==1656 then
        nGroup = 1
    elseif nMapId==1657 then
        nGroup = 2
    elseif nMapId==1658 then
        nGroup = 3
    end
    return nGroup
end

function getJingji3v3Group(nMapId)
    local nGroup=1
    if nMapId==1659 then
        nGroup = 1
    elseif nMapId==1660 then
        nGroup = 2
    elseif nMapId==1661 then
        nGroup = 3
    end
    return nGroup

end


function getJingji5v5Group(nMapId)
     local nGroup=1 
    return nGroup
end



function showJingjiDialog5()
    require("logic.jingji.jingjidialog5").getInstanceAndShow()
end

function showEnterJingjiDialog5()
    require("logic.jingji.jingjienterdialog5").getInstanceAndShow()
    
end

function closeJingjiDialog5()
    require("logic.jingji.jingjimanager").getInstance():exitJingji5()
    require("logic.jingji.jingjidialog5").DestroyDialog()
end

function  closeEnterJingjiDialog5()
     require("logic.jingji.jingjienterdialog5").DestroyDialog()
end

-----------------------
function showEnterJingjiDialog()
    require("logic.jingji.jingjienterdialog").getInstanceAndShow()

end

function showJingjiDialog()
    require("logic.jingji.jingjidialog").getInstanceAndShow()
end


function  closeEnterJingjiDialog()
    require("logic.jingji.jingjienterdialog").DestroyDialog()
end

function closeJingjiDialog()
    require("logic.jingji.jingjidialog").DestroyDialog()
    require("logic.jingji.jingjipipeidialog").DestroyDialog()
end

--------------------------------------------
function showEnterJingjiDialog3()
    require("logic.jingji.jingjienterdialog3").getInstanceAndShow()
    
end

function showJingjiDialog3()
    require("logic.jingji.jingjidialog3").getInstanceAndShow()
end


function  closeEnterJingjiDialog3()
     require("logic.jingji.jingjienterdialog3").DestroyDialog()
end

function closeJingjiDialog3()
    require("logic.jingji.jingjidialog3").DestroyDialog()
    require("logic.jingji.jingjipipeidialog3").DestroyDialog()
    require("logic.jingji.jingjiscorerankdialog").DestroyDialog()
end

function isDepotVisible()
	return require("logic.item.depot").isShowing()
end

function setPetItemCellBackgroundByQuality(itemcell, petTableId)
	if not itemcell or petTableId == 0 then
		return
	end
	cell = tolua.cast(itemcell, "CEGUI::ItemCell")
	if not cell then
		return
	end
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petTableId)
	if not conf then
		return
	end
	SetItemCellBoundColorByQulityPet(cell, conf.quality)
end

--@columnid  PetColumnTypes
function LuaRemovePetFromCol(petkey, columnid)
	if columnid == 5 then --摆摊
		local dlg = require("logic.shop.stalldlg").getInstanceNotCreate()
		if dlg and dlg.isRequestedMyStall then
			local p = require("protodef.fire.pb.shop.cmarketcontainerbrowse"):new()
			LuaProtocolManager:send(p)
		end
	elseif columnid == 1 or columnid == 2 then --人物或仓库
		require("logic.pet.petstoragedlg").removePet(columnid) --宠物仓库
	end
end

function GetNumberValueForStrKey(key)
	if key == "HORSE_ITEM_TYPEID" then --坐骑物品类型id
		return ITEM_TYPE.HORSE
	elseif key == "NEW_GUIDE_PET_ID" then -- 宠物引导id
		return 31023
	elseif key == "NEW_GUIDE_EQUIP_ID" then -- 穿装备引导
		return 31044
    elseif key == "NEW_GUIDE_BATTLE_PET_ID" then -- 引导上阵宠物ID
        return 33019
    elseif key == "NEW_GUIDE_NEW_PET_ID_1" then 
        return 33191
    elseif key == "NEW_GUIDE_NEW_PET_ID" then -- 引导上阵新宠物ID
        return 33021
	elseif key == "NEW_GUIDE_EQUIP_ID2" then -- 20级传装备引导
		return 31063
	elseif key == "NEW_GUIDE_EQUIP_ID3" then -- 30级传装备引导
		return 31083
	elseif key == "NEW_GUIDE_EQUIP_ID4" then -- 装备打造
		return 33009
    elseif key == "NEW_GUIDE_ZHENFA" then -- 阵法打造
		return 33180
    elseif key == "NEW_GUIDE_BUSINESS" then -- 商会购买引导
        return 33164
    elseif key == "NEW_GUIDE_CHAT_START" then -- 聊天常用语引导
        return 33100
   elseif key == "NEW_GUIDE_CHAT" then -- 聊天常用语引导
        return 33104
    elseif key == "NEW_GUIDE_CHAT_END" then -- 聊天常用语引导
        return 33105
    elseif key == "NEW_GUIDE_PACK" then   -- 背包格子不足引导
        return 33170
    elseif key == "NEW_GUIDE_ZHENFA1" then -- 阵法学习引导
        return 33181
	elseif key == "ITEM_TYPE_HUOBAN" then -- 伙伴类型（背包中）
		return 518
	elseif key == "BINGFENG_MAPID_BEGIN" then -- 秘境降妖开始地图ID
		return 1821
	elseif key == "BINGFENG_MAPID_END" then -- 秘境降妖结束地图ID
		return 1839
    elseif key == "GUANJUNSHILIAN_ALERT_TIME" then
        return 30000
    elseif key == "BAG_ITEMCELL_COUNT" then  -- 一页背包数量
        return 25
    elseif key == "NEWER_BATTLE_ID_START" then  -- 新手战斗id
        return 0
    elseif key == "NEWER_BATTLE_ID_END" then  -- 新手战斗id
        return 0
    elseif key == "CHAT_POP_MAX_WIDTH" then  -- 聊天 气泡宽度，偏移
        return 265
    elseif key == "CHAT_POP_LEFT_OFF" then
        return 7
    elseif key == "CHAT_POP_TOP_OFF" then 
        return 6
    elseif key == "CHAT_POP_TEXT_Y_OFF" then 
        return 0
    elseif key == "JINGLING_COLUM_REDIAN" then --热点
        return 1
    elseif key == "JINGLING_COLUM_TUIJIAN" then --推荐
        return 13
    elseif key == "JINGLING_COLUM_KEFU" then --客服
        return 15
    elseif key == "VOICE_JINGLING_CHANNEL" then --精灵语音频道
        return 888
    elseif key == "VOICE_FRIEND_CHANNEL" then  --好友语音频道
        return 889
    elseif key == "GET_GAME_ID" then 
        return 88
	end
	return 0
end

function RoleItem_OnUpdate(itemCell,proleItem,nParam3,nParam4)
    if not itemCell then
        return
    end

    if not proleItem then
        return
    end

    itemCell = CEGUI.toItemCell(itemCell)
    local roleItem = proleItem
    if not roleItem then
        return
    end
    local pObj = roleItem:GetObject()
    if not pObj then
        return
    end
    local bBind = roleItem:isBind()
    
    local nTimeEnd = pObj.data.markettime
    local nServerTime = gGetServerTime() /1000
    local nLeftSecond = nTimeEnd / 1000 - nServerTime
    if nLeftSecond > 0 then
        setItemCellSaleCool(itemCell,true)
    else
         if bBind==false then
            setItemCellSaleCool(itemCell,false)
         end
    end

    if bBind==true then
        itemCell:SetCornerImageAtPos("ccui", "tm", 1, 0.5,7,7)----绑定
    end

    -------------
    local itemData = proleItem
    if itemData:GetFirstType() ~= eItemType_EQUIP then
        return
    end

    local equipObj = itemData:GetObject() 
    if not equipObj then
        return
    end
	local nEndureMax = equipObj.endureuplimit
    local nCurEndure = equipObj.endure

    if nCurEndure <= 0  then 
        itemCell:SetCornerImageAtPos("linshi", "xiu", 0,1.0,7,7)
    else
    end

end

 

function setTeamGuideIndex( index )
    TEAMGUIDE = index
end

function getTeamGuideIndex()
    return TEAMGUIDE
end

function setLocked( islock )  -- 0没锁 1锁屏
    ISLOCK = islock
end

function getLocked()
    return ISLOCK
end

--[[
PetItemObject=0
food=1
drug=1
dimarm=0
gem=0
EquipRelativeObject=0
TaskObject =1
PetStarObject=0
PetSoulObject=0
--]]
function isNeedRequestItemData(nBagId,nItemKey,nParam3,nParam4)
    
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local itemData = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
    if not itemData then
        return 0
    end
    local itemTable = itemData:GetBaseObject()
    local nItemType = itemTable.itemtypeid
    local nFirstType =  require ("utils.mhsdutils").GetItemFirstType(nItemType)
    if  nFirstType==eItemType_EQUIP  or --装备
        nItemType ==290 or  --烹饪道具
        nItemType ==291 or --高级药道具
        nItemType ==118 or --藏宝图
        nItemType ==198 or --高级藏宝图
        nItemType ==358 or--附魔道具
        nItemType ==154
    then
        return 1 --请求数据
    end
    return 0
end

function isPetOpen()

  local nPetNum = MainPetDataManager.getInstance():GetPetNum()

  return nPetNum > 0 and 1 or 0
end


-- 返回weaponex，给UISprite用
function GetWeaponEx(id)
    local weaponex = ""
    local equip = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
    if equip then
        local equiptype = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(equip.itemtypeid);
        if equiptype and equiptype.weapon ~= "" then
            weaponex = equiptype.weapon
        end
    end
    return weaponex
end

function GetNewSpecialQuestName(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		return repeatCfg.strtypename;
	end
	return ""
end

function GetAcceptableTaskId(index)
    local questinfo = BeanConfigManager.getInstance():GetTableByName("mission.cacceptabletask"):getRecorder(index)
    if questinfo then
        return questinfo.destnpcid
    end
    return  0
end

function GetSchoolPicPath(schoolId)
    local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
    if schoolinfo then
        return schoolinfo.schoolpicpath
    end
    return ""
end

function ChangeSchoolMap()
    local schoolId = gGetDataManager():GetMainCharacterSchoolID()
    local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
    local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(schoolinfo.schooljobmapid)
	local randX = mapRecord.bottomx - mapRecord.topx
	randX = mapRecord.topx + math.random(0, randX)

	local randY = mapRecord.bottomy - mapRecord.topy
	randY = mapRecord.topy + math.random(0, randY)
	gGetNetConnection():send(fire.pb.mission.CReqGoto(schoolinfo.schooljobmapid, randX, randY))
end

function GetSchoolMapId(schoolId)
	local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
	return schoolinfo.schooljobmapid;
end

function GetSchoolMapGotoPosition(schoolId)
	local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
    local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(schoolinfo.schooljobmapid)
	local randX = mapRecord.bottomx - mapRecord.topx
	randX = mapRecord.topx + math.random(0, randX)

	local randY = mapRecord.bottomy - mapRecord.topy
	randY = mapRecord.topy + math.random(0, randY)

	return Nuclear.NuclearPoint(randX, randY);
end

function GetSchoolName(schoolId)
    local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
    return schoolinfo.name
end

function GetRoleSex(shape)
	-- print("1111111111111111")
	--print("shape============>%s",shape)
	--print(tonumber(string.sub(shape, -2)))
    local info = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(tonumber(string.sub(shape, -2)))
    --local info = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(shape)
    

	--local info = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(shape)
    local sex = 1

    if info == nil then
       sex = 1
    else
       sex = info.sex
    end
    return sex
end

function GetSchoolMasterID()
    local skillinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolmasterskillinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	if skillinfo == nil then
		return 0
    end
	return skillinfo.masterid;
end


function GetTableValueFromLua(tableName, tableId, key)
    local conf = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(tableId)
    if not conf then
        return nil
    end
    return conf[key]
end

function GetActionID(shape, weaponId)
    local t = BeanConfigManager.getInstance():GetTableByName("npc.cactioninfo")
    local ids = t:getAllID()
    for _,id in pairs(ids) do
        local conf = t:getRecorder(id)
        if conf.model == shape and conf.weapon == weaponId then
            return id
        end
    end
    return -1
end

function GetDyeIndex(id)
    local config = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(id);
	if config then
		return config.res
    end
    return id
end

--获取动作名称
local _savedActName1 = nil
local _savedActName2 = nil
function GetActionName(act, aid, riding,ridingmodel)
    -- if aid ~= 0 then
    --     local ainfo = BeanConfigManager.getInstance():GetTableByName("npc.cactioninfo"):getRecorder(aid)
	-- 	if ainfo then
    --         if act == eActionStand then
    --             if not riding then
    --                 return ainfo.stand
    --             else
    --                 return ainfo.ridstand
    --             end
    --         elseif act == eActionRun then
    --             if not riding then
    --                 return ainfo.run
    --             else
    --                 return ainfo.ridrun
    --             end
    --         elseif act == eActionRunaway then
    --             if not riding then
    --                 return ainfo.run
    --             else
    --                 return ainfo.ridrun
    --             end
    --         elseif act == eActionStandRandom then
    --             return "stand2"                      --��������
    --         elseif act == eActionBattleStand then
    --             return ainfo.battlestand             --ս������
    --         elseif act == eActionBattleRun then
    --             return "fightrun"                     
    --         elseif act == eActionBattleJump then
    --             return "fightjump"                      
    --         elseif act == eActionOnHit1 then
    --             return ainfo.attacked                --�ܻ�����
    --         elseif act == eActionAttack then
    --             return ainfo.attack                  --��������
    --         elseif act == eActionAttack2 then
    --             return "attack2"                       --��������
    --         elseif act == eActionMagic1 then
    --             return ainfo.magic                   --ʩ������
    --         elseif act == eActionDefence then
    --             return ainfo.defence                 --��������
    --         elseif act == eActionDodge then
    --             return ainfo.battlestand             --���ܶ���
    --         elseif act == eActionDying then         --�ο���ǰ�Ķ���
    --             return ainfo.attacked
    --         elseif act == eActionDeath then
    --             return ainfo.dying
    --         elseif act == eActionDeathStill then
    --             return ainfo.death          
    --         elseif act == eActionRoll then
    --             return ainfo.stand
    --         end
	-- 	end
	-- end

    --可以调整双坐姿
    if not _savedActName2 then
        _savedActName2 = {}
        _savedActName2[eActionStand]        = {"stand1", "riding_stand1","riding_stand2"}   --��ͨվ�� 
        _savedActName2[eActionRun]          = {"run", "riding_run","riding_run2"}
        _savedActName2[eActionRunaway]      = "run"
        _savedActName2[eActionStandRandom]  = "stand2"                      --��������
        _savedActName2[eActionBattleStand]  = "stand3"                      --ս������
        _savedActName2[eActionBattleRun]    = "fightrun"
        _savedActName2[eActionBattleJump]   = "fightjump"
        _savedActName2[eActionOnHit1]       = "attacked"                    --�ܻ�����
        _savedActName2[eActionAttack]       = "attack1"                     --��������
        _savedActName2[eActionAttack2]      = "attack2"                     --��������
        _savedActName2[eActionMagic1]       = "magic1"                      --ʩ������
        _savedActName2[eActionDefence]      = "defend"                      --��������
        _savedActName2[eActionDodge]        = "stand3"                      --���ܶ���
        _savedActName2[eActionDying]        = "attacked"
        _savedActName2[eActionDeath]        = "death2"
        _savedActName2[eActionDeathStill]   = "death"
        _savedActName2[eActionRoll]         = "stand1"
    end

    if act == eActionStand or act == eActionRun then
        if not riding then
            return _savedActName2[act][1]
        else
            if ridingmodel~=0 then 
               local stand= GetRideStandByModelID(ridingmodel)
                    if stand==1 then
                        return _savedActName2[act][2]
                    else
                        return _savedActName2[act][3]
                    end
            end
            return _savedActName2[act][2]
        end
    end

    return _savedActName2[act] or ""
end


--RichEditbox的通用链接回调，参数拼接成字符串arg
--arg第一个参数t表示链接类型，如: "t=1,id=10,type=100"
--  1: 摆摊
function HandleRichEditboxCommonLinkClicked(arg)
    print("click common link: " .. arg)

    local t = arg:match("t=(%d+)")

    if t == "1" then --摆摊
        local goodsid = tonumber(arg:match("id=(%d+)"))
        local itemtype = tonumber(arg:match("type=(%d+)"))
        print(goodsid, itemtype)

        local p = require("protodef.fire.pb.shop.cmarketitemchatshow"):new()
        p.id = goodsid
        p.itemtype = itemtype
        LuaProtocolManager:send(p)
    end

    require("logic.chat.cchatoutboxoperateldlg").SetOpenChatWnd(false)
end

function GetRideStandByModelID(modelID)
    local stand = 0
	if modelID == 0 then
		return 0
	end
    local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cridea")
    local ids = rideTable:getAllID()
    for _,id in pairs(ids) do
        local conf = rideTable:getRecorder(id)
        if conf.ridemodel == modelID then
			return conf.isstand
		end
    end
	return stand
end


function GetRideSpeedByModelID(modelID)
    local CurSpeed = 1000
	if modelID == 0 then
		return CurSpeed
	end
    local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cridea")
    local ids = rideTable:getAllID()
    for _,id in pairs(ids) do
        local conf = rideTable:getRecorder(id)
        if conf.ridemodel == modelID then
			CurSpeed = conf.speed
		end
    end
	return CurSpeed
end

function GetBattleLocation(formationId, battleId)
    local formation = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(formationId)
    if formation then
        return formation.formation[battleId-1]
    end
    return -1
end

function EquipEffect_GetID(quality)
    if quality ~= 0 then
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
		if record then
        	return record.effectId
		end
    end
    return 0
end

function GetConsumeFoodId(goodid)
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager.m_isPointCardServer then
        local pRecord = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashpcardlua"):getRecorder(goodid)
        if pRecord then
            return pRecord.foodid
        end
    else
        local record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(goodid)
        if record then
            return record.foodid
        end
    end
    return ""
end

function GetConsumeFoodName(goodid)
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager.m_isPointCardServer then
        local pRecord = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashpcardlua"):getRecorder(goodid)
        if pRecord then
            return pRecord.foodname
        end
    else
        local record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(goodid)
        if record then
            return record.foodname
        end
    end
    return ""
end

VOICE_RECORD_TYPE_CHAT = 1
VOICE_RECORD_TYPE_JINGLING = 2
VOICE_RECORD_TYPE_FRIEND = 3
function VoiceRecordTimeOver(type, arg)
    if type == VOICE_RECORD_TYPE_CHAT then
        require "logic.chat.chatoutputdialog".HandleVoiceEnd_(arg)
        require "logic.chat.cchatoutboxoperateldlg".HandleVoiceEnd_(arg)
    elseif type == VOICE_RECORD_TYPE_JINGLING then
        require "logic.jingling.jinglingdlg".HandleVoiceEnd_(arg)
    elseif type == VOICE_RECORD_TYPE_FRIEND then
        require "logic.friend.frienddialog".HandleVoiceEnd_(arg)
    end
end

function GetConsumeSellpricenum(goodid)
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(goodid)
    if record then
        return record.sellpricenum
    end
    return -1
end

function GetResolutionNumber(resolution)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.number
    end
    return -1
end

function GetResolutionLong(resolution)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.longa
    end
    return -1
end

function GetResolutionWide(resolution)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.wide
    end
    return -1
end

function GetResolutionDescription(resolution)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.description
    end
    return ""
end

function GetResolutionPositionsByresolution(resolution, index)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.positionsByresolution[index]
    end
    return ""
end

function GetResolutionPositionsBywatch(resolution, index)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.positionsBywatch[index]
    end
    return ""
end

function GetResolutionPositionsByme(resolution)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.positionsByme
    end
    return ""
end

function GetResolutionPositionsBytarget(resolution)
    local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.resolution"):getRecorder(resolution)
    if record then
        return record.positionsBytarget
    end
    return ""
end

g_mapTableFilePathInLua =
{
    ["item.citemattr"] = "item.citemattr_pointcard",
    ["item.cpetitemeffect"] = "item.cpetitemeffect_pointcard",
    ["item.cfoodanddrugeffect"] = "item.cfoodanddrugeffect_pointcard",
    ["item.cgemeffect"] = "item.cgemeffect_pointcard",
    ["item.cgroceryeffect"] = "item.cgroceryeffect_pointcard",
    ["item.cequipeffect"] = "item.cequipeffect_pointcard",
    ["item.ctaskrelative"] = "item.ctaskrelative_pointcard",
    ["item.cequipitemattr"] = "item.cequipitemattr_pointcard",
    ["pet.cpetfeeditemattr"] = "pet.cpetfeeditemattr_pointcard",
    ["pet.cfooditemattr"] = "pet.cfooditemattr_pointcard",
    ["fushi.caddcashlua"] = "fushi.caddcashpcardlua",
    ["item.cpresentconfig"] = "item.cpresentconfigpay",
    ["game.wisdomtrialvill"] = "game.wisdomtrialvillpay",
    ["game.wisdomtrialprov"] = "game.wisdomtrialprovpay",
    ["game.wisdomtrialstate"] = "game.wisdomtrialstatepay",
    ["friends.crecruitreward"] = "friends.crecruitrewardpay",
    ["friends.cmyrecruit"] = "friends.cmyrecruitpay"
}

g_mapTableFilePathInCpp =
{
    ["/table/bintable/item.cequipeffect.bin"] = "/table/bintable/item.cequipeffect_pointcard.bin",
}

function g_CheckCorrectTableName(strTablePath)
    if not IsPointCardServer() then
        return
    end
    local strNewName = g_mapTableFilePathInCpp[strTablePath]
    if not strNewName then
        return 
    end

    TableDataManager:instance():SetCorrectTableName(strNewName)

end

function g_CheckSimpTableName(strTablePath)
    if strTablePath == "mission.carroweffect" then
        local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
        local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
        if record.id ~= -1 then
            local strKey = record.key
            local value = gGetGameConfigManager():GetConfigValue(strKey)
            if value == 1 then 
                return "mission.carroweffectsimp"
            end 
        end
    end
    return strTablePath
end

function g_getCorrectTableFilePath(strTableName)
    if not IsPointCardServer() then
        return strTableName
    end

    local strNewName = g_mapTableFilePathInLua[strTableName]
    if not strNewName then
        return strTableName
    end
    return strNewName
end

function g_shareResultCallBack(nResult)
    if nResult==1 then
        require("logic.share.sharedlg").SetShareActiveComplete()
    end
end

function getJingjiMapType(nMapId,nParam2,nParam3,nParam4)
     if nMapId >= 1656 and nMapId <= 1658 then
            return 1
     end

     if nMapId >= 1659 and nMapId <= 1661 then
            return 2
     end
     
     if nMapId >= 1699 and nMapId <= 1710 then
            return 3
     end
	 


     -- non-jingji maps should not enter PVP/UI-hide flow
     return 0
end

function enterJingjiMap(nJingjiType,nParam2,nParam3,nParam4)
    if nJingjiType==0 then
        return
    end
    if nJingjiType==1 then
        showEnterJingjiDialog()
        showJingjiDialog()
        
        require("logic.task.renwulistdialog").trySetVisibleFalse()
    elseif nJingjiType==2 then
        showEnterJingjiDialog3()
        showJingjiDialog3()
        require("logic.task.renwulistdialog").trySetVisibleTrue()
    elseif nJingjiType==3 then
        
        showEnterJingjiDialog5()
        showJingjiDialog5()
        require("logic.task.renwulistdialog").trySetVisibleTrue()
    elseif nJingjiType==4 then

        showEnterGaojiDia()
       -- showJingjiDialog3()
        require("logic.task.renwulistdialog").trySetVisibleTrue()
    end
    require("logic.bingfengwangzuo.bingfengwangzuoTaskTips").DestroyDialog()
    require("logic.showhide").EnterPVPScene()
end


function exitJingjiMap(nJingjiType,nParam2,nParam3,nParam4)
    if nJingjiType==0 then
        return
    end
    if nJingjiType==1 then
        closeJingjiDialog()
	    closeEnterJingjiDialog()
    elseif nJingjiType==2 then
        closeJingjiDialog3()
        closeEnterJingjiDialog3()
    elseif nJingjiType==3 then
        closeJingjiDialog5()
        closeEnterJingjiDialog5()
    elseif nJingjiType==4 then
        --closeGuajiDia()
        closeEnterGuajiDia()
    end
end

function showEnterGaojiDia()
    require("logic.guaji.guajidia").getInstanceAndShow()
end

function  closeEnterGuajiDia()
    require("logic.guaji.guajidia").DestroyDialog()
end



function g_shareResultCallBack(nResult)
    if nResult==1 then
        require("logic.share.sharedlg").SetShareActiveComplete()
    end
end

function GetRideStandByModelID(modelID)
    local stand = 0
	if modelID == 0 then
		return 0
	end
    local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cride")
    local ids = rideTable:getAllID()
    for _,id in pairs(ids) do
        local conf = rideTable:getRecorder(id)
        if conf.ridemodel == modelID then
			return conf.isstand
		end
    end
	return stand
end


function GetRideSpeedByModelID(modelID)
    local CurSpeed = 1000
	if modelID == 0 then
		return CurSpeed
	end
    local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cride")
    local ids = rideTable:getAllID()
    for _,id in pairs(ids) do
        local conf = rideTable:getRecorder(id)
        if conf.ridemodel == modelID then
			CurSpeed = conf.speed
		end
    end
	return CurSpeed
end
