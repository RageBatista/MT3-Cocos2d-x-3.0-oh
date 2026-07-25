
require "logic.dialog"

XiulianguoTipsDlg = {}
setmetatable(XiulianguoTipsDlg, Dialog)
XiulianguoTipsDlg.__index = XiulianguoTipsDlg

local SKILLCELL_WIDTH = 38

local _instance
function XiulianguoTipsDlg.getInstance()
	if not _instance then
		_instance = XiulianguoTipsDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function XiulianguoTipsDlg.getInstanceAndShow()
	if not _instance then
		_instance = XiulianguoTipsDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function XiulianguoTipsDlg.getInstanceNotCreate()
	return _instance
end

function XiulianguoTipsDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function XiulianguoTipsDlg.ToggleOpenClose()
	if not _instance then
		_instance = XiulianguoTipsDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function XiulianguoTipsDlg.GetLayoutFileName()
	return "xiulianguotips.layout"
end

function XiulianguoTipsDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, XiulianguoTipsDlg)
	self.location=0
	self.fruittype=0
	return self
end

function XiulianguoTipsDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_bg = winMgr:getWindow("xiulianguotips")
	self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("xiulianguotips/rich"))
	self.petSkillName = winMgr:getWindow("xiulianguotips/name")
	 
	self.petSkillIcon = winMgr:getWindow("xiulianguotips/icon")

	self.fanhuanjingyanBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianguotips/fanhuanjingyan"))
	self.genghuanshuxingBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianguotips/genghuanshuxing"))


	self.fanhuanjingyanBtn:subscribeEvent("Clicked", XiulianguoTipsDlg.HandleFanhuan , self)	
	self.genghuanshuxingBtn:subscribeEvent("Clicked", XiulianguoTipsDlg.HandleGenghuan , self)	

	 

	self.triggerWnd = nil
 
	self.duedate = 0

    self.originRichboxWidth = self.editbox:getPixelSize().width
    self.originBgWidth = self.m_bg:getPixelSize().width
end

function XiulianguoTipsDlg:HandleFanhuan(args)

	print("HandleFanhuan self.location=%d", self.location)
	require "protodef.fire.pb.potentialfruit.creturnpotentialfruit"
	local req = CReturnPotentialFruit.Create()
	req.location = self.location
	LuaProtocolManager.getInstance():send(req)
end
function XiulianguoTipsDlg:HandleGenghuan(args)
	

	local function ClickYes(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		print("HandleGenghuan self.location=%d", self.location)
		require "protodef.fire.pb.potentialfruit.cresetpotentialfruit"
		local req = CResetPotentialFruit.Create()
		req.location = self.location
		LuaProtocolManager.getInstance():send(req)
		self:DestroyDialog()
    end
    local function ClickNo(self, args)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        return
    end
	local fruit = BeanConfigManager.getInstance():GetTableByName("qiannengguo.CQiannengguoLevelUp"):getRecorder(self.location)
     local str="更换第"..tostring(self.location).."颗潜能果,需要消耗"..tostring(fruit.resetmoney).."金币,是否进行更换?"
    gGetMessageManager():AddConfirmBox(eConfirmNormal, str, ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(11520),MHSD_UTILS.get_resstring(2036))

	
end

function XiulianguoTipsDlg.ShowTip(location,fruittype, xpos, ypos, duedate)
	XiulianguoTipsDlg.getInstanceAndShow()
	_instance.fruittype=fruittype
	_instance:showXiulianguoTips(location,fruittype, xpos, ypos, duedate)
	return _instance
end

function XiulianguoTipsDlg:showXiulianguoTips(location, fruittype,xpos, ypos, duedate)
	local fruit = BeanConfigManager.getInstance():GetTableByName("qiannengguo.CQiannengguo"):getRecorder(fruittype)
	if fruit == nil then
		self:GetWindow():setVisible(false)
		return
	end

	if self.location ~= location or self.duedate ~= duedate then
		self.location = location
		self.duedate = duedate
--���＼�ܿ��޸�
		self.editbox:Clear()
		self.petSkillName:setText(fruit.name)
	 
		self.petSkillIcon:setProperty("Image",fruit.image)
		--self.editbox:AppendImage(CEGUI.String("common"), CEGUI.String("common_biaoshi_cc"))
		--self.editbox:AppendBreak()
        
		local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(fruit.proptype)
		 
		--��������
		self.editbox:AppendText(CEGUI.String(propertyCfg.name.." +"..tostring(fruit.propvalue)))
		self.editbox:AppendBreak()
	
		 
		self.editbox:setSize(NewVector2(self.originRichboxWidth, 30))
		self.editbox:Refresh()

		local needSize = self.editbox:GetExtendSize()
		if needSize.width < self.originRichboxWidth then
			needSize.width = self.originRichboxWidth
		end
		needSize.height = needSize.height+10
		self.editbox:setSize(NewVector2(needSize.width, needSize.height))
        self.m_bg:setSize(NewVector2(self.originBgWidth, needSize.height + 240))
	end

	local x
	local y

	if xpos then
		local tw = self:GetWindow():getPixelSize().width
		local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width

		x = xpos + SKILLCELL_WIDTH
		if xpos == 0 then
			x = (pw - tw) * 0.5
		else
			if x + tw > pw then
				x = x - tw
			end
		end
	end

	if ypos then
		local th = self:GetWindow():getPixelSize().height
		local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height

		y = ypos + SKILLCELL_WIDTH
		if ypos == 0 then
			y = (ph - th) * 0.5
		else
			if y + th > ph then
				if y > th then
					y = y - th
				else
					y = ph - th
				end
			end
		end
	end

	if x and y then
		self.m_bg:setPosition(NewVector2(x, y))
	elseif x then
		self.m_bg:setXPosition(CEGUI.UDim(0, x))
	elseif y then
		self.m_bg:setYPosition(CEGUI.UDim(0, y))
	end

	self.willCheckTipsWnd = false

	self.fanhuanjingyanBtn:setAlwaysOnTop(true)
	self.genghuanshuxingBtn:setAlwaysOnTop(true)
end

function XiulianguoTipsDlg:leftTimeToString(lefttime)
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

return XiulianguoTipsDlg
