require "logic.dialog"
require "logic.battle.battleskilltip"

OrderEditorDlg = {}
setmetatable(OrderEditorDlg, Dialog)
OrderEditorDlg.__index = OrderEditorDlg

local _instance

function OrderEditorDlg.getInstance()
	if not _instance then
		_instance = OrderEditorDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function OrderEditorDlg.getInstanceAndShow()
	if not _instance then
		_instance = OrderEditorDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function OrderEditorDlg.getInstanceNotCreate()
	return _instance
end

function OrderEditorDlg.DestroyDialog()
    BattleSkillTip.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function OrderEditorDlg.ToggleOpenClose()
	if not _instance then
		_instance = OrderEditorDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function OrderEditorDlg.GetLayoutFileName()
	return "orderedit.layout"
end

function OrderEditorDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, OrderEditorDlg)
	return self
end

function OrderEditorDlg:OnCreate()
	Dialog.OnCreate(self)
    self.m_SkillType = 0
	self.m_mode = 0

    
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.swnd = winMgr:getWindow("orderedit")
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("orderedit/guanbi"))
	self.closeBtn:subscribeEvent("Clicked", self.handleCANCELClicked, self)

    
	self.otherBtn = CEGUI.toGroupButton(winMgr:getWindow("orderedit/them"))
	self.otherBtn:subscribeEvent("MouseButtonDown", self.handleOtherSideClicked, self)
    
	self.myBtn = CEGUI.toGroupButton(winMgr:getWindow("orderedit/ower"))
	self.myBtn:subscribeEvent("MouseButtonDown", self.handleMySideClicked, self)
    

	
    self.buttonlist = {}
    self.viewlistWnd = winMgr:getWindow("orderedit/list")
     for index = 1, 10 do
        local sID = tostring(index)
        local lyout = winMgr:loadWindowLayout("ordercell.layout",sID)

        local sx = math.floor((index-1) % 3) * lyout:getWidth().offset  
        local sy = math.floor((index-1) / 3) * lyout:getHeight().offset +1 
        self.viewlistWnd:addChildWindow(lyout)
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
        
        local info = {}
        info.bi = winMgr:getWindow(sID.."ordercell/bi")
        info.bi:setVisible(false)
        info.add = winMgr:getWindow(sID.."ordercell/add") 
        info.add:setVisible(false)  
        info.text = winMgr:getWindow(sID.."ordercell/text")
        info.text:setText("")
        info.lyout = lyout
        lyout:setID(index)
        lyout:subscribeEvent("MouseButtonUp", OrderEditorDlg.handleOrderClicked, self)
        table.insert(self.buttonlist,info)

        if self.defaultColor == nil then
            self.defaultColor = info.text:getProperty("TextColours")
        end
    end
    self:setShowSide(2)
    GetTeamManager():getMySelfCommand()
end
 
function OrderEditorDlg:handleCANCELClicked(args)  
    self.DestroyDialog()
end
function OrderEditorDlg:handleOtherSideClicked(args)  
    self:setShowSide(2)
end
function OrderEditorDlg:handleMySideClicked(args)
    self:setShowSide(1)
end
function OrderEditorDlg:refresh()
    self:setShowSide(self.m_side)
end

function OrderEditorDlg:setShowSide(side)
    self.m_side = side
    local showAdd = false
    local h = 0
    if self.m_side == 1 then
        self.myBtn:setSelected(true)
        for i=1,#self.buttonlist do
            local cmd = GetTeamManager():getOrderCmd(1,i)
            if cmd then
                self.buttonlist[i].text:setProperty("TextColours", self.defaultColor)
                self.buttonlist[i].text:setText(cmd.txt)
                self.buttonlist[i].bi:setVisible(cmd.edit)
				self.buttonlist[i].add:setVisible(false)
                self.buttonlist[i].lyout:setVisible(true)
                h = h + 1
            else
                if showAdd then
                    self.buttonlist[i].text:setText("")
                    self.buttonlist[i].bi:setVisible(false)
                    self.buttonlist[i].lyout:setVisible(false)
                else
                    self.buttonlist[i].text:setProperty("TextColours", "FFFFFFFF")
                    self.buttonlist[i].text:setText(MHSD_UTILS.get_resstring(11813))
                    self.buttonlist[i].bi:setVisible(false)
					self.buttonlist[i].add:setVisible(true)
                    self.buttonlist[i].lyout:setVisible(true)
                    h = h + 1
                    showAdd = true
                end
            end
        end
    else
        self.otherBtn:setSelected(true)
        for i=1,#self.buttonlist do
            local cmd = GetTeamManager():getOrderCmd(2,i)
            if cmd then
                self.buttonlist[i].text:setProperty("TextColours", self.defaultColor)
                self.buttonlist[i].text:setText(cmd.txt)
                self.buttonlist[i].bi:setVisible(cmd.edit)
				self.buttonlist[i].add:setVisible(false)
                self.buttonlist[i].lyout:setVisible(true)
                h = h + 1
            else
                if showAdd then
                    self.buttonlist[i].text:setText("")
                    self.buttonlist[i].lyout:setVisible(false)
                else
                    self.buttonlist[i].text:setProperty("TextColours", "FFFFFFFF")
                    self.buttonlist[i].text:setText(MHSD_UTILS.get_resstring(11813))
					self.buttonlist[i].add:setVisible(true)
                    self.buttonlist[i].lyout:setVisible(true)
                    h = h + 1
                    showAdd = true
                end
                self.buttonlist[i].bi:setVisible(false)
            end
        end
    end
    h = math.ceil(h/3)
    self.swnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,620), CEGUI.UDim(0,120 + h*85+13)))
    self.viewlistWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,600), CEGUI.UDim(0,h*80+13)))
end
function OrderEditorDlg:handleOrderClicked(args)    
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local cmd = GetTeamManager():getOrderCmd(self.m_side,index)
    if cmd and cmd.edit == false then 
        return
    end
    local dlg = OrderEditorInput.getInstanceAndShow()
    dlg:init(self.m_side,index)
end

local p = require "protodef.fire.pb.battle.battleflag.smodifybattleflag"
function p:process()
    local side = math.floor(self.index / 10) + 1
    local ind = self.index % 10 + GetTeamManager():getDefaultCmdCount(side) + 1
    GetTeamManager():setOrderCmd(side,ind,self.flag)
    local dlg = OrderEditorDlg.getInstanceNotCreate()
    if dlg then
        dlg:refresh()
    end
end
return OrderEditorDlg
