require "config"

-------------------------------------------------------------------------
-- LASTACCOUNT_SERVER_INI
-------------------------------------------------------------------------
local LASTACCOUNT_SERVER_INI 
local ROLE_CREATE_TIME
if DeviceInfo:sGetDeviceType()==3 or DeviceInfo:sGetDeviceType()==4 then
	LASTACCOUNT_SERVER_INI = ".Last_Account.ini"
else
	LASTACCOUNT_SERVER_INI = "Last_Account.ini"
end

local serverIniMgr = IniManager(LASTACCOUNT_SERVER_INI)

function GetServerIniMgr()
	return serverIniMgr
end

function SetServerIniInfo(section, param, value)
	if not serverIniMgr then return end
	serverIniMgr:WriteValueByName(section, param, value)
end

function GetServerIniInfo(section, param)
	if not serverIniMgr then return nil end
		
	local exist,_,_,value = serverIniMgr:GetValueByName(section, param, "0")
	if exist then
		return value
	end
	return nil
end

function RemoveServerIniInfo(section, param)
	if not serverIniMgr then return nil end
	serverIniMgr:RemoveValueByName(section, param)
end

function RemoveServerSection(section)
	serverIniMgr:RemoveSection(section)
end


-------------------------------------------------------------------------
-- POSITION
-------------------------------------------------------------------------
function SetPositionOffset(wnd, offsetx, offsety, anchorx, anchory)
	if not wnd then return end
	local p = CEGUI.UVector2(CEGUI.UDim(0, offsetx), CEGUI.UDim(0, offsety))
	
	local s = wnd:getPixelSize()
	local scale = wnd:getScale()
	
	if anchorx and anchorx ~= 0 then
		p.x.offset = p.x.offset-s.width*scale.x*anchorx
	end
	
	if anchory and anchory ~= 0 then
		p.y.offset = p.y.offset-s.height*scale.y*anchory
	end
	wnd:setPosition(p)
end

function SetPositionXOffset(wnd, offsetx, anchorx)
	if not wnd then return end
	local p = CEGUI.UDim(0, offsetx)
	if anchorx and anchorx ~= 0 then
		local s = wnd:getPixelSize()
		local scale = wnd:getScale()
		p.offset = p.offset-s.width*scale.x*anchorx
	end
	wnd:setXPosition(p)
end

function SetPositionYOffset(wnd, offsety, anchory)
	if not wnd then return end
	local p = CEGUI.UDim(0, offsety)
	if anchory and anchory ~= 0 then
		local s = wnd:getPixelSize()
		local scale = wnd:getScale()
		p.offset = p.offset-s.height*scale.y*anchory
	end
	wnd:setYPosition(p)
end

function SetPositionScreenCenter(wnd)
	local size = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	SetPositionOffset(wnd, size.width*0.5, size.height*0.5, 0.5, 0.5)
end

function GetPositionOffsetByAnchor(wnd, anchorx, anchory)
	local s = wnd:getPixelSize()
	local p = wnd:getPosition()
	return p.x.offset+s.width*anchorx, p.y.offset+s.height*anchory
end

function SetPositionOfWindowWithLabel(wnd)
	local size = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	SetPositionOffset(wnd, size.width*0.5-32, size.height*0.5+8, 0.5, 0.5)
end

-------------------------------------------------------------------------
-- SIZE
-------------------------------------------------------------------------
function NewVector2(x, y)
	x = x or 0
	y = y or 0
	return CEGUI.UVector2(CEGUI.UDim(0,x), CEGUI.UDim(0,y))
end

function SetWindowSize(wnd, w, h)
	if not wnd then return end
	local pos = wnd:getType():find("Image")
	if pos and pos >= 0 then
		wnd:setProperty("ImageSizeEnable", "True")
	end
	wnd:setSize(NewVector2(w, h))
end

function SetWindowScale(wnd, scale)
	if not wnd then return end
	local size = wnd:getPixelSize()
	size.width = size.width*scale
	size.height = size.height*scale
	SetWindowSize(wnd, size.width, size.height)
end

function GetScreenSize()
	return CEGUI.System:getSingleton():getGUISheet():getPixelSize()
end

function UseImageSourceSize(imgWnd, imagesetpath)
    local set, img = string.match(imagesetpath, "set:(.*) image:(.*)")
    local image = CEGUI.ImagesetManager:getSingleton():getImage(set, img)
    if not image then return end
    local w = image:getWidth()
    local h = image:getHeight()
    imgWnd:setProperty("ImageSizeEnable", "True")
    imgWnd:setProperty("LimitWindowSize", "False")
    imgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,w), CEGUI.UDim(0,h)))
end

-------------------------------------------------------------------------
-- GroupBtnTree
-------------------------------------------------------------------------
function SetGroupBtnTreeFirstIcon(item)
	item:seNormalImage(CEGUI.String("common"), CEGUI.String("treehuang1"))
	item:setHoverImage(CEGUI.String("common"),CEGUI.String("treelan1"))
	item:setSelectionImage(CEGUI.String("common"),CEGUI.String("treelan1"))
    item:setOpenImage(CEGUI.String("common"),CEGUI.String("treelan1"))
end

function SetGroupBtnTreeSecondIcon(item)
	item:seNormalImage(CEGUI.String("common"), CEGUI.String("treehuang2"))
	item:setHoverImage(CEGUI.String("common"),CEGUI.String("treelan2"))
    item:setSelectionImage(CEGUI.String("common"), CEGUI.String("treelan2"))
    item:setOpenImage(CEGUI.String("common"), CEGUI.String("treelan2"))
end


-------------------------------------------------------------------------
-- String
-------------------------------------------------------------------------
function GetByteCount(byteVal)
	
	if byteVal > 0 and byteVal <= 127 then
		return 1
	end
	
	if byteVal >= 192 and byteVal < 223 then
		return 2
	end
	
	if byteVal >= 224 and byteVal < 239 then
		return 3
	end
	
	if byteVal >= 240 and byteVal <= 247 then
		return 4
	end

	return 3
	
end
function GetByteCountSlipt(byteVal)
	
	if byteVal > 0 and byteVal <= 127 then
		return 1
	end
	
	if byteVal >= 192 and byteVal < 223 then
		return 2
	end
	
	if byteVal >= 224 and byteVal < 239 then
		return 2
	end
	
	if byteVal >= 240 and byteVal <= 247 then
		return 2
	end

	return 2
	
end
function GetCharCount(str)
	--把英文字符当做一个字符，其他的当做两个字符
	local cNum = 0
	local eNum = 0 --英文字符
	local i = 1
	while i <= #str do
		local byteVal = string.byte(str,i)
		local byteCount = GetByteCount(byteVal)
		if byteCount > 1 then
			cNum = cNum+1
		else
			eNum = eNum+1
		end
		i = i+byteCount
	end
	return cNum, eNum
end

function SliptStrByCharCount(str, count)
    if not str or str == "" or count < 0 then
        return ""
    end
    local n = 0
    local i = 1
    while i <= #str do
		local byteVal = string.byte(str,i)
		local byteCount = GetByteCountSlipt(byteVal)
        local byte = GetByteCount(byteVal)
        i = i+byte
        n = n+byteCount
		
        
        if n > count and i ~= #str then
            return string.sub(str, 1, i-1 - byte), true
        end
	end
    return str, false
end


-------------------------------------------------------------------------
-- Time
-- @return {h,m,s} --> {00,00,00}
-------------------------------------------------------------------------
function FormatTimeStrUnit(t)
	t = math.floor(math.abs(t))
	return (t>=10 and t or '0'..t)
end

function GetTimeStrByNumber(n)
	local h = n/3600
	local m = (n%3600)/60
	local s = n%60
	print('timestr', h, m, s)
	return {
		h=FormatTimeStrUnit(h),
		m=FormatTimeStrUnit(m),
		s=FormatTimeStrUnit(s)
	}
end

--检查记录的时间戳和当前时间是否不是同一天
--@timestamp  gGetServerTime()
function DayChanged(timestamp)
	if not timestamp or timestamp == 0 then
		return false
	end

	local time0 = math.floor(timestamp * 0.001)
	local time1 = math.floor(gGetServerTime() * 0.001)
	local date0 = os.date("*t", time0)
	local date1 = os.date("*t", time1)
	
	if date0.day ~= date1.day then
		return true
	end
	return false
end


-------------------------------------------------------------------------
-- Pet
-------------------------------------------------------------------------
-- Image Name
function GetPetKindImageRes(t, unusualid)
	return "set:chongwuui image:" .. 
		(t == 1 and (unusualid == 1 and "yeshenglingshou" or "chongwu_yesheng") or
		(t == 2 and (unusualid == 1 and "baobaolingshou" or "chongwu_bb") or
		(t == 3 and (unusualid == 1 and "bianyilingshou" or "chongwu_bianyi") or
		(t == 4 and "chongwu_shenshou" or ""))))
end


-- SkillBox for Pet
-- @skillBox	CEGUI.SkillBox
-- @petData		stMainPetData
-- @certification 用于显示认证角标
function SetPetSkillBoxInfo(skillBox, skillid, petData, showCornerImg, certification, showBindImg)
    if skillid == 0 then
        return
    end

    skillBox:SetSkillID(skillid)
	local skillexpiretime = petData and petData:getPetSkillExpires(skillid) or 0
	skillBox:SetSkillDueDate(skillexpiretime)

	local skillicon = RoleSkillManager.GetSkillIconByID(skillid)
	skillBox:SetImage(gGetIconManager():GetSkillIconByID(skillicon))
	skillBox:setTooltipText("")
	skillBox:SetBackgroundDynamic(true)

    local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
    if skillconf and skillconf.id ~= -1 then
        local img = (skillconf.skilltype==1 and "beiji" or "zhuji")
        img = img .. (skillconf.color)
		print("img >>>>>>>>>"..tostring(img))
        skillBox:SetBackGroundImage(CEGUI.String("chongwuui"), CEGUI.String(img))
    end

	-- corner certification image
	if showCornerImg then
	    if certification and certification == 1 then
		    skillBox:SetCornerImage("chongwuui", "renzheng")
            return
	    end
	end

    -- corner bind img
    if showBindImg then
        skillBox:SetCornerImage("chongwuui", "bangding")
    end
end


-- ItemCell for Pet
-- @cell	CEGUIItemCell
-- @petData stMainPetData
function SetPetItemCellInfo(cell, petData)
	if not cell or not petData then
		return
	end
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	cell:SetLockState(false)
    --cell:SetBackGroundImage("chongwuui", "chongwu_di")
	cell:SetImage(image)
	cell:SetTextUnit(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	--cell:setUserData(petData)
	cell:setID(petData.key)

	if petData.key == gGetDataManager():GetBattlePetID() then --出战
		cell:SetCornerImageAtPos("chongwuui", "chongwu_zhan", 1, 0.5)
	end
	if petData.flag == 2 then --绑定
		cell:SetCornerImageAtPos("common_equip", "suo", 1, 0.8) 
	end

    --local totalPropetyPoint = petData:getAttribute(fire.pb.attr.AttrType.CONS) + petData:getAttribute(fire.pb.attr.AttrType.IQ) + petData:getAttribute(fire.pb.attr.AttrType.STR) + petData:getAttribute(fire.pb.attr.AttrType.ENDU) + petData:getAttribute(fire.pb.attr.AttrType.AGI)

	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    local bTreasure = isPetTreasure(petData)
	if bTreasure then
		cell:SetCornerImageAtPos("shopui", "zhenpin", 0, 1)
	end
    if petAttr then
        SetItemCellBoundColorByQulityPet(cell, petAttr.quality)
    end
end

-- ItemCell for Pet 只设置绑定/珍品/品质框
-- @cell	CEGUIItemCell
-- @petData stMainPetData
function SetPetItemCellInfo2(cell, petData)
	if not cell or not petData then
		return
	end
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	cell:SetLockState(false)
	cell:SetImage(image)
    cell:ClearCornerImage(0)
    cell:ClearCornerImage(1)

	if petData.flag == 2 then --绑定
		cell:SetCornerImageAtPos("common_equip", "suo", 1, 0.8)
	end

	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    local bTreasure = isPetTreasure(petData)
	if bTreasure then
		cell:SetCornerImageAtPos("shopui", "zhenpin", 0, 1)
	end
    if petAttr then
        SetItemCellBoundColorByQulityPet(cell, petAttr.quality)
    end
end 

function isPetTreasure(petData)
    if not petData then
        return false
    end
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if not petAttr then
        return false
    end
    local nSkillNum = MainPetDataManager.getInstance():GetPetSkillNum(petData)
	if petData.score - petData.basescore >= petAttr.treasureScore and nSkillNum>=petAttr.treasureskillnums then
		return true
	end
    return false
end

function GetPetNameColour(petTableId)
    local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petTableId)
    if conf then
        return conf.colour
    end
    return "FFFFFFFF"
end

--1白、2绿、3蓝、4紫、5橙
function SetItemCellBoundColorByQulityPet(itemCell, quality)
    local img = (quality == 1 and "baikuang" or
                (quality == 2 and "lvkuang" or
                (quality == 3 and "lankuang" or
                (quality == 4 and "zikuang" or
                (quality == 5 and "jinkuang" or
                "chongwu_di")))))
    itemCell:SetBackGroundImage("chongwuui", img)
end

function SetItemCellBoundColorByQulityItemWithId(itemCell,nItemId)
    local nQuality = 0
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if  itemTable then
        nQuality = itemTable.nquality
    end
    SetItemCellBoundColorByQulityItem(itemCell,nQuality)
end

function SetItemCellBoundColorByQulityItem(itemCell, nQuality)


    if not itemCell then
        return
    end
    itemCell = CEGUI.toItemCell(itemCell)
    --[[
    local nQuality = 0
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if not itemTable then
        nQuality = itemTable.nquality
    end
    --]]


    if nQuality == 0 then
        itemCell:SetBackGroundImage("chongwuui1", "kuang16")
    elseif nQuality == 1 then
            itemCell:SetBackGroundImage("chongwuui", "baikuang")
    elseif nQuality == 2 then
        itemCell:SetBackGroundImage("chongwuui", "lvkuang")
    elseif nQuality == 3 then
        itemCell:SetBackGroundImage("chongwuui", "lankuang")
    elseif nQuality == 4 then
        itemCell:SetBackGroundImage("chongwuui", "zikuang")
    elseif nQuality == 5 then
        itemCell:SetBackGroundImage("chongwuui", "jinkuang")
    else
        itemCell:SetBackGroundImage("common_pack", "kuang95")
    end

    --refreshItemCellBind(itemCell,nBagId,nItemKey,nItemId)
end

function  setItemCellSaleCool(itemCell,bInCd)
    if bInCd then 
        itemCell:setUserString("cool", "true")
        itemCell:SetCornerImageAtPos("shopui", "dongjieqi", 1, 0.5,7,7)
    else
        if itemCell:isUserStringDefined("cool") then
            itemCell:setUserString("cool", "")
        end
        itemCell:SetCornerImageAtPos(nil, 1, 0.5)
    end
end

function g_refreshItemCellEquipEndureFlag(itemCell,nBagId,nItemKey)
    if not itemCell then
        return
    end
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local roleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, nBagId)
    if not roleItem then
        return
    end

    local itemData = roleItem
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

function refreshItemCellBind(itemCell,nBagId,nItemKey)
    if not itemCell then
        return
    end

    itemCell:SetCornerImageAtPos(nil, 1, 0.5)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local roleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, nBagId)
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
        itemCell:SetCornerImageAtPos("common_equip", "suo", 1, 0.5,7,7)
    end
end

-------------------------------------------------------------------------
-- Role Type 人物类型: 物攻、法攻、治疗、辅助、控制
-------------------------------------------------------------------------
function GetRoleTypeIconPath(roleType)
	return  (roleType == 1 and "set:huobanui image:huobanwugong" or
			(roleType == 2 and "set:huobanui image:huoban_fagong" or
			(roleType == 3 and "set:huobanui image:huoban_zhiliao" or
			(roleType == 4 and "set:huobanui image:huoban_fuzhu" or
			(roleType == 5 and "set:huobanui image:huoban_fengyin" or "")))))
end

function GetRoleTypeName(roleType)
	local strid = 	(roleType == 1 and 11106 or
					(roleType == 2 and 11107 or
					(roleType == 3 and 11108 or
					(roleType == 4 and 11109 or
					(roleType == 5 and 11110 or 0)))))
	if strid == 0 then
		return ""
	end
	return MHSD_UTILS.get_resstring(strid)
end


-------------------------------------------------------------------------
-- 记录一些全局变量，切换角色时会全部重置
-------------------------------------------------------------------------
gCommon = {}
function gCommon.reset()
	--for logic.pet.petlabel
	--gCommon.selectedPetKey = 0
	--gCommon.curPetLabelIdx = nil
	
	gCommon.curTaskLabelIdx = 0		--save task label id
	gCommon.selectedZhenfaID = 0	--used in zhenfadlg.lua
	gCommon.skillIndex = 1
	gCommon.selectedServerKey = -1    --save the selected server key
	gCommon.selectedTeamMatchActId = 0 --used in teammatchdlg.lua
    gCommon.RoleOperateType = -1
    gCommon.RoleSelecttedSkill = -1
    gCommon.PetOperateType = -1
    gCommon.PetSelecttedSkill = -1
    gCommon.changeRoleId = -1
    gCommon.bagOffset = 0
    gCommon.stalldlgArgs = nil
end
gCommon.reset()


-------------------------------------------------------------------------
-- CEGUIScrollablePane
-------------------------------------------------------------------------
function SetVeticalScrollOffset(scroll, offset)
	local bar = scroll:getVertScrollbar()
	local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
	
	offset = math.max(0, math.min(docH-pageH, offset)) / docH
	
	scroll:getVertScrollbar():Stop()
	scroll:setVerticalScrollPosition(offset)
end

function IsVerticalScrollCellInViewArea(scroll, wnd)
	local h = wnd:getPixelSize().height
	
	local bar = scroll:getVertScrollbar()
	local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
	
	local offset = wnd:getYPosition().offset-bar:getScrollPosition()
	
	if offset+h <= pageH and offset >= 0 then
		return true
	end
	return false
end

function SetVeticalScrollCellTop(scroll, wnd)
	if IsVerticalScrollCellInViewArea(scroll, wnd) then
		return
	end
	
	local offset = wnd:getYPosition().offset
	
	local bar = scroll:getVertScrollbar()
	local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
	local h = wnd:getPixelSize().height
	
	offset = math.max(0, math.min(docH-pageH, offset-h*0.5)) --在最上面留出半格的空余，表示上面还是其他的行
	
	scroll:getVertScrollbar():Stop()
	scroll:getVertScrollbar():setScrollPosition(offset)
end

function SetHorizontalScrollCellRight(scroll,wnd)
	local offset = wnd:getXPosition().offset
	
	local bar = scroll:getHorzScrollbar()
	local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
	
	offset = math.max(math.min(docH-pageH, offset),0)
	
	scroll:getHorzScrollbar():Stop()
	scroll:getHorzScrollbar():setScrollPosition(offset)
end

--将某个cell显示在列表的正中间
--[[function SetVeticalScrollCellCenter(scroll, wnd)
	if IsVerticalScrollCellInViewArea(scroll, wnd) then
		return
	end
	
	local offset = wnd:getYPosition().offset
	local h = wnd:getPixelSize().height
	
	local bar = scroll:getVertScrollbar()
	local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
	
	offset = math.max(offset+h*0.5-pageH*0.5, 0)
	offset = math.max(0, math.min(docH-pageH, offset)) / docH
	
	scroll:getVertScrollbar():Stop()
	scroll:setVerticalScrollPosition(offset)
end--]]


-------------------------------------------------------------------------
-- 检查背包空间
-------------------------------------------------------------------------
function CheckBagCapacityForItem(itemid, num)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local emptyNum = roleItemManager:GetBagEmptyNum(fire.pb.item.BagTypes.BAG)
	print("CheckBagCapacityForItem", emptyNum)
	if num == 1 then
		return emptyNum >= 1
	end
	
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
	if itemAttr and itemAttr.maxNum > 1 then --判断是否可以堆叠
		return emptyNum >= 1
	end
	return emptyNum >= num
end


-------------------------------------------------------------------------
-- RichEditbox
-- @parseText eg:
-- @color  eg:FFFFFFFF
-------------------------------------------------------------------------
function RichEditboxParseTextSetColour(parseText, color)
    local t = {}
    string.gsub(parseText, "<(.-)>", function(w)
	    if string.find(w, "t=") and not string.find(w, "c=") then
		    local tmp = string.match(w, "(.*)/")
		    if tmp then
			    w = tmp .. " c='" .. color .. "'/"
		    else
			    w = w .. " c='" .. color .. "'"
		    end
	    else
		    w = string.gsub(w, "c=['\"].-['\"]", "c='" .. color .. "'")
	    end
	    table.insert(t, "<"..w..">")
    end)
    --print('---------', table.concat(t))
    return table.concat(t)
end

function RichEditboxRelaceWhiteColour(parseText, color)
    local t = {}
    string.gsub(parseText, "<(.-)>", function(w)
	    if string.find(w, "t=") and not string.find(w, "c=") then
		    local tmp = string.match(w, "(.*)/")
		    if tmp then
			    w = tmp .. " c='" .. color .. "'/"
		    else
			    w = w .. " c='" .. color .. "'"
		    end
	    else
		    w = string.gsub(w, "c=['\"][fF]+['\"]", "c='" .. color .. "'")
	    end
	    table.insert(t, "<"..w..">")
    end)
    --print('---------', table.concat(t))
    return table.concat(t)
end


-------------------------------------------------------------------------
-- Item
-------------------------------------------------------------------------
-- 物品ItemCell显示珍品角标，装备不显示
function ShowItemTreasureIfNeed(itemcell, itembaseid)
    local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itembaseid)
    if not itemAttr then
        return
    end

    local conf = nil
    local firstType = itemAttr.itemtypeid % 16

    if firstType == eItemType_PETITEM then
        conf = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(itembaseid)
    end
    if firstType == eItemType_FOOD then
        conf = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(itembaseid)
    end
    if firstType == eItemType_DIMARM then
    end
    if firstType == eItemType_GEM then
        conf = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(itembaseid)
    end
    if firstType == eItemType_GROCERY then
        conf = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(itembaseid)
    end
    if firstType == eItemType_EQUIP_RELATIVE then
        
    end
    if firstType == eItemType_TASKITEM then
        conf = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(itembaseid)
    end

    if conf and conf.id ~= 1 and conf.treasure == 1 and firstType ~= eItemType_EQUIP then
        itemcell:SetCornerImageAtPos("shopui", "zhenpin", 0, 1)
    end
end

function refreshItemCellTypeForHuoban(itemCell, nItemId)
	local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemTable and itemTable.itemtypeid == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
		  itemCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
     end
end

function GetRideEffectId(rideModalId)
	if rideModalId ~= 0 then
        local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cride")
        local ids = rideTable:getAllID()
        for _,id in pairs(ids) do
            local conf = rideTable:getRecorder(id)
            if conf.ridemodel == rideModalId then
				return conf.effectId;
			end
        end
	end
	return -1;
end

function GetRideEffectPos(rideModalId)
	if rideModalId ~= 0 then
        local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cride")
        local ids = rideTable:getAllID()
        for _,id in pairs(ids) do
            local conf = rideTable:getRecorder(id)
            if conf.ridemodel == rideModalId then
				return Nuclear.NuclearPoint(conf.effectPosX, conf.effectPosY);
			end
        end
	end
end

function Depot_ShowSilverCurrency(nNeed, pProtocol, pWidget, bCppProtocol)
	require "logic.item.depot".ShowSilverCurrency(nNeed, pProtocol, pWidget);
	if bCppProtocol then
		CurrencyManager.isCppprotocol();
	end
end

function GetMainPackDlg()
	if (require "logic.item.mainpackdlg":getInstanceOrNot()) == nil then
		return 0;
	else
		return 1;
	end
end

function IsMainPackDlgVisible()
	local pDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if pDlg == nil then
		return 0;
	else
		if pDlg:IsVisible() then
			return 1;
		else
			return 0;
		end
	end
end

function ItemCell_SetImage_renwuui(itemCell, pos)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		itemCell:SetImage("renwuui", pMainPackDlg:GetEquipTabBackImage(pos));
	end
end

function MainPackDlg_GetFirstEmptyCell()
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		return pMainPackDlg:GetFirstEmptyCell();
	end
	return -1;
end

function MainPackDlg_EndUseTaskItem()
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		pMainPackDlg:EndUseTaskItem();
	end
end

function MainPackDlg_EndUseTaskItemOrSetType(dlgState)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		if pMainPackDlg:GetDialogType() == dlgState then
			pMainPackDlg:EndUseTaskItem();
		end
		pMainPackDlg:SetDialogType(dlgState);
	end
end

function MainPackDlg_addEquipEffect(id)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		pMainPackDlg:addEquipEffect(id);
	end
end

function MainPackDlg_GetItemCellByPos(pos, tableType)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		return pMainPackDlg:GetItemCellByPos(pos, tableType);
	end
	return nil;
end

function MainPackDlg_GetEquipItemCellByPos(pos)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		return pMainPackDlg:GetEquipItemCellByPos(pos);
	end
end

function MainPackDlg_GetFirstPage()
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		return pMainPackDlg:GetFirstPage();
	end
	return nil;
end

function MainPackDlg_GetQuestItemPage()
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		return pMainPackDlg:GetQuestItemPage();
	end
	return nil;
end

function MainPackDlg_GetWindowName()
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		return pMainPackDlg:GetWindow():getName();
	end
	return "";
end

function MainPackDlg_HandleUseItem(roleItem)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		pMainPackDlg:HandleUseItem(roleItem);
	end
end

function MainPackDlg_HandleUnequip(roleItem)
	local pMainPackDlg = require "logic.item.mainpackdlg":getInstanceOrNot();
	if(pMainPackDlg)then
		pMainPackDlg:HandleUnequip(roleItem);
	end
end

function RoleItemManager_GetInstance()
	require("logic.item.roleitemmanager").getInstance()
end

function RoleItemManager_DestroyInstance()
	require("logic.item.roleitemmanager").destroyInstance()
end

function RoleItemManager_GetPackMoney()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:GetPackMoney()
end

function RoleItemManager_GetReserveMoney()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:GetReserveMoney()
end

function RoleItemManager_IsBagFull(badid)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:IsBagFull(badid)
end

function RoleItemManager_GetItemCellAtBag(baseID)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:GetItemCellAtBag(baseID)
end

function RoleItemManager_GetItemCellAtQuestBag(baseID)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:GetItemCellAtQuestBag(baseID)
end

function RoleItemManager_GetItemCellAtQuestBag(baseID)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:GetItemCellAtQuestBag(baseID)
end

function RoleItemManager_DestroyItem()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:DestroyItem()
end

function RoleItemManager_ClearBag(badid)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:ClearBag(badid)
end

function RoleItemManager_CheckEquipEffect()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:CheckEquipEffect()
end

function RoleItemManager_SetPackMoney(money)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:SetPackMoney(money)
end

function RoleItemManager_SetDeportMoney(money)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:SetDeportMoney(money)
end

function RoleItemManager_SetGold(gold)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:SetGold(gold)
end


function RoleItemManager_SetMoneyByMoneyType(moneyType, count)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:SetMoneyByMoneyType(moneyType, count)
end

function RoleItemManager_SetBagCapacity(bagid, capacity)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:SetBagCapacity(bagid, capacity)
end

function RoleItemManager_AddItem(bagid, id, flags, key, position, number, timeout, isnew, loseeffecttime, markettime)
	local data = require("protodef.rpcgen.fire.pb.item"):new()
    data.id = id
    data.flags = flags
    data.key = key
    data.position = position
    data.number = number
    data.timeout = timeout
    data.isnew = isnew
    data.loseeffecttime = loseeffecttime
    data.markettime = markettime

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    return roleItemManager:AddItem(bagid, data)
end

function FireProtocol_COneKeyApplyTeamInfo(teamid)
	CChatOutBoxOperatelDlg.bOpenChatWnd = false
	local p = require('protodef.fire.pb.team.conekeyapplyteaminfo').Create()
    p.teamid = tonumber(teamid)
	LuaProtocolManager:send(p)
end

-- ItemTable --

function CalTableSize(table, cellCount)
	local colCount = table:GetColCount();
	local rowNum = math.ceil(cellCount / colCount);

	local size = table:getPixelSize();
	local cellH = table:GetCellHeight();

	local lastShowRowFirstCellIndex = (rowNum -1) * colCount;
	local lastShowRowFirstCell = table:GetCell(lastShowRowFirstCellIndex);
	local cellY = lastShowRowFirstCell:getYPosition().offset;

	local tableHeight = cellY + cellH;
	return CEGUI.UVector2(CEGUI.UDim(0, size.width), CEGUI.UDim(0, tableHeight));
end

-- ItemTable --

----------------------------------------------------------------------

function MainPetDataManager_AddMyPet(pet, columnid)
    local petData = require("logic.pet.mainpetdata"):new()
    local data = tolua.cast(pet, "fire::pb::Pet")
    petData:initWithCplusplus(data)
    require("logic.pet.mainpetdatamanager").getInstance():AddMyPet(petData, columnid)
end

function MainPetDataManager_SetMyPetData_Zizhi(petkey, columnid, key, value)
    local petData = require("logic.pet.mainpetdatamanager").getInstance():FindMyPetByID(petkey, columnid)
    if petData then
        petData:setZizhi(key, value)
    end
end

function MainPetDataManager_SetMyPetData_Skillexpires(petkey, columnid, key, value)
    local petData = require("logic.pet.mainpetdatamanager").getInstance():FindMyPetByID(petkey, columnid)
    if petData then
        petData:setPetSkillExpires(key, tonumber(value))
    end
end

function MainPetDataManager_SetMyPetData_Skilllist(petkey, columnid, skillid, skillexp, skilltype, certification)
    local petData = require("logic.pet.mainpetdatamanager").getInstance():FindMyPetByID(petkey, columnid)
    if petData then
        require "protodef.rpcgen.fire.pb.petskill"
        local petSkill = Petskill:new()
        petSkill.skillid = skillid
        petSkill.skillexp = skillexp
        petSkill.skilltype = skilltype
        petSkill.certification = certification
        table.insert(petData.petskilllist, petSkill)
    end
end

----------------------------------------------------------------------

function MainPetDataManager_ClearPetList(columnid)
    require("logic.pet.mainpetdatamanager").getInstance():ClearPetList(columnid)
end

function MainPetDataManager_ClearBattlePetOfEndBattleScene()
    require("logic.pet.mainpetdatamanager").getInstance():ClearBattlePetOfEndBattleScene()
end

function MainPetDataManager_UpdateBattlePetAttribute(key, value)
    require("logic.pet.mainpetdatamanager").getInstance():UpdateBattlePetAttribute(key, value)
end

function MainPetDataManager_UpdateBattlePetHpChange(hpChange, hpmaxChange)
    require("logic.pet.mainpetdatamanager").getInstance():UpdateBattlePetHpChange(hpChange, hpmaxChange)
end

function MainPetDataManager_UpdateBattlePetMpChange(mpChange, mpmaxChange)
    require("logic.pet.mainpetdatamanager").getInstance():UpdateBattlePetMpChange(mpChange, mpmaxChange)
end

function MainPetDataManager_SetBattlePetState(state)
    require("logic.pet.mainpetdatamanager").getInstance():SetBattlePetState(state)
end

function MainPetDataManager_ResetPetState()
    require("logic.pet.mainpetdatamanager").getInstance():ResetPetState()
end

function MainPetDataManager_SetMaxPetNum(num)
    require("logic.pet.mainpetdatamanager").getInstance():SetMaxPetNum(num)
end

function MainPetDataManager_BattlePetIsMyPackPet()
    return require("logic.pet.mainpetdatamanager").getInstance():BattlePetIsMyPackPet()
end

function MainPetDataManager_IsMyPetFull()
    return require("logic.pet.mainpetdatamanager").getInstance():IsMyPetFull()
end

function MainPetDataManager_AddScenePetIfShowPetExist()
    require("logic.pet.mainpetdatamanager").getInstance():AddScenePetIfShowPetExist()
end

----------------------------------------------------------------------

-- 设置选服界面按钮是否可点击
function SelectServerEntry_EnableClick(enable)
    local dlg = require("logic.selectserverentry").getInstanceNotCreate()
    if dlg then
        dlg:enableClick(enable)
        return true
    end
    return false
end

----------------------------------------------------------------------

-- SDK界面切换账号回调，触发调用游戏内的“切换账号”
function Logout_CalledBySdk()
    LogInfo("Logout_CalledBySdk")
    local gameState = (gGetStateManager() and gGetStateManager():getGameState() or eGameStateNull)
    if gameState == eGameStateLogin or gameState == eGameStateNull then
        local dlg = require("logic.createroledialog"):getInstanceOrNot()
        if dlg then  --如果当前是人物创建界面的逻辑
            dlg:HandleReturnBtnClicked(nil)
        end
        return
    end

    local p = require("protodef.fire.pb.creturntologin"):new()
	LuaProtocolManager:send(p)
    local huodongmanager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if huodongmanager then
        huodongmanager:OpenPush()
    end
end

----------------------------------------------------------------------

function NewRoleGuideManager_GetInstance()
	require("logic.guide.newroleguidemanager").getInstance()
end

function NewRoleGuideManager_DestroyInstance()
	require("logic.guide.newroleguidemanager").destroyInstance()
end

function NewRoleGuideManager_FinishGuideInBattle()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:FinishGuideInBattle()
end

function NewRoleGuideManager_FinishGuide()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:FinishGuide()
end

function NewRoleGuideManager_IsBattleGuideFinsh(battleId, roundId)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:isBattleGuideFinsh(battleId, roundId)
end

function NewRoleGuideManager_GuideStartBattle(battleId, roundId)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:GuideStartBattle(battleId, roundId)
end

function NewRoleGuideManager_GetGuideModel()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:getGuideModel()
end

function NewRoleGuideManager_RemoveGuidePaticleEffect(pEffect)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:RemoveGuidePaticleEffect(tolua.cast(pEffect, "Nuclear::IEffect"))
end

function NewRoleGuideManager_UpdateGuidePaticleEffect(pEffect, pWnd)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:UpdateGuidePaticleEffect(tolua.cast(pEffect, "Nuclear::IEffect"), tolua.cast(pWnd, "CEGUI::Window"))
end

function NewRoleGuideManager_IsClickInvalidWhenLockScreen(x, y)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    local bClickInvalid = newroleguidemanager:NeedLockScreen() and (not newroleguidemanager:isClickInRect(x,y)) and newroleguidemanager:isTargetInDlg()
    return bClickInvalid
end

function NewRoleGuideManager_GetClickRect(id)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:GetClickRect(id)
end

function NewRoleGuideManager_GetCurGuideId()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:getCurGuideId()
end

function NewRoleGuideManager_IsPlayingAni()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:isPlayingAni()
end

function NewRoleGuideManager_NeedLockScreen()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:NeedLockScreen()
end

function NewRoleGuideManager_Run(elapse)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:Run(elapse)
end

function NewRoleGuideManager_IsGuideFinish(id)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:isGuideFinish(id)
end

function NewRoleGuideManager_GuideLevel(level)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:GuideLevel(level)
end

function NewRoleGuideManager_CheckTargetWindow()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:CheckTargetWindow()
end

function NewRoleGuideManager_FailGuide()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:FailGuide()
end

function NewRoleGuideManager_ShowLockEffect()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:ShowLockEffect()
end

function NewRoleGuideManager_GetGuideClickWnd(id, name)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:GetGuideClickWnd(id, name)
end

function NewRoleGuideManager_AddToWaitingList(id, clickName, highlightName)
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    newroleguidemanager:AddToWaitingList(id, clickName, highlightName)
end

function NewRoleGuideManager_GetLuaGetWindow()
	local newroleguidemanager = require("logic.guide.newroleguidemanager").getInstance()
    return newroleguidemanager:getLuaGetWindow()
end

----------------------------------------------------------------------

function RoleSkillManager_DrawEffect()
	local roleskillmanager = require("logic.skill.roleskillmanager").getInstance()
    roleskillmanager:DrawEffect()
end

function RoleSkillManager_AddNewGuideEffect(x, y)
	local roleskillmanager = require("logic.skill.roleskillmanager").getInstance()
    roleskillmanager:AddNewGuideEffect(Nuclear.NuclearPoint(x,y))
end

----------------------------------------------------------------------

function IsPointCardServer()
    local mgr = require("logic.pointcardserver.pointcardservermanager").getInstanceNotCreate()
    return mgr and mgr.m_isPointCardServer
end

function getHuodongDlg()
    local dlg = nil
    if IsPointCardServer() then
        dlg = require("logic.huodong.huodongdlgpay")
    else
        dlg = require("logic.huodong.huodongdlg")
    end
    return dlg
end

--点卡服时替换为相应的表
local _pointCardTable = {
    ["shop.cgoods"] = "shop.dcgoods",
    ["shop.cmallshop"] = "shop.dcmallshop",
    ["shop.cmarketfirsttable"] = "shop.dcmarketfirsttable",
    ["shop.cmarketsecondtable"] = "shop.dcmarketsecondtable",
    ["shop.cmarketthreetable"] = "shop.dcmarketthreetable",
    ["shop.cnpcsale"] = "shop.dcnpcsale",
    ["shop.ccommercefirstmenu"] = "shop.dccommercefirstmenu",
    ["shop.ccommercesecondmenu"] = "shop.dccommercesecondmenu",
    ["shop.cmallshoptabname"] = "shop.dcmallshoptabname",
	["mission.cguidecourse"] = "mission.cguidecoursepay",
    ["team.cteamlistinfo"] = "team.dcteamlistinfo",
    ["item.cequipcombin"] = "item.dcequipcombin",
    ["treasuremap.ceventconfig"] = "treasuremap.ceventconfigpay",
    ["shop.cquickbuy"] = "shop.cquickbuypay",
    ["login.clogintips"] = "login.clogintipsdianka",
    ["game.cshouchonglibao"] = "game.cshouchonglibaopay",
    ["game.cshareconfig"] = "game.cshareconfigpay"
}
function CheckTableName(tableName)
    if IsPointCardServer() then
        return _pointCardTable[tableName] or tableName
    end
    return tableName
end

----------------------------------------------------------------------

function MT3HeroManager_Initialize()
	local mt3heromanager = require("manager.mt3heromanager").getInstance()
    mt3heromanager:initialize()
end

function MT3HeroManager_PurgeData()
	local mt3heromanager = require("manager.mt3heromanager").getInstance()
    mt3heromanager:purgeData()
end

----------------------------------------------------------------------

function TaskManager_CToLua_SetTime(time)
	if GetTaskManager() and GetTaskManager():GetClearQuestTime() == 0 then
		GetTaskManager():SetClearQuestTime(time)
	end
end

function TaskManager_CToLua_ResetCurMainTaskNpcState()
	if GetTaskManager() then
		GetTaskManager():resetCurMainTaskNpcState()
	end
end

function TaskManager_CToLua_CheckAreaQuest()
	if GetTaskManager() then
		GetTaskManager():CheckAreaQuest()
	end
end

function TaskManager_CToLua_GetNpcStateByID(npckey, npcbaseid)
	if GetTaskManager() then
		return GetTaskManager():GetNpcStateByID(npckey, npcbaseid)
	end
    return eNpcMissionNoQuest
end

----------------------------------------------------------------------

function WelfareManager_OnLeveUpRefreshData()
    if gGetWelfareManager() then
	    gGetWelfareManager():onLeveUpRefreshData()
    end
end

----------------------------------------------------------------------

function  SelectServerEntry_YingYongBaoShow()
    local dlg = require("logic.selectserverentry").getInstanceAndShow()
    if dlg then
        dlg:SetYingyongBaoVisible(true)
        dlg:SetEnterGameVisible(false)
        return true
    end
    return false
end

function  SelectServerEntry_YingYongBaoHide()
    local dlg = require("logic.selectserverentry").getInstanceAndShow()
    if dlg then
        dlg:SetYingyongBaoVisible(false)
        dlg:SetEnterGameVisible(true)
        return true
    end
    return false
end

--充值成功后，应用宝请求符石信息
function YYB_RequestFushi()
    local p = require("protodef.fire.pb.fushi.creqfushiinfo"):new()
	LuaProtocolManager:send(p)
end

function SetRoleCreatTime(rolecreatetime)
    ROLE_CREATE_TIME = rolecreatetime
end

function GetRoleCreateTime()
    return math.floor(ROLE_CREATE_TIME/1000)
end

function SetBagOffset(offset)
    gCommon.bagOffset  = offset
end

function GetBagOffset()
    return gCommon.bagOffset 
end

 --获取是否在公会战中
function GetIsInFamilyFight()
    if gGetScene() then
        local curmapId = gGetScene():GetMapID()
        local mapRecord = BeanConfigManager.getInstance():GetTableByName("clan.cclanfight"):getRecorder(200)
        if mapRecord then
            if curmapId == mapRecord.mapid then
                return  true
            end
        end
    end

    return false
end
