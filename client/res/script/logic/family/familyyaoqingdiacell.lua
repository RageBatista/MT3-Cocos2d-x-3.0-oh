FamilyYaoQingDiaCell = {}

setmetatable(FamilyYaoQingDiaCell, Dialog)
FamilyYaoQingDiaCell.__index = FamilyYaoQingDiaCell
local prefix = 0

function FamilyYaoQingDiaCell.CreateNewDlg(parent)
	local newDlg = FamilyYaoQingDiaCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function FamilyYaoQingDiaCell.GetLayoutFileName()
	return "familyyaoqingdiacell.layout"
end

function FamilyYaoQingDiaCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyYaoQingDiaCell)
	return self
end

function FamilyYaoQingDiaCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    -- �װ壨���ڵ��������
	self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/dibang"))

    -- ְҵͼ��
	self.m_ImageIcon = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/zhiyeicon")

    -- �����Ϣ
	self.m_Name = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/name")
	self.m_Sex = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/xingbie")
	self.m_Level = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/dengji")
	self.m_ZhiYe = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/zhiye")
	self.m_PingJia = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/pingfen")
	self.m_Vip = winMgr:getWindow(prefixstr .. "familyyaoqingdiacell/VIP")

end

-- ����cell��Ϣ
function FamilyYaoQingDiaCell:SetCellInfo(Infor)
    if Infor then
        -- ְҵͼ��
        local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(Infor.school)
        if schoolName then
            self.m_ImageIcon:setProperty("Image", schoolName.schooliconpath)
        end

        -- �������
        self.m_Name:setText(Infor.rolename)
        -- ����Ա�
        if Infor.sex == eSex_Man then
            self.m_Sex:setText(MHSD_UTILS.get_resstring(eResTipID_Man))
        elseif Infor.sex == eSex_Woman then
            self.m_Sex:setText(MHSD_UTILS.get_resstring(eResTipID_Woman))
        else
            self.m_Sex:setText(Infor.sex)
        end
        -- ��ҵȼ�
        local rolelv = ""..Infor.level
    if Infor.level>1000 then
        local zscs,t2 = math.modf(Infor.level/1000)
        rolelv = zscs..""..(Infor.level-zscs*1000)
    end
        self.m_Level:setText(tostring(rolelv))
        -- ���ְҵ
        if schoolName then
            self.m_ZhiYe:setText(schoolName.name)
        end
        -- ����ۺ�ս��
        self.m_PingJia:setText(Infor.fightvalue)
        -- ���VIP
        self.m_Vip:setText(Infor.vip)
    end
end

return FamilyYaoQingDiaCell