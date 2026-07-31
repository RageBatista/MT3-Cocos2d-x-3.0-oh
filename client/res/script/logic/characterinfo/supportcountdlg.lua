require "logic.dialog"

supportcountdlg = {}
setmetatable(supportcountdlg, Dialog)
supportcountdlg.__index = supportcountdlg

local _instance
function supportcountdlg.getInstance()
	if not _instance then
		_instance = supportcountdlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function supportcountdlg.getInstanceAndShow()
	if not _instance then
		_instance = supportcountdlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function supportcountdlg.getInstanceNotCreate()
	return _instance
end

function supportcountdlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function supportcountdlg.ToggleOpenClose()
	if not _instance then
		_instance = supportcountdlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function supportcountdlg.GetLayoutFileName()
	return "yuanzhutongji.layout"
end

function supportcountdlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, supportcountdlg)
	return self
end

function supportcountdlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
     
	self.barExperience = CEGUI.toProgressBar(winMgr:getWindow("yuanzhutongji/mask/diban/jingyan/jindutiao"))
	self.btnExperience = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/jingyan/tishi"))

	self.barReputation = CEGUI.toProgressBar(winMgr:getWindow("yuanzhutongji/mask/diban/shengwang/jindutiao"))
	self.btnReputation = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/shengwang/tishi"))
	self.barFunction = CEGUI.toProgressBar(winMgr:getWindow("yuanzhutongji/mask/diban/gongxian/jindutiao"))
	self.btnFunction = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/gongxian/tishi"))
	self.btnClose = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/guanbienniu"))

	self.btnExperience:subscribeEvent("Clicked", supportcountdlg.btnExperienceCallBack, self)
	self.btnReputation:subscribeEvent("Clicked", supportcountdlg.btnReputationCallBack, self)
	self.btnFunction:subscribeEvent("Clicked", supportcountdlg.btnFunctionCallBack, self)
	self.btnClose:subscribeEvent("Clicked", supportcountdlg.btnCloseCallBack, self)

    self.barHelpOther = CEGUI.toProgressBar(winMgr:getWindow("yuanzhutongji/mask/diban/yuanzhuwupin/jindutiao"))--help other
	self.btnHelpOther = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/yuanzhuwupin/tishi"))
	self.barCallHelp = CEGUI.toProgressBar(winMgr:getWindow("yuanzhutongji/mask/diban/qiuzhuwupin/jindutiao")) --call help
	self.btnCallHelp = CEGUI.toPushButton(winMgr:getWindow("yuanzhutongji/mask/diban/qiuzhuwupin/tishi"))

    self.btnHelpOther:subscribeEvent("Clicked", supportcountdlg.btnHelpOtherCallBack, self)
	self.btnCallHelp:subscribeEvent("Clicked", supportcountdlg.btnCallHelpCallBack, self)

end

function supportcountdlg:btnHelpOtherCallBack(args)
	self.tips1 = require "logic.workshop.tips1"
	local strTitle = MHSD_UTILS.get_resstring(11473) 
	local strContent = MHSD_UTILS.get_resstring(11471) 
	self.tips1.getInstanceAndShow(strContent, strTitle)
end

function supportcountdlg:btnCallHelpCallBack(args)
	self.tips1 = require "logic.workshop.tips1"
	local strTitle = MHSD_UTILS.get_resstring(11474) 
	local strContent = MHSD_UTILS.get_resstring(11472) 
	self.tips1.getInstanceAndShow(strContent, strTitle)
end

function supportcountdlg:refreshData(data)
	local experience = data.expvalue / data.expvaluemax
	local reputation = data.shengwangvalue / data.shengwangvaluemax
	local faction = data.factionvalue / data.factionvaluemax
	self.barExperience:setText(data.expvalue.."/"..data.expvaluemax)
	self.barReputation:setText(data.shengwangvalue.."/"..data.shengwangvaluemax)
	self.barFunction:setText(data.factionvalue.."/"..data.factionvaluemax)
	self.barExperience:setProgress(experience)
	self.barReputation:setProgress(reputation)
	self.barFunction:setProgress(faction)

    local fHelperOtherPercent = data.helpgiveitemnum / data.helpgiveitemnummax
    self.barHelpOther:setText(data.helpgiveitemnum.."/"..data.helpgiveitemnummax)
    self.barHelpOther:setProgress(fHelperOtherPercent)

    local fHelperPercent = data.helpitemnum / data.helpitemnummax
    self.barCallHelp:setText(data.helpitemnum.."/"..data.helpitemnummax)
    self.barCallHelp:setProgress(fHelperPercent)

end

function supportcountdlg:btnCloseCallBack(args)
	supportcountdlg.DestroyDialog()
end

function supportcountdlg:btnExperienceCallBack(args)
	self.tips1 = require "logic.workshop.tips1"
	local strTitle = MHSD_UTILS.get_resstring(11313) 
	local strContent = MHSD_UTILS.get_resstring(11301) 
	self.tips1.getInstanceAndShow(strContent, strTitle)
end
function supportcountdlg:btnFunctionCallBack(args)
	self.tips1 = require "logic.workshop.tips1"
	local strTitle = MHSD_UTILS.get_resstring(11314) 
	local strContent = MHSD_UTILS.get_resstring(11302) 
	self.tips1.getInstanceAndShow(strContent, strTitle)
end 
function supportcountdlg:btnReputationCallBack(args)
	self.tips1 = require "logic.workshop.tips1"
	local strTitle = MHSD_UTILS.get_resstring(11312) 
	local strContent = MHSD_UTILS.get_resstring(11300) 
	self.tips1.getInstanceAndShow(strContent, strTitle)
end



return supportcountdlg
