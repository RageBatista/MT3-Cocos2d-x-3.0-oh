Familyfulidiacell = { }

setmetatable(Familyfulidiacell, Dialog)
Familyfulidiacell.__index = Familyfulidiacell
local prefix = 0

function Familyfulidiacell.GetLayoutFileName()
    return "familyfulidiacell.layout"
end

function Familyfulidiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfulidiacell)
    return self
end

function Familyfulidiacell:OnCreate(pParentDlg, id)
    Dialog.OnCreate(self, pParentDlg, id)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)

     

    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyfulidiacell/diban"))
    self.m_Icon = winMgr:getWindow(prefixstr .. "familyfulidiacell/fulidikuang/icon")
	self.m_Icon1 = winMgr:getWindow(prefixstr .. "familyfulidiacell/fulidikuang/icon1")
    self.m_NameText = winMgr:getWindow(prefixstr .. "familyfulidiacell/fuliname")
    self.m_DescText = winMgr:getWindow(prefixstr .. "familyfulidiacell/text")
    self.m_OpenBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyfulidiacell/dibang/open"))
    self.m_LingQuBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyfulidiacell/dibang/lingqu"))

    -- 公会分红
    self.m_TextUnder = winMgr:getWindow(prefixstr .. "familyfulidiacell/fenhong")
    self.m_GoldText = winMgr:getWindow(prefixstr .. "familyfulidiacell/fenhong/shuzi")
    self.m_HuoBiIcon = winMgr:getWindow(prefixstr .. "familyfulidiacell/huobiicon")
    self.m_Hongdian = winMgr:getWindow(prefixstr .. "familyfulidiacell/diban/hongqiu")
    self.m_TextWeekfuli = winMgr:getWindow(prefixstr .. "familyfulidiacell/diban/meizhoufuli")

    self.m_width = self:GetWindow():getPixelSize().width
	self.m_height = self:GetWindow():getPixelSize().height 

    -- 1 显示打开  2 显示领取
    self.m_Mode = 1
    self.id = 0
end

-- 创建cell
function Familyfulidiacell.CreateNewDlg(pParentDlg, id)
    LogInfo("enter familyfulidiacell.CreateNewDlg")
    local newDlg = Familyfulidiacell:new()
    newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

-- 设置信息
function Familyfulidiacell:SetInfor(infor)
    -- 设置Code
    -- 名字
    self.m_ID = infor.id
    self.m_NameText:setText(infor.name)
    -- 设置图片
    self.m_Icon:setProperty("Image", infor.icon)
	self.m_Icon1:setProperty("Image", infor.icon2)
    -- 设置描述
    self.m_DescText:setText(infor.desc)
    self:SetMode(infor.isgive)
    -- 公会分红
    self.m_TextUnder:setVisible(infor.id == 5)
    self.m_HuoBiIcon:setVisible(infor.id == 5)
    self.m_TextWeekfuli:setVisible(infor.id == 5)
    if infor.id == 5 then 
         self.m_DescText:setVisible(false);
    else 
         self.m_DescText:setVisible(true);
    end 

    self.id = infor.id
    --[[    -- 修炼技能45
    if self.m_ID == 1 then
        self.m_OpenBtn:setEnabled(gGetDataManager():GetMainCharacterLevel() >= 45)
        self.m_LingQuBtn:setEnabled(gGetDataManager():GetMainCharacterLevel() >= 45)
    elseif self.m_ID == 2 then
        self.m_OpenBtn:setEnabled(gGetDataManager():GetMainCharacterLevel() >= 35)
        self.m_LingQuBtn:setEnabled(gGetDataManager():GetMainCharacterLevel() >= 35)
    end]]
end

-- 设置按钮显示模式
-- 0 显示打开  1 显示领取
function Familyfulidiacell:SetMode(mode)
    self.m_Mode = mode
    self.m_OpenBtn:setVisible(self.m_Mode == 0)
    self.m_LingQuBtn:setVisible(self.m_Mode == 1)
end

-- 设置分红数字
function Familyfulidiacell:SetFenHongNumber(bonus)
    self.m_GoldText:setText(tostring(bonus))
    if bonus <= 0 then
        self.m_LingQuBtn:setEnabled(false)
        if self.id == 5 then
            self.m_Hongdian:setVisible(false)
        end
    else
        self.m_LingQuBtn:setEnabled(true)
        if self.id == 5 then
            self.m_Hongdian:setVisible(true)
        end
    end
end

return Familyfulidiacell
