require "logic.dialog"

OrderSetDlg = {}
setmetatable(OrderSetDlg, Dialog)
OrderSetDlg.__index = OrderSetDlg

local _instance
function OrderSetDlg.getInstance()
	if not _instance then
		_instance = OrderSetDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function OrderSetDlg.getInstanceAndShow()
	if not _instance then
		_instance = OrderSetDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function OrderSetDlg.getInstanceNotCreate()
	return _instance
end

function OrderSetDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			--[[for _,v in pairs(_instance.m_CellList) do
				v:OnClose(false, false)
			end
			_instance:Clear()]]--
			
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function OrderSetDlg.ToggleOpenClose()
	if not _instance then
		_instance = OrderSetDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function OrderSetDlg.GetLayoutFileName()
	return "order1.layout"
end

function OrderSetDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, OrderSetDlg)
	return self
end

function OrderSetDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
        
    self.bwnd = winMgr:getWindow("order1")

    self.buttonlist = {}
    self.viewlistWnd = winMgr:getWindow("order1/list")
     for index = 1, 13 do
        local sID = tostring(index) .. "SetDlg"
        local lyout = winMgr:loadWindowLayout("orderpkcell.layout",sID)

        local sx = math.floor((index-1) % 2) * lyout:getWidth().offset
        local sy = math.floor((index-1) / 2) * lyout:getHeight().offset +1
        self.viewlistWnd:addChildWindow(lyout)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
        
        local info = {}
        info.bi = winMgr:getWindow(sID.."orderpkcell/bi")
        info.bi:setVisible(false)
        info.text = winMgr:getWindow(sID.."orderpkcell/text")
		info.text:setText("")
        info.lyout = lyout
        lyout:setID(index)
        lyout:subscribeEvent("MouseButtonUp", OrderSetDlg.handleOrderClicked, self)
        table.insert(self.buttonlist,info)
        if self.defaultColor == nil then
            self.defaultColor = info.text:getProperty("TextColours")
        end
    end
    GetTeamManager():getMySelfCommand()
end

function OrderSetDlg:Clear()
	for _,v in pairs(self.m_CellList) do
		v:OnClose(false, false)
	end
	self.m_pList:cleanupNonAutoChildren()
	self.m_CellList = {}
	self.m_CellCount = 0
end
function OrderSetDlg.CSetBattleID(BattleID, PlayerOrPetOrNPC)
	if BattleID == 0 then
		OrderSetDlg.CSetVisible(false)
	else
		OrderSetDlg.CSetVisible(true)
	end
	OrderSetDlg.getInstance():SetBattleID(BattleID, PlayerOrPetOrNPC)
end

function OrderSetDlg.CSetVisible(Visible)
	OrderSetDlg.getInstance():SetVisible(Visible)
end
function OrderSetDlg:handleOrderClicked(args)    
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    
    local Battler = GetBattleManager():FindBattlerByID(self.battlerid)
    if Battler then
        local otxt = Battler:GetFlag()
        local send = require "protodef.fire.pb.battle.battleflag.csetbattleflag":new()
        
        send.index = self.battlerid
        send.flag = ""
        if index == 10000 then
            send.opttype = 1
        elseif index == 10001 then
            send.opttype = 3
        elseif index == 10002 then      
            local orddlg = OrderEditorDlg.getInstanceAndShow() 
            orddlg:setShowSide(self.m_side)                 
        else            
            local txt = self.buttonlist[index].text:getText()
            if txt == "" then
                return
            end
            if otxt == "" then
                send.opttype = 0
            else
                send.opttype = 2
            end
            send.flag = txt
        end
        require "manager.luaprotocolmanager":send(send)

        --Battler:SetFlag(send.flag)
    end
    self:DestroyDialog()
end

function OrderSetDlg:setShowSide(side)
    self.m_side = side
    local ct = 1
    if self.m_side == 1 then
        local mx = GetTeamManager():getOrderCmdCount(1)
        for i=1,mx do
            local cmd = GetTeamManager():getOrderIndexCmd(1,i)
            self.buttonlist[i].text:setProperty("TextColours", self.defaultColor)
            self.buttonlist[i].text:setText(cmd.txt)
            self.buttonlist[i].lyout:setID(i)
            ct = ct + 1
        end
    else
        local mx = GetTeamManager():getOrderCmdCount(2)
        for i=1,mx do
            local cmd = GetTeamManager():getOrderIndexCmd(2,i)
            self.buttonlist[i].text:setProperty("TextColours", self.defaultColor)
            self.buttonlist[i].text:setText(cmd.txt) 
            self.buttonlist[i].lyout:setID(i)
            ct = ct + 1         
        end
    end
        
    self.buttonlist[ct].text:setProperty("TextColours", "FFFFFFFF")
    self.buttonlist[ct].text:setText(MHSD_UTILS.get_resstring(11637))
    self.buttonlist[ct].lyout:setID(10000)
    ct = ct + 1   
    self.buttonlist[ct].text:setProperty("TextColours", "FFFFFFFF")
    self.buttonlist[ct].text:setText(MHSD_UTILS.get_resstring(11638))  
    self.buttonlist[ct].lyout:setID(10001)
    ct = ct + 1   
    self.buttonlist[ct].text:setProperty("TextColours", "FFFFFFFF")
    self.buttonlist[ct].text:setText(MHSD_UTILS.get_resstring(11639)) 
    self.buttonlist[ct].lyout:setID(10002)

    local t = math.min(ct,13)
    for i=1,t do
        self.buttonlist[i].lyout:setVisible(true)
    end
    local h = math.ceil(ct/2)
    self.bwnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,425), CEGUI.UDim(0,h*60+13)))
    self.viewlistWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,410), CEGUI.UDim(0,h*60+13)))
    ct = ct + 1   
    for i=ct,13 do
        self.buttonlist[i].text:setText("")
        self.buttonlist[i].lyout:setID(i)
        self.buttonlist[i].lyout:setVisible(false)
    end
end
function OrderSetDlg:setBattleID(bid)
    self.battlerid = bid
end
function OrderSetDlg:refresh()
    self:setShowSide(self.m_side)
end

return OrderSetDlg
