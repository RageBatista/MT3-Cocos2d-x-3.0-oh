local Dialog = require "logic.dialog"

local ZongHePingFenDlg = {}
setmetatable(ZongHePingFenDlg, Dialog)
ZongHePingFenDlg.__index = ZongHePingFenDlg 

ZongHePingFenDlg.curData = nil

local JEWELRY = 6

local function GetSecondType(typeid)
    local n = math.floor(typeid / 0x10)
    return n % 0x10
end

local _instance
function ZongHePingFenDlg.getInstance()
    if not _instance then
        _instance = ZongHePingFenDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function ZongHePingFenDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = ZongHePingFenDlg:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function ZongHePingFenDlg.getInstanceNotCreate()
    return _instance
end

function ZongHePingFenDlg.DestroyDialog()
    ZongHePingFenDlg.curData = nil 
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZongHePingFenDlg.ToggleOpenClose()
    if not _instance then 
        _instance = ZongHePingFenDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ZongHePingFenDlg.GetLayoutFileName()
    return "zonghepingfen.layout"
end

function ZongHePingFenDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZongHePingFenDlg)

    return self
end

function ZongHePingFenDlg:OnCreate(parent)
    Dialog.OnCreate(self,parent,1)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- ��ɫ��Ϣ

    self.txtSkillScore = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/skillscore")
    self.txtPlayerScore = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/rolescore1")
    self.txtLevelScore = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/levelscore")
    self.txtPetScore = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/petscore")
    self.txtZonghescore = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/zonghescore")	
    self.txtRank = winMgr:getWindow(tostring(1).."zonghepingfen1/rank/text")
    self.m_TipsButton = CEGUI.toPushButton(winMgr:getWindow(tostring(1).."zonghepingfen1/tips"))
    self.m_TipsButton:subscribeEvent("Clicked", ZongHePingFenDlg.HandleImageButtonClick, self)
    -- װ����

    self.txtRoleName = winMgr:getWindow(tostring(1).."zonghepingfen1/rolename")
    self.txtJewelryScore = winMgr:getWindow(tostring(1).."zonghepingfen1/ring")

    self.SpriteWnd = winMgr:getWindow(tostring(1).."zonghepingfen1/spriteBack")
    self.EffeectWnd = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/SpriteEffectTop")

    self.vEquip = {}
    self.vEquip[eEquipType_ADORN] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/adorn"))
    self.vEquip[eEquipType_ARMS] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/arms"))
    --self.vEquip[eEquipType_CUFF] = nil --CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/cuff"))
    self.vEquip[eEquipType_WAISTBAND] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/waistband"))
    self.vEquip[eEquipType_TIRE] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/tire"))
    --self.vEquip[eEquipType_CLOAK] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/cloak"))
    self.vEquip[eEquipType_LORICAE] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/loricae"))
    self.vEquip[eEquipType_BOOT] = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/boot"))
    --self.vEquip[eEquipType_EYEPATCH] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/extern01"))
    --self.vEquip[eEquipType_RESPIRATOR] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."zonghepingfen1/extern02"))
    --self.vEquip[eEquipType_VEIL] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/extern03"))
    --self.vEquip[eEquipType_FASHION] = nil;--CEGUI.toItemCell(winMgr:getWindow(tostring(1).."listdengjiview/extern04"))
    
    --self.vEquip[eEquipType_CUFF]:SetBackGroundImage("ccui1","kuang2")
    self.vEquip[eEquipType_ADORN]:SetBackGroundImage("ccui1","kuang2")
    self.vEquip[eEquipType_LORICAE]:SetBackGroundImage("ccui1","kuang2")
    self.vEquip[eEquipType_ARMS]:SetBackGroundImage("ccui1","kuang2")
    self.vEquip[eEquipType_TIRE]:SetBackGroundImage("ccui1","kuang2")
    --self.vEquip[eEquipType_CLOAK]:SetBackGroundImage("ccui1","kuang2")
    self.vEquip[eEquipType_BOOT]:SetBackGroundImage("ccui1","kuang2")
    --self.vEquip[eEquipType_WAISTBAND]:SetBackGroundImage("ccui1","kuang2")
    --self.vEquip[eEquipType_EYEPATCH]:SetBackGroundImage("ccui1","kuang2")
    --self.vEquip[eEquipType_RESPIRATOR]:SetBackGroundImage("ccui1","kuang2")

    for i = 0, 9 do
        if self.vEquip[i] ~= nil then
            self.vEquip[i]:subscribeEvent("TableClick", ZongHePingFenDlg.HandleItemClick, self)
        end
    end
		
	local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow(tostring(1).."zonghepingfen1"))
	self.CloseBtn = CEGUI.toPushButton(frameWnd:getCloseButton())
	self.CloseBtn:subscribeEvent("MouseClick", ZongHePingFenDlg.HandleQuitClick, self)
	
	self.SeeButton = CEGUI.toPushButton(winMgr:getWindow(tostring(1).."zonghepingfen1/chakan"))
	self.SeeButton:subscribeEvent("Clicked", ZongHePingFenDlg.HandleButtonClick, self)

    self.m_ZhiyeText =winMgr:getWindow(tostring(1).."zonghepingfen1/Back/Pattern/zhiyexianshi")
    self.m_LevelText = winMgr:getWindow(tostring(1).."zonghepingfen1/Back/Pattern/dengjixianshi")

    self.m_imgSchool = winMgr:getWindow(tostring(1).."zonghepingfen1/zhiyebiashi")
    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(self.curData.school)
    self.m_imgSchool:setProperty("Image", schoolConfig.schooliconpath)

end
function ZongHePingFenDlg:HandleImageButtonClick(args)
if not self.m_Number then
return
end
    local tips1 = require "logic.workshop.tips1"
    local strTitle = MHSD_UTILS.get_resstring(11396)
    local strContent = MHSD_UTILS.get_resstring(11395)
    strContent  = string.gsub(strContent,"%$parameter1%$",tostring(self.m_Number))
    if tips1.getInstanceNotCreate() == nil then
        local dlg =  tips1.getInstanceAndShow(strContent, strTitle)
        if dlg then
            SetPositionScreenCenter(dlg:GetWindow())
        end
    else
        -- ���������ı��Ϳ�����.
        tips1.getInstanceNotCreate():RefreshData(strContent, strTitle)
    end
end
function ZongHePingFenDlg:HandleQuitClick(e)
	
	ZongHePingFenDlg.DestroyDialog();
	
end

function ZongHePingFenDlg:HandleButtonClick(args)
	local e = CEGUI.toWindowEventArgs(args)
	if e.window == self.SeeButton then
		local roleID = self.curData.roleid
		if gGetFriendsManager() then
			gGetFriendsManager():SetContactRole(roleID, true)
		end
	end
end

function ZongHePingFenDlg:RefreshView()
    if ZongHePingFenDlg.curData == nil then
        LogErr("ZongHePingFenDlg.curData is nil in ZongHePingFenDlg:RefreshView")
        return
    end
     local level  =  ZongHePingFenDlg.curData.level
     if ZongHePingFenDlg.curData.level>1000 then
        local zscs,t2 = math.modf(ZongHePingFenDlg.curData.level/1000)
        level = ZongHePingFenDlg.curData.level-zscs*1000
     end
     local data = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level)
     self.m_Number = data.petfightnum
     --petfightnum
    -- ���ý�ɫ��Ϣ

    self.txtSkillScore:setText(ZongHePingFenDlg.curData.skillscore)
    self.txtLevelScore:setText(tostring(ZongHePingFenDlg.curData.levelscore)) --�������� by changhao
    self.txtRoleName:setText(ZongHePingFenDlg.curData.rolename) --��ɫ�� by changhao
    self.txtPetScore:setText(ZongHePingFenDlg.curData.manypetscore) --���� by changhao
    self.txtZonghescore:setText(ZongHePingFenDlg.curData.totalscore) --�������� by changhao	

    self.txtRank:setText(tostring(ZongHePingFenDlg.curData.rank+1))
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(ZongHePingFenDlg.curData.school)
    if schoolName.id~=-1 then
     self.m_ZhiyeText:setText(schoolName.name)
    end
    local rolelv = ""..ZongHePingFenDlg.curData.level
    if ZongHePingFenDlg.curData.level>1000 then
        local zscs,t2 = math.modf(ZongHePingFenDlg.curData.level/1000)
        rolelv = zscs..""..(ZongHePingFenDlg.curData.level-zscs*1000)
    end
    self.m_LevelText:setText(tostring(rolelv))
    
    local shape = 0
    if ZongHePingFenDlg.curData.shape > 20 then
        shape=ZongHePingFenDlg.curData.shape
    else
        shape=ZongHePingFenDlg.curData.shape + 1010100 + 1000
    end
	
    local roleSprite = gGetGameUIManager():AddWindowSprite(self.SpriteWnd, shape, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, false)

   -- roleSprite:SetUIScale(2.0)
    -- ����װ����

    local totalscore = 10;
	self.txtPlayerScore:setText(ZongHePingFenDlg.curData.rolescore)	
	
    local jewelryscore = 0

    self.vID = {}

    for i, v in pairs(ZongHePingFenDlg.curData.baginfo.items) do
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.id)
        if  self.vEquip[v.position] ~= nil then
            self.vEquip[v.position]:setID(v.key)
            if itemattr then
                self.vEquip[v.position]:SetImage(gGetIconManager():GetItemIconByID(itemattr.icon))
            end
        end
        self.vID[v.key] = v.id

        -- ��ģ������������
        if v.position == eEquipType_ARMS then
            roleSprite:SetSpriteComponent(eSprite_Weapon, v.id)
        end

       
        
    end

    for i, v in pairs(ZongHePingFenDlg.curData.components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            roleSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            roleSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            roleSprite:UpdateWeaponColorParticle(v)      
        end
    end
    if ZongHePingFenDlg.curData.components[60] then
        self:checkEquipEffect(roleSprite, ZongHePingFenDlg.curData.components[60])
    end
    
    
    if gGetDataManager() then
        local nMyRoleId = gGetDataManager():GetMainCharacterID()
        if ZongHePingFenDlg.curData.roleid ==  nMyRoleId then
            self.SeeButton:setVisible(false)
        end
    end

end

function ZongHePingFenDlg:checkEquipEffect(roleSprite, quality)
    if quality ~= 0 then
        if quality>10 then
			quality= 10
		end
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
        if record.effectId ~= 0 then
            local effect = roleSprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(record.effectId), false);
            effect:SetScale(1,1)
        end
    end
end

function ZongHePingFenDlg:HandleItemClick(args)

end

return ZongHePingFenDlg
