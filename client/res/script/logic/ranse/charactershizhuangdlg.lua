require "logic.dialog"

CharacterShiZhuangDlg = {}
setmetatable(CharacterShiZhuangDlg, Dialog)
CharacterShiZhuangDlg.__index = CharacterShiZhuangDlg

local _instance
function CharacterShiZhuangDlg.getInstance()
    if not _instance then
        _instance = CharacterShiZhuangDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function CharacterShiZhuangDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterShiZhuangDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function CharacterShiZhuangDlg.getInstanceNotCreate()
    return _instance
end

function CharacterShiZhuangDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function CharacterShiZhuangDlg.ToggleOpenClose()
    if not _instance then
        _instance = CharacterShiZhuangDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function CharacterShiZhuangDlg.GetLayoutFileName()
    return "jueseshizhuang.layout"
end

function CharacterShiZhuangDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CharacterShiZhuangDlg)
    return self
end

-- role.crolercolorconfig.colorlist 使用 0 基索引，且当前项目里 shape 可能为 101/201/301 前缀编码。
local function getRoleRanseColorByShape(record, shape)
    if not record or not record.colorlist then
        return "ffffffff"
    end

    local modelShape = tonumber(shape) or 0
    local colorIdx = 0
    if modelShape < 1010100 then
        colorIdx = modelShape
    else
        colorIdx = (modelShape % 100) - 1
        if colorIdx < 0 then
            colorIdx = 0
        end
    end

    local clr = record.colorlist[colorIdx]
    if not clr or clr == "" then
        clr = record.colorlist[0] or record.colorlist[1] or "ffffffff"
    end
    return clr
end

if _G and _G.FASHION_WEAPON_EQUIP_FIRST == nil then
    _G.FASHION_WEAPON_EQUIP_FIRST = false
end

local function getWeaponComponentIdFromEquipItemId(equipItemId)
    local itemId = tonumber(equipItemId) or 0
    if itemId <= 0 then
        return 0, "invalid_item_id"
    end

    -- 大ID（如 9250101）在当前项目里本身就是可用武器组件，优先直接使用，
    -- 避免再映射成低位 weaponid（如 210）导致预览不显示。
    local directWeaponId = 0
    if itemId >= 1000000 then
        directWeaponId = itemId
    end

    local isPointCardServer = (type(IsPointCardServer) == "function" and IsPointCardServer()) or false
    local mappedWeaponId = 0

    if isPointCardServer then
        local equipEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cequipeffect")
        if equipEffectTable then
            local equipEffectCfg = equipEffectTable:getRecorder(itemId)
            if equipEffectCfg and equipEffectCfg.id ~= -1 then
                mappedWeaponId = tonumber(equipEffectCfg.weaponid) or 0
            end
        end
    else
        if GameTable and GameTable.item and GameTable.item.GetCEquipEffectTableInstance then
            local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance()
            if equipEffectTable then
                local equipEffectCfg = equipEffectTable:getRecorder(itemId)
                if equipEffectCfg and equipEffectCfg.id ~= -1 then
                    mappedWeaponId = tonumber(equipEffectCfg.weaponid) or 0
                end
            end
        end
    end

    if directWeaponId > 0 then
        if mappedWeaponId > 0 and mappedWeaponId ~= directWeaponId then
            LogInfo(string.format("CharacterShiZhuangDlg.weapon resolve prefer direct itemId=%s over mapped=%s",
                tostring(itemId), tostring(mappedWeaponId)))
        end
        return directWeaponId, "direct_item_id"
    end

    if mappedWeaponId > 0 then
        return mappedWeaponId, "equip_effect_map"
    end

    return itemId, "direct_item_id_fallback"
end

local function getEquippedWeaponItemId()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if not roleItemManager then
        return 0, "no_role_item_manager"
    end

    if roleItemManager.GetCurrentEquip then
        local weaponEquip = roleItemManager:GetCurrentEquip(fire.pb.item.BagTypes.EQUIP, eEquipType_ARMS)
        if weaponEquip and weaponEquip.GetObjectID then
            local itemId = tonumber(weaponEquip:GetObjectID()) or 0
            if itemId > 0 then
                return itemId, "GetCurrentEquip"
            end
        end
    end

    if roleItemManager.GetBagInfo then
        local bagInfo = roleItemManager:GetBagInfo()
        local function scanList(list, source)
            if not list then
                return 0, source
            end
            for _, pItem in pairs(list) do
                if pItem and pItem.GetSecondType and pItem.GetObjectID then
                    local secondType = tonumber(pItem:GetSecondType()) or -1
                    if secondType == eEquipType_ARMS then
                        local loc = pItem.GetLocation and pItem:GetLocation() or nil
                        if (not loc) or loc.tableType == fire.pb.item.BagTypes.EQUIP then
                            local itemId = tonumber(pItem:GetObjectID()) or 0
                            if itemId > 0 then
                                return itemId, source
                            end
                        end
                    end
                end
            end
            return 0, source
        end

        if bagInfo then
            local itemId, source = scanList(bagInfo[fire.pb.item.BagTypes.EQUIP], "GetBagInfo[EQUIP]")
            if itemId > 0 then
                return itemId, source
            end
            for bagId, list in pairs(bagInfo) do
                itemId, source = scanList(list, "GetBagInfoScan:" .. tostring(bagId))
                if itemId > 0 then
                    return itemId, source
                end
            end
        end
    end

    return 0, "not_found"
end

local function isFashionEquipWeaponFirst()
    if _G and _G.FASHION_WEAPON_EQUIP_FIRST ~= nil then
        return _G.FASHION_WEAPON_EQUIP_FIRST == true
    end
    return false
end

local function getPreviewWeaponId(modelId)
    local weaponId = 0
    local mainWeaponId = 0
    local equipSource = "none"
    local equipBagWeaponId = 0
    local equipBagWeaponSource = "none"
    local equipItemId = 0

    local mainCharacter = GetMainCharacter()
    if mainCharacter and mainCharacter.GetSpriteComponent then
        mainWeaponId = tonumber(mainCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
    end

    equipItemId, equipSource = getEquippedWeaponItemId()
    if equipItemId > 0 then
        equipBagWeaponId, equipBagWeaponSource = getWeaponComponentIdFromEquipItemId(equipItemId)
    end

    -- 统一按角色当前武器组件显示；仅当组件缺失时才回退到装备栏映射。
    weaponId = mainWeaponId
    if weaponId <= 0 and equipBagWeaponId > 0 then
        weaponId = equipBagWeaponId
    end

    LogInfo(string.format("CharacterShiZhuangDlg.getPreviewWeaponId model=%s main=%s equipItemId=%s equipSource=%s equipWeapon=%s equipWeaponSource=%s final=%s",
        tostring(modelId), tostring(mainWeaponId), tostring(equipItemId), tostring(equipSource), tostring(equipBagWeaponId), tostring(equipBagWeaponSource), tostring(weaponId)))

    if weaponId > 0 then
        return weaponId
    end

    -- 彻底禁用按时装/shape默认武器回退，仅允许装备栏或角色组件来源。
    return 0
end

local function applyMainCharacterPreviewAppearance(sprite, modelId)
    if not sprite then
        return
    end

    local mainCharacter = GetMainCharacter()
    local dyeA = 0
    local dyeB = 0
    local weaponColor = 0
    if mainCharacter and mainCharacter.GetSpriteComponent then
        dyeA = tonumber(mainCharacter:GetSpriteComponent(eSprite_DyePartA)) or 0
        dyeB = tonumber(mainCharacter:GetSpriteComponent(eSprite_DyePartB)) or 0
        weaponColor = tonumber(mainCharacter:GetSpriteComponent(eSprite_WeaponColor)) or 0
    end

    local weaponId = getPreviewWeaponId(modelId)
    if weaponId > 0 then
        sprite:SetSpriteComponent(eSprite_Weapon, weaponId)
    end
    LogInfo(string.format("CharacterShiZhuangDlg.applyPreview model=%s weapon=%s dyeA=%s dyeB=%s",
        tostring(modelId), tostring(weaponId), tostring(dyeA), tostring(dyeB)))

    sprite:SetDyePartIndex(0, dyeA)
    sprite:SetDyePartIndex(1, dyeB)

    if weaponColor > 0 and sprite.UpdateWeaponColorParticle then
        sprite:UpdateWeaponColorParticle(weaponColor)
    end
end

local function queuePreviewAppearanceReapply(dialog, modelId, times)
    if not dialog then
        return
    end
    dialog.m_previewModelId = tonumber(modelId) or 0
    dialog.m_pendingPreviewReapply = tonumber(times) or 0
    if dialog.m_pendingPreviewReapply < 0 then
        dialog.m_pendingPreviewReapply = 0
    end
end

function CharacterShiZhuangDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    --SetPositionOfWindowWithLabel(self:GetWindow())
    --self:GetCloseBtn():removeEvent("Clicked")
    --self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)

    self.leftDown = false;
    self.rightDown = false;
    self.downTime = 0;
    self.turnL = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/xuanniu2"));
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/back"))
    self.cbTipBtn0 = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/yichu3"))--人物染色
    --self.cbTipBtn0:subscribeEvent("Clicked", self.handleCombineTipClicked0, self)
    self.cbTipBtn0:subscribeEvent("Clicked", self.handleranse, self)

    self.cbTipBtn1 = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/yichu1"))--我的衣橱
	self.cbTipBtn1:subscribeEvent("Clicked", self.handleCombineTipClicked1, self)
	--self.cbTipBtn1:subscribeEvent("Clicked", self.handleyichu, self)
	
	
	self.cbTipBtn2 = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/yichu2"))--宠物染色
	self.cbTipBtn2:subscribeEvent("Clicked", self.handleCombineTipClicked2, self)

	self.cbTipBtn3 = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/yichu6"))--时装
	self.cbTipBtn3:subscribeEvent("Clicked", self.handleCombineTipClicked3, self)
	
	self.cbTipBtn8 = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/yichu8"))--宠物染色
	self.cbTipBtn8:subscribeEvent("Clicked", self.handleCombineTipClicked8, self)

    self.turnL:subscribeEvent("MouseButtonDown", CharacterShiZhuangDlg.handleLeftClicked, self)
    self.turnR:subscribeEvent("MouseButtonDown", CharacterShiZhuangDlg.handleRightClicked, self)
    self.turnL:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handleLeftUp, self)
    self.turnR:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handleRightUp, self)
    self.turnL:subscribeEvent("MouseLeave", CharacterShiZhuangDlg.handleLeftUp, self)
    self.turnR:subscribeEvent("MouseLeave", CharacterShiZhuangDlg.handleRightUp, self)
    self.m_btnguanbi:subscribeEvent("Clicked", CharacterShiZhuangDlg.handleQuitBtnClicked, self)	

    self.shiyongBtn = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/huanyuan111"))--宠物染色
    self.shiyongBtn:subscribeEvent("Clicked", CharacterShiZhuangDlg.handleShiYongClicked, self)
    self.goumaiBtn = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/huanyuan11"))--宠物染色
    self.goumaiBtn:subscribeEvent("Clicked", CharacterShiZhuangDlg.handleGouMaiClicked, self)
    self.shiyongBtn:setVisible(false)
    --self.goumaiBtn:setVisible(false)


    self.shichuan = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/biaoti/qiehuan"));
    self.shichuan:subscribeEvent("Clicked", CharacterShiZhuangDlg.handleShiChuanClicked, self)
    self.shichuan:EnableClickAni(false)
    self.yongyou = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/biaoti/qiehuan1"));
    self.yongyou:subscribeEvent("Clicked", CharacterShiZhuangDlg.handleYongYouClicked, self)
    self.yongyou:EnableClickAni(false)
	
	self.shichuan:setVisible(false)
    self.yongyou:setVisible(false)

	
	
	self.currentActionIndex = 1
    self.availableActions = {"stand1", "run", "attack1", "magic1"}


    local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("jueseshizhuang/beijing/moxing")
    --self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0, 0, true)
	
		local pos = self.canvas:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y)
		self.sprite = UISprite:new(data.shape)
		if self.sprite then
            self.spriteOwner = "ui_sprite"
			self.sprite:SetUILocation(loc)
			self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
			self.canvas:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, CharacterShiZhuangDlg.performPostRenderFunctions))
            applyMainCharacterPreviewAppearance(self.sprite, data.shape)
		else
            self.spriteOwner = nil
		end

	
	
    self.partList = {};
    self.partList[1] = {}
    self.partList[2] = {}
    self.colorList = {};
    self.colorList[1] = {}
    self.colorList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
    local num = table.getn(ids)
    for i = 1, num do
 
        if ids[i] < 1000 then
            local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
            table.insert(self.partList[record.rolepos], record.id)
            local clr = getRoleRanseColorByShape(record, data.shape)

            --rolepos 部位
            table.insert(self.colorList[record.rolepos], clr)
        end
    end
 
    self.currentIDA = 1;
    self.currentIDB = 1;

    self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("jueseshizhuang/ranliao1"))

    self.ItemCellNeedItem1:setVisible(false)


    self.neeItemCountText1 = winMgr:getWindow("jueseshizhuang/ranliaoshu1")

    self.neeItemCountText1:setText("")

    self.neeItemNameText1 = winMgr:getWindow("jueseshizhuang/ranliaoming1")
	
	
    self.p_Scroll = winMgr:getWindow("jueseshizhuang/pets/petScroll")
	self.p_Scroll:addChildWindow(self.cbTipBtn0) --添加子控件
	self.p_Scroll:addChildWindow(self.cbTipBtn1) --添加子控件
	self.p_Scroll:addChildWindow(self.cbTipBtn8) --添加子控件
	self.p_Scroll:addChildWindow(self.cbTipBtn3) --添加子控件

	
	--关闭按钮
	self.close = winMgr:getWindow("jueseshizhuang/window/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)
	
	self.btbuy = winMgr:getWindow("jueseshizhuang/window/tabBtn1");
    self.btbuy:subscribeEvent("Clicked", CharacterShiZhuangDlg.qiehuanbuy, self)


	self.huanyuan = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/huanyuan"));
	self.gongji = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/gongji"));
	self.shifa = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/shifa"));
	self.fangda = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/fangda"));

	self.huanyuan:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handlehuanyuanClicked, self)
	self.gongji:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handlegongjiClicked, self)
	self.shifa:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handleshifaClicked, self)
	self.fangda:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handlefangdaClicked, self)

	--右侧帘子主界面控件 用于切换
	self.jm_shizhuang = winMgr:getWindow("jueseshizhuang/window/lianzi2/shizhuang")
	self.jm_ranse = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse")
	self.jm_yichu = winMgr:getWindow("jueseshizhuang/window/lianzi2/yichu")
	
	
	--染色界面控件
	----部件一控件列表
	self.rs_BJScroll1 = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1")
	self.rs_Col1 = {}
	for a=1 ,8 do
		self.rs_Col1[a] = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1/A"..a)
	end
	for a=1 ,8 do
		self.rs_BJScroll1:addChildWindow(self.rs_Col1[a]) --添加子控件
	end
	----部件二控件列表
	self.rs_BJScroll2 = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list2")
	self.rs_Col2 = {}
	for a=1 ,8 do
		self.rs_Col2[a] = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1/B"..a)
	end
	for a=1 ,8 do
		self.rs_BJScroll2:addChildWindow(self.rs_Col2[a]) --添加子控件
	end


	
	

	--动画层
	--self.MY_Win_Time1 =  0.4 --中间帘子起始位置
	self.lianzi = winMgr:getWindow("jueseshizhuang/lianli");
	--moveControl(self.lianzi, 0.5, 0,self.MY_Win_Time1, 0)
	self:zhonjianlianziAni(1)--1上升  2下拉


	self.MY_Win_Time2 =  0.2 --左侧帘子起始位置
	self.lianzi2 = winMgr:getWindow("jueseshizhuang/pets");
	moveControl(self.lianzi2, 0.17, 0,self.MY_Win_Time2, 0)

	self.lianzi3 = winMgr:getWindow("jueseshizhuang/window/lianzi2"); --右侧帘子  同步左侧帘子
	moveControl(self.lianzi3, 0.8, 0,self.MY_Win_Time2, 0)
	
	


	self:GetWindow():subscribeEvent("WindowUpdate", CharacterShiZhuangDlg.HandleWindowUpdate, self)--更新

	self:handleCombineTipClicked3()--默认打开时装


    self.neeItemNameText1:setText("")
    self.select = 0;
    self.selectye = 2;
    self.ItemCellNeedItem1:setVisible(false)
    self.neeItemNameText1:setVisible(false)
    self.neeItemCountText1:setVisible(false)
    local ids =BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getAllID()
    self.szlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("jueseshizhuang/biaoti/shizhuang/szs"));
    self.szlistWnd:EnableHorzScrollBar(false)
    self:refreshSzTable()
end

function CharacterShiZhuangDlg.performPostRenderFunctions(id)
	if _instance and _instance:IsVisible() and _instance:GetWindow():getEffectiveAlpha() > 0.95 and _instance.sprite then --_instance.selectedPetKey ~= 0 and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

local function clearShiZhuangCellEffects(cellMap)
	if not cellMap then
		return
	end
	for _, cell in pairs(cellMap) do
		if cell then
			gGetGameUIManager():AddUIEffect(cell, nil, true)
		end
	end
end

function CharacterShiZhuangDlg:updateShiZhuangSprite(modelId)
	if not modelId then
		return
	end
	if self.sprite then
		self.sprite:SetModel(modelId)
		self.sprite:SetUIDirection(self.dir)
        applyMainCharacterPreviewAppearance(self.sprite, modelId)
	else
		self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, modelId, self.dir, 0, 0, true)
        self.spriteOwner = "window_sprite"
        applyMainCharacterPreviewAppearance(self.sprite, modelId)
	end
    -- 模型切换后引擎可能在后续帧按 shape 默认 showWeaponId 回写武器，补几帧重设。
    queuePreviewAppearanceReapply(self, modelId, 6)
end

function CharacterShiZhuangDlg:handleCombineTipClicked3()  --打开时装界面

	if self.jm_ranse:isVisible() == true or self.jm_yichu:isVisible() == true then
		self:zhonjianlianziAni(1)--1上升  2下拉
	end
	self.jm_shizhuang:setVisible(true)
	self.jm_ranse:setVisible(false)
	self.jm_yichu:setVisible(false)
	self.cbTipBtn0:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn")  --右侧 染色按钮
	self.cbTipBtn1:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn")  --右侧 衣橱按钮
	self.cbTipBtn3:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn_t")  --右侧 时装按钮
	

	
end



function CharacterShiZhuangDlg:handleyichu()  --打开衣橱界面

	-- if self.jm_shizhuang:isVisible() == true then
		-- self:zhonjianlianziAni(2)--1上升  2下拉
	-- end

-- -----require "logic.ranse.yichudlg":getInstance()
-- --从界面中提取数据 第一次无法获得  需要点击二次
-- local dlg = require "logic.ranse.RanSeLabel":getInstance()
-- local yclist =yc_jiajiesuju
-- dlg:DestroyDialog()



-- -- local p = require "protodef.fire.pb.sreqcolorroomview"



	-- self.jm_shizhuang:setVisible(false)
	-- self.jm_ranse:setVisible(false)
	-- self.jm_yichu:setVisible(true)
	-- self.cbTipBtn0:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn")  --右侧 染色按钮
	-- self.cbTipBtn1:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn_t")  --右侧 衣橱按钮
	-- self.cbTipBtn3:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn")  --右侧 时装按钮
-- --GetCTipsManager():AddMessageTip("仙玉"..yclist[2].colorpos1)
-- --self.rolecolortypelist[i].colorpos1
    -- self.m_ycList = {}
    -- self.m_saveSpriteList = {}

	-- self:setYCList(yclist)

	

end


function CharacterShiZhuangDlg:handleranse()  --打开染色界面

	if self.jm_shizhuang:isVisible() == true then
		self:zhonjianlianziAni(2)--1上升  2下拉
	end

	self.jm_shizhuang:setVisible(false)
	self.jm_ranse:setVisible(true)
	self.jm_yichu:setVisible(false)
	self.cbTipBtn0:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn_t")  --右侧 染色按钮
	self.cbTipBtn1:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn")  --右侧 衣橱按钮
	self.cbTipBtn3:setProperty("NormalImage", "set:my_yuehuahuanyi image:btn")  --右侧 时装按钮



	--时装不能染色  染色时还原为无时装状态
	self:handlehuanyuanClicked()
	--r染色界面初始化
	local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.rs_partList = {};
	self.rs_partList[1] = {}
	self.rs_partList[2] = {}
    self.rs_colorList = {};
	self.rs_colorList[1] = {}
	self.rs_colorList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
	local num = table.getn(ids)
	for i =1, num do
        if ids[i] < 1000 then
		    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
            table.insert(self.rs_partList[record.rolepos],record.id)
                        
            local clr = getRoleRanseColorByShape(record, data.shape)
            table.insert(self.rs_colorList[record.rolepos],clr)
        end
	end
    for i = 1, 8 do
		local btn = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1/A" ..i)
	    local btndi = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1/A" .. tostring(i).."/bg")
        if self.rs_partList[1][i] ~= nil then
            btn:setID(i)
	        btn:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handlePartAClicked, self)
            btn:setVisible(true)        
            btndi:setProperty("ImageColours", self.rs_colorList[1][i])
            btndi:setVisible(true)    
        else
            btn:setVisible(false)
            btndi:setVisible(false)    
        end
		
		local btn2 = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1/B" ..i)
        local btn2di = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/list1/B" .. tostring(i).."/bg")
        if self.rs_partList[2][i] ~= nil then
            btn2:setID(i)
	        btn2:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handlePartBClicked, self)
            btn2:setVisible(true)
            btn2di:setProperty("ImageColours", self.rs_colorList[2][i])
            btn2di:setVisible(true) 
        else
            btn2:setVisible(false)
            btn2di:setVisible(false)    
        end

	end
	
	self.rs_ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/ranliao1"))
	self.rs_ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/ranliao2"))   
    self.rs_ItemCellNeedItem1:subscribeEvent("MouseClick",CharacterShiZhuangDlg.HandleItemCellItemClick,self) 
    self.rs_ItemCellNeedItem2:subscribeEvent("MouseClick",CharacterShiZhuangDlg.HandleItemCellItemClick,self) 
	
	self.rs_neeItemCountText1 = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/ranliao1txt")
	self.rs_neeItemCountText2 = winMgr:getWindow("jueseshizhuang/window/lianzi2/ranse/ranliao2txt")
    self.rs_ItemCellNeedItem1:setVisible(false)
    self.rs_ItemCellNeedItem2:setVisible(false)
	
	
	self.rsOkBtn = CEGUI.toPushButton(winMgr:getWindow("jueseshizhuang/huanyuan112"));
	self.rsOkBtn:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handleRSOKClicked, self)
    --self.rsOkBtn:EnableClickAni(false)
    self.rsOkBtn:setEnabled(false)
	
	self.m_pMainFrame:subscribeEvent("Activated", CharacterShiZhuangDlg.HandleActivate, self) 


	
	--获取现有的颜色
    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self:Init(pA,pB);
    applyMainCharacterPreviewAppearance(self.sprite, data.shape)

end

function CharacterShiZhuangDlg:HandleActivate(args)
    self:refreshItemShow()
end

function CharacterShiZhuangDlg:handleRSOKClicked(args)    

    local itemlist = {}
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local isYc = self:isInYiChu(self.rs_partList[1][self.currentIDA],self.rs_partList[2][self.currentIDB])
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
    p.rolecolorinfo.colorpos1 = self.rs_partList[1][self.currentIDA];
    p.rolecolorinfo.colorpos2 = self.rs_partList[2][self.currentIDB];
    require "manager.luaprotocolmanager".getInstance():send(p)
end

--获取现有的颜色
function CharacterShiZhuangDlg:Init(partA,partB)
    self.savePartA = self:GetPartIndex(1,partA)
    self.savePartB = self:GetPartIndex(2,partB)    
    self:SetPartIndex(1,self.savePartA)
    self:SetPartIndex(2,self.savePartB)
end
function CharacterShiZhuangDlg:GetPartIndex(part,id)    
    for i = 1, #self.rs_partList[part] do
        if  id == self.rs_partList[part][i] then
            return i
        end
    end
    return 0
end

function CharacterShiZhuangDlg:HandleItemCellItemClick(args) -- 提示道具信息
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

function CharacterShiZhuangDlg:handlePartAClicked(args) ---设置部位一颜色
	local e = CEGUI.toWindowEventArgs(args)
	local nColorID = e.window:getID()
    self.currentIDA = nColorID
    self:SetPartIndex(1,self.currentIDA)
	
	local btndi = {}
    for i = 1, 8 do
	    btndi[i] = CEGUI.WindowManager:getSingleton():getWindow("jueseshizhuang/window/lianzi2/ranse/list1/A" .. tostring(i).."/bg")
		gGetGameUIManager():AddUIEffect(btndi[i], nil, true)
	end
	gGetGameUIManager():AddUIEffect(btndi[nColorID], "animation/ui/My_texiao/my_rwsz_sel", true)

	
    --self:refreshSelect()
end
function CharacterShiZhuangDlg:handlePartBClicked(args) ---设置部位二颜色
	local e = CEGUI.toWindowEventArgs(args)
	local nColorID = e.window:getID()
    self.currentIDB = nColorID
    self:SetPartIndex(2,self.currentIDB)
	
	local btndi = {}
    for i = 1, 8 do
	    btndi[i] = CEGUI.WindowManager:getSingleton():getWindow("jueseshizhuang/window/lianzi2/ranse/list1/B" .. tostring(i).."/bg")
		gGetGameUIManager():AddUIEffect(btndi[i], nil, true)
	end
	gGetGameUIManager():AddUIEffect(btndi[nColorID], "animation/ui/My_texiao/my_rwsz_sel", true)

    --self:refreshSelect()
end


function CharacterShiZhuangDlg:SetPartIndex(part,id)  --设置部位颜色
    if part == 1 then 
        self.currentIDA = id
		self.sprite:SetDyePartIndex(part-1,self.rs_partList[1][self.currentIDA])
		self:refreshItemShow()  --设置需要的染料道具

    elseif part == 2 then 
        self.currentIDB = id
		self.sprite:SetDyePartIndex(part-1,self.rs_partList[2][self.currentIDB])
		self:refreshItemShow()  --设置需要的染料道具
    end

    local modelId = 0
    if self.sprite and self.sprite.GetModelID then
        modelId = tonumber(self.sprite:GetModelID()) or 0
    end
    applyMainCharacterPreviewAppearance(self.sprite, modelId)
    
    if self.currentIDA ~= self.savePartA or self.currentIDB ~= self.savePartB then
        self.rsOkBtn:setEnabled(true)
        --self.rsCancelBtn:setEnabled(true)
    else        
        self.rsOkBtn:setEnabled(false)
        --self.rsCancelBtn:setEnabled(false)
    end
end
function CharacterShiZhuangDlg:isInYiChu(cA,cB) -- 是否在衣橱
	if g_yclist then
    for i=1,#g_yclist do
        if g_yclist[i].colorA == cA and g_yclist[i].colorB == cB then
            return true
        end
    end
	end
    return false
end

--tp 1普通  2衣橱
function CharacterShiZhuangDlg:updateUseItem(tp,rate,itemlist)  --更新使用的染料道具
    
    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.rs_partList[1][self.currentIDA])
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
    record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.rs_partList[2][self.currentIDB])
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

function CharacterShiZhuangDlg:refreshItemShow()
    local itemlist = {}
    local isYc = self:isInYiChu(self.rs_partList[1][self.currentIDA],self.rs_partList[2][self.currentIDB])
    if isYc == true then
        local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
        self:updateUseItem(2,t,itemlist)
    else
        self:updateUseItem(1,1.0,itemlist)
    end
    --self.inYiChu:setVisible(isYc)
    self.rs_ItemCellNeedItem1:setVisible(false)
    self.rs_ItemCellNeedItem2:setVisible(false)
    self.rs_neeItemCountText1:setText("")
    self.rs_neeItemCountText2:setText("")
    -- self.rs_neeItemNameText1:setText("")
    -- self.rs_neeItemNameText2:setText("")

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
                self.rs_ItemCellNeedItem1:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))            
                self.rs_ItemCellNeedItem1:setID(key)
                self.rs_ItemCellNeedItem1:setVisible(true)
                -- self.rs_neeItemNameText1:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.rs_neeItemCountText1:setText(tColor..tStr)
            elseif i == 2 then
                self.rs_ItemCellNeedItem2:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))       
                self.rs_ItemCellNeedItem2:setID(key)
                self.rs_ItemCellNeedItem2:setVisible(true)
                --self.rs_neeItemNameText2:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.rs_neeItemCountText2:setText(tColor .. tStr)
            end
        end
        i = i + 1
    end
end

function CharacterShiZhuangDlg:handlegongjiClicked()  --攻击动作
	self.sprite:PlayAction(eActionAttack)
end

function CharacterShiZhuangDlg:handleshifaClicked()  -------施法动作
	self.sprite:PlayAction(eActionMagic1)
end
function CharacterShiZhuangDlg:handlehuanyuanClicked()  -------还原模型
    local data = gGetDataManager():GetMainCharacterData()

	self.sprite:SetModel(data.shape)
    applyMainCharacterPreviewAppearance(self.sprite, data.shape)
    queuePreviewAppearanceReapply(self, data.shape, 6)

end
function CharacterShiZhuangDlg:handlefangdaClicked()  --放大模型
	if self.Scale == 1.5 then
		self.Scale = 1.0
	else
		self.Scale = 1.5
	end
	
	self.sprite:SetUIScale(self.Scale)
	
	self.sprite:SetUIDirection(3)

end

 function CharacterShiZhuangDlg:qiehuanbuy()  --切换购买 

	if self.selectye ==  1 then
		self:handleShiChuanClicked()
		return
	end
	if self.selectye ==  2 then
		self:handleYongYouClicked()
		return
	end	
	
	
	
end

function CharacterShiZhuangDlg:zhonjianlianziAni(zt)  --中间帘子的动画
	if zt == 1 then--上升
		self.MY_Win_Time1 =  0.37 --中间帘子起始位置
		moveControl(self.lianzi, 0.5, 0,self.MY_Win_Time1, 0)

		self.szLzAni1 = 1
	end
	if zt == 2 then --下拉
		self.MY_Win_Time1 =  -0.17 --中间帘子起始位置
		moveControl(self.lianzi, 0.5, 0,self.MY_Win_Time1, 0)

		self.szLzAni1 = 2
	end

end


 function CharacterShiZhuangDlg:HandleWindowUpdate()  --update
	if  self.szLzAni1 == 1 then  --上升
		self.MY_Win_Time1 =  self.MY_Win_Time1 - 0.03  --中间帘子移动速度
		if self.MY_Win_Time1 > -0.2 then
		moveControl(self.lianzi, 0.5, 0, self.MY_Win_Time1, 0)

		
		end
	end
	if  self.szLzAni1 == 2 then  --下拉
		self.MY_Win_Time1 =  self.MY_Win_Time1 + 0.03  --中间帘子移动速度
		if self.MY_Win_Time1 < 0.4 then
		moveControl(self.lianzi, 0.5, 0, self.MY_Win_Time1, 0)
		end
	end
	
		self.MY_Win_Time2 =  self.MY_Win_Time2 + 0.03  --左右帘子移动速度
		if self.MY_Win_Time2 < 0.52 then
			moveControl(self.lianzi2, 0.17, 0, self.MY_Win_Time2, 0)
			moveControl(self.lianzi3, 0.8, 0, self.MY_Win_Time2, 0)
		end
		
	
		if self.sprite and (tonumber(self.m_pendingPreviewReapply) or 0) > 0 then
			local modelId = tonumber(self.m_previewModelId) or 0
			if modelId <= 0 and self.sprite.GetModelID then
				modelId = tonumber(self.sprite:GetModelID()) or 0
			end
			applyMainCharacterPreviewAppearance(self.sprite, modelId)
			self.m_pendingPreviewReapply = self.m_pendingPreviewReapply - 1
		end
		

		
end


function moveControl(controlName, xRatio, xOffset, yRatio, yOffset)--移动控件子函数 从居中位置来算
    --local control = CEGUI.WindowManager:getSingleton():getWindow(controlName)--可以用名字的方式取控件
    local parent = controlName:getParent() --获取待移动的控件的父级

    local parentWidth = parent:getPixelSize().width
    local parentHeight = parent:getPixelSize().height

    local xPosition = (parentWidth * xRatio) + xOffset - (controlName:getPixelSize().width/2)
    local yPosition = (parentHeight * yRatio) + yOffset - (controlName:getPixelSize().height/2)

    controlName:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPosition), CEGUI.UDim(0, yPosition)))
end














function CharacterShiZhuangDlg:handleShiYongClicked(args)
    if self.select~=0 then
        local data = gGetDataManager():GetMainCharacterData()
        local cmd = require "protodef.fire.pb.shizhuang.cchangeshizhuangshiyong".Create()
        cmd.shizhuangid = self.select
        cmd.moxing = data.shape
        LuaProtocolManager.getInstance():send(cmd)
		
		GetCTipsManager():AddMessageTip("时装更换成功")

    end
end
function CharacterShiZhuangDlg:handleGouMaiClicked(args)
    if self.select~=0 then
        local cmd = require "protodef.fire.pb.shizhuang.cchangeshizhuanggoumai".Create()
        cmd.shizhuangid = self.select
        LuaProtocolManager.getInstance():send(cmd)
		
		--GetCTipsManager():AddMessageTip("时装购买成功")

    end
end
function CharacterShiZhuangDlg:handleShiChuanClicked(args)
    local sz = #self.m_szList
    for index  = 1, sz do
        local lyout = self.m_szList[1]
        lyout.addclick = nil
        lyout.LevelText = nil
        self.szlistWnd:removeChildWindow(lyout)
        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_szList,1)
    end
    self:refreshSzTable()
    self.ItemCellNeedItem1:setVisible(false)
    self.neeItemNameText1:setVisible(false)
    self.neeItemCountText1:setVisible(false)
    self.ItemCellNeedItem1:setVisible(true)
    self.neeItemNameText1:setVisible(true)
    self.neeItemCountText1:setVisible(true)
    self.shiyongBtn:setVisible(false)
    self.goumaiBtn:setVisible(true)
    self.selectye = 2;
	
	self.btbuy:setProperty("NormalImage", "set:my_yuehuahuanyi image:biaoqian2")
	self.btbuy:setProperty("PushedImage", "set:my_yuehuahuanyi image:biaoqian2")
	self.btbuy:setProperty("HoverImage", "set:my_yuehuahuanyi image:biaoqian2")

	
end
function CharacterShiZhuangDlg:handleYongYouClicked(args)
    local sz = #self.m_szList
    for index  = 1, sz do
        local lyout = self.m_szList[1]
        lyout.addclick = nil
        lyout.LevelText = nil
        self.szlistWnd:removeChildWindow(lyout)
        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_szList,1)
    end
    self.ItemCellNeedItem1:setVisible(false)
    self.neeItemNameText1:setVisible(false)
    self.neeItemCountText1:setVisible(false)
    self.shiyongBtn:setVisible(true)
    self.goumaiBtn:setVisible(false)
    local cmd = require "protodef.fire.pb.shizhuang.cyichuyongyou".Create()
    cmd.xx=1
    LuaProtocolManager.getInstance():send(cmd)
    self.selectye = 1;
	
	self.btbuy:setProperty("NormalImage", "set:my_yuehuahuanyi image:biaoqian1")
	self.btbuy:setProperty("PushedImage", "set:my_yuehuahuanyi image:biaoqian1")
	self.btbuy:setProperty("HoverImage", "set:my_yuehuahuanyi image:biaoqian1")

end
function CharacterShiZhuangDlg:refreshSzTable()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    self.m_szList = {}
    local index = 0
    local index2 = 0
    local ids =BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getAllID()
	
	self.m_szCell = {}

    for i = 1, #ids do
        local shizhuang = BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getRecorder(ids[i])
        local shapeid = gGetDataManager():GetMainCharacterShape()
        local shapeid1=tostring(shapeid)
        local shape1=string.sub(shapeid1,-2)
        local shapeid2=tostring(shizhuang.moxing)
        local shape2=string.sub(shapeid2,-2)
        if shape1==shape2 then
            local sID = "CharacterShiZhuangDlg" .. tostring(index)
            local lyout = winMgr:loadWindowLayout("jueseshizhuangcell.layout",sID);
            self.szlistWnd:addChildWindow(lyout)
            if index2>=3 then
                index2=0
            end
            lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + index2 * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + math.floor(index/3) * (lyout:getHeight().offset))))
            index2=index2+1

            lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."jueseshizhuangcell"));
            lyout.addclick:setID(shizhuang.id)
            lyout.addclick:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handleSzSelected, self)
            lyout.szCell = CEGUI.toItemCell(winMgr:getWindow(sID.."jueseshizhuangcell/touxiang"))
            local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shizhuang.moxing)
            local image = gGetIconManager():GetImageByID(shizhuang.icon)
            lyout.szCell:SetLockState(false)
            lyout.szCell:SetImage(image)
            lyout.szCell:ClearCornerImage(0)
            lyout.szCell:ClearCornerImage(1)
			
			self.m_szCell[i] = lyout.szCell
			

            table.insert(self.m_szList, lyout)
            index = index + 1
        end
    end
end
function CharacterShiZhuangDlg:refreshSzTable2(szList)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    self.m_szList = {}
    local index = 0
    local index2 = 0
	
		self.m_szCell2 = {}

    for k,v in pairs(szList) do
        local shizhuang = BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getRecorder(v)
        local sID = "CharacterShiZhuangDlg" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("jueseshizhuangcell.layout",index);
        self.szlistWnd:addChildWindow(lyout)
        if index2>=3 then
            index2=0
        end
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + index2 * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + math.floor(index/3) * (lyout:getHeight().offset))))
        index2=index2+1

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(index.."jueseshizhuangcell"));
        lyout.addclick:setID(shizhuang.id)
        lyout.addclick:subscribeEvent("MouseButtonUp", CharacterShiZhuangDlg.handleSzSelected2, self)
        lyout.szCell = CEGUI.toItemCell(winMgr:getWindow(index.."jueseshizhuangcell/touxiang"))
        local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shizhuang.moxing)
        local image = gGetIconManager():GetImageByID(shizhuang.icon)
        lyout.szCell:SetLockState(false)
        lyout.szCell:SetImage(image)
        lyout.szCell:ClearCornerImage(0)
        lyout.szCell:ClearCornerImage(1)

		self.m_szCell2[shizhuang.id] = lyout.szCell
		

        table.insert(self.m_szList, lyout)
        index = index + 1
    end
end
function CharacterShiZhuangDlg:handleSzSelected(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()
    local shizhuang = BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getRecorder(idx)
    if shizhuang then
        self:updateShiZhuangSprite(shizhuang.moxing)
        self.select=idx
            self.ItemCellNeedItem1:setVisible(true)
            self.neeItemNameText1:setVisible(true)
            self.neeItemCountText1:setVisible(true)
            local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(shizhuang.cailiao);
            local itemIcon = gGetIconManager():GetItemIconByID(shizhuang.icon)
            self.ItemCellNeedItem1:setVisible(true)
            self.ItemCellNeedItem1:setID(shizhuang.cailiao)
            self.ItemCellNeedItem1:SetImage(itemIcon)
            --self.ItemCellNeedItem1:SetTextUnit(shizhuang.cailiaonum)
            SetItemCellBoundColorByQulityItemWithId(self.ItemCellNeedItem1,shizhuang.cailiao)
            self.neeItemNameText1:setText(item.name)
            local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            local mymoney=roleItemManager:GetItemNumByBaseID(shizhuang.cailiao)
            self.neeItemCountText1:setText(shizhuang.cailiaonum.." / "..mymoney)
			
			clearShiZhuangCellEffects(self.m_szCell)
			if self.m_szCell and self.m_szCell[idx] then
				gGetGameUIManager():AddUIEffect(self.m_szCell[idx], "animation/ui/My_texiao/my_rwsz_sel", true)
			end

    end
end
function CharacterShiZhuangDlg:handleSzSelected2(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()
    local shizhuang = BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getRecorder(idx)
    if shizhuang then
        self:updateShiZhuangSprite(shizhuang.moxing)
        self.select=idx
        self.ItemCellNeedItem1:setVisible(false)
        self.neeItemNameText1:setVisible(false)
        self.neeItemCountText1:setVisible(false)
		
		clearShiZhuangCellEffects(self.m_szCell2)
		if self.m_szCell2 and self.m_szCell2[idx] then
			gGetGameUIManager():AddUIEffect(self.m_szCell2[idx], "animation/ui/My_texiao/my_rwsz_sel", true)
		end

    end
end
function CharacterShiZhuangDlg:handleQuitBtnClicked(e)
if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function CharacterShiZhuangDlg:handleCombineTipClicked0()--衣橱按钮
    --self.DestroyDialog();

    require("logic.ranse.ranselabel").Show(1)--衣橱
	
    --require"logic.workshop.zhuangbeiqh".getInstanceAndShow()
end
function CharacterShiZhuangDlg:handleCombineTipClicked1()--衣橱按钮
    self.DestroyDialog();

	 require("logic.ranse.ranselabel").Show(2)--衣橱
	 
end
function CharacterShiZhuangDlg:handleCombineTipClicked2()--宠物按钮
    self.DestroyDialog();

	 --require("logic.ranse.ranselabel").Show(1)--染色
	 --require("logic.ranse.ranselabel").Show(2)--衣橱
	 require("logic.ranse.ranselabel").Show(3)--宠物染色
	--require"logic.workshop.zhuangbeiqh".getInstanceAndShow()
end
function CharacterShiZhuangDlg:handleCombineTipClicked8()--宠物按钮
     self.DestroyDialog();

	 --require("logic.ranse.ranselabel").Show(1)--染色
	 --require("logic.ranse.ranselabel").Show(2)--衣橱
	 require("logic.ranse.ranselabel").Show(3)--宠物染色
	--require"logic.workshop.zhuangbeiqh".getInstanceAndShow()
end

function CharacterShiZhuangDlg:handleLeftClicked(args)
    self.dir = self.dir + 1;
    if self.dir > 7 then
        self.dir = 0;
    end
    if self.sprite then
		self.sprite:SetUIDirection(self.dir)
	end
    self.leftDown = true;
    self.downTime = 0;
end

function CharacterShiZhuangDlg:handleRightClicked(args)
    self.dir = self.dir - 1;
    if self.dir < 0 then
        self.dir = 7;
    end
    if self.sprite then
		self.sprite:SetUIDirection(self.dir)
	end
	
    self.rightDown = true;
    self.downTime = 0;
end
function CharacterShiZhuangDlg:handleLeftUp(args)
    self.leftDown = false;
end
function CharacterShiZhuangDlg:handleRightUp(args)
    self.rightDown = false;
end

function CharacterShiZhuangDlg:OnClose()
	if self.sprite then
		if self.spriteOwner == "ui_sprite" then
			pcall(function() self.sprite:delete() end)
		end
		self.sprite = nil
        self.spriteOwner = nil
	end
	self.m_szCell = nil
	self.m_szCell2 = nil
	Dialog.OnClose(self)
end
return CharacterShiZhuangDlg
