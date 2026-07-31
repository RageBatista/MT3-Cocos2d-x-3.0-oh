ZhuangBeiXiLianCell = {}

setmetatable(ZhuangBeiXiLianCell, Dialog)
ZhuangBeiXiLianCell.__index = ZhuangBeiXiLianCell
local prefix = 0

function ZhuangBeiXiLianCell.CreateNewDlg(parent)
    local newDlg = ZhuangBeiXiLianCell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function ZhuangBeiXiLianCell.GetLayoutFileName()
    return "zhuangbeixiliancell.layout"
end

function ZhuangBeiXiLianCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhuangBeiXiLianCell)
    return self
end

function ZhuangBeiXiLianCell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "zhuangbeixiliancell"))
    self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "zhuangbeixiliancell/daojukuang"))
    self.name = winMgr:getWindow(prefixstr .. "zhuangbeixiliancell/mingcheng")

end

return ZhuangBeiXiLianCell