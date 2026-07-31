require "logic.dialog"

CharacterRanseDlg = {}
setmetatable(CharacterRanseDlg, Dialog)
CharacterRanseDlg.__index = CharacterRanseDlg

local _instance
function CharacterRanseDlg.getInstance()
	if not _instance then
		_instance = CharacterRanseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CharacterRanseDlg.getInstanceAndShow()
	if not _instance then
		_instance = CharacterRanseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CharacterRanseDlg.getInstanceNotCreate()
	return _instance
end

function CharacterRanseDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CharacterRanseDlg.ToggleOpenClose()
	if not _instance then
		_instance = CharacterRanseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CharacterRanseDlg.GetLayoutFileName()
	return "jueseranse.layout"
end

function CharacterRanseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CharacterRanseDlg)
	return self
end

function CharacterRanseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)

    self.leftDown = false;
    self.rightDown = false;
    self.downTime = 0;
    self.turnL = CEGUI.toPushButton(winMgr:getWindow("jueseranse/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("jueseranse/xuanniu2"));
    
	self.turnL:subscribeEvent("MouseButtonDown", CharacterRanseDlg.handleLeftClicked, self)
	self.turnR:subscribeEvent("MouseButtonDown", CharacterRanseDlg.handleRightClicked, self)
	self.turnL:subscribeEvent("MouseButtonUp", CharacterRanseDlg.handleLeftUp, self)
	self.turnR:subscribeEvent("MouseButtonUp", CharacterRanseDlg.handleRightUp, self)
    self.turnL:subscribeEvent("MouseLeave", CharacterRanseDlg.handleLeftUp, self) 
    self.turnR:subscribeEvent("MouseLeave", CharacterRanseDlg.handleRightUp, self) 

    self.inYiChu = winMgr:getWindow("jueseranse/biaoti/yichu")
    self.inYiChu:setVisible(false)
	
	
	
	self.smokeBg = winMgr:getWindow("jueseranse/Back/flagbg/smoke")-----¶¯»­
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi6", true, s.width*0.5, s.height)


    self.rsOkBtn = CEGUI.toPushButton(winMgr:getWindow("jueseranse/huanyuan1"));
	self.rsOkBtn:subscribeEvent("MouseButtonUp", CharacterRanseDlg.handleRSOKClicked, self)
    self.rsOkBtn:EnableClickAni(false)
    self.rsOkBtn:setEnabled(false)
     
    self.rsCancelBtn = CEGUI.toPushButton(winMgr:getWindow("jueseranse/huanyuan"));
	self.rsCancelBtn:subscribeEvent("MouseButtonUp", CharacterRanseDlg.handleRSCANCELClicked, self)
    self.rsCancelBtn:EnableClickAni(false)
    self.rsCancelBtn:setEnabled(false)
     
	local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("jueseranse/beijing/moxing")
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0,0, true)	
        
    self.partList = {};
	self.partList[1] = {}
	self.partList[2] = {}
    self.colorList = {};
	self.colorList[1] = {}
	self.colorList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
	local num = table.getn(ids)
	for i =1, num do
        if ids[i] < 1000 then
		    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
            table.insert(self.partList[record.rolepos],record.id)
                        
            local clr = record.colorlist[data.shape-1010101]
            table.insert(self.colorList[record.rolepos],clr)
        end
	end
    self.currentIDA = 1;
    self.currentIDB = 1;

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("jueseranse/ranliao1"))
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("jueseranse/ranliao2"))   
    self.ItemCellNeedItem1:subscribeEvent("MouseClick",CharacterRanseDlg.HandleItemCellItemClick,self) 
    self.ItemCellNeedItem2:subscribeEvent("MouseClick",CharacterRanseDlg.HandleItemCellItemClick,self) 
    self.ItemCellNeedItem1:setVisible(false)
    self.ItemCellNeedItem2:setVisible(false)

    self.neeItemCountText1 = winMgr:getWindow("jueseranse/ranliaoshu1")
    self.neeItemCountText2 = winMgr:getWindow("jueseranse/ranliaoshu2")
    self.neeItemCountText1:setText("")
    self.neeItemCountText2:setText("")
    self.neeItemNameText1 = winMgr:getWindow("jueseranse/ranliaoming1")
    self.neeItemNameText2 = winMgr:getWindow("jueseranse/ranliaoming2")
    self.neeItemNameText1:setText("")
    self.neeItemNameText2:setText("")

    self.buttonA = {}
    self.buttonB = {}
    for i = 1, 8 do
        local btn = winMgr:getWindow("jueseranse/yansebeijing/partA" .. tostring(i) .. "di")
        local btnbj = winMgr:getWindow("jueseranse/yansebeijing/partA" .. tostring(i) .. "/duigou")
        local btndi = winMgr:getWindow("jueseranse/yansebeijing/partA" .. tostring(i))
        if self.partList[1][i] ~= nil then
            btn:setID(i)
	        btn:subscribeEvent("MouseButtonUp", CharacterRanseDlg.handlePartAClicked, self)
            btn:setVisible(true)        
            btndi:setProperty("ImageColours", self.colorList[1][i])
            btndi:setVisible(true)    
        else
            btn:setVisible(false)
            btndi:setVisible(false)    
        end
        
        local btn2 = winMgr:getWindow("jueseranse/yansebeijing/partB" .. tostring(i) .. "di")
        local btn2bj = winMgr:getWindow("jueseranse/yansebeijing/partB" .. tostring(i) .. "/duigou")
        local btn2di = winMgr:getWindow("jueseranse/yansebeijing/partB" .. tostring(i))
        if self.partList[2][i] ~= nil then
            btn2:setID(i)
	        btn2:subscribeEvent("MouseButtonUp", CharacterRanseDlg.handlePartBClicked, self)
            btn2:setVisible(true)
            btn2di:setProperty("ImageColours", self.colorList[2][i])
            btn2di:setVisible(true) 
        else
            btn2:setVisible(false)
            btn2di:setVisible(false)    
        end
        if btnbj then
            btnbj:setVisible(false)
            table.insert(self.buttonA,btnbj)
        end
        if btn2bj then
            btn2bj:setVisible(false)
            table.insert(self.buttonB,btn2bj)
        end
    end

    self.m_pMainFrame:subscribeEvent("Activated", CharacterRanseDlg.HandleActivate, self) 

    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self:Init(pA,pB);
    self:refreshSelect()
end


function CharacterRanseDlg:DestroyDialogc()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function CharacterRanseDlg:refreshSelect()
    for i=1,#self.buttonA do
        local btn = self.buttonA[i]
        if self.currentIDA == i then
            btn:setVisible(true)
        else            
            btn:setVisible(false)
        end
    end
    for i=1,#self.buttonB do
        local btn = self.buttonB[i]
        if self.currentIDB == i then
            btn:setVisible(true)
        else            
            btn:setVisible(false)
        end
    end
end
function CharacterRanseDlg:update(delta)
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
function CharacterRanseDlg:handleLeftClicked(args)
    self.dir =  self.dir + 1;
    if self.dir > 7 then
        self.dir = 0;
    end
    self.sprite:SetUIDirection(self.dir)
    self.leftDown = true;
    self.downTime = 0;
end

function CharacterRanseDlg:handleRightClicked(args)
    self.dir =  self.dir - 1;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
    self.rightDown = true;
    self.downTime = 0;
end
function CharacterRanseDlg:handleLeftUp(args)
    self.leftDown = false;
end
function CharacterRanseDlg:handleRightUp(args)
    self.rightDown = false;
end

function CharacterRanseDlg:handlePartAClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nColorID = e.window:getID()
    self.currentIDA = nColorID
    self:SetPartIndex(1,self.currentIDA)
    self:refreshSelect()
end
function CharacterRanseDlg:handlePartBClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nColorID = e.window:getID()
    self.currentIDB = nColorID
    self:SetPartIndex(2,self.currentIDB)
    self:refreshSelect()
end


function CharacterRanseDlg:GetPartIndex(part,id)    
    for i = 1, #self.partList[part] do
        if  id == self.partList[part][i] then
            return i
        end
    end
    return 0
end
function CharacterRanseDlg:SetPartIndex(part,id)
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

function CharacterRanseDlg:SetDyeInfo(part,dyeindex)
    self.sprite:SetDyePartIndex(part-1,dyeindex)
    self:refreshItemShow()
end
function CharacterRanseDlg:isInYiChu(cA,cB)
    for i=1,#g_yclist do
        if g_yclist[i].colorA == cA and g_yclist[i].colorB == cB then
            return true
        end
    end
    return false
end
function CharacterRanseDlg:refreshItemShow()
    local itemlist = {}
    local isYc = self:isInYiChu(self.partList[1][self.currentIDA],self.partList[2][self.currentIDB])
    if isYc == true then
        local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
        self:updateUseItem(2,t,itemlist)
    else
        self:updateUseItem(1,1.0,itemlist)
    end
    self.inYiChu:setVisible(isYc)
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
            local tColor = "[colour=".."\'".."ffffffff".."\'".."]"
            if hasCount < value then
                 tColor = "[colour=".."\'".."ffffffff".."\'".."]"
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
function CharacterRanseDlg:HandleActivate(args)
    self:refreshItemShow()
end
--tp 1ÆÕÍ¨  2ÒÂ³÷
function CharacterRanseDlg:updateUseItem(tp,rate,itemlist)
    
    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[1][self.currentIDA])
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
    record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[2][self.currentIDB])
    if record then
        if self.currentIDB ~= self.savePartB then
            if not itemlist[record.itemcode]  then 
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
end

function CharacterRanseDlg:handleRSOKClicked(args)    

    local itemlist = {}
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local isYc = self:isInYiChu(self.partList[1][self.currentIDA],self.partList[2][self.currentIDB])
    if isYc == true then
        local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
        self:updateUseItem(2,t,itemlist)
    else
        self:updateUseItem(1,1.0,itemlist)
    end

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

	local p = require "protodef.fire.pb.crequsecolor":new()
    p.rolecolorinfo.colorpos1 = self.partList[1][self.currentIDA];
    p.rolecolorinfo.colorpos2 = self.partList[2][self.currentIDB];
    require "manager.luaprotocolmanager".getInstance():send(p)
end
function CharacterRanseDlg:handleRSCANCELClicked(args)  
    self:SetPartIndex(1,self.savePartA);
    self:SetPartIndex(2,self.savePartB);
    self:refreshSelect()
end

function CharacterRanseDlg:Init(partA,partB)
    self.savePartA = self:GetPartIndex(1,partA)
    self.savePartB = self:GetPartIndex(2,partB)    
    self:SetPartIndex(1,self.savePartA)
    self:SetPartIndex(2,self.savePartB)
end

function CharacterRanseDlg:HandleItemCellItemClick(args)
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


return CharacterRanseDlg
