------------------------------------------------------------------
-- ѡ����＼����
------------------------------------------------------------------
require "logic.dialog"

PetAddSkillBook = {
	booktype = 49,	--���＼����(d�������ͱ�.xlsx)
	books = {},
	bookItems = {},
	lastSelectedBtn = nil
}
setmetatable(PetAddSkillBook, Dialog)
PetAddSkillBook.__index = PetAddSkillBook

local _instance
function PetAddSkillBook.getInstance()
	if not _instance then
		_instance = PetAddSkillBook:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetAddSkillBook.getInstanceAndShow(_booktype_,selectedPetKey,cellid)
	if not _instance then
		_instance = PetAddSkillBook:new()
		if _booktype_ ~= nil then
			_instance.booktype = _booktype_
			_instance.cellid = cellid
			_instance.selectedPetKey=selectedPetKey
		end
		_instance:OnCreate()
	else
		if _booktype_ ~= nil then
			_instance.booktype = _booktype_
			_instance.cellid = cellid
			_instance.selectedPetKey=selectedPetKey
		end
		_instance:SetVisible(true)
	end
	return _instance
end

function PetAddSkillBook.getInstanceNotCreate()
	return _instance
end

function PetAddSkillBook.DestroyDialog()
	if _instance then
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetAddSkillBook.CloseIfExist()
	if _instance then
		PetAddSkillBook.DestroyDialog()
	end
end

function PetAddSkillBook.GetLayoutFileName()
	return "petskilladd.layout"
end

function PetAddSkillBook:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetAddSkillBook)
	return self
end

function PetAddSkillBook:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petskilladd_mtg/main/scroll"))

    self.jinengText = winMgr:getWindow("petskilladd_mtg/bg/f3biaoshi/jineng")
    self.neidanText = winMgr:getWindow("petskilladd_mtg/bg/f3biaoshi/neidan")

    if self.booktype == 49 then
        self.jinengText:setVisible(true)
        self.neidanText:setVisible(false)
    elseif self.booktype == 50 then
        self.jinengText:setVisible(false)
        self.neidanText:setVisible(true)
    end
    
    self:loadBookList()
    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(PetAddSkillBook.onEventItemNumChange)
end

function PetAddSkillBook:loadBookList()
	self.books = {}
    self.bookItems = {}
    self.lastSelectedBtn = nil
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.books = roleItemManager:GetItemKeyListByType(self.books, self.booktype)
	for i = 0, self.books:size() - 1 do
		local idx = i+1
		local cell = self:createCell(self.books[i], idx)
		local height = cell.window:getHeight():asAbsolute(0)
		local offset = (height+5) * i or 1
		cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
		self.bookItems[idx] = cell
	end
end

function PetAddSkillBook:createCell(itemkey, idx)
    local cell = {}
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefix = tostring(itemkey)
    cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskillbookcell_mtg.layout", prefix))
    cell.item = CEGUI.toItemCell(winMgr:getWindow(prefix .. "petskillbookcell_mtg/item"))
    cell.name = winMgr:getWindow(prefix .. "petskillbookcell_mtg/name")
    cell.count = winMgr:getWindow(prefix .. "petskillbookcell_mtg/count")  -- 获取数量文本控件
    self.scroll:addChildWindow(cell.window)
    
    cell.window:setID(idx)
    cell.window:EnableClickAni(false)
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
    if item ~= nil then
        cell.itemData = item
        cell.itemKey = itemkey
        cell.item:SetImage(gGetIconManager():GetItemIconByID(item:GetBaseObject().icon))
        cell.name:setText(item:GetBaseObject().namecc1)
        local color = item:GetNameColour()
        cell.name:setProperty("TextColours", "FF8C5E2A")
        cell.item:setID(item:GetObjectID())
        cell.item:subscribeEvent("TableClick", PetAddSkillBook.HandleShowToolTipsWithItemID, self)

        cell.window:subscribeEvent("SelectStateChanged", PetAddSkillBook.handleBookItemChoosed, self)

        --  将获取数量和设置文本的代码移到 if 语句块内部 
        local itemNum = roleItemManager:GetItemNumByBaseID(item:GetBaseObject().id)  -- 获取物品数量
        cell.count:setText("" .. itemNum)   
    end
    
    return cell
end

function PetAddSkillBook:HandleShowToolTipsWithItemID(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
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
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end
function PetAddSkillBook:onNeidanSuccess()
	 PetPropertyDlgNew.getInstance():choosedSkillBookItem(self.cellid,self.neidankey,self.neidanskill)
	 self:DestroyDialog()
end
function PetAddSkillBook:handleBookItemChoosed(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	if self.lastSelectedBtn == wnd then
		return
	end

	self.lastSelectedBtn = wnd

	local idx = wnd:getID()
	local cell = self.bookItems[idx]
	local itemEffectData = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(cell.itemData:GetObjectID())
	if itemEffectData then
		if self.booktype==50 then
			 if self.cellid then
                local skillType = math.floor((itemEffectData.petskillid or 0) / 10000)
                local isMatch = false
                if skillType == 26 and self.cellid >= 1 and self.cellid <= 4 then
                    isMatch = true
                elseif skillType == 27 and self.cellid == 6 then
                    isMatch = true
                elseif skillType == 28 and self.cellid == 5 then
                    isMatch = true
                end
                if not isMatch then
                    local tipId = 201090
                    if self.cellid == 5 then
                        tipId = 201088
                    elseif self.cellid == 6 then
                        tipId = 201089
                    end
                    GetCTipsManager():AddMessageTipById(tipId)
                    return
                end
                if self.cellid==5 then
					if cell.itemData:GetBaseObject().nquality~=5 then
                        GetCTipsManager():AddMessageTipById(201088)
	 
						return 
					end
				elseif self.cellid==6 then
					--判断低级内胆不能选高级
					--这里内丹原修改 if cell.itemData:GetBaseObject().nquality~=4 then
					if cell.itemData:GetBaseObject().nquality~=5 then
                        GetCTipsManager():AddMessageTipById(201089)
	 
						return 
					end
				else
				    --这里内丹原修改 if cell.itemData:GetBaseObject().nquality~=3 then
					if cell.itemData:GetBaseObject().nquality~=5 then
                        GetCTipsManager():AddMessageTipById(201090)
 
						return 
					end
				end
				if not self.selectedPetKey or self.selectedPetKey == 0 then
					return
				end
				local p = require("protodef.fire.pb.pet.cpetlearninternalbybook"):new()
				p.petkey = self.selectedPetKey
				p.bookkey = cell.itemData:GetThisID()
				p.idx = self.cellid
				LuaProtocolManager:send(p)
				self.neidankey=cell.itemData:GetThisID()
				self.neidanskill=itemEffectData.petskillid
			else
				PetLianYaoDlg.getInstance():choosedSkillBookItem(self.booktype,cell.itemData:GetThisID(), itemEffectData.petskillid)
				self:DestroyDialog()
			end
		else
			PetLianYaoDlg.getInstance():choosedSkillBookItem(self.booktype,cell.itemData:GetThisID(), itemEffectData.petskillid)
			self:DestroyDialog()
		end
	end
end

function PetAddSkillBook.onEventItemNumChange(bagid, itemkey, itembaseid)
    -- 检查界面是否创建和显示
    if not _instance or not _instance:IsVisible() then
        return
    end
    -- 检查是否是背包事件
    if bagid ~= fire.pb.item.BagTypes.BAG then
        return
    end
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
    -- 如果物品不存在（例如被使用或删除）
    if not item then
        -- 遍历已有的书籍列表
        for i=1, #_instance.bookItems do
            -- 获取当前书籍信息
            local cell = _instance.bookItems[i]
            -- 如果当前书籍的key与发生变化的物品key一致
            if cell.itemKey == itemkey then
                -- 如果当前书籍是被选中的状态
                if _instance.lastSelectedBtn == cell.window then
                    -- 清空选中状态
                    _instance.lastSelectedBtn = nil
                end
                -- 从界面中删除该书籍
                CEGUI.WindowManager:getSingleton():destroyWindow(cell.window)
                -- 从书籍列表中移除该书籍
                table.remove(_instance.bookItems, i)
                -- 更新后续书籍的位置和id
                for j=i,#_instance.bookItems do
                    cell = _instance.bookItems[j]
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
    else  -- 物品数量发生变化
        -- 遍历已有的书籍列表
        for i=1, #_instance.bookItems do
            -- 获取当前书籍信息
            local cell = _instance.bookItems[i]
            -- 如果当前书籍的key与发生变化的物品key一致
            if cell.itemKey == itemkey then
                -- 获取更新后的物品数量
                local itemNum = roleItemManager:GetItemNumByBaseID(item:GetBaseObject().id)
                
                cell.count:setText("" .. itemNum)
                break
            end
        end
    end
end

return PetAddSkillBook
