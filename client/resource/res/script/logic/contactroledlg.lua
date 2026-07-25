require "protodef.fire.pb.item.cgetroleinfo"
require "protodef.fire.pb.friends.ccamppk"

ContactRoleDialog = { }
setmetatable(ContactRoleDialog, Dialog)
ContactRoleDialog.__index = ContactRoleDialog 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ContactRoleDialog.getInstance()
    print("enter ContactRoleDialog")
    if not _instance then
        _instance = ContactRoleDialog:new()
        _instance:OnCreate()
    end

    return _instance
end

function ContactRoleDialog.getInstanceAndShow()
    print("enter instance show")
    if not _instance then
        _instance = ContactRoleDialog:new()
        _instance:OnCreate()
    else
        print("set visible")
        _instance:SetVisible(true)
    end

    return _instance
end

function ContactRoleDialog.getInstanceNotCreate()
    return _instance
end



function ContactRoleDialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ContactRoleDialog.ToggleOpenClose()
    if not _instance then
        _instance = ContactRoleDialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end
----/////////////////////////////////////////------

function ContactRoleDialog.GetLayoutFileName()
    return "contactcharacter.layout"
end

function ContactRoleDialog:OnCreate()
    print("enter ContactRoleDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_Name = winMgr:getWindow("ContactCharacter/Name")
    self.m_ChatBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/Chat"))
    self.m_AddOrRemoveFriendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/Friend"))
    self.m_TeamBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/Jointeam"))
    self.m_FactionInviteBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/FamilyInvite")) -- 申请入会 / 邀请入会
    self.m_ViewBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/View"))
    self.m_RoleID = winMgr:getWindow("ContactCharacter/id")
    self.m_CampPK = winMgr:getWindow("ContactCharacter/camppk")
    self.m_pCampPic = winMgr:getWindow("ContactCharacter/camp")
	self.m_JuBaoBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/jubao"))

	self.spriteBack = winMgr:getWindow("ContactCharacter/ckc1/ccmoxing")---新增加模型读取


    self.m_familyName = winMgr:getWindow("ContactCharacter/gonghui1")

    self.m_btnSpace = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/kongjian")) 
    self.m_btnSpace:subscribeEvent("MouseClick", ContactRoleDialog.HandleClickSpace, self)

    self.m_pHeadIcon = winMgr:getWindow("ContactCharacter/touxiangkuang/touxiang")
    self.m_pSchoolIcon = winMgr:getWindow("ContactCharacter/tubiao")
    self.m_pSchoolName = winMgr:getWindow("ContactCharacter/zhiye")
    self.m_level = winMgr:getWindow("ContactCharacter/touxiangkuang/level")

    self.m_btnSendFlower = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/flower"))
    self.m_btnSendFlower:subscribeEvent("Clicked", ContactRoleDialog.HandleClickSendFlowerBtn, self)

    self.m_ChatBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickChatBtn, self)
    self.m_AddOrRemoveFriendBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickAddOrRemoveFriendBtn, self)

    self.m_TeamBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickTeamBtn, self)
    self.m_FactionInviteBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickFactionInviteBtn, self) -- 申请入会 / 邀请入会
    self.m_ViewBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickViewBtn, self)
    self.m_CampPK:subscribeEvent("Clicked", ContactRoleDialog.HandleCampPKBtn, self)

    self.m_pkBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ContactCharacter/pk"))
    self.m_pkBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickPKBtn, self)

	--举报按钮
	self.m_JuBaoBtn:subscribeEvent("Clicked", ContactRoleDialog.HandleClickJuBaoBtn, self)

    -- init settings
    self.m_CharacterRoleID = 0
    self.m_CharacterName = ""
    self.m_TeamState = -1


    print("exit ContactRoleDialog OnCreate")
end

------------------- private: -----------------------------------

function ContactRoleDialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, ContactRoleDialog)

    return self
end

--function ContactRoleDialog:SetCharacter(roleID, roleName, roleLevel, roleCamp, roleHeadID, roleSchool, roleFactionID, roleFactionName)
function ContactRoleDialog:SetCharacter(roleID, roleName, roleLevel, roleCamp, roleHeadID, roleSchool, roleFactionID, roleFactionName,shapeId,weaponid)
 
 print("ContactRoleDialog:SetCharacter")
    self.m_CharacterRoleID = roleID
    self.m_CharacterName = roleName
    self.m_CharacterLevel = roleLevel
    self.m_CharacterCamp = roleCamp
    self.m_CharacterFactionID = roleFactionID
    self.m_CharacterRoleSchool = roleSchool
    self.m_CharacterRoleHeadID = roleHeadID

     -- 申请入会 / 邀请入会
    if self.m_CharacterFactionID > 0 then
        self.m_FactionInviteBtn:setText(MHSD_UTILS.get_resstring(2739)) -- 申请入会
    end
    if roleFactionName ~= "" then
        self.m_familyName:setText(roleFactionName)
    end
    self.m_Name:setText(roleName)
    if roleID == -1 then
        self.m_RoleID:setText(MHSD_UTILS.get_resstring(2846))
    else
        self.m_RoleID:setText(tostring(roleID))
    end
    self.m_level:setText(tostring(roleLevel))
    if roleCamp == 1 then
        self.m_pCampPic:setProperty("Image", "set:common image:common_biaoshi_cc")
        self.m_pCampPic:setVisible(true)
    elseif roleCamp == 2 then
        self.m_pCampPic:setProperty("Image", "set:common image:common_biaoshi_cc")
        self.m_pCampPic:setVisible(true)
    else
        self.m_pCampPic:setVisible(false)
    end

    if gGetFriendsManager():isMyFriend(roleID) then
        self.m_AddOrRemoveFriendBtn:setText(MHSD_UTILS.get_resstring(2741))
    else
        self.m_AddOrRemoveFriendBtn:setText(MHSD_UTILS.get_resstring(2742))
    end

    self.m_TeamState = -1

    local character = gGetScene():FindCharacterByID(self.m_CharacterRoleID)
    if character then
        if GetTeamManager():IsOnTeam() then
            self.m_TeamState = 0
            self.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2738))
            -- 邀请入队
        elseif (character:IsOnTeam()) then
            self.m_TeamState = 1
            self.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2740))
            -- 申请入队
        else
            self.m_TeamState = 0
            self.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2738))
            -- 邀请入队
        end

        if (character:IsInBattle()) then
            self.m_pkBtn:setText(MHSD_UTILS.get_resstring(2810));
        else
            self.m_pkBtn:setText(MHSD_UTILS.get_resstring(2809));
        end
    else

        if self.m_CharacterRoleID > 0 then
            local p = require("protodef.fire.pb.creqroleteamstate"):new()
            p.roleid = self.m_CharacterRoleID
	        LuaProtocolManager:send(p)
        end
    end

    local headPath = gGetIconManager():GetImagePathByID(roleHeadID):c_str()
    self.m_pHeadIcon:setProperty("Image", headPath)

    local schoolConf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(roleSchool)
    if schoolConf then
        self.m_pSchoolIcon:setProperty("Image", schoolConf.schooliconpath)
        self.m_pSchoolName:setText(schoolConf.name)
    end

    if gGetDataManager():GetMainCharacterID() == self.m_CharacterRoleID then
        self.m_btnSendFlower:setEnabled(false)
		self.m_JuBaoBtn:setEnabled(false)
    end
	    if shapeId then
        if not self.sprite then
            self.spriteBack:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, ContactRoleDialog.performPostRenderFunctions))
            local pos = self.spriteBack:GetScreenPosOfCenter()
            local loc = Nuclear.NuclearPoint(pos.x, pos.y)
            self.sprite = UISprite:new(tonumber(shapeId))
            self.sprite:SetUILocation(loc)
            self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)

            local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
            local psA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
            local psB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
			self.sprite:SetSpriteComponent(eSprite_Weapon, weapon)
            self.sprite:SetDyePartIndex(0, psA)
            self.sprite:SetDyePartIndex(1, psB)
            self.sprite:SetUIScale(1.0)
        elseif self.sprite:GetModelID() ~= shapeId then
            self.sprite:SetModel(shapeId)
        end
    end
end

function ContactRoleDialog.performPostRenderFunctions(id)
	local instance = ContactRoleDialog.getInstanceNotCreate()
	if not instance then
		return
	end

	if instance.sprite then
		instance.sprite:RenderUISprite()
	end
end

function ContactRoleDialog.GlobalSetCharacter()
    print("ContactRoleDialog.GlobalSetCharacter")
    local dlg = nil
    if gGetDataManager():GetMainCharacterLevel() > 0 then
        dlg = ContactRoleDialog.getInstanceAndShow()
    else
        GetCTipsManager():AddMessageTipById(145677)
        -- new add 应策划要求不提示不限制
        return
    end
    if dlg then
        local roleID = gGetFriendsManager():GetWantToContactRoleID()
        local roleInf = gGetFriendsManager():GetContactRole(roleID)
        local roleHeadID = 0
        local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(roleInf.shape)
        if shapeConf then
            roleHeadID = shapeConf.littleheadID
        end
      --  dlg:SetCharacter(roleID, roleInf.name, roleInf.rolelevel, roleInf.camp, roleHeadID, roleInf.school, roleInf.factionID, roleInf.factionName)
        dlg:SetCharacter(roleID, roleInf.name, roleInf.rolelevel, roleInf.camp, roleHeadID, roleInf.school, roleInf.factionID, roleInf.factionName,roleInf.shape,shapeConf.showWeaponId) ----修改
        
		dlg:ResetWndPositon()
    end
end
function ContactRoleDialog:ResetWndPositon()
    --[[local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()

    local tw = self:GetWindow():getPixelSize().width
    local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width

    local x = mousePos.x
    if mousePos.x + tw > pw then

        x = mousePos.x - tw
    end

    local th = self:GetWindow():getPixelSize().height
    local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
    local y = mousePos.y
    if (mousePos.y + th > ph) then

        y = mousePos.y - th
    end

    if x < 0.0 then
        x = 0.0
    end

    if y < 0.0 then
        y = 0.0
    end

    self:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, x), CEGUI.UDim(0.0, y)))]]
end

function ContactRoleDialog.WndPosForChat()
    local win = ContactRoleDialog.getInstance()
    if win and win:GetWindow() then
        win:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, 725), CEGUI.UDim(0.0, 50)))
    end
end

function ContactRoleDialog:HandleClickSendFlowerBtn(args)

    if self.m_CharacterRoleID and self.m_CharacterRoleID > 0 then
         local sendgift = require "logic.friend.sendgiftdialog".getInstanceAndShow()
         gGetFriendsManager():SetContactRole(self.m_CharacterRoleID, true)
         sendgift:insertCharacterWithParams(self.m_CharacterRoleID, self.m_CharacterName, self.m_CharacterLevel, self.m_CharacterRoleSchool, self.m_CharacterRoleHeadID)
         sendgift:createContactList(self.m_CharacterRoleID)
         local tipDlg = ContactRoleDialog.getInstanceNotCreate()
         if tipDlg then
            tipDlg:DestroyDialog()
         end

    end
end

function  ContactRoleDialog:HandleClickSpace(args)
    local nnRoleId = self.m_CharacterRoleID
    local nLevel = self.m_CharacterLevel
    local spManager = require("logic.space.spacemanager").getInstance()
    spManager:openSpace(nnRoleId,nLevel)

    self:DestroyDialog()
end

function ContactRoleDialog:HandleClickJuBaoBtn(args)
	local roleID = gGetFriendsManager():GetWantToContactRoleID()
	local tmp = RoleAccusation.getInstanceAndShow()
	tmp:Init(roleID, self.m_CharacterName)
	

	self:DestroyDialog()
end

function ContactRoleDialog:HandleClickChatBtn(args)
    print("ContactRoleDialog:HandleClickChatBtn")
    if self.m_CharacterRoleID == gGetDataManager():GetMainCharacterID() then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(166006))
        return true
    end

	--yangbin  close chat dialog
	if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():ToHide()
    end
    gGetFriendsManager():RequestSetChatRoleID(self.m_CharacterRoleID)
    self:DestroyDialog()

    local spaceDlg = require("logic.space.spacelabel").getInstanceNotCreate()
    if spaceDlg then
        spaceDlg:OnClose()
    end

    return true
end

function ContactRoleDialog:HandleClickAddOrRemoveFriendBtn(args)
    print("ContactRoleDialog:HandleClickAddOrRemoveFriendBtn")
    if self.m_CharacterRoleID == gGetDataManager():GetMainCharacterID() then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(166006))
        return true
    end

    if gGetFriendsManager():isMyFriend(self.m_CharacterRoleID) then
        gGetFriendsManager():RequestBreakFriendRelation(self.m_CharacterRoleID)
    else
        gGetFriendsManager():RequestAddFriend(self.m_CharacterRoleID)
    end

    self:DestroyDialog()

    return true
end

function ContactRoleDialog:HandleClickTeamBtn(args)
    print("ContactRoleDialog:HandleClickTeamBtn")
    if self.m_TeamState == 1 then

        if GetTeamManager():IsOnTeam() then
            GetCTipsManager():AddMessageTipById(140855)
        else
            GetTeamManager():RequestJoinOneTeam(self.m_CharacterRoleID)
        end
    else

        GetTeamManager():RequestInviteToMyTeam(self.m_CharacterRoleID)
    end
    self:DestroyDialog()

    return true
end

-- 申请入会 / 邀请入会
function ContactRoleDialog:HandleClickFactionInviteBtn(args)
    if self.m_CharacterFactionID > 0 then
        -- 申请入帮
        local send = require "protodef.fire.pb.clan.capplyclan":new()
        send.clanid = self.m_CharacterFactionID
        LuaProtocolManager.getInstance():send(send)
    else
        -- 邀请入帮
        if self.m_CharacterRoleID > 0 then
            local datamanager = require "logic.faction.factiondatamanager"
            local ret =  datamanager.GetApplyTimeCollectionEntry(self.m_CharacterRoleID)
            if ret then
                GetCTipsManager():AddMessageTipById(160608)
                return
            end
            local p = require "protodef.fire.pb.clan.cclaninvitation":new()
            p.guestroleid = self.m_CharacterRoleID
            require "manager.luaprotocolmanager":send(p)
            datamanager.AddApplyTimeCollection(self.m_CharacterRoleID)
        end
    end

    self:DestroyDialog()
    return true
end

function ContactRoleDialog:HandleClickViewBtn(args)

    local send = require "protodef.fire.pb.item.cgetroleequip":new()
    send.roleid = self.m_CharacterRoleID
    send.sendmsg = 0
    require "manager.luaprotocolmanager":send(send)
    self:DestroyDialog()
    return true
end

function ContactRoleDialog:HandleClickPKBtn(args)

    LogInfo("___ContactRoleDialog:HandleClickPKBtn")
    local character = gGetScene():FindCharacterByID(self.m_CharacterRoleID)
    if character then
        if character:IsInBattle() then
            local p = require("protodef.fire.pb.battle.csendwatchbattle"):new()
            p.roleid = self.m_CharacterRoleID
	        LuaProtocolManager:send(p)
            return;
        end
    end

    local send = require "protodef.fire.pb.battle.cinvitationplaypk":new()
    send.objectid = self.m_CharacterRoleID
    require "manager.luaprotocolmanager":send(send)

    self:DestroyDialog()
    require  "logic.leitai.leitaidatamanager".m_IsTick = true
    require  "logic.leitai.leitaidatamanager".m_Time = 0 
    return true
end

function ContactRoleDialog:HandleCampPKBtn(args)
    LogInfo("ContactRoleDialog handle camppk clicked")

    local campPK = CCampPK.Create()
    campPK.roleid = self.m_CharacterRoleID
    LuaProtocolManager.getInstance():send(campPK)

end

function ContactRoleDialog.GlobalOnLButtonClick()
    local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
    return true
end

function ContactRoleDialog.RefreshRoleTeamState(roleID, teamState)
    LogInfo("ContactRoleDialog.RefreshRoleTeamState")

    if _instance and roleID == _instance.m_CharacterRoleID then
        _instance.m_TeamState = teamState
        LogInfo("roleteamstate:" .. tostring(teamState))
        if teamState == 1 then

            _instance.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2740))
        else

            _instance.m_TeamBtn:setText(MHSD_UTILS.get_resstring(2738))
        end
    end

end

