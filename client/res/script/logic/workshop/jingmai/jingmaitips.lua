------------------------------------------------------------------
-- ���＼��tip
------------------------------------------------------------------
require "logic.dialog"

JingMaiTips = {}
setmetatable(JingMaiTips, Dialog)
JingMaiTips.__index = JingMaiTips

local SKILLCELL_WIDTH = 38

local _instance
function JingMaiTips.getInstance()
	if not _instance then
		_instance = JingMaiTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function JingMaiTips.getInstanceAndShow()
	if not _instance then
		_instance = JingMaiTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function JingMaiTips.getInstanceNotCreate()
	return _instance
end

function JingMaiTips.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function JingMaiTips.ToggleOpenClose()
	if not _instance then
		_instance = JingMaiTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function JingMaiTips.GetLayoutFileName()
	return "jingmaitips.layout"
end

function JingMaiTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, JingMaiTips)
	return self
end

function JingMaiTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_bg = winMgr:getWindow("jingmaitips")
	self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("jingmaitips/rich"))
	self.petSkillName = winMgr:getWindow("jingmaitips/name")
	self.petSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("jingmaitips/jineng"))
	self.petSkillIcon:SetBackGroundEnable(true)
    self.petSkillIcon:SetBackGroupOnTop(true)
	self.xingchenitem = CEGUI.toItemCell(winMgr:getWindow("jingmaitips/xingchenitem"))
	self.xingchenshuxing = winMgr:getWindow("jingmaitips/xingchenshuxing")
	self.tihuan = CEGUI.toPushButton(winMgr:getWindow( "jingmaitips/tihuan"))
	self.quxia = CEGUI.toPushButton(winMgr:getWindow( "jingmaitips/yiwang"))
	self.jihuo = CEGUI.toPushButton(winMgr:getWindow( "jingmaitips/jihuo"))
	self.xiangqian = CEGUI.toPushButton(winMgr:getWindow( "jingmaitips/xiangqian"))
	self.guanbi = CEGUI.toPushButton(winMgr:getWindow( "jingmaitips/guanbi"))
	self.guanbi:subscribeEvent("MouseClick", JingMaiTips.handleguanbiClicked, self)
	self.tihuan:subscribeEvent("MouseClick", JingMaiTips.handletihuanClicked, self)
	self.quxia:subscribeEvent("MouseClick", JingMaiTips.handlequxiaClicked, self)
	self.jihuo:subscribeEvent("MouseClick", JingMaiTips.handlejihuoClicked, self)
	self.xiangqian:subscribeEvent("MouseClick", JingMaiTips.handlexiangqianClicked, self)
	self.triggerWnd = nil
	self.skillid = 0
	self.duedate = 0
	self.data = nil
	self.index = 0
    self.originRichboxWidth = self.editbox:getPixelSize().width
    self.originBgWidth = self.m_bg:getPixelSize().width

end
function JingMaiTips:handleguanbiClicked(args)
	self:DestroyDialog();
	return true
end
function JingMaiTips:handletihuanClicked(args)

	require "logic.workshop.jingmai.jingmaixingchencell2":GetSingletonDialogAndShowIt(self.index,self.data)
	self:DestroyDialog();
	return true
end
function JingMaiTips:handlequxiaClicked(args)

	local function ClickYes(self, args)
		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		local p = require "logic.workshop.jingmai.cjingmaisel":new()
		p.idx = 6 --normal
		p.index = self.index--normal
		require "manager.luaprotocolmanager":send(p)
	self.DestroyDialog()

	end
	local function ClickNo(self, args)
		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		if _instance then
			_instance.DestroyDialog()
		end
	end

	local text = MHSD_UTILS.get_resstring(11930)
	gGetMessageManager():AddConfirmBox(eConfirmNormal, text, ClickYes,
			self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))

	return true
end
function JingMaiTips:handlejihuoClicked(args)

	if self.data.jingmais[self.index]~=0 then
		return
	end
	if self.index~=1 and self.data.jingmais[self.index-1]==0 then
		GetCTipsManager():AddMessageTipById(199003)
		return
	end
	if self.data.state==0 then
		GetCTipsManager():AddMessageTipById(199004)
		return
	end


	if self.index>=1 and self.index<=12 then
		require "logic.workshop.jingmai.jingmaijihuo1".getInstanceAndShow(self.data,self.index)
	else
		require "logic.workshop.jingmai.jingmaijihuo2".getInstanceAndShow(self.data,self.index)
	end



	--local p = require "logic.workshop.jingmai.cjingmaisel":new()
	--p.idx = 3 --normal
	--p.index = self.index --normal
	--require "manager.luaprotocolmanager":send(p)
	self.DestroyDialog()
	return true
end
function JingMaiTips:handlexiangqianClicked(args)
	require "logic.workshop.jingmai.jingmaixingchencell1":GetSingletonDialogAndShowIt(self.index,self.data)
	self:DestroyDialog();
	return true
end

function JingMaiTips.ShowTip(skillid1,skillid2,data,index)
	JingMaiTips.getInstanceAndShow()
	_instance:showSkillTips(skillid1,skillid2,data,index)
	return _instance
end
function JingMaiTips:showSkillTips(skillid1,skillid2,data,index)
	_instance.index=index
	_instance.data=data
	self.tihuan:setVisible(false)
	self.quxia:setVisible(false)
	self.jihuo:setVisible(false)
	self.xingchenitem:setVisible(false)
	self.xingchenshuxing:setVisible(false)
	self.xiangqian:setVisible(false)
	if data.jingmais[index]==0 then
		self.jihuo:setVisible(true)
	else
		if skillid2~=0 then
			if not data.xingchen[index] then
				self.xiangqian:setVisible(true)
				local xingchennum=0
				for k,v in pairs(data.xingchen) do
					if v then
						xingchennum=xingchennum+1
					end
				end
				local jihuox=0
				for k,v in pairs(data.jingmais) do
					if v==1 then
						jihuox=jihuox+1
					end
				end
				local keqianxian=0
				if GetMainCharacter():GetLevel()<=69 then
					keqianxian=5
				elseif GetMainCharacter():GetLevel()>=70 and GetMainCharacter():GetLevel()<=89 then
					keqianxian=6
				elseif GetMainCharacter():GetLevel()>=90 then
					keqianxian=7
				end
				if jihuox>=16 then
					keqianxian=keqianxian+1
				end
				if xingchennum >= keqianxian then
					self.xiangqian:setEnabled(false)
					self.xiangqian:setText(MHSD_UTILS.get_resstring(11927))
				else
					self.xiangqian:setEnabled(true)
					self.xiangqian:setText(MHSD_UTILS.get_resstring(11926))
				end
			else
				self.tihuan:setVisible(true)
				self.quxia:setVisible(true)
			end
		end
	end


	local skill1 = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(skillid1)
	self.editbox:Clear()
	self.petSkillName:setText(skill1.name)
	self.petSkillIcon:SetImage(gGetIconManager():GetSkillIconByID(skill1.icon))
	self.editbox:AppendImage(CEGUI.String("common"), CEGUI.String("common_biaoshi_cc"))
	self.editbox:AppendBreak()
	self.petSkillIcon:SetBackgroundDynamic(true)

	local skillEffectColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff696969")) --SKILLEFFECT_COLOR
	self.editbox:AppendText(CEGUI.String("激活效果:"), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff87cefa"))) --����
	self.editbox:AppendBreak()
	if data.jingmais[index]==0 then
		self.editbox:AppendText(CEGUI.String(skill1.describe), skillEffectColor) --����
	else
		self.editbox:AppendText(CEGUI.String(skill1.describe), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff7fff00"))) --����
	end

	self.editbox:AppendBreak()
	if skillid2~=0 then
		local skill2 = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(skillid2)
		self.editbox:AppendText(CEGUI.String("镶嵌效果:"), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff87cefa"))) --����
		self.editbox:AppendBreak()
		if not data.xingchen[index] then
			local sb = StringBuilder:new()
			sb:Set("parameter1", skill2.jingmaizhi)
			local strMsg = sb:GetString(skill2.describe)
			sb:delete()
			self.editbox:AppendText(CEGUI.String(strMsg), skillEffectColor) --����
		else
			local sb = StringBuilder:new()
			sb:Set("parameter1", skill2.jingmaizhi*data.xingchen[index].pinzhi/100)
			local strMsg = sb:GetString(skill2.describe)
			sb:delete()
			self.editbox:AppendText(CEGUI.String(strMsg), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff7fff00"))) --����
			self.xingchenitem:setVisible(true)
			self.xingchenshuxing:setVisible(true)
			local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(data.xingchen[index].id)
			self.xingchenitem:SetImage(gGetIconManager():GetItemIconByID(needItemCfg.icon))
			self.xingchenshuxing:setText(MHSD_UTILS.get_resstring(11000)..":"..data.xingchen[index].naijiu.." "..MHSD_UTILS.get_resstring(1456)..data.xingchen[index].pinzhi)
		end
		self.editbox:AppendBreak()
	end


	--if petskill.skilltype == 1 then
	--	self.editbox:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(2160)), skillEffectColor) --����
	--else
	--	self.editbox:AppendText(CEGUI.String(petskill.param), skillEffectColor)
	--end
	--self.editbox:AppendBreak()

	--self.editbox:AppendImage(CEGUI.String("common"), CEGUI.String("common_biaoshi_cc"))
	--self.editbox:AppendBreak()
	--
	----��������
	--self.editbox:AppendParseText(CEGUI.String(petskill.skilldescribe))

	self.editbox:setSize(NewVector2(self.originRichboxWidth, 30))
	self.editbox:Refresh()
	local needSize = self.editbox:GetExtendSize()
	if needSize.width < self.originRichboxWidth then
		needSize.width = self.originRichboxWidth
	end
	needSize.height = needSize.height+10
	self.editbox:setSize(NewVector2(needSize.width, needSize.height))
	--	--��ʱЧ�ĳ��＼�ܣ�tipsҪ��ʾ����ʣ��ʱ��
	--	if duedate and duedate > 0 then
	--		local curTime = gGetServerTime()
	--		local strLeftTime = self:leftTimeToString(duedate - curTime)
	--		self.editbox:AppendText(CEGUI.String(strLeftTime), skillEffectColor)
	--		self.editbox:AppendBreak()
	--	end
	--
	--	self.editbox:setSize(NewVector2(self.originRichboxWidth, 30))
	--	self.editbox:Refresh()
	--
	--	local needSize = self.editbox:GetExtendSize()
	--	if needSize.width < self.originRichboxWidth then
	--		needSize.width = self.originRichboxWidth
	--	end
	--	needSize.height = needSize.height+10
	--	self.editbox:setSize(NewVector2(needSize.width, needSize.height))
    --    --self.m_bg:setSize(NewVector2(self.originBgWidth, needSize.height + 150))
	--end
	--
	--local x
	--local y
	--
	--if xpos then
	--	local tw = self:GetWindow():getPixelSize().width
	--	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	--
	--	x = xpos + SKILLCELL_WIDTH
	--	if xpos == 0 then
	--		x = (pw - tw) * 0.5
	--	else
	--		if x + tw > pw then
	--			x = x - tw
	--		end
	--	end
	--end
	--
	--if ypos then
	--	local th = self:GetWindow():getPixelSize().height
	--	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	--
	--	y = ypos + SKILLCELL_WIDTH
	--	if ypos == 0 then
	--		y = (ph - th) * 0.5
	--	else
	--		if y + th > ph then
	--			if y > th then
	--				y = y - th
	--			else
	--				y = ph - th
	--			end
	--		end
	--	end
	--end
	--
	----if x and y then
	----	self.m_bg:setPosition(NewVector2(x, y))
	----elseif x then
	----	self.m_bg:setXPosition(CEGUI.UDim(0, x))
	----elseif y then
	----	self.m_bg:setYPosition(CEGUI.UDim(0, y))
	----end
	--
	--self.willCheckTipsWnd = false
end

function JingMaiTips:leftTimeToString(lefttime)
	if lefttime < 0 then
		return MHSD_UTILS.get_resstring(2161) --�ѵ���
	end

	local day = math.floor(lefttime/1000) / (24*3600)
	local hour = math.floor((math.floor(lefttime/1000) % (24*3600)) / 3600)

	local str = MHSD_UTILS.get_resstring(2162) --ʣ��:
	if day == 0 and hour == 0 then
		return str .. MHSD_UTILS.get_resstring(2163) --����һСʱ
	end

	if day >= 1 then
		return str .. day .. MHSD_UTILS.get_resstring(2164) --��
	end

	return str .. hour .. MHSD_UTILS.get_resstring(2165) --Сʱ
end

return JingMaiTips
