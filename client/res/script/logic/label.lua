require "logic.dialog"

local LabelDlgs = {}
LabelDlg = {}
setmetatable(LabelDlg, Dialog)
LabelDlg.__index = LabelDlg
function LabelDlg.new(prefix)
	local newLabel = {}
	print(prefix)
	setmetatable(newLabel, LabelDlg)
	newLabel.__index = newLabel
	newLabel:OnCreate(prefix)

	return newLabel
end

function LabelDlg.getLabelById(index)
	return LabelDlgs[index]
end

function LabelDlg:OnCreate(prefix)
	self.prefix = prefix
	local name_prefix = tostring(prefix)
	Dialog.OnCreate(self, nil, name_prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_labels = {}
	for i = 1, 4 do
		local wndname = i == 1 and name_prefix.."Lable/button" or name_prefix.."Lable/button"..i-1
		local btn = CEGUI.Window.toPushButton(winMgr:getWindow(wndname))
		local strImageRedName = name_prefix.."Lable/button/image"..i
		local imageRed =  winMgr:getWindow(strImageRedName)
		imageRed:setVisible(false)
		btn.imageRed = imageRed
		table.insert(self.m_labels, btn)
		
	end
	self.m_dlgs = {}
	LabelDlgs[prefix] = self
end

function LabelDlg:SetRedPointVisible(nIndex,bVisible)
	if 	nIndex<1 or 
		nIndex>4 or 
		nIndex>#self.m_labels
		then
		return
	end
	local btnLabel = self.m_labels[nIndex]
	btnLabel.imageRed:setVisible(bVisible)
end

function LabelDlg:GetLayoutFileName()
	--print("Get LabelDlg layout name")
	return "lable.layout"
end

function HideDialogs(tab)
  for k,v in pairs(tab) do
    if v:IsVisible() then
      v:SetVisible(false)
    end
  end
end

function LabelDlg.InitJianghu()
	--@DEPRECATED
end


function LabelDlg:InitButtons(arg1, arg2, arg3, arg4)
	local maxbuttonnum = #(self.m_labels)
	for i=1,maxbuttonnum do
		self.m_labels[i]:setVisible(false)
	end

	if arg1 then
		self.m_labels[1]:setVisible(true)
		self.m_labels[1]:setText(arg1)
	end
	if arg2 then
		self.m_labels[2]:setVisible(true)
		self.m_labels[2]:setText(arg2)
	end
	if arg3 then
		self.m_labels[3]:setVisible(true)
		self.m_labels[3]:setText(arg3)
	end
	if arg4 then
		self.m_labels[4]:setVisible(true)
		self.m_labels[4]:setText(arg4)
	end

end

function LabelDlg.RemoveLabel(prefix)
	LabelDlgs[prefix] = nil
end

function LabelDlg:OnClose()
	Dialog.OnClose(self)
	if self.prefix then
		LabelDlgs[self.prefix] = nil
	end

	for k,v in pairs(self.m_dlgs) do
	 v:OnClose()
	end
end

return LabelDlg
