require "logic.dialog"
require "logic.zhenfa.zhenfaadjustdlg"
require "logic.zhenfa.zhenfadlg"
require "logic.team.teamdialognew"
debugrequire "logic.team.huobanzhuzhaninfo"
if not DefultSelectID then
    DefultSelectID = 1
end

HuoBanZhuZhanDialog = { }
setmetatable(HuoBanZhuZhanDialog, Dialog)
HuoBanZhuZhanDialog.__index = HuoBanZhuZhanDialog

-- Ӧ�ñ���
local _instance
local CHUZHANOFFSET = -10
local SUOOFFSETX = -3
local SUOOFFSETY = 49      
local HuoBanZhuZhan_PageID = 1
local YOFFECT = 8
-----------------------------------------------------------------------------------
local nIconCount = 9
local nCellCount = 2
-- ����б�
local p = require "protodef.fire.pb.huoban.shuobanlist"
function p:process()
	for k, info in ipairs(self.huobans) do
		MT3HeroManager.getInstance():setupHeroState(info.huobanid, info.infight > 0, info.state, info.weekfree > 0)
	end
	MT3HeroManager.getInstance():sort()
	HuoBanZhuZhanDialog.refreshUICpp()
end

-- �����б�
p = require "protodef.fire.pb.huoban.szhenronginfo"
function p:process()
	local activeGroup = self.dangqianzhenrong
    local groups = {}
    groups[0] = MT3HeroGroup:new()
    groups[1] = MT3HeroGroup:new()
    groups[2] = MT3HeroGroup:new()
    for i, info in pairs(self.zhenrongxinxi) do
        for j, v in pairs(info.huobanlist) do
            groups[i].mMember:push_back(v)
        end
		groups[i].mZhenfaId = info.zhenfa
    end

	MT3HeroManager.getInstance():setupGroups(activeGroup,groups[0],groups[1],groups[2])
end

-- �ı�������Ϣ
p = require "protodef.fire.pb.huoban.schangezhenrong"
function p:process()

    local members = { }
    for i = 1, 4 do
        members[i] = 0
    end
    for i, v in pairs(self.huobanlist) do
        members[i] = v
    end
    MT3HeroManager.getInstance():setGroupMember(self.reason, self.zhenrong, #self.huobanlist, members[1], members[2], members[3], members[4])
    MT3HeroManager.getInstance():sort()

    if self.reason == 3 then
        local membersNew = MT3HeroManager.getInstance():getGroupMember(self.zhenrong)
        local strbuilder = StringBuilder:new()
        local msgid = 0
        if membersNew:size() == 4 then
            msgid = 150113
            strbuilder:Set("Paramenet1", self.zhenrong + 1)
            strbuilder:Set("Paramenet2", 4)
        else
            msgid = 150112
            strbuilder:Set("Paramenet1", self.zhenrong + 1)
            strbuilder:Set("Paramenet2", membersNew:size())
            strbuilder:Set("Paramenet3", 4 - membersNew:size())
        end
        local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(msgid))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(msg)
    end

    if _instance ~= nil then
        _instance:refreshUI(_instance.m_SelectGroup, _instance.mSelectGroupPos, _instance.mState_filter)
    end

    if ZhenFaDlg.getInstanceNotCreate() then
        ZhenFaDlg.getInstanceNotCreate():onEventMemberChange()
    end

    if ZhenFaAdjustDlg.getInstanceNotCreate() then
        ZhenFaAdjustDlg.getInstanceNotCreate():onEventMemberChange()
    end

    local dlg = require("logic.team.teamdialognew").getInstanceNotCreate()
    if dlg then
        dlg:recvZhenRongChanged()
    end

end

-- �ı����ݹ⻷
p = require "protodef.fire.pb.huoban.sswitchzhenfa"
function p:process()
    MT3HeroManager.getInstance():setGroupZhenfaId(self.zhenrongid, self.zhenfaid)
    MT3HeroManager.getInstance():sort()

    local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(self.zhenfaid)
    if baseconf and self.zhenfaid ~= 0 and GetChatManager() then
        GetChatManager():AddTipsMsg(162136, 0, {baseconf.name}, false) --�⻷����Ϊ$parameter1$
    end

    if _instance then
        local zhenfaName = baseconf.name
        local zhenfaLevel = FormationManager.getInstance():getFormationLevel(self.zhenfaid)
        local levelStr = ""
        if tonumber(zhenfaLevel) > 0 then
            levelStr = zhenfaLevel .. MHSD_UTILS.get_resstring(3)
        end
        
        if self.zhenrongid  + 1 == _instance.m_SelectGroup then
            if _instance.m_ZhenfaBtn then
                _instance.m_ZhenfaBtn:setText(levelStr .. zhenfaName)
            else
                LogWar("protodef.fire.pb.huoban.sswitchzhenfa _instance.mWnd_group[self.zhenrongid+1].zhenfaBtn:setText(levelStr .. zhenfaName)")
            end
        end
    end

    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceNotCreate():refreshZhenfaName()
    end

    if ZhenFaDlg.getInstanceNotCreate() then
        ZhenFaDlg.getInstanceNotCreate():refreshOpenedZhenfa(self.zhenfaid)
    end
end

function HuoBanZhuZhanDialog:OnGroupBG( index )
    if HuoBanZhuZhan_PageID ~= index then
        HuoBanZhuZhan_PageID = index
        self:SelectGroup(index)
        --����
    end
end

-- �༭����1
function HuoBanZhuZhanDialog:HandleGroupBg(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
    self:OnGroupBG(id)
end
-- ѡ�񷽰�
function HuoBanZhuZhanDialog:SelectGroup(id)
    if self.m_SelectGroup == id then
        return
    end

    HuoBanZhuZhan_PageID = id
    self.m_SelectGroup = id
    if self.m_Members[self.mSelectGroupPos] ~= nil then
        self.m_Members[self.mSelectGroupPos]:SetSelected(false)
    end
    self.mSelectGroupPos = -1
    
    MT3HeroManager.getInstance():ChangeGroupInfo(self.m_SelectGroup)
    MT3HeroManager.getInstance():sort()
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
    self:UpdataGuangHuan()
end
function HuoBanZhuZhanDialog:UpdataGuangHuan()
    --���¹⻷
    local zhenfaid = MT3HeroManager.getInstance():getGroupZhenfaId(self.m_SelectGroup - 1)
    local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(zhenfaid)
    local zhenfaName = baseconf.name
    local zhenfaLevel = FormationManager.getInstance():getFormationLevel(zhenfaid)
    local levelStr = ""
    if tonumber(zhenfaLevel) > 0 then
        levelStr = zhenfaLevel .. MHSD_UTILS.get_resstring(3)
    end
        
    if _instance.m_ZhenfaBtn then
        _instance.m_ZhenfaBtn:setText(levelStr .. zhenfaName)
    end
end


function HuoBanZhuZhanDialog.refreshUICpp()
    if _instance ~= nil then
        _instance:refreshUI(_instance.m_SelectGroup, _instance.mSelectGroupPos, _instance.mState_filter)
    end
end

-- ����1
function HuoBanZhuZhanDialog:HandleGroupCheckBox(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
    for i = 1, 3 do 
        if i == id then
            MT3HeroManager.getInstance():activeGroup(i-1)
            self.mWnd_group[i]:setSelectedNoEvent(true)
            self.m_pGroupBtn[i]:setSelected(true, false)
        else
            self.mWnd_group[i]:setSelectedNoEvent(false)
            self.m_pGroupBtn[i]:setSelected(false, false)
        end
    end
    self:OnGroupBG(id)
end

-- ������б����ǵ�Ӣ���б�
function HuoBanZhuZhanDialog:HandleTabControl(args)
    local selectId = self.mWnd_TabControl:getSelectedTabIndex()
    self.PreTabMode = self.TabMode
    if self.TabMode == selectId then
        return
    end
    if selectId == 0 then
        -- Ӣ��ҳ
        self.TabMode = 0
        self.TabControlBoolean = true
        -- self.mState_ActiveHeroListPage=true
    elseif selectId == 1 then
        -- ����ҳ
        self.TabMode = 1
        -- self.mState_ActiveHeroListPage=false
    end

end

-- ��ͼ��Ӣ�ۻ����б�Ӣ��
function HuoBanZhuZhanDialog:HandleSelectHeroTable(args)
    -- �������������б���������
    if self.TabMode == 1 then
        return
    end
    if self.TabMode == 0 and self.TabControlBoolean then

        self.TabControlBoolean = false
    else
        if DefultSelectID == 0 then
            DefultSelectID = 1
        else
            DefultSelectID = 0
        end
    end

    self:SelectHeroTableVisible()

    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)

end
-- ͼ��Ӣ�ۻ����б�Ӣ��������
function HuoBanZhuZhanDialog:SelectHeroTableVisible()

    -- �����ǰ��ͼ���б�״̬
    self.mWnd_image1:setVisible(DefultSelectID == 0)
    self.mWnd_image2:setVisible(DefultSelectID == 1)

    self.mWnd_cellHeroList:setVisible(DefultSelectID == 1)
    self.mWnd_iconHeroListPane:setVisible(DefultSelectID == 0)
    --[[
    for i = 1, 5 do
        self.mWnd_jobButton[i]:setVisible(true)
    end
    --]]
end
function HuoBanZhuZhanDialog:ResetHeroTableVisible()
    self.mWnd_image1:setVisible(false)
    self.mWnd_image2:setVisible(false)

    self.mWnd_cellHeroList:setVisible(false)
    self.mWnd_iconHeroListPane:setVisible(false)
end

-- ��ְҵ����
function HuoBanZhuZhanDialog:HandleJobFilter(args)
    local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()

    for i = 1, #self.mWnd_jobButton do
        self.mWnd_jobButton[i]:SetPushState(false)
    end


    if self.mState_filter == id then
        self.mState_filter = 0
    else
        self.mState_filter = id
        local tableInstance = BeanConfigManager.getInstance():GetTableByName("message.cstringres")
        self.mWnd_jobButton[self.mState_filter]:SetPushState(true)
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11387).msg)
    end

    -- self:AppendCellPage(true)
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
end
function HuoBanZhuZhanDialog:HandleSchoolFilter(id)
    for i = 1, #self.mWnd_jobButton do
        self.mWnd_jobButton[i]:SetPushState(false)
    end

    if self.mState_filter == id then
        self.mState_filter = 0
    else
        self.mState_filter = id
    end
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("message.cstringres")
    if self.mState_filter == 0 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11387).msg)
        -- ���������11�Ǹ���ְҵ���ñ������id����
    elseif self.mState_filter == 11 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11378).msg)
    elseif self.mState_filter == 12 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11379).msg)
    elseif self.mState_filter == 13 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11380).msg)
    elseif self.mState_filter == 14 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11381).msg)
    elseif self.mState_filter == 15 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11382).msg)
    elseif self.mState_filter == 16 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11383).msg)
    elseif self.mState_filter == 17 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11384).msg)
    elseif self.mState_filter == 18 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11385).msg)
    elseif self.mState_filter == 19 then
        self.m_Schoolbtn:setText(tableInstance:getRecorder(11386).msg)
    end
    
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
    --[[
    for i = 1, 5 do
        self.mWnd_jobButton[i]:setVisible(false)
    end
    --]]
end

-- ����
function HuoBanZhuZhanDialog:JohnGroup(itemCell)

    local heroId = itemCell:getID()
    local members = MT3HeroManager.getInstance():getGroupMember(self.m_SelectGroup - 1)
    local menber = members:size()
    for i = 0, members:size() -1 do
        if members[i] == heroId then
            GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(150114))
            return
        end
    end
    if MT3HeroManager.getInstance():johnGroup(heroId, self.m_SelectGroup - 1, self.mSelectGroupPos - 1) then


        -- ���״̬
        if self.m_Members[self.mSelectGroupPos] ~= nil then
            self.m_Members[self.mSelectGroupPos]:SetSelected(false)
        end
        self.mSelectGroupPos = -1
        
        -- MT3HeroManager.getInstance():sort()
        -- self:refreshUI(self.m_SelectGroup,self.mSelectGroupPos,self.mState_filter)
    end
end

-- ����
function HuoBanZhuZhanDialog:HandleGroupMemberMask(args)

    local e = CEGUI.toWindowEventArgs(args)
    local itemCell = CEGUI.Window.toItemCell(e.window)
    if itemCell:getID() == self.mSelectGroupPos then
        if MT3HeroManager.getInstance():quitGroup(self.m_SelectGroup - 1, self.mSelectGroupPos - 1) then
            -- ���״̬
            if self.m_Members[self.mSelectGroupPos] ~= nil then
                self.m_Members[self.mSelectGroupPos]:SetSelected(false)
            end
            self.mSelectGroupPos = -1
            
            -- self:refreshUI(self.m_SelectGroup,self.mSelectGroupPos,self.mState_filter)
        end
    end
end

-- ��ս���еĳ�Ա
function HuoBanZhuZhanDialog:HandleGroupMember(args)
    local e = CEGUI.toWindowEventArgs(args)
    local itemCell = CEGUI.Window.toItemCell(e.window)
    local groupPos = itemCell:getID()
    if groupPos == self.mSelectGroupPos then
        -- ���ѡ��
        if self.m_Members[self.mSelectGroupPos] ~= nil then
            self.m_Members[self.mSelectGroupPos]:SetSelected(false)
        end
        self.mSelectGroupPos = -1
        
    else
        -- ����ѡ���
        local members = MT3HeroManager.getInstance():getGroupMember(self.m_SelectGroup - 1)
        local memberCount = members:size()
        local clearSelect = false
        if groupPos <= memberCount then
            if MT3HeroManager.getInstance():swapGroupMember(self.m_SelectGroup - 1, groupPos - 1, self.mSelectGroupPos - 1) then
                clearSelect = true
            end
        end
        if clearSelect then
            if self.m_Members[self.mSelectGroupPos] ~= nil then
                self.m_Members[self.mSelectGroupPos]:SetSelected(false)
            end
            self.mSelectGroupPos = -1
            
        else
            if groupPos <= memberCount + 1 then
                if self.m_Members[self.mSelectGroupPos] ~= nil then
                    self.m_Members[self.mSelectGroupPos]:SetSelected(false)
                end
                
                self.mSelectGroupPos = groupPos
                if self.m_Members[self.mSelectGroupPos] ~= nil then
                    self.m_Members[self.mSelectGroupPos]:SetSelected(true)
                end
            end
        end
    end
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
end

-- ���ͻ�ȡϸ����Ϣ������
function HuoBanZhuZhanDialog:SendMessage_CGetHuobanDetailInfo(heroId)
    local msg = require "protodef.fire.pb.huoban.cgethuobandetailinfo":new()
    msg.huobanid = heroId
    require "manager.luaprotocolmanager":send(msg)
end

-- ����ϸ����Ϣ
local p = require "protodef.fire.pb.huoban.shuobandetail"
debugrequire("logic.team.huobanzhuzhaninfo")
function p:process()
    -- huobanzhuzhaninfo.DestroyDialog()
    local heroInfo = self.huoban
    MT3HeroManager.getInstance():setHeroInfo(heroInfo.huobanid, heroInfo.infight, heroInfo.state, heroInfo.weekfree, heroInfo.datas)
    huobanzhuzhaninfo.getInstance():setHeroId(heroInfo.huobanid)
    if HuoBanZhuZhanDialog.getInstanceNotCreate() then
        HuoBanZhuZhanDialog.getInstanceNotCreate():update(0)
    end

end
-- ��Ӣ�۵�Ԫ
function HuoBanZhuZhanDialog:HandleHeroCellWnd(args)
    if self.m_SelectGroup ~= -1 and self.mSelectGroupPos ~= -1 then
        self:JohnGroup(CEGUI.toWindowEventArgs(args).window)
    else
        local iconWnd = CEGUI.toWindowEventArgs(args).window
        local heroId = iconWnd:getID()
        local i = 1
        for _, v in pairs(self.m_IconIDCollection) do
            if v == heroId then
                self.m_SelectIndex = i
            end
            i = i + 1
        end
        self:SendMessage_CGetHuobanDetailInfo(heroId)
    end
end

function HuoBanZhuZhanDialog:ChangeHeroCellWnd()
    local heros = MT3HeroManager.getInstance():getAllHero()
    local heroCount = #heros
    local step = 1
    local id = 0
    for _, v in pairs(self.m_IconIDCollection) do
        if self.m_SelectIndex == step then
            id = v
            break
        end
        step = step + 1
    end
    for index = 0, heroCount - 1 do

        local iconWnd = self.mWnd_cells[index + 1]
        if iconWnd:getID() == id then
            iconWnd:setSelected(true)
            self.mWnd_cellHeroList:setVerticalScrollPosition(iconWnd:getHeight().offset * math.floor(index / nCellCount) / self.mWnd_cellHeroList:getVertScrollbar():getDocumentSize() * 1.0)
            self.mWnd_cellHeroList:invalidate()
            break
        end
    end
end

function HuoBanZhuZhanDialog:ChangeHeroIconWnd()
    local heros = MT3HeroManager.getInstance():getAllHero()
    local heroCount = #heros
    local step = 1
    local id = 0
    for _, v in pairs(self.m_IconIDCollection) do
        if self.m_SelectIndex == step then
            id = v
            break
        end
        step = step + 1
    end
    for index = 0, heroCount - 1 do

        local iconWnd = self.mWnd_iconHeroList:GetCell(index)
        if iconWnd:getID() == id then

            self.mWnd_iconHeroListPane:setVerticalScrollPosition(iconWnd:getHeight().offset * math.floor(index / nIconCount) / self.mWnd_iconHeroListPane:getVertScrollbar():getDocumentSize() * 1.0)
            self.mWnd_iconHeroListPane:invalidate()
            -- 		iconWnd:setSelected(true)
            --            self.mWnd_cellHeroList:setVerticalScrollPosition(iconWnd:getHeight().offset * index / self.mWnd_cellHeroList:getVertScrollbar():getDocumentSize() * 1.0)
            --            self.mWnd_cellHeroList:invalidate()
            break
        end

    end

end
--
function HuoBanZhuZhanDialog:HandleTableButtonUp(args)
    local e = CEGUI.toMouseEventArgs(args)
    local itemCell = self.mWnd_iconHeroList:GetCellAtPoint(e.position)
    if itemCell ~= nil then
        if  self.mSelectGroupPos ~= -1 then
            self:JohnGroup(itemCell)
        else
            local heroId = itemCell:getID()
            local i = 1
            for _, v in pairs(self.m_IconIDCollection) do
                if v == heroId then
                    self.m_SelectIndex = i
                end
                i = i + 1
            end
            self:SendMessage_CGetHuobanDetailInfo(heroId)
        end
    end
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
end

-- ˢ������ͼ���ʱ��
function HuoBanZhuZhanDialog.updateTime(deltaTime)
    if deltaTime ~= nil then
        MT3HeroManager.getInstance():tick(deltaTime / 1000)
    end
end

function HuoBanZhuZhanDialog:update(deltaTime)
    self.m_Tick = self.m_Tick + deltaTime
    self.m_CollectgarbageTick = self.m_CollectgarbageTick + deltaTime
    -- ˢ�º���
    if self.m_Tick < 1000 then
    else
        self.m_Tick = 0
        MT3HeroManager.getInstance():sort()
    end
    -- ˢ����������
    if self.m_CollectgarbageTick > 10000 then
        self.m_CollectgarbageTick = 0
        collectgarbage()
    end

    -- MT3HeroManager.getInstance():sort()
    -- ׼������
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    local heros = MT3HeroManager.getInstance():getAllHero()


    -- ˢ��ͼ���б���״̬
    local heroCount = #heros
    for index = 0, heroCount - 1 do
        local id = heros[index+1].mHeroId
        local state = heros[index+1].mState
        local week = heros[index+1].mWeekFree
        local HeroType = tableInstance:getRecorder(heros[index+1].mHeroId).type

        if self.mState_filter == 0 or HeroType == self.mState_filter then
            if self:IsFightState(id) then
                -- ��ս
                -- self.mWnd_iconHeroList:GetCell(index):SetMaskImage(0,CEGUI.String("huobanui"),CEGUI.String("huoban_zhan"))

                self.mWnd_iconHeroList:GetCell(index):SetCornerImageAtPos("huobanui", "huoban_zhan", 0, 1, CHUZHANOFFSET, CHUZHANOFFSET);
                self.mWnd_iconHeroList:GetCell(index):ClearMaskImage(1)
                self.mWnd_iconHeroList:GetCell(index):SetTextUnitText(CEGUI.String(""), 2, YOFFECT)
            end
            if state == 0 then
                -- ����
                self.mWnd_iconHeroList:GetCell(index):ClearMaskImage(3)
                self.mWnd_iconHeroList:GetCell(index):SetCornerImageAtPos("huobanui", "huoban_suo", 0, 1, SUOOFFSETX, SUOOFFSETY);
                local imageId = tableInstance:getRecorder(heros[index+1].mHeroId).headid
                local imageIdGey = gGetIconManager():GetImageByID(imageId + 10000)
                self.mWnd_iconHeroList:GetCell(index):SetImage(imageIdGey)
                self.mWnd_iconHeroList:GetCell(index):SetTextUnitText(CEGUI.String(""), 2, YOFFECT)
                -- self.mWnd_iconHeroList:GetCell(index):SetMaskImage(3,CEGUI.String("huobanui"),CEGUI.String("huoban_mengban2"))
            elseif state == 1 then
                -- ����ʹ��
                self.mWnd_iconHeroList:GetCell(index):ClearMaskImage(3)
                self.mWnd_iconHeroList:GetCell(index):SetTextUnitText(CEGUI.String(""), 2, YOFFECT)
            elseif week then
                -- �������
                self.mWnd_iconHeroList:GetCell(index):ClearMaskImage(3)
                self.mWnd_iconHeroList:GetCell(index):SetTextUnitText(CEGUI.String(self.mWord_benzhoumianfei), 2, YOFFECT)
            else
                -- ��ʱ���
                self.mWnd_iconHeroList:GetCell(index):ClearMaskImage(3)
                self.mWnd_iconHeroList:GetCell(index):SetTextUnitText(CEGUI.String(self:GetFreeTimeString(heros[index+1])), 2, YOFFECT)
            end
        end
    end


    -- ˢ��CELLʱ��
    local text = ""
    for index = 0, #self.mWnd_cells - 1 do
        local prefixName = tostring(index + 1) .. "hero"
        local freeWnd = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/qunxiongtext")
        local iconWnd = CEGUI.Window.toItemCell(self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/cell"))
        local HeroType = tableInstance:getRecorder(heros[index+1].mHeroId).type
        local Heroheadid = tableInstance:getRecorder(heros[index+1].mHeroId).headid
        if self.mState_filter == 0 or HeroType == self.mState_filter then
            if self:IsFightState(heros[index+1].mHeroId) then
                -- ��ս
                local sun = 1
            end
            if heros[index+1].mState == 0 then
                -- ����
                iconWnd:SetCornerImageAtPos("huobanui", "huoban_suo", 0, 1, SUOOFFSETX, SUOOFFSETY);
                local imageIdGrey = gGetIconManager():GetImageByID(Heroheadid + 10000)
                iconWnd:SetImage(imageIdGrey)
                freeWnd:setVisible(false)
            elseif heros[index+1].mState == 1 then
                -- �������

            elseif heros[index+1].mWeekFree then
                -- �������
                freeWnd:setVisible(true)
                freeWnd:setText(self.mWord_benzhoumianfei)
            else
                -- ��ʱ���
                freeWnd:setVisible(true)
                text = self:GetFreeTimeString(heros[index+1])
                freeWnd:setText(text)
            end
        end
    end



    -- û����������ˢ��ʱ����ʲô���壿����

    --[[	--ˢ��ʱ��(�����Ϣ����)
	if huobanzhuzhaninfo.getInstanceNotCreate()~=nil  then
		huobanzhuzhaninfo.getInstance():SetTime(text)
	end--]]
end

--
function HuoBanZhuZhanDialog:AppendCellPage(loadAll)
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    local heros = MT3HeroManager.getInstance():getAllHero()
    local heroCount = 10
    local heroBeginNumber = #self.mWnd_cells
    if #self.mWnd_cells > 0 then
        heroCount = heroBeginNumber + 5
    end
    if heroCount > #heros or loadAll then
        heroCount = #heros
    end
    --[[	for i = 1,#self.mWnd_cells do
	self.mWnd_cellHeroList:destroyWindow(self.mWnd_cells[i])
end
self.mWnd_cells = {}]]


    for index = heroBeginNumber, heroCount - 1 do
        local heroData = heros[index+1]
        local myID = heroData.mHeroId
        local record = tableInstance:getRecorder(heroData.mHeroId)
        local imageId = gGetIconManager():GetImageByID(record.headid)
        local prefixName = tostring(index + 1) .. "hero"
        self.winMgr:loadWindowLayout("huobanzhuzhancell.layout", prefixName)
        local wndCell = CEGUI.Window.toGroupButton(self.winMgr:getWindow(prefixName .. "huobazhuzhancell1"))
        -- ȥ������
        wndCell:EnableClickAni(false)
        -- wndCell:setID(heroData.mHeroId)
        wndCell:subscribeEvent("MouseClick", self.HandleHeroCellWnd, self)
        self.mWnd_cells[index + 1] = wndCell
        self.mWnd_cellHeroList:addChildWindow(wndCell)
        local iconWnd = CEGUI.Window.toItemCell(self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/cell"))
        iconWnd:subscribeEvent("MouseClick", self.HandleHeroCellWnd, self)
        --[[		local iconWnd=CEGUI.Window.toItemCell(self.winMgr:getWindow(prefixName.."huobazhuzhancell1/cell"))
	iconWnd:SetImage(imageId)
	iconWnd:setFont("simhei-10")
	iconWnd:setID(heroData.mHeroId)
	iconWnd:subscribeEvent("MouseClick",self.HandleHeroCellWnd,self)
	local nameWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/name")
	nameWnd:setText(record.name)
	local levelWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/level")
	levelWnd:setText("Lv"..tostring(gGetDataManager():GetMainCharacterLevel()))
	local jobIconWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/qunxiongzhiyetubiao")
	local jobTypeWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/qunxiongleixing")
	if record.type==1 then
		jobIconWnd:setProperty("Image","set:huobanui image:huobanwugong")
		jobTypeWnd:setText(self.mWord_job1)
	elseif record.type==2 then
		jobIconWnd:setProperty("Image","set:huobanui image:huoban_fagong")
		jobTypeWnd:setText(self.mWord_job2)
	elseif record.type==3 then
		jobIconWnd:setProperty("Image","set:huobanui image:huoban_zhiliao")
		jobTypeWnd:setText(self.mWord_job3)
	elseif record.type==4 then
		jobIconWnd:setProperty("Image","set:huobanui image:huoban_fuzhu")
		jobTypeWnd:setText(self.mWord_job4)
	elseif record.type==5 then
		jobIconWnd:setProperty("Image","set:huobanui image:huoban_fengyin")
		jobTypeWnd:setText(self.mWord_job5)
		end]]

        -- ��ʱ�رպ�����ص���Ϣ
        local wndFriendJobType = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/haoyouzhiye")
        wndFriendJobType:setVisible(false)
        local wndFriendVolumeType = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/haoyoudu")
        wndFriendVolumeType:setVisible(false)
        local wndFriendVolumeNumber = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/haoyoudushu")
        wndFriendVolumeNumber:setVisible(false)
        local wndFriendText = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/haoyoutext")
        wndFriendText:setVisible(false)
    end

end

-- �϶�CELL�б���ĩβ��
function HuoBanZhuZhanDialog:HandleListNextPage(args)
    -- self:AppendCellPage(false)
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
end

-- ���˳���ť
function HuoBanZhuZhanDialog:HandleQuitButton(e)
    HuoBanZhuZhanDialog.CloseDialog()
end

function HuoBanZhuZhanDialog:handleConfirmLearnZhenfa()
    ZhenFaDlg.getInstanceAndShow(false)
end

-- ��⻷��ť
function HuoBanZhuZhanDialog:HandleZhenfaClicked(args)
    if FormationManager.getInstance():haveLearnedFormation() then        
        local btn = CEGUI.toWindowEventArgs(args).window
        local zhenfaId = MT3HeroManager.getInstance():getGroupZhenfaId(self.m_SelectGroup - 1)

        local dlg = ZhenFaDlg.getInstanceAndShow(false)
        dlg:focusOnZhenfaById(zhenfaId)

    else
        -- GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(150180)) --����δѧϰ�⻷
        MessageBoxSimple.show(
        MHSD_UTILS.get_msgtipstring(160042),
        -- ��Ŀǰ��û��ѧ��⻷���Ƿ���ת���⻷����ѧϰ�⻷
        HuoBanZhuZhanDialog.handleConfirmLearnZhenfa, self, nil, nil
        )
    end
end

-- �����Ի���
function HuoBanZhuZhanDialog:OnCreate()
    print("HuoBanZhuZhanDialog oncreate begin")
    Dialog.OnCreate(self)

    self.winMgr = CEGUI.WindowManager:getSingleton()

    self.m_threeCellname = ""
    self.m_fourCellname = ""


    self.frameWnd = CEGUI.Window.toFrameWindow(self.winMgr:getWindow("huobanzhuzhan/diban"))
    local autoCloseButton = self.frameWnd:getCloseButton()
    autoCloseButton:subscribeEvent("MouseClick", self.HandleQuitButton, self)
    self.mWnd_image1 = self.winMgr:getWindow("huobanzhuzhan/diban/image1")
    self.mWnd_image2 = self.winMgr:getWindow("huobanzhuzhan/diban/image2")
    self.mWnd_TabControl = CEGUI.Window.toTabControl(self.winMgr:getWindow("huobanzhuzhan/diban/tabcon"))
    -- FIXME: ����δ�꣬��ʱ��ȥ�����ѷ�ҳ
    -- self.mWnd_TabControl:removeTab("huobanzhuzhan/diban/tabcon/Tab 2")

    local heroListButton = self.winMgr:getWindow("huobanzhuzhan/diban/tabcon__auto_TabPane__Buttons__auto_btnTab 1")
    heroListButton:subscribeEvent("Clicked", self.HandleSelectHeroTable, self)
    self.mWnd_TabControl:subscribeEvent("TabSelectionChanged", self.HandleTabControl, self)
    self.mWnd_heroTable = self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab 1")
    -- self.mWnd_heroTable:setMousePassThroughEnabled(true)
    -- tab->SetMulitySelect(true);

    -- self.mWnd_heroTable:subscribeEvent("MouseClick",self.HandleSelectHeroTable,self)
    -- self.mWnd_friendTable=self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab 2")
    -- self.mWnd_friendTable:subscribeEvent("TabSelectionChanged",self.HandleSelectFriendTable,self)
    self.mWnd_iconHeroListPane = CEGUI.Window.toScrollablePane(self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab 1/tablePane"))

    self.mWnd_iconHeroList = CEGUI.Window.toItemTable(self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab 1/table"))
    self.mWnd_iconHeroList:setProperty("LimitWindowSize", "False")
    self.mWnd_iconHeroList:SetColCount(9)
    self.mWnd_iconHeroList:SetCellWidth(90.0)
    self.mWnd_iconHeroList:SetCellHeight(90.0)
    self.mWnd_iconHeroList:SetSpaceX(19.0)
    self.mWnd_iconHeroList:SetSpaceY(19.0)
    self.mWnd_iconHeroList:SetStartX(19)
    self.mWnd_iconHeroList:SetStartY(19)
    -- self.mWnd_iconHeroList:subscribeEvent("TableClick",self.HandleTableClick,self)
    self.mWnd_iconHeroList:subscribeEvent("MouseButtonUp", self.HandleTableButtonUp, self)
    self.mWnd_iconHeroListPane:EnableAllChildDrag(self.mWnd_iconHeroListPane)
    self.mWnd_cellHeroList = CEGUI.Window.toScrollablePane(self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab 1/list"))
    self.mWnd_cellHeroList:subscribeEvent("NextPage", HuoBanZhuZhanDialog.HandleListNextPage, self)
    -- self.mWnd_friendList=CEGUI.Window.toScrollablePane(self.winMgr:getWindow("huobanzhuzhan/diban/list3"))

    self.mWnd_jobButton = { }
    for i = 1, 5 do
        self.mWnd_jobButton[i] = CEGUI.Window.toPushButton(self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab 1/job" .. i))
        self.mWnd_jobButton[i]:setID(i)
        self.mWnd_jobButton[i]:subscribeEvent("MouseButtonUp", self.HandleJobFilter, self)
        self.mWnd_jobButton[i]:SetMouseLeaveReleaseInput(false)
    end
    -- self.mWnd_friendList=CEGUI.Window.toScrollablePane(self.winMgr:getWindow("huobanzhuzhan/diban/list3"))
    -- self.mWnd_wgButton={}
    -- for i=1,6 do
    -- 	self.mWnd_wgButton[i]=CEGUI.Window.toPushButton(self.winMgr:getWindow("huobanzhuzhan/diban/tabcon/Tab2/btnwugong"..i))
    -- end

    self.mWnd_group = { }
    self.m_pGroupBtn = { }
    self.m_pGroupBG={}
    for i = 1, 3 do
        self.mWnd_group[i] = CEGUI.Window.toCheckbox(self.winMgr:getWindow("huobanzhuzhan/diban/right" .. i .. "/checkbox" .. i))
        self.mWnd_group[i]:setID(i)
        self.mWnd_group[i]:subscribeEvent("CheckStateChanged", self.HandleGroupCheckBox, self)

        self.m_pGroupBtn[i] = CEGUI.Window.toGroupButton(self.winMgr:getWindow("huobanzhuzhan/diban/right" .. i))
        self.m_pGroupBtn[i]:setSelected(false)
        self.m_pGroupBtn[i]:setID(i)
        self.m_pGroupBtn[i]:subscribeEvent("SelectStateChanged", self.HandleGroupBg, self)
    end

    self.m_ZhenfaBtn =  CEGUI.toPushButton(self.winMgr:getWindow("huobanzhuzhan/diban/right1/btnzhen1"))
    self.m_ZhenfaBtn:subscribeEvent("Clicked", self.HandleZhenfaClicked, self)
    self.m_Members = {}

    for i = 1, 4 do 
        self.m_Members[i] = CEGUI.Window.toItemCell(self.winMgr:getWindow("huobanzhuzhan/diban/right1/item" .. i))
        self.m_Members[i]:setID(i)
        self.m_Members[i]:subscribeEvent("TableClick", self.HandleGroupMember, self)
        self.m_Members[i]:subscribeEvent("MaskClick", self.HandleGroupMemberMask, self)
        self.m_Members[i]:setWantsMultiClickEvents(false);
    end


    for i = 1, 3 do 

    end
    --self.m_ScrollPaneBG:EnableAllChildDrag(self.m_ScrollPanel)

    -- ��ʼ������
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("message.cstringres")
    self.mWord_benzhoumianfei = tableInstance:getRecorder(11104).msg
    self.mWord_tian = tableInstance:getRecorder(11105).msg
    self.mWord_xiaoshi = tableInstance:getRecorder(315).msg
    self.mWord_fenzhong = tableInstance:getRecorder(314).msg
    self.mWord_miao = tableInstance:getRecorder(10015).msg
    self.mWord_job1 = tableInstance:getRecorder(11106).msg
    self.mWord_job2 = tableInstance:getRecorder(11107).msg
    self.mWord_job3 = tableInstance:getRecorder(11108).msg
    self.mWord_job4 = tableInstance:getRecorder(11109).msg
    self.mWord_job5 = tableInstance:getRecorder(11110).msg

    -- ��ʼ����ʾ
    self.mWnd_cells = { }
    self.mState_LastSelectGroupMember = -1
    self.mSelectGroupPos = -1

    self.PreTabMode = 1
    self.TabMode = 0
    -- 0 Ӣ��ҳ 1 ����ҳ
    self.TabControlBoolean = false
    -- self.mState_ActiveHeroListPage=true--����Ӣ��ҳ�����򼤻����ҳ


    self.mState_filter = 0
    -- Ӣ�ۻ���ѵĹ���

    self.collect = 0
    self.m_IconIDCollection = { }
    -- id�ϼ�
    self.m_ListEntryIDCollection = { }
    -- ��ĿID����
    self.m_SelectIndex = 1
    -- Ĭ��ѡ��
    self.m_SelectGroup = 1
    --
    MT3HeroManager.getInstance():sort()
    self:initializeUI()
    self:refreshUI(self.m_SelectGroup, self.mSelectGroupPos, self.mState_filter)
    self:SelectHeroTableVisible()
    self.m_Tick = 0
    self.m_CollectgarbageTick = 0

    self.m_SchoolbtnStatus = false

    self.m_Schoolbtn = CEGUI.Window.toPushButton(self.winMgr:getWindow("huobanzhuzhan/diban/btn2"))
    self.m_Schoolbtn:subscribeEvent("Clicked", HuoBanZhuZhanDialog.HandleSchoolBtn, self)
    self.m_SchoolUp = self.winMgr:getWindow("huobanzhuzhan/diban/shang")
    self.m_SchoolUp:setVisible(true)
    self.m_SchoolBottom = self.winMgr:getWindow("huobanzhuzhan/diban/xia")
    self.m_SchoolBottom:setVisible(false)
    local activeGroupId = MT3HeroManager.getInstance():getActiveGroupId() + 1
    -- ����ѡ�е���
    self.m_pGroupBtn[activeGroupId]:setSelected(true)
    -- ����check��ť
    
    self.mWnd_group[activeGroupId]:setSelected(true)

    self:UpdataGuangHuan()

    print("create success!")
end

-- ˢ���б��ߴ�
function HuoBanZhuZhanDialog:HandleSchoolBtn(e)
    if self.m_SchoolbtnStatus == false then
        self.m_SchoolUp:setVisible(false)
        self.m_SchoolBottom:setVisible(true)

        local posx = self.m_Schoolbtn:getPosition().x.offset;
        local posy = self.m_Schoolbtn:getPosition().y.offset;
        local posWiny = self.m_Schoolbtn:getHeight().offset;
        local dlg = require "logic.team.huobanzhuzhanschoolbg".getInstance(self.frameWnd)

        if dlg then
            dlg:GetWindow():setXPosition(CEGUI.UDim(0, posx))
            dlg:GetWindow():setYPosition(CEGUI.UDim(0, posy + posWiny))
        end

    else
        self.m_SchoolUp:setVisible(true)
        self.m_SchoolBottom:setVisible(false)
        if require "logic.team.huobanzhuzhanschoolbg".getInstanceNotCreate() then
            require "logic.team.huobanzhuzhanschoolbg".DestroyDialog()
        end

    end
    self.m_SchoolbtnStatus = not self.m_SchoolbtnStatus
end
function HuoBanZhuZhanDialog:CloseSchoolBtn()
    self.m_SchoolUp:setVisible(true)
    self.m_SchoolBottom:setVisible(false)
    self.m_SchoolbtnStatus = false
    if require "logic.team.huobanzhuzhanschoolbg".getInstanceNotCreate() then
        require "logic.team.huobanzhuzhanschoolbg".DestroyDialog()
    end
end
function HuoBanZhuZhanDialog:refreshIconTableViewSize()
    local count = 0
    for _, v in pairs(self.m_IconIDCollection) do
        count = count + 1
    end
    local PageCount = 9
    local PageWidth = self.mWnd_iconHeroListPane:getPixelSize().width
    local PageHeight = self.mWnd_iconHeroListPane:getPixelSize().height
    local Page = 1
    Page = math.ceil(count / PageCount)
    self.mWnd_iconHeroList:setSize(NewVector2(PageWidth,(90 + 25) * Page + 20))
end
-- �رնԻ���
function HuoBanZhuZhanDialog:CloseDialog()
    if _instance then
        LogInfo("destroy HuoBanZhuZhanDialog")
        _instance:OnClose()
        _instance = nil
        -- wangbin add refresh jingji huoban team
        local jjManager = require("logic.jingji.jingjimanager").getInstance()
        jjManager:refreshHuoban()

    end
end

-- �µĳ�ʼ��
function HuoBanZhuZhanDialog:initializeUI()

    -- ��ʼ��ͼ���б�
    -- self.initIconList=false

    -- ��ʼ��CELL�б�
    -- self:AppendCellPage(false)
    -- self:AppendCellPage(true)

    local activeGroupId = MT3HeroManager.getInstance():getSelectGroupId() + 1
    self.m_SelectGroup = activeGroupId
    --[[
        if activeGroupId == i then
            self.mWnd_group[activeGroupId].checkbox:setSelected(true)
        else
            self.mWnd_group[activeGroupId].checkbox:setSelected(false)
        end
        --]]
    local zhenfaId = MT3HeroManager.getInstance():getGroupZhenfaId(activeGroupId - 1)
    if zhenfaId == 0 then
        self.m_ZhenfaBtn:setText(MHSD_UTILS.get_resstring(1731))
        -- �޹⻷
    else
        local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(zhenfaId)
        local zhenfaLevel = FormationManager.getInstance():getFormationLevel(zhenfaId)
        local levelStr = zhenfaLevel .. MHSD_UTILS.get_resstring(3)
        self.m_ZhenfaBtn:setText(levelStr .. baseconf.name)
    end

    -- ����ս�ӳ�Ա
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    local members = MT3HeroManager.getInstance():getGroupMember(activeGroupId - 1)
    for i = 1, 4 do
        local cellWnd = self.m_Members[i]
        if i - 1 < members:size() then
            local memberId = members[i - 1]
            local record = tableInstance:getRecorder(memberId)
            local image = gGetIconManager():GetImageByID(record.headid)
            cellWnd:SetImage(image)
            cellWnd:SetStyle(0)
        else
            cellWnd:SetImage(nil)
            cellWnd:setText("")
        end
    end

    -- ����Ĭ����ʾ�Ŀؼ�
    -- Ӣ��ҳ
    self.mWnd_heroTable:setVisible(true)
    self.mWnd_cellHeroList:setVisible(true)
    self.mWnd_iconHeroListPane:setVisible(false)


    -- ����ҳ
    -- self.mWnd_friendList:setVisible(false)
    -- self.mWnd_friendTable:setVisible(false)
end

-- ����Ƿ��ڳ�ս״̬
function HuoBanZhuZhanDialog:IsFightState(heroId)
    local members = MT3HeroManager.getInstance():getGroupMember(HuoBanZhuZhan_PageID-1)
    for i=0,members:size()-1 do
        local memberHeroId = members[i]
        if heroId == memberHeroId then
            return true
        end
    end
    return false
end

-- ����Ƿ���ѡ��״̬
function HuoBanZhuZhanDialog:IsSelectState()
    return  self.mSelectGroupPos ~= -1
end

-- ����Ƿ����������״̬
function HuoBanZhuZhanDialog:IsFreeState(heroData)
    return heroData.mState == 1
end

-- ����Ƿ��ڱ������״̬
function HuoBanZhuZhanDialog:IsWeekFreeState(heroData)
    return heroData.mWeekFree
end

-- ����Ƿ�����״̬
function HuoBanZhuZhanDialog:IsLockState(heroData)
    return heroData.mState == 0
end

-- ��ȡʱ��
function HuoBanZhuZhanDialog:GetFreeTimeString(heroData)

    if heroData.mEnableTime >= 86400 then
        -- һ����86400��
        local tian = math.floor(heroData.mEnableTime / 86400)
        return tostring(tian) .. self.mWord_tian
    elseif heroData.mEnableTime >= 3600 then
        -- һСʱ��3600��
        local xiaoshi = math.floor(heroData.mEnableTime / 3600)
        return tostring(xiaoshi) .. self.mWord_xiaoshi
    elseif heroData.mEnableTime >= 60 then
        -- һ����60��
        local fenzhong = math.floor(heroData.mEnableTime / 60)
        return tostring(fenzhong) .. self.mWord_fenzhong
    else
        return tostring(math.floor(heroData.mEnableTime)) .. self.mWord_miao
    end

    return "0" .. self.mWord_miao
end

-- ����Ƿ������ݳ�Ա
function HuoBanZhuZhanDialog:IsActiveGroupMember(heroId)
    local members = MT3HeroManager.getInstance():getGroupMember(self.m_SelectGroup - 1)
    for j = 1, members:size() do
        if heroId == members[j - 1] then
            return true
        end
    end
    return false
end

-- ˢ��Ӣ�۵�״̬
function HuoBanZhuZhanDialog:refreshUI(selectGroupId, selectGroupPos, filterType)

    -- ׼������
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    local heros = MT3HeroManager.getInstance():getAllHero()

    local heroCount = #heros
    local activeGroupId = MT3HeroManager.getInstance():getSelectGroupId() + 1
    -- ��ʼ��ID�б�����
    self.m_IconIDCollection = { }
    local indexIcon = 0
    --[[	for index=0,heroCount-1 do
	local heroData=heros[index+1]
	local record=tableInstance:getRecorder(heroData.mHeroId)
	if filterType==0 or record.type==filterType then
		self.m_IconIDCollection[index+1] = heroData.mHeroId
	end
end--]]

    -- ��ʼ��ͼ���б�
    self.mWnd_iconHeroList:DestroyAllCell()
    -- if self.initIconList==false then
    -- self.initIconList=true
    for index = 0, heroCount - 1 do
        local heroData = heros[index+1]
        local myID = heroData.mHeroId
        local record = tableInstance:getRecorder(myID)
        self.mWnd_iconHeroList:AddCell(index)
        local imageId = gGetIconManager():GetImageByID(record.headid)
        local iconWnd = self.mWnd_iconHeroList:GetCell(index)
        iconWnd:SetImage(imageId)
        iconWnd:setFont("num-count1")
        iconWnd:setID(heroData.mHeroId)
        iconWnd:SetHaveSelectedState(false)
        iconWnd:SetCellTypeMask(1)
        iconWnd:setMousePassThroughEnabled(true)
        iconWnd:SetStyle(CEGUI.ItemCellStyle_IconExtend)
    end
    -- end

    -- ˢ��ͼ���б���״̬
    for index = 0, heroCount - 1 do
        local heroData = heros[index+1]
        local iconWnd = self.mWnd_iconHeroList:GetCell(index)
        local record = tableInstance:getRecorder(heroData.mHeroId)
        local blnShow = false
        -- ���filterType>5 ˵�������ְҵ ���������ǵ��µİ�ť
        if filterType > 5 then
            if record.school == filterType then
                blnShow = true
            end
        else
            if filterType == 0 or record.type == filterType then
                blnShow = true
            end
        end
        if blnShow then
            -- ��һ��
            iconWnd:ClearCornerImage(0)
            iconWnd:ClearCornerImage(2)
            iconWnd:ClearAllMaskImage()
            iconWnd:setText("")
            iconWnd:SetTextUnitText(CEGUI.String(""), 2, YOFFECT)
            local myID = heroData.mHeroId
            local record = tableInstance:getRecorder(myID)

            local upArrowState = false
            if self:IsFightState(heroData.mHeroId) then
                -- ��ս
                -- iconWnd:SetMaskImage(0,CEGUI.String("huobanui"),CEGUI.String("huoban_zhan"))
                iconWnd:ClearMaskImage(1)
                iconWnd:SetCornerImageAtPos("huobanui", "huoban_zhan", 0, 1, CHUZHANOFFSET, CHUZHANOFFSET);
                if selectGroupId ~= activeGroupId then
                    upArrowState = true
                end
            end
            if self:IsWeekFreeState(heroData) then
                -- �������
                iconWnd:ClearMaskImage(3)
                iconWnd:SetTextUnitText(CEGUI.String(self.mWord_benzhoumianfei), 2, YOFFECT)
                upArrowState = true
            elseif self:IsLockState(heroData) then
                -- ����
                -- iconWnd:SetMaskImage(3,CEGUI.String("huobanui"),CEGUI.String("huoban_mengban2"))
                iconWnd:SetCornerImageAtPos("huobanui", "huoban_suo", 0, 1, SUOOFFSETX, SUOOFFSETY);
                local imageId = gGetIconManager():GetImageByID(record.headid + 10000)
                iconWnd:SetImage(imageId)
                -- iconWnd:SetMaskImage(0,CEGUI.String("huobanui"),CEGUI.String("huoban_suo"))
            elseif self:IsFreeState(heroData) then
                -- ����ʹ��
                iconWnd:ClearMaskImage(3)
                upArrowState = true
            else
                -- ��ʱ���
                iconWnd:ClearMaskImage(3)
                -- iconWnd:SetMaskImage(3,CEGUI.String("huobanui"),CEGUI.String("huoban_mengban2"))
                iconWnd:SetTextUnitText(CEGUI.String(self:GetFreeTimeString(heroData)), 2, YOFFECT)
                upArrowState = true
            end
            -- ��ʾ�����־
            if upArrowState and self:IsSelectState() then
                if not self:IsActiveGroupMember(heroData.mHeroId) then
                    iconWnd:SetCornerImageAtPos("ccui1", "shangsheng", 2, 1)
                    -- iconWnd:SetMaskImage(4,CEGUI.String("huobanui"),CEGUI.String("huoban_UP"))
                end
            end
            iconWnd:setVisible(true)
        else
            iconWnd:setVisible(false)
        end
    end
    self.mWnd_iconHeroList:RefreshCellPos(true)

    self:AppendCellPage(true)
    --[[
local iconWnd=CEGUI.Window.toItemCell(self.winMgr:getWindow(prefixName.."huobazhuzhancell1/cell"))
iconWnd:SetImage(imageId)
iconWnd:setFont("simhei-10")
iconWnd:setID(heroData.mHeroId)
iconWnd:subscribeEvent("MouseClick",self.HandleHeroCellWnd,self)
local nameWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/name")
nameWnd:setText(record.name)
local levelWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/level")
levelWnd:setText("Lv"..tostring(gGetDataManager():GetMainCharacterLevel()))
local jobIconWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/qunxiongzhiyetubiao")
local jobTypeWnd=self.winMgr:getWindow(prefixName.."huobazhuzhancell1/qunxiongleixing")
if record.type==1 then
	jobIconWnd:setProperty("Image","set:huobanui image:huobanwugong")
	jobTypeWnd:setText(self.mWord_job1)
elseif record.type==2 then
	jobIconWnd:setProperty("Image","set:huobanui image:huoban_fagong")
	jobTypeWnd:setText(self.mWord_job2)
elseif record.type==3 then
	jobIconWnd:setProperty("Image","set:huobanui image:huoban_zhiliao")
	jobTypeWnd:setText(self.mWord_job3)
elseif record.type==4 then
	jobIconWnd:setProperty("Image","set:huobanui image:huoban_fuzhu")
	jobTypeWnd:setText(self.mWord_job4)
elseif record.type==5 then
	jobIconWnd:setProperty("Image","set:huobanui image:huoban_fengyin")
	jobTypeWnd:setText(self.mWord_job5)
	end]]
    -- ˢ��CELL�б���״̬
    local enableIndex = 0
    local colIndex = 0
    local len = heroCount - 1
    for index = 0, len do
        local heroData = heros[index+1]
        local myID = heroData.mHeroId
        local record = tableInstance:getRecorder(myID)
        local cellWnd = self.mWnd_cells[index + 1]
        local prefixName = tostring(index + 1) .. "hero"
        local iconWnd = CEGUI.Window.toItemCell(self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/cell"))
        -- �������������Ϣ.
        iconWnd:SetStyle(CEGUI.ItemCellStyle_IconExtend)
        local imageId = gGetIconManager():GetImageByID(record.headid)
        iconWnd:SetImage(imageId)
        iconWnd:setFont("simhei-10")
        cellWnd:setID(myID)
        iconWnd:setID(myID)
        -- iconWnd:subscribeEvent("MouseClick",self.HandleHeroCellWnd,self)
        local nameWnd = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/name")
        nameWnd:setText(record.name)
        local levelWnd = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/level")
        local rolelevel =  gGetDataManager():GetMainCharacterLevel()
        local rolelv = ""..rolelevel
    if rolelevel>1000 then
        local zscs,t2 = math.modf(rolelevel/1000)
        rolelv = zscs..""..(rolelevel-zscs*1000)
    end
        levelWnd:setText("" .. tostring(rolelv))
        local jobIconWnd = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/qunxiongzhiyetubiao")
        local jobTypeWnd = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/qunxiongleixing")
        local schoolrecord = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(record.school)
        jobIconWnd:setProperty("Image", schoolrecord.schoolpicpathc)
        jobTypeWnd:setText(schoolrecord.namecc)
        -- 	if record.type==1 then
        -- 		jobIconWnd:setProperty("Image","set:huobanui image:huobanwugong")
        -- 		jobTypeWnd:setText(self.mWord_job1)
        -- 	elseif record.type==2 then
        -- 		jobIconWnd:setProperty("Image","set:huobanui image:huoban_fagong")
        -- 		jobTypeWnd:setText(self.mWord_job2)
        -- 	elseif record.type==3 then
        -- 		jobIconWnd:setProperty("Image","set:huobanui image:huoban_zhiliao")
        -- 		jobTypeWnd:setText(self.mWord_job3)
        -- 	elseif record.type==4 then
        -- 		jobIconWnd:setProperty("Image","set:huobanui image:huoban_fuzhu")
        -- 		jobTypeWnd:setText(self.mWord_job4)
        -- 	elseif record.type==5 then
        -- 		jobIconWnd:setProperty("Image","set:huobanui image:huoban_fengyin")
        -- 		jobTypeWnd:setText(self.mWord_job5)
        -- 	end
        local freeWnd = self.winMgr:getWindow(prefixName .. "huobazhuzhancell1/qunxiongtext")
        -- huobazhuzhancell1/cell
        local blnShow = false
        -- ���filterType>5 ˵�������ְҵ ���������ǵ��µİ�ť
        if filterType > 5 then
            if record.school == filterType then
                blnShow = true
            end
        else
            if filterType == 0 or record.type == filterType then
                blnShow = true
            end
        end
        if blnShow then
            iconWnd:ClearCornerImage(0)
            iconWnd:ClearCornerImage(2)
            iconWnd:ClearAllMaskImage()
            iconWnd:setText("")
            iconWnd:SetTextUnitText(CEGUI.String(""), YOFFECT)

            local upArrowState = false
            freeWnd:setVisible(true)
            -- ��ս�ͽ���û��ֱ�ӹ�ϵ ��Ӧ����һ���ж���
            if self:IsFightState(myID) then
                -- ��ս
                iconWnd:SetCornerImageAtPos("huobanui", "huoban_zhan", 0, 1, CHUZHANOFFSET, CHUZHANOFFSET);
                -- iconWnd:SetMaskImage(0,CEGUI.String("huobanui"),CEGUI.String("huoban_zhan"))
                iconWnd:ClearMaskImage(1)
                freeWnd:setVisible(false)
                if selectGroupId ~= activeGroupId then
                    upArrowState = true
                end
                if self:IsWeekFreeState(heroData) then
                    freeWnd:setText(self.mWord_benzhoumianfei)
                    upArrowState = true
                    freeWnd:setVisible(true)
                end
            end
            if self:IsLockState(heroData) then
                -- ����
                iconWnd:SetCornerImageAtPos("huobanui", "huoban_suo", 0, 1, SUOOFFSETX, SUOOFFSETY);
                local imageIdGrey = gGetIconManager():GetImageByID(record.headid + 10000)
                iconWnd:SetImage(imageIdGrey)
                -- iconWnd:SetMaskImage(0,CEGUI.String("huobanui"),CEGUI.String("huoban_suo"))
                -- iconWnd:SetMaskImage(3,CEGUI.String("huobanui"),CEGUI.String("huoban_mengban2"))
                freeWnd:setVisible(false)
            elseif self:IsFreeState(heroData) then
                -- ����ʹ��
                freeWnd:setVisible(false)
                upArrowState = true
            elseif self:IsWeekFreeState(heroData) then
                -- �������
                -- iconWnd:SetMaskImage(3,"huobanui","huoban_mengban1")
                freeWnd:setText(self.mWord_benzhoumianfei)
                upArrowState = true
                freeWnd:setVisible(true)
            else
                -- ��ʱ���
                freeWnd:setText(self:GetFreeTimeString(heroData))
                upArrowState = true
            end
            -- ��ʾ�����־
            if upArrowState and self:IsSelectState() then
                if not self:IsActiveGroupMember(myID) then
                    iconWnd:SetCornerImageAtPos("ccui1", "shangsheng", 2, 1);
                    -- iconWnd:SetMaskImage(4,CEGUI.String("huobanui"),CEGUI.String("huoban_UP"))
                end
            end
            -- ����CELLλ��.
            local xPos = 9.0
            if colIndex == 1 then
                xPos = 9.0 + cellWnd:getPixelSize().width + 10
            end
            local yPos = cellWnd:getPixelSize().height * enableIndex
            cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0,10 + yPos + 4.0 * enableIndex)))

            self.m_IconIDCollection[indexIcon + 1] = myID

            -- �����������õ�
            if enableIndex == 1 and colIndex==0 then
                self.m_threeCellname = prefixName .. "huobazhuzhancell1/cell"
            elseif enableIndex == 1 and colIndex==1 then
                self.m_fourCellname = prefixName .. "huobazhuzhancell1/cell"
            end

            if colIndex == 1 then
                enableIndex = enableIndex + 1
                colIndex = 0
            else
                colIndex = 1
            end

            indexIcon = indexIcon + 1
            -- ��ʾ
            cellWnd:setVisible(true)
        else
            cellWnd:setVisible(false)
        end
    end
    self.mWnd_cellHeroList:invalidate()

    -- ˢ������
    local members = MT3HeroManager.getInstance():getGroupMember(selectGroupId - 1)
    for j = 1, 4 do

        local iconWnd = self.m_Members[j]
        iconWnd:ClearCornerImage(0)
        iconWnd:ClearCornerImage(2)
        iconWnd:ClearAllMaskImage()
        iconWnd:ClearBackUpImage()
        iconWnd:SetImage(nil)
        -- ��ʾѡ�п�

        if j - 1 < members:size() then
            -- ��ʾͼ��
            iconWnd:SetStyle(1)
            local record = tableInstance:getRecorder(members[j - 1])
            local image = gGetIconManager():GetImageByID(record.headid)
            iconWnd:SetImage(image)
            iconWnd:SetEnableMaskClick(false)
            -- ��ʾ���źͽ���
            if self:IsSelectState() then
                if j == self.mSelectGroupPos then
                    -- ��ʾ����
                    iconWnd:SetMaskImage(0, CEGUI.String("huobanui"), CEGUI.String("huoban_jianhao"))
                    iconWnd:SetEnableMaskClick(true)
                elseif self.mSelectGroupPos ~= members:size() + 1 then
                    -- ��ʾ����
                    -- iconWnd:SetMaskImage(4,CEGUI.String("huobanui"),CEGUI.String("huoban_jiaohuan"))
                    iconWnd:SetCornerImageAtPos("huobanui", "huoban_jiaohuan", 2, 1);
                end
            end
        elseif j - 1 == members:size() then
            -- ��ʾ�Ӻ�
            iconWnd:SetStyle(0)
            iconWnd:SetImage("huobanui", "huoban_jiahao")
        end
        if i == self.m_SelectGroup and j == self.mSelectGroupPos then

            iconWnd:SetBackUpImage("huobanui", "huoban_kuang")
        end

    end

    self:refreshIconTableViewSize()
end


----------------------------------���д���---------------------------------
function HuoBanZhuZhanDialog.GetLayoutFileName()
    return "huobanzhuzhan.layout"
end

function HuoBanZhuZhanDialog.getInstance()
    LogInfo("enter get HuoBanZhuZhanDialog instance")
    if not _instance then
        _instance = HuoBanZhuZhanDialog:new()
        _instance:OnCreate()
    end

    return _instance
end

function HuoBanZhuZhanDialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function HuoBanZhuZhanDialog.getInstanceAndShow()
    LogInfo("enter HuoBanZhuZhanDialog instance show")

    if not _instance then
        _instance = HuoBanZhuZhanDialog:new()
        _instance:OnCreate()
    else
        LogInfo("set HuoBanZhuZhanDialog visible")
        _instance:SetVisible(true)
    end

    return _instance
end

function HuoBanZhuZhanDialog.getInstanceNotCreate()
    return _instance
end

function HuoBanZhuZhanDialog.ToggleOpenClose()
    if not _instance then
        _instance = HuoBanZhuZhanDialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function HuoBanZhuZhanDialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, HuoBanZhuZhanDialog)
    return self
end

function HuoBanZhuZhanDialog:getThreeCellName()
    return self.m_threeCellname
end
function HuoBanZhuZhanDialog:getFourCellName()
    return self.m_fourCellname
end
return HuoBanZhuZhanDialog


