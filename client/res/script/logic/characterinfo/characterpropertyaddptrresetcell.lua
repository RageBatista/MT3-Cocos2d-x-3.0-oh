require "logic.characterinfo.addpointmanger"

characterpropertyaddptrresetdlgcell = {}

setmetatable(characterpropertyaddptrresetdlgcell, Dialog)
characterpropertyaddptrresetdlgcell.__index = characterpropertyaddptrresetdlgcell
local prefix = 1

function characterpropertyaddptrresetdlgcell.CreateNewDlg(parent)
	local newDlg = characterpropertyaddptrresetdlgcell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function characterpropertyaddptrresetdlgcell.GetLayoutFileName()
	return "resettingshuxingcell.layout"
end
function characterpropertyaddptrresetdlgcell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, characterpropertyaddptrresetdlgcell)
	return self
end

function characterpropertyaddptrresetdlgcell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_itemID = 0;

	--self.m_textProPtr = winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/one")
	--self.m_textProPtrChange = winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/shuxing3")
	self.m_textItemName = winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/name")
	self.m_itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/itemkuang/button"))
	self.m_textItemPro =  winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/shuxing")
	self.m_textCanResetPtr =   winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/shuxing2")
	self.m_textXXXX =   winMgr:getWindow(prefixstr .. "resettingshuxingcell/bg/itemkuang/txet")
	self.m_textXXXX:setVisible(false)
	self.m_itemCell:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
	
    self.m_bg = CEGUI.Window.toGroupButton(winMgr:getWindow(prefixstr .. "resettingshuxingcell"))
    self.m_bg:subscribeEvent("SelectStateChanged", characterpropertyaddptrresetdlgcell.HandleCellClick, self)
    self.m_bg:EnableClickAni(false)
    self.m_bg:setGroupID(1)
    self.m_quanshuxing = winMgr:getWindow(prefixstr.."resettingshuxingcell/bg/quanshuxing")
    self.m_id = 0
    
end
function characterpropertyaddptrresetdlgcell:setId(id)
    self.m_id = id
end
function characterpropertyaddptrresetdlgcell:HandleCellClick(e)
    local dlg = require("logic.characterinfo.characterpropertyaddptrresetdlg").getInstanceNotCreate()
    if dlg then
        dlg.m_index = self.m_id
        dlg:RefreshAll()
    end
end
function characterpropertyaddptrresetdlgcell:UpdateItemID( itemID )
	--刷新控件id
	self.m_itemID = itemID;
	self.m_itemCell:setID(self.m_itemID)
end

function characterpropertyaddptrresetdlgcell:RefreshItem()
	if self.m_itemID ~= 0 then
		local data = gGetDataManager():GetMainCharacterData();
		local svrPointScheme = data.pointSchemeID;
		
		local configPtrItem = BeanConfigManager.getInstance():GetTableByName("role.caddpointresetitemconfig"):getRecorder(self.m_itemID);
		local configItem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_itemID);
        if configItem then
		    local iconID = configItem.icon;
		    self.m_itemCell:SetImage( gGetIconManager():GetItemIconByID(iconID) );
            SetItemCellBoundColorByQulityItemWithId(self.m_itemCell,self.m_itemID)
        end
        self.m_textItemName:setText(configItem.name)
		local itemType = configPtrItem.type;
		local tizhi = configPtrItem.tizhi;
		local moli = configPtrItem.moli;
		local liliang = configPtrItem.liliang;
		local naili = configPtrItem.naili;
		local minjie = configPtrItem.minjie;

		local indexCnt = 0;
		
		local tArrConfigPro = {tizhi, moli, liliang, naili, minjie};
		local tArrTextID = { 2186, 2188, 2185, 2189, 2187 };
		
		local protype = 0;
		local PtrChangeText = ""
		for i in pairs( tArrConfigPro ) do
			if tArrConfigPro[i] ~= 0 then
				protype = i;
				indexCnt = indexCnt+1;
				self.m_textItemPro:setText(MHSD_UTILS.get_resstring( tArrTextID[i] ))
				PtrChangeText = tostring(tArrConfigPro[i])
			end
		end
		self.m_textItemPro:setVisible(true)
		--刷新物品个数
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local nItemNum = roleItemManager:GetItemNumByBaseID(self.m_itemID)
		self.m_itemCell:SetTextUnitText( CEGUI.String(""..nItemNum.."/".."1") )
		--道具不足时， 显示红色
		if nItemNum == 0 then
			self.m_itemCell:SetTextUnitColor(CEGUI.PropertyHelper:stringToColour("ffff0000"))
		else	
			self.m_itemCell:SetTextUnitColor(CEGUI.PropertyHelper:stringToColour("ffffffff"))
		end
		
		local canResetPtr = AddPointManager.getInstance():GetAddedPoint(svrPointScheme, protype) 
		
		self.m_textCanResetPtr:setText("[colour='ff553923']"..canResetPtr.."[colour='ff2c90d6'] "..PtrChangeText)
		self.m_textCanResetPtr:setVisible(true)
		--是否显示全重置
		if indexCnt == 5 then
			self.m_textItemPro:setText(MHSD_UTILS.get_resstring(10022));
			local nptr = AddPointManager.getInstance():GetAllProResetPoint(svrPointScheme)
			self.m_textCanResetPtr:setVisible(false)
			--self.m_textProPtrChange:setVisible(false)
            self.m_textItemPro:setVisible(false)
			--self.m_textProPtr:setVisible(false)
            self.m_quanshuxing:setVisible(true)
		else
			--self.m_textProPtrChange:setVisible(true)
			--self.m_textProPtr:setVisible(true)
            self.m_quanshuxing:setVisible(false)
		end
		
		local proptr = AddPointManager.getInstance():GetTotalPointByIndex(protype)
		--self.m_textProPtr:setText(""..proptr)
	end
	
end

return characterpropertyaddptrresetdlgcell
