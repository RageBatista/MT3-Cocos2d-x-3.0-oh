workshophccell = {}

setmetatable(workshophccell, Dialog)
workshophccell.__index = workshophccell
local prefix = 0

function workshophccell.CreateNewDlg(parent)
	local newDlg = workshophccell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function workshophccell.GetLayoutFileName()
	return "baoshihechengcell.layout"
end

function workshophccell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, workshophccell)
	return self
end

function workshophccell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "baoshihechengcell"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "baoshihechengcell/daojukuang"))
	self.num = winMgr:getWindow(prefixstr .. "baoshihechengcell/daojukuang/shuliang")
	self.name = winMgr:getWindow(prefixstr .. "baoshihechengcell/mingcheng")
	self.describe = winMgr:getWindow(prefixstr .. "baoshihechengcell/miaoshu")
	self.level = winMgr:getWindow(prefixstr .. "baoshihechengcell/mingchengLv")
	self.describe1 = winMgr:getWindow(prefixstr .. "baoshihechengcell/miaoshu1")
	self.describe11 = winMgr:getWindow(prefixstr .. "baoshihechengcell/miaoshu11")
	--self.value = winMgr:getWindow(prefixstr .. "baoshihechengcell/miaoshushuzhi")

    self.btnBg:subscribeEvent("MouseButtonUp", workshophccell.HandleBtnClicked, self)

end

function workshophccell:initInfoByTable(info)
    self.btnBg:setID(info.id)
	self.itemCell:SetImage(gGetIconManager():GetItemIconByID(info.nicon))
    SetItemCellBoundColorByQulityItemWithId(self.itemCell, info.nitemid)
    self.name:setText(info.strname)
    self.describe:setText(info.stradddes)
end

function workshophccell:HandleBtnClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local typeId = e.window:getID()
    local info = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getRecorder(typeId)
    local dlg = require "logic.workshop.workshophcnew":getInstanceNotCreate()
    if dlg then
        dlg:refreshGemType(info)
    end
    require "logic.workshop.gemtypelist".DestroyDialog()
    return true
end

return workshophccell