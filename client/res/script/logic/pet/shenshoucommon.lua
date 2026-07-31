require "logic.pet.shenshoureset"
require "logic.pet.shenshouIncrease"
require "logic.shop.npcshenshoushop"

ShenShouCommon = {}

-- 获取宠物栏中的神兽列表
function ShenShouCommon.GetShenShouList()
    local shenShouList = {}

    local num = MainPetDataManager.getInstance():GetPetNum()
    for i = 1, num  do
        local petInfo = MainPetDataManager.getInstance():getPet(i)
        if petInfo and petInfo.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
            table.insert(shenShouList, petInfo)
        end
    end

    return shenShouList
end

-- 获取所有神兽数据列表（排除传入的id对应的神兽）
function ShenShouCommon.GetShenShouIdListWithoutMine(myBaseid)
    local shenShouIdList = {}

	local ids =  BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getAllID()
	for i = 1, #ids do
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(ids[i])
		if petAttr.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
            if petAttr.id ~= myBaseid then
			    table.insert(shenShouIdList, petAttr.id)
            end
		end
	end

    return shenShouIdList
end

-- 兑换神兽
function ShenShouCommon.DuiHuan(npckey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- 背包中“神兽兑换道具”的数量
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- 兑换神兽需要的“神兽兑换道具”的数量
	--local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(286).value
    --local nNeedItemNum = tonumber(strNeedItemNum)

    -- 宠物栏容量和宠物栏的当前宠物数
    local maxPetNum = MainPetDataManager.getInstance():GetMaxPetNum()
    local curPetNum = MainPetDataManager.getInstance():GetPetNum()

    -- 兑换道具不足
    --[[if curItemNum < nNeedItemNum then
	    if itemAttr then
            local parameters = {}
            table.insert(parameters, itemAttr.name)
            ShenShouCommon.SendClientTips(162093, parameters, npckey, nil, nil, nil)
	    end
    else--]]
    -- 宠物栏已满
    if curPetNum >= maxPetNum then
        ShenShouCommon.SendClientTips(162101, nil, npckey, nil, nil, nil)

    -- 满足条件
    else
	    if itemAttr then
            -- 目前是随机获得神兽
            ShenShouCommon.DoDuiHuan(itemAttr.name, npckey, nil)
	    end
    end
end

-- 提升神兽能力
function ShenShouCommon.Increase(npckey)
    -- 宠物栏中的神兽列表
    local shenShouList = ShenShouCommon.GetShenShouList()

    -- 宠物栏没有神兽
    if #shenShouList == 0 then
        ShenShouCommon.SendClientTips(162105, nil, npckey, nil, nil, nil)
    
    -- 宠物栏有神兽
    else
        ShenShouIncrease.getInstanceAndShow()
    end
end

-- 重置神兽
function ShenShouCommon.Reset(npckey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- 背包中兑换道具的数量
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- 重置神兽需要的“神兽兑换道具”的数量
	local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(287).value
    local nNeedItemNum = tonumber(strNeedItemNum)

    -- 宠物栏中的神兽列表
    local shenShouList = ShenShouCommon.GetShenShouList()

    -- 宠物栏没有神兽
    if #shenShouList == 0 then
        ShenShouCommon.SendClientTips(162104, nil, npckey, nil, nil, nil)
    
    -- 宠物栏有一只神兽
    elseif #shenShouList == 1 then

        -- 兑换道具不足
        if curItemNum < nNeedItemNum then
	        if itemAttr then
                local parameters = {}
                table.insert(parameters, itemAttr.name)
                ShenShouCommon.SendClientTips(162092, parameters, npckey, nil, nil, nil)
            end

        -- 满足条件
        else
	        if itemAttr then
                local petInfo = shenShouList[1]
	            local chooseDlg = require("logic.chosepetdialog").getInstance()
                local shenshouidlist = ShenShouCommon.GetShenShouIdListWithoutMine(petInfo.baseid)
		        chooseDlg:SetSelectShenShouId(1, shenshouidlist, itemAttr.name, npckey, petInfo.name, petInfo.shenshouinccount, petInfo.key)
            end
        end

    -- 宠物栏有多只神兽
    else
	    if itemAttr then
            local dlg = ShenShouReset.getInstanceAndShow()
            dlg:SetNpcKey(npckey)
            dlg:SetItemName(itemAttr.name)
        end
    end
end

-- 查看神兽
function ShenShouCommon.Show(npckey)
    -- 打开图鉴
require "logic.pet.petgallerydlg"
        PetGalleryDlg.getInstanceAndShow()
    -- 打开神兽页签
    local dlg = PetGalleryDlg.getInstanceNotCreate()
    if dlg then
        dlg:refreshPetTable(20000, 20000)
        dlg.shenshouBtn:setSelected(true)
    end
end

-- 处理兑换神兽
function ShenShouCommon.DoDuiHuan(itemname, npckey, needpetbaseid)
--    local parameters = {}
--    table.insert(parameters, itemname)
--    ShenShouCommon.SendClientTips(162090, parameters, npckey, ShenShouCommon.HandleDuiHuanEvent, needpetbaseid, nil)

    NpcShenShouShop.getInstanceAndShow()
end

-- 处理重置神兽
function ShenShouCommon.DoReset(itemname, npckey, needpetbaseid, mypetname, mypetinccount, mypetkey)
    local parameters = {}
    table.insert(parameters, mypetname)
    table.insert(parameters, tostring(mypetinccount))
    table.insert(parameters, itemname)
    ShenShouCommon.SendClientTips(162091, parameters, npckey, ShenShouCommon.HandleResetEvent, mypetkey, needpetbaseid)
end

-- 处理提升神兽能力
function ShenShouCommon.DoIncrease(petkey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- 背包中“神兽兑换道具”的数量
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- 提升神兽需要的“神兽兑换道具”的数量
	local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(288).value
    local nNeedItemNum = tonumber(strNeedItemNum)

    -- 神兽提升最大次数
	local strMaxIncCnt = GameTable.common.GetCCommonTableInstance():getRecorder(305).value
    local nMaxIncCnt = tonumber(strMaxIncCnt)

    -- 当前神兽
	local petInfo = MainPetDataManager.getInstance():FindMyPetByID(petkey)

    -- 神兽等级是否满足
    local bLevelFit = false
    local nIncLevel = 0
    local ids = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getAllID()
    for i = 1, #ids do
        local shenshouinc = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getRecorder(ids[i])
        if shenshouinc and shenshouinc.petid == petInfo.baseid and shenshouinc.inccount == petInfo.shenshouinccount + 1 then
            if petInfo:getAttribute(fire.pb.attr.AttrType.LEVEL) >= shenshouinc.inclv then
                bLevelFit = true
            else
                nIncLevel = shenshouinc.inclv
            end
        end
    end

    local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petInfo.baseid)
    
    -- 提升次数已满
    if petInfo.shenshouinccount >= nMaxIncCnt then
        ShenShouCommon.SendClientTips(162096, nil, npckey, nil, nil, nil)

    -- 神兽等级不足
    elseif not bLevelFit then
        local parameters = {}
        table.insert(parameters, tostring(nIncLevel))
        ShenShouCommon.SendClientTips(162107, parameters, npckey, nil, nil, nil)

    -- 兑换道具不足
    elseif curItemNum < nNeedItemNum then
	    if itemAttr then
            local parameters = {}
            table.insert(parameters, itemAttr.name)
            ShenShouCommon.SendClientTips(162094, parameters, npckey, nil, nil, nil)
        end

    -- 满足条件
    else
        local p = require "protodef.fire.pb.pet.shenshou.cshenshouyangcheng":new()
        p.petkey = petkey
        require "manager.luaprotocolmanager":send(p)
    end
end

-- 确认兑换神兽
function ShenShouCommon:HandleDuiHuanEvent(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData())

    local p = require "protodef.fire.pb.pet.shenshou.cshenshouduihuan":new()
    -- 兼容选择神兽和随机获得神兽，目前是随机获得神兽
	if pConfirmBoxInfo and pConfirmBoxInfo.userID ~= -1 then
        p.needpetid = pConfirmBoxInfo.userID
    end
    require "manager.luaprotocolmanager":send(p)

    if pConfirmBoxInfo then
	    gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
    end

    return true
end

-- 确认重置神兽
function ShenShouCommon:HandleResetEvent(e)
	local windowargs = CEGUI.toWindowEventArgs(e)

	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData())
	if pConfirmBoxInfo and pConfirmBoxInfo.userID ~= -1 and pConfirmBoxInfo.userID2 ~= -1 then
        local p = require "protodef.fire.pb.pet.shenshou.cshenshouchongzhi":new()
        p.petkey = pConfirmBoxInfo.userID
        p.needpetid = pConfirmBoxInfo.userID2
        require "manager.luaprotocolmanager":send(p)
    end

    if pConfirmBoxInfo then
	    gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
    end

    return true
end

-- 神兽相关客户端提示
function ShenShouCommon.SendClientTips(msgid, parameters, npckey, handler, id, id2)
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(msgid)
	if tip.id == -1 then
		return
	end

    local strMsg = tip.msg
    if parameters then
	    local sb = StringBuilder:new()
        for i = 1, #parameters do
            sb:Set("parameter" .. i, parameters[i])
        end
        strMsg = sb:GetString(strMsg)
        sb:delete()
    end

    -- 透明框提示
    local nType = tonumber(tip.type)
    if nType == fire.pb.talk.TipsMsgType.TIPS_POPMSG then
        GetCTipsManager():AddMessageTip(strMsg, true, true, true)

    -- NPC对话框提示
    elseif nType == fire.pb.talk.TipsMsgType.TIPS_NPCTALK then
        NpcDialog.getInstance():AddTipsMessage(npckey, 0, strMsg)

    -- 确认框提示
    elseif nType == fire.pb.talk.TipsMsgType.TIPS_CONFIRM then
        if handler then
            if not id then id = -1 end
            if not id2 then id2 = -1 end
            gGetMessageManager():AddConfirmBox(
                eConfirmNormal, strMsg,
                handler, ShenShouCommon,
                MessageManager.HandleDefaultCancelEvent, MessageManager, id, id2)
        end
    end
end



return ShenShouCommon