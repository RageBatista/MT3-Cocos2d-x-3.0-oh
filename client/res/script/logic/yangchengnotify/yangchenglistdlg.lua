require "logic.dialog"
require "logic.logo.logoinfodlg"

local TYPE_ROLE_POINT_ADD = "rolePointAdd"
local TYPE_PET_POINT_ADD = "petPointAdd"
local TYPE_SKILL_POINT_ADD = "skillPointAdd"
local TYPE_HUOYUEDU_POINT_ADD = "huoyueduAdd"
local TYPE_ZHENFA_ADD = "zhenfaAdd"
local TYPE_XIULI = "xiuli"




YangChengListDlg = { }
setmetatable(YangChengListDlg, Dialog)
YangChengListDlg.__index = YangChengListDlg

YangChengListDlg.nTypeXiuliKey = 6
YangChengListDlg.fEndurePercent = 0.1

notify_cells = { [1] = "0", [2] = "0", [3] = "0", [4] = "0", [5] = "0",[6]="0" }
local isInit = 0
local zfItemID = -1

local _instance
function YangChengListDlg.getInstance()
    if not _instance then
        _instance = YangChengListDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function YangChengListDlg.getInstanceAndShow()
    if not _instance then
        _instance = YangChengListDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function YangChengListDlg.getInstanceNotCreate()
    return _instance
end

function YangChengListDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function YangChengListDlg.ToggleOpenClose()
    if not _instance then
        _instance = YangChengListDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function YangChengListDlg.GetLayoutFileName()
    return "yangchengtixing.layout"
end

function YangChengListDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, YangChengListDlg)
    return self
end

function YangChengListDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_MainFrame = winMgr:getWindow("yangchengtixing")
    self.m_basePane = CEGUI.Window.toScrollablePane(winMgr:getWindow("yangchengtixing/liebiao"))

    self.wndcells = { }
    self.dlgCellHeight = 0
    self.dlgCellWidth = 0
    local cellIndex = 0

    for k, v in ipairs(notify_cells) do
        if v ~= "0" then
            local cell = winMgr:loadWindowLayout("yangchengtixingcell.layout", k)
            local cellColse = CEGUI.toPushButton(winMgr:getWindow(k .. "yangchengtixingcell/guanbi"))
            local text = winMgr:getWindow(k .. "yangchengtixingcell/wenben")
            local cellWidth = cell:getPixelSize().width
            local cellHeight = cell:getPixelSize().height
            self.dlgCellWidth = cellWidth * 1.06 - 1
            self.dlgCellHeight = cellHeight
            text:setText(BeanConfigManager.getInstance():GetTableByName("game.cnotifyconfig"):getRecorder(k).text)
            cell:setUserString("cellBindString", tostring(v))
            cellColse:setUserString("cellBindString", tostring(v))
            cell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5, - cellWidth * 0.55), CEGUI.UDim(0, cellIndex * cellHeight)))
            self.m_basePane:addChildWindow(cell)

            cell:subscribeEvent("MouseClick", YangChengListDlg.handleCellClick, self)
            cellColse:subscribeEvent("Clicked", YangChengListDlg.handleCellClose, self)

            cellIndex = cellIndex + 1

            self.wndcells[k] = cell
        end
    end

    self:setFrameSize(cellIndex)
end

function YangChengListDlg:setFrameSize(count)
    if count <= 4 then
        self.m_MainFrame:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.dlgCellWidth), CEGUI.UDim(0, self.dlgCellHeight * 0.42 + self.dlgCellHeight * count)))
        self.m_basePane:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.dlgCellWidth), CEGUI.UDim(0, self.dlgCellHeight * count)))
    else
        self.m_MainFrame:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.dlgCellWidth), CEGUI.UDim(0, self.dlgCellHeight * 0.42 + self.dlgCellHeight * 4)))
        self.m_basePane:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.dlgCellWidth), CEGUI.UDim(0, self.dlgCellHeight * 4)))
    end
end

function YangChengListDlg.setInit(value)
    isInit = value
end

function YangChengListDlg.GameStartInitCell(index)

    if index == 1 then
        -- 人物加点
        local data = gGetDataManager():GetMainCharacterData()

        local ptAdded = data:GetValue(10) + data:GetValue(20) + data:GetValue(30) + data:GetValue(40) + data:GetValue(50)
        local level = data:GetValue(1230)
        local totalPoint = level * 10

        if totalPoint > ptAdded then
            if not YangChengListDlg.checkDataInTable(TYPE_ROLE_POINT_ADD) then
                notify_cells[1] = TYPE_ROLE_POINT_ADD
                YangChengListDlg.notifyLogoChangeStatus(true)
            end
        end
    elseif index == 2 then
        -- 宠物加点
        local num = MainPetDataManager.getInstance():GetPetNum()
        local allPetPointClear = true
        for i = 1, num do
            local petData = MainPetDataManager.getInstance():getPet(i)
            local petPoint = petData:getAttribute(fire.pb.attr.AttrType.POINT)
            if petPoint > 0 then
                allPetPointClear = false
                break
            end
        end

        if not allPetPointClear then
            if not YangChengListDlg.checkDataInTable(TYPE_PET_POINT_ADD) then
                notify_cells[2] = TYPE_PET_POINT_ADD
                YangChengListDlg.notifyLogoChangeStatus(true)
            end
        end

    elseif index == 3 then
        -- 公会（门-派）技能
        if not(require "logic.xingongnengkaiqi.xingongnengopendlg".checkFeatureOpened(4)) then return end

        if not YangChengListDlg.checkAllLevelIsFull() then
            if not YangChengListDlg.checkDataInTable(TYPE_SKILL_POINT_ADD) then
                notify_cells[3] = TYPE_SKILL_POINT_ADD
                YangChengListDlg.notifyLogoChangeStatus(true)
            end
        end

    elseif index == 4 then
        -- 活力超阈值
        local data = gGetDataManager():GetMainCharacterData()
        local hl = data:GetValue(fire.pb.attr.AttrType.ENERGY)
        local hlLimit = data:GetValue(fire.pb.attr.AttrType.ENLIMIT)

        local value = GameTable.common.GetCCommonTableInstance():getRecorder(164).value
        if hl > math.floor(hlLimit * value) then
            if not YangChengListDlg.checkDataInTable(TYPE_HUOYUEDU_POINT_ADD) then
                notify_cells[4] = TYPE_HUOYUEDU_POINT_ADD
                YangChengListDlg.notifyLogoChangeStatus(true)
            end
        end

    elseif index == 5 then
        -- 光环提升
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local bookinbag = roleItemManager:GetItemTotalNumByTypeID(ITEM_TYPE.FORMATION_BOOK, fire.pb.item.BagTypes.BAG)
        if bookinbag > 0 then
            if not YangChengListDlg.checkDataInTable(TYPE_ZHENFA_ADD) then
                notify_cells[5] = TYPE_ZHENFA_ADD
                YangChengListDlg.notifyLogoChangeStatus(true)
            end
        end
    end

end

function YangChengListDlg.checkEquipTishiXiuli(itemData)
    if not itemData then
        return
    end

    if itemData:GetFirstType() ~= eItemType_EQUIP then
        return
    end

    local equipObj = itemData:GetObject() 
    if not equipObj then
        return
    end
	local nEndureMax = equipObj.endureuplimit
    local nCurEndure = equipObj.endure
    if nCurEndure < nEndureMax*YangChengListDlg.fEndurePercent then
        if nCurEndure==0 then
            MainControl.ShowBtnInFirstRow(MainControlBtn_Repair)
        end
        YangChengListDlg.notifyXiuliEquip()
    end
    -- YangChengListDlg.refreshBroken()
    if nCurEndure <= 0 then 
        MainControl.ShowBtnInFirstRow(MainControlBtn_Repair)
    end

end



function YangChengListDlg.refreshBroken()
    local bBroken = true
    local bVisible = false
    local nBagId,nItemKey = require("logic.workshop.workshopmanager").getToXiuliItemBagAndKey(bBroken)
    if nBagId ==-1 then
        bVisible = false
    else
        bVisible = true
    end

    MainControl.ShowBtnInFirstRow(MainControlBtn_Repair, bVisible)
end

function YangChengListDlg.refreshTixingXiuli()
    local nBagId,nItemKey = require("logic.workshop.workshopmanager").getToXiuliItemBagAndKey()
    if nBagId ==-1 then
        YangChengListDlg.dealwithXiuliEquipStatus()
    else
          YangChengListDlg.notifyXiuliEquip()
    end
    YangChengListDlg.refreshBroken()
end

function YangChengListDlg.GameStartInitCell_xiuli()
        local nBagId,nItemKey = require("logic.workshop.workshopmanager").getToXiuliItemBagAndKey()
        if nBagId ==-1 then
             return
        end
        if not YangChengListDlg.checkDataInTable(TYPE_XIULI) then
              notify_cells[YangChengListDlg.nTypeXiuliKey] = TYPE_XIULI
              YangChengListDlg.notifyLogoChangeStatus(true)
        end
         YangChengListDlg.refreshBroken()
end

-- 点击不同的cell跳转到不同的界面
function YangChengListDlg:handleCellClick(e)
    local e = CEGUI.toWindowEventArgs(e)
    local cellType = e.window:getUserString("cellBindString")

    if cellType == TYPE_ROLE_POINT_ADD then
        -- 打开人物加点界面
        require "logic.characterinfo.characterlabel".Show(3)
    elseif cellType == TYPE_PET_POINT_ADD then
        -- 打开宠物加点界面
        local num = MainPetDataManager.getInstance():GetPetNum()

        for i = 1, num do
            local petData = MainPetDataManager.getInstance():getPet(i)
            if petData then
                local point = petData:getAttribute(fire.pb.attr.AttrType.POINT)
                if point ~= 0 then
                    local dlg = require('logic.pet.petaddpointdlg').getInstanceAndShow()
                    dlg:setPetData(petData)
                    break
                end
            end
        end

    elseif cellType == TYPE_SKILL_POINT_ADD then
        -- 打开技能升级界面
        require "logic.skill.skilllable".Show(1)
    elseif cellType == TYPE_ZHENFA_ADD then
        -- 打开光环学习界面
        if zfItemID ~= -1 then
	        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            if roleItemManager:GetItemTotalNumByTypeID(ITEM_TYPE.FORMATION_BOOK, fire.pb.item.BagTypes.BAG) > 0 then
                if roleItemManager:GetItemTotalNumByBaseID(zfItemID, fire.pb.item.BagTypes.BAG) > 0 then
                    require "logic.zhenfa.zhenfadlg".useZhenfaBookItemFromBag(zfItemID)
                else
                    local vItemList = roleItemManager:GetItemListByType(ITEM_TYPE.FORMATION_BOOK, fire.pb.item.BagTypes.BAG)
                    for i=0, vItemList:size()-1 do
                       require "logic.zhenfa.zhenfadlg".useZhenfaBookItemFromBag(vItemList[i]:GetObjectID())
                       break
                    end
                end
            else
                require "logic.zhenfa.zhenfadlg".getInstanceAndShow()
            end
        else
            require "logic.zhenfa.zhenfadlg".getInstanceAndShow()
        end
    elseif cellType == TYPE_HUOYUEDU_POINT_ADD then
        -- 活力界面
        require "logic.skill.strengthusedlg".getInstanceAndShow()
    elseif cellType == TYPE_XIULI then
        local nBagId,nItemKey = require("logic.workshop.workshopmanager").getToXiuliItemBagAndKey()
        if nBagId ==-1 then
            return
        end
        local Openui = require("logic.openui")
        Openui.OpenUI(Openui.eUIId.zhuangbeixiuli_08, nBagId, nItemKey)

    end
end

function YangChengListDlg:handleCellClose(e)
    local e = CEGUI.toWindowEventArgs(e)
    local cellType = e.window:getUserString("cellBindString")

    local closeType = YangChengListDlg.removeTheType(cellType)
    if closeType ~= -1 then
        if YangChengListDlg.nTypeXiuliKey ~= closeType then
            SystemSettingNewDlg.sendGameConfig(20 + closeType - 1, 0)
        end
        if YangChengListDlg.nTypeXiuliKey == closeType then
             local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
             SystemSettingNewDlg.sendGameConfig(SettingEnum.equipendure, 0)
        end
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    local bg = CEGUI.Window.toScrollablePane(winMgr:getWindow("yangchengtixing/liebiao"))
    bg:removeChildWindow(e.window:getParent())
    winMgr:destroyWindow(e.window:getParent())

    YangChengListDlg.resetCellsPos()

    local cellCount = 0
    for _, v in pairs(notify_cells) do
        if v ~= "0" then
            cellCount = cellCount + 1
        end
    end

    if cellCount == 0 then
        YangChengListDlg.notifyLogoChangeStatus(false)
        self:DestroyDialog()
    else
        self:setFrameSize(cellCount)
    end
end

function YangChengListDlg.notifyShowDlg()
    if not _instance then
        YangChengListDlg.getInstanceAndShow()
    end
    _instance:SetVisible(true)
end

function YangChengListDlg.notifyHideDlg()
    if not _instance then
        return
    end
    _instance:SetVisible(false)
end

function YangChengListDlg.notifyXiuliEquip()
    if isInit == 0 or YangChengListDlg.checkDataInTable(TYPE_XIULI) then
        return
    end

    notify_cells[YangChengListDlg.nTypeXiuliKey] = TYPE_XIULI
    YangChengListDlg.notifyLogoChangeStatus(true)
    --YangChengListDlg.sendCellStatus(1, 1)

    local flag =1
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    SystemSettingNewDlg.sendGameConfig(SettingEnum.equipendure, flag)

end

-- 人物加点
function YangChengListDlg.nofityRolePointAdd()
    if isInit == 0 or YangChengListDlg.checkDataInTable(TYPE_ROLE_POINT_ADD) then
        return
    end

    notify_cells[1] = TYPE_ROLE_POINT_ADD
    YangChengListDlg.notifyLogoChangeStatus(true)
    YangChengListDlg.sendCellStatus(1, 1)
end

-- 宠物加点
function YangChengListDlg.notifyPetPointAdd()
    if isInit == 0 or YangChengListDlg.checkDataInTable(TYPE_PET_POINT_ADD) then
        return
    end

    notify_cells[2] = TYPE_PET_POINT_ADD
    YangChengListDlg.notifyLogoChangeStatus(true)
    YangChengListDlg.sendCellStatus(2, 1)
end

-- 提升技能
function YangChengListDlg.notifySkillAdd()
    if not(require "logic.xingongnengkaiqi.xingongnengopendlg".checkFeatureOpened(4)) then return end

    if isInit == 0 or YangChengListDlg.checkDataInTable(TYPE_SKILL_POINT_ADD) then
        return
    end

    if YangChengListDlg.checkAllLevelIsFull() then return end

    notify_cells[3] = TYPE_SKILL_POINT_ADD


    YangChengListDlg.notifyLogoChangeStatus(true)
    YangChengListDlg.sendCellStatus(3, 1)
end



-- 活跃度提升
function YangChengListDlg.notifyHuoyueduAdd()
    if isInit == 0 or YangChengListDlg.checkDataInTable(TYPE_HUOYUEDU_POINT_ADD) then
        return
    end

    notify_cells[4] = TYPE_HUOYUEDU_POINT_ADD
    YangChengListDlg.notifyLogoChangeStatus(true)
    YangChengListDlg.sendCellStatus(4, 1)
end

-- 光环提升
function YangChengListDlg.notifyZhenFaAdd(itemID)
    zfItemID = itemID

    if isInit == 0 or YangChengListDlg.checkDataInTable(TYPE_ZHENFA_ADD) then
        return
    end

    notify_cells[5] = TYPE_ZHENFA_ADD
    YangChengListDlg.notifyLogoChangeStatus(true)
    YangChengListDlg.sendCellStatus(5, 1)
end


----------------------------------------------------
--- 处理cell点击后的事件，是否删除cell
-----------------------------------------------------

function YangChengListDlg.dealwithXiuliEquipStatus()
    if YangChengListDlg.checkDataInTable(TYPE_XIULI)  then
        YangChengListDlg.removeTheType(TYPE_XIULI)
    end
end


-- 人物点数有变化后检测cell是否应该消失，如果当前table存在，并且点数为0则应该清楚cell
function YangChengListDlg.dealwithRoleAddpointStatus()
    local data = gGetDataManager():GetMainCharacterData()
    local curPoint = data:GetValue(fire.pb.attr.AttrType.POINT)
    if YangChengListDlg.checkDataInTable(TYPE_ROLE_POINT_ADD) and curPoint == 0 then
        YangChengListDlg.removeTheType(TYPE_ROLE_POINT_ADD)
    end
end

function YangChengListDlg.dealwithPetAddpointStatus()
    local num = MainPetDataManager.getInstance():GetPetNum()
    local allPetPointClear = true
    for i = 1, num do
        local petData = MainPetDataManager.getInstance():getPet(i)
        local petPoint = petData:getAttribute(fire.pb.attr.AttrType.POINT)
        if petPoint > 0 then
            allPetPointClear = false
            break
        end
    end

    if YangChengListDlg.checkDataInTable(TYPE_PET_POINT_ADD) and allPetPointClear then
        YangChengListDlg.removeTheType(TYPE_PET_POINT_ADD)
    end
end

function YangChengListDlg.dealwithSkillPoint()
    if not YangChengListDlg.checkAllLevelIsFull() then return end

    if YangChengListDlg.checkDataInTable(TYPE_SKILL_POINT_ADD) then
        YangChengListDlg.removeTheType(TYPE_SKILL_POINT_ADD)
    end
end

function YangChengListDlg.dealwithZhenfaUse()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local bookinbag = roleItemManager:GetItemTotalNumByTypeID(ITEM_TYPE.FORMATION_BOOK, fire.pb.item.BagTypes.BAG)

    if YangChengListDlg.checkDataInTable(TYPE_ZHENFA_ADD) and bookinbag == 0 then
        YangChengListDlg.removeTheType(TYPE_ZHENFA_ADD)
    end
end

function YangChengListDlg.dealwithHuoyueduChange()
    if YangChengListDlg.checkDataInTable(TYPE_HUOYUEDU_POINT_ADD) then
        YangChengListDlg.removeTheType(TYPE_HUOYUEDU_POINT_ADD)
    end
end

--------通知logoinfo 如果有cell显示 则在logoinfo中显示图标和红点
function YangChengListDlg.notifyLogoChangeStatus(status)
    local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:setTishengSts(status)
	end 
end

function YangChengListDlg.sendCellStatus(index, flag)
    SystemSettingNewDlg.sendGameConfig(20 + index - 1, flag)
end

function YangChengListDlg.resetCellsPos()
    local cellIndex = 0
    for k, v in pairs(_instance.wndcells) do
        local cellWidth = v:getPixelSize().width
        local cellHeight = v:getPixelSize().height
        v:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5, - cellWidth * 0.55), CEGUI.UDim(0, cellIndex * cellHeight)))
        cellIndex = cellIndex + 1
    end
end


function YangChengListDlg.checkDataInTable(type)
    for k, v in pairs(notify_cells) do
        if v == type then
            return true
        end
    end

    return false
end

function YangChengListDlg.removeTheType(type)
    local typeID = -1
    for k, v in pairs(notify_cells) do
        if v == type then
            notify_cells[k] = "0"
            typeID = k
            if _instance then
                _instance.wndcells[k] = nil
            end
            break
        end
    end

    local cellCount = 0
    for k, v in pairs(notify_cells) do
        if v ~= "0" then
            cellCount = cellCount + 1
        end
    end

    if cellCount == 0 then
        YangChengListDlg.notifyLogoChangeStatus(false)
    end
    return typeID
end

function YangChengListDlg.checkAllLevelIsFull()
    local acupointVec = RoleSkillManager.getInstance():GetRoleAcupointVec()
    local m_acupointMap = { }
    local pointSize = #acupointVec
    local pointID = nil
    local pointLevel = nil
    for i = 0, pointSize - 1 do
        if i % 2 == 0 then
            pointID = acupointVec[i+1]
        else
            pointLevel = acupointVec[i+1]
            local localTbl = { }
            localTbl.pointID = pointID
            localTbl.pointLevel = pointLevel
            table.insert(m_acupointMap, localTbl)
        end
    end

    local data = gGetDataManager():GetMainCharacterData()
    local roleLevel = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local MAX_SKILLNUM = 9
    local isFullLevel = true

    for i = 1, MAX_SKILLNUM do
        local tb = m_acupointMap[i]
        if tb then
            local pointID = tb.pointID
            --local acupointInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(tb.pointID)
            local acupointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(tb.pointID)
			if acupointInfo then
	            -- 判断该技能是否已解锁
	            if require "logic.skill.characterskillupdatedlg":checkSkillLearned(tb.pointID) then
	                if not acupointInfo.isJueji then
	                    -- 不是绝技 如果小于人物等级则有提示
	                    if tb.pointLevel < roleLevel then
	                        isFullLevel = false
	                        break
	                    end
	                end
	            end
	
	            -- 判断是不是绝技
	            if acupointInfo.isJueji then break end
			end
        end
    end

    return isFullLevel
end

function YangChengListDlg.Clean()
    YangChengListDlg.setInit(0)
    notify_cells = { [1] = "0", [2] = "0", [3] = "0", [4] = "0", [5] = "0" ,[6]="0"}
end

return YangChengListDlg
