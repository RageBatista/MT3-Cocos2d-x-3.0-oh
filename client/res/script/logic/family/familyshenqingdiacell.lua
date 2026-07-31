Familyshenqingdiacell = { }

setmetatable(Familyshenqingdiacell, Dialog)
Familyshenqingdiacell.__index = Familyshenqingdiacell
local prefix = 0

function Familyshenqingdiacell.CreateNewDlg(parent)
    local newDlg = Familyshenqingdiacell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyshenqingdiacell.GetLayoutFileName()
    return "familyshenqingdiacell.layout"
end

function Familyshenqingdiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyshenqingdiacell)
    return self
end

function Familyshenqingdiacell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)
    -- ͼ��Icon
    self.m_ImageIcon = winMgr:getWindow(prefixstr .. "familyshenqingdiacell/zhiyeicon")
    self.m_ID = 0
    -- ��ť�װ�
    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyshenqingdiacell/diban"))
    self.m_Btn:EnableClickAni(false)
    -- ����
    self.m_PersonName = winMgr:getWindow(prefixstr .. "familyshenqingdiacell/name")
    -- �ȼ�
    self.m_Level = winMgr:getWindow(prefixstr .. "familyshenqingdiacell/level")
    -- ְҵ
    self.m_Zhiye = winMgr:getWindow(prefixstr .. "familyshenqingdiacell/zhiye")
    -- ID
    self.m_IDText = winMgr:getWindow(prefixstr .. "familyshenqingdiacell/ID")
	
	 -- �ۺ�ս��
    self.m_fightvalue = winMgr:getWindow(prefixstr .. "familyshenqingdiacell/zonghe")
	
    local datamanager = require "logic.faction.factiondatamanager"
    local infor = datamanager.GetMyZhiWuInfor()
	
	 
   
	 

    -- ȷ�Ͻ���
    self.m_YesBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyshenqingdiacell/yes"))
    -- �ܾ�
    self.m_NoBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyshenqingdiacell/no"))
    if infor then
        if infor.clearapplylist == 0 then
            self.m_YesBtn:setEnabled(true)
            self.m_NoBtn:setEnabled(true)
        end
    end
    -- ����
    self.m_ChatBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyshenqingdiacell/siliao"))
end
-- ������Ϣ
function Familyshenqingdiacell:SetInfor(infor)
    self.m_ID = infor.roleid
    self.m_ChatBtn:setID(infor.roleid)
    self.m_IDText:setText(tostring(infor.roleid))
    self.m_YesBtn:setID(infor.roleid)
    self.m_NoBtn:setID(infor.roleid)
    self.m_PersonName:setText(infor.rolename)
    local rolelv = ""..infor.rolelevel
    if infor.rolelevel>1000 then
        local zscs,t2 = math.modf(infor.rolelevel/1000)
        rolelv = zscs..""..(infor.rolelevel-zscs*1000)
    end
    self.m_Level:setText(tostring(rolelv))
	--print("infor.fightvalue =========== " .. infor.fightvalue )
	self.m_fightvalue:setText(tostring(infor.fightvalue))  -- �ۺ�ս��
	 
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(infor.roleschool)
    if schoolName then
        self.m_Zhiye:setText(schoolName.name)
        self.m_ImageIcon:setProperty("Image", schoolName.schooliconpath)
    end
end

return Familyshenqingdiacell
