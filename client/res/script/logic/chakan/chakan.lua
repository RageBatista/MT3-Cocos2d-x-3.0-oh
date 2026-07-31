require "logic.dialog"

ChaKan = { }
setmetatable(ChaKan, Dialog)
ChaKan.__index = ChaKan

local _instance
function ChaKan.getInstance()
    if not _instance then
        _instance = ChaKan:new()
        _instance:OnCreate()
    end
    return _instance
end

function ChaKan.getInstanceAndShow()
    if not _instance then
        _instance = ChaKan:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function ChaKan.getInstanceNotCreate()
    return _instance
end

function ChaKan.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ChaKan.ToggleOpenClose()
    if not _instance then
        _instance = ChaKan:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ChaKan.GetLayoutFileName()
    return "chakan_mtg.layout"
end

function ChaKan:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, ChaKan)
    return self
end

function ChaKan:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_ViewPetBtn = CEGUI.toPushButton(winMgr:getWindow("chakan_mtg/btn1"))
    self.m_Equip1 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/tou"))
    self.m_Equip2 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/wuqi"))
    self.m_Equip3 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/yaodai"))
    self.m_Equip4 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/xinghuang"))
    self.m_Equip5 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/xianglian"))
    self.m_Equip6 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/kaijia"))
    self.m_Equip7 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/xiezi"))
    self.m_Equip8 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/extern01"))
    self.m_Equip9 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/jinjia"))
    self.m_Equip10 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/doupeng"))
    self.m_Equip11 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/zuoqi"))
	self.m_Equip12 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/feijian"))---chakan_mtg/fengdai
	self.m_Equip13 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/fengdai"))
	self.m_Equip14 = CEGUI.toItemCell(winMgr:getWindow("chakan_mtg/chongwufb"))
    self.m_ZhiYe = winMgr:getWindow("chakan_mtg/ditu/name1")
    self.m_Score = winMgr:getWindow("chakan_mtg/ditu/pingfen1")
    self.m_Close = CEGUI.toPushButton(winMgr:getWindow("chakan_mtg/X"))
    self.m_Close:subscribeEvent("Clicked", ChaKan.OnClickedClose, self)
    self.m_ViewPetBtn:subscribeEvent("Clicked", ChaKan.OnClickedViewPet, self)
    self.SpriteWnd = winMgr:getWindow("chakan_mtg/ditu/yinying")
    self.m_ZhiYeIcon = winMgr:getWindow("chakan_mtg/ditu/name")
    self.m_LevelText  = winMgr:getWindow("chakan_mtg/ditu/dengji2")
    

    self.PosTable =
    {
        [0] = self.m_Equip2,
        [1] = nil,
        [2] = self.m_Equip5,
        [3] = self.m_Equip6,
        [4] = self.m_Equip3,
        [5] = self.m_Equip7,
        [6] = self.m_Equip1,
        [7] = self.m_Equip4,
        [8] = self.m_Equip8,
        [12] = self.m_Equip9,
        [14] =self.m_Equip10,
        [16] = self.m_Equip11,
		[15] = self.m_Equip12,
		[13] = self.m_Equip13,
		[9] = self.m_Equip14,
    }
   
   self:GetWindow():setRiseOnClickEnabled(false)

end
function ChaKan:OnClickedViewPet(args)
    local p = require("protodef.fire.pb.item.cgetrolepetinfo"):new()
    p.roleid = self.m_Data.roleid
    LuaProtocolManager:send(p)
end
-- ���cell
function ChaKan:HandleCellClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    local id2 = CEGUI.toWindowEventArgs(args).window:getID2()
    local p = require("protodef.fire.pb.item.cotheritemtips"):new()
    p.roleid = self.m_Data.roleid
    p.packid = fire.pb.item.BagTypes.EQUIP
    p.keyinpack = id
    LuaProtocolManager:send(p)

    local pos = CEGUI.toWindowEventArgs(args).window:GetScreenPosOfCenter()
    local roleItem = RoleItem:new()
    roleItem:SetItemBaseData(id2, 0)
    roleItem:SetObjectID(id2)
    local tip = Commontiphelper.showItemTip(id2, roleItem:GetObject(), true, false, pos.x, pos.y)
    tip.roleid = self.m_Data.roleid
    tip.roleItem = roleItem
    tip.itemkey = id

end

function ChaKan:OnClickedClose(args)
    self:DestroyDialog()
end

function ChaKan:checkEquipEffect(roleSprite, quality)
    if quality ~= 0 then
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
        if record.effectId ~= 0 then
            self.m_pPackEquipEffect = roleSprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(record.effectId), false);
            if self.m_pPackEquipEffect then
                self.m_pPackEquipEffect:SetScale(2,2)
            end
        end
    end
end

function ChaKan:RefreshData(prag)
    -- ����ֵ
    self.m_Data = prag
    if not self.m_Data then
        return
    end
    if not self.m_Data.equipinfo then
        return
    end
    local equips = self.m_Data.equipinfo.items
    -- ˢ��װ����ʾ
    for k, v in pairs(equips) do
        if v then
            local info = self.PosTable[v.position]
            if info then
                -- ����ͼƬ
                local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.id)
                if itemattr then
                    info:SetImage(gGetIconManager():GetItemIconByID(itemattr.icon))
                    info:setID(v.key)
                    info:setID2(v.id)
                    SetItemCellBoundColorByQulityItem(info, itemattr.nquality)
                    info:subscribeEvent("TableClick", self.HandleCellClicked, self)
                end
            end
        end
    end


    -- ����
    if self.SpriteWnd then
        local shape=self.m_Data.shape
        if shape<3000000 then
            shape= shape+ 1011100
        end
        local roleSprite = gGetGameUIManager():AddWindowSprite(self.SpriteWnd,shape, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, false)
       -- roleSprite:SetUIScale(1.5)
        for i, v in pairs(self.m_Data.components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            roleSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            roleSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            roleSprite:UpdateWeaponColorParticle(v)
        end
        if self.m_Data.components[60] then -- ��װ��Ч
            self:checkEquipEffect(roleSprite, self.m_Data.components[60])
        end
    end
    end

    -- �ۺ�����
    if self.m_Score then
        self.m_Score:setText(tostring(self.m_Data.totalscore))
    end

    -- ����
    if self.m_ZhiYe then
        self.m_ZhiYe:setText(tostring(self.m_Data.rolename))
    end

    if self.m_ZhiYeIcon then
        -- ְҵ
        local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(self.m_Data.profession)
        if schoolName then
            self.m_ZhiYeIcon:setProperty("Image", schoolName.schooliconpath)
        end
    end

    if self.m_LevelText then
    self.m_LevelText:setText(tostring(self.m_Data.rolelevel))
    end

end



return ChaKan
