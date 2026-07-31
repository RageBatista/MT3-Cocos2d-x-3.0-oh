------------------------------------------------------------------
-- 宠物图鉴
------------------------------------------------------------------
require "logic.dialog"
--require "logic.multimenu"
require "logic.multimenuset"

local RANDOM_ACT = {
eActionRun,
eActionAttack,
eActionMagic1
}

--[[
fire.pb.pet.PetTypeEnum.WILD = 1	--野生
fire.pb.pet.PetTypeEnum.BABY = 2 --宝宝
fire.pb.pet.PetTypeEnum.VARIATION	= 3 --变异
fire.pb.pet.PetTypeEnum.SACREDANIMAL = 4 --神兽
--]]


PetGalleryDlg = {
	selectedPetID = 0
}
setmetatable(PetGalleryDlg, Dialog)
PetGalleryDlg.__index = PetGalleryDlg

local _instance
function PetGalleryDlg.getInstance()
	if not _instance then
		_instance = PetGalleryDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetGalleryDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetGalleryDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetGalleryDlg.getInstanceNotCreate()
	return _instance
end

function PetGalleryDlg.DestroyDialog()
	if _instance then 
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function PetGalleryDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetGalleryDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetGalleryDlg.GetLayoutFileName()
	return "petfieldguide_mtg.layout"
end

function PetGalleryDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetGalleryDlg)
	return self
end

function PetGalleryDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.nameText = winMgr:getWindow("petfieldguide_mtg/Left/Page8")
	self.profileIcon = winMgr:getWindow("petfieldguide_mtg/Left/Item")
	self.kindImg = winMgr:getWindow("petfieldguide_mtg/Left/Item16/imagebb")
	self.fightLevel = winMgr:getWindow("petfieldguide_mtg/Left/Item16/textlevel")
	self.gainWayBtn1 = CEGUI.toPushButton(winMgr:getWindow("petfieldguide_mtg/Left1/textbg1/btnditu"))
	self.gainWayBtn2 = CEGUI.toPushButton(winMgr:getWindow("petfieldguide_mtg/Left1/textbg1/btnditu1"))
	self.gainWayBtn3 = CEGUI.toPushButton(winMgr:getWindow("petfieldguide_mtg/Left1/textbg1/btnditu2"))
	self.babyGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/Left1/groupbtnbb"))
	self.bianyiGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/Left1/groupbtnbianyi"))
	self.wildGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/Left1/groupbtnbb2"))
	self.gongzi = winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/textzizhi1")
	self.tizi = winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/textzizhi2")
	self.suzi = winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/textzizhi3")
	self.fangzi = winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/textzizhi4")
	self.fazi = winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/textzizhi5")
	self.grow = winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/textzizhi6")
	self.discuss = CEGUI.toPushButton(winMgr:getWindow("petfieldguide_mtg/Left1/btnpingjia"))
	self.filterBtn = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/beijingkuang/btnquanbu"))
	self.lingshouBtn = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/left/btnquanbu1"))
	self.shenshouBtn = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/beijingkuang/btnquanbu1"))
	self.m_cashicon = winMgr:getWindow("petfieldguide_mtg/Left/Item161")	
	self.xuanze =winMgr:getWindow("petfieldguide_mtg/beijingkuang")
	self.quanbu = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/quanbu"))
	self.petshape = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/shizhuang"))

    self.filterBtn:setSelected(true)

--    self.filterBtn:setProperty("NormalImage", "set:renwuzhedang image:h60")
--    self.filterBtn:setProperty("PushedImage", "set:renwuzhedang image:l60")

--    self.lingshouBtn:setProperty("NormalImage", "set:renwuzhedang image:h60")
--    self.lingshouBtn:setProperty("PushedImage", "set:renwuzhedang image:l60")

	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("petfieldguide_mtg/left/list"))
	self.petTable = CEGUI.toItemTable(winMgr:getWindow("petfieldguide_mtg/left/list/petTable"))

	-- self:GetCloseBtn():removeEvent("Clicked")
	-- self:GetCloseBtn():subscribeEvent("Clicked", PetLabel.hide, nil)
	
	self.gainWayBtn1:subscribeEvent("Clicked", PetGalleryDlg.handleGainWayClicked, self)
	self.gainWayBtn2:subscribeEvent("Clicked", PetGalleryDlg.handleBuyPetClicked, self)
	self.gainWayBtn3:subscribeEvent("Clicked", PetGalleryDlg.handleBuyPet2Clicked, self)
	self.discuss:subscribeEvent("Clicked", PetGalleryDlg.handleDiscussClicked, self)
	self.filterBtn:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleFilterClicked, self)
	self.lingshouBtn:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleLingShouClicked, self)
	self.shenshouBtn:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleShenShouClicked, self)
	self.petScroll:EnableAllChildDrag(self.petScroll)
	self.petTable:subscribeEvent("TableClick", PetGalleryDlg.handlePetClicked, self)
	self.quanbu:subscribeEvent("Clicked", PetGalleryDlg.handleChangeNameOnClicked, self)
	self.petshape:subscribeEvent("MouseClick", PetGalleryDlg.handlePetShapeClicked, self)

	
	self.skillBoxes = {}
	for i=1,8 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/box"..i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", PetGalleryDlg.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
	end
    
	self.upBtnes = {}
	for i=1,4 do
		self.upBtnes[i] = CEGUI.toGroupButton(winMgr:getWindow("petfieldguide_mtg/Left1/textbg2/btntishen"..i))
		self.upBtnes[i]:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleUpGroupBtnClicked, self)
        self.upBtnes[i]:setID(i)
	end
   
	self.showPropType = 1
	self.babyGroupBtn:setID(fire.pb.pet.PetTypeEnum.BABY)
	self.bianyiGroupBtn:setID(fire.pb.pet.PetTypeEnum.VARIATION)
	self.wildGroupBtn:setID(fire.pb.pet.PetTypeEnum.WILD)
	self.babyGroupBtn:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleGroupBtnClicked, self)
	self.bianyiGroupBtn:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleGroupBtnClicked, self)
	self.wildGroupBtn:subscribeEvent("SelectStateChanged", PetGalleryDlg.handleGroupBtnClicked, self)
	
	self:converPetShopData()
	self:loadAllPetData()
	self:refreshPetTable()

end

--如果是在宠物商店有卖，就把宠物id保存为key，值为它在宠物商店里的可见等级
function PetGalleryDlg:converPetShopData()
	self.petShopTable = {}	
	local ids = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getAllID()
	for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getRecorder(id)
		for j=0, conf.goodsids:size()-1 do
			local goods = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(conf.goodsids[j])
			self.petShopTable[goods.itemId] = conf.limitLookLv
		end
	end
	ids = nil
end

function PetGalleryDlg:loadAllPetData()
	self.allPetData = {}
	local ids = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getAllID()
	for i = 1, #ids do
		local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(ids[i])
		if (not IsPointCardServer() and conf.whethershow == 1) or (IsPointCardServer() and conf.pointcardisshow == 1) then
			table.insert(self.allPetData, conf)
		end
	end

	table.sort(self.allPetData, function(v1,v2)
		if v1.uselevel < v2.uselevel then
			return true
		end
		if v1.uselevel == v2.uselevel and v1.id < v2.id then
			return true
		end
		return false
	end)
end

function PetGalleryDlg:refreshPetTable(levelmin, levelmax)
	local filterData = {}
	if levelmin == nil or (levelmin == 0 and levelmax == 0) then
		for _,v in pairs(self.allPetData) do
			if v.unusualid~=1 and v.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then
				table.insert(filterData, v)
			end
		end
    elseif levelmin == 10000 and levelmax == 10000 then --灵兽
        for _,v in pairs(self.allPetData) do
			if  v.unusualid == 1 and v.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then
				table.insert(filterData, v)
			end
		end
    elseif levelmin == 20000 and levelmax == 20000 then --神兽
        for _,v in pairs(self.allPetData) do
			if v.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
				table.insert(filterData, v)
			end
		end
	else
		for _,v in pairs(self.allPetData) do
			if  v.uselevel >= levelmin and v.uselevel <= levelmax and v.unusualid~=1 then
				table.insert(filterData, v)
			end
		end
	end
	
	if #filterData > 0 then
		self.selectedPetID = filterData[1].id
	end
	self.selectedPetID = self.selectedPetID or 0
	
	
	local num = #filterData
	local row = math.ceil(num/3)
	if self.petTable:GetRowCount() ~= row then
		self.petTable:SetRowCount(row)
		local h = self.petTable:GetCellHeight()
		local spaceY = self.petTable:GetSpaceY()
		self.petTable:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
		--self.petScroll:EnableAllChildDrag(self.petScroll)
	end

	for i=1, row*3 do
		local cell = self.petTable:GetCell(i-1)
		cell:Clear()
		cell:SetHaveSelectedState(true)
		if i <= num then
			local conf = filterData[i]
			local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(conf.modelid)
			local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
			cell:SetImage(image)
			cell:SetTextUnit(conf.uselevel)
			if conf.quality <= 4 then---只显示品质4以下的等级文本，和官方一样。cc254
            cell:SetTextUnit(conf.uselevel)
            else
            cell:SetTextUnit("")
            end
			--cell:setUserData(conf)
			cell:setID(conf.id)
            SetItemCellBoundColorByQulityPet(cell, conf.quality)
            self.petScroll:EnableChildDrag(cell)
			if conf.id == self.selectedPetID then
				cell:SetSelected(true)
			end
		else
			cell:setVisible(false)
		end
	end
	
	
	self:refreshSelectedPet()
end

function PetGalleryDlg:refreshSelectedPet()
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.selectedPetID)
    if not conf then
        return
    end
	
	--保存宠物的表数据，key为kind
	self.petConfs = {}
	self.petConfs[conf.kind] = conf
	if conf.kind ~= fire.pb.pet.PetTypeEnum.BABY and conf.thebabyid ~= 0 then --宝宝
		self.petConfs[fire.pb.pet.PetTypeEnum.BABY] = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.thebabyid)
	end
	if conf.kind ~= fire.pb.pet.PetTypeEnum.VARIATION and conf.thebianyiid ~= 0 then --变异
		self.petConfs[fire.pb.pet.PetTypeEnum.VARIATION] = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.thebianyiid)
	end
    if conf.kind ~= fire.pb.pet.PetTypeEnum.WILD and conf.thewildid ~= 0 then --野生
        self.petConfs[fire.pb.pet.PetTypeEnum.WILD] = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.thewildid)
    end

    if conf.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then --神兽
        self.babyGroupBtn:setVisible(false)
        self.bianyiGroupBtn:setVisible(false)
		self.wildGroupBtn:setVisible(false)
        for i=1,#self.upBtnes do
            self.upBtnes[i]:setVisible(true)
        end
        self.upBtnes[1]:setSelected(true, false)
	    self.curUpKind = 1
        self.showPropType = 2
    else
        self.babyGroupBtn:setVisible(true)
		self.babyGroupBtn:setSelected(true, false)
        self.bianyiGroupBtn:setVisible(self.petConfs[fire.pb.pet.PetTypeEnum.VARIATION] ~= nil)
        self.wildGroupBtn:setVisible(self.petConfs[fire.pb.pet.PetTypeEnum.WILD] ~= nil)
        for i=1,#self.upBtnes do
            self.upBtnes[i]:setVisible(false)
        end
        self.showPropType = 1
	end
	
    local wildconf = self.petConfs[fire.pb.pet.PetTypeEnum.WILD] or conf
    local bornmapdes = (IsPointCardServer() and wildconf.pointcardbornmapdes or wildconf.bornmapdes)
    local bornmapid = (IsPointCardServer() and wildconf.pointcardbornmapid or wildconf.bornmapid)
	self.gainWayBtn1:setText(bornmapdes)
	self.gainWayBtn1:setID(bornmapid)
	self.gainWayBtn1:setEnabled(bornmapid ~= 0)
	
	if self.petShopTable[wildconf.id] then
        self.gainWayBtn2:setID(wildconf.id)
		self.gainWayBtn2:setID2(self.petShopTable[wildconf.id])
		self.gainWayBtn2:setEnabled(true)
	else
        self.gainWayBtn2:setID(0)
		self.gainWayBtn2:setEnabled(false)
	end

	
    local babyconf =  self.petConfs[fire.pb.pet.PetTypeEnum.BABY] or conf
	self.curPetKind = babyconf.kind
	
    --self.nameText:setProperty("TextColours", babyconf.colour)
	self.nameText:setProperty("TextColours", "ff743a0f")----图鉴宠物名字颜色
	self.nameText:setText(babyconf.name)
	self.fightLevel:setText(babyconf.uselevel)
    local imgpath = GetPetKindImageRes(babyconf.kind, babyconf.unusualid)
	self.kindImg:setProperty("Image", imgpath)
    UseImageSourceSize(self.kindImg, imgpath)
	self:refreshPetSprite(babyconf)
	
	local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(babyconf.modelid)
	if config and config.roleimage then
		local strHeadPath = gGetIconManager():GetImagePathByID(config.roleimage):c_str()
		self.m_cashicon:setProperty("Image", strHeadPath)
		UseImageSourceSize(self.m_cashicon, strHeadPath)
	end
    if babyconf.uselevel >= 55 or conf.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
        self.gainWayBtn3:setEnabled(true)
    else
        self.gainWayBtn3:setEnabled(false)
    end
	self:refreshAttributes()
	
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.selectedPetID)
    if petAttr then
        local common323 = GameTable.common.GetCCommonTableInstance():getRecorder(323)
        local common668 = GameTable.common.GetCCommonTableInstance():getRecorder(668)
        local mustRate = common323 and tonumber(common323.value) or nil
        local rareRate = common668 and tonumber(common668.value) or nil

        for i = 1, 8 do
            self.skillBoxes[i]:Clear()
            if i <= conf.skillid:size() then
                -- SkillBoxControl.SetSkillInfo(self.skillBoxes[i], conf.skillid[i-1])
                SetPetSkillBoxInfo(self.skillBoxes[i], conf.skillid[i-1])
                --显示必带角标
                for j = 0, petAttr.skillid:size() - 1 do
                    if petAttr.skillid[j] == conf.skillid[i-1] then
                        local curRate = petAttr.skillrate[j]
                        if curRate then
                            if mustRate and curRate >= mustRate then
                                self.skillBoxes[i]:SetCornerImage("chongwuui", "chongwu_bidai")
                            elseif rareRate and curRate >= rareRate then
                                self.skillBoxes[i]:SetCornerImage("ccui1", "tm")
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

function PetGalleryDlg:refreshPetSprite(petConf)
	if not self.sprite then
		local s = self.profileIcon:getPixelSize()
		self.sprite = gGetGameUIManager():AddWindowSprite(self.profileIcon, petConf.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, false)
	else
		self.sprite:SetModel(petConf.modelid)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
    self.sprite:SetDyePartIndex(0,petConf.area1colour)
    self.sprite:SetDyePartIndex(1,petConf.area2colour)
	
	self.elapse = 0
	self.defaultActCurTimes = 0
	self.defaultActRepeatTimes = 3
	self.actType = eActionStand
end

function PetGalleryDlg:update(dt)
	if not self.sprite then
		return
	end
	self.elapse = self.elapse+dt
	if self.elapse >= self.sprite:GetCurActDuration() then
		self.elapse = 0
		if self.actType == eActionStand then
			self.defaultActCurTimes = self.defaultActCurTimes+1
			if self.defaultActCurTimes == self.defaultActRepeatTimes then
				self.defaultActCurTimes = 0
				local idx = math.random(1, #RANDOM_ACT)
				self.actType = RANDOM_ACT[idx]
				self.sprite:PlayAction(self.actType)
			end
		else
			self.actType = eActionStand
			self.sprite:PlayAction(self.actType)
		end
	end
end

function PetGalleryDlg:refreshAttributes()	

    if self.showPropType == 1 then	
	    local conf = self.petConfs[self.curPetKind]
	    if not conf then return end
	    self.gongzi:setText(conf.attackaptmin .. '~' .. conf.attackaptmax)
	    self.fangzi:setText(conf.defendaptmin .. '~' .. conf.defendaptmax)
	    self.tizi:setText(conf.phyforceaptmin .. '~' .. conf.phyforceaptmax)
	    self.fazi:setText(conf.magicaptmin .. '~' .. conf.magicaptmax)
	    self.suzi:setText(conf.speedaptmin .. '~' .. conf.speedaptmax)
	
	    local growrate = conf.growrate
	    local growratemax = 0
	    local growratemin = 100000
	    for i=0, growrate:size()-1 do
		    if growratemax < growrate[i] then
			    growratemax = growrate[i]
		    end
		    if growratemin > growrate[i] then
			    growratemin = growrate[i]
		    end
	    end
	    growratemax = growratemax/1000
	    growratemin = growratemin/1000
	
	    if growratemin == growratemax then
		    self.grow:setText(math.floor(growratemin*1000)/1000)
	    else
            local str = string.format("%.3f-%.3f",math.floor(growratemin*1000)/1000, math.floor(growratemax*1000)/1000)
		    self.grow:setText(str)
	    end
    else
	    local conf = self.petConfs[fire.pb.pet.PetTypeEnum.SACREDANIMAL]
	    if not conf then return end
        
        local gongziVal = conf.attackaptmax
        local fangziVal = conf.defendaptmax
        local tiziVal = conf.phyforceaptmax
        local faziVal = conf.magicaptmax
        local suziVal = conf.speedaptmax
        local growVal = 0
        local growrate = conf.growrate
        if growrate:size() > 0 then
            growVal = growrate[0]
            growVal = growVal/1000
        end
        if self.curUpKind == 1 then
	        self.gongzi:setText(gongziVal)
	        self.fangzi:setText(fangziVal)
	        self.tizi:setText(tiziVal)
	        self.fazi:setText(faziVal)
	        self.suzi:setText(suziVal)
		    self.grow:setText(string.format("%.3f",math.floor(growVal*1000)/1000))
        else
            local ids = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getAllID()
            for i = 1, #ids do
	            local shenshouinc = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getRecorder(ids[i])

                if shenshouinc and shenshouinc.petid == self.selectedPetID then
                    if shenshouinc.inccount <= self.curUpKind-1 then
                        gongziVal = gongziVal + shenshouinc.atkinc
                        fangziVal = fangziVal + shenshouinc.definc
                        tiziVal = tiziVal + shenshouinc.hpinc
                        faziVal = faziVal + shenshouinc.mpinc
                        suziVal = suziVal + shenshouinc.spdinc
                        growVal = growVal + shenshouinc.attinc / 1000
                        if shenshouinc.inccount == self.curUpKind-1 then
                            self.gongzi:setText(gongziVal)
                            self.fangzi:setText(fangziVal)
                            self.tizi:setText(tiziVal)
                            self.fazi:setText(faziVal)
                            self.suzi:setText(suziVal)
		                    self.grow:setText(string.format("%.3f",math.floor(growVal*1000)/1000))
                        end
                    end
                end
            end
        end
    end
end


function PetGalleryDlg:handleChangeNameOnClicked()
 if not self.xuanze:isVisible() then
    self.xuanze:setVisible(true)
else
 self.xuanze:setVisible(false)
end
end


function PetGalleryDlg:handlePetShapeClicked(args)
    PetLabel.DestroyDialog()
    require("logic.pet.petshizhuangdlg").getInstanceAndShow()
end
function PetGalleryDlg:handlePetClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if self.selectedPetID ~= id then
		self.selectedPetID = id
		self:refreshSelectedPet()
	end
end

function PetGalleryDlg:handleSkillClicked(args)
	local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if wnd:GetSkillID() == 0 then
		return
	end
	local pos = wnd:GetScreenPos()
	PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

function PetGalleryDlg:handleUpGroupBtnClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
	self.curUpKind = id

	self:refreshAttributes()
	--[[    
	local conf = self.petConfs[kind]
    local imgpath = GetPetKindImageRes(kind, conf.unusualid)
	self.kindImg:setProperty("Image", imgpath)
    UseImageSourceSize(self.kindImg, imgpath)
    self.nameText:setProperty("TextColours", GetPetNameColour(conf.id))
	self.nameText:setText(conf.name)
	self:refreshPetSprite(conf)--]]
end

function PetGalleryDlg:handleGroupBtnClicked(args)
	local selectedBtn = self.babyGroupBtn:getSelectedButtonInGroup()
	local kind = selectedBtn:getID()
	self.curPetKind = kind
	self:refreshAttributes()
	local conf = self.petConfs[kind]

	if kind == fire.pb.pet.PetTypeEnum.BABY then
		self.gainWayBtn1:setEnabled( self.gainWayBtn1:getID() ~= 0 )
		self.gainWayBtn2:setEnabled( self.gainWayBtn2:getID() ~= 0 )
        if conf.uselevel >= 35 then
		    self.gainWayBtn3:setEnabled(true)
        else
		    self.gainWayBtn3:setEnabled(false)
        end
		
	elseif kind == fire.pb.pet.PetTypeEnum.VARIATION then
        if self.lingshouBtn:getSelectedButtonInGroup() == self.lingshouBtn then
            self.gainWayBtn1:setEnabled(false)
        else
            local bornmapid = (IsPointCardServer() and conf.pointcardbornmapid or conf.bornmapid)
	        self.gainWayBtn1:setEnabled(bornmapid ~= 0)
        end
		self.gainWayBtn2:setEnabled(false)
        if conf.uselevel >= 35 then
		    self.gainWayBtn3:setEnabled(true)
        else
		    self.gainWayBtn3:setEnabled(false)
        end
	
	elseif kind == fire.pb.pet.PetTypeEnum.WILD then
		self.gainWayBtn1:setEnabled( self.gainWayBtn1:getID() ~= 0 )
		self.gainWayBtn2:setEnabled( self.gainWayBtn2:getID() ~= 0 )
		self.gainWayBtn3:setEnabled( false )
	end

    local imgpath = GetPetKindImageRes(kind, conf.unusualid)
	self.kindImg:setProperty("Image", imgpath)
    UseImageSourceSize(self.kindImg, imgpath)
	self.nameText:setProperty("TextColours", "ff743a0f")
    --self.nameText:setProperty("TextColours", GetPetNameColour(conf.id))
	self.nameText:setText(conf.name)
	self:refreshPetSprite(conf)
end

--function PetGalleryDlg:handleGainWayClicked(args)
--	PetLabel.Show(2)
--end

function PetGalleryDlg:handleGainWayClicked(args)
	local mapId = CEGUI.toWindowEventArgs(args).window:getID()
	local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId)

	if mapRecord == nil then
		return
	end

	if GetTeamManager() and not GetTeamManager():CanIMove() then
		if GetChatManager() then GetChatManager():AddTipsMsg(150030) end --处于组队状态，无法传送
		return true
	end
	
	local randX = mapRecord.bottomx - mapRecord.topx
	randX = mapRecord.topx + math.random(0, randX)
	
	local randY = mapRecord.bottomy - mapRecord.topy
	randY = mapRecord.topy + math.random(0, randY)
	gGetNetConnection():send(fire.pb.mission.CReqGoto(mapId, randX, randY))
	if gGetScene()  then
		gGetScene():EnableJumpMapForAutoBattle(false);
	end
	 PetLabel.hide()
end

function PetGalleryDlg:handleFilterClicked(args)
    self.xuanze:setVisible(false)
	self:refreshPetTable(0, 0)
	
end


--过滤灵兽
function PetGalleryDlg:handleLingShouClicked(args)
   self.xuanze:setVisible(false)
	self:refreshPetTable(10000, 10000)

end
--过滤神兽
function PetGalleryDlg:handleShenShouClicked(args)
    self.xuanze:setVisible(false)
	self:refreshPetTable(20000, 20000)

end


function PetGalleryDlg:handleBuyPetClicked(args)
    if self.gainWayBtn2:getID() == 0 or self.gainWayBtn2:getID2() > gGetDataManager():GetMainCharacterLevel() then
        GetCTipsManager():AddMessageTipById(160250) --等级不足，不能购买
    else
	    local dlg = require("logic.shop.npcpetshop").getInstanceAndShow()
	    dlg:selectGoodsByPetId(self.gainWayBtn2:getID(), false)
    end
end

function PetGalleryDlg:handleBuyPet2Clicked(args)
    require("logic.shop.stalllabel").openStallToBuy(self.selectedPetID)
end

function PetGalleryDlg:handleDiscussClicked(args)
   
end

return PetGalleryDlg
