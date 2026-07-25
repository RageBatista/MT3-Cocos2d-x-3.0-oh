LeiTaiGuanZhan = { }

setmetatable(LeiTaiGuanZhan, Dialog)
LeiTaiGuanZhan.__index = LeiTaiGuanZhan
local prefix = 0

function LeiTaiGuanZhan.CreateNewDlg(parent)
    local newDlg = LeiTaiGuanZhan:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function LeiTaiGuanZhan.GetLayoutFileName()
    return "leitaiguanzhan_mtg.layout"
end

function LeiTaiGuanZhan:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiGuanZhan)
    return self
end

function LeiTaiGuanZhan:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_Tips1 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/zudui")
    self.m_Tips2 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/zudui2")
    self.m_ItemCell1 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/itemcell"))
    self.m_ZhiYeIcon1 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/tubiao")
    self.m_ItemCell2 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/itemcell2"))
    self.m_ZhiYeIcon2 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/tubiao2")
    self.m_LookFightButton = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/btnguanzhan"))
    self.m_NameText1 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/name")
    self.m_NameText2 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/name2")
    self.m_ZuDuiText1 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/ji1")
    self.m_ZuDuiText2 = winMgr:getWindow(prefixstr .. "leitaiguanzhan_mtg/ji2")
end

function LeiTaiGuanZhan:SetInfor(infor)
    if not infor then
        return
    end
    local Role1 = infor.role1
    local Role2 = infor.role2
    if not Role1 or not Role2 then
        return
    end
    self.m_RoleID1 = Role1.roleid
    self.m_RoleID2 = Role2.roleid
    self.m_LookFightButton:setID(self.m_RoleID1)
    local shapeConf1 = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(Role1.shape)
    if shapeConf1.id ~= -1 then
        roleHeadID = shapeConf1.littleheadID
        local image1 = gGetIconManager():GetImageByID(roleHeadID)
        self.m_ItemCell1:SetImage(image1)
    end
    if Role1.teamnum > 0 then
        self.m_ItemCell1:SetCornerImageAtPos("teamui", "team_dui", 0, 1)
    else
        self.m_ItemCell1:SetCornerImageAtPos(nil, 0, 1)
    end
     

    local shapeConf2 = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(Role2.shape)
    if shapeConf2.id ~= -1 then
        roleHeadID = shapeConf2.littleheadID
        local image2 = gGetIconManager():GetImageByID(roleHeadID)
        self.m_ItemCell2:SetImage(image2)
    end

    if Role2.teamnum > 0 then
        self.m_ItemCell2:SetCornerImageAtPos("teamui", "team_dui", 0, 1)
    else
        self.m_ItemCell2:SetCornerImageAtPos(nil, 0, 1)
    end
    self.m_ItemCell1:SetTextUnitText(CEGUI.String(tostring(Role1.level)))
    self.m_ItemCell2:SetTextUnitText(CEGUI.String(tostring(Role2.level)))
    local schoolName1 = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(Role1.school)
    if schoolName1 then
        -- 职业图标
        self.m_ZhiYeIcon1:setProperty("Image", schoolName1.schooliconpath)
    end
    local schoolName2 = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(Role2.school)
    if schoolName2 then
        -- 职业图标
        self.m_ZhiYeIcon2:setProperty("Image", schoolName2.schooliconpath)
    end
    self.m_NameText1:setText(Role1.rolename)
    self.m_NameText2:setText(Role2.rolename)
    self.m_ZuDuiText1:setText(tostring(Role1.teamnum) .. "/" .. tostring(Role1.teamnummax))
    self.m_ZuDuiText2:setText(tostring(Role2.teamnum) .. "/" .. tostring(Role2.teamnummax))


    self.m_ZuDuiText1:setVisible(Role1.teamnummax ~= 0)
    self.m_ZuDuiText2:setVisible(Role2.teamnummax ~= 0)
    local text = ""


    if Role1.teamnummax == 0 then
        text = MHSD_UTILS.get_resstring(11365)
        self.m_Tips1:setText(text)
    else
        text = MHSD_UTILS.get_resstring(1442)
        self.m_Tips1:setText(text)
    end

    if Role2.teamnummax == 0 then
        text = MHSD_UTILS.get_resstring(11365)
        self.m_Tips2:setText(text)
    else
        text = MHSD_UTILS.get_resstring(1442)
        self.m_Tips2:setText(text)
    end
end

return LeiTaiGuanZhan
