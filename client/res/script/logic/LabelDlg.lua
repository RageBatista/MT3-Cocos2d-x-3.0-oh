local super = require "logic.singletondialog";

enumLabel =
{
	enumPackLabel = 1,
	enumCharacterLabel = 2,
	enumWorkShopLabel = 3,
	enumPetLabel = 4,
	enumFactionLabel = 5,
	enumSettingLabel = 6,
	enumRanSeLabel = 7,
    enumFriendMailLabel = 8,
	enumLabelMax = 9
};

LABEL_NUM = 5;

CLabelDlg = {
	d_labels = { },
	d_usedLabel = 0,
	d_curshow = - 1
};
setmetatable(CLabelDlg, super);
CLabelDlg.__index = CLabelDlg;

CLabelDlg.s_labels = { };
CLabelDlg.s_iCount = 0;

function CLabelDlg.new()
	local obj = { };
	setmetatable(obj, CLabelDlg);
    obj.m_eDialogType = {}
	obj.m_eDialogType[DialogTypeTable.eDialogType_BattleClose] = 1;

	return obj;
end

function CLabelDlg:GetLayoutFileName()
	return "lable.layout";
end

function CLabelDlg:OnCreate()
	local name_prefix = CEGUI.PropertyHelper:intToString(self:getPrefix());
	super.OnCreate(self, nil, name_prefix);
	local winMgr = CEGUI.WindowManager:getSingleton();
	self.d_labels[0] =( { d_btn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "Lable/button")), d_hasCreated = false });
	self.d_labels[0].d_btn:SetMouseLeaveReleaseInput(false);
	self.d_labels[1] =( { d_btn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "Lable/button1")), d_hasCreated = false });
	self.d_labels[1].d_btn:SetMouseLeaveReleaseInput(false);
	self.d_labels[2] =( { d_btn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "Lable/button2")), d_hasCreated = false });
	self.d_labels[2].d_btn:SetMouseLeaveReleaseInput(false);
	self.d_labels[3] =( { d_btn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "Lable/button3")), d_hasCreated = false });
	self.d_labels[3].d_btn:SetMouseLeaveReleaseInput(false);
	self.d_labels[4] =( { d_btn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "Lable/button4")), d_hasCreated = false });
	self.d_labels[4].d_btn:SetMouseLeaveReleaseInput(false);

	self:GetWindow():setAlwaysOnTop(true);
	self:GetWindow():EnableAllowModalState(true);
	self:GetWindow():setRiseOnClickEnabled(false);

	for i = 0, LABEL_NUM - 1 do
		self.d_labels[i].d_btn:setVisible(false);
	end
	self.d_usedLabel = 0;
	CLabelDlg.s_iCount = CLabelDlg.s_iCount + 1;
	table.insert(CLabelDlg.s_labels, self.m_pMainFrame:getName());
end

function CLabelDlg:HandleDlgStateChange(e)
	self:GetWindow():setVisible(self:getNeedShow());

	return true;
end

function CLabelDlg:getNeedShow()
	for i = 0, LABEL_NUM - 1 do
		if (self.d_labels[i].d_hasCreated) then
			local pDlg = self:GetDialogInstance(i, false);
			if pDlg and pDlg:GetWindow() then
				if (pDlg:GetWindow():isVisible() and pDlg:GetWindow():getEffectiveAlpha() > 0.95) then
					return true;
				end
			end
		end

	end
	return false;
end

return CLabelDlg;
