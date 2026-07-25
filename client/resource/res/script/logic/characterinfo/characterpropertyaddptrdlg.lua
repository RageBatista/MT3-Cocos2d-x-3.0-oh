require "logic.dialog"
require "logic.addpointlistdlg"
require "logic.addpointintro"
require "logic.addcpointintro"


CharacterPropertyAddPtrDlg = {


}


setmetatable(CharacterPropertyAddPtrDlg, Dialog)
CharacterPropertyAddPtrDlg.__index = CharacterPropertyAddPtrDlg
local _instance


function CharacterPropertyAddPtrDlg.getInstance()
	LogInfo("CharacterPropertyAddPtrDlg.getInstance")
    if not _instance then
        _instance = CharacterPropertyAddPtrDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CharacterPropertyAddPtrDlg.getInstanceAndShow()
	LogInfo("____CharacterPropertyAddPtrDlg.getInstanceAndShow")
    if not _instance then
        _instance = CharacterPropertyAddPtrDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CharacterPropertyAddPtrDlg.hide()
  if _instance then
    _instance:SetVisible(false)
  end
end

function CharacterPropertyAddPtrDlg.getInstanceExistAndShow()
	LogInfo("____CharacterPropertyAddPtrDlg.getInstanceExistAndShow")
    if not _instance then
		return;
	else
		_instance:notifyUserDataChange();		    
		return _instance
    end

end


function CharacterPropertyAddPtrDlg.getInstanceNotCreate()
    return _instance
end

function CharacterPropertyAddPtrDlg:OnClose()
	if _instance then
		Dialog.OnClose(_instance)
		_instance = nil
	end
end

function CharacterPropertyAddPtrDlg.DestroyDialog()
	if _instance then 
		
		Dialog.OnClose(_instance)
		_instance = nil
	end
	
end

function CharacterPropertyAddPtrDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CharacterPropertyAddPtrDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CharacterPropertyAddPtrDlg.GetLayoutFileName()
    return "charecterjiadian.layout"
end

function CharacterPropertyAddPtrDlg:addButtonAnimation(button, animationName)
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


function CharacterPropertyAddPtrDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CharacterPropertyAddPtrDlg)
	
	self.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1
	
    return self
end

function CharacterPropertyAddPtrDlg:OnCreate()
	LogInfo("enter CharacterPropertyAddPtrDlg oncreate")
    Dialog.OnCreate(self)
	
	local winMgr = CEGUI.WindowManager:getSingleton();
	SetPositionOfWindowWithLabel(self:GetWindow())
	self.charecterinfo = winMgr:getWindow("charecterjiadian")
	
    self.disFloat = 0.0
	
	self.m_protext1 = winMgr:getWindow("charecterjiadian/left/textbg/1");
	self.m_protext2 = winMgr:getWindow("charecterjiadian/left/textbg/2");
	self.m_protext3 = winMgr:getWindow("charecterjiadian/left/textbg/3");
	self.m_protext4 = winMgr:getWindow("charecterjiadian/left/textbg/4");
	self.m_protext5 = winMgr:getWindow("charecterjiadian/left/textbg/5");
	self.m_protext6 = winMgr:getWindow("charecterjiadian/left/textbg/6");
	self.m_protext7 = winMgr:getWindow("charecterjiadian/left/textbg/7");
	
	
	self.m_proaddtext1 = winMgr:getWindow("charecterjiadian/left/textbg/add1");
	self.m_proaddtext2 = winMgr:getWindow("charecterjiadian/left/textbg/add2");
	self.m_proaddtext3 = winMgr:getWindow("charecterjiadian/left/textbg/add3");
	self.m_proaddtext4 = winMgr:getWindow("charecterjiadian/left/textbg/add4");
	self.m_proaddtext5 = winMgr:getWindow("charecterjiadian/left/textbg/add5");
	self.m_proaddtext6 = winMgr:getWindow("charecterjiadian/left/textbg/add6");
	self.m_proaddtext7 = winMgr:getWindow("charecterjiadian/left/textbg/add7");
	
	self.m_textSchemeOpen = winMgr:getWindow("charecterjiadian/left/dangqian");
	self.m_textintroaddpoint = winMgr:getWindow("charecterjiadian/right/kaiqifangan");
	
	--剩余点数显示
	self.m_surplustext = winMgr:getWindow("charecterjiadian/right/0");
	
	self.m_ptrtext1 = winMgr:getWindow("charecterjiadian/right/8");
	self.m_ptrtext2 = winMgr:getWindow("charecterjiadian/right/9");
	self.m_ptrtext3 = winMgr:getWindow("charecterjiadian/right/10");
	self.m_ptrtext4 = winMgr:getWindow("charecterjiadian/right/11");
	self.m_ptrtext5 = winMgr:getWindow("charecterjiadian/right/12");
	self.ptrTextArray = {self.m_ptrtext1, self.m_ptrtext2,
		self.m_ptrtext3, self.m_ptrtext4, self.m_ptrtext5 };
		
	self.m_ptraddtext1 = winMgr:getWindow("charecterjiadian/right/add8");
	self.m_ptraddtext2 = winMgr:getWindow("charecterjiadian/right/add9");
	self.m_ptraddtext3 = winMgr:getWindow("charecterjiadian/right/add10");
	self.m_ptraddtext4 = winMgr:getWindow("charecterjiadian/right/add11");
	self.m_ptraddtext5 = winMgr:getWindow("charecterjiadian/right/add12");	
	self.ptrAddTextArray = {self.m_ptraddtext1, self.m_ptraddtext2,
		self.m_ptraddtext3, self.m_ptraddtext4, self.m_ptraddtext5 };
	
	self.m_addbutton1 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jiahao1"));
	self.m_addbutton2 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jiahao2"));
	self.m_addbutton3 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jiahao3"));
	self.m_addbutton4 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jiahao4"));
	self.m_addbutton5 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jiahao5"));
    self.m_addbutton1:EnableClickAni(false)
    self.m_addbutton2:EnableClickAni(false)
    self.m_addbutton3:EnableClickAni(false)
    self.m_addbutton4:EnableClickAni(false)
    self.m_addbutton5:EnableClickAni(false)
	
	self.m_reducebutton1 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jianhao1"));
	self.m_reducebutton2 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jianhao2"));
	self.m_reducebutton3 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jianhao3"));
	self.m_reducebutton4 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jianhao4"));
	self.m_reducebutton5 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/jianhao5"));
	
    self.m_reducebutton1:EnableClickAni(false)
    self.m_reducebutton2:EnableClickAni(false)
    self.m_reducebutton3:EnableClickAni(false)
    self.m_reducebutton4:EnableClickAni(false)
    self.m_reducebutton5:EnableClickAni(false)

	self.m_movebutton1 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/bule1/button1"));
	self.m_movebutton2 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/bule1/button2"));
	self.m_movebutton3 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/bule1/button3"));
	self.m_movebutton4 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/bule1/button4"));
	self.m_movebutton5 = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/bule1/button5"));

    self.m_movebutton1:EnableClickAni(false)
    self.m_movebutton2:EnableClickAni(false)
    self.m_movebutton3:EnableClickAni(false)
    self.m_movebutton4:EnableClickAni(false)
    self.m_movebutton5:EnableClickAni(false)
    self.m_movebutton1:SetMouseLeaveReleaseInput(false)
    self.m_movebutton2:SetMouseLeaveReleaseInput(false)
    self.m_movebutton3:SetMouseLeaveReleaseInput(false)
    self.m_movebutton4:SetMouseLeaveReleaseInput(false)
    self.m_movebutton5:SetMouseLeaveReleaseInput(false)
	
	self.m_resetpointBtn = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/xidianbutton"));
	self.m_resetpointBtn:subscribeEvent("Clicked", CharacterPropertyAddPtrDlg.HandleResetBtnClicked, self);	
	self:addButtonAnimation(self.m_resetpointBtn, "stucdyBtnPress")---洗点
	
	self.m_addpointBtn = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/right/querenjiadian"));
	self.m_addpointBtn:subscribeEvent("Clicked", CharacterPropertyAddPtrDlg.HandleSendBtnClicked, self);	
    self:addButtonAnimation(self.m_addpointBtn, "stucdyBtnPress")---加点
	
	self.m_schemeBtn = CEGUI.toPushButton(winMgr:getWindow("charecterjiadian/left/jiadianfanganbutton"));
	self.m_schemeBtn:subscribeEvent("Clicked", CharacterPropertyAddPtrDlg.HandleSchemeBtnClicked, self);	
	self.m_schemeBtnStatus = false
	
	
	self.m_blue1 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1"));
	self.m_blue2 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule2"));
	self.m_blue3 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule3"));
	self.m_blue4 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule4"));
	self.m_blue5 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule5"));
	
	self.m_yellow1 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1/yellow1"));
	self.m_yellow2 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1/yellow2"));
	self.m_yellow3 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1/yellow3"));
	self.m_yellow4 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1/yellow4"));
	self.m_yellow5 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1/yellow5"));
	
	self.m_mvblue1 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule1/lan1"));
	self.m_mvblue2 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule2/lan2"));
	self.m_mvblue3 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule3/lan3"));
	self.m_mvblue4 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule4/lan4"));
	self.m_mvblue5 = CEGUI.Window.toProgressBar(winMgr:getWindow("charecterjiadian/right/bule5/lan5"));
	
	self.m_imgSchemedeployOpen = winMgr:getWindow("charecterjiadian/left/tanchu");
	self.m_imgSchemedeployClose =winMgr:getWindow("charecterjiadian/left/jiadianfanganbutton/fan");
		


	
	self.addButtonArray = {self.m_addbutton1, self.m_addbutton2,
		self.m_addbutton5, self.m_addbutton4, self.m_addbutton3 };
	
	self.reduceButtonArray = {self.m_reducebutton3, self.m_reducebutton2,
		self.m_reducebutton1, self.m_reducebutton4, self.m_reducebutton5 };

	self.moveButtonArray = {self.m_movebutton1, self.m_movebutton2,
		self.m_movebutton3 , self.m_movebutton4, self.m_movebutton5};
	
	self.imageBlueArray = { self.m_blue1, self.m_blue2, self.m_blue3, self.m_blue4,
			self.m_blue5};				
	
	self.imageYellowArray = { self.m_yellow1, self.m_yellow2, self.m_yellow3, 
			self.m_yellow4,	self.m_yellow5 };
			
	self.imageMvBlueArray = { self.m_mvblue1, self.m_mvblue2, self.m_mvblue3, 
			self.m_mvblue4,	self.m_mvblue5 };
			
	self.ptrTextArray = { self.m_ptrtext1, self.m_ptrtext2, self.m_ptrtext3, self.m_ptrtext4, 
			self.m_ptrtext5};
	self.m_addbutton1:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleAddBtnClicked, self);	
	self.m_addbutton2:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleAddBtnClicked, self);	
	self.m_addbutton3:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleAddBtnClicked, self);	
	self.m_addbutton4:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleAddBtnClicked, self);	
	self.m_addbutton5:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleAddBtnClicked, self);

	self.m_addbutton1:setID( 1 );
	self.m_addbutton2:setID( 2 );
	self.m_addbutton3:setID( 5 );
	self.m_addbutton4:setID( 4 );
	self.m_addbutton5:setID( 3 );
	
	self.m_reducebutton1:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleReduceBtnClicked, self);
	self.m_reducebutton2:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleReduceBtnClicked, self);
	self.m_reducebutton3:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleReduceBtnClicked, self);
	self.m_reducebutton4:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleReduceBtnClicked, self);
	self.m_reducebutton5:subscribeEvent("MouseButtonDown", CharacterPropertyAddPtrDlg.HandleReduceBtnClicked, self);
	self.m_reducebutton1:setID( 3 );
	self.m_reducebutton2:setID( 2 );
	self.m_reducebutton3:setID( 1 );
	self.m_reducebutton4:setID( 4 );
	self.m_reducebutton5:setID( 5 );
	
	self.m_movebutton1:subscribeEvent("MouseMove", CharacterPropertyAddPtrDlg.HandleMoveBtnClicked, self);
	self.m_movebutton2:subscribeEvent("MouseMove", CharacterPropertyAddPtrDlg.HandleMoveBtnClicked, self);
	self.m_movebutton3:subscribeEvent("MouseMove", CharacterPropertyAddPtrDlg.HandleMoveBtnClicked, self);
	self.m_movebutton4:subscribeEvent("MouseMove", CharacterPropertyAddPtrDlg.HandleMoveBtnClicked, self);
	self.m_movebutton5:subscribeEvent("MouseMove", CharacterPropertyAddPtrDlg.HandleMoveBtnClicked, self);
	self.m_movebutton1:setID( 1 );
	self.m_movebutton2:setID( 2 );
	self.m_movebutton3:setID( 3 );
	self.m_movebutton4:setID( 4 );
	self.m_movebutton5:setID( 5 );
	local pos1 = self.m_movebutton1:getPosition().x.offset;
	local pos2 = self.m_movebutton2:getPosition().x.offset;
	local pos3 = self.m_movebutton3:getPosition().x.offset;
	local pos4 = self.m_movebutton4:getPosition().x.offset;
	local pos5 = self.m_movebutton5:getPosition().x.offset;
	self.movePos = {pos1, pos2, pos3, pos4, pos5};
	

	
	self.addedPointArray = { 0, 0, 0, 0, 0};
	self.addPointArray = { 0, 0, 0, 0, 0 };
	
	
	local data = gGetDataManager():GetMainCharacterData()
	
	local ntizhi = data:GetValue(fire.pb.attr.AttrType.CONS)
	local nmoli = data:GetValue(fire.pb.attr.AttrType.IQ)
	local nliliang = data:GetValue(fire.pb.attr.AttrType.STR)
	local nnaili = data:GetValue(fire.pb.attr.AttrType.ENDU)
	local nminjie = data:GetValue(fire.pb.attr.AttrType.AGI)
	
	
	
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	local total = level*5;
	self.totalPoint = total;
	self.m_ArrayLeftPro = {};
	-- 所选择的方案ID
	self.m_schemeID = data.pointSchemeID;
	self.m_btnOpenScheme = CEGUI.toPushButton(winMgr:getWindow"charecterjiadian/left/kaiqi");
	self.m_btnOpenScheme:subscribeEvent("Clicked", CharacterPropertyAddPtrDlg.HandleOpenSchemeBtnClicked, self);
	self:addButtonAnimation(self.m_btnOpenScheme, "stucdyBtnPress")---开启方案
	
	self.addedpointschemeArray = {
							{2, 2, 2, 3, 4}, 
							{1, 3, 2, 3, 4}, 
							{5, 2, 3, 1, 1}, 
						};
	local map1 = data.cons_save;
	local map2 = data.iq_save;
	local map3 = data.str_save;
	local map4 = data.endu_save;
	local map5 = data.agi_save;
	for idxMap1  = 1 , 3 do
		self.addedpointschemeArray[idxMap1][1] = map1[idxMap1]
	end
	for idxMap2  = 1 , 3 do
		self.addedpointschemeArray[idxMap2][2] = map2[idxMap2]
	end
	for idxMap3  = 1 , 3 do
		self.addedpointschemeArray[idxMap3][3] = map3[idxMap3]
	end
	for idxMap4  = 1 , 3 do
		self.addedpointschemeArray[idxMap4][4] = map4[idxMap4]
	end	
	for idxMap5  = 1 , 3 do
		self.addedpointschemeArray[idxMap5][5] = map5[idxMap5]
	end
	
	-- 服务器更新次数
	self.schemeChangeTime = data.pointSchemeChangeTimes;
	
	self.yelArray = { ntizhi - self.addedpointschemeArray[self.m_schemeID][1] , nmoli - self.addedpointschemeArray[self.m_schemeID][2] ,
	 nliliang - self.addedpointschemeArray[self.m_schemeID][3]  , nnaili - self.addedpointschemeArray[self.m_schemeID][4]  ,
	 nminjie - self.addedpointschemeArray[self.m_schemeID][5]  };	
	
	local totalTizhi = self.yelArray[1] + level*5;
	local totalMoli = self.yelArray[2] + level*5;
	local totalLiliang = self.yelArray[3] + level*5;
	local totalNaili = self.yelArray[4] + level*5;
	local totalMinjie = self.yelArray[5] + level*5;

	self.totalArray = { totalTizhi, totalMoli, totalLiliang, totalNaili, totalMinjie };
	
	
	-- 推荐加点
	self.m_btnAddPtrIntro = CEGUI.toPushButton(winMgr:getWindow"charecterjiadian/right/tuijianjiadian");
	self.m_btnAddPtrIntro:subscribeEvent("Clicked", CharacterPropertyAddPtrDlg.HandleAddIntroBtnClicked, self);
	self:addButtonAnimation(self.m_btnAddPtrIntro, "stucdyBtnPress")---推荐加点
	
	self.m_btnAddcPtrIntro = CEGUI.toPushButton(winMgr:getWindow"charecterjiadian/right/tuijianjiadian1");
	self.m_btnAddcPtrIntro:subscribeEvent("Clicked", CharacterPropertyAddPtrDlg.HandleAddIntro1BtnClicked, self);
	self:addButtonAnimation(self.m_btnAddcPtrIntro, "stucdyBtnPress")---推荐加点
	
	--关闭label
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", CharacterLabel.DestroyDialog, nil)
	
	-- 可支配剩余点数
	self.surplus = 0;
	self:GetSurplusAddPtr();
	
	--刷新加点条
	self:UpdatePtrYellowLine();
	self:UpdatePtrBlueLine();
	self:SetMoveButtonPos();
	self:SetMoveBlue();
	--刷新所有的按钮
	self:UpdateAddBtnEnable();	
	self:UpdateReduceBtnEnable();
	--self:UpdateLine();
	
	self:CaclLeftPro();
	self:UpdateSelectSchemeID( self.m_schemeID );
	
	self:CaclLeftPro();
	
	self:UpdatePtrText();
	
	self:UpdateLeftAttr();

	
	LogInfo("exit CharacterPropertyAddPtrDlg OnCreate")
end

function CharacterPropertyAddPtrDlg:CaclLeftPro()

	local data = gGetDataManager():GetMainCharacterData()	
	local qixue = data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local mofa = data:GetValue(fire.pb.attr.AttrType.SPIRIT)
	local wuliAtk = data:GetValue(fire.pb.attr.AttrType.ATTACK)
	local fashuAtk = data:GetValue(fire.pb.attr.AttrType.MAGIC_ATTACK)
	local wuliDef = data:GetValue(fire.pb.attr.AttrType.DEFEND)
	local fashuDef = data:GetValue(fire.pb.attr.AttrType.MAGIC_DEF)
	local sudu = data:GetValue(fire.pb.attr.AttrType.SPEED)
	
	local nTotalArray = { qixue, mofa, wuliAtk, fashuAtk, wuliDef, fashuDef, sudu };
	local nProArray = {self.m_protext1, self.m_protext2, self.m_protext3, self.m_protext4, self.m_protext5, self.m_protext6,self.m_protext7  };
	local nIndexArray = {fire.pb.attr.AttrType.MAX_HP,  fire.pb.attr.AttrType.MAX_MP, fire.pb.attr.AttrType.ATTACK,  fire.pb.attr.AttrType.MAGIC_ATTACK, 
		fire.pb.attr.AttrType.DEFEND, fire.pb.attr.AttrType.MAGIC_DEF, fire.pb.attr.AttrType.SPEED};
	
	
	-- 将二级属性遍历		
	for proIndex in pairs(nProArray) do
		
		local nAddptr = 0;
		
		local configProID = nIndexArray[proIndex];
				
		local nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(configProID);

		for index in pairs( self.addedPointArray ) do
			if index == 1 then
				nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
			end
			if index == 2 then
				nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
			end
			if index == 3 then
				nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
			end
			if index == 4 then
				nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]);
			end
			if index == 5 then
				nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
			end		
		end
        nAddptr = math.floor(nAddptr + self.disFloat)
		
		self.m_ArrayLeftPro[proIndex] = nTotalArray[proIndex] - nAddptr;
	end
	
end

function CharacterPropertyAddPtrDlg:getAddPointArray()
	return self.addPointArray;	
end

function CharacterPropertyAddPtrDlg:getAddedPointArray()
	return self.addedPointArray;	
end

function CharacterPropertyAddPtrDlg:UpdateLeftAttr()
	local data = gGetDataManager():GetMainCharacterData()	
	local qixue = data:GetFloatValue(fire.pb.attr.AttrType.MAX_HP)
	local mofa = data:GetFloatValue(fire.pb.attr.AttrType.MAX_MP)
	local wuliAtk = data:GetFloatValue(fire.pb.attr.AttrType.ATTACK)
	local fashuAtk = data:GetFloatValue(fire.pb.attr.AttrType.MAGIC_ATTACK)
	local wuliDef = data:GetFloatValue(fire.pb.attr.AttrType.DEFEND)
	local fashuDef = data:GetFloatValue(fire.pb.attr.AttrType.MAGIC_DEF)
	local sudu = data:GetFloatValue(fire.pb.attr.AttrType.SPEED)

	local nScaleConfig = BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(60);
	local nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end		
	end
	nAddptr = math.floor(qixue+nAddptr+ self.disFloat)- math.floor(qixue + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext1:setText( "+"..nAddptr );
	else
		self.m_proaddtext1:setText( "" );
	end
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(90);
	nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index])
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end		
	end
	nAddptr = math.floor(mofa+nAddptr+ self.disFloat) - math.floor(mofa + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext2:setText( "+"..nAddptr );
	else
		self.m_proaddtext2:setText( "" );
	end
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(130);
	nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index])
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end		
	end
	nAddptr = math.floor(wuliAtk+nAddptr+ self.disFloat) - math.floor(wuliAtk + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext3:setText( "+"..nAddptr );
	else
		self.m_proaddtext3:setText( "" );
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(140);
	nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index])
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end		
	end
	nAddptr = math.floor(wuliDef+nAddptr+ self.disFloat)- math.floor(wuliDef + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext5:setText( "+"..nAddptr );
	else
		self.m_proaddtext5:setText( "" );
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(150);
	nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index])
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end		
	end
	nAddptr = math.floor(fashuAtk+nAddptr+ self.disFloat)- math.floor(fashuAtk + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext4:setText( "+"..nAddptr )
	else
		self.m_proaddtext4:setText( "" )
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(160)
	nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index])
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])- nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end		
	end
	nAddptr = math.floor(fashuDef+nAddptr+ self.disFloat) - math.floor(fashuDef + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext6:setText( "+"..nAddptr );
	else
		self.m_proaddtext6:setText( "" );
	end
	
	nScaleConfig =   BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(200);
	nAddptr = 0;
	for index in pairs( self.addPointArray ) do
		if index == 1 then
			nAddptr = nAddptr+nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.consfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 2 then
			nAddptr = nAddptr+nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.iqfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 3 then
			nAddptr = nAddptr+nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.strfactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
		if index == 4 then
			nAddptr = nAddptr+nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.endufactor*(self.addedPointArray[index]+self.yelArray[index])
		end
		if index == 5 then
			nAddptr = nAddptr+nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]+self.addPointArray[index])-nScaleConfig.agifactor*(self.addedPointArray[index]+self.yelArray[index]);
		end
	end
	nAddptr = math.floor(sudu+nAddptr+ self.disFloat) - math.floor(sudu + self.disFloat)
	if nAddptr > 0 then
		self.m_proaddtext7:setText( "+"..nAddptr );
	else
		self.m_proaddtext7:setText( "" );
	end
end


--设置所选ID
function CharacterPropertyAddPtrDlg:UpdateSelectSchemeID(id)
	-- 首先根据加点方案， 查看是否显示加点按钮
	self.m_schemeID = id;
	
	-- 同时将按键名称换掉	
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", id)
	self.m_schemeBtn:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(10020)))
	strbuilder:delete()
	--之前的逻辑改成直接改成方案点加到固蓝中， 所以固定的蓝条值也需要改变
	-- 将已加点数清零
	for indexClear in pairs( self.addPointArray ) do
		self.addPointArray[indexClear] = 0;					
	end
	
	-- 将固定点数清零
	for indexClearA in pairs( self.addedPointArray ) do
		self.addedPointArray[indexClearA] = 0;
	end
	local data = gGetDataManager():GetMainCharacterData()
	local ntizhi = data:GetValue(fire.pb.attr.AttrType.CONS);
	local nmoli = data:GetValue(fire.pb.attr.AttrType.IQ);
	local nliliang = data:GetValue(fire.pb.attr.AttrType.STR);
	local nnaili = data:GetValue(fire.pb.attr.AttrType.ENDU);
	local nminjie = data:GetValue(fire.pb.attr.AttrType.AGI);

	for ia = 1 , 3 do
		if id == ia then			
			for ib = 1, 5 do
				self.addedPointArray[ib] = self.addedpointschemeArray[ia][ib];
			end
			break;
		end
	end
	
	
	local svrPointScheme = data.pointSchemeID;
	
	if  svrPointScheme == self.m_schemeID then
		self.m_btnOpenScheme:setVisible(  false);
		self.m_textSchemeOpen:setVisible( true );
		self.m_textintroaddpoint:setVisible(false);
		self.m_resetpointBtn:setVisible(true);
		self.m_addpointBtn:setVisible(true);
	else
		self.m_btnOpenScheme:setVisible(true);
		self.m_textSchemeOpen:setVisible( false );
		self.m_textintroaddpoint:setVisible(true);
		self.m_resetpointBtn:setVisible(false);
		self.m_addpointBtn:setVisible(false);
	end
	
	
	--刷新加点条
	self:UpdatePtrYellowLine();
	self:UpdatePtrBlueLine();
	self:SetMoveButtonPos();
	self:SetMoveBlue();
	--刷新所有的按钮
	self:UpdateAddBtnEnable();	
	self:UpdateReduceBtnEnable();
	self:UpdatePtrText();	
	self:UpdateLeftAttr();
	self:UpdateSendBtn();
	
end


-- 当玩家数据改变时， 这个界面也需要改变
function CharacterPropertyAddPtrDlg:notifyUserDataChange()


	if _instance == nil  then
		return;
	end
		
	local data = gGetDataManager():GetMainCharacterData()	
	local ntizhi = data:GetValue(fire.pb.attr.AttrType.CONS);
	local nmoli = data:GetValue(fire.pb.attr.AttrType.IQ);
	local nliliang = data:GetValue(fire.pb.attr.AttrType.STR);
	local nnaili = data:GetValue(fire.pb.attr.AttrType.ENDU);
	local nminjie = data:GetValue(fire.pb.attr.AttrType.AGI);
	
	
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL);	
	

	
	self.m_schemeID = data.pointSchemeID;
	local mapA = data.cons_save;
	local mapB = data.iq_save;
	local mapC = data.str_save;
	local mapD = data.endu_save;
	local mapE = data.agi_save;
	for idxMapA  = 1 , 3 do
		self.addedpointschemeArray[idxMapA][1] = mapA[idxMapA]
	end
	for idxMapB  = 1 , 3 do
		self.addedpointschemeArray[idxMapB][2] = mapB[idxMapB]
	end
	for idxMapC  = 1 , 3 do
		self.addedpointschemeArray[idxMapC][3] = mapC[idxMapC]
	end
	for idxMapD  = 1 , 3 do
		self.addedpointschemeArray[idxMapD][4] = mapD[idxMapD]
	end	
	for idxMapE  = 1 , 3 do
		self.addedpointschemeArray[idxMapE][5] = mapE[idxMapE]	
	end
	
	--这里的黄条可以更新， 因为一级属性已经改变
	self.yelArray = { ntizhi - self.addedpointschemeArray[self.m_schemeID][1] , nmoli - self.addedpointschemeArray[self.m_schemeID][2] ,
	 nliliang - self.addedpointschemeArray[self.m_schemeID][3]  , nnaili - self.addedpointschemeArray[self.m_schemeID][4]  ,
	 nminjie - self.addedpointschemeArray[self.m_schemeID][5]  }
	
	local totalTizhi = self.yelArray[1] + level*5
	local totalMoli = self.yelArray[2] + level*5
	local totalLiliang = self.yelArray[3] + level*5
	local totalNaili = self.yelArray[4] + level*5
	local totalMinjie = self.yelArray[5] + level*5

	self.totalArray = { totalTizhi, totalMoli, totalLiliang, totalNaili, totalMinjie }
	
	self.schemeChangeTime = data.pointSchemeChangeTimes
	
	self:GetSurplusAddPtr()
	
	
	
	--刷新加点条
	self:UpdateSelectSchemeID(self.m_schemeID)
	self:UpdatePtrYellowLine()
	self:UpdatePtrBlueLine()
	self:SetMoveButtonPos()
	self:SetMoveBlue()
	--刷新所有的按钮
	self:UpdateAddBtnEnable();
	self:UpdateReduceBtnEnable()
	self:CaclLeftPro()
	self:UpdatePtrText()
	self:UpdateSendBtn()
	
end

function CharacterPropertyAddPtrDlg:GetSurplusAddPtr()

	local addedPoint = 0;
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL);
	self.totalPoint = level*5;
	for useIdx in pairs( self.addedPointArray ) do
		addedPoint = self.addedPointArray[useIdx] + addedPoint + self.addPointArray[useIdx];
	end

	self.surplus = self.totalPoint - addedPoint;
	return self.surplus;
	
end

function CharacterPropertyAddPtrDlg:UpdateSendBtn()

	local nAddPtr = 0;
	for index in pairs( self.addPointArray ) do
		nAddPtr = nAddPtr + self.addPointArray[index];
	end
	
	if nAddPtr == 0  then
		self.m_addpointBtn:setEnabled(false);
	else
		self.m_addpointBtn:setEnabled(true);
	end
end
function CharacterPropertyAddPtrDlg:OpenScheme()
	if self.schemeChangeTime >= 1  then
	
		local configID = self.schemeChangeTime
        local maxRecordid = 0
        local tableAllId = BeanConfigManager.getInstance():GetTableByName("role.caddpointchange"):getAllID()
        for _, v in pairs(tableAllId) do
            if v>maxRecordid then
                maxRecordid = v
            end
        end
        if configID >= maxRecordid then
            configID = maxRecordid - 1
        end
		local record = BeanConfigManager.getInstance():GetTableByName("role.caddpointchange"):getRecorder(configID + 1);
		local money   = record.consume;
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", money)
			
		local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150012))
        strbuilder:delete()
			gGetMessageManager():AddConfirmBox(eConfirmNormal,msg, CharacterPropertyAddPtrDlg.OpenSchemeClickOK,self,	MessageManager.HandleDefaultCancelEvent, MessageManager)
		
	elseif 	self.schemeChangeTime ==0 then
	
		local msg = MHSD_UTILS.get_msgtipstring(150011)
		gGetMessageManager():AddConfirmBox(eConfirmNormal,msg, CharacterPropertyAddPtrDlg.OpenSchemeClickOK,self,	MessageManager.HandleDefaultCancelEvent, MessageManager)
	end
end
function CharacterPropertyAddPtrDlg:HandleOpenSchemeBtnClicked( args )
    local creqpointschemetime = require "protodef.fire.pb.creqpointschemetime"
	local req = creqpointschemetime.Create()
	LuaProtocolManager.getInstance():send(req)
end

function CharacterPropertyAddPtrDlg:OpenSchemeClickOK( args )
	gGetMessageManager():CloseCurrentShowMessageBox()
   	local configID = self.schemeChangeTime;

    local totalSilver  = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_SilverCoin)
    local maxRecordid = 0
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("role.caddpointchange"):getAllID()
    for _, v in pairs(tableAllId) do
        if v>maxRecordid then
            maxRecordid = v
        end
    end
    if configID >= maxRecordid then
        configID = maxRecordid - 1
    end
	local record = BeanConfigManager.getInstance():GetTableByName("role.caddpointchange"):getRecorder(configID + 1);
	local money   = record.consume;
    if totalSilver < money then
        local CChangepointscheme = require "protodef.fire.pb.cchangepointscheme"
	    local req = CChangepointscheme.Create()
	    req.schemeid = self.m_schemeID
        CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin,  money - totalSilver , money, req)
    else
        local CChangepointscheme = require "protodef.fire.pb.cchangepointscheme"
	    local req = CChangepointscheme.Create()
	    req.schemeid = self.m_schemeID
	    LuaProtocolManager.getInstance():send(req)
    end
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function CharacterPropertyAddPtrDlg:OpenSchemeClickCancel( args )
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	return
end


function CharacterPropertyAddPtrDlg:HandleSendBtnClicked( args )
	
	if GetBattleManager():IsInBattle() then
		GetChatManager():AddTipsMsg(160190)
		return true
	end
	
	local p = require("protodef.fire.pb.caddpointtoattr"):new()
	p.cons = self.addPointArray[1]
	p.iq = self.addPointArray[2]
	p.str = self.addPointArray[3]
	p.endu  = self.addPointArray[4]
	p.agi	= self.addPointArray[5]
	
    LuaProtocolManager:send(p)

end

-- 洗点按钮
function CharacterPropertyAddPtrDlg:HandleResetBtnClicked( args )
	--洗点
	local data = gGetDataManager():GetMainCharacterData()		
	
	local level = data:GetValue(1230);
	-- 40 级 开启 加点及洗点
	local nAddPointLevel = 40
	if level >= nAddPointLevel then
		characterpropertyaddptrresetdlg.getInstanceAndShow();
	else
	
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", nAddPointLevel)
		--150013
		local tempStrTip = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150013))
        strbuilder:delete()
		GetCTipsManager():AddMessageTip(tempStrTip)
		
	end	
end

function CharacterPropertyAddPtrDlg:HandleAddIntroBtnClicked( args )
	if AddpointIntro.getInstanceNotCreate() then
		AddpointIntro.DestroyDialog()
		return
	end
	local dlg = AddpointIntro.getInstanceAndShow(self.charecterinfo);
end	

function CharacterPropertyAddPtrDlg:HandleAddIntro1BtnClicked( args )
	if AddcpointIntro.getInstanceNotCreate() then
		AddcpointIntro.DestroyDialog()
		return
	end
	local dlg = AddcpointIntro.getInstanceAndShow(self.charecterinfo);
end	

function CharacterPropertyAddPtrDlg:SetSchemeArrowImg( beVisible )
    self.m_schemeBtnStatus = beVisible
	self.m_imgSchemedeployOpen:setVisible(not beVisible);
	self.m_imgSchemedeployClose:setVisible( beVisible);	
end

-- 加点方案按钮
function CharacterPropertyAddPtrDlg:HandleSchemeBtnClicked( args )
	
	if self.m_schemeBtnStatus then
        if AddpointListDlg.getInstanceNotCreate() then
		    AddpointListDlg.DestroyDialog()
            self.m_schemeBtnStatus = false
		    return
	    end
    else
	    local dlg = AddpointListDlg.getInstance(self.m_schemeBtn)
	    dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,10), CEGUI.UDim(0, self.m_schemeBtn:getPixelSize().height)))
	    local pos = dlg:GetWindow():getPosition() 
	    local size = dlg:GetWindow():getSize() 
	

	    pos.x.offset = pos.x.offset - 50;
	
	    dlg:GetWindow():setPosition(pos) 
	    dlg:GetWindow():setSize(size)
	
	    local cpos = dlg.container:getPosition() 
	    cpos.x.offset = cpos.x.offset - 2;
	    dlg.container:setPosition(cpos) 
        self.m_schemeBtnStatus = true
    end
end	

function CharacterPropertyAddPtrDlg:HandleMoveBtnClicked(args)
	LogInfo("AddBtn clicked")
	--如果不是当前开启方案， 不能点击
	local data = gGetDataManager():GetMainCharacterData();
	local svrPointScheme = data.pointSchemeID;
	if  svrPointScheme ~= self.m_schemeID then
		return
	end
	-- 遍历 那个 按钮 被使用
	local eventargs = CEGUI.toWindowEventArgs(args)
	local moveEvent = CEGUI.toMouseEventArgs(args)
	local delta = moveEvent.moveDelta						--移动偏移量
	local id = eventargs.window:getID()
	-- 遍历 移动 按钮组
	for index in pairs(self.moveButtonArray) do
		if id == 3 then
			local m = 0;
		end
		if id  == index then
			local tmpBtn = self.moveButtonArray[index];
			local pos = tmpBtn:getPosition()
			local size = tmpBtn:getSize()
			-- 增加x水平线的偏移
			pos.x.offset = pos.x.offset+delta.x;
			--获取 蓝色条的长度
			local tmpBl = self.imageBlueArray[index];
			local totalWidth  = tmpBl:getWidth().offset;
			local tmpBlScale = tmpBl:getProgress();
			local nWidth = totalWidth*tmpBl:getProgress();	
			-- 最小单位, 每一个对应的 点数不同， 取totalArray值
			local perDistan = totalWidth/self.totalArray[index];
			--local perDistan = totalWidth/self.totalPoint;
			-- 这个值需要每次都更新一次
			local surplusPtr = self:GetSurplusAddPtr();
			-- 最小为蓝框
			local nEssenX = self.movePos[index];
			local miniOffset = perDistan*(self.yelArray[index]+self.addedPointArray[index]) + nEssenX ;
			--local maxOffset = totalWidth+nEssenX;
			local maxOffset = perDistan*(  self.yelArray[index] 
					+ self.addedPointArray[index] + self.addPointArray[index] + surplusPtr) + nEssenX ;			
			-- 这里涉及到拖到误差的问题， 因为进行叠加式太麻烦这里到最大值， 直接将显示改变
			local tmpText = self.ptrTextArray[index];
			--self.m_pDailyRewardBtn:setEnabled(false) 
			local bMini = false;
			local bMax = false;
			if pos.x.offset <= miniOffset then
				pos.x.offset = miniOffset;
				bMini = true;
			end
			if  pos.x.offset >= maxOffset then
				pos.x.offset = maxOffset;
				bMax = true;
			end
			--计算所加点数
			local nAddPtr = math.ceil((pos.x.offset - nEssenX)/perDistan);			
			local nStr = "";
			if bMini  then				
				nAddPtr = (self.yelArray[index]+self.addedPointArray[index]);
			elseif bMax  then
				nAddPtr = (self.yelArray[index] + self.addedPointArray[index] +
				 self.addPointArray[index] + surplusPtr);
			end
			nStr = nStr..nAddPtr;
			tmpText:setText(nStr);	
			--设置坐标		
			tmpBtn:setPosition(pos);
			tmpBtn:setSize(size);
			--这里让可移动蓝条跟随
			local tmpMvBl = self.imageMvBlueArray[index];
			local posMv = tmpMvBl:getPosition();
			local value = pos.x.offset - nEssenX;
			local nScale = value/totalWidth;
			tmpMvBl:setProgress( nScale );
			--处理点数
			self.addPointArray[index] = nAddPtr - self.yelArray[index]-self.addedPointArray[index];
			--这里重新计算一下点数
			self.surplus = self:GetSurplusAddPtr();
			
		end
	end
	self:UpdatePtrYellowLine();
	self:UpdatePtrBlueLine();
	self:SetMoveBlue();
	self:UpdateAddBtnEnable();	
	self:UpdateReduceBtnEnable();
	self:UpdatePtrText();	
	self:UpdateLeftAttr();
	self:UpdateSendBtn();
	
end


-- 更新点数文本
function CharacterPropertyAddPtrDlg:UpdatePtrText()
	for index in pairs( self.ptrTextArray ) do
		local totalPtr = self.yelArray[index] + self.addedPointArray[index]
			+ self.addPointArray[index]
		local tmpText = self.ptrTextArray[ index ]
		tmpText:setText(""..totalPtr)
		local tmpTextAdd = self.ptrAddTextArray[ index ]
		if self.addPointArray[index] > 0 then
			tmpTextAdd:setText("+"..self.addPointArray[index] )
		else
			tmpTextAdd:setText( "" )
		end
		
	end
	
	local nSurplus = self:GetSurplusAddPtr()
	self.m_surplustext:setText(""..nSurplus)
	local data = gGetDataManager():GetMainCharacterData()	

	local qixue = data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local mofa = data:GetValue(fire.pb.attr.AttrType.MAX_MP)
	local wuliAtk = data:GetValue(fire.pb.attr.AttrType.ATTACK)
	local fashuAtk = data:GetValue(fire.pb.attr.AttrType.MAGIC_ATTACK)
	local wuliDef = data:GetValue(fire.pb.attr.AttrType.DEFEND)
	local fashuDef = data:GetValue(fire.pb.attr.AttrType.MAGIC_DEF)
	local sudu = data:GetValue(fire.pb.attr.AttrType.SPEED)
	
	
	self.m_protext1:setText(""..qixue)
	self.m_protext2:setText(""..mofa)
	self.m_protext3:setText(""..wuliAtk)
	self.m_protext4:setText(""..fashuAtk)
	self.m_protext5:setText(""..wuliDef)
	self.m_protext6:setText(""..fashuDef)
	self.m_protext7:setText(""..sudu)
	
	local nProArray = {self.m_protext1, self.m_protext2, self.m_protext3, self.m_protext4, self.m_protext5, self.m_protext6,self.m_protext7  }
	local nIndexArray = {fire.pb.attr.AttrType.MAX_HP,  fire.pb.attr.AttrType.MAX_MP, fire.pb.attr.AttrType.ATTACK,  fire.pb.attr.AttrType.MAGIC_ATTACK, 
		fire.pb.attr.AttrType.DEFEND, fire.pb.attr.AttrType.MAGIC_DEF, fire.pb.attr.AttrType.SPEED}
	
	
	-- 将二级属性遍历		
	for proIndex in pairs(nProArray) do
		local tmpText = nProArray[proIndex]
		local nAddptr = 0
		
		local configProID = nIndexArray[proIndex]

	
	    local nScaleConfig = BeanConfigManager.getInstance():GetTableByName("role.cattrmoddata"):getRecorder(configProID)
	    for index in pairs( self.addPointArray ) do
		    if index == 1 then
			    nAddptr = nAddptr+nScaleConfig.consfactor* (self.addedPointArray[index] - self.addedpointschemeArray[data.pointSchemeID][index])
		    end
		    if index == 2 then
			    nAddptr = nAddptr+nScaleConfig.iqfactor* (self.addedPointArray[index] - self.addedpointschemeArray[data.pointSchemeID][index])
		    end
		    if index == 3 then
			    nAddptr = nAddptr+nScaleConfig.strfactor* (self.addedPointArray[index] - self.addedpointschemeArray[data.pointSchemeID][index])
		    end
		    if index == 4 then
			    nAddptr = nAddptr+nScaleConfig.endufactor* (self.addedPointArray[index] - self.addedpointschemeArray[data.pointSchemeID][index])
		    end
		    if index == 5 then
			    nAddptr = nAddptr+nScaleConfig.agifactor* (self.addedPointArray[index] - self.addedpointschemeArray[data.pointSchemeID][index])
		    end
	    end

        local pro = data:GetFloatValue(configProID)
        nAddptr = math.floor(pro + self.disFloat + nAddptr)
		tmpText:setText( ""..(nAddptr) )
	end


end	


-- 设置移动按钮位置, 根据蓝条的位置， 在初始阶段
function CharacterPropertyAddPtrDlg:SetMoveButtonPos()
	-- 遍历 移动 按钮组
	for index in pairs(self.moveButtonArray) do
		local tmpBtn = self.moveButtonArray[index]
		
		local size = tmpBtn:getSize()
		local pos = tmpBtn:getPosition()
		
		--获取 蓝色条的长度
		local tmpBl = self.imageBlueArray[index]
		-- 计算已经加的点数 / 总数
		scale =   (self.yelArray[index]+self.addedPointArray[index] + self.addPointArray[index] ) / self.totalArray[index]
		local nWidth = tmpBl:getWidth().offset* scale 
		pos.x.offset = self.movePos[index]+nWidth
		tmpBtn:setPosition(pos)
		tmpBtn:setSize(size)
	end	
end

-- 将可移动的蓝条直接设置成0.0
function CharacterPropertyAddPtrDlg:SetMoveBlue()
	for index in pairs(self.imageMvBlueArray) do
		local tmpImg = self.imageMvBlueArray[index]
		-- 计算已经加的点数 / 总数
		scale =   (self.yelArray[index]+self.addedPointArray[index] + self.addPointArray[index] ) / self.totalArray[index]
		tmpImg:setProgress(scale)
	end
	
end


function CharacterPropertyAddPtrDlg:HandleAddBtnClicked(args)
	LogInfo("AddBtn clicked")
	
	--如果不是当前开启方案， 不能点击
	local data = gGetDataManager():GetMainCharacterData()
	local svrPointScheme = data.pointSchemeID
	if  svrPointScheme ~= self.m_schemeID then
		return
	end
	-- 遍历 那个 按钮 被使用
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	-- 遍历 加号 按钮组
	for index in pairs(self.addButtonArray) do
		if id  == index then
			if self.surplus > 0 then
				self.addPointArray[index] = self.addPointArray[index] + 1
				self.surplus = self.surplus - 1
			end
			--设置进度条， 设置拖动按钮
		end
	end	
	--刷新加点条
	self:UpdatePtrYellowLine();
	self:UpdatePtrBlueLine();
	self:SetMoveButtonPos();
	self:SetMoveBlue();
	--刷新所有的按钮
	self:UpdateAddBtnEnable();	
	self:UpdateReduceBtnEnable();
	self:UpdatePtrText();	
	self:UpdateLeftAttr();
	self:UpdateSendBtn();
	
end


function CharacterPropertyAddPtrDlg:UpdateLine()
	-- 根据 addedPoint 的情况添加事件
	-- 遍历 移动 按钮组
	for index in pairs( self.addPointArray ) do
		local tmpPoint = self.addPointArray[index];
		--获取 蓝色条的长度
		local tmpBl = self.imageBlueArray[index];
		local totalWidth  = tmpBl:getWidth().offset;
		local tmpBlScale = tmpBl:getProgress();
		-- 最小单位, 每一个对应的 点数不同， 取totalArray值
		local perDistan = totalWidth/self.totalArray[index];
		local totalPtr = tmpPoint + self.addedPointArray[index] + self.yelArray[index] ;
		local scale = totalPtr / self.totalArray[index];
		--根据比例设置 progressBar 的百分比
		tmpBl:setProgress( scale );
		--设置可动按钮的位置
		local mvBtn = self.moveButtonArray[index];
		local essenX = self.movePos[index];
		local mvWidth = scale*totalWidth+essenX;		
		local pos = mvBtn:getPosition();
		local size = mvBtn:getSize();
		pos.x.offset = mvWidth;
		mvBtn:setPosition( pos );
		mvBtn:setSize( size );
	end
end
function CharacterPropertyAddPtrDlg:UpdateAddBtnEnable()
	self.surplus = self:GetSurplusAddPtr();
	if self.surplus > 0 then
		
	end
		
	for index in pairs( self.addButtonArray ) do
		local tmpBtn = self.addButtonArray[index];
		tmpBtn:setEnabled( (self.surplus > 0) );
	end
	
end
function CharacterPropertyAddPtrDlg:HandleReduceBtnClicked(args)
	LogInfo("AddBtn clicked")
	local data = gGetDataManager():GetMainCharacterData();
	local svrPointScheme = data.pointSchemeID;
	
	if  svrPointScheme ~= self.m_schemeID then
		return
	end
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	for index in pairs(self.reduceButtonArray) do
		
		if id  == index then
			
			if self.addPointArray[index] > 0 then
				self.addPointArray[index] = self.addPointArray[index] - 1;
				self.surplus = self.surplus + 1;
			end
			
		end
	end
	self:UpdatePtrYellowLine();
	self:UpdatePtrBlueLine();
	self:SetMoveButtonPos();
	self:SetMoveBlue();
	self:UpdateAddBtnEnable();	
	self:UpdateReduceBtnEnable();
	self:UpdatePtrText();	
	
	self:UpdateLeftAttr();
	self:UpdateSendBtn();
	
end
function CharacterPropertyAddPtrDlg:UpdateReduceBtnEnable()

	for index in pairs( self.reduceButtonArray ) do
		local tmpBtn = self.reduceButtonArray[index];
		
		if self.addPointArray[index] <= 0 then
			tmpBtn:setEnabled(false);
		else
			tmpBtn:setEnabled(true);
		end
		
	end
	
end

function CharacterPropertyAddPtrDlg:UpdatePtrBlueLine()
	for index in pairs( self.imageBlueArray ) do
		local scale =  (self.addedPointArray[index]+self.yelArray[index]) / self.totalArray[index];
		local tempBlBar = self.imageBlueArray[index];
		tempBlBar:setProgress(scale);
	end	
end

function CharacterPropertyAddPtrDlg:UpdatePtrYellowLine()
	for yellowIdx in pairs( self.imageYellowArray ) do
		local scale = self.yelArray[yellowIdx] / self.totalArray[yellowIdx];
		local tempYelBar = self.imageYellowArray[yellowIdx];
		tempYelBar:setProgress(scale);
	end

end

function CharacterPropertyAddPtrDlg:UpdatePointLine()
	local data = gGetDataManager():GetMainCharacterData()
	local strengh = data:GetValue(fire.pb.attr.AttrType.CONS);
	local hpR = (data:GetValue(fire.pb.attr.AttrType.MAX_HP)-data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP)) / data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local mp = data:GetValue(fire.pb.attr.AttrType.MP) / data:GetValue(fire.pb.attr.AttrType.MAX_MP)
	local sp = data:GetValue(fire.pb.attr.AttrType.SP) / data:GetValue(fire.pb.attr.AttrType.MAX_SP)

	
	for blueIdx in pairs( self.imageBlueArray ) do		
		local tempBlBar = self.imageBlueArray[blueIdx];
		tempBlBar:setProgress(1.0);
	end
	
	for yellowIdx in pairs( self.imageYellowArray ) do
		local tempYelBar = self.imageYellowArray[yellowIdx];
		tempYelBar:setProgress(0.5);
	end
	
	
end


return CharacterPropertyAddPtrDlg
