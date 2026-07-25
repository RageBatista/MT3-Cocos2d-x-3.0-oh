LeiTaiCell = { }

setmetatable(LeiTaiCell, Dialog)
LeiTaiCell.__index = LeiTaiCell
local prefix = 0

function LeiTaiCell.CreateNewDlg(parent)
    local newDlg = LeiTaiCell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function LeiTaiCell.GetLayoutFileName()
    return "leitaicell_mtg.layout"
end

function LeiTaiCell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiCell)
    return self
end

function LeiTaiCell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_ItemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "leitaicell_mtg/itemcell"))
    self.m_NameText = winMgr:getWindow(prefixstr .. "leitaicell_mtg/mingzi")
    self.m_ZhiYeIcon = winMgr:getWindow(prefixstr .. "leitaicell_mtg/tubiao")
    self.m_ZhiYeText = winMgr:getWindow(prefixstr .. "leitaicell_mtg/zhiye")
    self.m_FightButton = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "leitaicell_mtg/btn"))

    -- self.m_FightButton:subscribeEvent("Clicked", LeiTaiCell.OnclikcedFightButton, self)

end
-- 设置信息
function LeiTaiCell:SetInfor(infor)
    if not infor then
        return
    end
    self.m_ID = infor.roleid
    self.m_FightButton:setID(self.m_ID)
    self.m_NameText:setText(tostring(infor.rolename))
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(infor.school)
    if schoolName then
        -- 职业图标
        self.m_ZhiYeIcon:setProperty("Image", schoolName.schooliconpath)
    end
    self.m_ZhiYeText:setText(schoolName.name)
    self.m_ItemCell:SetTextUnitText(CEGUI.String(tostring(infor.level)))
    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(infor.shape)
        if shapeConf.id ~= -1 then
            roleHeadID = shapeConf.littleheadID
            local image = gGetIconManager():GetImageByID(roleHeadID)
            self.m_ItemCell:SetImage(image)
        end
end

return LeiTaiCell
