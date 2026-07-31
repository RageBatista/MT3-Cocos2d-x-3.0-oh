require "logic.dialog"
require "logic.multimenuset"
require "logic.family.familytichudialog"

Familycaidan = { }
setmetatable(Familycaidan, Dialog)
Familycaidan.__index = Familycaidan

local _instance
function Familycaidan.getInstance()
    if not _instance then
        _instance = Familycaidan:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familycaidan.getInstanceAndShow(Infor)
    if not _instance then
        _instance = Familycaidan:new()
        _instance.m_MemberData = Infor
        _instance:OnCreate()
        _instance:RefreshData(Infor)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familycaidan.getInstanceNotCreate()
    return _instance
end

function Familycaidan.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familycaidan.ToggleOpenClose()
    if not _instance then
        _instance = Familycaidan:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familycaidan.GetLayoutFileName()
    return "familycaidan.layout"
end

function Familycaidan:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familycaidan)
    return self
end

-- ����
function Familycaidan:HandleClickChatBtn(args)
    local memberid = self.m_MemberData.roleid
    if not memberid then
        return true
    end
    if gGetFriendsManager() then
        gGetFriendsManager():RequestSetChatRoleID(memberid)
    end
    Family.DestroyDialog(true)
    self.DestroyDialog()
end

-- �������
function Familycaidan:HandleClickTeamInviteBtn(args)
    local character = gGetDataManager():GetMainCharacterData()
    local src = gGetScene():FindCharacterByID(character.roleid)
    if self.m_TeamState then
        if self.m_TeamState == 1 and(not src:IsOnTeam()) then
            GetTeamManager():RequestJoinOneTeam(self.m_MemberData.roleid)
        else
            GetTeamManager():RequestInviteToMyTeam(self.m_MemberData.roleid)
        end
    end
    self:DestroyDialog()
end

-- ����
function Familycaidan:HandleClickAppointBtn(args)
    local data = gGetDataManager():GetMainCharacterData()
    local datamanager = require "logic.faction.factiondatamanager"
    local member = datamanager.getMember(data.roleid)
    local menu = familyRenmingMenu.toggleShowHide(self.m_MemberData)
    if menu then
        menu:setTriggerBtn(self.btnAppoint)
        menu:setButtonClickCallBack(Familycaidan.handleAppointMenuClicked, self)

        local pos = self.btnAppoint:GetScreenPos()
        local s = self.btnAppoint:getPixelSize()
        local s1 = menu.window:getPixelSize()
        menu:RefreshPos(700, 120)
        self.IsCanClose = false
    end

end


local confirmtype
local JinYanMemberID
local state
local function JinYanOK()
    gGetMessageManager():CloseConfirmBox(confirmtype, false)
    if not JinYanMemberID then
        return
    end
    local send = require "protodef.fire.pb.clan.cbannedtalk":new()
    send.memberid = JinYanMemberID
    if state == 0 then
        send.flag = 1
        -- ������ʾ��1����  2���
    elseif state == 1 then
        send.flag = 2
    end
    require "manager.luaprotocolmanager":send(send)
    JinYanMemberID = nil
    state = nil
end
-- ����
function Familycaidan:HandleClickJinYanBtn(args)
    JinYanMemberID = self.m_MemberData.roleid
    state = self.m_MemberData.isbannedtalk
    local msg = ""
    if state == 0 then
        msg = MHSD_UTILS.get_resstring(11295)
    else
        msg = MHSD_UTILS.get_resstring(11296)
    end

    msg = string.gsub(msg, "%$parameter1%$", self.m_MemberData.rolename)
    confirmtype = MHSD_UTILS.addConfirmDialog(msg, JinYanOK)
    self.DestroyDialog()
end
-- �����Ա
function Familycaidan:HandleClickExpelBtn(args)
    local cmemberid = self.m_MemberData.roleid
    local cmembername = self.m_MemberData.rolename
    Familytichudialog.getInstanceAndShow()
    if Familytichudialog.getInstanceNotCreate() then
        Familytichudialog.getInstanceNotCreate():RefreshInfor(cmemberid, cmembername)
    end
end
-- �����˵�
function Familycaidan:handleAppointMenuClicked(btn)
end
-- �Ӻ���
function Familycaidan:HandleClickAddFriendBtn(args)
    local cmemberid = self.m_MemberData.roleid
    gGetFriendsManager():RequestAddFriend(cmemberid)
    self:DestroyDialog()
end


function Familycaidan:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.IsCanClose = true
    -- �װ�
    self.m_BackUnder = winMgr:getWindow("familycaidan/Tips/back")
    -- ����
    self.btnChat = CEGUI.toPushButton(winMgr:getWindow("familycaidan/StartChat"))
    -- �Ӻ���
    self.m_AddFriendBtn = CEGUI.toPushButton(winMgr:getWindow("familycaidan/jiaweihaoyou"))
    -- �������
    self.btnTeamInvite = CEGUI.toPushButton(winMgr:getWindow("familycaidan/friend"))
    -- ����
    self.btnAppoint = CEGUI.toPushButton(winMgr:getWindow("familycaidan/ChangePosition"))
    -- ����
    self.btnJinYan = CEGUI.toPushButton(winMgr:getWindow("familycaidan/jinzhi"))
    -- ���
    self.btnExpel = CEGUI.toPushButton(winMgr:getWindow("familycaidan/KickMember"))
    -- �鿴����װ��
    self.m_ViewBtn = CEGUI.toPushButton(winMgr:getWindow("familycaidan/view"))

    self.icon = winMgr:getWindow("familycaidan/Tips/back/dikuang/icon")
    self.level = winMgr:getWindow("familycaidan/Tips/back/dikuang/level")
    self.textState = winMgr:getWindow("familycaidan/Tips/back/zhuangtai")
    self.joinTime = winMgr:getWindow("familycaidan/Tips/back/time")

    self.level:setAlwaysOnTop(true)

    self.btnChat:subscribeEvent("Clicked", Familycaidan.HandleClickChatBtn, self)
    self.btnTeamInvite:subscribeEvent("Clicked", Familycaidan.HandleClickTeamInviteBtn, self)
    self.btnAppoint:subscribeEvent("Clicked", Familycaidan.HandleClickAppointBtn, self)
    self.btnJinYan:subscribeEvent("Clicked", Familycaidan.HandleClickJinYanBtn, self)
    self.btnExpel:subscribeEvent("Clicked", Familycaidan.HandleClickExpelBtn, self)
    self.m_AddFriendBtn:subscribeEvent("Clicked", Familycaidan.HandleClickAddFriendBtn, self)
    self.m_ViewBtn:subscribeEvent("Clicked", Familycaidan.HandleClickViewOtherEquipBtn, self)
end
-- �鿴����װ��
function Familycaidan:HandleClickViewOtherEquipBtn(args)
    if not self.m_MemberData then
        return
    end
    if not self.m_MemberData.roleid then
        return
    end
    local send = require "protodef.fire.pb.item.cgetroleequip":new()
    send.roleid = self.m_MemberData.roleid
    send.sendmsg = 0
    require "manager.luaprotocolmanager":send(send)
    self:DestroyDialog()
end
-- ˢ����ʾ��ť
function Familycaidan:RefreshShow()
    -- ������Ϣ
    local character = gGetDataManager():GetMainCharacterData()
    local src = gGetScene():FindCharacterByID(character.roleid)

    if (src:IsOnTeam()) then
        self.btnTeamInvite:setText(MHSD_UTILS.get_resstring(2738))
        -- �������
    elseif (self.m_TeamState == 1) then
        self.btnTeamInvite:setText(MHSD_UTILS.get_resstring(2740))
        -- �������
    else
        self.btnTeamInvite:setText(MHSD_UTILS.get_resstring(2738))
        -- �������
    end
    local memberid = self.m_MemberData.roleid
    -- ˢ�¼���ʱ��
    -- ����
    self.joinTime:setText(self.m_MemberData.rolename)
    -- ����״̬
    if self.m_MemberData.lastonlinetime == 0 then
        self.textState:setText(MHSD_UTILS.get_resstring(354))
    else
        self.textState:setText(MHSD_UTILS.get_resstring(353))
    end

    -- �����Ƿ��û�
    if gGetFriendsManager() then
        if gGetFriendsManager():isMyFriend(memberid) then
            self.m_AddFriendBtn:setEnabled(not gGetFriendsManager():isMyFriend(memberid))
        end
    end

    local datamanager = require "logic.faction.factiondatamanager"
    local infor = datamanager.GetMyZhiWuInfor()
    if infor.id~=-1 then
        -- ����
        -- �Ƿ����  0 δ���ԣ� 1����
        local str = ""
        if self.m_MemberData.isbannedtalk == 0 then
            str = MHSD_UTILS.get_resstring(11293)
        elseif self.m_MemberData.isbannedtalk == 1 then
            str = MHSD_UTILS.get_resstring(11294)
        end
        self.btnJinYan:setText(str)

        -- ���롰��x���ų����ܲ�����y���ž�Ӣ�����ж�
        function canOperate(memberPosition, myPosition)
            -- ��һ���ų��Ĳ��ɲ����ļ���
            local One = {8,9,10}
            -- �ڶ����ų��Ĳ��ɲ����ļ���
            local Two = {7,9,10}
            -- �������ų��Ĳ��ɲ����ļ���
            local Three = {7,8,10}
            -- ���ľ��ų��Ĳ��ɲ����ļ���
            local Four = {7,8,9}

            -- key = ���ų�ְ��ID , value = ���ų��Ĳ��ɲ����ļ���
            local JunTuanZhang = 
            {
                [3] = One,
                [4] = Two,
                [5] = Three,
                [6] = Four
            }

            local infor = JunTuanZhang[myPosition]
            if not infor then
                return true
            else
                for k,v in pairs(infor) do
                    if memberPosition == v then
                        return false
                    end
                end
                return true
            end

        end

--        function isJobInSameLevel(memberPosition,myPosition)
--            local myRow =  BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(myPosition)
--            local destRow =  BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(memberPosition)
--            if myRow and destRow and destRow.poslevel == myRow.poslevel then
--                return true
--            end
--            return false
--        end
--        if isJobInSameLevel(self.m_MemberData.position,infor.id) then
--            self.btnAppoint:setEnabled(false)
--            self.btnExpel:setEnabled(false)
--        else
--            self.btnAppoint:setEnabled(true)
--            self.btnExpel:setEnabled(true)
--        end

        self.btnAppoint:setVisible(infor.renming == 1 and self.m_MemberData.position > infor.id and canOperate(self.m_MemberData.position,infor.id))
        self.btnJinYan:setVisible(infor.jinyan == 1 and self.m_MemberData.position > infor.id and canOperate(self.m_MemberData.position,infor.id))
        self.btnExpel:setVisible(infor.tichu == 1 and self.m_MemberData.position > infor.id and canOperate(self.m_MemberData.position,infor.id))

        local Height = self.m_BackUnder:getPixelSize().height
        if infor.renming == 0 or self.m_MemberData.position <= infor.id or not canOperate(self.m_MemberData.position,infor.id) then
            Height = Height - 52
            local y1 = self.btnJinYan:getPosition().y.offset
            local y2 = self.btnExpel:getPosition().y.offset
            local y3 = self.m_ViewBtn:getPosition().y.offset
            SetPositionYOffset(self.btnJinYan, y1 - 53, 0)
            SetPositionYOffset(self.btnExpel, y2 - 53, 0)
            SetPositionYOffset(self.m_ViewBtn, y3 - 53, 0)
        end
        if infor.jinyan == 0 or self.m_MemberData.position <= infor.id or not canOperate(self.m_MemberData.position,infor.id) then
            Height = Height - 52
            local y3 = self.m_ViewBtn:getPosition().y.offset
            SetPositionYOffset(self.m_ViewBtn, y3 - 53, 0)
        end
        if infor.tichu == 0 or self.m_MemberData.position <= infor.id or not canOperate(self.m_MemberData.position,infor.id) then
            Height = Height - 52
            local y3 = self.m_ViewBtn:getPosition().y.offset
            SetPositionYOffset(self.m_ViewBtn, y3 - 53, 0)
        end
        -- ���ø߶�
        self.m_BackUnder:setHeight(CEGUI.UDim(0, Height))
    end
end

-- ˢ�����뻹���������
function Familycaidan.RefreshTeamState(roleID, teamState)
    if _instance and roleID == _instance.m_MemberData.roleid then
        if teamState == 1 then
            _instance.btnTeamInvite:setText(MHSD_UTILS.get_resstring(2740))
        else
            _instance.btnTeamInvite:setText(MHSD_UTILS.get_resstring(2738))
        end
    end
end

-- ˢ��λ��
function Familycaidan:RefreshPosition(parent, x, y)
    SetPositionOffset(self:GetWindow(), x, y, 0, 0)
end

function Familycaidan:RefreshData(info)
    local conf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(info.shapeid)
    local iconpath = gGetIconManager():GetImagePathByID(conf.littleheadID):c_str()
    self.icon:setProperty("Image", iconpath)
    local rolelv = ""..info.rolelevel
    if info.rolelevel>1000 then
        local zscs,t2 = math.modf(info.rolelevel/1000)
        rolelv = zscs..""..(info.rolelevel-zscs*1000)
    end
    self.level:setText(tostring(rolelv))
end
return Familycaidan
