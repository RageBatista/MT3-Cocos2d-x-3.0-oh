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


    self.m_titleTxt = winMgr:getWindow("wenzitoubiao")
    self.m_serverlevelTxt = CEGUI.toRichEditbox(winMgr:getWindow("shuaijianshuoming/shuaijianshuoming1"))
    self.m_smalltitleTxt = winMgr:getWindow("shuaijianliang")
    self.m_biliTxt = winMgr:getWindow("baifenbi")
    self.m_bg = winMgr:getWindow("fuwuqidengji")

end
function ServerLevelTipDlg:setData(level, bili)
    local server = gGetDataManager():getServerLevel()
    if level ==0 and bili == 0 then
        self.m_smalltitleTxt:setText(require "utils.mhsdutils".get_resstring(11505))
        self.m_biliTxt:setText(100 .. "%")
        local huoliColor = "FFFF0000"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_biliTxt:setProperty("TextColours", textColor)
        self.m_smalltitleTxt:setProperty("TextColours", textColor)
    elseif level < 0 then
        
        self.m_smalltitleTxt:setText(require "utils.mhsdutils".get_resstring(11432))
        self.m_biliTxt:setText((bili - 1) * 100 .. "%")
        local huoliColor = "FFFF0000"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_biliTxt:setProperty("TextColours", textColor)
        self.m_smalltitleTxt:setProperty("TextColours", textColor)
    else
        self.m_titleTxt:setText(require "utils.mhsdutils".get_resstring(11505))
        self.m_smalltitleTxt:setText(require "utils.mhsdutils".get_resstring(11433))
        self.m_biliTxt:setText((1 -bili) * 100 .. "%")
        local huoliColor = "FFFF0000"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_biliTxt:setProperty("TextColours", textColor)
        self.m_smalltitleTxt:setProperty("TextColours", textColor)
    end

    local strAllString = require "utils.mhsdutils".get_resstring(11506)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(gGetDataManager():getServerLevel()))
    strbuilder:Set("parameter2", tostring(gGetDataManager():getServerLevelDays()))
    strAllString = strbuilder:GetString(strAllString)
   
    self.m_titleTxt:setText(strAllString)
    strbuilder:delete()

    strAllString = require "utils.mhsdutils".get_resstring(11434)

    self.m_serverlevelTxt:Clear()
    self.m_serverlevelTxt:AppendParseText(CEGUI.String(strAllString))
    self.m_serverlevelTxt:Refresh()
	local size = self.m_serverlevelTxt:GetExtendSize()
	local vec2 = NewVector2(size.width+10, size.height+10)
	self.m_serverlevelTxt:setSize(vec2)
	
	vec2.x.offset = size.width+20
	vec2.y.offset = size.height+100
	self.m_bg:setSize(vec2)
end
return ServerLevelTipDlg