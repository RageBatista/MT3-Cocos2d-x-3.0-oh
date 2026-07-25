require "logic.dialog"

RanseDlg = {}
setmetatable(RanseDlg, Dialog)
RanseDlg.__index = RanseDlg

local _instance
function RanseDlg.getInstance()
	if not _instance then
		_instance = RanseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RanseDlg.getInstanceAndShow()
	if not _instance then
		_instance = RanseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RanseDlg.getInstanceNotCreate()
	return _instance
end

function RanseDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RanseDlg.ToggleOpenClose()
	if not _instance then
		_instance = RanseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RanseDlg.GetLayoutFileName()
	return "ranse1.layout"
end

function RanseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RanseDlg)
	return self
end

function RanseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.m_rsWnd = winMgr:getWindow("ranse1/caozuoqu/fenye1")
	self.m_ycWnd = winMgr:getWindow("ranse1/caozuoqu/fenye2")

    self.m_rsWnd:setVisible(true);
    self.m_ycWnd:setVisible(false);

    self.m_rsBtn = CEGUI.toCheckbox(winMgr:getWindow("ranse1/caozuoqu/1"))
    self.m_ycBtn = CEGUI.toCheckbox(winMgr:getWindow("ranse1/caozuoqu/2"))
    self.m_rsBtn:setSelected(true);
    self.m_ycBtn:setSelected(false);
	self.m_rsBtn:subscribeEvent("MouseButtonUp", RanseDlg.handleRSClicked, self)
	self.m_ycBtn:subscribeEvent("MouseButtonUp", RanseDlg.handleYCClicked, self)

    self.turnL = CEGUI.toPushButton(winMgr:getWindow("ranse1/zuozhuan"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("ranse1/youzhuan"));

	self.turnL:subscribeEvent("MouseButtonUp", RanseDlg.handleLeftClicked, self)
	self.turnR:subscribeEvent("MouseButtonUp", RanseDlg.handleRightClicked, self)
        
    self.partAL = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye1/di/zuo1"));
    self.partAR = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye1/di/you1"));    
	self.partAL:subscribeEvent("MouseButtonUp", RanseDlg.handleDecPartAClicked, self)
	self.partAR:subscribeEvent("MouseButtonUp", RanseDlg.handleAddPartAClicked, self)
    self.partAText = winMgr:getWindow("ranse1/caozuoqu/fenye1/di/wenben1")

    self.partBL = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye1/di/zuo2"));
    self.partBR = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye1/di/you2")); 
	self.partBL:subscribeEvent("MouseButtonUp", RanseDlg.handleDecPartBClicked, self)
	self.partBR:subscribeEvent("MouseButtonUp", RanseDlg.handleAddPartBClicked, self)
    self.partBText = winMgr:getWindow("ranse1/caozuoqu/fenye1/di/wenben11")

    self.rsOkBtn = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye1/ranse1"));
	self.rsOkBtn:subscribeEvent("MouseButtonUp", RanseDlg.handleRSOKClicked, self)
    self.rsOkBtn:setEnabled(false)
    
    self.rsCancelBtn = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye1/huanyuan"));
	self.rsCancelBtn:subscribeEvent("MouseButtonUp", RanseDlg.handleRSCANCELClicked, self)
    self.rsCancelBtn:setEnabled(false)
    
    self.ycOKBtn = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye2/shanchu1"));
	self.ycOKBtn:subscribeEvent("MouseButtonUp", RanseDlg.handleYCRSOKClicked, self)
 
    self.ycDelBtn = CEGUI.toPushButton(winMgr:getWindow("ranse1/caozuoqu/fenye2/shanchu"));
	self.ycDelBtn:subscribeEvent("MouseButtonUp", RanseDlg.handleDelYCClicked, self)
 
	local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("ranse1/moxing")
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0,0, true)	

    self.yclistWnd = CEGUI.toScrollablePane(winMgr:getWindow("ranse1/caozuoqu/fenye2/di/liebiao"));
    self.yclistWnd:EnableHorzScrollBar(true)
    self.m_saveSpriteList = {}
    self.m_ycList = {}
    self.m_ycSel = 0
    local sx = 12.0;
    local sy = 2.0;
    for index = 1, 3 do
        local sID = tostring(index)
        local lyout = winMgr:loadWindowLayout("ranse1cell.layout",sID);
        self.yclistWnd:addChildWindow(lyout)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + (index-1) * (lyout:getWidth().offset+8)), CEGUI.UDim(0.0, sy)))

        local addclick = winMgr:getWindow(sID.."ranse1cell/dianxuan");
        addclick:setID(index)
	    addclick:subscribeEvent("MouseButtonUp", RanseDlg.handleSelYCClicked, self)
        local body = gGetGameUIManager():AddWindowSprite(addpos, data.shape, Nuclear.XPDIR_BOTTOMRIGHT, 0,0, true)

        local addpos = winMgr:getWindow(sID.."ranse1cell/moxing");
        local body = gGetGameUIManager():AddWindowSprite(addpos, data.shape, Nuclear.XPDIR_BOTTOMRIGHT, 0,0, true)
        lyout:setVisible(false)
        
        lyout.cbtn = winMgr:getWindow(sID.."ranse1cell/moxing/xuanzhong");
        lyout.cbtn:setVisible(false)

        table.insert(self.m_ycList, lyout)
		table.insert(self.m_saveSpriteList, body)
	end
    
    self.partList = {};
	self.partList[1] = {}
	self.partList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
	local num = table.getn(ids)
	for i =1, num do
		local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
        table.insert(self.partList[record.rolepos],record.id)
	end
    self.currentIDA = 1;
    self.currentIDB = 1;

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("ranse1/caozuoqu/fenye1/wupin1"))
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("ranse1/caozuoqu/fenye1/wupin2"))   
    self.ItemCellNeedItem1:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID) 
    self.ItemCellNeedItem2:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID) 
    self.ItemCellNeedItem1:setVisible(false)
    self.ItemCellNeedItem2:setVisible(false)

    self.neeItemCountText1 = winMgr:getWindow("ranse1/caozuoqu/fenye1/shuliang1")
    self.neeItemCountText2 = winMgr:getWindow("ranse1/caozuoqu/fenye1/shuliang2")
    self.neeItemCountText1:setText("")
    self.neeItemCountText2:setText("")
    self.neeItemNameText1 = winMgr:getWindow("ranse1/caozuoqu/fenye1/name1")
    self.neeItemNameText2 = winMgr:getWindow("ranse1/caozuoqu/fenye1/name2")
    self.neeItemNameText1:setText("")
    self.neeItemNameText2:setText("")

    self.YCItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("ranse1/caozuoqu/fenye2/wupin1"))
	self.YCItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("ranse1/caozuoqu/fenye2/wupin2"))  
    self.YCItemCellNeedItem1:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID) 
    self.YCItemCellNeedItem2:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID)   
    self.YCItemCellNeedItem1:setVisible(false)
    self.YCItemCellNeedItem2:setVisible(false)

    self.YCneeItemCountText1 = winMgr:getWindow("ranse1/caozuoqu/fenye2/shuliang1")
    self.YCneeItemCountText2 = winMgr:getWindow("ranse1/caozuoqu/fenye2/shuliang2")
    self.YCneeItemCountText1:setText("")
    self.YCneeItemCountText2:setText("")
    self.YCneeItemNameText1 = winMgr:getWindow("ranse1/caozuoqu/fenye2/name1")
    self.YCneeItemNameText2 = winMgr:getWindow("ranse1/caozuoqu/fenye2/name2")
    self.YCneeItemNameText1:setText("")
    self.YCneeItemNameText2:setText("")

    self.hasYCData = false

    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self:Init(pA,pB);
end

function RanseDlg:OnClose()  
    for index  = 1, 3 do
        local lyout = self.m_ycList[1]
        self.yclistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_ycList,1)
        table.remove(self.m_saveSpriteList,1)
	end
	Dialog.OnClose(self)
end

function RanseDlg:handleLeftClicked(args)
    self.dir =  self.dir + 1;
    if self.dir > 7 then
        self.dir = 0;
    end
    self.sprite:SetUIDirection(self.dir)
end

function RanseDlg:handleRightClicked(args)
    self.dir =  self.dir - 1;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
end

function RanseDlg:handleRSClicked(args)
    self.m_rsWnd:setVisible(true);
    self.m_ycWnd:setVisible(false);
    self:SetPartIndex(1,self.savePartA)
    self:SetPartIndex(2,self.savePartB)
end
function RanseDlg:handleYCClicked(args)
    self.m_rsWnd:setVisible(false);
    self.m_ycWnd:setVisible(true);
    self:setSelectYC(self.m_ycSel)
    if self.hasYCData == false then
	    local p = require "protodef.fire.pb.creqcolorroomview":new()
        require "manager.luaprotocolmanager".getInstance():send(p)
    end
end

local p = require "protodef.fire.pb.sreqcolorroomview"
function p:process()
     local dlg = RanseDlg.getInstance()
     dlg:setYCList(self.rolecolortypelist,self.nummax)
     dlg.hasYCData = true
end

local p = require "protodef.fire.pb.srequsecolor"
function p:process()  
     local dlg = RanseDlg.getInstance()
     dlg:Init(self.rolecolorinfo.colorpos1,self.rolecolorinfo.colorpos2)
     dlg:refreshItemShow()
     dlg.m_ycSel = 0
     for index = 1, 3 do        
        if dlg.m_ycList[index].cbtn then
            dlg.m_ycList[index].cbtn:setVisible(false)
        else
            LogWar("protodef.fire.pb.srequsecolor dlg.m_ycList[index].cbtn:setVisible")
        end
     end
     dlg:refreshItemShow()
end


function RanseDlg:handleDecPartAClicked(args)
    self.currentIDA = self.currentIDA - 1;
    if self.currentIDA < 1 then
        self.currentIDA = #self.partList[1]
    end
    self:SetPartIndex(1,self.currentIDA)
end
function RanseDlg:handleAddPartAClicked(args)
    self.currentIDA = self.currentIDA + 1;
    if self.currentIDA > #self.partList[1] then
        self.currentIDA = 1
    end
    self:SetPartIndex(1,self.currentIDA)
end
function RanseDlg:handleDecPartBClicked(args)
    self.currentIDB = self.currentIDB - 1
    if self.currentIDB < 1 then
        self.currentIDB = #self.partList[2]
    end
    self:SetPartIndex(2,self.currentIDB)
end
function RanseDlg:handleAddPartBClicked(args)
    self.currentIDB = self.currentIDB + 1
    if self.currentIDB > #self.partList[2] then
        self.currentIDB = 1
    end
    self:SetPartIndex(2,self.currentIDB)
end

function RanseDlg:handleSelYCClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
    self:setSelectYC(nItemId)
end

function RanseDlg:setSelectYC(id)
    for index = 1, 3 do        
        self.m_ycList[index].cbtn:setVisible(false)
    end
    self.m_ycSel = id
    if id ~= 0 then
        self.m_ycList[id].cbtn:setVisible(true)    
        local selA = self:GetPartIndex(1,self.m_ycList[id].colorA)
        local selB = self:GetPartIndex(2,self.m_ycList[id].colorB)    
        self:SetPartIndex(1,selA)
        self:SetPartIndex(2,selB)
        self.ycOKBtn:setVisible(true)
        self.ycDelBtn:setVisible(true)
    else        
        self:SetPartIndex(1,self.savePartA)
        self:SetPartIndex(2,self.savePartB)
        self.ycOKBtn:setVisible(false)
        self.ycDelBtn:setVisible(false)
    end
    self:refreshItemShow()
end


function RanseDlg:GetPartIndex(part,id)    
    for i = 1, #self.partList[part] do
        if  id == self.partList[part][i] then
            return i
        end
    end
    return 0
end
function RanseDlg:SetPartIndex(part,id)
    if part == 1 then 
        self.currentIDA = id
        self:SetDyeInfo(1,self.partList[1][self.currentIDA])
    elseif part == 2 then 
        self.currentIDB = id
        self:SetDyeInfo(2,self.partList[2][self.currentIDB])
    end
    
    if self.currentIDA ~= self.savePartA or self.currentIDB ~= self.savePartB then
        self.rsOkBtn:setEnabled(true)
        self.rsCancelBtn:setEnabled(true)
    else        
        self.rsOkBtn:setEnabled(false)
        self.rsCancelBtn:setEnabled(false)
    end
end

function RanseDlg:SetDyeInfo(part,dyeindex)
    self.sprite:SetDyePartIndex(part-1,dyeindex)
    local text = MHSD_UTILS.get_resstring(11366)
    if dyeindex == 0 then    
        text = string.gsub(text, "%$parameter1%$", tostring(1))
        if part == 1 then
            self.partAText:setText(text)
        elseif part == 2 then
            self.partBText:setText(text)
        end
    else
        local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(dyeindex)
        if record then
            text = string.gsub(text, "%$parameter1%$", tostring(record.modeltype))
            if record.rolepos == 1 then
                self.partAText:setText(text)
            elseif record.rolepos == 2 then
                self.partBText:setText(text)
            end
        end
    end
    self:refreshItemShow()
end
function RanseDlg:refreshItemShow()
    local itemlist = {}
    self:updateUseItem(1,1.0,itemlist)
    self.ItemCellNeedItem1:setVisible(false)
    self.ItemCellNeedItem2:setVisible(false)
    self.neeItemCountText1:setText("")
    self.neeItemCountText2:setText("")
    self.neeItemNameText1:setText("")
    self.neeItemNameText2:setText("")

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local i = 1
    for key,value in pairs(itemlist) do        
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(key)
        if itemAttrCfg then
            local hasCount = roleItemManager:GetItemNumByBaseID(key)

            local tStr = tostring(value) .. "/" .. tostring(hasCount)
            local tColor = "[colour=".."\'".."ff00ff00".."\'".."]"
            if hasCount < value then
                tColor = "[colour=".."\'".."ffff0000".."\'".."]"
            end

            if i == 1 then
                self.ItemCellNeedItem1:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))            
                self.ItemCellNeedItem1:setID(key)
                self.ItemCellNeedItem1:setVisible(true)
                self.neeItemNameText1:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.neeItemCountText1:setText(tColor..tStr)
            elseif i == 2 then
                self.ItemCellNeedItem2:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))       
                self.ItemCellNeedItem2:setID(key)
                self.ItemCellNeedItem2:setVisible(true)
                self.neeItemNameText2:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.neeItemCountText2:setText(tColor .. tStr)
            end
        end
        i = i + 1
    end
end

function RanseDlg:refreshItemShow()
    local itemlist = {}
    local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
    self:updateUseItem(2,t,itemlist)
    self.YCItemCellNeedItem1:setVisible(false)
    self.YCItemCellNeedItem2:setVisible(false)
    self.YCneeItemCountText1:setText("")
    self.YCneeItemCountText2:setText("")
    self.YCneeItemNameText1:setText("")
    self.YCneeItemNameText2:setText("")

    if self.m_ycSel == 0 then
        return
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local i = 1
    for key,value in pairs(itemlist) do        
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(key)
        if itemAttrCfg then
            local hasCount = roleItemManager:GetItemNumByBaseID(key)

            local tStr = tostring(value) .. "/" .. tostring(hasCount)
            local tColor = "[colour=".."\'".."ff00ff00".."\'".."]"
            if hasCount < value then
            tColor = "[colour=".."\'".."ffff0000".."\'".."]"
            end

            if i == 1 then
                self.YCItemCellNeedItem1:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))
                self.YCItemCellNeedItem1:setID(key)
                self.YCItemCellNeedItem1:setVisible(true)
                self.YCneeItemNameText1:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.YCneeItemCountText1:setText(tColor..tStr)
            elseif i == 2 then
                self.YCItemCellNeedItem2:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))
                self.YCItemCellNeedItem2:setID(key)
                self.YCItemCellNeedItem2:setVisible(true)
                self.YCneeItemNameText2:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.YCneeItemCountText2:setText(tColor .. tStr)
            end
        end
        i = i + 1
    end
end
--tp 1ÆÕÍ¨  2ÒÂ³÷
function RanseDlg:updateUseItem(tp,rate,itemlist)
    
    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[1][self.currentIDA])
    if record then
        if tp ~= 1 or self.currentIDA ~= self.savePartA then
            if not itemlist[record.itemcode]  then 
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
    record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[2][self.currentIDB])
    if record then
        if tp ~= 1 or self.currentIDB ~= self.savePartB then
            if not itemlist[record.itemcode]  then 
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
end

function RanseDlg:handleRSOKClicked(args)    
	local p = require "protodef.fire.pb.crequsecolor":new()
    p.selecttype = 0
    p.rolecolorinfo.colorpos1 = self.partList[1][self.currentIDA];
    p.rolecolorinfo.colorpos2 = self.partList[2][self.currentIDB];
    require "manager.luaprotocolmanager".getInstance():send(p)
end
function RanseDlg:handleRSCANCELClicked(args)  
    self:SetPartIndex(1,self.savePartA);
    self:SetPartIndex(2,self.savePartB);
end
function RanseDlg:handleYCRSOKClicked(args)    
	local p = require "protodef.fire.pb.crequsecolor":new()
    p.selecttype = 1
    p.rolecolorinfo.colorpos1 = self.partList[1][self.currentIDA];
    p.rolecolorinfo.colorpos2 = self.partList[2][self.currentIDB];
    require "manager.luaprotocolmanager".getInstance():send(p)
end
function RanseDlg:handleDelYCClicked(args)   
    if self.m_ycSel ~= 0 then
	    local p = require "protodef.fire.pb.creqdelcolor":new()
        p.removeindex = self.m_ycSel-1
        require "manager.luaprotocolmanager".getInstance():send(p)  
        self:setSelectYC(0)
    end
end
function RanseDlg:setYCList(yclist,maxcount)  
    for i=1,3 do
        self.m_ycList[i]:setVisible(false)
    end
    local len = #yclist
    for i=1,len do
        self.m_saveSpriteList[i]:SetDyePartIndex(0,yclist[i].colorpos1)
        self.m_saveSpriteList[i]:SetDyePartIndex(1,yclist[i].colorpos2)
        self.m_ycList[i].colorA = yclist[i].colorpos1
        self.m_ycList[i].colorB = yclist[i].colorpos2
        self.m_ycList[i]:setVisible(true)
    end
end

function RanseDlg:Init(partA,partB)
    self.savePartA = self:GetPartIndex(1,partA)
    self.savePartB = self:GetPartIndex(2,partB)    
    self:SetPartIndex(1,self.savePartA)
    self:SetPartIndex(2,self.savePartB)
end

return RanseDlg
