require "logic.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

NewsWarnDlg = {}
setmetatable(NewsWarnDlg, Dialog)
NewsWarnDlg.__index = NewsWarnDlg 


local _instance
local isHideWebView = false

function NewsWarnDlg.getInstance()
    if not _instance then
        _instance = NewsWarnDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function NewsWarnDlg.getInstanceAndShow()
    if not _instance then
        _instance = NewsWarnDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function NewsWarnDlg.getInstanceNotCreate()
    return _instance
end

function NewsWarnDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
           gGetGameUIManager():removeGameUpdateTextView()
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NewsWarnDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NewsWarnDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NewsWarnDlg.GetLayoutFileName()
    return "newswarn.layout"
end

function NewsWarnDlg:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.movingToFront = false

    self.board = winMgr:getWindow("NewsWarn")
    
    self.m_boxNewsContent = CEGUI.Window.toRichEditbox(winMgr:getWindow("NewsWarn/main") )
    self.m_boxNewsContent:setReadOnly(true)
    self.m_boxNewsContent:setTopAfterLoadFont(true)

    self.m_btnOK = CEGUI.Window.toPushButton(winMgr:getWindow("NewsWarn/btn"))
    self.m_btnOK:subscribeEvent("Clicked", NewsWarnDlg.HandleOKBtnClicked, self)
    
    self:GetWindow():subscribeEvent("ZChanged", NewsWarnDlg.handleZchange, self)

    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        self.exec_done = false
        self.cnt = 0
    else
        self:RefreshUpdateContent()
    end
end
function NewsWarnDlg:handleZchange(e)
    if not self.movingToFront then
        self.movingToFront = true
        if self:GetWindow():getParent() then
            local drawList = self:GetWindow():getParent():getDrawList()
            if drawList:size() > 0 then
                local topWnd = drawList[drawList:size()-1]
                self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(topWnd, "CEGUI::Window"))
            end
        end
        self.movingToFront = false
    end
end
function NewsWarnDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NewsWarnDlg)

    return self
end

function NewsWarnDlg.Update_Cpp()
	if _instance and DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        if not _instance.exec_done then
            _instance.cnt = _instance.cnt + 1
            if _instance.cnt > 30 then
                _instance:RefreshUpdateContent()
                _instance.exec_done = true
            end
        end
    end
end

function NewsWarnDlg:update(delta)
    if _instance then
        if self:IsVisible() == false or self:GetWindow():getEffectiveAlpha() == 0 or  gGetScene():isLoadMaping() then --or gGetMessageManager():isHaveConfirmBox() or gGetMessageManager():isHaveMessageBox() then
            if not isHideWebView then
                isHideWebView = true
                gGetGameUIManager():hideGameUpdateTextView()
            end
        else
            if isHideWebView then
                isHideWebView = false
                gGetGameUIManager():resumeGameUpdateTextView()
            end
        end
    end
end

function NewsWarnDlg.hideBoard()
    if _instance then
        _instance.board:setVisible(false)
    end
end

function NewsWarnDlg.showBoard()
    if _instance then
        _instance.board:setVisible(true)
    end
end


function NewsWarnDlg:HandleOKBtnClicked(args)
    NewsWarnDlg.DestroyDialog()
    return true
end

function NewsWarnDlg:RefreshUpdateContent()
    gGetGameUIManager():showGameUpdateTextView()
end


return NewsWarnDlg
