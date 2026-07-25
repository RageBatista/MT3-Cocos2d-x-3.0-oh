require "logic.dialog"
require "utils.mhsdutils"
require "logic.task.taskdialog"
require "logic.shop.shoplabel"

ZhanDouAnNiu = {}
setmetatable(ZhanDouAnNiu, Dialog)
ZhanDouAnNiu.__index = ZhanDouAnNiu
local btnID_bag = 1  		--背包
local btnID_jineng = 2		--技能
local btnID_team = 3 		--队伍
local btnID_renwu = 4  	    --任务
local btnID_huodong = 5		--活动
local btnID_jiangli = 6  	--奖励
local btnID_paihang = 7		--排行
local btnID_bangpai = 8		--公会
local btnID_qianghua = 9	--强化
local btnID_shangcheng = 10  --商城
local btnID_paimai = 11    --拍卖
local btnID_xitong = 12 	--系统

--local btnID_zhuzhan = 13		--助战
local btnID_zhiyin = 14		--指引
local btnID_guaji = 15  	--挂机
local btnID_hongbao = 16    --红包
local btnWidth = 95
local btnHeight = 90
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ZhanDouAnNiu.getInstance()
	if not _instance then
		_instance = ZhanDouAnNiu:new()
		_instance:OnCreate()
	end
	
	return _instance
end

function ZhanDouAnNiu.getInstanceAndShow()
	if not _instance then
		_instance = ZhanDouAnNiu:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	
	return _instance
end

function ZhanDouAnNiu.getInstanceNotCreate()
	return _instance
end

function ZhanDouAnNiu.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
        	NotificationCenter.removeObserver(Notifi_TeamApplicantChange, ZhanDouAnNiu.handleEventTeamApplyChange)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhanDouAnNiu.ToggleOpenClose()
	if not _instance then
		_instance = ZhanDouAnNiu:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhanDouAnNiu.HideZhandouAnNiu()
	_instance.m_pBG:setVisible(false)
	_instance.m_pBtntanchu:setVisible(true)
	_instance.m_pBtnfanhui:setVisible(false)
end

----/////////////////////////////////////////------

function ZhanDouAnNiu.GetLayoutFileName()
	return "zhandouanniu.layout"
end

function ZhanDouAnNiu:OnCreate()
	Dialog.OnCreate(self)

    local chatDlg = require("logic.chat.chatoutputdialog").getInstanceNotCreate()
    if chatDlg then
        self:GetWindow():getParent():bringWindowAbove(chatDlg:GetWindow(), self:GetWindow())
    end
    self:GetWindow():subscribeEvent("ZChanged", ZhanDouAnNiu.handleZChange, self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.m_pRoot = winMgr:getWindow("fightfunction")
	
	self.m_pBG = winMgr:getWindow("fightfunction/fightbg")
	
	self.m_pBtntanchu = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/tanchu"))
	self.m_pBtntanchu:subscribeEvent("Clicked", ZhanDouAnNiu.BtntanchuClicked, self)
	
	self.m_pBtnfanhui = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fanhui"))
	self.m_pBtnfanhui:subscribeEvent("Clicked", ZhanDouAnNiu.BtnfanhuiClicked, self)
	
	
	self.m_pBtnbag = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/bag"))
	self.m_pBtnbag:subscribeEvent("Clicked", ZhanDouAnNiu.BtnbagClicked, self)
	
	self.m_pBtnpaihang = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/paihang"))
	self.m_pBtnpaihang:subscribeEvent("Clicked", ZhanDouAnNiu.BtnpaihangClicked, self)
	
--	self.m_pBtnzhuzhan = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/zhuzhan"))
--	self.m_pBtnzhuzhan:subscribeEvent("Clicked", ZhanDouAnNiu.BtnzhuzhanClicked, self)
	
	self.m_pBtnjineng = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/jineng"))
	self.m_pBtnjineng:subscribeEvent("Clicked", ZhanDouAnNiu.BtnjinengClicked, self)
	
	self.m_pBtnhuodong = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/huodong"))
	self.m_pBtnhuodong:subscribeEvent("Clicked", ZhanDouAnNiu.BtnhuodongClicked, self)
	
	self.m_pBtnbangpai = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/bangpai"))
	self.m_pBtnbangpai:subscribeEvent("Clicked", ZhanDouAnNiu.BtnbangpaiClicked, self)
	
	self.m_pBtnqianghua = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/qianghua"))
	self.m_pBtnqianghua:subscribeEvent("Clicked", ZhanDouAnNiu.BtnqianghuaClicked, self)
	
	self.m_pBtnxitong = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/xitong"))
	self.m_pBtnxitong:subscribeEvent("Clicked", ZhanDouAnNiu.BtnxitongClicked, self)
	
	self.m_pBtnshangcheng = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/shangcheng"))
	self.m_pBtnshangcheng:subscribeEvent("Clicked", ZhanDouAnNiu.BtnshangchengClicked, self)
	
	self.m_pBtnteam = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/team"))
	self.m_pBtnteam:subscribeEvent("Clicked", ZhanDouAnNiu.BtnteamClicked, self)
	
	self.m_pBtnzhiyin = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/zhiyin"))
	self.m_pBtnzhiyin:subscribeEvent("Clicked", ZhanDouAnNiu.BtnzhiyinClicked, self)
	
	self.m_pBtnguaji = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/guaji"))
	self.m_pBtnguaji:subscribeEvent("Clicked", ZhanDouAnNiu.BtnguajiClicked, self)
	
	self.m_pBtnrenwu = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/renwu"))
	self.m_pBtnrenwu:subscribeEvent("Clicked", ZhanDouAnNiu.BtnrenwuClicked, self)
    
	self.m_pBtnjiangli = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/fuli"))
	self.m_pBtnjiangli:subscribeEvent("Clicked", ZhanDouAnNiu.BtnjiangliClicked, self)

    self.m_pBtnRedPack = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/shangcheng2"))
	self.m_pBtnRedPack:subscribeEvent("Clicked", ZhanDouAnNiu.BtnRedPackClicked, self)

    self.m_pBtnPaiMai = CEGUI.Window.toPushButton(winMgr:getWindow("fightfunction/fightbg/paimai"))
	self.m_pBtnPaiMai:subscribeEvent("Clicked", ZhanDouAnNiu.BtnPaiMaiClicked, self)

    self.m_pBangPaiMark = winMgr:getWindow("fightfunction/fightbg/bangpai/hongdian")
	self.m_imgRBZhiyin = winMgr:getWindow("fightfunction/fightbg/zhiyin/hongdian")
    self.m_imgRBHuodong = winMgr:getWindow("fightfunction/fightbg/huodong/hongdian")
    self.teamApplyTipDot = winMgr:getWindow("fightfunction/fightbg/team/hongdian")
    self.m_pShangChengMark = winMgr:getWindow("fightfunction/fightbg/shangcheng/hongdian")
    self.m_pJiangLiMark = winMgr:getWindow("fightfunction/fightbg/fuli/hongdian")

	--主操作控件已经执行了下面两行代码,这里不执行是否可以,有待确认
	local p = require "protodef.fire.pb.clan.crequestapplylist":new()
	require "manager.luaprotocolmanager":send(p)
	
	self.m_btnGroupId = {}
	self.m_btnGroup = {}
	self.m_btnGroup[btnID_bag] = self.m_pBtnbag
	self.m_btnGroup[btnID_paihang] = self.m_pBtnpaihang
	
	self.m_btnGroup[btnID_jineng] = self.m_pBtnjineng
	self.m_btnGroup[btnID_huodong] = self.m_pBtnhuodong
	self.m_btnGroup[btnID_bangpai] = self.m_pBtnbangpai
	self.m_btnGroup[btnID_qianghua] = self.m_pBtnqianghua
	self.m_btnGroup[btnID_xitong] = self.m_pBtnxitong
	self.m_btnGroup[btnID_shangcheng] = self.m_pBtnshangcheng
	self.m_btnGroup[btnID_team] = self.m_pBtnteam
	self.m_btnGroup[btnID_zhiyin] = self.m_pBtnzhiyin
	self.m_btnGroup[btnID_guaji] = self.m_pBtnguaji
	self.m_btnGroup[btnID_renwu] = self.m_pBtnrenwu
	self.m_btnGroup[btnID_jiangli] = self.m_pBtnjiangli
	self.m_btnGroup[btnID_hongbao] = self.m_pBtnRedPack
    self.m_btnGroup[btnID_paimai] = self.m_pBtnPaiMai
	--self.m_btnGroup[btnID_zhuzhan] = self.m_pBtnzhuzhan
	--开启限制ID来自表(x新功能开启.xlsx) 0 代表没有限制
	self.m_btnGroupId[btnID_bag] = 0
	self.m_btnGroupId[btnID_paihang] = 8
	
	self.m_btnGroupId[btnID_jineng] = 4
	self.m_btnGroupId[btnID_huodong] = 14
	self.m_btnGroupId[btnID_bangpai] = 5
	self.m_btnGroupId[btnID_qianghua] = 11
	self.m_btnGroupId[btnID_xitong] = 0
	self.m_btnGroupId[btnID_shangcheng] = 0
	self.m_btnGroupId[btnID_team] = 0
	self.m_btnGroupId[btnID_zhiyin] = 2
	self.m_btnGroupId[btnID_guaji] = 7
	self.m_btnGroupId[btnID_renwu] = 0
	self.m_btnGroupId[btnID_jiangli] = 0
	self.m_btnGroupId[btnID_hongbao] = 0
    self.m_btnGroupId[btnID_paimai] = 0
	--self.m_btnGroupId[btnID_zhuzhan] = 6
	self:refreshBtn()
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_REDPACK then
                    if v.state == 1 then
                        self.m_pBtnRedPack:setVisible(false)
                        self.m_btnGroup[btnID_hongbao]  = nil
                        self.m_btnGroupId[btnID_hongbao] = nil
                        break
                    end
                end
            end
        end
    end
	NotificationCenter.addObserver(Notifi_TeamApplicantChange, ZhanDouAnNiu.handleEventTeamApplyChange)
end

------------------- private: -----------------------------------

function ZhanDouAnNiu:Show()
	if _instance then
		_instance:SetVisible(true)
		
		self:BtnfanhuiClicked()
		--如果等级不够隐藏助战伙伴按钮
		self:refreshBtn()
	end
end

function ZhanDouAnNiu:Hide()
	if _instance then
		_instance:SetVisible(false)
	end
end

function ZhanDouAnNiu:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhanDouAnNiu)
	
	return self
end

function ZhanDouAnNiu:run(delta)
	if self:IsVisible() == false then
		return
	end
end
function ZhanDouAnNiu:BtnRedPackClicked(args)
    require("logic.redpack.redpacklabel")
    RedPackLabel.DestroyDialog()
    RedPackLabel.show(1)
end
function ZhanDouAnNiu:BtnPaiMaiClicked(args)
    require("logic.shop.stalllabel").show()
end
function ZhanDouAnNiu:BtntanchuClicked(args)
	--self.m_pRoot:setXPosition(CEGUI.UDim(0,0))
	self.m_pBG:setVisible(true)
	self.m_pBtntanchu:setVisible(false)
	self.m_pBtnfanhui:setVisible(true)
	return true
end

function ZhanDouAnNiu:BtnfanhuiClicked(args)
	--self.m_pRoot:setXPosition(CEGUI.UDim(0,self.m_pBG:getPixelSize().width * -1))
	self.m_pBG:setVisible(false)
	self.m_pBtntanchu:setVisible(true)
	self.m_pBtnfanhui:setVisible(false)
	return true
end

function ZhanDouAnNiu:BtnbagClicked(args)
	LogInfo("ZhanDouAnNiu:BtnbagClicked")
	CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
	
	return true
end

function ZhanDouAnNiu:BtnpaihangClicked(args)
	LogInfo("ZhanDouAnNiu:BtnpaihangClicked")
	
    require"logic.rank.rankinglist".getInstanceAndShow()
	
	return true
end

function ZhanDouAnNiu:BtnzhuzhanClicked(args)
	require "logic.team.huobanzhuzhandialog"
	HuoBanZhuZhanDialog.getInstanceAndShow()
	return true
end

function ZhanDouAnNiu:BtnjinengClicked(args)
	LogInfo("ZhanDouAnNiu:BtnjinengClicked")
	require "logic.skill.skilllable"
	SkillLable.Show(1)
	return true
end

function ZhanDouAnNiu:BtnhuodongClicked(args)
    LogInfo("LogoInfoDialog:HandleBtnHuodongClick")
    return LogoInfoDialog.openHuoDongDlg();
end

function ZhanDouAnNiu:BtnbangpaiClicked(args)
	LogInfo("ZhanDouAnNiu:BtnbangpaiClicked")

    -- 打开公会UI
    require "logic.faction.factiondatamanager".OpenFamilyUI()
	
	return true
end

function ZhanDouAnNiu:BtnqianghuaClicked(args)
	LogInfo("ZhanDouAnNiu:BtnqianghuaClicked")
	WorkshopLabel.Show(1, 3, 0)
	return true
end

function ZhanDouAnNiu:BtnxitongClicked(args)
	LogInfo("ZhanDouAnNiu:BtnxitongClicked")
	SystemSettingNewDlg.getInstanceAndShow()
	return true
end

function ZhanDouAnNiu:BtnshangchengClicked(args)
	LogInfo("ZhanDouAnNiu:BtnshangchengClicked")
	
	ShopLabel.show()
	
	--[[require "protodef.fire.pb.fushi.copencontinuechargedlg"
	local p = COpenContinueChargeDlg.Create()
	p.flag = 2 -- for shop show1
	p.page = 3
	require "manager.luaprotocolmanager":send(p)--]]
	
	return true
end

function ZhanDouAnNiu:BtnteamClicked(args)
	LogInfo("ZhanDouAnNiu:BtnteamClicked")
	TeamDialogNew.getInstanceAndShow()
	return true
end

function ZhanDouAnNiu:BtnzhiyinClicked(args)
	LogInfo("ZhanDouAnNiu:BtnzhiyinClicked")
	require("logic.guide.guidelabel").show()
	return true
end

function ZhanDouAnNiu:BtnguajiClicked(args)
	LogInfo("ZhanDouAnNiu:BtnguajiClicked")
	
	--	BattleAutoDlg.getInstance():HandleCancelBtnClicked()	--new add
	
	LogoInfoDialog.getInstance():HandleBtnGuajiClick()
	
	return true
end

function ZhanDouAnNiu:BtnrenwuClicked(args)
    require "logic.task.tasklabel".Show(1)
end
function ZhanDouAnNiu:BtnjiangliClicked(args)
    local dlg = require("logic.qiandaosongli.jianglinewdlg").getInstanceAndShow()
    dlg:showSysId(1)
end

function ZhanDouAnNiu:refreshBtn()
	local pos = self.m_pBtnbag:getPosition()
	local data = gGetDataManager():GetMainCharacterData()
	local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	local posX = 0
	local posY = 0
	for i = 1, 12 do
        if self.m_btnGroupId[i] then
		    if self.m_btnGroupId[i] == 0 then
			    local x = CEGUI.UDim(0,  posX * btnWidth)
			    local y = CEGUI.UDim(0,  posY * btnHeight)
			    local posOff = CEGUI.UVector2(x+ pos.x,y + pos.y)
			    self.m_btnGroup[i]:setPosition(posOff)
			    self.m_btnGroup[i]:setVisible(true)
			    posX = posX + 1
			    --如果超过4个换行
			    if  posX ==  3 then
				    posX = 0
				    posY = posY + 1
			    end
		    else
                local record =  BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getRecorder(self.m_btnGroupId[i])
			    local needlevel = record.needlevel
			    if XinGongNengOpenDLG.checkFeatureOpened(self.m_btnGroupId[i]) then
				    local x = CEGUI.UDim(0,  posX * btnWidth)
				    local y = CEGUI.UDim(0,  posY * btnHeight)
				    local posOff = CEGUI.UVector2(x+ pos.x,y + pos.y)
				    self.m_btnGroup[i]:setPosition(posOff)
				    self.m_btnGroup[i]:setVisible(true)
				    posX = posX + 1
				    --如果超过4个换行
				    if  posX ==  3 then
					    posX = 0
					    posY = posY + 1
				    end

			    else
				    self.m_btnGroup[i]:setVisible(false)
			    end
		    end
        end
	end

    
    --显示红点公会
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        if datamanager.m_FactionTips then
            self.m_pBangPaiMark:setVisible(datamanager.m_FactionTips[1] == 1)
        end
    end
    
    local guideManager = require "logic.guide.guidemanager".getInstance()
    if guideManager.m_HasHongdian then
        self.m_imgRBZhiyin:setVisible(true)
    else
        self.m_imgRBZhiyin:setVisible(false)
    end
    
    local huodongManager = HuoDongManager.getInstance()
    if huodongManager.hasHongdianAll then
        self.m_imgRBHuodong:setVisible(true)
    else
        self.m_imgRBHuodong:setVisible(false)
    end
    
	local applicantNum = GetTeamManager():GetApplicationNum()
	self.teamApplyTipDot:setVisible(applicantNum > 0)

    local datamanager = require "logic.chargedatamanager"
    local redpoint =  datamanager.GetRedPointStatus()
    self.m_pShangChengMark:setVisible(redpoint)

    local mgr = LoginRewardManager.getInstanceNotCreate()
    if mgr then
        local nJiangliCnt = mgr:GetCanRewardCount()
        self.m_pJiangLiMark:setVisible(nJiangliCnt > 0)
    end
end

function ZhanDouAnNiu:refreshHuodongBtn()
    local huodongManager = HuoDongManager.getInstance()
    if huodongManager.hasHongdianAll then
        self.m_imgRBHuodong:setVisible(true)
    else
        self.m_imgRBHuodong:setVisible(false)
    end
end
function ZhanDouAnNiu:refreshZhiyinBtn()
    local guideManager = GuideManager.getInstance()
    if guideManager.m_HasHongdian then
        self.m_imgRBZhiyin:setVisible(true)
    else
        self.m_imgRBZhiyin:setVisible(false)
    end
end

function ZhanDouAnNiu.handleEventTeamApplyChange()
	if _instance then
		local applicantNum = GetTeamManager():GetApplicationNum()
		_instance.teamApplyTipDot:setVisible(applicantNum > 0)
	end
end

--a layer order issue happened occasionally
function ZhanDouAnNiu:handleZChange()
    local chatDlg = require("logic.chat.chatoutputdialog").getInstanceNotCreate()
    if not chatDlg then
        return
    end
    
    if self:GetWindow() and self:GetWindow():getParent() then
        local drawList = self:GetWindow():getParent():getDrawList()
        for i=0, drawList:size()-1 do
            if drawList[i] == chatDlg:GetWindow() then
                self:GetWindow():getParent():bringWindowAbove(chatDlg:GetWindow(), self:GetWindow())
                break
            elseif drawList[i] == self:GetWindow() then
                break
            end
        end
    end
end

return ZhanDouAnNiu

