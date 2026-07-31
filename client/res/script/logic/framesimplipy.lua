require "logic.dialog"

FrameSimplipy = {}
setmetatable(FrameSimplipy, Dialog)
FrameSimplipy.__index = FrameSimplipy

local _instance
function FrameSimplipy.getInstance()
	if not _instance then
		_instance = FrameSimplipy:new()
		_instance:OnCreate()
	end
	return _instance
end

function FrameSimplipy.getInstanceAndShow()
	if not _instance then
		_instance = FrameSimplipy:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FrameSimplipy.getInstanceNotCreate()
	return _instance
end

function FrameSimplipy.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FrameSimplipy.ToggleOpenClose()
	if not _instance then
		_instance = FrameSimplipy:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FrameSimplipy.GetLayoutFileName()
	return "jianhua.layout"
end

function FrameSimplipy:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FrameSimplipy)
	return self
end

function FrameSimplipy:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_tableWnd = {}
    self.m_btnJiangli = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/1"))
    self.m_btnJiangli:subscribeEvent("MouseClick", FrameSimplipy.HandleJiangliClick, self)
    
    self.m_btnHuodong = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/2"))
    self.m_btnHuodong:subscribeEvent("MouseClick", FrameSimplipy.HandleHuodongClick, self)

    self.m_btnChengjiu = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/3"))
    self.m_btnChengjiu:subscribeEvent("MouseClick", FrameSimplipy.HandleChengjiuClick, self)
    
    self.m_btnGuaji = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/4"))
    self.m_btnGuaji:subscribeEvent("MouseClick", FrameSimplipy.HandleGuajiClick, self)
    
    self.m_btnHongbao = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/5"))
    self.m_btnHongbao:subscribeEvent("MouseClick", FrameSimplipy.HandleHongbaoClick, self)
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_REDPACK then
                    if v.state == 1 then
                        self.m_btnHongbao:setVisible(false)
                        break
                    end
                end
            end
        end
    end   
    self.m_btnPaihang = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/6"))
    self.m_btnPaihang:subscribeEvent("MouseClick", FrameSimplipy.HandlePaihangClick, self)
    
    self.m_btnShezhi = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/7"))
    self.m_btnShezhi:subscribeEvent("MouseClick", FrameSimplipy.HandleShezhiClick, self)
    
    self.m_btnPaimai = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/8"))
    self.m_btnPaimai:subscribeEvent("MouseClick", FrameSimplipy.HandlePaimaiClick, self)
    
    self.m_btnShangcheng = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/9"))
    self.m_btnShangcheng:subscribeEvent("MouseClick", FrameSimplipy.HandleShangchengClick, self)
    
    self.m_btnZhuzhan = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/10"))
    self.m_btnZhuzhan:subscribeEvent("MouseClick", FrameSimplipy.HandleZhuzhanClick, self)
    
    self.m_btnJineng = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/11"))
    self.m_btnJineng:subscribeEvent("MouseClick", FrameSimplipy.HandleJinengClick, self)
    
    self.m_btnQianghua = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/12"))
    self.m_btnQianghua:subscribeEvent("MouseClick", FrameSimplipy.HandleQianghuaClick, self)
    
    self.m_btnGonghui = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/13"))
    self.m_btnGonghui:subscribeEvent("MouseClick", FrameSimplipy.HandleGonghuiClick, self)
    
    self.m_btnClose = CEGUI.toPushButton(winMgr:getWindow("jianhua/mask/close"))
    self.m_btnClose:subscribeEvent("MouseClick", FrameSimplipy.HandleCloseClick, self)

    self.m_btnJiangliRed = winMgr:getWindow("jianhua/mask/1/hongdian")
    self.m_btnHuodongRed = winMgr:getWindow("jianhua/mask/2/hongdian")
    self.m_btnChengjiuRed = winMgr:getWindow("jianhua/mask/3/hongdian")
    self.m_btnGuajiRed = winMgr:getWindow("jianhua/mask/4/hongdian")
    self.m_btnHongbaoRed = winMgr:getWindow("jianhua/mask/5/hongdian")
    self.m_btnPaihangRed = winMgr:getWindow("jianhua/mask/6/hongdian")
    self.m_btnShezhiRed = winMgr:getWindow("jianhua/mask/7/hongdian")
    self.m_btnPaimaiRed = winMgr:getWindow("jianhua/mask/8/hongdian")
    self.m_btnShangchengRed = winMgr:getWindow("jianhua/mask/9/hongdian")
    self.m_btnZhuzhanRed = winMgr:getWindow("jianhua/mask/10/hongdian")
    self.m_btnJinengRed = winMgr:getWindow("jianhua/mask/11/hongdian")
    self.m_btnQianghuaRed = winMgr:getWindow("jianhua/mask/12/hongdian")
    self.m_btnGonghuiRed = winMgr:getWindow("jianhua/mask/13/hongdian")

    self.m_btnJiangliHui = winMgr:getWindow("jianhua/mask/1/image")
    self.m_btnHuodongHui= winMgr:getWindow("jianhua/mask/2/image")
    self.m_btnChengjiuHui = winMgr:getWindow("jianhua/mask/3/image")
    self.m_btnGuajiHui = winMgr:getWindow("jianhua/mask/4/image")
    self.m_btnHongbaoHui = winMgr:getWindow("jianhua/mask/5/image")
    self.m_btnPaihangHui = winMgr:getWindow("jianhua/mask/6/image")
    self.m_btnShezhiHui = winMgr:getWindow("jianhua/mask/7/image")
    self.m_btnPaimaiHui = winMgr:getWindow("jianhua/mask/8/image")
    self.m_btnShangchengHui = winMgr:getWindow("jianhua/mask/9/image")
    self.m_btnZhuzhanHui = winMgr:getWindow("jianhua/mask/10/image")
    self.m_btnJinengHui = winMgr:getWindow("jianhua/mask/11/image")
    self.m_btnQianghuaHui = winMgr:getWindow("jianhua/mask/12/image")
    self.m_btnGonghuiHui = winMgr:getWindow("jianhua/mask/13/image")

    self.m_bg = winMgr:getWindow("jianhua/mask")
    self.m_bg:subscribeEvent("MouseClick", FrameSimplipy.HandleCloseClick, self)

    self.m_tableWnd[1] = self.m_btnJiangliRed
    self.m_tableWnd[2] = self.m_btnHuodongRed
    self.m_tableWnd[3] = self.m_btnChengjiuRed
    self.m_tableWnd[4] = self.m_btnGuajiRed
    self.m_tableWnd[5] = self.m_btnHongbaoRed
    self.m_tableWnd[6] = self.m_btnPaihangRed
    self.m_tableWnd[7] = self.m_btnShezhiRed
    self.m_tableWnd[8] = self.m_btnPaimaiRed
    self.m_tableWnd[9] = self.m_btnShangchengRed
    self.m_tableWnd[10] = self.m_btnZhuzhanRed
    self.m_tableWnd[11] = self.m_btnJinengRed
    self.m_tableWnd[12] = self.m_btnQianghuaRed
    self.m_tableWnd[13] = self.m_btnGonghuiRed

    self:initRed()
    self:initBtn()
end

function FrameSimplipy:initRed()
    local maincontrol =  require"logic.maincontrol".getInstanceNotCreate()
    if maincontrol then
        for i = 1, require "utils.tableutil".tablelength(maincontrol.m_simplipyTips) do 
            if maincontrol.m_simplipyTips[i] == 0 then
                self.m_tableWnd[i]:setVisible(false)
            else
                self.m_tableWnd[i]:setVisible(true)
            end
        end
    end
end
function FrameSimplipy:initBtn()
    self.m_btnHuodong:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(14))
    self.m_btnChengjiu:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(2))
    self.m_btnGuaji:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(7))
    self.m_btnPaihang:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(8))
    self.m_btnZhuzhan:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(6))
    self.m_btnJineng:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(4))
    self.m_btnQianghua:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(11))
    self.m_btnGonghui:setEnabled(XinGongNengOpenDLG.checkFeatureOpened(5))

    self.m_btnHuodongHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(14))
    self.m_btnChengjiuHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(2))
    self.m_btnGuajiHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(7))
    self.m_btnPaihangHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(8))
    self.m_btnZhuzhanHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(6))
    self.m_btnJinengHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(4))
    self.m_btnQianghuaHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(11))
    self.m_btnGonghuiHui:setVisible(not XinGongNengOpenDLG.checkFeatureOpened(5))
end
function FrameSimplipy:HandleCloseClick(e)
    self:CloseDlg()
end
function FrameSimplipy:CloseDlg()
	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():SetVisible(true)
	end
    if LogoInfoDialog.getInstanceNotCreate() then
        LogoInfoDialog.getInstanceNotCreate():MoveWifiRight()
        LogoInfoDialog.getInstanceNotCreate():ShowAllButton()
        LogoInfoDialog.getInstanceNotCreate():RefreshAllBtn()
    end
	if Renwulistdialog.getSingleton() and require "logic.bingfengwangzuo.bingfengwangzuomanager":isInBingfeng() == false then
		--LogCustom(99,"Renwulistdialog.getSingleton():SetVisible(true)")
        local nIsJingji1v1 = 0
        if gGetScene() then
             local nMapId = gGetScene():GetMapID()
              local nJingjiType = getJingjiMapType(nMapId)
             if nJingjiType==1 then
                nIsJingji1v1 = 1
             end
        end
        if nIsJingji1v1==0 then
		    Renwulistdialog.getSingleton():SetVisible(true)
        end
	end
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:GetWindow():setVisible(true)
    end
    dlg = require ("logic.chat.cchatoutboxoperateldlg").getInstanceNotCreate()
    if dlg then
        dlg:GetWindow():setVisible(true)
    end
    self.DestroyDialog()
end
function FrameSimplipy:HandleJiangliClick(e)
    local dlg = require("logic.qiandaosongli.jianglinewdlg").getInstanceAndShow()
    dlg:showSysId(1)
end
function FrameSimplipy:HandleHuodongClick(e)
    LogoInfoDialog.openHuoDongDlg()
end
function FrameSimplipy:HandleChengjiuClick(e)
    require("logic.guide.guidelabel").show()
end
function FrameSimplipy:HandleGuajiClick(e)
    local curMapID = gGetScene():GetMapID()
    local roleLevel = gGetDataManager():GetMainCharacterLevel()

    if true then
        local mapID = LogoInfoDialog.getInstance():GetAutoBattleMapByLevel(roleLevel)
        if mapID ~= -1 then
            MapChoseDlg.getInstanceAndShow()
            MapChoseDlg.getInstanceNotCreate().SetMapID()
        end
        GetMainCharacter():StopPacingMove()
        return true
    end

    return true
end
function FrameSimplipy:HandleHongbaoClick(e)
    require("logic.redpack.redpacklabel")
    RedPackLabel.DestroyDialog()
    RedPackLabel.show(1)    
end
function FrameSimplipy:HandlePaihangClick(e)
    require"logic.rank.rankinglist".getInstanceAndShow()
end
function FrameSimplipy:HandleShezhiClick(e)
    SystemSettingNewDlg.getInstanceAndShow()
end
function FrameSimplipy:HandlePaimaiClick(e)
    require("logic.shop.stalllabel").show()
end
function FrameSimplipy:HandleShangchengClick(e)
    require("logic.shop.shoplabel").show()
end
function FrameSimplipy:HandleZhuzhanClick(e)
    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end

    require "logic.team.huobanzhuzhandialog"
    HuoBanZhuZhanDialog.getInstanceAndShow()
    
    local cgethuobanlist = require "protodef.fire.pb.huoban.cgethuobanlist":new()
    require "manager.luaprotocolmanager":send(cgethuobanlist)
end
function FrameSimplipy:HandleJinengClick(e)
    require "logic.skill.skilllable"

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() ~= nil then
        CChatOutputDialog:getInstance():OnClose()
    end
    local skillIndex = gCommon.skillIndex or 1
    SkillLable.Show(skillIndex)
end
function FrameSimplipy:HandleQianghuaClick(e)
    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() ~= nil then
        CChatOutputDialog:getInstance():OnClose()
    end

    local waManager = require "logic.workshop.workshopmanager".getInstance()
    local nShowType = waManager.nShowType
    WorkshopLabel.Show(nShowType, 3, 0)
end
function FrameSimplipy:HandleGonghuiClick(e)
    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() ~= nil then
        CChatOutputDialog:getInstance():OnClose()
    end

    -- 打开公会UI
    require "logic.faction.factiondatamanager".OpenFamilyUI()
end
return FrameSimplipy