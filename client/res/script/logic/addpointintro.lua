require "logic.dialog"
require "utils.commonutil"

AddpointIntro = {}
setmetatable(AddpointIntro, Dialog)
AddpointIntro.__index = AddpointIntro

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function AddpointIntro:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AddpointIntro)
    return self
end

function AddpointIntro.getInstance(parent)
    if not _instance then
        _instance = AddpointIntro:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function AddpointIntro.getInstanceAndShow(parent)
    if not _instance then
        _instance = AddpointIntro:new()
        _instance:OnCreate(parent)
	else
		--_instance:SetVisible(true)
    end
    _instance:SetVisible(true)
    return _instance
end

function AddpointIntro.getInstanceNotCreate()
    return _instance
end

function AddpointIntro.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function AddpointIntro.ToggleOpenClose(parent)
	if not _instance then 
		_instance = AddpointIntro:new() 
		_instance:OnCreate(parent)
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function AddpointIntro.GetLayoutFileName()
    return "explainjiadian.layout"
end

function AddpointIntro:OnCreate(parent)

    Dialog.OnCreate(self, parent)

    local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.basewindow = CEGUI.toPushButton(winMgr:getWindow("explainjiadian"))
	--self.basewindow:subscribeEvent("Clicked", AddpointIntro.HandleBaseBgClicked , self)	
    --self.line = winMgr:getWindow("charecterinfo/line")
		
	self.textscheme1 = winMgr:getWindow("explainjiadian/bg/text1");
	self.textscheme2 = winMgr:getWindow("explainjiadian/bg/text2");
	self.textscheme3 = winMgr:getWindow("explainjiadian/bg/text3");
	self.arrayTextScheme = {self.textscheme1 , self.textscheme2, self.textscheme3};
	
	self.textschemeintro1 = winMgr:getWindow("explainjiadian/bg/shuoming1");
	self.textschemeintro2 = winMgr:getWindow("explainjiadian/bg/shuoming2");
	self.textschemeintro3 = winMgr:getWindow("explainjiadian/bg/shuoming3");
	self.arrayTextSchemeIntro = {self.textschemeintro1 , self.textschemeintro2, self.textschemeintro3};


	self.textaddedptr1 = winMgr:getWindow("explainjiadian/bg/dianshu1");
	self.textaddedptr2 = winMgr:getWindow("explainjiadian/bg/2dian");
	self.textaddedptr3 = winMgr:getWindow("explainjiadian/bg/3dian");
	self.textaddedptr4 = winMgr:getWindow("explainjiadian/bg/4dian");
	self.textaddedptr5 = winMgr:getWindow("explainjiadian/bg/5dian");
	
	self.textrecommend1 = winMgr:getWindow("explainjiadian/bg/tuijian1");
	self.textrecommend2 = winMgr:getWindow("explainjiadian/bg/tuijian2");
	self.textrecommend3 = winMgr:getWindow("explainjiadian/bg/tuijian3");
	
	self.textAddptrArray = { self.textaddedptr1, self.textaddedptr2, self.textaddedptr3, 
								self.textaddedptr4, self.textaddedptr5 };
	
	
	self:UpdateText();
    -- get windows	
end

function AddpointIntro:HandleBaseBgClicked(args)
	
	self.DestroyDialog()
end

function AddpointIntro:UpdateText()
	--CharacterPropertyAddPtrDlg.getInstance():UpdateSelectSchemeID(index);
	
	local data = gGetDataManager():GetMainCharacterData();	
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL);
	LogInfo("AddpointIntro:UpdateText Get The Level " .. level)
	local school = data.school;
	
	self.textscheme1:setText( BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).scheme	 );
	self.textscheme2:setText( BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).scheme2	 );
	self.textscheme3:setText( BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).scheme3	 );
	
	self.textschemeintro1:setText( BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).explain	 );
	self.textschemeintro2:setText( BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).explain2	 );
	self.textschemeintro3:setText( BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).explain3	 );
	
	local tmpAddpointArray = CharacterPropertyAddPtrDlg.getInstance():getAddedPointArray();
	for index in pairs( tmpAddpointArray ) do
		local tmpText = self.textAddptrArray[index];
		local nPoint = tmpAddpointArray[index];
		tmpText:setText( "".. nPoint );
	end
	
	local textArray = {};	
	
	local showproArray1 = {};
	--addpoint2, addpoint3
	--local nWord = string.format( " %d个 %s %s" , nPrice, nCoinStr, (nRefreshTimes) );
	local tmpvector = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).addpoint;	
	

	local showindex = 0;
	for indexvec = 0 , tmpvector:size() - 1 do
		if( indexvec == 0 ) then
			--tizhi
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(10)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};				
			end
		elseif indexvec == 1 then
		--zhili
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(20)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};
			end
		elseif indexvec == 2 then
		--liliang
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(30)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};				
			end
		elseif indexvec == 3 then
		--naili
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(40)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};										
			end
		elseif indexvec == 4 then
		--minjie
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(50)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};					
			end
		end
	end				
	-- 拼接第一条显示
	local nWord = "";

	table.sort( showproArray1, function(a, b)
	 return a[2] > b[2] 
	end  );	
	for index in pairs(showproArray1)  do
		--if index > 3 then -- 一共就显示三项
			--break
			nWord = nWord..showproArray1[index][3].. showproArray1[index][2];
		--end		
	end
	self.textrecommend1:setText(nWord);
	
	
	-- 第二列
	showproArray1 = {};
	--addpoint2, addpoint3
	--local nWord = string.format( " %d个 %s %s" , nPrice, nCoinStr, (nRefreshTimes) );
	tmpvector = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).addpoint2;	
	
	showindex = 0;
	for indexvec = 0 , tmpvector:size() - 1 do
		if( indexvec == 0 ) then
			--tizhi
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(10)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};				
			end
		elseif indexvec == 1 then
		--zhili
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(20)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};
			end
		elseif indexvec == 2 then
		--liliang
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(30)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};				
			end
		elseif indexvec == 3 then
		--naili
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(40)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};										
			end
		elseif indexvec == 4 then
		--minjie
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(50)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};					
			end
		end
	end				
	-- 拼接第一条显示
	nWord = "";
	table.sort( showproArray1, function(a, b)
	 return a[2] > b[2] 
	end  );	
	for index in pairs(showproArray1)  do
		--if index > 3 then -- 一共就显示三项
			--break
			nWord = nWord..showproArray1[index][3].. showproArray1[index][2];
		--end		
	end
	self.textrecommend2:setText(nWord);
	
	
	-- 第三列
	showproArray1 = {};
	--addpoint2, addpoint3
	--local nWord = string.format( " %d个 %s %s" , nPrice, nCoinStr, (nRefreshTimes) );
	tmpvector = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school).addpoint3;	
	
	showindex = 0;
	for indexvec = 0 , tmpvector:size() - 1 do
		if( indexvec == 0 ) then
			--tizhi
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(10)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};				
			end
		elseif indexvec == 1 then
		--zhili
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(20)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};
			end
		elseif indexvec == 2 then
		--liliang
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(30)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};				
			end
		elseif indexvec == 3 then
		--naili
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(40)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};										
			end
		elseif indexvec == 4 then
		--minjie
			local nConfigPoint = tmpvector[indexvec];
			if  nConfigPoint > 0 then
				showindex = showindex + 1;
                local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(50)
				showproArray1[showindex] = { showindex, nConfigPoint*level, attrconfig.name..":"};					
			end
		end
	end					
	-- 拼接第一条显示
	nWord = "";
	table.sort( showproArray1, function(a, b)
	 return a[2] > b[2] 
	end  );	
	for index in pairs(showproArray1)  do
		--if index > 3 then -- 一共就显示三项
			--break
			nWord = nWord..showproArray1[index][3].. showproArray1[index][2];
		--end		
	end
	
	
	self.textrecommend3:setText(nWord);
	
	
	--local GetSchoolInfoTableInstance();
	
	
	
end



return AddpointIntro
