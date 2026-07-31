require "logic.dialog"

ShengSiZhanWatchDlg = {}
setmetatable(ShengSiZhanWatchDlg, Dialog)
ShengSiZhanWatchDlg.__index = ShengSiZhanWatchDlg

local _instance
function ShengSiZhanWatchDlg.getInstance()
	if not _instance then
		_instance = ShengSiZhanWatchDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShengSiZhanWatchDlg.getInstanceAndShow()
	if not _instance then
		_instance = ShengSiZhanWatchDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShengSiZhanWatchDlg.getInstanceNotCreate()
	return _instance
end

function ShengSiZhanWatchDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShengSiZhanWatchDlg.ToggleOpenClose()
	if not _instance then
		_instance = ShengSiZhanWatchDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShengSiZhanWatchDlg.GetLayoutFileName()
	return "shengsizhanguanzhan_mtg.layout"
end

function ShengSiZhanWatchDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShengSiZhanWatchDlg)
	return self
end

function ShengSiZhanWatchDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.viewlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("shengsizhanguanzhan_mtg/list"));
    self.viewlistWnd:EnableHorzScrollBar(false)
    
    self.nobody = winMgr:getWindow("shengsizhanguanzhan_mtg/di/wuren")
    self.nobody:setVisible(true)

    self.m_iconList = {}
    
	local p = require "protodef.fire.pb.battle.livedie.clivediebattlewatchview":new()
	require "manager.luaprotocolmanager":send(p)
end

function ShengSiZhanWatchDlg:handleSureClicked(args)
    return true
end

function ShengSiZhanWatchDlg:handleCANCELClicked(args)  
    self.DestroyDialog()
end

function ShengSiZhanWatchDlg:releaseIcon()
    local sz = #self.m_iconList
    for index  = 1, sz do
        local lyout = self.m_iconList[1]
        self.viewlistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_iconList,1)
	end
end
function ShengSiZhanWatchDlg:setData(datalist)
    self:releaseIcon()
    local sx = 12.0;
    local sy = 2.0;
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sz = #datalist
    for index = 1, sz do
        local sID = tostring(index)
        local lyout = winMgr:loadWindowLayout("shengsizhanguanzhancell_mtg.layout",sID);
        self.viewlistWnd:addChildWindow(lyout)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx ), CEGUI.UDim(0.0, sy + (index-1) * (lyout:getHeight().offset+8))))

        lyout.data = datalist[index]

        winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/mingzi"):setText(lyout.data.role1.rolename)
        winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/mingzi1"):setText(lyout.data.role2.rolename)

        local headA = CEGUI.Window.toItemCell(winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/ren1")) 
        local headB = CEGUI.Window.toItemCell(winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/ren11")) 
        
        local shapeDataA = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(lyout.data.role1.shape)
	    local imageA = gGetIconManager():GetImageByID(shapeDataA.littleheadID)
	    headA:SetImage(imageA)
        
        local shapeDataB = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(lyout.data.role2.shape)
	    local imageB = gGetIconManager():GetImageByID(shapeDataB.littleheadID)
	    headB:SetImage(imageB)

        local schoolA = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/zhiye")
        local schoolArecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(lyout.data.role1.school)
        schoolA:setProperty("Image", schoolArecord.schooliconpath)
        local schoolB = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/zhiye1")
        local schoolBrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(lyout.data.role2.school)
        schoolB:setProperty("Image", schoolBrecord.schooliconpath)

        local watchbtn = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/btnzan")
        watchbtn:setID(index)
	    watchbtn:subscribeEvent("MouseButtonUp", ShengSiZhanWatchDlg.handleWatchClicked, self)

        if lyout.data.role1.teamnum == 0 then
            local tText1 = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/zudui")
            local tText2 = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/zudui1")
            tText1:setVisible(false)
            tText2:setVisible(false)
            local tTextNum1 = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/duiwurenshu1")
            local tTextNum2 = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/duiwurenshu")
            tTextNum1:setVisible(false)
            tTextNum2:setVisible(false)
        else
            local tTextNum1 = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/duiwurenshu1")
            local tTextNum2 = winMgr:getWindow(sID.."shengsizhanguanzhancell_mtg/duiwurenshu")
            tTextNum1:setText(tostring(lyout.data.role1.teamnum) .. "/" .. tostring(lyout.data.role1.teamnummax))
            tTextNum2:setText(tostring(lyout.data.role2.teamnum) .. "/" .. tostring(lyout.data.role2.teamnummax))
            tTextNum1:setVisible(true)
            tTextNum2:setVisible(true)
        end
        table.insert(self.m_iconList, lyout)
	end
    if #self.m_iconList > 0 then
        self.nobody:setVisible(false)
    else
        self.nobody:setVisible(true)
    end
end

function ShengSiZhanWatchDlg:handleWatchClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local dt = self.m_iconList[index].data
    local p = require("protodef.fire.pb.battle.csendwatchbattle"):new()
    p.roleid = dt.role1.roleid
	LuaProtocolManager:send(p)
    self:DestroyDialog()
end

local p = require "protodef.fire.pb.battle.livedie.slivediebattlewatchview"
function p:process()
    local dlg = ShengSiZhanWatchDlg.getInstanceAndShow()
    if dlg then
        dlg:setData(self.rolewatchlist)
    end
end

return ShengSiZhanWatchDlg
