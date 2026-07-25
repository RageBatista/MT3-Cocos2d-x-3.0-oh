TeamMemberUnit = {}
TeamMemberUnit.__index = TeamMemberUnit
local prefix = 0
function TeamMemberUnit.new()
	local self = {}
	setmetatable(self, TeamMemberUnit)

	local winMgr = CEGUI.WindowManager:getSingleton()
	LogInsane("Load team member "..prefix)

    self.pWnd = winMgr:loadWindowLayout("teammaincell.layout", tostring(prefix))
    self.pWnd:subscribeEvent("MouseClick", TeamMemberUnit.HandleMouseClick,self)
    self.pIcon = winMgr:getWindow(prefix.."teammaincell/icon")
    self.pHp = CEGUI.toProgressBar(winMgr:getWindow(prefix.."teammaincell/hp"))
    self.pHp:setBarType(0)
    self.pMp = CEGUI.toProgressBar(winMgr:getWindow(prefix.."teammaincell/mp"))
    self.pMp:setBarType(2)
    self.pLevel = winMgr:getWindow(prefix.."teammaincell/level")
    self.pName = winMgr:getWindow(prefix.."teammaincell/name")
    self.pMark = winMgr:getWindow(prefix.."teammaincell/mark")
	self.pSchool = winMgr:getWindow(prefix .. "teammaincell/school")

    self.pWnd:subscribeEvent("AlphaChanged", TeamMemberUnit.onWndStateChanged, self)
    self.pWnd:subscribeEvent("Shown", ShopLabel.handleDlgStateChange, self)
	self.pWnd:subscribeEvent("Hidden", ShopLabel.handleDlgStateChange, self)
    self.pWnd:subscribeEvent("InheritAlphaChanged", TeamMemberUnit.onWndStateChanged, self)

	prefix = prefix+1
    return self
end

function TeamMemberUnit:init(id, hp, maxHp, mp, maxMp, level, name, shapeId, schoolID)
	self.id = id
	self.idx = GetTeamManager():GetTeamMemberIndexByID(id)
	self.pHp:setProgress(hp/maxHp)
	self.pMp:setProgress(mp/maxMp)
	self.pLevel:setText(tostring(level))
	self.pName:setText(name)

    if gGetDataManager():GetMainCharacterID() == id then
        self.pWnd:setProperty("Image", "set:ccui1 image:tm")
    else
        self.pWnd:setProperty("Image", "set:ccui1 image:tm")
    end

	local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeId)
    local iconpath = gGetIconManager():GetImagePathByID(config.littleheadID)
    self.pIcon:setProperty("Image", iconpath:c_str())

	local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolID)
	self.pSchool:setProperty("Image", schoolconf.schooliconpath)
end

function TeamMemberUnit:onWndStateChanged(args)
    if not self.pWnd:isVisible() or self.pWnd:getEffectiveAlpha() <= 0.95 or self.pWnd:getAlpha() <= 0.95 then
        local dlg =  TeamMemberMenu.getInstanceNotCreate()
	    if dlg and dlg:IsVisible() then
            dlg:SetVisible(false)
        end
    end
end
        
function TeamMemberUnit:HandleMouseClick(e)
	print("TeamMemberUnit:HandleMouseClick------------------")  
    if GetTeamManager():IsOnTeam() then
		

		local wnd = CEGUI.toWindowEventArgs(e).window
		if TeamMemberMenu.checkTriggerWnd(wnd) then
			return
		end

		local dlg = TeamMemberMenu.getInstanceAndShow()
		local t = nil
		local myId = gGetDataManager():GetMainCharacterID()
        if self.id == myId then
            t = dlg.TYPE.MAINUI_SELF
        elseif GetTeamManager():IsMyselfLeader() then
            t = dlg.TYPE.MAINUI_LEADER_SEE_MEMBER
        else
            t = dlg.TYPE.MAINUI_MEMBER_SEE_MEMBER
        end

		dlg:InitBtn(t, self.idx)
		dlg:setTriggerWnd(wnd)
		local p = wnd:GetScreenPos()
		local s = dlg:GetWindow():getPixelSize()
        local disy = 0
        --如果是最后一个成员 需要把menu往上移动100像素
        if self.idx == 5 then
            disy = 100
        end
		dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x-s.width-10), CEGUI.UDim(0, p.y - disy)))
    end
    return true;
end
        
