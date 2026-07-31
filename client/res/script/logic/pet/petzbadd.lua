require "logic.dialog"
--------
---宠装界面
--------
PetAddZb = {
ItemType=154,
Items={},
EquipItems={},
lastSelectedBtn = nil,
itemid=0,
itemkey=0,
item = {},
}
setmetatable(PetAddZb, Dialog)
PetAddZb.__index = PetAddZb

local _instance
function PetAddZb.getInstance()
    if not _instance then
        _instance = PetAddZb:new()
        _instance:OnCreate()
    end
    return _instance
end

function PetAddZb.getInstanceAndShow(key)
    if not _instance then
        _instance = PetAddZb:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    _instance.petkey=key
    return _instance
end

function PetAddZb.CloseIfExist()
    if _instance then
        PetAddZb.DestroyDialog()
    end
end

function PetAddZb.getInstanceNotCreate()
    return _instance
end

function PetAddZb.DestroyDialog()
    if _instance then 
	_instance.chuandai.animation:stop()
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function PetAddZb.ToggleOpenClose()
    if not _instance then
        _instance = PetAddZb:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function PetAddZb.GetLayoutFileName()
    return "petzbadd.layout"
end

function PetAddZb:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetAddZb)
    return self
end

function PetAddZb:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        -- 保存动画实例
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetAddZb:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petzbadd_mtg/main/scroll"))
    self.chuandai = CEGUI.toPushButton(winMgr:getWindow("petzbadd_mtg/chuandai"))
    self:loadEquipList()
    self.chuandai:subscribeEvent("MouseClick", PetAddZb.handlewearEquipClicked, self)
	self:addButtonAnimation(self.chuandai, "studyBtnPress")
    self.m_tishi = winMgr:getWindow("petzbadd_mtg/tishic1")
    
    self.btnClose = CEGUI.toPushButton(winMgr:getWindow("petzbadd_mtg/guanbi"))
    self.btnClose:subscribeEvent("Clicked", PetAddZb.btnCloseCallBack, self)
	
	self.tishiwz = CEGUI.toRichEditbox(winMgr:getWindow("petzbadd_mtg/tishic1/cwtishi"))
	self.tishiwz:Clear()
    self.tishiwz:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7407)))
    self.tishiwz:Refresh() 

    -- 隐藏提示框
    self.m_tishi:setVisible(true)

    if #self.EquipItems > 0 then
        self.m_tishi:setVisible(false)
        self.chuandai:setEnabled(true)  -- 启用按钮
    else
        self.chuandai:setEnabled(false)  -- 禁用按钮
    end
end
function PetAddZb:loadEquipList()
    self.Items = {}
    self.EquipItems = {}
    self.lastSelectedBtn = nil
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    self.Items = roleItemManager:GetItemKeyListByType(self.Items, self.ItemType)

    local COLUMN_COUNT = 4  
    local col = 0
    local row = 0

    for i = 0, self.Items:size() - 1 do
        local idx = i + 1
        local cell = self:createCell(self.Items[i], idx)
        local height = cell.window:getHeight():asAbsolute(0)
        local width = cell.window:getWidth():asAbsolute(0) 

     
        local offsetX = (width + 5) * col 
        local offsetY = (height + 5) * row
        cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0, offsetX), CEGUI.UDim(0, offsetY)))


        col = col + 1
        if col >= COLUMN_COUNT then
            col = 0
            row = row + 1
        end

        self.EquipItems[idx] = cell
    end
end
function PetAddZb:handlewearEquipClicked()
    if self.itemid == 0 then
        return
    end
    LogInfo("id"..self.itemid)
    self:handlEquipClicked(self.itemKey)
end
function PetAddZb:createCell(itemkey,idx)
    local cell = {}
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefix = tostring(itemkey)
    cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petzbcell_mtg.layout", prefix))
    cell.item = CEGUI.toItemCell(winMgr:getWindow(prefix .. "petzbcell_mtg/item"))
    cell.name = winMgr:getWindow(prefix .. "petzbcell_mtg/name")
    self.scroll:addChildWindow(cell.window)
    
    cell.window:setID(idx)
    cell.window:EnableClickAni(false)
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
    if item ~= nil then
        cell.itemData = item
        cell.itemKey = itemkey
        cell.item:SetImage(gGetIconManager():GetItemIconByID(item:GetBaseObject().icon))
        cell.name:setText(item:GetBaseObject().level)
        local color = item:GetNameColour()
        cell.name:setProperty("TextColours", "fffff2df")
        cell.item:setID(item:GetObjectID())
        self.item = item:GetObject()
        SetItemCellBoundColorByQulityItemtm(cell.item,item:GetBaseObject().nquality)
        cell.window:subscribeEvent("SelectStateChanged", PetAddZb.handleEquipItemChoosed, self)
    end
    return cell
end
function PetAddZb:HandleShowToolTipsWithItemID(args)
    local e = CEGUI.toWindowEventArgs(args).window
    local nItemId = e:getID()
    LogInfo("petid1"..nItemId)
    local e2 = CEGUI.toMouseEventArgs(args)
    local touchPos = e2.position
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if not itemAttrCfg.id then
        return
    end
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    --local nType = Commontipdlg.eType.eComeFrom
    local nType = Commontipdlg.eType.epetequip 
    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY,self.item)
end
function PetAddZb:handleEquipItemqiehuan(args)
    self.item = args
end

function PetAddZb:handleEquipItemChoosed(args)
   local Commontipdlg = require "logic.tips.commontipdlg"
   Commontipdlg.getInstance().DestroyDialog()
    local wnd = CEGUI.toWindowEventArgs(args).window
    if self.lastSelectedBtn == wnd then
        return
    end

    self.lastSelectedBtn = wnd

    local idx = wnd:getID()
    local cell = self.EquipItems[idx]
    local nItemId = cell.itemData:GetObjectID()
    
    local itemEffectData = BeanConfigManager.getInstance():GetTableByName("item.CPetEquipItemEffect"):getRecorder(cell.itemData:GetObjectID())
    self.itemkey = cell.itemData:GetThisID()--宠物装备背包key
    self.itemid = itemEffectData.id--宠物装备id
    self.item = cell.itemData:GetObject()
    local e2 = CEGUI.toMouseEventArgs(args)
    local touchPos = e2.position
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if not itemAttrCfg.id then
        return
    end
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    
    local nType = Commontipdlg.eType.epetequip 
    commontipdlg:RefreshItem(nType,nItemId,200,500,self.item)
    
end

function PetAddZb.onEventItemNumChange(bagid, itemkey, itembaseid)
    if not _instance or not _instance:IsVisible() then
        return
    end
    if bagid ~= fire.pb.item.BagTypes.BAG then
        return
    end
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
    if not item then
        for i=1, #_instance.EquipItems do
            local cell = _instance.EquipItems[i]
            if cell.itemKey == itemkey then
                if _instance.lastSelectedBtn == cell.window then
                    _instance.lastSelectedBtn = nil
                end
                CEGUI.WindowManager:getSingleton():destroyWindow(cell.window)
                table.remove(_instance.EquipItems, i)
                for j=i,#_instance.EquipItems do
                    cell = _instance.EquipItems[j]
                    local h = cell.window:getPixelSize().height
                    local y = cell.window:getYPosition()
                    y.offset = y.offset-h-5
                    cell.window:setYPosition(y)
                    cell.window:setID(cell.window:getID()-1)
                    cell.window:setHeight(CEGUI.UDim(0,h))
                end
                break
            end
        end
    end
end
function PetAddZb:handlEquipClicked(itemkey)--穿戴宠物装备
            
               if _instance.petkey == 0 or itemkey == 0 then
                 return
               end

               if GetBattleManager():IsInBattle() then    
                   if _instance.petkey == gGetDataManager():GetBattlePetID() then
                    GetCTipsManager():AddMessageTipById(150062) 
                    return
                   end
               end
               
               local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.petkey)
               
               if petData then
                if petData.flag == 1 then
                    GetCTipsManager():AddMessageTipById(150063)
                    return
                end
               end
                
               local p = require("protodef.fire.pb.pet.cpetequipbypet"):new()
                p.petkey = _instance.petkey
                p.itemkey = self.itemkey
                LogInfo("petneedid"..p.petkey)
                LogInfo("petneedid"..p.itemkey)
               LuaProtocolManager:send(p)
               self.DestroyDialog()
end

function PetAddZb:btnCloseCallBack(args)
    PetAddZb.DestroyDialog()
end

return PetAddZb