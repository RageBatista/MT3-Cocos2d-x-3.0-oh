Familychengyuandiacell = { }

setmetatable(Familychengyuandiacell, Dialog)
Familychengyuandiacell.__index = Familychengyuandiacell

function Familychengyuandiacell.CreateNewDlg(parent, id)
    local newDlg = Familychengyuandiacell:new()
    newDlg:OnCreate(parent, id)
    return newDlg
end

function Familychengyuandiacell.GetLayoutFileName()
    return "familychengyuandiacell.layout"
end

function Familychengyuandiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familychengyuandiacell)
    return self
end

function Familychengyuandiacell:OnCreate(parent, id)
    Dialog.OnCreate(self, parent, id)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)
    self.m_ID = 0
    -- cell��ʾģʽ
    -- Ĭ��ֵΪ0 �Ժ�ֵ�ı�
    self.m_Mode = 0
    -- �װ�
    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familychengyuandiacell/dibang"))
    self.m_Btn:EnableClickAni(false)
    -- ����
    self.m_Name = winMgr:getWindow(prefixstr .. "familychengyuandiacell/name")
    -- �ȼ�
    self.m_Level = winMgr:getWindow(prefixstr .. "familychengyuandiacell/level")
    -- ְҵ
    self.m_ZhiYe = winMgr:getWindow(prefixstr .. "familychengyuandiacell/zhiye")
    self.m_ZhiWu = winMgr:getWindow(prefixstr .. "familychengyuandiacell/zhiwu")
    self.m_BenZhouGongXian = winMgr:getWindow(prefixstr .. "familychengyuandiacell/benzhougongxian")
    self.m_XianYouGongXian = winMgr:getWindow(prefixstr .. "familychengyuandiacell/xianyougongxian")
    self.m_LiShiGongXian = winMgr:getWindow(prefixstr .. "familychengyuandiacell/lishigongxian")
    self.m_BenZhouYuanZhu = winMgr:getWindow(prefixstr .. "familychengyuandiacell/benzhouyuanzhu")
    self.m_LiShiYuanZhu = winMgr:getWindow(prefixstr .. "familychengyuandiacell/lishiyuanzhu")
    self.m_BenLunJingSai = winMgr:getWindow(prefixstr .. "familychengyuandiacell/benlunjingsai")
    self.m_LiShiJingSai = winMgr:getWindow(prefixstr .. "familychengyuandiacell/lishijingsai")
    self.m_JiaRuGongXian = winMgr:getWindow(prefixstr .. "familychengyuandiacell/jiarugonghui")
    self.m_LiXianShiJian = winMgr:getWindow(prefixstr .. "familychengyuandiacell/lixianshijian")
    self.m_ImageIcon = winMgr:getWindow(prefixstr .. "familychengyuandiacell/zhiyeicon")
	self.m_FightValue = winMgr:getWindow(prefixstr .. "familychengyuandiacell/dibang/zonghe") -- �ۺ�ս��
	 
	
    self.m_BianKuang = winMgr:getWindow(prefixstr .. "familychengyuandiacell/biankuang")
    self.m_BianKuang:setVisible(false)
    
end
-- ����cell����������
function Familychengyuandiacell:ResetVisible()
    self.m_Level:setVisible(false)
    self.m_ZhiYe:setVisible(false)
    self.m_ZhiWu:setVisible(false)
    self.m_BenZhouGongXian:setVisible(false)
    self.m_XianYouGongXian:setVisible(false)
    self.m_LiShiGongXian:setVisible(false)
    self.m_BenZhouYuanZhu:setVisible(false)
    self.m_LiShiYuanZhu:setVisible(false)
    self.m_BenLunJingSai:setVisible(false)
    self.m_LiShiJingSai:setVisible(false)
    self.m_JiaRuGongXian:setVisible(false)
    self.m_LiXianShiJian:setVisible(false)
	self.m_FightValue:setVisible(false)
end
-- ģʽ1 (�ȼ� ְҵ ְ�� ���ܰﹱ ���аﹱ ��ʷ�ﹱ )
-- ģʽ2 ������Ԯ�� ��ʷԮ�� ���־��� ��ʷ���� ���ʱ�� ����ʱ�䣩
function Familychengyuandiacell:SetMode(args)
    if type(args) == "number" then
        if self.m_Mode == args then return end
        self:ResetVisible()
        self.m_Mode = args
        if args == 1 then
            self.m_Level:setVisible(true)
            self.m_ZhiYe:setVisible(true)
            self.m_ZhiWu:setVisible(true)
            self.m_BenZhouGongXian:setVisible(true)
            self.m_XianYouGongXian:setVisible(true)
            self.m_LiShiGongXian:setVisible(true)
        elseif args == 2 then
            self.m_BenZhouYuanZhu:setVisible(true)
            self.m_LiShiYuanZhu:setVisible(true)
            self.m_BenLunJingSai:setVisible(true)
            self.m_JiaRuGongXian:setVisible(true)
            self.m_LiXianShiJian:setVisible(true)
            self.m_LiShiJingSai:setVisible(true)
		elseif args == 3 then	
			self.m_FightValue:setVisible(true)
        end

    end

end
-- ���ó�Աcell��Ϣ
function Familychengyuandiacell:SetInfor(Infor)
    if Infor then
        -- ����״̬
        self.m_JinYan = Infor.isbannedtalk
        -- ID
        self.m_ID = Infor.roleid
        local data = gGetDataManager():GetMainCharacterData()
        -- ����
        self.m_Name:setText(Infor.rolename)
        -- �ȼ�
        local rolelv = ""..Infor.rolelevel
    if Infor.rolelevel>1000 then
        local zscs,t2 = math.modf(Infor.rolelevel/1000)
        rolelv = zscs..""..(Infor.rolelevel-zscs*1000)
    end
        self.m_Level:setText(tostring(rolelv))
        -- ְҵ
        local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(Infor.school)
        if schoolName then
            self.m_ZhiYe:setText(schoolName.name)
            self.m_ImageIcon:setProperty("Image", schoolName.schooliconpath)
        end
        -- ְ��
        -- ��ʾְ��
        local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(Infor.position)
        if conf then
            self.m_ZhiWu:setText(conf.posname)
        end
		
		-- �ۺ�ս��
        self.m_FightValue:setText(tostring(Infor.fightvalue))
	 
		
        -- ���ܹ���
        self.m_BenZhouGongXian:setText(tostring(Infor.preweekcontribution))
        -- ���ܹ���
        self.m_XianYouGongXian:setText(tostring(Infor.weekcontribution))
        -- ����Ԯ��
        self.m_BenZhouYuanZhu:setText(tostring(Infor.weekaid))
        -- ����/��ʷ����
        self.m_LiShiGongXian:setText(tostring(Infor.rolecontribution.."/"..Infor.historycontribution))
        -- ��ʷԮ��
        self.m_LiShiYuanZhu:setText(tostring(Infor.historyaid))
        -- �μӹ���ս����
        self.m_LiShiJingSai:setText(tostring(Infor.clanfightnum))
        -- �μӹ��ḱ������
        self.m_BenLunJingSai:setText(tostring(Infor.claninstnum))
        -- ����ʱ��
        local tian =(Infor.jointime) / 3600
        if tian<=1 then
            local str = MHSD_UTILS.get_resstring(11266)
            if self.m_JiaRuGongXian then
                self.m_JiaRuGongXian:setText(str)
            end
        elseif tian >1 and  tian<24 then
            local str = MHSD_UTILS.get_resstring(11371)
            str = string.gsub(str, "%$parameter1%$",math.ceil(tian) )
            if self.m_JiaRuGongXian then
                self.m_JiaRuGongXian:setText(str)
            end
        else
            local str = MHSD_UTILS.get_resstring(11265)
            tian = math.floor(tian)
            str = string.gsub(str, "%$parameter1%$", math.ceil(tian/24))
            if self.m_JiaRuGongXian then
                self.m_JiaRuGongXian:setText(str)
            end
        end
        -- ���ߡ�ʱ��
        self.m_Lastonlinetime = Infor.lastonlinetime
        if Infor.lastonlinetime == 0 then
            local str = MHSD_UTILS.get_resstring(354)
            self.m_LiXianShiJian:setText(str)
        else
            local s1 = os.date("%y-%m-%d", Infor.lastonlinetime)
            self.m_LiXianShiJian:setText(s1)
        end
        self:RefreshJinYan()
    end
end

-- ˢ�½���״̬
function Familychengyuandiacell:RefreshJinYan()
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

        -- �������ȴ���
        if self.m_Lastonlinetime ~= 0 then
            ret = color[3]
        end
        self.m_Name:setProperty("TextColours", ret)
        self.m_Level:setProperty("TextColours", ret)
        self.m_ZhiYe:setProperty("TextColours", ret)
        self.m_ZhiWu:setProperty("TextColours", ret)

        self.m_BenZhouYuanZhu:setProperty("TextColours", ret)
        self.m_LiShiYuanZhu:setProperty("TextColours", ret)
        self.m_BenLunJingSai:setProperty("TextColours", ret)
        self.m_JiaRuGongXian:setProperty("TextColours", ret)
        self.m_LiXianShiJian:setProperty("TextColours", ret)
        self.m_LiShiJingSai:setProperty("TextColours", ret)

        self.m_BenZhouGongXian:setProperty("TextColours", ret)
        self.m_XianYouGongXian:setProperty("TextColours", ret)
        self.m_LiShiGongXian:setProperty("TextColours", ret)
		self.m_FightValue:setProperty("TextColours", ret)
    end
end

return Familychengyuandiacell
