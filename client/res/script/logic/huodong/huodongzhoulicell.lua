huodongzhoulicell = {}

--活动周历cell（不是今天的）   wjf  
setmetatable(huodongzhoulicell, Dialog)
huodongzhoulicell.__index = huodongzhoulicell
local prefix = 0
function huodongzhoulicell.CreateNewDlg(parent)
	local newDlg = huodongzhoulicell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function huodongzhoulicell.GetLayoutFileName()
	return "huodongzhoulicell.layout"
end
function huodongzhoulicell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, huodongzhoulicell)
	return self
end

function huodongzhoulicell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	self.m_imgTubiao = winMgr:getWindow(prefixstr.. "huodongzhoulicell/tubiao")
	self.m_txtTime = winMgr:getWindow(prefixstr.. "huodongzhoulicell/wenben")
	self.m_txtText = winMgr:getWindow(prefixstr.."huodongzhoulicell/wenben2")
    self.mainFrame = winMgr:getWindow(prefixstr.."huodongzhoulicell")
	
end
function huodongzhoulicell.addIndex()
	prefix = prefix + 1
end
function huodongzhoulicell:RefreshItem(nType, strText, strTime)
	if nType == 1 then
		self.m_txtText:setVisible(false)
		self.m_txtTime:setText(strTime)
	elseif nType == 2 then
		self.m_imgTubiao:setVisible(false)
		self.m_txtTime:setVisible(false)
        self.m_txtText:setText("")
		if strText ~= nil and strText ~= "" then
            local tableName = ""
            if IsPointCardServer() then
                tableName = "mission.cactivitynewpay"
            else
                tableName = "mission.cactivitynew"
            end
            local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(tonumber(strText))
            if record~=nil then
                self.mainFrame:subscribeEvent("MouseClick",huodongzhoulicell.HandleItemClicked,self)
                self.m_id = record.id
                self.m_txtText:setText(record.name)
            end
        end

	end

end
function huodongzhoulicell:HandleItemClicked(args)
	local adlg = require "logic.tips.activitytips"
	if not adlg.getInstanceNotCreate() then
		local acttipdlg = adlg.getInstanceAndShow()
		acttipdlg.m_id = self.m_id
		acttipdlg:RefreshTips()
	end    
end

return huodongzhoulicell
