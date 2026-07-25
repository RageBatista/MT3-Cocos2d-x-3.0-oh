require "logic.dialog"

WinLoginDlg = {}
setmetatable(WinLoginDlg, Dialog)
WinLoginDlg.__index = WinLoginDlg

ExecMode_Login = 0
ExecMode_LoginAgain = 1

local _instance

function WinLoginDlg.getInstance()
    if not _instance then
        _instance = WinLoginDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WinLoginDlg.getInstanceAndShow()
    if not _instance then
        _instance = WinLoginDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function WinLoginDlg.getInstanceNotCreate()
    return _instance
end

function WinLoginDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
            gGetLoginManager():CloseWinWebView()
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WinLoginDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WinLoginDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function WinLoginDlg.GetLayoutFileName()
    return "winlogindlg.layout"
end

function WinLoginDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.board = winMgr:getWindow("WinLoginDlg")
	--self.board:getCloseButton():subscribeEvent("Clicked", WinLoginDlg.DestroyDialog, nil)
    
    self.m_content = CEGUI.Window.toRichEditbox(winMgr:getWindow("WinLoginDlg/main") )
    self.m_content:setReadOnly(true)
    self.m_content:setTopAfterLoadFont(true)
end

function WinLoginDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WinLoginDlg)

    return self
end

function WinLoginDlg:setExecMode(exec_mode)
    self.exec_mode = exec_mode
    self.exec_done = false
    self.cnt = 0
end

function WinLoginDlg.Update()
	if _instance then
        if _instance.exec_done then
            gGetLoginManager():WinWebViewUpdate()
        else
            _instance.cnt = _instance.cnt + 1
            if _instance.cnt > 30 then
                if _instance.exec_mode == ExecMode_Login then
                    gGetGameUIManager():sdkLogin()
                    _instance.exec_done = true
                elseif _instance.exec_mode == ExecMode_LoginAgain then
                    gGetLoginManager():LoginAgain()
                    _instance.exec_done = true
                end
            end
        end
    end
end

function WinLoginDlg.hideBoard()
    if _instance then
        _instance.board:setVisible(false)
    end
end

function WinLoginDlg.showBoard()
    if _instance then
        _instance.board:setVisible(true)
    end
end

return WinLoginDlg
