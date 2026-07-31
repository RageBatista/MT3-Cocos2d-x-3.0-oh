-------------------------------------------------------------------------------------------
-- µ»¥˝Ã· æ
-------------------------------------------------------------------------------------------
WaitingDlg = {}
local wndName = "waitingdlg"
local textName = wndName .. "text"

function WaitingDlg.show(parent, str)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local wnd = nil
    if not winMgr:isWindowPresent(wndName) then
        wnd = winMgr:createWindow("TaharezLook/common_diban", wndName)
        wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,200), CEGUI.UDim(0,30)))
        wnd:setAlwaysOnTop(true)
        wnd:setTopMost(true)
        wnd:setProperty("MousePassThroughEnabled", "True")

        local text = winMgr:createWindow("TaharezLook/StaticText", textName)
        text:setSize(wnd:getSize())
        text:setProperty("BackgroundEnabled", "False")
		text:setProperty("FrameEnabled", "False")
		text:setProperty("HorzFormatting", "HorzCentred")
		text:setProperty("VertFormatting", "VertCentred")
		text:setProperty("MousePassThroughEnabled", "True")
		text:setProperty("TextColours", "FFFFFFFF")
		text:setProperty("Font", "simhei-12")
        text:setText(str)
        wnd:addChildWindow(text)
    else
        wnd = winMgr:getWindow(wndName)
        local text = winMgr:getWindow(textName)
        text:setText(str)
    end

    parent = parent or CEGUI.System:getSingleton():getGUISheet()
    if wnd:getParent() ~= parent then
        parent:addChildWindow(wnd)
    end
    wnd:moveToFront()

    local parentSize = parent:getPixelSize()
    SetPositionOffset(wnd, parentSize.width*0.5, parentSize.height*0.5, 0.5, 0.5)
end

function WaitingDlg.hide()
    local winMgr = CEGUI.WindowManager:getSingleton()
    if winMgr:isWindowPresent(wndName) then
        local wnd = winMgr:getWindow(wndName)
        winMgr:destroyWindow(wnd)
    end
end

return WaitingDlg
