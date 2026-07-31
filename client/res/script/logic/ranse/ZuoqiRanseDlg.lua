require "logic.dialog"

ZuoqiRanseDlg = {}
setmetatable(ZuoqiRanseDlg, Dialog)
ZuoqiRanseDlg.__index = ZuoqiRanseDlg

local _instance
function ZuoqiRanseDlg.getInstance()
	if not _instance then
		_instance = ZuoqiRanseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZuoqiRanseDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZuoqiRanseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZuoqiRanseDlg.getInstanceNotCreate()
	return _instance
end

function ZuoqiRanseDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZuoqiRanseDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZuoqiRanseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZuoqiRanseDlg.GetLayoutFileName()
	return "zuoqiranse.layout"
end

function ZuoqiRanseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZuoqiRanseDlg)
	return self
end

function ZuoqiRanseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	SetPositionOfWindowWithLabel(self:GetWindow())
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)

    self.leftDown = false;
    self.rightDown = false;
    self.downTime = 0;
    self.turnL = CEGUI.toPushButton(winMgr:getWindow("zuoqiranse/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("zuoqiranse/xuanniu2"));
    
	self.turnL:subscribeEvent("MouseButtonDown", ZuoqiRanseDlg.handleLeftClicked, self)
	self.turnR:subscribeEvent("MouseButtonDown", ZuoqiRanseDlg.handleRightClicked, self)
	self.turnL:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handleLeftUp, self)
	self.turnR:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handleRightUp, self)
    self.turnL:subscribeEvent("MouseLeave", ZuoqiRanseDlg.handleLeftUp, self) 
    self.turnR:subscribeEvent("MouseLeave", ZuoqiRanseDlg.handleRightUp, self) 

    self.inYiChu = winMgr:getWindow("zuoqiranse/biaoti/yichu")
    self.inYiChu:setVisible(false)

    self.rsOkBtn = CEGUI.toPushButton(winMgr:getWindow("zuoqiranse/huanyuan1"));
	self.rsOkBtn:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handleRSOKClicked, self)
    self.rsOkBtn:EnableClickAni(false)
    self.rsOkBtn:setEnabled(false)
     
    self.rsCancelBtn = CEGUI.toPushButton(winMgr:getWindow("zuoqiranse/huanyuan"));
	self.rsCancelBtn:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handleRSCANCELClicked, self)
    self.rsCancelBtn:EnableClickAni(false)
    self.rsCancelBtn:setEnabled(false)
     
	local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("zuoqiranse/beijing/moxing")
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0,0, true)
    local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Horse)
    --self.sprite:SetSpriteComponent(eSprite_Weapon,weapon,Nuclear.NuclearColor(0xffffffff));
    --self.sprite:SetSpriteComponent(eSprite_Horse,weapon);
    self.partList = {};
	self.partList[1] = {}
	self.partList[2] = {}
    self.colorList = {};
	self.colorList[1] = {}
	self.colorList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getAllID()
	local num = table.getn(ids)
	for i =1, num do
        if ids[i] < 1000 then
		    local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(ids[i])
            table.insert(self.partList[1],record.id)
            table.insert(self.colorList[1],record.yanse)
        end
	end
    self.currentIDA = 1;
    --self.currentIDB = 1;

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zuoqiranse/ranliao1"))
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("zuoqiranse/ranliao2"))   
    self.ItemCellNeedItem1:subscribeEvent("MouseClick",ZuoqiRanseDlg.HandleItemCellItemClick,self) 
    self.ItemCellNeedItem2:subscribeEvent("MouseClick",ZuoqiRanseDlg.HandleItemCellItemClick,self) 
    self.ItemCellNeedItem1:setVisible(false)
    self.ItemCellNeedItem2:setVisible(false)

    self.szlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("zuoqiranse/zuoqis"));
    self.szlistWnd:EnableHorzScrollBar(false)

    self.neeItemCountText1 = winMgr:getWindow("zuoqiranse/ranliaoshu1")
    self.neeItemCountText2 = winMgr:getWindow("zuoqiranse/ranliaoshu2")
    self.neeItemCountText1:setText("")
    self.neeItemCountText2:setText("")
    self.neeItemNameText1 = winMgr:getWindow("zuoqiranse/ranliaoming1")
    self.neeItemNameText2 = winMgr:getWindow("zuoqiranse/ranliaoming2")
    self.neeItemNameText1:setText("")
    self.neeItemNameText2:setText("")

    self.buttonA = {}
    self.buttonB = {}
    for i = 1, 8 do
        local btn = winMgr:getWindow("zuoqiranse/yansebeijing/partA" .. tostring(i))
        local btnbj = winMgr:getWindow("zuoqiranse/yansebeijing/partA" .. tostring(i) .. "/duigou")
        local btndi = winMgr:getWindow("zuoqiranse/yansebeijing/partA" .. tostring(i) .. "di")
        if self.partList[1][i] ~= nil then
            btn:setID(i)
	        btn:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handlePartAClicked, self)
            btn:setVisible(true)        
            btn:setProperty("ImageColours", self.colorList[1][i])
            btndi:setVisible(true)    
        else
            btn:setVisible(false)
            btndi:setVisible(false)    
        end
        
        --local btn2 = winMgr:getWindow("zuoqiranse/yansebeijing/partB" .. tostring(i))
        --local btn2bj = winMgr:getWindow("zuoqiranse/yansebeijing/partB" .. tostring(i) .. "/duigou")
        --local btn2di = winMgr:getWindow("zuoqiranse/yansebeijing/partB" .. tostring(i) .. "di")
        --if self.partList[2][i] ~= nil then
        --    btn2:setID(i)
	    --    btn2:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handlePartBClicked, self)
        --    btn2:setVisible(true)
        --    btn2:setProperty("ImageColours", self.colorList[2][i])
        --    btn2di:setVisible(true)
        --else
        --    btn2:setVisible(false)
        --    btn2di:setVisible(false)
        --end
        if btnbj then
            btnbj:setVisible(false)
            table.insert(self.buttonA,btnbj)
        end
        --if btn2bj then
        --    btn2bj:setVisible(false)
        --    table.insert(self.buttonB,btn2bj)
        --end
    end
    local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getAllID()
    for _, v in pairs(zuoqis) do
        local record = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(v)
        if record.ridemodel==weapon then
            local zuoqix =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getAllID()
            for _, x in pairs(zuoqix) do
                local records = BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(x)
                if records.rideid==v then
                    self.selectitem=x
                end
            end
        end
    end


    self.m_szList = {}
    self.zuoqis = {}
    self.m_pMainFrame:subscribeEvent("Activated", ZuoqiRanseDlg.HandleActivate, self)
    local cmd = require "logic.zuoqi.czuoqiyongyou".Create()
    LuaProtocolManager.getInstance():send(cmd)
    --local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    --local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    local aA =GetMainCharacter():GetSpriteComponent(102)
    if aA==0 then
        aA=1
    end
    self:Init(aA);
    self:refreshSelect()
end
function ZuoqiRanseDlg:refreshSzTable2(szList)
    local sz = #self.m_szList
    for index  = 1, sz do
        local lyout = self.m_szList[1]
        lyout.addclick = nil
        lyout.LevelText = nil
        self.szlistWnd:removeChildWindow(lyout)
        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_szList,1)
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    local index = 0
    local index2 = 0
    self.m_szList = {}
    for k,v in pairs(szList) do
        self.zuoqis[k]=v
        local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(k)
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(k)
        --local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
        local sID = "CharacterZuoQiDlg2" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("juesezuoqicell2.layout",index);
        self.szlistWnd:addChildWindow(lyout)
        if index2>=3 then
            index2=0
        end
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + index2 * (lyout:getWidth().offset-5)), CEGUI.UDim(0.0, sy + math.floor(index/3) * (lyout:getHeight().offset-5))))
        index2=index2+1

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(index.."juesezuoqicell2"));
        lyout.addclick:setID(k)
        lyout.addclick:subscribeEvent("MouseButtonUp", ZuoqiRanseDlg.handleSzSelected, self)
        lyout.szCell = CEGUI.toItemCell(winMgr:getWindow(index.."juesezuoqicell2/touxiang"))
        --local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shizhuang.moxing)
        local image = gGetIconManager():GetImageByID(itemattr.icon)
        lyout.szCell:SetLockState(false)
        lyout.szCell:SetImage(image)
        lyout.szCell:ClearCornerImage(0)
        lyout.szCell:ClearCornerImage(1)

        table.insert(self.m_szList, lyout)
        index = index + 1
    end
    --local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Horse)
    --self.sprite:SetSpriteComponent(eSprite_Weapon,weapon,Nuclear.NuclearColor(0xffffffff));
    --self.sprite:SetSpriteComponent(102,self.zuoqis[weapon]);
end
function ZuoqiRanseDlg:handleSzSelected(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()

    local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(idx)
    local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
    local shapeid = gGetDataManager():GetMainCharacterShape();
    --self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, shapeid, self.dir, 0, 0, true)

    self.selectitem=idx
    self:SetPartIndex(1,self.zuoqis[self.selectitem])
    self:refreshSelect()

end
function ZuoqiRanseDlg:refreshSelect()
    for i=1,#self.buttonA do
        local btn = self.buttonA[i]
        if self.currentIDA == i then
            btn:setVisible(true)
        else            
            btn:setVisible(false)
        end
    end
    --for i=1,#self.buttonB do
    --    local btn = self.buttonB[i]
    --    if self.currentIDB == i then
    --        btn:setVisible(true)
    --    else
    --        btn:setVisible(false)
    --    end
    --end
end
function ZuoqiRanseDlg:update(delta)
    if self.leftDown == true then
        self.downTime = self.downTime + delta;
        if self.downTime > 200 then
            self.dir =  self.dir + 1;
            if self.dir > 7 then
                self.dir = 0;
            end
            self.sprite:SetUIDirection(self.dir)
            self.downTime = 0
        end
    end
    if self.rightDown == true then
        self.downTime = self.downTime + delta;
        if self.downTime > 200 then
            self.dir =  self.dir - 1;
            if self.dir < 0 then
                self.dir = 7;
            end
            self.sprite:SetUIDirection(self.dir)
            self.downTime = 0
        end
    end
end
function ZuoqiRanseDlg:handleLeftClicked(args)
    self.dir =  self.dir + 1;
    if self.dir > 7 then
        self.dir = 0;
    end
    self.sprite:SetUIDirection(self.dir)
    self.leftDown = true;
    self.downTime = 0;
end

function ZuoqiRanseDlg:handleRightClicked(args)
    self.dir =  self.dir - 1;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
    self.rightDown = true;
    self.downTime = 0;
end
function ZuoqiRanseDlg:handleLeftUp(args)
    self.leftDown = false;
end
function ZuoqiRanseDlg:handleRightUp(args)
    self.rightDown = false;
end

function ZuoqiRanseDlg:handlePartAClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nColorID = e.window:getID()
    self.currentIDA = nColorID
    self:SetPartIndex(1,self.currentIDA)
    self:refreshSelect()
end
--function ZuoqiRanseDlg:handlePartBClicked(args)
--	local e = CEGUI.toWindowEventArgs(args)
--	local nColorID = e.window:getID()
--    self.currentIDB = nColorID
--    self:SetPartIndex(2,self.currentIDB)
--    self:refreshSelect()
--end


function ZuoqiRanseDlg:GetPartIndex(part,id)    
    for i = 1, #self.partList[part] do
        if  id == self.partList[part][i] then
            return i
        end
    end
    return 0
end
function ZuoqiRanseDlg:SetPartIndex(part,id)
    if part == 1 then 
        self.currentIDA = id
        self:SetDyeInfo(1,self.partList[1][self.currentIDA])
    --elseif part == 2 then
    --    self.currentIDB = id
    --    self:SetDyeInfo(2,self.partList[2][self.currentIDB])
    end
    
    if self.currentIDA ~= self.savePartA  then
        self.rsOkBtn:setEnabled(true)
        self.rsCancelBtn:setEnabled(true)
    else        
        self.rsOkBtn:setEnabled(false)
        self.rsCancelBtn:setEnabled(false)
    end
end

function ZuoqiRanseDlg:SetDyeInfo(part,dyeindex)
    local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(dyeindex)
    local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(self.selectitem)
    local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
    self.sprite:SetSpriteComponent(eSprite_Horse,zuoqis.ridemodel,Nuclear.NuclearColor(tonumber("0x"..record.yanse)));

    self:refreshItemShow()
end
function ZuoqiRanseDlg:isInYiChu(cA)
    for i=1,#g_yclist do
        if g_yclist[i].colorA == cA  then
            return true
        end
    end
    return false
end
function ZuoqiRanseDlg:refreshItemShow()
    local itemlist = {}
    --local isYc = self:isInYiChu(self.partList[1][self.currentIDA])
    --if isYc == true then
    --    local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
    --    self:updateUseItem(2,t,itemlist)
    --else
        self:updateUseItem(1,1.0,itemlist)
    --end
   -- self.inYiChu:setVisible(isYc)
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
            --local hasCount = gGetRoleItemManager():GetItemNumByBaseID(key)
            local hasCount = roleItemManager:GetItemNumByBaseID(key)

            local tStr = tostring(hasCount) .. "/" .. tostring(value)
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
function ZuoqiRanseDlg:HandleActivate(args)
    self:refreshItemShow()
end
--tp 1��ͨ  2�³�
function ZuoqiRanseDlg:updateUseItem(tp,rate,itemlist)
    
    local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(self.partList[1][self.currentIDA])
    if record then
        if self.currentIDA ~= self.savePartA then
            if not itemlist[record.itemcode]  then
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
    --record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[2][self.currentIDB])
    --if record then
    --    if self.currentIDB ~= self.savePartB then
    --        if not itemlist[record.itemcode]  then
    --            itemlist[record.itemcode] = {}
    --            itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
    --        else
    --            itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
    --        end
    --    end
    --end
end

function ZuoqiRanseDlg:handleRSOKClicked(args)    

    local itemlist = {}
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    --local isYc = self:isInYiChu(self.partList[1][self.currentIDA])
    --if isYc == true then
    --    local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
    --    self:updateUseItem(2,t,itemlist)
    --else
        self:updateUseItem(1,1.0,itemlist)
    --end

    local maxkey = table.maxn(itemlist)
    local hasCount = roleItemManager:GetItemNumByBaseID(maxkey)
    if hasCount < itemlist[maxkey] then
          ShopManager:tryQuickBuy(maxkey,itemlist[maxkey]-hasCount)
          return
    end

    for key,value in pairs(itemlist) do        
         local hasCount = roleItemManager:GetItemNumByBaseID(key)
         if hasCount < value then
             GetCTipsManager():AddMessageTipById(190014)
             ShopManager:tryQuickBuy(key,value-hasCount)
             return
         end
    end

	local p = require "protodef.fire.pb.ranse.cwuqiranse":new()
    p.rolecolorinfo = self.partList[1][self.currentIDA]
    p.itemid = self.selectitem
    --p.rolecolorinfo.colorpos2 = self.partList[2][self.currentIDB];
    require "manager.luaprotocolmanager".getInstance():send(p)
end
function ZuoqiRanseDlg:handleRSCANCELClicked(args)  
    self:SetPartIndex(1,self.savePartA);
    --self:SetPartIndex(2,self.savePartB);
    self:refreshSelect()
end

function ZuoqiRanseDlg:Init(partA)
    self.savePartA = self:GetPartIndex(1,partA)
    --self.savePartB = self:GetPartIndex(2,partB)
    self:SetPartIndex(1,self.savePartA)
    --self:SetPartIndex(2,self.savePartB)
end

function ZuoqiRanseDlg:HandleItemCellItemClick(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local commontipdlg = require "logic.tips.commontipdlg"
	local dlg = commontipdlg.getInstanceAndShow()
	local nType = commontipdlg.eType.eComeFrom
	dlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end


return ZuoqiRanseDlg
