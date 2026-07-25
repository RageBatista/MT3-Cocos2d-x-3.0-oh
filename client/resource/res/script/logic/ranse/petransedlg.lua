require "logic.dialog"

PetRanseDlg = {}
setmetatable(PetRanseDlg, Dialog)
PetRanseDlg.__index = PetRanseDlg

local _instance
function PetRanseDlg.getInstance()
	if not _instance then
		_instance = PetRanseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetRanseDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetRanseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetRanseDlg.getInstanceNotCreate()
	return _instance
end

function PetRanseDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetRanseDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetRanseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetRanseDlg.GetLayoutFileName()
	return "chongwuranse.layout"
end

function PetRanseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetRanseDlg)
	return self
end

function PetRanseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	--SetPositionOfWindowWithLabel1(self:GetWindow())
	-- self:GetCloseBtn():removeEvent("Clicked")
	-- self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)
	--�رհ�ť
	self.close = winMgr:getWindow("chongwuranse/window/x")
	self.close:subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)


		RanSeLabel.getInstance().m_pButton1:setVisible(false)
		RanSeLabel.getInstance().m_pButton2:setVisible(false)
		RanSeLabel.getInstance().m_pButton3:setVisible(false)
		RanSeLabel.getInstance().m_pButton4:setVisible(false)
		RanSeLabel.getInstance().m_pButton5:setVisible(false)


	self.gongji = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/gongji"));
	self.shifa = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/shifa"));
	self.fangda = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/fangda"));
	
	self.gongji:subscribeEvent("MouseButtonUp", PetRanseDlg.handlegongjiClicked, self)
	self.shifa:subscribeEvent("MouseButtonUp", PetRanseDlg.handleshifaClicked, self)
	self.fangda:subscribeEvent("MouseButtonUp", PetRanseDlg.handlefangdaClicked, self)
	
	self.turnL = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/xuanniu2"));
    self.turnL:subscribeEvent("MouseButtonUp", PetRanseDlg.handleLeftClicked, self)
    self.turnR:subscribeEvent("MouseButtonUp", PetRanseDlg.handleRightClicked, self)

	
	--�Ҳ��б�
    self.shizhuangBtn = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/chongwuranse6"));--�Ҳ��б� ʱװ��ť
	self.shizhuangBtn:subscribeEvent("MouseButtonUp", PetRanseDlg.handleSZClicked, self)
    self.ranseBtn = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/chongwuranse3"));--�Ҳ��б� Ⱦɫ��ť
	self.ranseBtn:subscribeEvent("MouseButtonUp", PetRanseDlg.handleRSClicked, self)
    self.yichuBtn = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/chongwuranse1"));--�Ҳ��б� �³���ť
	self.yichuBtn:subscribeEvent("MouseButtonUp", PetRanseDlg.handleYCClicked, self)

	--������
	self.MY_Win_Time1 =  0.4 --�м�������ʼλ��
	self.lianzi = winMgr:getWindow("chongwuranse/lianli");
	moveControl(self.lianzi, 0.5, 0,self.MY_Win_Time1, 0)


	self.MY_Win_Time2 =  0.2 --���������ʼλ��
	self.lianzi2 = winMgr:getWindow("chongwuranse/pets");
	moveControl(self.lianzi2, 0.17, 0,self.MY_Win_Time2, 0)

	self.lianzi3 = winMgr:getWindow("chongwuranse/window/lianzi2"); --�Ҳ�����  ͬ���������
	moveControl(self.lianzi3, 0.8, 0,self.MY_Win_Time2, 0)
	
	


	self:GetWindow():subscribeEvent("WindowUpdate", PetRanseDlg.HandleWindowUpdate, self)--����


    self.rsOkBtn = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/ranse"));
	self.rsOkBtn:subscribeEvent("MouseButtonUp", PetRanseDlg.handleRSOKClicked, self)
    self.rsOkBtn:EnableClickAni(false)
    self.rsOkBtn:setEnabled(false)

    self.tishi1 = winMgr:getWindow("chongwuranse/chongwuliebiaobeijing/chongwuliebiaoxialakuang/tishi")
    self.tishi2 = winMgr:getWindow("chongwuranse/fanganxuanzebeijing/tishikuang")
    self.tishi3 = winMgr:getWindow("chongwuranse/fanganxuanzebeijing/tupian")   
    
    self.petlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/chongwuliebiaobeijing/chongwuliebiaoxialakuang"));
    self.petlistWnd:EnableHorzScrollBar(false)
    
    local sx = 0.1;
    local sy = 0.1;
    self.m_petList = {}
    local index = 0
    local fightid = gGetDataManager():GetBattlePetID()
    for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
 
        local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if  conf and conf.dyelist~="" and conf.dyelist~="0" then
 
       -- if petData.kind == 3 then 
            local sID = tostring(index)
            local lyout = winMgr:loadWindowLayout("petcellrs.layout",sID);
            self.petlistWnd:addChildWindow(lyout)
	        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy + index * (lyout:getHeight().offset+3))))
            lyout:setID(petData.key)

            local addclick = CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
            addclick:setID(petData.key)
	        addclick:subscribeEvent("MouseButtonUp", PetRanseDlg.handleSelPetClicked, self)

            if index == 0 then
                addclick:setSelected(true)
            end
                    
            local NameText = winMgr:getWindow(sID.."petcell/name")
            NameText:setText(petData.name)

            local petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang"))
            SetPetItemCellInfo3(petCell, petData)         
            
            local LevelText = winMgr:getWindow(sID.."petcell/number")
            LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))  

            local chuzhan = winMgr:getWindow(sID.."petcell/zhan")
            --local bangding = winMgr:getWindow(sID.."chongwucell/touxiang/bangding")
           -- bangding:setVisible(false) 
            chuzhan:setVisible(false) 

           -- if petData.flag == 2 then
            --    bangding:setVisible(true) 
           -- end
            if fightid == petData.key then
                chuzhan:setVisible(true) 
            end
            table.insert(self.m_petList, lyout)
            index = index + 1
       -- end
        end
    end 
	
	


    if #self.m_petList > 0 then
        self.tishi1:setVisible(false)
		
		local ApetData = MainPetDataManager.getInstance():FindMyPetByID(self.m_petList[1]:getID())

		self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
		self.canvas = winMgr:getWindow("chongwuranse/beijing/moxing")
		self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, ApetData.shape, self.dir, 0,0, true)	

		
    else
        self.tishi1:setVisible(true)
    end 

    self.ranselistWnd = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/fanganxuanzebeijing/fanganxuanzetuozhuai"));
    self.ranselistWnd:EnableHorzScrollBar(false)
     
    self.m_saveSpriteList = {}
    self.m_iconList = {}
    self.m_seliconList = {}
    
    self.partList = {};
    self.m_saveSpriteList = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
	local num = table.getn(ids)
	for i =1, num do
        if ids[i] < 200 then
		    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
            table.insert(self.partList,record.id)
		    table.insert(self.m_saveSpriteList, body)
        end
	end
    --[[self.currentIDA = 1;
    self.currentIDB = 1;
    ]]--
	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("chongwuranse/ranliaotubiao"))
    self.ItemCellNeedItem1:subscribeEvent("MouseClick",PetRanseDlg.HandleItemCellItemClick,self) 
    self.ItemCellNeedItem1:setVisible(false)    
    self.neeItemCountText1 = winMgr:getWindow("chongwuranse/ranliaoshuliang")
    self.neeItemCountText1:setText("")
    self.neeItemNameText1 = winMgr:getWindow("chongwuranse/ranliaomingzi")
    self.neeItemNameText1:setText("")
        
        
    if #self.m_petList > 0 then
        self:setSelectPet(self.m_petList[1]:getID())
    end
end

 function PetRanseDlg:HandleWindowUpdate()  --update
		self.MY_Win_Time1 =  self.MY_Win_Time1 - 0.03  --�м������ƶ��ٶ�
		if self.MY_Win_Time1 > -0.2 then
		moveControl(self.lianzi, 0.5, 0, self.MY_Win_Time1, 0)

		
		end
	
		self.MY_Win_Time2 =  self.MY_Win_Time2 + 0.03  --���������ƶ��ٶ�
		if self.MY_Win_Time2 < 0.52 then
			moveControl(self.lianzi2, 0.17, 0, self.MY_Win_Time2, 0)
			moveControl(self.lianzi3, 0.8, 0, self.MY_Win_Time2, 0)
		end
	
	

	
end

function PetRanseDlg:handleLeftClicked(args)
    -- self.dir = self.dir + 4;
    -- if self.dir >= 8 then
        -- self.dir = 0;
    -- end
    -- self.sprite:SetUIDirection(self.dir)
    -- self.leftDown = true;
    -- self.downTime = 0;
	
	self.dir = self.dir - 4;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
	
    self.rightDown = true;
    self.downTime = 0;
end

function PetRanseDlg:handleRightClicked(args)
    self.dir = self.dir - 4;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
	
    self.rightDown = true;
    self.downTime = 0;
end

function PetRanseDlg:OnClose()  
    self:releaseIcon()
	Dialog.OnClose(self) 
end

function PetRanseDlg:handlegongjiClicked()  --��������
	self.sprite:PlayAction(eActionAttack)
end

function PetRanseDlg:handleshifaClicked()  -------ʩ������
	self.sprite:PlayAction(eActionMagic1)
end
function PetRanseDlg:handlefangdaClicked()  --�Ŵ�ģ��
	if self.Scale == 1.5 then
		self.Scale = 1.0
	else
		self.Scale = 1.5
	end
	
	self.sprite:SetUIScale(self.Scale)
	
	self.sprite:SetUIDirection(3)

end

function PetRanseDlg:handleSZClicked()
	self.DestroyDialog()
	require"logic.ranse.charactershizhuangdlg".getInstanceAndShow()
end
function PetRanseDlg:handleRSClicked()
	self.DestroyDialog()
	require"logic.ranse.charactershizhuangdlg".getInstanceAndShow():handleranse()
end
function PetRanseDlg:handleYCClicked()
    self.DestroyDialog();
	require("logic.ranse.ranselabel").Show(2)--�³�
end



function PetRanseDlg:releaseIcon()
if self.m_iconList then
    local sz = #self.m_iconList
    for index  = 1, sz do
        local lyout = self.m_iconList[1]
        self.ranselistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_iconList,1)
        table.remove(self.m_saveSpriteList,1)
	end
end
    self.m_ycSel = 0
	
end

function PetRanseDlg:handleSelPetClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local petKey = e.window:getID()
    if self.m_petSel ~= petKey  then
        self:setSelectPet(petKey)
    end
end

function PetRanseDlg:setSelectPet(pkey)
    self.m_petSel = pkey
    local petData = MainPetDataManager.getInstance():FindMyPetByID(pkey)
    
	local winMgr = CEGUI.WindowManager:getSingleton()
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if not petAttr then return end
    local rsTable = StringBuilder.Split(petAttr.dyelist, ";")
    
	

		self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, petData.shape, self.dir, 0,0, true)	

	
	
    self.savePartA = petData.petdye1
    self.savePartB = petData.petdye2
    if petData.petdye1 == 0 then
        if petAttr then
            self.savePartA = petAttr.area1colour
        end
    end
    if petData.petdye2 == 0 then
        if petAttr then
            self.savePartB = petAttr.area2colour
        end
    end

    self:releaseIcon()
    local sx = 0.1;
    local sy = 0.1;
    for index = 1, #rsTable do
        local sID = tostring(index)
        local lyout = winMgr:loadWindowLayout("chongwumoxingcell.layout",sID);
        self.ranselistWnd:addChildWindow(lyout)
	    local xindex = (index-1)%2
        local yindex = math.floor((index-1)/2)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset+1)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset+2))))

        local addclick = CEGUI.toGroupButton(winMgr:getWindow(sID.."chongwumoxingcell"))
        
        local rsColor = StringBuilder.Split(rsTable[index], ",")
        addclick:setID(rsColor[1])
        addclick:setID2(rsColor[2])
	    addclick:subscribeEvent("MouseButtonUp", PetRanseDlg.handleSelRSClicked, self)
        
        local addpos = winMgr:getWindow(sID.."chongwumoxingcell/beijing/moxingdian");
        local body = gGetGameUIManager():AddWindowSprite(addpos, petData.shape, Nuclear.XPDIR_BOTTOMRIGHT, 0,0, true)
                
        --lyout.cbtn = winMgr:getWindow(sID.."ranse1cell/moxing/xuanzhong");
        --lyout.cbtn:setVisible(false)
        
        body:SetDyePartIndex(0,rsColor[1])
        body:SetDyePartIndex(1,rsColor[2])
        lyout.colorA = rsColor[1]
        lyout.colorB = rsColor[2]

        lyout.gou = winMgr:getWindow(sID.."chongwumoxingcell/beijing/duigou")
        lyout.gou:setVisible(false)

        if tonumber(rsColor[1]) == self.savePartA and  tonumber(rsColor[2]) == self.savePartB then
            addclick:setSelected(true)
            lyout.gou:setVisible(true)
        end
        
        table.insert(self.m_iconList, lyout)
		table.insert(self.m_saveSpriteList, body)
	end
    
    if #rsTable > 0 then
        self.tishi2:setVisible(false)
        self.tishi3:setVisible(false)
    else
        --self.tishi2:setVisible(true)
        --self.tishi3:setVisible(true)
    end 
    self.m_petColorA = self.savePartA
    self.m_petColorB = self.savePartB
    self:refreshItemShow()
end
function PetRanseDlg:setSelectRS(pkey,pkey2)
    self.m_petColorA = pkey
    self.m_petColorB = pkey2
    self:refreshItemShow()
end

function PetRanseDlg:GetPartIndex(part,id)    
    for i = 1, #self.partList[part] do
        if  id == self.partList[part][i] then
            return i
        end
    end
    return 0
end

function PetRanseDlg:handleSelRSClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local petKey = e.window:getID()
	local petKey2 = e.window:getID2()
    self:setSelectRS(petKey,petKey2)
	
	    self.sprite:SetDyePartIndex(0,petKey)
        self.sprite:SetDyePartIndex(1,petKey2)

    
end

function PetRanseDlg:refreshItemShow()
    local itemlist = {}
    self:updateUseItem(1,1.0,itemlist)
    self.ItemCellNeedItem1:setVisible(false)
    --self.ItemCellNeedItem2:setVisible(false)
    self.neeItemCountText1:setText("")
    --self.neeItemCountText2:setText("")
    self.neeItemNameText1:setText("")
    --self.neeItemNameText2:setText("")
    local i = 1
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
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
                self.ItemCellNeedItem1:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))            
                self.ItemCellNeedItem1:setID(key)
                self.ItemCellNeedItem1:setVisible(true)
                self.neeItemNameText1:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.neeItemCountText1:setText(tColor..tStr)
            --[[elseif i == 2 then
                self.ItemCellNeedItem2:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))       
                self.ItemCellNeedItem2:setID(key)
                self.ItemCellNeedItem2:setVisible(true)
                self.neeItemNameText2:setText("[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name)
                self.neeItemCountText2:setText(tColor .. tStr)]]--
            end
        end
        i = i + 1
    end

    if i > 1 then  
        self.rsOkBtn:setEnabled(true)
    else    
        self.rsOkBtn:setEnabled(false)
    end
end
--tp 1��ͨ  2�³�
function PetRanseDlg:updateUseItem(tp,rate,itemlist)
    
    local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(self.m_petColorA)
    if record and record.id ~= -1 then
        if self.m_petColorA ~= self.savePartA or self.m_petColorB ~= self.savePartB then
            if not itemlist[record.itemcode]  then 
                itemlist[record.itemcode] = {}
                itemlist[record.itemcode] = math.ceil(record.itemnum * rate)
            else
                itemlist[record.itemcode] = itemlist[record.itemcode] + math.ceil(record.itemnum * rate)
            end
        end
    end
end

function PetRanseDlg:handleRSOKClicked(args)    
    
    local itemlist = {}
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    self:updateUseItem(1,1.0,itemlist)
    for key,value in pairs(itemlist) do        
         local hasCount = roleItemManager:GetItemNumByBaseID(key)
         if hasCount < value then
             ShopManager:tryQuickBuy(key,value-hasCount)
             return
         end
    end

	local p = require "protodef.fire.pb.crequsepetcolor":new()
    p.petkey = self.m_petSel
    p.colorpos1 = self.m_petColorA
    p.colorpos2 = self.m_petColorB
    require "manager.luaprotocolmanager".getInstance():send(p)
end

function PetRanseDlg:HandleItemCellItemClick(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local commontipdlg = require "logic.tips.commontipdlg"
	local dlg = commontipdlg.getInstanceAndShow()
	local nType = commontipdlg.eType.eComeFrom
	dlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

local p = require "protodef.fire.pb.srequsepetcolor"
function p:process()
    local petData = require("logic.pet.mainpetdatamanager").getInstance():FindMyPetByID(self.petkey,1)
	if petData == nil then
		return
    end
	petData.petdye1 = self.colorpos1
	petData.petdye2 = self.colorpos2
    local dlg = PetRanseDlg.getInstance()
    dlg.savePartA = petData.petdye1
    dlg.savePartB = petData.petdye2
    dlg:setSelectRS(petData.petdye1,petData.petdye2)

    local sz = #dlg.m_iconList
    for index  = 1, sz do
        local lyout = dlg.m_iconList[index]
        local gou = lyout.gou
        if gou then
            if petData.petdye1 == tonumber(lyout.colorA) and petData.petdye2 == tonumber(lyout.colorB) then
                gou:setVisible(true)
            else
                gou:setVisible(false)
            end
        end
	end
end

return PetRanseDlg
