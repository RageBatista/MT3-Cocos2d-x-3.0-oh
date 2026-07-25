require "logic.dialog"

YiChuDlg = {}
setmetatable(YiChuDlg, Dialog)
YiChuDlg.__index = YiChuDlg

local _instance
function YiChuDlg.getInstance()
	if not _instance then
		_instance = YiChuDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function YiChuDlg.getInstanceAndShow()
	if not _instance then
		_instance = YiChuDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function YiChuDlg.getInstanceNotCreate()
	return _instance
end

function YiChuDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function YiChuDlg.ToggleOpenClose()
	if not _instance then
		_instance = YiChuDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function YiChuDlg.GetLayoutFileName()
	return "yichu.layout"
end

function YiChuDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, YiChuDlg)
	return self
end

function YiChuDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	--SetPositionOfWindowWithLabel1(self:GetWindow())
	--self:GetCloseBtn():removeEvent("Clicked")
	--self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)
	--关闭按钮
	self.close = winMgr:getWindow("yichu/window/x")
	self.close:subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)

		RanSeLabel.getInstance().m_pButton1:setVisible(false)
		RanSeLabel.getInstance().m_pButton2:setVisible(false)
		RanSeLabel.getInstance().m_pButton3:setVisible(false)
		RanSeLabel.getInstance().m_pButton4:setVisible(false)
		RanSeLabel.getInstance().m_pButton5:setVisible(false)



    self.turnL = CEGUI.toPushButton(winMgr:getWindow("yichu/zuoxhuan"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("yichu/youzhuan"));

	self.turnL:subscribeEvent("MouseButtonUp", YiChuDlg.handleLeftClicked, self)
	self.turnR:subscribeEvent("MouseButtonUp", YiChuDlg.handleRightClicked, self)
     
    self.ycOKBtn = CEGUI.toPushButton(winMgr:getWindow("yichu/ranseanniu"));
	self.ycOKBtn:subscribeEvent("MouseButtonUp", YiChuDlg.handleYCRSOKClicked, self)
	
	
	--右侧列表
    self.shizhuangBtn = CEGUI.toPushButton(winMgr:getWindow("yichu/yichu6"));--右侧列表 时装按钮
	self.shizhuangBtn:subscribeEvent("MouseButtonUp", YiChuDlg.handleSZClicked, self)
    self.ranseBtn = CEGUI.toPushButton(winMgr:getWindow("yichu/yichu3"));--右侧列表 染色按钮
	self.ranseBtn:subscribeEvent("MouseButtonUp", YiChuDlg.handleRSClicked, self)
    self.petranseBtn = CEGUI.toPushButton(winMgr:getWindow("yichu/yichu8"));--右侧列表 宠物染色按钮
	self.petranseBtn:subscribeEvent("MouseButtonUp", YiChuDlg.handlePetRSClicked, self)

 
 	--动画层
	--self.MY_Win_Time1 =  0.4 --中间帘子起始位置
	self.MY_Win_Time1 =  -0.17 --中间帘子起始位置
	self.lianzi = winMgr:getWindow("yichu/lianli");
	--moveControl(self.lianzi, 0.5, 0,self.MY_Win_Time1, 0)
	--self:zhonjianlianziAni(1)--1上升  2下拉


	self.MY_Win_Time2 =  0.2 --左侧帘子起始位置
	self.lianzi2 = winMgr:getWindow("yichu/pets");
	moveControl(self.lianzi2, 0.17, 0,self.MY_Win_Time2, 0)

	self.lianzi3 = winMgr:getWindow("yichu/window/lianzi2"); --右侧帘子  同步左侧帘子
	moveControl(self.lianzi3, 0.8, 0,self.MY_Win_Time2, 0)
	
	
	self.huanyuan = CEGUI.toPushButton(winMgr:getWindow("yichu/huanyuan"));
	self.gongji = CEGUI.toPushButton(winMgr:getWindow("yichu/gongji"));
	self.shifa = CEGUI.toPushButton(winMgr:getWindow("yichu/shifa"));
	self.fangda = CEGUI.toPushButton(winMgr:getWindow("yichu/fangda"));
	
	self.huanyuan:subscribeEvent("MouseButtonUp", YiChuDlg.handlehuanyuanClicked, self)
	self.gongji:subscribeEvent("MouseButtonUp", YiChuDlg.handlegongjiClicked, self)
	self.shifa:subscribeEvent("MouseButtonUp", YiChuDlg.handleshifaClicked, self)
	self.fangda:subscribeEvent("MouseButtonUp", YiChuDlg.handlefangdaClicked, self)


	self:GetWindow():subscribeEvent("WindowUpdate", YiChuDlg.HandleWindowUpdate, self)--更新

 
 
    self.ycDelBtn = CEGUI.toPushButton(winMgr:getWindow("yichu/huanyuananniu"));
	self.ycDelBtn:subscribeEvent("MouseButtonUp", YiChuDlg.handleDelYCClicked, self)

	local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("yichu/moxingbeijing/moxingdian")
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0,0, true)	
    
    self.yclistWnd = CEGUI.toScrollablePane(winMgr:getWindow("yichu/fanganbeijing/xuanzechuang"));
    self.yclistWnd:EnableHorzScrollBar(false)
    
    self.m_saveSpriteList = {}
    self.m_ycList = {}

    self.partList = {};
	self.partList[1] = {}
	self.partList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
	local num = table.getn(ids)
	for i =1, num do
		local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
        table.insert(self.partList[record.rolepos],record.id)
	end
    self.currentIDA = 1;
    self.currentIDB = 1;
        
    self.YCItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("yichu/ranliao"))
	self.YCItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("yichu/ranliao1"))  
    self.YCItemCellNeedItem1:subscribeEvent("MouseClick",YiChuDlg.HandleItemCellItem1Click,self) 
    self.YCItemCellNeedItem2:subscribeEvent("MouseClick",YiChuDlg.HandleItemCellItem2Click,self)   
    self.YCItemCellNeedItem1:setVisible(false)
    self.YCItemCellNeedItem2:setVisible(false)

    self.YCneeItemCountText1 = winMgr:getWindow("yichu/shuliang")
    self.YCneeItemCountText2 = winMgr:getWindow("yichu/shuliang1")
    self.YCneeItemCountText1:setText("")
    self.YCneeItemCountText2:setText("")
    self.YCneeItemNameText1 = winMgr:getWindow("yichu/wupinming")
    self.YCneeItemNameText2 = winMgr:getWindow("yichu/wupinming1")
    self.YCneeItemNameText1:setText("")
    self.YCneeItemNameText2:setText("")
end


function YiChuDlg:handlegongjiClicked()  --攻击动作
	self.sprite:PlayAction(eActionAttack)
end

function YiChuDlg:handleshifaClicked()  -------施法动作
	self.sprite:PlayAction(eActionMagic1)
end
function YiChuDlg:handlehuanyuanClicked()  -------还原模型
    local data = gGetDataManager():GetMainCharacterData()

	self.sprite:SetModel(data.shape)

end
function YiChuDlg:handlefangdaClicked()  --放大模型
	if self.Scale == 1.5 then
		self.Scale = 1.0
	else
		self.Scale = 1.5
	end
	
	self.sprite:SetUIScale(self.Scale)
	
	self.sprite:SetUIDirection(3)

end

 function YiChuDlg:HandleWindowUpdate()  --update
		-- self.MY_Win_Time1 =  self.MY_Win_Time1 - 0.03  --中间帘子移动速度
		-- if self.MY_Win_Time1 > -0.2 then
		-- moveControl(self.lianzi, 0.5, 0, self.MY_Win_Time1, 0)

		-- end
	
		self.MY_Win_Time1 =  self.MY_Win_Time1 + 0.03  --中间帘子移动速度
		if self.MY_Win_Time1 < 0.4 then
		moveControl(self.lianzi, 0.5, 0, self.MY_Win_Time1, 0)
		end
	
		self.MY_Win_Time2 =  self.MY_Win_Time2 + 0.03  --左右帘子移动速度
		if self.MY_Win_Time2 < 0.52 then
			moveControl(self.lianzi2, 0.17, 0, self.MY_Win_Time2, 0)
			moveControl(self.lianzi3, 0.8, 0, self.MY_Win_Time2, 0)
		end
	
	

	
end


function YiChuDlg:OnClose()  
    self:releaseYC()
	Dialog.OnClose(self)
end

function YiChuDlg:handleSZClicked()
	self.DestroyDialog()
	require"logic.ranse.charactershizhuangdlg".getInstanceAndShow()
end
function YiChuDlg:handleRSClicked()
	self.DestroyDialog()
	require"logic.ranse.charactershizhuangdlg".getInstanceAndShow():handleranse()
end
function YiChuDlg:handlePetRSClicked()
    self.DestroyDialog();
	require("logic.ranse.ranselabel").Show(3)--宠物染色
end

function YiChuDlg:releaseYC()
    local sz = #self.m_ycList
    for index  = 1, sz do
        local lyout = self.m_ycList[1]
        self.yclistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_ycList,1)
        table.remove(self.m_saveSpriteList,1)
	end
    self.m_ycSel = 0
    self.m_ycSelIndex = 0
end

function YiChuDlg:handleLeftClicked(args)
    self.dir =  self.dir + 1;
    if self.dir > 7 then
        self.dir = 0;
    end
    self.sprite:SetUIDirection(self.dir)
end

function YiChuDlg:handleRightClicked(args)
    self.dir =  self.dir - 1;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
end

function YiChuDlg:handleSelYCClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local sID = e.window:getID2()
    self:setSelectYC(nItemId,sID)
end

function YiChuDlg:setSelectYC(id,sid)
    --[[for index = 1, #self.m_ycList do        
        self.m_ycList[index].cbtn:setVisible(false)
    end]]--
    self.m_ycSel = id
    self.m_ycSelIndex = sid
    if id ~= 0 then
        --self.m_ycList[id].cbtn:setVisible(true)    
        local selA = self:GetPartIndex(1,self.m_ycList[id].colorA)
        local selB = self:GetPartIndex(2,self.m_ycList[id].colorB)    
        self:SetPartIndex(1,selA)
        self:SetPartIndex(2,selB)
        self.ycOKBtn:setVisible(true)
        self.ycDelBtn:setVisible(true)
        
        if selA == self.savePartA and selB == self.savePartB then
            self.ycDelBtn:setEnabled(false)
        else
            self.ycDelBtn:setEnabled(true)
        end          

    else        
        self:SetPartIndex(1,self.savePartA)
        self:SetPartIndex(2,self.savePartB)
        self.ycOKBtn:setVisible(false)
        self.ycDelBtn:setVisible(false)
    end
    self:refreshItemShow()
end


function YiChuDlg:GetPartIndex(part,id)    
    for i = 1, #self.partList[part] do
        if  id == self.partList[part][i] then
            return i
        end
    end
    return 0
end
function YiChuDlg:SetPartIndex(part,id)
    if part == 1 then 
        self.currentIDA = id
        self:SetDyeInfo(1,self.partList[1][self.currentIDA])
    elseif part == 2 then 
        self.currentIDB = id
        self:SetDyeInfo(2,self.partList[2][self.currentIDB])
    end
end

function YiChuDlg:SetDyeInfo(part,dyeindex)
    self.sprite:SetDyePartIndex(part-1,dyeindex)
end

function YiChuDlg:refreshItemShow()
    local itemlist = {}
    local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
    self:updateUseItem(2,t,itemlist)
    self.YCItemCellNeedItem1:setVisible(false)
    self.YCItemCellNeedItem2:setVisible(false)
    self.YCneeItemCountText1:setText("")
    self.YCneeItemCountText2:setText("")
    self.YCneeItemNameText1:setText("")
    self.YCneeItemNameText2:setText("")
    
    local clrA = self.partList[1][self.savePartA]
    local clrB = self.partList[2][self.savePartB]

    for index = 1, #self.m_ycList do
        if self.m_ycList[index].colorA == clrA and self.m_ycList[index].colorB == clrB then
            self.m_ycList[index].cbtn:setVisible(true)
        else
            self.m_ycList[index].cbtn:setVisible(false)   
        end
    end 

    if self.m_ycSel == 0 then
        return
    end
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local i = 1
    for key,value in pairs(itemlist) do        
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(key)
        if itemAttrCfg then
            local hasCount = roleItemManager:GetItemNumByBaseID(key)

            local tStr = tostring(hasCount) .. "/" .. tostring(value)
            local tColor = "[colour=".."\'".."ffffffff".."\'".."]"
            if hasCount < value then
                tColor = "[colour=".."\'".."ffffffff".."\'".."]"
            end

            if i == 1 then
                self.YCItemCellNeedItem1:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))
                self.YCItemCellNeedItem1:setID(key)
                self.YCItemCellNeedItem1:setVisible(true)
                self.YCneeItemNameText1:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.YCneeItemCountText1:setText(tColor..tStr)
            elseif i == 2 then
                self.YCItemCellNeedItem2:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))
                self.YCItemCellNeedItem2:setID(key)
                self.YCItemCellNeedItem2:setVisible(true)
                self.YCneeItemNameText2:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.YCneeItemCountText2:setText(tColor .. tStr)
            end
        end
        i = i + 1
    end
end
--tp 1普通  2衣橱
function YiChuDlg:updateUseItem(tp,rate,itemlist)
    
    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[1][self.currentIDA])
    if record then
        if tp ~= 1 and self.currentIDA ~= self.savePartA then
            if not itemlist[record.itemcode]  then 
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
    record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.partList[2][self.currentIDB])
    if record then
        if tp ~= 1 and self.currentIDB ~= self.savePartB then
            if not itemlist[record.itemcode]  then 
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
end

function YiChuDlg:handleYCRSOKClicked(args)    
    
    local itemlist = {}
    local t = GameTable.common.GetCCommonTableInstance():getRecorder(226).value
    self:updateUseItem(2,t,itemlist)

    local maxkey = table.maxn(itemlist)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local hasCount = roleItemManager:GetItemNumByBaseID(maxkey)
    if itemlist[maxkey] and hasCount < itemlist[maxkey] then
          ShopManager:tryQuickBuy(maxkey,itemlist[maxkey]-hasCount)
          return
    end

    for key,value in pairs(itemlist) do        
         local hasCount = roleItemManager:GetItemNumByBaseID(key)
         if hasCount < value then
             GetCTipsManager():AddMessageTipById(190014)
             ShopManager:tryQuickBuy(key,value-hasCount)
             return
         end
    end

	local p = require "protodef.fire.pb.crequsecolor":new()
    p.selecttype = 1
    p.rolecolorinfo.colorpos1 = self.partList[1][self.currentIDA];
    p.rolecolorinfo.colorpos2 = self.partList[2][self.currentIDB];
    require "manager.luaprotocolmanager".getInstance():send(p)
end
function YiChuDlg:handleDelYCClicked(args)   
    if self.m_ycSelIndex ~= 0 then 
	    local p = require "protodef.fire.pb.creqdelcolor":new()
        p.removeindex = self.m_ycSelIndex-1
        require "manager.luaprotocolmanager".getInstance():send(p)  
        self:setSelectYC(0,0)
    end
end
function YiChuDlg:setYCList(yclist)  
    self:releaseYC()
    local len = #yclist
	local winMgr = CEGUI.WindowManager:getSingleton()
	local data = gGetDataManager():GetMainCharacterData()
    
    local clrA = self.partList[1][self.savePartA]
    local clrB = self.partList[2][self.savePartB]

    for i=1,len do
        if yclist[i].colorA == clrA and yclist[i].colorB == clrB then
            if i ~= 1 then
                local temp = yclist[i]
                yclist[i] = yclist[1]
                yclist[1] = temp
            end
            break
        end
    end
    local sx = 0.1;
    local sy = 0.1;
    for index = 1, len do
        local sID = tostring(index)
        local lyout = winMgr:loadWindowLayout("jssz_yichumoxingcell.layout",sID);
        self.yclistWnd:addChildWindow(lyout)

        local xindex = (index-1)%2
        local yindex = math.floor((index-1)/2)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset+1)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset+2))))

        local addclick = winMgr:getWindow(sID.."yichumoxingcell");
        addclick:setID(index)
        addclick:setID2(yclist[index].index)
		--	GetCTipsManager():AddMessageTip("仙玉"..yclist[index].index)

	    addclick:subscribeEvent("MouseButtonUp", YiChuDlg.handleSelYCClicked, self)

        local addpos = winMgr:getWindow(sID.."yichumoxingcell/beijing/moxingdian");
        local body = gGetGameUIManager():AddWindowSprite(addpos, data.shape, Nuclear.XPDIR_BOTTOMRIGHT, 0,0, true)
        --lyout:setVisible(false)
    
        lyout.cbtn = winMgr:getWindow(sID.."yichumoxingcell/beijing/dangqian");
        lyout.cbtn:setVisible(false)
        
        body:SetDyePartIndex(0,yclist[index].colorA)
        body:SetDyePartIndex(1,yclist[index].colorB)
        lyout.colorA = yclist[index].colorA
        lyout.colorB = yclist[index].colorB
        if clrA == lyout.colorA and 
            clrB == lyout.colorB then 
            lyout.cbtn:setVisible(true)
        end
        table.insert(self.m_ycList, lyout)
		table.insert(self.m_saveSpriteList, body)
	end
end

function YiChuDlg:Init(partA,partB)
    self.savePartA = self:GetPartIndex(1,partA)
    self.savePartB = self:GetPartIndex(2,partB)    
    self:SetPartIndex(1,self.savePartA)
    self:SetPartIndex(2,self.savePartB)
end

function YiChuDlg:HandleItemCellItem1Click(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	
    local size = self.YCItemCellNeedItem1:getPixelSize()
	local pos = self.YCItemCellNeedItem1:getPosition()

	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = pos.x.offset + size.width * 1.5
	local nPosY = pos.y.offset + size.height
	local commontipdlg = require "logic.tips.commontipdlg"
	local dlg = commontipdlg.getInstanceAndShow()
	local nType = commontipdlg.eType.eComeFrom
	dlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function YiChuDlg:HandleItemCellItem2Click(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	
    local size = self.YCItemCellNeedItem2:getPixelSize()
	local pos = self.YCItemCellNeedItem2:getPosition()

	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = pos.x.offset + size.width * 1.5
	local nPosY = pos.y.offset + size.height
	local commontipdlg = require "logic.tips.commontipdlg"
	local dlg = commontipdlg.getInstanceAndShow()
	local nType = commontipdlg.eType.eComeFrom
	dlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

return YiChuDlg
