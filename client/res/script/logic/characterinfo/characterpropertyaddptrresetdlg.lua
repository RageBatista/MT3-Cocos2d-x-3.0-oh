require "logic.dialog"
require "logic.characterinfo.characterpropertyaddptrresetcell"
require "logic.characterinfo.addpointmanger"

characterpropertyaddptrresetdlg = {}
setmetatable(characterpropertyaddptrresetdlg, Dialog)
characterpropertyaddptrresetdlg.__index = characterpropertyaddptrresetdlg

local _instance
function characterpropertyaddptrresetdlg.getInstance()
	if not _instance then
		_instance = characterpropertyaddptrresetdlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function characterpropertyaddptrresetdlg.getInstanceAndShow()
	if not _instance then
		_instance = characterpropertyaddptrresetdlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
		_instance:RefreshAll()
	end
	return _instance
end

function characterpropertyaddptrresetdlg.getInstanceExistAndShow()
	if _instance then
		_instance:SetVisible(true)
		_instance:RefreshAll()
	end
	
end


function characterpropertyaddptrresetdlg.getInstanceNotCreate()
	return _instance
end

function characterpropertyaddptrresetdlg.DestroyDialog()
	print( "characterpropertyaddptrresetdlg.DestroyDialog" )
	if _instance then
		if not _instance.m_bCloseIsHide then
            for index in pairs( _instance.m_arrayItemComponent ) do
		        local cell = _instance.m_arrayItemComponent[index]
		        if cell then
			        cell:OnClose()
		        end
	        end
            gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)	
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function characterpropertyaddptrresetdlg.ToggleOpenClose()
	if not _instance then
		_instance = characterpropertyaddptrresetdlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function characterpropertyaddptrresetdlg.GetLayoutFileName()
	return "resettingshuxing.layout"
end

function characterpropertyaddptrresetdlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, characterpropertyaddptrresetdlg)
	return self
end

function characterpropertyaddptrresetdlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7) 
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function characterpropertyaddptrresetdlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager : getSingleton()
     
	 
	self.cc_pay = winMgr:getWindow("resettingshuxing/bg")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_pay)
    self.animationInstance:start()
	
	--用到的数据
	self.m_numItemCount = 6 -- 这里固定值
	self.m_arrayItemID = {}
	self.m_arrayItemComponent = {}
	self.m_numSurplusPoint = 0
    self.disFloat = 0.5001
	self.m_multiList01 = winMgr:getWindow("resettingshuxing/bg/list")
	self.m_textSurplusPtr = winMgr:getWindow("resettingshuxing/bg/bg2/zero")
	self.m_btnuse = CEGUI.toPushButton(winMgr:getWindow("resettingshuxing/bg/btn"))
    self.m_btnuse:subscribeEvent("MouseClick",characterpropertyaddptrresetdlg.HandleUseClick,self)
	self:addButtonAnimation(self.m_btnuse, "studyBtnPress")
	self.col = 3
	self.row = 2
	self.m_index = 1
	local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow("resettingshuxing/bg"))
	self.closeBtn=CEGUI.toPushButton(frameWnd:getCloseButton())
	self.closeBtn:subscribeEvent("MouseClick",characterpropertyaddptrresetdlg.HandleCloseClick,self)
	
	for i=1, self.m_numItemCount do
		local cellWnd = characterpropertyaddptrresetdlgcell.CreateNewDlg(self.m_multiList01)
        self.m_arrayItemComponent[i] = cellWnd
        cellWnd:setId(i)
        if i == 1 then
            cellWnd.m_bg:setSelected(true, false)
        end
	end

    self.m_ListAddProTxt = {}

    for i = 1, 7 do
        local tempTxt = winMgr:getWindow("resettingshuxing/bg/bg12/"..i+7)
        table.insert(self.m_ListAddProTxt, tempTxt )
    end
	
	self.m_listProTxt = {}

	for i = 1 , 7 do
		local tempTxt = winMgr:getWindow("resettingshuxing/bg/bg12/"..i)
		table.insert( self.m_listProTxt, tempTxt )
	end

		
	self:DataUpdateItemID();
	self:DataUpdateSurplusPtr();
	
	self:DisplayItem()
	self:DisplaySurplusPtr()
	self:DisplayPro()

    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(characterpropertyaddptrresetdlg.onEventBagItemNumChange)
    self:RefreshAddPoint()

    
end

function characterpropertyaddptrresetdlg:DisplayPro()
	local data = gGetDataManager():GetMainCharacterData()	
	
	local tempList = { fire.pb.attr.AttrType.MAX_HP,  fire.pb.attr.AttrType.MAX_MP, fire.pb.attr.AttrType.ATTACK,  fire.pb.attr.AttrType.MAGIC_ATTACK, 
		fire.pb.attr.AttrType.DEFEND, fire.pb.attr.AttrType.MAGIC_DEF, fire.pb.attr.AttrType.SPEED }
	for i, v in pairs( self.m_listProTxt ) do
        local pro = data:GetFloatValue(tempList[i])
        local num = math.floor(pro + self.disFloat)
		v:setText (num)
		local qixue = data:GetValue(60);		
	end 
end

function characterpropertyaddptrresetdlg:RefreshAll()
	self:DataUpdateItemID();
	self:DataUpdateSurplusPtr();
	self:DisplayItem();
	self:DisplaySurplusPtr();	
	self:DisplayPro()
    self:RefreshAddPoint()
end
function characterpropertyaddptrresetdlg:RefreshAddPoint()
	local configPtrItem = BeanConfigManager.getInstance():GetTableByName("role.caddpointresetitemconfig"):getRecorder(self.m_arrayItemID[self.m_index])
	local itemType = configPtrItem.type
	local tizhi = configPtrItem.tizhi
	local moli = configPtrItem.moli
	local liliang = configPtrItem.liliang
	local naili = configPtrItem.naili
	local minjie = configPtrItem.minjie
	local data = gGetDataManager():GetMainCharacterData()
	local svrPointScheme = data.pointSchemeID
	local indexCnt = 0
		
	local tArrConfigPro = {tizhi, moli, liliang, naili, minjie}
		
	local protype = 0
	local PtrChangeText = ""
	for i in pairs( tArrConfigPro ) do
		if tArrConfigPro[i] ~= 0 then
			protype = i
			indexCnt = indexCnt+1
		end
	end
    --全部重置
    if indexCnt == 5 then
        for i = 1,5 do
            tArrConfigPro[i] = AddPointManager.getInstance():GetAddedPoint(svrPointScheme, i) * -1
        end
    else
        local canResetPtr = AddPointManager.getInstance():GetAddedPoint(svrPointScheme, protype)
        if canResetPtr > 0 then
            if canResetPtr == 1 then
                tArrConfigPro[self.m_index] = -1
            end
        else
            tArrConfigPro[self.m_index] = 0
        end
    end

	local qixue = data:GetFloatValue(fire.pb.attr.AttrType.MAX_HP)
	local mofa = data:GetFloatValue(fire.pb.attr.AttrType.MAX_MP)
	local wuliAtk = data:GetFloatValue(fire.pb.attr.AttrType.ATTACK)
	local fashuAtk = data:GetFloatValue(fire.pb.attr.AttrType.MAGIC_ATTACK)
	local wuliDef = data:GetFloatValue(fire.pb.attr.AttrType.DEFEND)
	local fashuDef = data:GetFloatValue(fire.pb.attr.AttrType.MAGIC_DEF)
	local sudu = data:GetFloatValue(fire.pb.attr.AttrType.SPEED)

	local nScaleConfig = BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.MAX_HP)
	local nAddptr = 0;
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end		
	end
	nAddptr = math.floor(qixue+nAddptr+ self.disFloat)- math.floor(qixue + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[1]:setText( nAddptr )
	else
		self.m_ListAddProTxt[1]:setText( "" )
	end
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.MAX_MP)
	nAddptr = 0
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end		
	end
	nAddptr = math.floor(mofa+nAddptr+ self.disFloat) - math.floor(mofa + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[2]:setText( nAddptr )
	else
		self.m_ListAddProTxt[2]:setText( "" )
	end
	nScaleConfig = BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.ATTACK)
	nAddptr = 0
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end		
	end
	nAddptr = math.floor(wuliAtk+nAddptr+ self.disFloat) - math.floor(wuliAtk + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[3]:setText( nAddptr )
	else
		self.m_ListAddProTxt[3]:setText( "" )
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.MAGIC_ATTACK)
	nAddptr = 0
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end		
	end
	nAddptr = math.floor(wuliDef+nAddptr+ self.disFloat)- math.floor(wuliDef + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[4]:setText( nAddptr )
	else
		self.m_ListAddProTxt[4]:setText( "" )
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.DEFEND)
	nAddptr = 0
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end		
	end
	nAddptr = math.floor(fashuAtk+nAddptr+ self.disFloat)- math.floor(fashuAtk + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[5]:setText( nAddptr )
	else
		self.m_ListAddProTxt[5]:setText( "" )
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.MAGIC_DEF)
	nAddptr = 0
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end		
	end
	nAddptr = math.floor(fashuDef+nAddptr+ self.disFloat) - math.floor(fashuDef + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[6]:setText( nAddptr )
	else
		self.m_ListAddProTxt[6]:setText( "" )
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(fire.pb.attr.AttrType.SPEED)
	nAddptr = 0
	for index in pairs( tArrConfigPro ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor * tArrConfigPro[index]
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor * tArrConfigPro[index]
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor * tArrConfigPro[index]
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor * tArrConfigPro[index]
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor * tArrConfigPro[index]
		end
	end
	nAddptr = math.floor(sudu+nAddptr+ self.disFloat) - math.floor(sudu + self.disFloat)
	if nAddptr < 0 then
		self.m_ListAddProTxt[7]:setText( nAddptr )
	else
		self.m_ListAddProTxt[7]:setText( "" )
	end      
end
function characterpropertyaddptrresetdlg:DataUpdateItemID()
	
	local itemArray = {331000, 331001, 331002, 331003, 331004, 331005}
	
	for i = 0, self.m_numItemCount - 1 do 
		local tempCom = self.m_arrayItemComponent[i+1]
		self.m_arrayItemID[i+1] = itemArray[i+1]
		tempCom:UpdateItemID( self.m_arrayItemID[i+1] )
	end	
	
end


function characterpropertyaddptrresetdlg:DataUpdateSurplusPtr()	
	
	
end
function characterpropertyaddptrresetdlg.onEventBagItemNumChange(bagid, itemkey, itembaseid) 
    require "logic.characterinfo.addpointmanger".getInstanceAndUpdate()
end
function characterpropertyaddptrresetdlg:DisplayItem()
    
    for index in pairs( self.m_arrayItemComponent ) do
        local tempCom = self.m_arrayItemComponent[index]
        tempCom:RefreshItem()
    end
    
    local arrayIndex = 0;
    -- 定义间距变量
    local spacingX = 6  -- 水平间距，根据需要修改
    local spacingY = 3   -- 垂直间距，根据需要修改
    local height = self.m_arrayItemComponent[1].m_pMainFrame:getHeight()
    local width = self.m_arrayItemComponent[1].m_pMainFrame:getWidth()
    local xO = 0
    local yO = 0
    local newPos = CEGUI.UVector2( CEGUI.UDim(0, xO), CEGUI.UDim(0, yO) )
    for colIndex = 1  ,  self.col do

        
        for rowIndex = 1, self.row do
            arrayIndex = arrayIndex + 1;
            local tempCom = self.m_arrayItemComponent[arrayIndex]
            -- 计算位置时加上间距
            local offsetX = xO + (rowIndex - 1) * (width.offset + spacingX)
            local offsetY = yO + (colIndex - 1) * (height.offset + spacingY)
            local tempPos = CEGUI.UVector2(CEGUI.UDim(0, offsetX), CEGUI.UDim(0, offsetY ) )
            tempCom.m_pMainFrame:setPosition(tempPos)
        end

    end
    
end
function characterpropertyaddptrresetdlg:HandleUseClick(e)
	if GetBattleManager():IsInBattle() then
					
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(131451)
		if tip.id ~= -1 then
			GetCTipsManager():AddMessageTip(tip.msg)
		end
		return true;
	end	
	local id = self.m_arrayItemID[self.m_index]
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemnum = roleItemManager:GetItemNumByBaseID(id)
	if itemnum == 0 then
        local recordQuickBuy = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cquickbuy")):getRecorder(id)
        if not recordQuickBuy then
		    local configItem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id);
            if configItem then
		        local name = configItem.name;
		
		        local strbuilder = StringBuilder:new()
		        strbuilder:Set("parameter1", name)
		        local tempStrTip = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150020))
                strbuilder:delete()
		        GetCTipsManager():AddMessageTip(tempStrTip)
            end
        else
            ShopManager:tryQuickBuy(id)
        end
        return
	end
	
	local protype = self:GetProIDReadConfig(id)
	local data = gGetDataManager():GetMainCharacterData();
	local svrPointScheme = data.pointSchemeID;
	local surplus = AddPointManager.getInstance():GetAddedPoint(svrPointScheme, protype) 
	
	if surplus == 0 then
		local tempStrTip = MHSD_UTILS.get_msgtipstring(150015)
		GetCTipsManager():AddMessageTip(tempStrTip)
		return
	end
	
	local pitem = roleItemManager:GetItemByBaseID(id)
	if pitem then
		roleItemManager:UseItem(pitem)
	end    
end
function characterpropertyaddptrresetdlg:GetProIDReadConfig(id)
	local indexCnt = 0
	local protype = 0
	local configPtrItem = BeanConfigManager.getInstance():GetTableByName("role.caddpointresetitemconfig"):getRecorder(id)
	--对应道具位置
	local itemType = configPtrItem.type
	local tizhi = configPtrItem.tizhi
	local moli = configPtrItem.moli
	local liliang = configPtrItem.liliang
	local naili = configPtrItem.naili
	local minjie = configPtrItem.minjie
	local tArrConfigPro = {tizhi, moli, liliang, naili, minjie}
	for i in pairs( tArrConfigPro ) do
		if tArrConfigPro[i] ~= 0 then
			protype = i
			indexCnt = indexCnt+1
		end
	end
	
	if indexCnt == 5 then
		return 6	
	else
		return protype	
	end
end

function characterpropertyaddptrresetdlg.HandleCloseClick()
	LogInfo("characterpropertyaddptrresetdlg.HandleCloseClick")	
	if _instance then 		
		_instance.DestroyDialog()
	end
end
function characterpropertyaddptrresetdlg:DisplaySurplusPtr()
	local data = gGetDataManager():GetMainCharacterData();
	local svrPointScheme = data.pointSchemeID;
	local surplusPtr = AddPointManager.getInstance():GetSurplusPoint( svrPointScheme )
	self.m_textSurplusPtr:setText(""..surplusPtr)
	
end


return characterpropertyaddptrresetdlg
