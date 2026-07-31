LevelUpRewardCell = {}

setmetatable(LevelUpRewardCell, Dialog)
LevelUpRewardCell.__index = LevelUpRewardCell

function LevelUpRewardCell.CreateNewDlg(parent, rewardID, id, prefix)
	local newDlg = LevelUpRewardCell:new()
	newDlg.m_nIndexID = id
	newDlg.m_nRewardID = rewardID
	newDlg:OnCreate(parent, prefix)
	return newDlg
end

function LevelUpRewardCell.GetLayoutFileName()
	return "shengjidalibaocell.layout"
end

function LevelUpRewardCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LevelUpRewardCell)
	return self
end

function LevelUpRewardCell:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function LevelUpRewardCell:OnCreate(parent, prefix)
	local prefixstr = tostring(prefix)
	Dialog.OnCreate(self, parent, prefixstr)

	local winMgr = CEGUI.WindowManager:getSingleton()
	

	self.m_bg = winMgr:getWindow(prefixstr .. "shengjidalibaocell")
	self.m_txtTitle = winMgr:getWindow(prefixstr .. "shengjidalibaocell/wenben")
	self.m_btnGot = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "shengjidalibaocell/anniu"))
	self:addButtonAnimation(self.m_btnGot, "studyBtnPress")
	print(self.m_btnGot:getName().." self.m_btnGot")
	self.m_btnGot:subscribeEvent( "MouseClick", LevelUpRewardCell.HandleBtnGotClicked, self )
	self.m_bgWidth =  self.m_bg:getWidth().offset
    self.m_bgHeight = self.m_bg:getHeight().offset
	self.m_btnGotWidth =  self.m_btnGot:getPosition().x.offset
    self.m_btnGotHeight =  self.m_btnGot:getPosition().y.offset
	self.m_listItemCell = {}
	self.heightDis = 100
	for i = 1 , 12 do
		local n =  CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "shengjidalibaocell/wupin"..i))
		n:setID( i )
		n:subscribeEvent("MouseClick",LevelUpRewardCell.HandleItemClicked,self)
		table.insert( self.m_listItemCell, n )
	end
	
	self.m_vecItemList = nil
	local cpresentCfg = BeanConfigManager.getInstance():GetTableByName("item.cpresentconfig"):getRecorder(self.m_nRewardID)
	self:SetVecItemList(cpresentCfg.itemids)
	self.flag = false --不能领取
	self:RefreshItemList()
end

function LevelUpRewardCell:SetFlag( flag )
	self.flag = flag
	self.m_btnGot:setEnabled( self.flag )
end


function LevelUpRewardCell:SetVecItemList( vecItem )
	self.m_vecItemList = vecItem	
end

function LevelUpRewardCell:RefreshItemList()
	local cpresentCfg = BeanConfigManager.getInstance():GetTableByName("item.cpresentconfig"):getRecorder(self.m_nRewardID)
	local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cpresentCfg.itemid )
    if not itembean then
        return
    end
	local nImId = cpresentCfg.itemid
	local nLv = itembean.needLevel

	local strBuild = StringBuilder:new()
    strBuild:Set("parameter1", nLv)
    self.m_txtTitle:setText(strBuild:GetString(MHSD_UTILS.get_resstring(11203)))	
    
    strBuild:Set("parameter1", nLv)  
    self.m_btnGot:setText(strBuild:GetString(MHSD_UTILS.get_resstring(7700))) 

    strBuild:delete()

	for i = 0, self.m_vecItemList:size() - 1 do
		local itemid = self.m_vecItemList[i]
        local nItemNum = 0
        if i < cpresentCfg.itemnums:size() then
            nItemNum = cpresentCfg.itemnums[i]
        end
		local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid )
		if itembean and itembean.itemtypeid ~= 166 then
			self.m_listItemCell[i+1]:SetImage(gGetIconManager():GetItemIconByID( itembean.icon ))
            if nItemNum > 1 then
                  self.m_listItemCell[i+1]:SetTextUnitText(CEGUI.String(tostring(nItemNum)))
            end
            SetItemCellBoundColorByQulityItemWithId(self.m_listItemCell[i+1],itembean.id)
            SetItemCellBoundColorByQulityItem(self.m_listItemCell[i+1], itembean.nquality, itembean.itemtypeid)
		end
	end

	self.m_btnGot:setEnabled( self.flag )
end

function LevelUpRewardCell:HandleItemClicked(args)

	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
	
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	if index-1 >= self.m_vecItemList:size() then
		return true
	end
	
	local nItemId = self.m_vecItemList[index-1]
	
	local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId )
	if itembean and itembean.itemtypeid == 166 then
		return true
	end
	
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal
	


	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
	return true
end


function LevelUpRewardCell:HandleBtnGotClicked(args)

	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
	
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position

	if gGetNetConnection() then
		local cpresentCfg = BeanConfigManager.getInstance():GetTableByName("item.cpresentconfig"):getRecorder(self.m_nRewardID)
		local ll = cpresentCfg.itemid
 	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local pItem = roleItemManager:GetItemByBaseID(cpresentCfg.itemid)
		if not pItem then
			return 
		end
		
		local userID = gGetDataManager():GetMainCharacterID()
	    require "protodef.fire.pb.item.cappenditem"
	    local useItem = CAppendItem.Create()
        useItem.keyinpack = pItem:GetThisID()
        useItem.idtype = 0
        useItem.id = userID
	    LuaProtocolManager.getInstance():send(useItem)
	end
	
end

return LevelUpRewardCell


