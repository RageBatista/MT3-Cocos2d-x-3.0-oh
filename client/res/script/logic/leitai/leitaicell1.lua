LeiTaiCell1 = { }

setmetatable(LeiTaiCell1, Dialog)
LeiTaiCell1.__index = LeiTaiCell1
local prefix = 0

function LeiTaiCell1.CreateNewDlg(parent)
    local newDlg = LeiTaiCell1:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function LeiTaiCell1.GetLayoutFileName()
    return "leitaicell_mtg1.layout"
end

function LeiTaiCell1:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiCell1)
    return self
end

function LeiTaiCell1:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_ItemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "leitaicell_mtg1/itemcell"))
    self.m_NameText = winMgr:getWindow(prefixstr .. "leitaicell_mtg1/mingzi")
    self.m_ZhiYeIcon = winMgr:getWindow(prefixstr .. "leitaicell_mtg1/tubiao")
    self.m_PersonNumberText = winMgr:getWindow(prefixstr .. "leitaicell_mtg1/ji")
    self.m_FightButton = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "leitaicell_mtg1/btn"))


end
function LeiTaiCell1:SetInfor(infor)
    if not infor then
        return
    end
    self.m_ID = infor.roleid
    self.m_FightButton:setID(self.m_ID)
    self.m_NameText:setText(tostring(infor.rolename))
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(infor.school)
    if schoolName then
        -- Ö°ÒµÍ¼±ê
        self.m_ZhiYeIcon:setProperty("Image", schoolName.schooliconpath)
    end
    self.m_PersonNumberText:setText(tostring(infor.teamnum) .. "/" .. tostring(infor.teamnummax))
    self.m_ItemCell:SetTextUnitText(CEGUI.String(tostring(infor.level)))
    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(infor.shape)
        if shapeConf.id ~= -1 then
            roleHeadID = shapeConf.littleheadID
            local image = gGetIconManager():GetImageByID(roleHeadID)
            self.m_ItemCell:SetImage(image)
        end

     if infor.teamnum > 0 then
        self.m_ItemCell:SetCornerImageAtPos("teamui", "team_dui", 0, 1)
    else
        self.m_ItemCell:SetCornerImageAtPos(nil, 0, 1)
    end
end
return LeiTaiCell1
