MTG_OnLineWelfareDlg = {}
MTG_OnLineWelfareDlg.__index = MTG_OnLineWelfareDlg

local _instance

function MTG_OnLineWelfareDlg.create()
    if not _instance then
		_instance = MTG_OnLineWelfareDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function MTG_OnLineWelfareDlg.getInstance()
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceAndShow()
    if not jlDlg then
        return nil
    end 
    local dlg = jlDlg:showSysId(Jianglinew.systemId.newPlayerReward)
	return dlg
end

function MTG_OnLineWelfareDlg.getInstanceAndShow()
	return MTG_OnLineWelfareDlg.getInstance()
end

function MTG_OnLineWelfareDlg.getInstanceNotCreate()
	return _instance
end

function MTG_OnLineWelfareDlg:remove()
    self:clearData()
    _instance = nil
end

function MTG_OnLineWelfareDlg:clearData()
end


function MTG_OnLineWelfareDlg.DestroyDialog()
    _instance.m_btnGot.animation:stop()
    require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
end


function MTG_OnLineWelfareDlg:new()
	local self = {}
	
	setmetatable(self, MTG_OnLineWelfareDlg)
	return self
end

function MTG_OnLineWelfareDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function MTG_OnLineWelfareDlg:OnCreate()
	gGetWelfareManager():setCountDownEnable(true)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local layoutName = "xinshouliwu.layout"
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)

    self.itemCell = CEGUI.toItemCell(winMgr:getWindow("xinshouliwu/di/zhong/wupin1"))
    self.itemCell:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID)
    self.m_txtTime = winMgr:getWindow("xinshouliwu/di/wenben1") 
    self.m_btnGot = CEGUI.toPushButton(winMgr:getWindow("xinshouliwu/di/lingqu"))
    self:addButtonAnimation(self.m_btnGot, "studyBtnPress")	

    self.m_btnGot:subscribeEvent("MouseButtonUp",MTG_OnLineWelfareDlg.HandleBtnGotClick,self)
	self.nRewardId = gGetWelfareManager():getGiftId()
	self.fLeftTime = 0
    self.fDegreeSpace = 360/7
    self:refreshItemCell()
    self.m_btnGot:setVisible(false)
end

function MTG_OnLineWelfareDlg:refreshItemCell()
    self.nRewardId = gGetWelfareManager():getGiftId()
    local giftconfig = BeanConfigManager.getInstance():GetTableByName("item.conlinegift"):getRecorder(self.nRewardId)
         if giftconfig  then
            local nItemId  = giftconfig.itemidnew1
            local nItemNum = giftconfig.itemnum1
            local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
            if itemattr then
                self.itemCell:setID(nItemId)
                self.itemCell:SetImage(gGetIconManager():GetItemIconByID( itemattr.icon ))	
                SetItemCellBoundColorByQulityItemWithIdtm(self.itemCell,itemattr.id)
            end

            if nItemNum > 1 then
                self.itemCell:SetTextUnit(tostring(nItemNum))
            end
         end

end

function MTG_OnLineWelfareDlg:refreshToGet()
    local bShowRed = false
    if self.fLeftTime > 0 then
        bShowRed = false
    else
         bShowRed = true
    end
    self:setGetBtnVisible(bShowRed)
end


function MTG_OnLineWelfareDlg:setGetBtnVisible(bVisible)
        self.m_btnGot:setVisible(bVisible)    
end


function MTG_OnLineWelfareDlg:SetTime(ntime, isReady)
    self.m_txtTime:setText(ntime)
    self:setGetBtnVisible(isReady)

    
end

function MTG_OnLineWelfareDlg.RemoteSetTime( fLeftSecond )

    local bShowRed = false
    if fLeftSecond > 0 then
        bShowRed = false
    else
         bShowRed = true
    end
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceNotCreate()
    if not jlDlg then
        return 
    end 
    jlDlg:refreshRedWithSysId(Jianglinew.systemId.newPlayerReward,bShowRed)

    if not _instance then
        return
    end
    _instance.fLeftTime = fLeftSecond
    local strTimeLeft = require("utils.mhsdutils").GetTimeHMSString(fLeftSecond)
    _instance.m_txtTime:setText(strTimeLeft)
	--_instance:refreshArrow(fLeftSecond)

    _instance:refreshToGet()

    local nRewardId = gGetWelfareManager():getGiftId()
    if _instance.nRewardId ~= nRewardId then
        _instance:refreshItemCell()
        _instance.nRewardId = nRewardId
    end

end


function MTG_OnLineWelfareDlg.RemoteSetBtnEnable( isReady )
    if isReady then
		local mgr = LoginRewardManager:getInstance()
		mgr.m_listOpenReward[ LoginRewardManager.eRewardType.eOnlineGift ] = 1
		mgr.m_listRewardEffect[ LoginRewardManager.eRewardType.eOnlineGift ] = 1
		
		local logoDlg = LogoInfoDialog.getInstanceNotCreate()
		if logoDlg then
			logoDlg:RefreshBtnJiangli()
		end 
        
        local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
        local jlDlg = Jianglinew.getInstanceNotCreate()
        if  jlDlg then
            jlDlg:refreshRedWithSysId(Jianglinew.systemId.newPlayerReward,true)
        end 
	end


    if not _instance then
        return
    end
    _instance:setGetBtnVisible(isReady)

end

function MTG_OnLineWelfareDlg:HandleBtnGotClick(args)
    if not gGetNetConnection() then
        return
    end
    local nrewardid = gGetWelfareManager():getGiftId()
    if nrewardid <= 0 then
        return
    end

	require "protodef.fire.pb.item.cgettimeaward"
	local clg = CGetTimeAward.Create()
    clg.awardid = nrewardid
    LuaProtocolManager.getInstance():send(clg)
end

return MTG_OnLineWelfareDlg







