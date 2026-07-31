require "logic.dialog"
require "logic.redpack.redpackcelldlg"
require "logic.redpack.redpackhistorylabel"

RedPackDlg = {}
setmetatable(RedPackDlg, Dialog)
RedPackDlg.__index = RedPackDlg

local _instance
local TYPE_WORLD = 1 --世界红包
local TYPE_CLAN = 2 --公会红包
local TYPE_TEAM = 3 --队伍红包

function RedPackDlg.getInstance()
	if not _instance then
		_instance = RedPackDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RedPackDlg.getInstanceAndShow()
	if not _instance then
		_instance = RedPackDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackDlg.getInstanceNotCreate()
	return _instance
end

function RedPackDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RedPackDlg.ToggleOpenClose()
	if not _instance then
		_instance = RedPackDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RedPackDlg.GetLayoutFileName()
	return "hongbaojiemian1.layout"
end

function RedPackDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackDlg)
	return self
end

function RedPackDlg:OnCreate()
	Dialog.OnCreate(self) 
    self:GetWindow():setRiseOnClickEnabled(false)
	local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionOfWindowWithLabel(self:GetWindow())
    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", RedPackLabel.hide, nil)

    self.m_Title = winMgr:getWindow("hongbaozhujiemian")
    self.m_List = winMgr:getWindow("hongbaozhujiemian/list")
    self.m_SendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("hongbaozhujiemian/anniu1"))
    self.m_SendBtn:subscribeEvent("MouseClick", RedPackDlg.HandleSendClicked, self)
    self.m_DesBtn = CEGUI.Window.toPushButton(winMgr:getWindow("hongbaozhujiemian/tanhao"))
    self.m_DesBtn:subscribeEvent("MouseClick", RedPackDlg.HandleDesClicked, self)
    self.m_HistoryBtn = CEGUI.Window.toPushButton(winMgr:getWindow("hongbaozhujiemian/lishijilu"))
    self.m_HistoryBtn:subscribeEvent("MouseClick", RedPackDlg.HandleHistoryClicked, self)
    self.m_Cover = winMgr:getWindow("hongbaozhujiemian/cover")
    self.m_wenzi = winMgr:getWindow("hongbaozhujiemian/wenzi")
    self.m_notHas = winMgr:getWindow("hongbaozhujiemian/kuang")
    self.m_notHas1 = winMgr:getWindow("hongbaozhujiemian/renwutu")
    self.m_Cover:setVisible(false)
    local s = self.m_List:getPixelSize()
	self.m_TableView = TableView.create(self.m_List)
	self.m_TableView:setViewSize(s.width-20, s.height-20)
	self.m_TableView:setPosition(10, 10)
	self.m_TableView:setColumCount(4)
    self.m_TableView:setDataSourceFunc(self, RedPackDlg.tableViewGetCellAtIndex)
    self.time = 0
    self.m_index = 1
    self.m_effect = winMgr:getWindow("hongbaozhujiemian/effect")
    self.m_blnOpenLabel1 = false
    self.m_blnOpenLabel2 = false
    self.m_blnOpenLabel3 = false
end
function RedPackDlg:AddRedPackEffect(num)
    local scale = 1
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            scale = 100
        end
    end
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    if num >= 1000 * scale * realsize then
        local flagEffect = gGetGameUIManager():AddUIEffect(self.m_effect, "spine/hongbao/hongbao", false, 0, 0, false)
    else
        local flagEffect = gGetGameUIManager():AddUIEffect(self.m_effect, "spine/hongbao/hongbao", false, 0, 0, false)
        flagEffect:SetDefaultActName("play2")
    end
end
function RedPackDlg:HandleSendClicked(e)
    local index = self.m_index
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            index = index + 1000
        end
    end
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.credpackconfig"):getRecorder(index)
    local nCurLevel = GetMainCharacter():GetLevel()

    if self.m_index == 2 then
        local datamanager = require "logic.faction.factiondatamanager"
        if not datamanager:IsHasFaction() then
            GetCTipsManager():AddMessageTipById(145077)
            return
        end
    end
    if self.m_index == 3 then
        if not GetTeamManager():IsOnTeam() then
		    GetCTipsManager():AddMessageTipById(140498)
		    return
	    end
    end

    -- 限制发红包
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.needBindTelAgain() then
        require("logic.shoujianquan.shoujiyanzheng").getInstanceAndShow()
        return
    elseif shoujianquanmgr.notBind7Days() then
        require("logic.shoujianquan.shoujiguanlianqueren").getInstanceAndShow()
        return
    end

    if nCurLevel >= 10 then
        local dlg = require"logic.redpack.redpacksenddlg".getInstanceAndShow()
        if dlg then
            dlg:InitData(self.m_index)
        end
    else
        GetCTipsManager():AddMessageTipById(172010)-- 发送成功
    end


end
function RedPackDlg:HandleDesClicked(e)
    local tips1 = require "logic.workshop.tips1"
    local title = MHSD_UTILS.get_resstring(11490)
    local tipsid = 11487
    if self.m_index == 1 then
        tipsid = 11487
    elseif self.m_index == 2 then
        tipsid = 11488
    elseif self.m_index == 3 then
        tipsid = 11489
    end
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
             if self.m_index == 1 then
                tipsid = 11516
            elseif self.m_index == 2 then
                tipsid = 11517
            elseif self.m_index == 3 then
                tipsid = 11518
            end       
        end
    end
    local strAllString = MHSD_UTILS.get_resstring(tipsid)
    local tips_instance = tips1.getInstanceAndShow(strAllString, title)
end
function RedPackDlg:HandleHistoryClicked(e)
    --require "logic.redpack.redpacklabel".hide()
    require "logic.redpack.redpackhistorylabel".DestroyDialog()
    require "logic.redpack.redpackhistorylabel".show(self.m_index)
    RedPackLabel.hide()
end
function RedPackDlg:InitData(index)
    self.m_index = index
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            index = index + 1000
        end
    end
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.credpackconfig"):getRecorder(index)
    self.m_Title:setText(record.name)
    self.m_wenzi:setText(record.name)
    
end
function RedPackDlg:Clear()
    self.m_TableView:setCellCount(0)
    self.m_TableView:clear()
    self.m_TableView:reloadData()
--    self.m_notHas:setVisible(true)
--    self.m_notHas1:setVisible(true)
end
function RedPackDlg:InitTable()
    self.m_Cover:setVisible(false)
    local manager = require"logic.redpack.redpackmanager".getInstance()
    local size = 0
    if manager.m_RedPacks[self.m_index] then
        size = #manager.m_RedPacks[self.m_index]
    else
        size = 0
    end
    

    if size == 0 then
        self.m_notHas:setVisible(true)
        self.m_notHas1:setVisible(true)
    else
        self.m_notHas:setVisible(false)
        self.m_notHas1:setVisible(false)
    end
    self.m_TableView:clear()
	self.m_TableView:setCellCountAndSize(size, 200, 290)
	self.m_TableView:reloadData()
end

function RedPackDlg:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = RedPackCellDlg.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("MouseClick", RedPackDlg.HandleCellClicked, self)
	end
    local manager = require"logic.redpack.redpackmanager".getInstance()
	cell:setCellData(manager.m_RedPacks[self.m_index][idx + 1], self.m_index)
	cell.window:setID(idx)
	return cell
end

function RedPackDlg:HandleCellClicked(e)
    if gGetDataManager():GetMainCharacterLevel() < 10 then
        GetCTipsManager():AddMessageTipById(172032)-- 发送成功
        return true
    end
    local eventargs = CEGUI.toWindowEventArgs(e)
    local id = eventargs.window:getID()
    local manager = require"logic.redpack.redpackmanager".getInstance()
    if manager.m_RedPacks[self.m_index][id + 1].redpackstate == 0 then
        local p = require("protodef.fire.pb.fushi.redpack.cgetredpack"):new()
        p.modeltype =self.m_index
        p.redpackid = manager.m_RedPacks[self.m_index][id + 1].redpackid
        LuaProtocolManager:send(p)
    else
        local p = require("protodef.fire.pb.fushi.redpack.csendredpackhisview"):new()
        p.modeltype =self.m_index
        p.redpackid = manager.m_RedPacks[self.m_index][id + 1].redpackid
        LuaProtocolManager:send(p)
    end

end
function RedPackDlg:Update(delta)
    local s = self.m_List:getPixelSize()
    local manager = require"logic.redpack.redpackmanager".getInstance()
--    if TableUtil.tablelength(manager.m_RedPacks) == 0 then
--        return
--    end
--    local num = TableUtil.tablelength(manager.m_RedPacks) % 4
--    if num == 0 then
--        num = math.floor(TableUtil.tablelength(manager.m_RedPacks) / 4)
--    else
--        num = math.floor(TableUtil.tablelength(manager.m_RedPacks) / 4) + 1
--    end
--    local height = math.floor(num * 290 - (s.height-20))

--    if not self.m_Cover:isVisible() and num >= 25 then
--        if self.m_TableView:getContentOffset() - height > 50 then
--            self.m_Cover:setVisible(true)
--            local p = require("protodef.fire.pb.fushi.redpack.csendredpackview"):new()
--            p.modeltype =self.m_index
--            p.redpackid = manager.m_RedPacks[#manager.m_RedPacks].redpackid
--            LuaProtocolManager:send(p)
--        end
--    end
end
return RedPackDlg