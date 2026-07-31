require "logic.dialog"

RoleChargeDialog = {}
setmetatable(RoleChargeDialog, Dialog)
RoleChargeDialog.__index = RoleChargeDialog

local _instance

function RoleChargeDialog.getInstance()
	if not _instance then
		_instance = RoleChargeDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function RoleChargeDialog.getInstanceAndShow()
	if not _instance then
		_instance = RoleChargeDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function RoleChargeDialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RoleChargeDialog:OnClose()
	Dialog.OnClose(self);
	getmetatable(self)._instance = nil;
end

function RoleChargeDialog.GetLayoutFileName()
	return "rolecharge.layout"
end

function RoleChargeDialog.getInstanceNotCreate()
	return _instance
end


function RoleChargeDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RoleChargeDialog)
	return self
end

function RoleChargeDialog:getChargeItem()
	-- case eHttpShareUrl:
	-- case eHttpInfoUrl:
	-- case eHttpChatUrl:
	-- case eHttpCommunityUrl:
	-- case eHttpNoticeUrl:
	-- case eHttpConfigUrl:
	-- case eHttpServerInfoUrl:
	-- case eHttpHorseRunUrl:
	-- case eHttpJinglingUrl:
	-- case eHttpKongjianUrl:
    local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
    local action = eHttpShareUrl.."/api/charge_award/getchargeitem"
    local param = {}
    param["account"] = gGetLoginManager():GetAccount()
    param["roleid"] = gGetDataManager():GetMainCharacterID()
	param["serverid"] = tostring(gGetLoginManager():getServerID())
    param["type"] = 2

    local actionname = "getChargeItemRole"
    CTipsManager:ServerPost(action,param,actionname)
end
function RoleChargeDialog:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", RoleChargeDialog.DestroyDialog, nil)
	
    self.scrollable = winMgr:getWindow("rolechargedlg/bg/scrollable") --背景

	self.cells = {}
    self:getChargeItem()

end
function RoleChargeDialog:changeCell(param)
    _instance.chargeData = param
    for k,v in pairs(param.data) do
        _instance:addchargecell(k,v)
    end
end

function RoleChargeDialog:addchargecell(index,data)
	
	local winMgr = CEGUI.WindowManager:getSingleton()

    local width = 633;
    local height = 100;

    local textwidth = 150;
    local textheight = 40;

    local infowidth = 350;
    local infoheight = 80;

    local btnwidth = 90;
    local btnheight = 45;
    
    local barwidth = 150;
    local barheight = 25;
    
    local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF1D0403"))

    local StaticImage = winMgr:createWindow("TaharezLook/common_itemlistbg","chargeawardcell"..index)
    StaticImage:setMousePassThroughEnabled(true)
    StaticImage:setSize(CEGUI.UVector2(CEGUI.UDim(0, width), CEGUI.UDim(0, height)))
    StaticImage:setPosition((CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, 5+(index-1)*105 ))))
    self.scrollable:addChildWindow(StaticImage)
    
    local StaticText = winMgr:createWindow("TaharezLook/StaticText","chargeawardcell"..index.."/title")
    StaticText:setSize(CEGUI.UVector2(CEGUI.UDim(0, textwidth), CEGUI.UDim(0, textheight)))
    StaticText:setPosition(CEGUI.UVector2(CEGUI.UDim(0,12), CEGUI.UDim(0,8)))
    StaticText:setProperty("BackgroundEnabled", "False")
    StaticText:setProperty("HorzFormatting", "HorzCentred")
    StaticText:setProperty("VertFormatting", "VertCentred")
    StaticText:setProperty("MousePassThroughEnabled", "True")
    StaticText:setProperty("AlwaysOnTop", "True")
    StaticText:setProperty("TextColours", "FFAC160B")
    StaticText:setProperty("Font", "simhei-10")
    StaticText:setText(tostring("累计充值"..data.value.."元"))
    StaticImage:addChildWindow(StaticText) 

    local RichEditbox = winMgr:createWindow("TaharezLook/RichEditbox","chargeawardcell"..index.."/info")
    local EditBox = CEGUI.toRichEditbox(RichEditbox)

	EditBox:setFont("simhei-8")
    EditBox:setMousePassThroughEnabled(true)
    EditBox:setSize(CEGUI.UVector2(CEGUI.UDim(0, infowidth), CEGUI.UDim(0, infoheight)))
    EditBox:setPosition((CEGUI.UVector2(CEGUI.UDim(0,172), CEGUI.UDim(0,10))))

    EditBox:Clear()

    EditBox:AppendBreak()
    EditBox:AppendText(CEGUI.String(data.info), color)
    EditBox:AppendBreak()
    EditBox:Refresh()

    StaticImage:addChildWindow(EditBox)

    
    local ImageButton = winMgr:createWindow("TaharezLook/common_honganniu", "chargeawardcell"..index.."/duihuanbutton")
    ImageButton:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnwidth), CEGUI.UDim(0, btnheight)))
    ImageButton:setPosition((CEGUI.UVector2(CEGUI.UDim(0,530), CEGUI.UDim(0,30))))
    ImageButton:setID(index)
	ImageButton:setFont("simhei-10")
    ImageButton:subscribeEvent("Clicked", RoleChargeDialog.handleLingquButtonClick, self)
    ImageButton:setEnabled(true);
    ImageButton:setText("领取")
    local exp = self.chargeData.charge/data.value
    if exp > 1 then
        exp = 1
    end
    if exp < 1 then
        ImageButton:setEnabled(false);
        ImageButton:setText("条件不足")
    end
    if data.lq == 1 then
        ImageButton:setEnabled(false);
        ImageButton:setText("已领取")
    end
    StaticImage:addChildWindow(ImageButton)


    local ProgressBar_green = winMgr:createWindow("TaharezLook/ProgressBar_green", "chargeawardcell"..index.."/chargenumbar")
    local ProgressBar = CEGUI.toProgressBar(ProgressBar_green)
    ProgressBar:setSize(CEGUI.UVector2(CEGUI.UDim(0, barwidth), CEGUI.UDim(0, barheight)))
    ProgressBar:setPosition(CEGUI.UVector2(CEGUI.UDim(0,13), CEGUI.UDim(0,55)))
    ProgressBar:setProgress(exp)
	ProgressBar:setFont("simhei-10")
    ProgressBar:setProperty("FrameEnable", "True")
    ProgressBar:setText(self.chargeData.charge.."/"..data.value)
    StaticImage:addChildWindow(ProgressBar) 
    table.insert(self.cells, StaticImage)
end
function RoleChargeDialog:handleLingquButtonClick(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
    local daycharge = self.chargeData.charge
    local btnparam = self.chargeData['data'][id]
    local check = daycharge/btnparam.value
    if check < 1 then
        GetCTipsManager():AddMessageTipByMsg("当前角色未满足领取条件")
        return false
    end
    
    local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
    local action = eHttpShareUrl.."/api/charge_award/receiverole"
    local param = {}
    param["account"] = gGetLoginManager():GetAccount()
    param["roleid"] = gGetDataManager():GetMainCharacterID()
	param["serverid"] = tostring(gGetLoginManager():getServerID())
    param["chargeid"] = btnparam.id

    local actionname = 'ReceiveRoleCharge'
    
    CTipsManager:ServerPost(action,param,actionname)

end



return RoleChargeDialog