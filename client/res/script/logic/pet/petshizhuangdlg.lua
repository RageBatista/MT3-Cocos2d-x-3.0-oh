require "logic.dialog"

PetShiZhuangDlg = {}
setmetatable(PetShiZhuangDlg, Dialog)
PetShiZhuangDlg.__index = PetShiZhuangDlg

local _instance
function PetShiZhuangDlg.getInstance()
	if not _instance then
		_instance = PetShiZhuangDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetShiZhuangDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetShiZhuangDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetShiZhuangDlg.getInstanceNotCreate()
	return _instance
end

function PetShiZhuangDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetShiZhuangDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetShiZhuangDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetShiZhuangDlg.GetLayoutFileName()
	return "chongwushizhuang.layout"
end

function PetShiZhuangDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetShiZhuangDlg)
	return self
end



function PetShiZhuangDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	--SetPositionOfWindowWithLabel(self:GetWindow())
	--self:GetCloseBtn():removeEvent("Clicked")
	--self:GetCloseBtn():subscribeEvent("Clicked", PetShiZhuangDlg.DestroyDialog, nil)
	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/pets/petScroll"))
	self.petScroll:EnableAllChildDrag(self.petScroll)
	self.petScrollbuy = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/petcardbuy/buy"))
	self.petScrollbuy:EnableAllChildDrag(self.petScrollbuy)
	self.petScrollwon = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/petcardwon/won"))
	self.petScrollwon:EnableAllChildDrag(self.petScrollwon)
	self.icon = winMgr:getWindow("chongwuranse/icon")
	self.titlename = winMgr:getWindow("chongwuranse/tishi/text3")
	self.tskg = winMgr:getWindow("chongwuranse/tishikuang")
	self.tskgxr = winMgr:getWindow("chongwuranse/tishikuangxiaoren")
	self.tskgbuy = winMgr:getWindow("chongwuranse/tishikuangbuy")
	self.tskgxrbuy = winMgr:getWindow("chongwuranse/tishikuangxiaorenbuy")
	
	self.nullbut = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/shop"));
	self.buybut =	CEGUI.toPushButton(winMgr:getWindow("chongwuranse/buy"));
	self.wonbut =	CEGUI.toPushButton(winMgr:getWindow("chongwuranse/use"));
	self.huanyuan = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/huanyuan"));
	self.gongji = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/gongji"));
	self.shifa = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/shifa"));
	self.fangda = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/fangda"));
	
	self.btbuy = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/left"));  --购买
    self.btwon = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/right"));  --拥有
    self.btbuy2 = winMgr:getWindow("chongwuranse/window/tabBtn");  --购买
    self.btwon2 = winMgr:getWindow("chongwuranse/window/tabBtn1");  --拥有
	
	
	--购买列表
	self.goumailist = winMgr:getWindow("chongwuranse/window/lianzi2/goumai");
	--拥有列表
	self.yongyoulist = winMgr:getWindow("chongwuranse/window/lianzi2/yongyou");

	
	
	self.ownerk = winMgr:getWindow("chongwuranse/Back1");
    self.owner = winMgr:getWindow("chongwuranse/money3");
	self.costk = winMgr:getWindow("chongwuranse/Back3");
    self.cost = winMgr:getWindow("chongwuranse/money");
	
	self.turnL = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("chongwuranse/xuanniu2"));
	
	self.btbuy:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleLeftbuyClicked, self) --购买
	self.btwon:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleRightwonClicked, self)--拥有
	self.btbuy2:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleLeftbuyClicked, self)--购买
	self.btwon2:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleRightwonClicked, self)--拥有
	
	
	self.nullbut:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlenullClicked, self)
	self.buybut:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlebuyClicked, self)
	self.wonbut:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlewonClicked, self)
	self.huanyuan:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlehuanyuanClicked, self)
	self.gongji:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlegongjiClicked, self)
	self.shifa:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleshifaClicked, self)
	self.fangda:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlefangdaClicked, self)

	
	self.turnL:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleLeftClicked, self)
	self.turnR:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleRightClicked, self)
	self.turnL:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleLeftUp, self)
	self.turnR:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handleRightUp, self)
    self.turnL:subscribeEvent("MouseLeave", PetShiZhuangDlg.handleLeftUp, self) 
    self.turnR:subscribeEvent("MouseLeave", PetShiZhuangDlg.handleRightUp, self) 
	
	self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
	
	self.leftDown = false;
    self.rightDown = false;
	self.bbb = 0;
	
    self.downTime = 0;
	self.retbuy = 0;
	self.retwon = 0;
	self.validate =1;
	self.listfashionid = {};
	self.listfashionname = {};
	self.listfashionshape = {};
	self.listfashionpath = {};
	self.listfashiontitle = {};
	self.listfashioncost = {};
	self.wonfashionid = {};
	self.wonfashionname = {};
	self.wonfashionshape = {};
	self.wonfashionpath = {};
	self.wonfashiontitle = {};
	
	self.m_petList = {}
	self.petlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/pets/petScroll"));
    self.petlistWnd:EnableHorzScrollBar(false)
	self.petlistbuy = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/petcardbuy/buy"));
    self.petlistbuy:EnableHorzScrollBar(false)
	self.petlistbuy:setVisible(false)
	self.petlistwon = CEGUI.toScrollablePane(winMgr:getWindow("chongwuranse/petcardwon/won"));
    self.petlistwon:EnableHorzScrollBar(false)
	self.petlistwon:setVisible(false)
	 local defaultPet = MainPetDataManager.getInstance():GetBattlePet() or MainPetDataManager.getInstance():getPet(1)

	 
	 self:refreshSelectedPet(defaultPet)
	self:refreshPetTable()
	
	
	
	


	
	--self:selTab(2)--默认选择  1为购买  2为拥有
	
	--动画层
	self.MY_Win_Time1 =  0.4 --中间帘子起始位置
	self.lianzi = winMgr:getWindow("chongwuranse/lianli");
	moveControl(self.lianzi, 0.5, 0,self.MY_Win_Time1, 0)

	self.MY_Win_Time2 =  0.2 --左侧帘子起始位置
	self.lianzi2 = winMgr:getWindow("chongwuranse/pets");
	moveControl(self.lianzi2, 0.17, 0,self.MY_Win_Time2, 0)

	self.lianzi3 = winMgr:getWindow("chongwuranse/window/lianzi2"); --右侧帘子  同步左侧帘子
	moveControl(self.lianzi3, 0.8, 0,self.MY_Win_Time2, 0)


	self:GetWindow():subscribeEvent("WindowUpdate", PetShiZhuangDlg.HandleWindowUpdate, self)--更新

	
	--关闭按钮
	self.close = winMgr:getWindow("chongwuranse/window/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)

end

 function PetShiZhuangDlg:HandleWindowUpdate()  --update
	
	self.MY_Win_Time1 =  self.MY_Win_Time1 - 0.03  --中间帘子移动速度
	if self.MY_Win_Time1 > -0.2 then
		moveControl(self.lianzi, 0.5, 0, self.MY_Win_Time1, 0)
	end
	
	self.MY_Win_Time2 =  self.MY_Win_Time2 + 0.03  --中间帘子移动速度
	if self.MY_Win_Time2 < 0.52 then
		moveControl(self.lianzi2, 0.17, 0, self.MY_Win_Time2, 0)
		moveControl(self.lianzi3, 0.8, 0, self.MY_Win_Time2, 0)
	end
	
end


function moveControl(controlName, xRatio, xOffset, yRatio, yOffset)--移动控件子函数 从居中位置来算
    --local control = CEGUI.WindowManager:getSingleton():getWindow(controlName)--可以用名字的方式取控件
    local parent = controlName:getParent() --获取待移动的控件的父级

    local parentWidth = parent:getPixelSize().width
    local parentHeight = parent:getPixelSize().height

    local xPosition = (parentWidth * xRatio) + xOffset - (controlName:getPixelSize().width/2)
    local yPosition = (parentHeight * yRatio) + yOffset - (controlName:getPixelSize().height/2)

    controlName:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPosition), CEGUI.UDim(0, yPosition)))
end

-- function PetShiZhuangDlg:selTab(id) 
	-- if id == 1 then  --购买标签
		-- self:handleLeftbuyClicked()
		-- self.selid = 1
	-- end
	-- if id == 2 then  --拥有标签
		-- self:handleRightwonClicked()
		-- self.selid = 2
	-- end
 
-- end

function PetShiZhuangDlg:refreshPetTable()    
	self:releasePetIcon()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sx = 1.0;
	local sy = 2.0;
	self.m_petList = {}
	local index = 0
	local fightid = gGetDataManager():GetBattlePetID()
	for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
		local sID =tostring(index)
		local lyout = winMgr:loadWindowLayout("petcellsz.layout",sID);
		self.petlistWnd:addChildWindow(lyout)
		lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy + index * (lyout:getHeight().offset))))
		lyout.key = petData.key

		lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
		lyout.addclick:setID(index)
		lyout.addclick:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlePetIconSelected, self)
		
		--选中框
		lyout.xuanzhon = winMgr:getWindow(sID.."petcell/bg/xz")
		lyout.xuanzhon:setVisible(false) 


		if petData.key == self.selectedPetKey then
			lyout.addclick:setSelected(true)
			lyout.xuanzhon:setVisible(true) 

		end
					
		lyout.NameText = winMgr:getWindow(sID.."petcell/name")
		lyout.NameText:setText(petData.name)
		lyout.LevelText = winMgr:getWindow(sID.."petcell/number")
		lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL)) 
		

		lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang"))   
		SetPetItemCellInfo3(lyout.petCell, petData) 

		lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
		lyout.chuzhan:setVisible(false)    

		lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
		lyout.addtext:setVisible(false)

		if fightid == petData.key then
			lyout.chuzhan:setVisible(true) 
		end
		table.insert(self.m_petList, lyout)
		index = index + 1
	end
end

function PetShiZhuangDlg:refreshPetTablebuy()  
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sx = 0.0;
	local sy = 0.0;
	local index = 0
	self.cost:setText(tostring(self.listfashioncost[self.bbb]))
	self.owner:setText(CurrencyManager.getOwnCurrencyMount(111))
	for i = 1, self.listnum do		 
		local petData = MainPetDataManager.getInstance():getPet(self.validate)
		local sID = "uniquePetCard_".. tostring(index)
		local lyout = winMgr:loadWindowLayout("petcard.layout",sID);
		self.petlistbuy:setVisible(true)
		self.petlistbuy:addChildWindow(lyout)
		
		 lyout.key = petData.key
		lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcard"));
		lyout.addclick:setID(index +1)
		lyout.addclick:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlePetIconSelectedbuy, self)

		if petData.key == self.selectedPetKey then
			lyout.addclick:setSelected(true)
			
		end
		lyout.biao = winMgr:getWindow(sID.."petcard/touxiang/jiahao")
		if self.retbuy ~= 0 and self.retbuy == i then 
		lyout.biao:setVisible(true)
		end
		lyout.NameText = winMgr:getWindow(sID.."petcard/name")
		lyout.NameText:setText(self.listfashionname[i-1])
		
	
		lyout.Card = CEGUI.Window.toPushButton(winMgr:getWindow(sID.."petcard/touxiang")) 
		lyout.Card:setProperty("Image", self.listfashionpath[i-1])
		local high = math.floor(index/2)
			if index % 2 == 0 then
			lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx-60 ), CEGUI.UDim(0.0, sy + high * (lyout:getHeight().offset-10))))

		else
			lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx-60 + 1 * (lyout:getWidth().offset-10)), CEGUI.UDim(0.0, sy + high * (lyout:getHeight().offset-10))))

		end

		index = index + 1
	end
end

function PetShiZhuangDlg:refreshPetTablewon()  
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sx = 0.0;
	local sy = 0.0;
	local index = 0
	for i = 1, self.wonnum do
		local petData = MainPetDataManager.getInstance():getPet(self.validate)
		local sID = "uniquePetCardwon_".. tostring(index)
		local lyout = winMgr:loadWindowLayout("petcardwon.layout",sID);
		self.petlistwon:setVisible(true)
		self.petlistwon:addChildWindow(lyout)
		
		lyout.key = petData.key

		lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcard"));
		lyout.addclick:setID(index +1)
		lyout.addclick:subscribeEvent("MouseButtonUp", PetShiZhuangDlg.handlePetIconSelectedwon, self)

		if petData.key == self.selectedPetKey then
			lyout.addclick:setSelected(true)
		end
		lyout.biao = winMgr:getWindow(sID.."petcard/touxiang/jiahao")
		if self.retwon ~= 0 and self.retwon == i then 
		lyout.biao:setVisible(true)
		end
		lyout.NameText = winMgr:getWindow(sID.."petcard/name")
		lyout.NameText:setText(self.wonfashionname[i-1])

		lyout.Card = CEGUI.Window.toPushButton(winMgr:getWindow(sID.."petcard/touxiang")) 
		lyout.Card:setProperty("Image", self.wonfashionpath[i-1])
		local high = math.floor(index/2)
			if index % 2 == 0 then
			lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx-60 ), CEGUI.UDim(0.0, sy + high * (lyout:getHeight().offset-10))))

		else
			lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx-60 + 1 * (lyout:getWidth().offset-10)), CEGUI.UDim(0.0, sy + high * (lyout:getHeight().offset-10))))

		end

		index = index + 1
	end
end

function PetShiZhuangDlg:clearPetTablebuy()
    local childCount = self.petlistbuy:getChildCount()
    for i = childCount - 1, 0, -1 do
        local childWindow = self.petlistbuy:getChildAtIdx(i)
        self.petlistbuy:removeChildWindow(childWindow)
        CEGUI.WindowManager:getSingleton():destroyWindow(childWindow)
    end
end

function PetShiZhuangDlg:clearPetTablewon()
    local childCount = self.petlistwon:getChildCount()
    for i = childCount - 1, 0, -1 do
        local childWindow = self.petlistwon:getChildAtIdx(i)
        self.petlistwon:removeChildWindow(childWindow)
        CEGUI.WindowManager:getSingleton():destroyWindow(childWindow)
    end
end

function PetShiZhuangDlg:handlenullClicked()
	if self.tskgbuy:isVisible() then
	GetCTipsManager():AddMessageTip('尚未发布相应时装，请等待后续更新');
	else
	GetCTipsManager():AddMessageTip('请点左侧购买按钮');
	end
end

function PetShiZhuangDlg:handlehuanyuanClicked()
	local petData = MainPetDataManager.getInstance():getPet(self.validate)
	local fash = BeanConfigManager.getInstance():GetTableByName("pet.cpetfashion"):getRecorder(petData.baseid)
    if fash ==nil or fash.id == fash.defaultid then
		GetCTipsManager():AddMessageTip('已经是默认造型请正确选择宠物');
		return
	end
	local cmd = require "protodef.fire.pb.pet.cpetfashion".Create()
	cmd.petkey = self.selectedPetKey
	cmd.resultkey = fash.id
	cmd.defaulttype = 0
	LuaProtocolManager.getInstance():send(cmd)
end

function PetShiZhuangDlg:handlegongjiClicked()
	self.sprite:PlayAction(eActionAttack)
end

function PetShiZhuangDlg:handleshifaClicked()
	self.sprite:PlayAction(eActionMagic1)
end

function PetShiZhuangDlg:handlefangdaClicked()
	if self.Scale == 2.0 then
		self.Scale = 1.0
	else
		self.Scale = 2.0
	end
	
	self.sprite:SetUIScale(self.Scale)
end

function PetShiZhuangDlg:handlebuyClicked()
	
	if not self:getcost() then
		
	return
	end
	
	local vecID = gGetDataManager():GetAllTitleID()
		for k=1,#vecID do
			if vecID[k] == self.listfashiontitle[self.retbuy-1] then
			GetCTipsManager():AddMessageTip('已拥有此皮肤');
				return
			end
		end	
    
	local cmd = require "protodef.fire.pb.pet.cpetfashion".Create()
	cmd.petkey = self.selectedPetKey
	cmd.resultkey = self.listfashionid[self.retbuy-1]
	cmd.defaulttype = 1
	LuaProtocolManager.getInstance():send(cmd)
end

function PetShiZhuangDlg:handlewonClicked()
	local petData = MainPetDataManager.getInstance():getPet(self.validate)
	if self.wonfashionid[self.retwon-1] == nil then
	GetCTipsManager():AddMessageTip('请选择拥有的时装');
	end
	if petData.baseid == self.wonfashionid[self.retwon-1] then
	
	GetCTipsManager():AddMessageTip('造型以切换请不要重复使用');
	return
	end
	local cmd = require "protodef.fire.pb.pet.cpetfashion".Create()
	cmd.petkey = self.selectedPetKey
	cmd.resultkey = self.wonfashionid[self.retwon-1]
	cmd.defaulttype = 2
	LuaProtocolManager.getInstance():send(cmd)
    
end

function PetShiZhuangDlg:getcost()
	local bool = true
	if self.listfashioncost[self.bbb] == nil then
	GetCTipsManager():AddMessageTip('尚未发布相应时装，请等待后续更新');
	return  false
	end
	if self.listfashioncost[self.bbb] > CurrencyManager.getOwnCurrencyMount(111) then
	GetCTipsManager():AddMessageTip('吉里币不够');
	return  false
	end	
    return bool
end

function PetShiZhuangDlg:refreshSelectedPet(petData)
	if petData then
		self.selectedPetKey = petData.key
		self.titlename:setText(petData.name)
		self:fashionset(petData)
	else
		self.selectedPetKey = 0
	end
	self.Scale = 1.0
	self:refreshPetSprite(petData and petData.shape or nil)
end

function PetShiZhuangDlg:handlePetIconSelected(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local idx = wnd:getID()
	if idx < MainPetDataManager.getInstance():GetPetNum() then
		local petData = MainPetDataManager.getInstance():getPet(idx+1)
		if self.selectedPetKey ~= petData.key then
			self:refreshSelectedPet(petData)
			self.validate= idx+1 
			
			for A=1 ,#self.m_petList do
				self.m_petList[A].xuanzhon:setVisible(false) 
			end
			self.m_petList[idx+1].xuanzhon:setVisible(true) 

		end
	end
end  

function PetShiZhuangDlg:fashionset(petData)
	self.listnum = 0
	self.wonnum = 0
	self.bool =true
	local vecID = gGetDataManager():GetAllTitleID()
	
	for k in pairs(self.listfashionid) do
       self.listfashionid[k] = nil
	end
	for k in pairs(self.listfashionname) do
       self.listfashionname[k] = nil
	end
	for k in pairs(self.listfashionshape) do
       self.listfashionshape[k] = nil
	end
	for k in pairs(self.listfashionpath) do
       self.listfashionpath[k] = nil
	end
	for k in pairs(self.listfashiontitle) do
       self.listfashiontitle[k] = nil
	end
	
	for k in pairs(self.wonfashionid) do
       self.wonfashionid[k] = nil
	end
	for k in pairs(self.wonfashionname) do
       self.wonfashionname[k] = nil
	end
	for k in pairs(self.wonfashionshape) do
       self.wonfashionshape[k] = nil
	end
	for k in pairs(self.wonfashionpath) do
       self.wonfashionpath[k] = nil
	end
	for k in pairs(self.wonfashiontitle) do
       self.wonfashiontitle[k] = nil
	end
	for k in pairs(self.listfashioncost) do
       self.listfashioncost[k] = nil
	end
	
	if petData then
	local fash = BeanConfigManager.getInstance():GetTableByName("pet.cpetfashion"):getRecorder(petData.baseid)
		if fash then
			
			self.tskgbuy:setVisible(false)
			self.tskgxrbuy:setVisible(false)
			for i = 0 , 10 do
				if fash.fashionid[i] and fash.fashionid[i] > 0 then
					self.listfashionid[i] = fash.fashionid[i]
					self.listfashionname[i] = fash.fashionname[i]
					self.listfashionshape[i] = fash.fashionshape[i]
					self.listfashionpath[i] = fash.fashionpath[i]
					self.listfashiontitle[i] = fash.fashiontitle[i]
					self.listfashioncost[i] = fash.fashioncost[i]
					self.listnum = self.listnum +1
					
					for k=1,#vecID do
						if vecID[k] == fash.fashiontitle[i] then
						self.wonfashionid[self.wonnum] = fash.fashionid[i]
						self.wonfashionname[self.wonnum] = fash.fashionname[i]
						self.wonfashionshape[self.wonnum] = fash.fashionshape[i]
						self.wonfashionpath[self.wonnum] = fash.fashionpath[i]
						self.wonfashiontitle[self.wonnum] = fash.fashiontitle[i]
						self.wonnum = self.wonnum + 1
						end
					end
				else
					break
				end	
			end
		else
			self.tskgbuy:setVisible(true)
			self.tskgxrbuy:setVisible(true)
			self.bool = (false)
			
		end
		
	end
	
	if not self.bool and self.costk:isVisible()   then
	self.costk:setVisible(false)
	self.ownerk:setVisible(false)
	self.cost:setVisible(false)
	self.owner:setVisible(false)
	end
	
	if not self.costk:isVisible() and self.bool  then
	self.costk:setVisible(true)
	self.ownerk:setVisible(true)
	self.cost:setVisible(true)
	self.owner:setVisible(true)
	end
	
	if self.wonnum == 0 then
		self.tskg:setVisible(true)
		self.tskgxr:setVisible(true)
		self.nullbut:setVisible(true)
		self.wonbut:setVisible(false)
	else
		self.tskg:setVisible(false)
		self.tskgxr:setVisible(false)
		self.nullbut:setVisible(false)
		if not self.petlistbuy:isVisible() then
		self.wonbut:setVisible(true)
		end
	end
	if self.petlistbuy:isVisible() then
		self.petlistbuy:cleanupNonAutoChildren()
		self:refreshPetTablebuy()
		self.tskg:setVisible(false)
		self.tskgxr:setVisible(false)	
	end
	if self.petlistwon:isVisible() then
		self.petlistwon:cleanupNonAutoChildren()
		self:refreshPetTablewon()	
		
	end
	if not self.petlistbuy:isVisible() and not self.petlistwon:isVisible() then
		self:refreshPetTablewon()
		self.nullbut:setVisible(true)
		
	end
	
	if self.bool and self.buybut:isVisible() then
	self.petlistbuy:cleanupNonAutoChildren()
	self:refreshPetTablebuy()
	end
	
	if not self.petlistbuy:isVisible() and self.costk:isVisible() then
		self.costk:setVisible(false)
		self.ownerk:setVisible(false)
		self.cost:setVisible(false)
		self.owner:setVisible(false)
	end

end



function PetShiZhuangDlg:handlePetIconSelectedbuy(args)
	self.Scale = 1.0
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local idx = wnd:getID()
	self.retbuy = idx
	self.bbb = idx -1
	self.petlistbuy:cleanupNonAutoChildren()
	 self:refreshPetTablebuy()
	 
	self:refreshPetSprite( self.listfashionshape[self.bbb] or nil)
end 

function PetShiZhuangDlg:handlePetIconSelectedwon(args)
	self.Scale = 1.0
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local idx = wnd:getID()
	self.retwon = idx
	self.petlistwon:cleanupNonAutoChildren()
	 self:refreshPetTablewon()
	self:refreshPetSprite( self.wonfashionshape[idx-1] or nil)
end 

function PetShiZhuangDlg:releasePetIcon()   
	local sz = #self.m_petList
	for index  = 1, sz do
		local lyout = self.m_petList[1]
		lyout.addclick = nil
		lyout.NameText = nil
		lyout.LevelText = nil
		lyout.petCell = nil
		lyout.chuzhan = nil
		lyout.dengji = nil
		self.petlistWnd:removeChildWindow(lyout)
		CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
		table.remove(self.m_petList,1)
	end
	if self.addPetButton then
		local lyout = self.addPetButton
		lyout.addclick = nil
		lyout.NameText = nil
		lyout.LevelText = nil
		lyout.petCell = nil
		lyout.chuzhan = nil
		lyout.dengji = nil
		CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
		self.addPetButton = nil
	end
end

function PetShiZhuangDlg:refreshPetSprite(shapeID)
	if not shapeID then
		return
	end
	if not self.sprite then
		local pos = self.icon:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y+50)
		self.sprite = UISprite:new(shapeID)
		if self.sprite then
			self.sprite:SetUILocation(loc)
			self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
			self.icon:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, PetShiZhuangDlg.performPostRenderFunctions))
		end
	else
		self.sprite:SetModel(shapeID)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
	
	self.elapse = 0
	self.defaultActCurTimes = 0
end

function PetShiZhuangDlg.performPostRenderFunctions(id)
	if _instance and _instance:IsVisible() and _instance:GetWindow():getEffectiveAlpha() > 0.95 and _instance.selectedPetKey ~= 0 and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

function PetShiZhuangDlg:handleLeftbuyClicked()

	self.btbuy2:setVisible(false)--购买
	self.btwon2:setVisible(true)--拥有


	self.goumailist:setVisible(true)
	self.yongyoulist:setVisible(false)

	self.tskg:setVisible(false)
	self.tskgxr:setVisible(false)
	if not self.costk:isVisible() and self.bool  then
	self.costk:setVisible(true)
	self.ownerk:setVisible(true)
	self.cost:setVisible(true)
	self.owner:setVisible(true)
	end
--	self:refreshPetTablebuy() 
--	self.petlistwon:cleanupNonAutoChildren()
	if self.petlistwon:isVisible() then
		
		self.petlistwon:setVisible(false)
	--	self.petlistwon:cleanupNonAutoChildren()
	end	
	
	if self.wonbut:isVisible() then
	self.wonbut:setVisible(false)
	end
	self.buybut:setVisible(true)
	self.petlistwon:cleanupNonAutoChildren()
	self:refreshPetTablebuy()

end




function PetShiZhuangDlg:handleRightwonClicked()

	self.goumailist:setVisible(false)
	self.yongyoulist:setVisible(true)

	self.btbuy2:setVisible(true)--购买
	self.btwon2:setVisible(false)--拥有

	
--	self.petlistbuy:cleanupNonAutoChildren()
--	self:refreshPetTablewon() 
	if self.petlistbuy:isVisible() then
		self.petlistbuy:setVisible(false)
		--self.petlistbuy:cleanupNonAutoChildren()
	end	
	
	
	if self.buybut:isVisible() then
	self.buybut:setVisible(false)
	end
	self.petlistwon:cleanupNonAutoChildren()
	self:refreshPetTablewon()
	if self.wonnum == 0 then
		self.tskg:setVisible(true)
		self.tskgxr:setVisible(true)
		self.nullbut:setVisible(true)
		self.wonbut:setVisible(false)
	else
		self.tskg:setVisible(false)
		self.tskgxr:setVisible(false)
		self.wonbut:setVisible(true)	
	end
	
	if  self.costk:isVisible()  then
		self.costk:setVisible(false)
		self.ownerk:setVisible(false)
		self.cost:setVisible(false)
		self.owner:setVisible(false)
	end
	
	
end

-- function PetShiZhuangDlg:handleLeftbuyClicked() --购买


	
	-- if self.selid == 2 then  --拥有标签
		-- self:handleLeftbuyClicked()

		-- self.selid = 1
		-- return
	-- end
	-- if self.selid == 1 then  --购买标签
		-- self:handleRightwonClicked()

		-- self.selid = 2
		-- return
	-- end



	
-- end

function PetShiZhuangDlg:handleLeftClicked(args)
    self.dir =  self.dir + 2;
    if self.dir > 7 then
        self.dir = 1;
    end
    self.sprite:SetUIDirection(self.dir)
    self.leftDown = true;
    self.downTime = 0;
end

function PetShiZhuangDlg:handleRightClicked(args)
    self.dir =  self.dir - 2;
    if self.dir < 0 then
        self.dir = 7;
    end
	self.sprite:SetUIDirection(self.dir)
	
    self.rightDown = true;
    self.downTime = 0;
end
function PetShiZhuangDlg:handleLeftUp(args)
    self.leftDown = false;
end
function PetShiZhuangDlg:handleRightUp(args)
    self.rightDown = false;
end

function PetShiZhuangDlg:update(delta)
    if self.leftDown == true then
        self.downTime = self.downTime + delta;
        if self.downTime > 200 then
            self.dir =  self.dir + 2;
            if self.dir > 7 then
                self.dir = 0;
            end
            self.sprite:SetUIDirection(self.dir)
			
            self.downTime = 0
        end
    end
    if self.rightDown == true then
        self.downTime = self.downTime + delta;
        if self.downTime > 200 then
            self.dir =  self.dir - 2;
            if self.dir < 0 then
                self.dir = 7;
            end
            self.sprite:SetUIDirection(self.dir)
			
            self.downTime = 0
        end
    end
end

function PetShiZhuangDlg:OnClose()  
	Dialog.OnClose(self) 
end

function PetShiZhuangDlg:refui()
	local petData = MainPetDataManager.getInstance():getPet(self.validate)
	self.petlistWnd:cleanupNonAutoChildren()
	self:refreshPetTable()
	self:refreshPetSprite(petData and petData.shape or nil)
	if self.petlistbuy:isVisible() then
	self.petlistbuy:cleanupNonAutoChildren()
	self:refreshPetTablebuy()
	end
end



return PetShiZhuangDlg
