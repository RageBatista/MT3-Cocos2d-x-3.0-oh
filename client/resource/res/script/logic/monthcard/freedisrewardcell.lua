FreedisRewardCell = {}

setmetatable(FreedisRewardCell, Dialog)
FreedisRewardCell.__index = FreedisRewardCell
local prefix = 0

function FreedisRewardCell.CreateNewDlg(parent)
	local newDlg = FreedisRewardCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function FreedisRewardCell.GetLayoutFileName()
	return "ziyoufenpeilibaocell.layout"
end

function FreedisRewardCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FreedisRewardCell)
	return self
end

function FreedisRewardCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
    self.window = winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell")
    self.m_add = winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell/jiahao")
    self.m_sub = winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell/jianhao")
    self.m_numText = winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell/numbg/num")
	self.m_add:subscribeEvent("MouseClick", FreedisRewardCell.HandleAddClicked, self)
    self.m_sub:subscribeEvent("MouseClick", FreedisRewardCell.HandleSubClicked, self)
    self.m_item = CEGUI.toItemCell(winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell/item"))
    self.m_itemName = winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell/name")
	self.m_itemNamec = winMgr:getWindow(prefixstr.."ziyoufenpeilibaocell/item/namec")
    self:setNum(0)
end
function FreedisRewardCell:HandleAddClicked(e)
    local dlg = require"logic.monthcard.freedisrewarddlg".getInstanceNotCreate()
    if dlg then
        if dlg.m_unNum <= 0 then
            GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(190069))
        else
            dlg:ChangeNum(self.window:getID(), -1)
            self:setNum(self.m_num + 1)
        end
        
    end
end
function FreedisRewardCell:HandleSubClicked(e)
    local dlg = require"logic.monthcard.freedisrewarddlg".getInstanceNotCreate()
    if self.m_num > 0 then
        if dlg then
            dlg:ChangeNum(self.window:getID(), 1)
            self:setNum(self.m_num - 1)
        end
    end
end
function FreedisRewardCell:setNum(num)
    self.m_num = num 
    self.m_numText:setText(num)
    if num == 0 then
        self.m_sub:setEnabled(false)
    else
        self.m_sub:setEnabled(true)
    end
end
function FreedisRewardCell:refreshUI(index)
    local dlg = require"logic.monthcard.freedisrewarddlg".getInstanceNotCreate()
    if dlg then
        local itemid = dlg.m_ItemS[index + 1]
        local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
        if itembean then
		    self.m_item:SetImage(gGetIconManager():GetItemIconByID( itembean.icon))
            SetItemCellBoundColorByQulityItemWithIdtm(self.m_item,itembean.id)
            ShowItemTreasureIfNeedtm(self.m_item,itembean.id)
            self.m_itemName:setText(itembean.name)
			self.m_itemNamec:setText(itembean.namecc5)
        end        
    end
end

return FreedisRewardCell