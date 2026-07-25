require "logic.dialog"

TitleCell = {}
setmetatable(TitleCell, Dialog)
TitleCell.__index = TitleCell

local _instance
local prefix= 0
function TitleCell.getInstance()
	if not _instance then
		_instance = TitleCell:new()
		_instance:OnCreate()
	end
	return _instance
end

function TitleCell.getInstanceAndShow()
	if not _instance then
		_instance = TitleCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function TitleCell.getInstanceNotCreate()
	return _instance
end

function TitleCell.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TitleCell.ToggleOpenClose()
	if not _instance then
		_instance = TitleCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TitleCell.CreateNewDlg(parent)
	local newDlg = TitleCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end
function TitleCell.GetLayoutFileName()
	return "chengweicell_mtg.layout"
end

function TitleCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TitleCell)
	return self
end

function TitleCell:OnCreate(parent )
    prefix = prefix + 1
	Dialog.OnCreate(self, parent,prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)
    self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "chengweicell_mtg"))
	self.bufftips = winMgr:getWindow(prefixstr.."chengweicell_mtg/bufftips")
    self.window:EnableClickAni(false)
    self.name = winMgr:getWindow(prefixstr.."chengweicell_mtg/name")
end
function TitleCell:setData(id)
    if id < 0 then 
        self.name:setText(MHSD_UTILS.get_resstring(11325))
        self.bufftips:setVisible(false)  -- 没有称谓，隐藏 bufftips
    else 
        local titleRecord = BeanConfigManager.getInstance():GetTableByName("title.ctitleconfig"):getRecorder(id)
        local titleName = titleRecord.titlename
        self.name:setText(titleName)

        -- 判断获得方式是否为空
        if titleRecord.gettype and titleRecord.gettype ~= "" then  -- 获得方式不为空
            self.bufftips:setVisible(true)  -- 显示 bufftips
        else
            self.bufftips:setVisible(false) -- 隐藏 bufftips
        end
    end
end
return TitleCell
