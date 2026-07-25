require "logic.dialog"
require "logic.family.familyfubencell"

familyfuben = {}
setmetatable(familyfuben, Dialog)
familyfuben.__index = familyfuben

local _instance
function familyfuben.getInstance()
	if not _instance then
		_instance = familyfuben:new()
		_instance:OnCreate()
	end
	return _instance
end

function familyfuben.getInstanceAndShow()
	if not _instance then
		_instance = familyfuben:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function familyfuben.getInstanceNotCreate()
	return _instance
end

function familyfuben.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function familyfuben.ToggleOpenClose()
	if not _instance then
		_instance = familyfuben:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function familyfuben.GetLayoutFileName()
	return "gonghuifubenguanli.layout"
end

function familyfuben:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyfuben)
	return self
end

function familyfuben:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.btnClose = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/guanbienniu"))
	self.btnSave = CEGUI.toPushButton(winMgr:getWindow("gonghuifubenguanli/mask/baocun"))
	self.list = CEGUI.toScrollablePane(winMgr:getWindow("gonghuifuben/mask/diban/list"))
    self.btnSave:subscribeEvent("MouseClick", familyfuben.HandleSaveMouseClicked, self)
    self.btnClose:subscribeEvent("MouseClick", familyfuben.HandleCloseMouseClicked, self)
    self:initInfo()
end

function familyfuben:initInfo()
    local index = 0
    self.m_List = {}

    local tableAllId = BeanConfigManager.getInstance():GetTableByName("instance.cinstaceconfig"):getAllID()
    for _, v in pairs(tableAllId) do
        local config = BeanConfigManager.getInstance():GetTableByName("instance.cinstaceconfig"):getRecorder(v)
        if FactionDataManager.claninstservice[config.serversid] then
            index = index + 1
		    self.m_List[index] = familyfubencell.CreateNewDlg(self.list)
		    local mainFrame = self.m_List[index]:GetWindow()
		    local hoffset = (index-1)*(mainFrame:getPixelSize().height+10) + 10
		    mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, 1.0), CEGUI.UDim(0.0, hoffset)))
		    self.m_List[index]:SetCellInfo(config.name)
		    self.m_List[index].fubenId = config.serversid
		    self.m_List[index].checkbox:setID(index)
            if TableUtil.tablelength(FactionDataManager.claninstservice) > 1 then
                self.m_List[index].checkbox:subscribeEvent("MouseButtonUp", familyfuben.CheckBoxStateChanged, self)
            else -- 只有一个副本情况
                self.m_List[index].checkbox:setSelected(true)
                self.m_List[index].checkbox:setEnabled(false)
            end
            if FactionDataManager.claninstservice[config.serversid] == 1 and TableUtil.tablelength(FactionDataManager.claninstservice) > 1 then
                self.m_List[index].checkbox:setSelected(true)
                self.m_SelectedFubenId = self.m_List[index].fubenId
            end
        end
    end
end

function familyfuben:HandleSaveMouseClicked(args)
    if TableUtil.tablelength(FactionDataManager.claninstservice) > 1 then
        self:sendFubenSelectedInfo(self.m_SelectedFubenId)
    else  -- 只有一个副本情况
        familyfuben.DestroyDialog()
    end
    return true
end

function familyfuben:HandleCloseMouseClicked(args)
    familyfuben.DestroyDialog()
    return true
end

function familyfuben:ResetCheckBox()
    for k,v in pairs(self.m_List) do
        v.checkbox:setSelected(false)
    end
end

function familyfuben:CheckBoxStateChanged(args)
    self:ResetCheckBox()
    self.m_SelectedID = CEGUI.toWindowEventArgs(args).window:getID()
    if self.m_List[self.m_SelectedID] then
        self.m_SelectedFubenId = self.m_List[self.m_SelectedID].fubenId
        self.m_List[self.m_SelectedID].checkbox:setSelected(true)
    end
    return true
end

function familyfuben:sendFubenSelectedInfo(fubenId)
    local p = require "protodef.fire.pb.clan.cchangeclaninst":new()
	p.claninstservice = fubenId
	LuaProtocolManager.getInstance():send(p)
end

return familyfuben