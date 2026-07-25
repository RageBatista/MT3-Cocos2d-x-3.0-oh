local Dialog = require "logic.dialog"

local RankLevelViewDlg = {}
setmetatable(RankLevelViewDlg, Dialog)
RankLevelViewDlg.__index = RankLevelViewDlg 

RankLevelViewDlg.curData = nil

local JEWELRY = 6

local function GetSecondType(typeid)
    local n = math.floor(typeid / 0x10)
    return n % 0x10
end

local _instance
function RankLevelViewDlg.getInstance()
    if not _instance then
        _instance = RankLevelViewDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankLevelViewDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = RankLevelViewDlg:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function RankLevelViewDlg.getInstanceNotCreate()
    return _instance
end

function RankLevelViewDlg.DestroyDialog()
    RankLevelViewDlg.curData = nil 
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RankLevelViewDlg.ToggleOpenClose()
    if not _instance then 
        _instance = RankLevelViewDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function RankLevelViewDlg.GetLayoutFileName()
    return "listdengjiview.layout"
end

function RankLevelViewDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RankLevelViewDlg)

    return self
end

function RankLevelViewDlg:OnCreate(parent)
    Dialog.OnCreate(self,parent,1)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 角色信息

    self.txtSkillScore = winMgr:getWindow(tostring(1).."listdengjiview/Back/skillscore")
    self.txtEquipScore = winMgr:getWindow(tostring(1).."listdengjiview/Back/equipscore")
    self.txtLevelScore = winMgr:getWindow(tostring(1).."listdengjiview/Back/levelscore")
    self.txtXiulian = winMgr:getWindow(tostring(1).."listdengjiview/Back/xiulianscore")
    self.txtRolescore = winMgr:getWindow(tostring(1).."listdengjiview/Back/rolescore")	
    self.txtRank = winMgr:getWindow(tostring(1).."listdengjiview/rank/text")

    -- 装备栏

    self.txtRoleName = winMgr:getWindow(tostring(1).."listdengjiview/rolename")
    self.txtJewelryScore = winMgr:getWindow(tostring(1).."listdengjiview/ring")

    self.SpriteWnd = winMgr:getWindow(tostring(1).."listdengjiview/spriteBack")
    self.EffeectWnd = winMgr:getWindow(tostring(1).."listdengjiview/Back/SpriteEffectTop")

    self.schoolIcon = winMgr:getWindow(tostring(1).."listdengjiview/zhiyebiaoshi")

    self.vEquip = {}
    self.vEquip[eEquipType_ADORN] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/adorn"))
    self.vEquip[eEquipType_ARMS] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/arms"))
    --self.vEquip[eEquipType_CUFF] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/cuff"))
    self.vEquip[eEquipType_WAISTBAND] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/waistband"))
    self.vEquip[eEquipType_TIRE] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/tire"))
    --self.vEquip[eEquipType_CLOAK] = nil;-- CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/cloak"))
    self.vEquip[eEquipType_LORICAE] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/loricae"))
    self.vEquip[eEquipType_BOOT] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/boot"))
    --self.vEquip[eEquipType_EYEPATCH] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/extern01"))
    --self.vEquip[eEquipType_RESPIRATOR] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/extern02"))
    --self.vEquip[eEquipType_VEIL] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/extern03"))
    --self.vEquip[eEquipType_FASHION] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/extern04"))

    for i = 0, 9 do
        if self.vEquip[i] ~= nil then
            self.vEquip[i]:subscribeEvent("TableClick", RankLevelViewDlg.HandleItemClick, self)
        end
    end
	
	self.SeeButton = CEGUI.toPushButton(winMgr:getWindow(tostring(1).."listdengjiview/chakan"))
	self.SeeButton:subscribeEvent("Clicked", RankLevelViewDlg.HandleButtonClick, self)
	
	local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow(tostring(1).."listdengjiview"))
	self.CloseBtn = CEGUI.toPushButton(frameWnd:getCloseButton())
	self.CloseBtn:subscribeEvent("MouseClick", RankLevelViewDlg.HandleQuitClick, self)


    self.m_ZhiyeText =winMgr:getWindow(tostring(1).."listdengjiview/Back/Pattern/zhiyexianshi")
    self.m_LevelText = winMgr:getWindow(tostring(1).."listdengjiview/Back/Pattern/dengjixianshi")
end

function RankLevelViewDlg:HandleQuitClick(e)
	
	RankLevelViewDlg.DestroyDialog();
	
end

function RankLevelViewDlg:HandleButtonClick(args)
	
    local e = CEGUI.toWindowEventArgs(args)
	if e.window == self.SeeButton then
		
		dlg = ContactRoleDialog.getInstanceAndShow()
	
		if dlg then

			local roleHeadID = 0
			local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(self.curData.shape)
			
			if shapeConf.id ~= -1 then
				roleHeadID = shapeConf.littleheadID
			end
			
			local roleID = self.curData.roleid;
			local roleName = self.curData.rolename;
			local roleLevel = self.curData.level;
			local roleCamp = self.curData.camp;
		
			dlg:SetCharacter(roleID,roleName,roleLevel,roleCamp,roleHeadID,self.curData.school, 0, self.curData.factionname)				
			
		end		
		
	end
	
end

function RankLevelViewDlg:checkEquipEffect(roleSprite, quality)
    if quality ~= 0 then
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
        if record.effectId ~= 0 then
            local effect = roleSprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(record.effectId), false)
            effect:SetScale(2,2)
        end
    end
end

function RankLevelViewDlg:RefreshView()
    if RankLevelViewDlg.curData == nil then
        LogErr("RankLevelViewDlg.curData is nil in RankLevelViewDlg:RefreshView")
        return
    end

    -- 设置角色信息

    self.txtSkillScore:setText(RankLevelViewDlg.curData.skillscore)
    self.txtLevelScore:setText(tostring(RankLevelViewDlg.curData.levelscore)) --技能评分 by changhao
    self.txtRoleName:setText(RankLevelViewDlg.curData.rolename) --角色名 by changhao
    self.txtXiulian:setText(RankLevelViewDlg.curData.xiulianscore) --公会（门-派） by changhao
    self.txtRolescore:setText(RankLevelViewDlg.curData.rolescore) --人物评分 by changhao	

    self.txtRank:setText(tostring(RankLevelViewDlg.curData.rank+1))
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(RankLevelViewDlg.curData.school)
    self.schoolIcon:setProperty("Image", schoolName.schooliconpath)
    if schoolName.id~=-1 then
     self.m_ZhiyeText:setText(schoolName.name)
    end
    self.m_LevelText:setText(tostring(RankLevelViewDlg.curData.level))
	
    local shape=RankLevelViewDlg.curData.shape
    if shape<3000000 then
        shape=shape + 1010100 + 1000
    end

    local roleSprite = gGetGameUIManager():AddWindowSprite(self.SpriteWnd,  shape, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, false)
    self:checkEquipEffect(roleSprite, RankLevelViewDlg.curData.components[60])
    -- 设置装备栏

    local totalscore = 17;
	self.txtEquipScore:setText(RankLevelViewDlg.curData.equipscore)	
	
    local jewelryscore = 0

    self.vID = {}

    for i, v in pairs(RankLevelViewDlg.curData.baginfo.items) do
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.id)
        if self.vEquip[v.position] ~= nil then
            self.vEquip[v.position]:setID(v.key)
            if itemattr then
                self.vEquip[v.position]:SetImage(gGetIconManager():GetItemIconByID(itemattr.icon))
            end
        end
        self.vID[v.key] = v.id

        -- 在模型上添加武器
        if v.position == eEquipType_ARMS then
            roleSprite:SetSpriteComponent(eSprite_Weapon, v.id)
        end
    end
    
    for i, v in pairs(RankLevelViewDlg.curData.components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            roleSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            roleSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            roleSprite:UpdateWeaponColorParticle(v)      
        end
    end
    if RankLevelViewDlg.curData.components[60] then
        self:checkEquipEffect(roleSprite, RankLevelViewDlg.curData.components[60])
    end

    if gGetDataManager() then
        local nMyRoleId = gGetDataManager():GetMainCharacterID()
        if RankLevelViewDlg.curData.roleid ==  nMyRoleId then
            self.SeeButton:setVisible(false)
        end
    end
     
    
    
end

function RankLevelViewDlg:HandleItemClick(args)

end

return RankLevelViewDlg
