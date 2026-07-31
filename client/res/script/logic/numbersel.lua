require "logic.dialog"

NumberSelDlg = {}
setmetatable(NumberSelDlg, Dialog)
NumberSelDlg.__index = NumberSelDlg

local _instance
function NumberSelDlg.getInstance(parent,numlist,callback)
	if not _instance then
		_instance = NumberSelDlg:new()
		_instance:OnCreate(parent,numlist,callback)
	end
	return _instance
end
function NumberSelDlg.getInstanceAndShow(parent,numlist,callback)
	if not _instance then
		_instance = NumberSelDlg:new()
		_instance:OnCreate(parent,numlist,callback)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NumberSelDlg.getInstanceNotCreate()
	return _instance
end
function NumberSelDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NumberSelDlg.GetLayoutFileName()
	return "leitaishaixuan_mtg.layout"
end

function NumberSelDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NumberSelDlg)
	return self
end

function NumberSelDlg:OnCreate(parent,numlist,callback)
    local strBattleAI = "battleai"
	Dialog.OnCreate(self,parent,strBattleAI)
	local winMgr = CEGUI.WindowManager:getSingleton()
    --local sID = tostring(index)
    self.currentID = 0
	self.m_framewindow = winMgr:getWindow(strBattleAI.."leitaishaixuan_mtg")
    self.m_framewindow:setAlwaysOnTop(true)
    for i=1,#numlist do
        local lyout =  CEGUI.Window.toPushButton(winMgr:loadWindowLayout("guajifuzhucell2_mtg.layout",i));
        lyout:setID(i)
	    lyout:subscribeEvent("MouseButtonUp", callback, self)
	    --lyout:subscribeEvent("MouseButtonUp", NumberSelDlg.handleNumClicked, self)
        lyout:setText(tostring(numlist[i]))
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, 10), CEGUI.UDim(0.0, 8+55*(i-1))))
        self:GetWindow():addChildWindow(lyout)
    end
    self.m_framewindow:setSize(CEGUI.UVector2(CEGUI.UDim(0, 75), CEGUI.UDim(0, #numlist*59)))
end

function NumberSelDlg:setCallBack(func,param)
    self.func = func
    self.param = param
end

function NumberSelDlg:OnClose()  
	Dialog.OnClose(self)        
end

function NumberSelDlg:handleNumClicked(args)    
    local e = CEGUI.toWindowEventArgs(args)
	self.currentID = e.window:getID()
    self:DestroyDialog()
end
return NumberSelDlg
