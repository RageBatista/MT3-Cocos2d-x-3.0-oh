require "logic.dialog"
require "logic.shengsizhan.fenxianglistdlg"

ShengSiBangDlg = {}
setmetatable(ShengSiBangDlg, Dialog)
ShengSiBangDlg.__index = ShengSiBangDlg

local _instance
function ShengSiBangDlg.getInstance()
	if not _instance then
		_instance = ShengSiBangDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShengSiBangDlg.getInstanceAndShow()
	if not _instance then
		_instance = ShengSiBangDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShengSiBangDlg.getInstanceNotCreate()
	return _instance
end

function ShengSiBangDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShengSiBangDlg.ToggleOpenClose()
	if not _instance then
		_instance = ShengSiBangDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShengSiBangDlg.GetLayoutFileName()
	return "shengsizhanbenripaihang_mtg.layout"
end

function ShengSiBangDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShengSiBangDlg)
	return self
end

function ShengSiBangDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.todayBtn = CEGUI.toGroupButton(winMgr:getWindow("shengsizhanbenripaihang_mtg/btn1"))
    self.weekBtn = CEGUI.toGroupButton(winMgr:getWindow("shengsizhanbenripaihang_mtg/btn2"))
    self.historyBtn = CEGUI.toGroupButton(winMgr:getWindow("shengsizhanbenripaihang_mtg/btn3"))
    self.mybattleBtn = CEGUI.toGroupButton(winMgr:getWindow("shengsizhanbenripaihang_mtg/btn4"))
    self.todayBtn:setID(1)
    self.weekBtn:setID(2)
    self.historyBtn:setID(3)
    self.mybattleBtn:setID(4)
    self.todayBtn:setSelected(true)
    
    
	self.todayBtn:subscribeEvent("MouseButtonDown", ShengSiBangDlg.HandleSelectType, self)
	self.weekBtn:subscribeEvent("MouseButtonDown", ShengSiBangDlg.HandleSelectType, self)
	self.historyBtn:subscribeEvent("MouseButtonDown", ShengSiBangDlg.HandleSelectType, self)
	self.mybattleBtn:subscribeEvent("MouseButtonDown", ShengSiBangDlg.HandleSelectType, self)
    
    self.viewlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("shengsizhanbenripaihang_mtg/diban/list"));
    self.viewlistWnd:EnableHorzScrollBar(false)
    self.m_iconList = {}
    self:selectType(1)
end

function ShengSiBangDlg:HandleSelectType(args)
    local e = CEGUI.toWindowEventArgs(args)
	local typeid = e.window:getID()
    self:selectType(typeid)
end

function ShengSiBangDlg:handleCANCELClicked(args)  
    self.DestroyDialog()
end

function ShengSiBangDlg:releaseIcon()
    local sz = #self.m_iconList
    for index  = 1, sz do
        local lyout = self.m_iconList[1]
        lyout.data = nil
        lyout.zanText = nil
        lyout.fenxiangbtn = nil
        self.viewlistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_iconList,1)
	end
end

function ShengSiBangDlg:selectType (id)
    local req = require"protodef.fire.pb.battle.livedie.clivediebattlerankview".Create()
    req.modeltype = id
    LuaProtocolManager.getInstance():send(req)
end
function ShengSiBangDlg:setData(tp,datalist)
    self:releaseIcon()
    if tp == 1 or tp == 2 or tp ==3 then
        self:setDataA(tp,datalist)
    elseif tp == 4 then
        self:setDataB(tp,datalist)
    end
end
function ShengSiBangDlg:setDataA(tp,datalist)
    self.tp = tp
    
    local sx = 10;
    local sy = 10.0;
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sz = #datalist
    local myid = gGetDataManager():GetMainCharacterID()
    for index = 1, sz do
        local sID = tostring(index)
        
        local lyoutname
        if datalist[index].role1.roleid == myid or datalist[index].role2.roleid == myid then
            lyoutname = "shengsizhanbenripaihangcell2_mtg"
        else
            lyoutname = "shengsizhanbenripaihangcell_mtg"
        end
        local lyout = winMgr:loadWindowLayout(lyoutname .. ".layout",sID)

        self.viewlistWnd:addChildWindow(lyout)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx ), CEGUI.UDim(0.0, sy + (index-1) * (lyout:getHeight().offset+8))))
        
        lyout.data = datalist[index]

        winMgr:getWindow(sID..lyoutname.."/mingzi"):setText(lyout.data.role1.rolename)
        winMgr:getWindow(sID..lyoutname.."/mingzi1"):setText(lyout.data.role2.rolename)        
        winMgr:getWindow(sID..lyoutname.."/pingmingwenzi"):setText(tostring(index))

        local headA = CEGUI.Window.toItemCell(winMgr:getWindow(sID..lyoutname.."/ren1")) 
        local headB = CEGUI.Window.toItemCell(winMgr:getWindow(sID..lyoutname.."/ren11")) 
        headA:setID(index)
        headB:setID(index)
        headA:SetTextUnitText(CEGUI.String(tostring(lyout.data.role1.level)))
        headB:SetTextUnitText(CEGUI.String(tostring(lyout.data.role2.level)))
        
        local shapeDataA = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(lyout.data.role1.shape)
	    local imageA = gGetIconManager():GetImageByID(shapeDataA.littleheadID)
	    headA:SetImage(imageA)
        
        local shapeDataB = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(lyout.data.role2.shape)
	    local imageB = gGetIconManager():GetImageByID(shapeDataB.littleheadID)
	    headB:SetImage(imageB)
        
        local schoolA = winMgr:getWindow(sID..lyoutname.."/zhiye")
        local schoolArecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(lyout.data.role1.school)
        schoolA:setProperty("Image", schoolArecord.schooliconpath)
        local schoolB = winMgr:getWindow(sID..lyoutname.."/zhiye1")
        local schoolBrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(lyout.data.role2.school)
        schoolB:setProperty("Image", schoolBrecord.schooliconpath)
        
        local win = winMgr:getWindow(sID..lyoutname.."/sheng")
        local lost = winMgr:getWindow(sID..lyoutname.."/fu")
        if lyout.data.battleresult > 0 then
            win:setVisible(true)
            lost:setVisible(false)
        else
            win:setVisible(false)
            lost:setVisible(true)
        end

        lyout.zanText = winMgr:getWindow(sID..lyoutname.."/dianzancishu")
        lyout.zanText:setText(tostring(lyout.data.rosenum))

        local watchbtn = winMgr:getWindow(sID..lyoutname.."/btnluxiang")
        watchbtn:setID(index)
	    watchbtn:subscribeEvent("MouseButtonUp", ShengSiBangDlg.handleWatchClicked, self)
        
        local dianzanbtn = winMgr:getWindow(sID..lyoutname.."/btnzan")
        dianzanbtn:setID(index)
	    dianzanbtn:subscribeEvent("MouseButtonUp", ShengSiBangDlg.handleZanClicked, self)
                
        if lyout.data.role1.teamnum == 0 then
            local tText1 = winMgr:getWindow(sID..lyoutname.."/zudui")
            local tText2 = winMgr:getWindow(sID..lyoutname.."/zudui1")
            local tText3 = winMgr:getWindow(sID..lyoutname.."/danren")
            local tText4 = winMgr:getWindow(sID..lyoutname.."/danren1")
            tText1:setVisible(false)
            tText2:setVisible(false)
            local tTextNum1 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu1")
            local tTextNum2 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu")
            tTextNum1:setVisible(false)
            tTextNum2:setVisible(false)
            tText3:setVisible(true)
            tText4:setVisible(true)
        else
            local tTextNum1 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu1")
            local tTextNum2 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu")
            tTextNum1:setText(tostring(lyout.data.role1.teamnum) .. "/" .. tostring(lyout.data.role1.teamnummax))
            tTextNum2:setText(tostring(lyout.data.role2.teamnum) .. "/" .. tostring(lyout.data.role2.teamnummax))
            tTextNum1:setVisible(true)
            tTextNum2:setVisible(true)
            local tText3 = winMgr:getWindow(sID..lyoutname.."/danren")
            local tText4 = winMgr:getWindow(sID..lyoutname.."/danren1")
            tText3:setVisible(false)
            tText4:setVisible(false)
        end
        if lyout.data.role1.teamnum > 0 then
	        headA:subscribeEvent("MouseButtonDown", ShengSiBangDlg.handleHeadLClicked, self)
        end
        if lyout.data.role2.teamnum > 0 then
	        headB:subscribeEvent("MouseButtonDown", ShengSiBangDlg.handleHeadRClicked, self)
        end
        table.insert(self.m_iconList, lyout)
	end

end

function ShengSiBangDlg:setDataB(tp,datalist)

    local sx = 8.0;
    local sy = 10.0;
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sz = #datalist
    for index = 1, sz do
        local sID = tostring(index)

        local lyoutname
        lyoutname = "shengsizhanbenripaihangcell3_mtg"

        local lyout = winMgr:loadWindowLayout(lyoutname .. ".layout",sID)
        self.viewlistWnd:addChildWindow(lyout)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx ), CEGUI.UDim(0.0, sy + (index-1) * (lyout:getHeight().offset+8))))
        
        lyout.data = datalist[index]

        winMgr:getWindow(sID..lyoutname.."/mingzi"):setText(lyout.data.role1.rolename)
        winMgr:getWindow(sID..lyoutname.."/mingzi1"):setText(lyout.data.role2.rolename)

        winMgr:getWindow(sID..lyoutname.."/pingmingwenzi"):setText(tostring(index))

        local headA = CEGUI.Window.toItemCell(winMgr:getWindow(sID..lyoutname.."/ren1")) 
        local headB = CEGUI.Window.toItemCell(winMgr:getWindow(sID..lyoutname.."/ren11")) 
        headA:setID(index)
        headB:setID(index)
        headA:SetTextUnitText(CEGUI.String(tostring(lyout.data.role1.level)))
        headB:SetTextUnitText(CEGUI.String(tostring(lyout.data.role2.level)))
        
        local shapeDataA = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(lyout.data.role1.shape)
	    local imageA = gGetIconManager():GetImageByID(shapeDataA.littleheadID)
	    headA:SetImage(imageA)
        
        local shapeDataB = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(lyout.data.role2.shape)
	    local imageB = gGetIconManager():GetImageByID(shapeDataB.littleheadID)
	    headB:SetImage(imageB)

        local schoolA = winMgr:getWindow(sID..lyoutname.."/zhiye")
        local schoolArecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(lyout.data.role1.school)
        schoolA:setProperty("Image", schoolArecord.schooliconpath)
        local schoolB = winMgr:getWindow(sID..lyoutname.."/zhiye1")
        local schoolBrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(lyout.data.role2.school)
        schoolB:setProperty("Image", schoolBrecord.schooliconpath)

        local win = winMgr:getWindow(sID..lyoutname.."/sheng")
        local lost = winMgr:getWindow(sID..lyoutname.."/fu")
        if lyout.data.battleresult > 0 then
            win:setVisible(true)
            lost:setVisible(false)
        else
            win:setVisible(false)
            lost:setVisible(true)
        end

        lyout.zanText = winMgr:getWindow(sID..lyoutname.."/dianzancishu")
        lyout.zanText:setText(tostring(lyout.data.rosenum))

        local watchbtn = winMgr:getWindow(sID..lyoutname.."/btnluxiang")
        watchbtn:setID(index)
	    watchbtn:subscribeEvent("MouseButtonUp", ShengSiBangDlg.handleWatchClicked, self)
        
        local dianzanbtn = winMgr:getWindow(sID..lyoutname.."/btnzan")
        dianzanbtn:setID(index)
	    dianzanbtn:subscribeEvent("MouseButtonUp", ShengSiBangDlg.handleZanClicked, self)
        
        lyout.fenxiangbtn = winMgr:getWindow(sID..lyoutname.."/btnfen")
        lyout.fenxiangbtn:setID(index)
	    lyout.fenxiangbtn:subscribeEvent("MouseButtonUp", ShengSiBangDlg.handleFenXiangClicked, self)
        
        if lyout.data.role1.teamnum == 0 then
            local tText1 = winMgr:getWindow(sID..lyoutname.."/zudui")
            local tText2 = winMgr:getWindow(sID..lyoutname.."/zudui1")
            local tText3 = winMgr:getWindow(sID..lyoutname.."/danren")
            local tText4 = winMgr:getWindow(sID..lyoutname.."/danren1")
            tText1:setVisible(false)
            tText2:setVisible(false)
            tText3:setVisible(true)
            tText4:setVisible(true)
            local tTextNum1 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu1")
            local tTextNum2 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu")
            tTextNum1:setVisible(false)
            tTextNum2:setVisible(false)
        else
            local tTextNum1 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu1")
            local tTextNum2 = winMgr:getWindow(sID..lyoutname.."/duiwurenshu")
            tTextNum1:setText(tostring(lyout.data.role1.teamnum) .. "/" .. tostring(lyout.data.role1.teamnummax))
            tTextNum2:setText(tostring(lyout.data.role2.teamnum) .. "/" .. tostring(lyout.data.role2.teamnummax))
            tTextNum1:setVisible(true)
            tTextNum2:setVisible(true)
            local tText3 = winMgr:getWindow(sID..lyoutname.."/danren")
            local tText4 = winMgr:getWindow(sID..lyoutname.."/danren1")
            tText3:setVisible(false)
            tText4:setVisible(false)
        end
        if lyout.data.role1.teamnum > 0 then
	        headA:subscribeEvent("MouseButtonDown", ShengSiBangDlg.handleHeadLClicked, self)
        end
        if lyout.data.role2.teamnum > 0 then
	        headB:subscribeEvent("MouseButtonDown", ShengSiBangDlg.handleHeadRClicked, self)
        end
        table.insert(self.m_iconList, lyout)
	end
end
function ShengSiBangDlg:setSingleData(vedioid,rosenum,roseflag)
    local sz = #self.m_iconList
    for index  = 1, sz do
        local lyout = self.m_iconList[index]
        if lyout.data and lyout.data.videoid == vedioid then
            lyout.data.rosenum = rosenum
            lyout.data.roseflag = roseflag
            lyout.zanText:setText(tostring(lyout.data.rosenum))
            return
        end
	end
end
function ShengSiBangDlg:handleWatchClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local dt = self.m_iconList[index].data
    local req = require"protodef.fire.pb.battle.livedie.clivediebattlewatchvideo".Create()
    req.vedioid = dt.videoid
    LuaProtocolManager.getInstance():send(req)
    self:DestroyDialog()
end

function ShengSiBangDlg:handleZanClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local dt = self.m_iconList[index].data

    if dt.roseflag ~= 0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(162100))
    else
        local req = require"protodef.fire.pb.battle.livedie.clivediebattlegiverose".Create()
        req.vedioid = dt.videoid
        LuaProtocolManager.getInstance():send(req)
    end
    --self:DestroyDialog()
end

function ShengSiBangDlg:handleHeadLClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local dt = self.m_iconList[index].data
    ShengSiZhanTeamPanel.SetTeamList(dt.teamlist1)
end

function ShengSiBangDlg:handleHeadRClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local dt = self.m_iconList[index].data
    ShengSiZhanTeamPanel.SetTeamList(dt.teamlist2)
end

function ShengSiBangDlg:handleFenXiangClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local index = e.window:getID()
    local dt = self.m_iconList[index].data
        
    if FenxiangListDlg.getInstanceNotCreate() then
		FenxiangListDlg.DestroyDialog()
		return
	end
    
	local dlg = FenxiangListDlg.getInstance(self.m_iconList[index].fenxiangbtn,self.HandleCellClicked)
    dlg:setDIndex(index)
	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,-65), CEGUI.UDim(0, 60)))
	local pos = dlg:GetWindow():getPosition() 
	
	-- CEGUI coordinate taimafan
	pos.x.offset = pos.x.offset - 30;
	
	dlg:GetWindow():setPosition(pos) 
	
	local cpos = dlg.container:getPosition() 
	cpos.x.offset = cpos.x.offset - 2;
	dlg.container:setPosition(cpos) 
    
end

function ShengSiBangDlg:HandleCellClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()	
    local dlg = ShengSiBangDlg.getInstanceNotCreate()
    if dlg then
        local dt = dlg.m_iconList[self.dindex].data

        local strbuilder = StringBuilder:new()
        local msgqing = require "utils.mhsdutils".get_resstring(11461)
        strbuilder:Set("parameter1", tostring(dt.role1.rolename))
        strbuilder:Set("parameter2", tostring(dt.role2.rolename))
        strbuilder:Set("parameter3", tostring(dt.videoid))
                
		local chatCmd = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
		chatCmd.messagetype = id
		chatCmd.message = strbuilder:GetString(msgqing)--"<T t=\"asdfasdfsdf\" c=\"FF693F00\"></T><P t=\"[watch]\" type=\"14\" key=\"".. tostring(dt.videoid) .."\" TextColor=\"FF693F00\"></P>"
		strbuilder:delete()
        chatCmd.checkshiedmessage = ""
		chatCmd.displayinfos = {}
        if id == 4 then chatCmd.funtype = 2 
        elseif id == 5 then chatCmd.funtype = 3 
        end
		LuaProtocolManager.getInstance():send(chatCmd)
    end

	self.DestroyDialog()
end

local p = require "protodef.fire.pb.battle.livedie.slivediebattlerankview"
function p:process()
    local dlg = ShengSiBangDlg.getInstanceAndShow()
    if dlg then
        dlg:setData(self.modeltype,self.rolefightlist)
    end
end

local p = require "protodef.fire.pb.battle.livedie.slivediebattlegiverose"
function p:process()
    local dlg = ShengSiBangDlg.getInstanceAndShow()
    if dlg then
        dlg:setSingleData(self.vedioid,self.rosenum,self.roseflag)
    end
end

return ShengSiBangDlg
