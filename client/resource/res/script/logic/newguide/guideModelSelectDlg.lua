require "logic.dialog"

guideModelSelectDlg = {}
setmetatable(guideModelSelectDlg, Dialog)
guideModelSelectDlg.__index = guideModelSelectDlg

local _instance
function guideModelSelectDlg.getInstance()
	if not _instance then
		_instance = guideModelSelectDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function guideModelSelectDlg.getInstanceAndShow()
	if not _instance then
		_instance = guideModelSelectDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function guideModelSelectDlg.getInstanceNotCreate()
	return _instance
end

function guideModelSelectDlg.DestroyDialog()
	if _instance then 
        _instance:startFirstTaskGuide()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function guideModelSelectDlg.ToggleOpenClose()
	if not _instance then
		_instance = guideModelSelectDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function guideModelSelectDlg.GetLayoutFileName()
	return "zhiyindingzhi_mtg.layout"
end

function guideModelSelectDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, guideModelSelectDlg)
	return self
end

function guideModelSelectDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    if IsPointCardServer() then
        require "logic.newguide.pointcardguidedlg".getInstanceAndShow()
        guideModelSelectDlg.DestroyDialog()
        return
    end


	self.btnOldPlayer = CEGUI.toPushButton(winMgr:getWindow("zhiyindingzhi_mtg/OK"))
	self.btnNewPlayer = CEGUI.toPushButton(winMgr:getWindow("zhiyindingzhi_mtg/Canle"))

    self.btnOldPlayer:subscribeEvent("MouseClick", guideModelSelectDlg.HandleOldPlayerClick, self)
    self.btnNewPlayer:subscribeEvent("MouseClick", guideModelSelectDlg.HandleNewPlayerClick, self)

     
end

function guideModelSelectDlg:HandleNewPlayerClick(args)
    NewRoleGuideManager.getInstance():setGuideModel(0)
    self:sendModelSelectPro(0)
    guideModelSelectDlg.DestroyDialog()
end

function guideModelSelectDlg:HandleOldPlayerClick(args)
    NewRoleGuideManager.getInstance():setGuideModel(1)
    self:sendModelSelectPro(1)
    guideModelSelectDlg.DestroyDialog()
end

function guideModelSelectDlg:sendModelSelectPro( model )
    local csetpilottype = require "protodef.fire.pb.csetpilottype"
	local req = csetpilottype.Create()
    req.pilotType = model
	LuaProtocolManager.getInstance():send(req)
end

function guideModelSelectDlg:startFirstTaskGuide()
    local school = gGetDataManager():GetMainCharacterData().school;
    if school == 11 then
        NewRoleGuideManager.getInstance():StartGuide(31001, "180101TaskTrackcell", "180101TaskTrackcell");
    elseif school == 12 then
        NewRoleGuideManager.getInstance():StartGuide(31002, "180201TaskTrackcell", "180201TaskTrackcell");
    elseif school == 13 then
        NewRoleGuideManager.getInstance():StartGuide(31004, "180401TaskTrackcell", "180401TaskTrackcell");
    elseif school == 14 then
        NewRoleGuideManager.getInstance():StartGuide(31003, "180301TaskTrackcell", "180301TaskTrackcell");
    elseif school == 15 then
        NewRoleGuideManager.getInstance():StartGuide(31005, "180501TaskTrackcell", "180501TaskTrackcell");
    elseif school == 16 then
        NewRoleGuideManager.getInstance():StartGuide(31006, "180601TaskTrackcell", "180601TaskTrackcell");
    elseif school == 17 then
        NewRoleGuideManager.getInstance():StartGuide(31009, "180701TaskTrackcell", "180701TaskTrackcell");
    elseif school == 18 then
        NewRoleGuideManager.getInstance():StartGuide(31010, "180801TaskTrackcell", "180801TaskTrackcell");
    elseif school == 19 then
        NewRoleGuideManager.getInstance():StartGuide(31011, "180901TaskTrackcell", "180901TaskTrackcell");
    end
end

return guideModelSelectDlg