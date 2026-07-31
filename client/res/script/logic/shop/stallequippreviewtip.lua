------------------------------------------------------------------
-- 摆摊装备搜索装备预览
------------------------------------------------------------------

require "logic.dialog"

StallEquipPreviewTip = {}
setmetatable(StallEquipPreviewTip, Dialog)
StallEquipPreviewTip.__index = StallEquipPreviewTip

local _instance
function StallEquipPreviewTip.getInstance()
	if not _instance then
		_instance = StallEquipPreviewTip:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallEquipPreviewTip.getInstanceAndShow()
	if not _instance then
		_instance = StallEquipPreviewTip:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallEquipPreviewTip.getInstanceNotCreate()
	return _instance
end

function StallEquipPreviewTip.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallEquipPreviewTip.ToggleOpenClose()
	if not _instance then
		_instance = StallEquipPreviewTip:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallEquipPreviewTip.GetLayoutFileName()
	return "baitanequippreview.layout"
end

function StallEquipPreviewTip:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallEquipPreviewTip)
	return self
end

function StallEquipPreviewTip:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.nameText = winMgr:getWindow("equipprevicetip/namebg/name")

	self.attrTexts = {}
	self.valueTexts = {}
	for i=1,3 do
		self.attrTexts[i] = winMgr:getWindow("equipprevicetip/attr" .. i)
		self.valueTexts[i] = winMgr:getWindow("equipprevicetip/val" .. i)
	end

end

function StallEquipPreviewTip:setEquipName(name)
	self.nameText:setText(name)
end

--同一名称的装备，不同的品质，对应的id不同，但属性类型一样
function StallEquipPreviewTip:setEquipItemIds(itemids)
	if #itemids == 0 then
		return
	end

	local function getFirst(vec)
		if vec:size() > 0 then
			return vec[0]
		end
		return 0
	end

	local function getLast(vec)
		if vec:size() > 0 then
			return vec[vec:size()-1]
		end
		return 0
	end


	local attrs = {}
	for i=1,3 do
		local attr = {}
		attr.id = 0
		attr.min = 1000000
		attr.max = 0
		attrs[i] = attr
	end

	for i,id in ipairs(itemids) do
		local equipAttr = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(id)
        if equipAttr then
		    local info = BeanConfigManager.getInstance():GetTableByName("item.cequipiteminfo"):getRecorder(equipAttr.baseAttrId)
            if info then
		        attrs[1].id = info.shuxing1id
		        attrs[1].min = math.min(attrs[1].min, getFirst(info.shuxing1bodongduanmin))
		        attrs[1].max = math.max(attrs[1].max, getLast(info.shuxing1bodongduanmax))

		        attrs[2].id = info.shuxing2id
		        attrs[2].min = math.min(attrs[2].min, getFirst(info.shuxing2bodongduanmin))
		        attrs[2].max = math.max(attrs[2].max, getLast(info.shuxing2bodongduanmax))

		        attrs[3].id = info.shuxing3id
		        attrs[3].min = math.min(attrs[3].min, getFirst(info.shuxing3bodongduanmin))
		        attrs[3].max = math.max(attrs[3].max, getLast(info.shuxing3bodongduanmax))
            end
        end
	end


	

	for i=1,3 do
		if attrs[i].id ~= 0 then
			local attr = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(attrs[i].id)
			self.attrTexts[i]:setText(attr.name)
			self.valueTexts[i]:setText("+" .. attrs[i].min .. "~" .. attrs[i].max)
		else
			self.attrTexts[i]:setVisible(false)
			self.valueTexts[i]:setVisible(false)
		end
	end
end

return StallEquipPreviewTip