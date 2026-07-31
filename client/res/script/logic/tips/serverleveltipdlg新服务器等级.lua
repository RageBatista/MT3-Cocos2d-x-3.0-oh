
require "logic.dialog"

ServerLevelTipDlg = {}
setmetatable(ServerLevelTipDlg, Dialog)
ServerLevelTipDlg.__index = ServerLevelTipDlg

local _instance
function ServerLevelTipDlg.getInstance()
	if not _instance then
		_instance = ServerLevelTipDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ServerLevelTipDlg.getInstanceAndShow()
	if not _instance then
		_instance = ServerLevelTipDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ServerLevelTipDlg.getInstanceNotCreate()
	return _instance
end

function ServerLevelTipDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ServerLevelTipDlg.ToggleOpenClose()
	if not _instance then
		_instance = ServerLevelTipDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ServerLevelTipDlg.GetLayoutFileName()
	return "fuwuqidengji.layout"
end

function ServerLevelTipDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ServerLevelTipDlg)
	return self
end

function ServerLevelTipDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_bg = winMgr:getWindow("fuwuqidengji")---界面
	
	self.m_smalltitleTxt = winMgr:getWindow("shuaijianliang")--加成显示
    self.m_biliTxt = winMgr:getWindow("baifenbi")--加成比例
    self.m_titleTxt = winMgr:getWindow("wenzitoubiao")---服务器等级
	self.m_newTxt = CEGUI.toRichEditbox(winMgr:getWindow("newTxt"))
    self.m_serverlevelTxt = CEGUI.toRichEditbox(winMgr:getWindow("shuaijianshuoming/shuaijianshuoming1"))---经验说明
	self.m_cbhp = winMgr:getWindow("syhp")
    self.m_cbmp = winMgr:getWindow("symp")
	
	self.m_btnAdd = CEGUI.toPushButton(winMgr:getWindow("fuwuqidengji/cc3/tzsd"))
	self.m_btnAdd:subscribeEvent("Clicked", ServerLevelTipDlg.HandlerBtnAddClicked, self)
	
    self.m_dateTxt = winMgr:getWindow("fuwuqidengji/cc2/riqi")
    self:GetWindow():subscribeEvent("WindowUpdate", self.onUpdate, self) 
	
	self.shuomingtips = CEGUI.toRichEditbox(winMgr:getWindow("fuwuqidengji/cc1/ccyy"))
	self.shuomingtips:Clear()
    self.shuomingtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(11432)))
    self.shuomingtips:Refresh()
	
	self.jingyantips = CEGUI.toRichEditbox(winMgr:getWindow("fuwuqidengji/cc1/ccyy1"))
	self.jingyantips:Clear()
    self.jingyantips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(11434)))
    self.jingyantips:Refresh()
end
function ServerLevelTipDlg:onUpdate(args)
   -- 获取当前时间 
   local currentTime = os.date("*t")
   
   -- 格式化日期和时间 
   local formattedDateTime = string.format("%d年/%d月/%d日 %02d:%02d:%02d",
                                      currentTime.year, currentTime.month, currentTime.day,
                                      currentTime.hour, currentTime.min, currentTime.sec)
   
   -- 设置日期时间文本 
   self.m_dateTxt:setText(formattedDateTime)
end
function ServerLevelTipDlg.HandlerBtnAddClicked( args )
    local dlg = require "logic.shop.npcshop":getInstanceAndShow()
    dlg:setShopType( SHOP_TYPE.WINESHOP )
end
function ServerLevelTipDlg:setData(level, bili)
    local server = gGetDataManager():getServerLevel()
    -- 将颜色定义提前
    local huoliColor = "FFF4D8B9" 
    local otherColor = "FF33FF00"
    
    if level ==0 and bili == 0 then
        self.m_smalltitleTxt:setText(require "utils.mhsdutils".get_resstring(11505))
        self.m_biliTxt:setText(100 .. "%")

        -- 应用颜色到文本框
        local textColor1 = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        local textColor2 = "tl:"..otherColor.." tr:"..otherColor.." bl:"..otherColor.." br:"..otherColor 
        self.m_biliTxt:setProperty("TextColours", textColor2) 
        self.m_smalltitleTxt:setProperty("TextColours", textColor1) 
    elseif level < 0 then
        
        self.m_smalltitleTxt:setText(require "utils.mhsdutils".get_resstring(11432))
        self.m_biliTxt:setText((bili - 1) * 100 .. "%")

        -- 应用颜色到文本框
        local textColor1 = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        local textColor2 = "tl:"..otherColor.." tr:"..otherColor.." bl:"..otherColor.." br:"..otherColor 
        self.m_biliTxt:setProperty("TextColours", textColor2)
        self.m_smalltitleTxt:setProperty("TextColours", textColor1) 
    else
        self.m_titleTxt:setText(require "utils.mhsdutils".get_resstring(11505))
        self.m_smalltitleTxt:setText(require "utils.mhsdutils".get_resstring(11433))
        self.m_biliTxt:setText((1 -bili) * 100 .. "%")

        -- 应用颜色到文本框
        local textColor1 = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        local textColor2 = "tl:"..otherColor.." tr:"..otherColor.." bl:"..otherColor.." br:"..otherColor 
        self.m_biliTxt:setProperty("TextColours", textColor2) 
        self.m_smalltitleTxt:setProperty("TextColours", textColor1)
    end
	


    local strAllString = require "utils.mhsdutils".get_resstring(11506)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(gGetDataManager():getServerLevel()))
    strbuilder:Set("parameter2", tostring(gGetDataManager():getServerLevelDays()))
    strAllString = strbuilder:GetString(strAllString)
   
    self.m_titleTxt:setText(strAllString)
    strbuilder:delete()
	
	self.m_titleTxt:setText(strAllString)  
    strbuilder:delete()

    self.m_newTxt:Clear()
    self.m_newTxt:AppendParseText(CEGUI.String(strAllString)) 
    self.m_newTxt:Refresh()

    strAllString = require "utils.mhsdutils".get_resstring(11434)
	
    self.m_serverlevelTxt:Clear()
    self.m_serverlevelTxt:AppendParseText(CEGUI.String(strAllString)) 
    self.m_serverlevelTxt:Refresh()
	
	
    local size = self.m_serverlevelTxt:GetExtendSize()
    local vec2 = NewVector2(size.width+10, size.height+10)
    self.m_serverlevelTxt:setSize(vec2)
    
    vec2.x.offset = size.width+28
    vec2.y.offset = size.height+350
    self.m_bg:setSize(vec2) 
	
	local hpStore = gGetDataManager():GetHPMPStoreByID(500009) 
    local mpStore = gGetDataManager():GetHPMPStoreByID(500010) 

    self.m_cbhp:setText(tostring(hpStore))
    self.m_cbmp:setText(tostring(mpStore))
end
return ServerLevelTipDlg