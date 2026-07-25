-------------------------------------------------------------------------------------------
-- 数字小键盘
-------------------------------------------------------------------------------------------
require "logic.dialog"

NumKeyboardDlg = {}
setmetatable(NumKeyboardDlg, Dialog)
NumKeyboardDlg.__index = NumKeyboardDlg

local _instance
function NumKeyboardDlg.getInstance()
	if not _instance then
		_instance = NumKeyboardDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function NumKeyboardDlg.getInstanceAndShow(parent)
	if not _instance then
		_instance = NumKeyboardDlg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NumKeyboardDlg.getInstanceNotCreate()
	return _instance
end

function NumKeyboardDlg.DestroyDialog()
	if _instance then 
		if _instance.closeCallfunc then
			_instance.closeCallfunc.func(_instance.closeCallfunc.target)
		end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NumKeyboardDlg.ToggleOpenClose()
	if not _instance then
		_instance = NumKeyboardDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NumKeyboardDlg.GetLayoutFileName()
	return "xiaojianpan_mtg.layout"
end

function NumKeyboardDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NumKeyboardDlg)
	return self
end

function NumKeyboardDlg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	for i=0, 9 do
		local num = winMgr:getWindow("xiaojianpan_mtg/btn" .. i)
		num:setID(i)
		num:subscribeEvent("MouseButtonDown", NumKeyboardDlg.handleNumClicked, self)
	end

	self.delBtn = CEGUI.toPushButton(winMgr:getWindow("xiaojianpan_mtg/btnfanhui"))
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("xiaojianpan_mtg/btnok"))

	self.delBtn:subscribeEvent("MouseButtonDown", NumKeyboardDlg.handleBackspaceClicked, self)
	self.okBtn:subscribeEvent("Clicked", NumKeyboardDlg.handleOkClicked, self)

	self.inputNums = {}
	self.maxLength = 100
	self.maxValue = -1 --no limit
    self.minValue = 0
    self.m_Msg = ""
end
function NumKeyboardDlg:setMaxMsg(msg)
    self.m_Msg = msg
end
--触发小键盘的按钮，如果点击的是这个按钮就不自动关闭小键盘
function NumKeyboardDlg:setTriggerBtn(btn)
	self.triggerBtn = btn
end

--设置数字改变时的回调
function NumKeyboardDlg:setInputChangeCallFunc(func, target)
	self.callfunc = { target=target, func=func }
end

--键盘关闭时回调
function NumKeyboardDlg:setCloseCallFunc(func, target)
	self.closeCallfunc = { target=target, func=func }
end

--退格键是否清空输入
function NumKeyboardDlg:setAllowClear(b)
	self.allowClear = b
end

--可输入的最大长度
function NumKeyboardDlg:setMaxLength(length)
	self.maxLength = length
end

--可输入的最大值
function NumKeyboardDlg:setMaxValue(value)
	self.maxValue = value
end

function NumKeyboardDlg:setMinValue(value)
	self.minValue = value
end

function NumKeyboardDlg:setNumber(num)
	self.inputNums = {}
	local n = #tostring(num)
	for i=n-1, 0, -1 do
		table.insert(self.inputNums, math.floor(num / (10^i))%10)
	end
end

function NumKeyboardDlg:handleNumClicked(args)
	if #self.inputNums == self.maxLength then
		return
	end

	local btn = CEGUI.toWindowEventArgs(args).window

	if self.maxValue ~= -1 and tonumber(table.concat(self.inputNums)) == self.maxValue then
        if self.m_Msg == "" then
            GetCTipsManager():AddMessageTipById(160044) --输入数字超出范围！
        else
            GetCTipsManager():AddMessageTip(self.m_Msg)
        end
		
        btn:activate()
		return
	end

	if #self.inputNums == 1 and self.inputNums[1] == 0 then
		table.remove(self.inputNums)
	end
	
	
	table.insert(self.inputNums, btn:getID())
	
	if self.maxValue ~= -1 and tonumber(table.concat(self.inputNums)) > self.maxValue then
		self.inputNums = {}
		local n = #tostring(self.maxValue)
		for i=n-1, 0, -1 do
			table.insert(self.inputNums, math.floor(self.maxValue / (10^i))%10)
		end
        if self.m_Msg == "" then
            GetCTipsManager():AddMessageTipById(160044) --输入数字超出范围！
        else
            GetCTipsManager():AddMessageTip(self.m_Msg)
        end
	end

    if tonumber(table.concat(self.inputNums)) < self.minValue then
		self.inputNums = {}
		local n = #tostring(self.minValue)
		for i=n-1, 0, -1 do
			table.insert(self.inputNums, math.floor(self.minValue / (10^i))%10)
		end
		GetCTipsManager():AddMessageTipById(160044) --输入数字超出范围！
	end


	if self.callfunc then
		self.callfunc.func(self.callfunc.target, tonumber(table.concat(self.inputNums)))
	end
end

function NumKeyboardDlg:handleBackspaceClicked(args)
	if #self.inputNums > 0 then
		table.remove(self.inputNums)
	end
	
	if #self.inputNums == 0 then
		if self.callfunc then
			if self.allowClear then
				self.callfunc.func(self.callfunc.target, nil)
			else
				self.callfunc.func(self.callfunc.target, 0)
			end
		end
	else
		if self.callfunc then
			self.callfunc.func(self.callfunc.target, tonumber(table.concat(self.inputNums)))
		end
	end
end

function NumKeyboardDlg:handleOkClicked(args)
	NumKeyboardDlg.DestroyDialog()
end

return NumKeyboardDlg
