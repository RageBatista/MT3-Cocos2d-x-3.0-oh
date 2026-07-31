------------------------------------------------------------------
-- ���＼��tip
------------------------------------------------------------------
require "logic.dialog"

WenShiTips = {}
setmetatable(WenShiTips, Dialog)
WenShiTips.__index = WenShiTips

local SKILLCELL_WIDTH = 38

local _instance
function WenShiTips.getInstance()
	if not _instance then
		_instance = WenShiTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function WenShiTips.getInstanceAndShow()
	if not _instance then
		_instance = WenShiTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function WenShiTips.getInstanceNotCreate()
	return _instance
end

function WenShiTips.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WenShiTips.ToggleOpenClose()
	if not _instance then
		_instance = WenShiTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function WenShiTips.GetLayoutFileName()
	return "wenshitips.layout"
end

function WenShiTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, WenShiTips)
	return self
end

function WenShiTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_bg = winMgr:getWindow("wenshitips")
	self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("wenshitips/rich"))
	self.petSkillName = winMgr:getWindow("wenshitips/name")
	self.petSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("wenshitips/jineng"))
	self.petSkillIcon:SetBackGroundEnable(true)
    self.petSkillIcon:SetBackGroupOnTop(true)
	self.tihuan = CEGUI.toPushButton(winMgr:getWindow( "wenshitips/tihuan"))
	self.quxia = CEGUI.toPushButton(winMgr:getWindow( "wenshitips/quxia"))


	self.tihuan:subscribeEvent("MouseClick", WenShiTips.handletihuanClicked, self)
	self.quxia:subscribeEvent("MouseClick", WenShiTips.handlequxiaClicked, self)
	self.close = winMgr:getWindow("wenshitips/x")
	self.close:subscribeEvent("MouseClick", self.DestroyDialog, nil)


	self.triggerWnd = nil
	self.skillid = 0
	self.duedate = 0
	self.data = nil
	self.index = 0
	self.zuoqiid = 0
    self.originRichboxWidth = self.editbox:getPixelSize().width
    self.originBgWidth = self.m_bg:getPixelSize().width

end
function WenShiTips:handletihuanClicked(args)
	require "logic.zuoqi.zuoqicell1":GetSingletonDialogAndShowIt(self.index,self.zuoqiid,self.data)
	self:DestroyDialog();
	return true
end
function WenShiTips:handlequxiaClicked(args)

	local function ClickYes(self, args)
		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		local p = require "logic.zuoqi.czuoqizyshiyong":new()
		p.zuoqiid = self.zuoqiid--normal
		p.idx = 3 --normal
		p.index = self.index--normal
		require "manager.luaprotocolmanager":send(p)
		_instance.DestroyDialog()
	end
	local function ClickNo(self, args)
		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		if _instance then
			_instance.DestroyDialog()
		end
	end

	local text = MHSD_UTILS.get_resstring(11806)
	gGetMessageManager():AddConfirmBox(eConfirmNormal, text, ClickYes,
			self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))

	return true
end

function WenShiTips:handlexiangqianClicked(args)
	require "logic.workshop.jingmai.jingmaixingchencell1":GetSingletonDialogAndShowIt(self.index,self.data)
	self:DestroyDialog();
	return true
end

function WenShiTips.ShowTip(data,index,zuoqiid)
	WenShiTips.getInstanceAndShow()
	_instance:showSkillTips(data,index,zuoqiid)
	return _instance
end
function WenShiTips:showSkillTips(data,index,zuoqiid)
	_instance.index=index
	_instance.data=data
	_instance.zuoqiid=zuoqiid

	local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(data.wenshiitems[index].id)

	self.editbox:Clear()
	self.petSkillName:setText(ItemCfg.name)
	self.petSkillIcon:SetImage(gGetIconManager():GetSkillIconByID(ItemCfg.icon))
	self.editbox:AppendImage(CEGUI.String("common"), CEGUI.String("common_biaoshi_cc"))
	self.editbox:AppendBreak()
	self.petSkillIcon:SetBackgroundDynamic(true)


	local strJichushuxing = require "utils.mhsdutils".get_resstring(122)
	self.editbox:AppendText(CEGUI.String(strJichushuxing),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	self.editbox:AppendBreak()
	for k,v in pairs(data.wenshiitems[index].shuxing) do
		local nBaseId = k
		local nBaseValue = v
		local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(math.floor(nBaseId/10)*10)
		if nBaseValue ~= 0 then
			if propertyCfg ~=nil then
				if propertyCfg and propertyCfg.id ~= -1 then
					local strTitleName = propertyCfg.name
					local nValue = math.abs(nBaseValue)
					--local nValue = pEquipData.petequipprovalue
					local formatted_number = string.format("%.2f", nValue)
					strTitleName = strTitleName .. " " .. "+" .. tostring(formatted_number)
					strTitleName = "  " .. strTitleName
					strTitleName = CEGUI.String(strTitleName)
					self.editbox:AppendText(strTitleName, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
				end
			end
			self.editbox:AppendBreak()
		end
	end
	self.editbox:AppendText(CEGUI.String("耐久:"..data.wenshiitems[index].naijiu), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	self.editbox:AppendBreak()
	self.editbox:AppendText(CEGUI.String(""),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	self.editbox:AppendBreak()
	self.editbox:AppendText(CEGUI.String("镶嵌：坐骑"),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
	self.editbox:AppendBreak()
	self.editbox:AppendText(CEGUI.String(ItemCfg.destribe),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
	self.editbox:AppendBreak()
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

function WenShiTips:leftTimeToString(lefttime)
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

return WenShiTips
