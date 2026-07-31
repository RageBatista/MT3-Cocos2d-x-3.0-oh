require "logic.dialog"

lyshc1 = {}
setmetatable(lyshc1, Dialog)
lyshc1.__index = lyshc1

local _instance
function lyshc1.getInstance()
	if not _instance then
		_instance = lyshc1:new()
		_instance:OnCreate()
	end
	return _instance
end

function lyshc1.getInstanceAndShow()
	if not _instance then
		_instance = lyshc1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function lyshc1.getInstanceNotCreate()
	return _instance
end

function lyshc1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function lyshc1.ToggleOpenClose()
	if not _instance then
		_instance = lyshc1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function lyshc1.GetLayoutFileName()
	return "lyshc1.layout"
end

function lyshc1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, lyshc1)
	return self
end

function lyshc1:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_hc1hs11 = CEGUI.Window.toPushButton(winMgr:getWindow("lyshc1/hs1"))
	self.m_hc1hs11:subscribeEvent("Clicked", lyshc1.hc1hs1, self)

	self.m_item = CEGUI.toItemCell(winMgr:getWindow("lyshc1/item"))
	self.m_item:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

	self.m_NoBtn = CEGUI.toPushButton(winMgr:getWindow("lyshc1/btn11"))---取消按钮
	self.m_CloseBtn = CEGUI.toPushButton(winMgr:getWindow("lyshc1/close")) ---关闭按钮
	self.m_NoBtn:subscribeEvent("Clicked", lyshc1.OnClickedNoBtn, self)
	self.m_CloseBtn:subscribeEvent("Clicked", lyshc1.OnClickedCloseBtn, self)
	
	-- 新增加 812
local itemid = GameTable.common.GetCCommonTableInstance():getRecorder(812)
local itemid1 = tonumber(itemid.value)
local itemnum = GameTable.common.GetCCommonTableInstance():getRecorder(996)
local itemnum1 = tonumber(itemnum.value)

local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid1)
if not needItemCfg1 then
    return
end
self.m_item:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
SetItemCellBoundColorByQulityItemWithId(self.m_item,needItemCfg1.id)
self.m_item:setID(needItemCfg1.id)
local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
local strNumNeed_own1 = nOwnItemNum1.."/"..itemnum1
self.m_item:SetTextUnit(strNumNeed_own1)
if nOwnItemNum1 >= itemnum1 then
    self.m_item:SetTextUnitColor(MHSD_UTILS.get_greencolor())
else
    self.m_item:SetTextUnitColor(MHSD_UTILS.get_redcolor())
end

end

TaskHelper.m_hc1hs11 = 254201


function lyshc1.hc1hs1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


function lyshc1:OnClickedNoBtn(args)
            self:DestroyDialog()
end

function lyshc1:OnClickedCloseBtn(args)
        self:DestroyDialog()
end

return lyshc1
