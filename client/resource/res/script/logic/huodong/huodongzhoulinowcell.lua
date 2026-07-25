huodongzhoulinowcell = {}

--活动周历cell  当天的 wjf
setmetatable(huodongzhoulinowcell, Dialog)
huodongzhoulinowcell.__index = huodongzhoulinowcell
local prefix = 0

function huodongzhoulinowcell.CreateNewDlg(parent)
	local newDlg = huodongzhoulinowcell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function huodongzhoulinowcell.GetLayoutFileName()
	return "huodongzhoulicell2.layout"
end
function huodongzhoulinowcell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, huodongzhoulinowcell)
	return self
end

function huodongzhoulinowcell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	self.m_txtTime = winMgr:getWindow(prefixstr.. "huodongzhoulicell2/wenben")
	self.mainFrame = winMgr:getWindow(prefixstr.. "huodongzhoulicell2")
end

function huodongzhoulinowcell:HandleItemClicked(args)
	local adlg = require "logic.tips.activitytips"
	if not adlg.getInstanceNotCreate() then
		local acttipdlg = adlg.getInstanceAndShow()
		acttipdlg.m_id = self.m_id
		acttipdlg:RefreshTips()
	end    
end
function huodongzhoulinowcell.addIndex()
	prefix = prefix + 1
end


function huodongzhoulinowcell:RefreshItem(nType, strText, strTime)
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
	self.m_txtTime:setText("")
	if strText ~= nil and strText ~= "" then
        local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(tonumber(strText))
        if record~=nil then
            self.mainFrame:subscribeEvent("MouseClick",huodongzhoulinowcell.HandleItemClicked,self)
            self.m_id = record.id
            self.m_txtTime:setText(record.name)
        end
    end
end


return huodongzhoulinowcell
