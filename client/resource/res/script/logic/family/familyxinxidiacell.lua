require "logic.dialog"

Familyxinxidiacell = { }
setmetatable(Familyxinxidiacell, Dialog)
Familyxinxidiacell.__index = Familyxinxidiacell

local _instance
function Familyxinxidiacell.getInstance()
    if not _instance then
        _instance = Familyxinxidiacell:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyxinxidiacell.getInstanceAndShow()
    if not _instance then
        _instance = Familyxinxidiacell:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyxinxidiacell.getInstanceNotCreate()
    return _instance
end

function Familyxinxidiacell.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Familyxinxidiacell.ToggleOpenClose()
    if not _instance then
        _instance = Familyxinxidiacell:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyxinxidiacell.GetLayoutFileName()
    return "familyxinxidiacell.layout"
end

function Familyxinxidiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyxinxidiacell)
    return self
end

function Familyxinxidiacell:OnCreate(pParentDlg, id)
    Dialog.OnCreate(self, pParentDlg, id)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)
    -- ͼƬIcon
    self.m_IconImage = winMgr:getWindow(prefixstr .. "familyxinxidiacell/diban/icon")
    -- �װ�
    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyxinxidiacell/diban"))
    self.m_Btn:EnableClickAni(false)
    -- �����ı�
    self.m_NameText = winMgr:getWindow(prefixstr .. "familyxinxidiacell/name")
    -- �ȼ��ı�
    self.m_LevelText = winMgr:getWindow(prefixstr .. "familyxinxidiacell/level")
    -- ְҵ�ı�
    self.m_ZhiyeText = winMgr:getWindow(prefixstr .. "familyxinxidiacell/zhiye")
    -- ְ���ı�
    self.m_ZhiWuText = winMgr:getWindow(prefixstr .. "familyxinxidiacell/zhiwu")

    self.m_BianKuang = winMgr:getWindow(prefixstr .. "familyxinxidiacell/biankuang")
    self.m_BianKuang:setVisible(false)
   
    -- ��ɫID
    self.m_ID = 0
end

function Familyxinxidiacell.CreateNewDlg(pParentDlg, id)
    local newDlg = Familyxinxidiacell:new()
    newDlg:OnCreate(pParentDlg, id)

    return newDlg
end
-- ������Ϣ
-- ClanMember �ṹ��
function Familyxinxidiacell:SetInfor(Infor)
    if Infor then
        -- �Ƿ����
        self.m_JinYan = Infor.isbannedtalk
        -- ����id
        self.m_ID = Infor.roleid
        -- ��ʾ����
        self.m_NameText:setText(Infor.rolename)
        -- ��ʾ�ȼ�
        local rolelv = ""..Infor.rolelevel
    if Infor.rolelevel>1000 then
        local zscs,t2 = math.modf(Infor.rolelevel/1000)
        rolelv = zscs..""..(Infor.rolelevel-zscs*1000)
    end
        self.m_LevelText:setText(tostring(rolelv))
        -- ��ʾְ��
        local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(Infor.position)
        if conf then
            self.m_ZhiWuText:setText(conf.posname)
        end

        -- ��ʾְҵ
        local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(Infor.school)
        if schoolName then
            self.m_ZhiyeText:setText(schoolName.name)
            self.m_IconImage:setProperty("Image", schoolName.schooliconpath)
        end
        -- ˢ�½���״̬
        self:RefreshJinYan()
    end
end

-- ˢ�½���״̬
function Familyxinxidiacell:RefreshJinYan()
    if self.m_JinYan then
        local color =
        {
            -- ����
            [1] = "ff8c5e2a",
            -- ����
            [2] = "ff8c5e2a",
            -- ������
            [3] = "ff8c5e2a",
            -- ����
            [4] = "ff8c5e2a",
        }
        local ret = color[self.m_JinYan + 1]

        -- �����������������ɫ
        if self.m_JinYan == 0 and gGetDataManager():GetMainCharacterData().roleid == self.m_ID then
            ret = color[4]
        end

        self.m_NameText:setProperty("TextColours", ret)
        self.m_LevelText:setProperty("TextColours", ret)
        self.m_ZhiWuText:setProperty("TextColours", ret)
        self.m_ZhiyeText:setProperty("TextColours", ret)
    end
end
return Familyxinxidiacell
