------------------------------------------------------------------
-- 宠物合成选择
------------------------------------------------------------------
require "logic.dialog"

PetChooseDlg = {}
setmetatable(PetChooseDlg, Dialog)
PetChooseDlg.__index = PetChooseDlg

local _instance
function PetChooseDlg.getInstance()
	if not _instance then
		_instance = PetChooseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetChooseDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetChooseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetChooseDlg.getInstanceNotCreate()
	return _instance
end

function PetChooseDlg.DestroyDialog()
	if _instance then
	_instance.chooseBtn.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetChooseDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetChooseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetChooseDlg.GetLayoutFileName()
	return "pethechongyulan_mtg.layout"
end

function PetChooseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetChooseDlg)
	return self
end

function PetChooseDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        -- 保存动画实例
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetChooseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("pethechongyulan_mtg/bg"))
	self.waigongzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/bar0"))
	self.fangyuzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/bar1"))
	self.tilizizhiBar = CEGUI.toProgressBar(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/bar2"))
	self.neigongzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/bar3"))
	self.suduzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/bar4"))
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/RightBack"))
	self.growBar = CEGUI.toProgressBar(winMgr:getWindow("pethechongyulan_mtg/bg/text2bg/barchengzhang"))
	self.chooseBtn = CEGUI.toPushButton(winMgr:getWindow("pethechongyulan_mtg/bg/btnxuanze"))
	self:addButtonAnimation(self.chooseBtn, "studyBtnPress")
	
 
	self.m_petList = {}
	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("pethechongyulan_mtg/bg/labepane"))
	self.petScroll:EnableHorzScrollBar(false)
	self.chooseBtn:subscribeEvent("Clicked", PetChooseDlg.handleChooseClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", PetChooseDlg.DestroyDialog, nil)

	self.petScroll:EnableAllChildDrag(self.petScroll)
	
	self.skillBoxes = {}
	for i=1,25 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("pethechongyulan_mtg/Skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", PetChooseDlg.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
	end
	self.skillBoxes[25]:setVisible(false)
	self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
end

--1.left 2.right
function PetChooseDlg:setIndex(idx ,otherkey,choosekey)
	self.idx = idx
	self.otherkey = otherkey
	self.choosekey  = choosekey
	
	local winSize = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	SetPositionXOffset(self.frameWindow, winSize.width, 1)
 
	self:refreshPetTableOnProfileView()
	self:refreshSelectedPet(self.selectedPetData)
end

 

function PetChooseDlg:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local pos = cell:GetScreenPosOfCenter()
	SetPositionOffset(tip:GetWindow(), pos.x, pos.y, 1, 1)
end


function PetChooseDlg:handlePetIconSelected(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local idx = wnd:getID()
	if idx < MainPetDataManager.getInstance():GetPetNum() then
		local petData = MainPetDataManager.getInstance():getPet(idx+1)
		if self.selectedPetData ~= petData then
			self:refreshSelectedPet(petData)
		end
	end
end

function PetChooseDlg:refreshSelectedPet(petData)
	self.selectedPetData = petData
	
	if petData then
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petAttr then
            if petAttr.kind == fire.pb.pet.PetTypeEnum.VARIATION then
                local nBaoBaoId = petAttr.thebabyid 
                local baobaoTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nBaoBaoId)
                if baobaoTable then
                    petAttr = baobaoTable
                end
            end
			
			

		    --(cur-min)/(max-min)
		    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
		    self.waigongzizhiBar:setText(curVal)
		    self.waigongzizhiBar:setProgress((curVal-petAttr.attackaptmin)/(petAttr.attackaptmax-petAttr.attackaptmin))

		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
		    self.fangyuzizhiBar:setText(curVal)
		    self.fangyuzizhiBar:setProgress((curVal-petAttr.defendaptmin)/(petAttr.defendaptmax-petAttr.defendaptmin))
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
		    self.tilizizhiBar:setText(curVal)
		    self.tilizizhiBar:setProgress((curVal-petAttr.phyforceaptmin)/(petAttr.phyforceaptmax-petAttr.phyforceaptmin))
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
		    self.neigongzizhiBar:setText(curVal)
		    self.neigongzizhiBar:setProgress((curVal-petAttr.magicaptmin)/(petAttr.magicaptmax-petAttr.magicaptmin))
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
		    self.suduzizhiBar:setText(curVal)
		    self.suduzizhiBar:setProgress((curVal-petAttr.speedaptmin)/(petAttr.speedaptmax-petAttr.speedaptmin))
		
		    curVal = math.floor(petData.growrate*1000) / 1000
		    self.growBar:setText(curVal)
		    if petAttr.growrate:size() > 1 then
			    local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
			    if maxgrow > 0 then
				    self.growBar:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
                else
				    self.growBar:setProgress(1)
			    end
		    end
        end
	else
		self.waigongzizhiBar:setText("")
		self.waigongzizhiBar:setProgress(0)
		self.fangyuzizhiBar:setText("")
		self.fangyuzizhiBar:setProgress(0)
		self.tilizizhiBar:setText("")
		self.tilizizhiBar:setProgress(0)
		self.neigongzizhiBar:setText("")
		self.neigongzizhiBar:setProgress(0)
		self.suduzizhiBar:setText("")
		self.suduzizhiBar:setProgress(0)
		self.growBar:setText("")
		self.growBar:setProgress(0)
	end
	
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	self.skillBoxes[25]:setVisible(skillnum==25)
	for i = 1, 25 do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification)
		end
	end
end

function PetChooseDlg:handleChooseClicked(args)
	if not self.selectedPetData then
		PetChooseDlg.DestroyDialog()
		return
	end  
	
    if GetBattleManager():IsInBattle() then    
	    if self.selectedPetData.key == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(150051) --战斗中不能进行此操作
		    return
	    end
    end

	if self.selectedPetData.flag == 2 then
		GetCTipsManager():AddMessageTipById(150052) --绑定宠物不能进行合成
		return
	end
	if self.selectedPetData.flag == 1 then
		GetCTipsManager():AddMessageTipById(150053) --锁定宠物不能进行合成
		return
	end
	if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() < 55 then
		local msg = MHSD_UTILS.get_msgtipstring(150054)
		msg = string.gsub(msg, "%$parameter1%$", 55)
		GetCTipsManager():AddMessageTip(msg) --人物等级不足55级，抓紧时间升级吧
		return
	end
    if self.selectedPetData.kind == fire.pb.pet.PetTypeEnum.WILD then --野生
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.selectedPetData.baseid)
        if petAttr and petAttr.unusualid == 0 then --非灵兽
            GetCTipsManager():AddMessageTipById(150085) --野生宠物不能进行合成
            return
        end
    end
	

	if self.selectedPetData.kind == fire.pb.pet.PetTypeEnum.BABY then 
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.selectedPetData.baseid)
        if petAttr and petAttr.unusualid == 1 then 
            GetCTipsManager():AddMessageTipById(193500) 
            return
        end
    end
	
	--if self.selectedPetData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then --神兽
		--GetCTipsManager():AddMessageTipById(150086) 
		--return
	--end

	if self.selectedPetData.key == gGetDataManager():GetBattlePetID() then
		GetCTipsManager():AddMessageTipById(150056) 
		return
	end
	if self.selectedPetData:getIdentifiedSkill() then
		GetCTipsManager():AddMessageTipById(150068) 
		return
	end
   if self.selectedPetData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then 
    if self.selectedPetData.baseid >= 900501 and self.selectedPetData.baseid <= 901100 then
        
    else
        GetCTipsManager():AddMessageTipById(150086) 
        return
    end
end
	
	
	local dlg = require("logic.pet.petlianyaodlg").getInstanceNotCreate()
	if dlg then
		dlg:addCombinePet(self.idx, self.selectedPetData)
	end
	PetChooseDlg.DestroyDialog()
end



function PetChooseDlg:refreshPetTableOnProfileView()   
    self:releasePetIcon()
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 0.0;
    local sy = 2.0;
    self.m_petList = {}
    local index = 0
    local fightid = gGetDataManager():GetBattlePetID()
    for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
		if self.otherkey == nil  or  self.otherkey  ~= petData.key then 
		 
			local sID = "PetChooseDlg" .. tostring(index)
			local lyout = winMgr:loadWindowLayout("pethechengcell.layout",sID);
			self.petScroll:addChildWindow(lyout)
			--self.petlistWnd:addChildWindow(lyout)
	   
           local xindex = (index)%5
           local yindex = math.floor((index)/5)

            lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))
			lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."pethechengcell"));
			lyout.addclick:setID(i-1)
			lyout.addclick:subscribeEvent("MouseButtonUp", PetChooseDlg.handlePetIconSelected, self)
   
			if self.choosekey ~= nil and self.choosekey  == petData.key then
			    self.selectedPetData = petData;
				lyout.addclick:setSelected(true)
			end
			 
			lyout.NameText = winMgr:getWindow(sID.."pethechengcell/text/name")
			lyout.NameText:setText(petData.name)
			lyout.LevelText = winMgr:getWindow(sID.."pethechengcell/text/dengji")
			lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))        
			lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."pethechengcell/itemcell"))
			SetPetItemCellInfo2(lyout.petCell, petData)
			
			lyout.chuzhan = winMgr:getWindow(sID.."pethechengcell/zhan")
			lyout.chuzhan:setVisible(false) 
			if fightid == petData.key then
				lyout.chuzhan:setVisible(true) 
			end
			table.insert(self.m_petList, lyout)
			index = index + 1
		end 
    end 
end
function PetChooseDlg:releasePetIcon()   
    local sz = #self.m_petList
    for index  = 1, sz do
        local lyout = self.m_petList[1]
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil 
        lyout.petCell = nil
        lyout.chuzhan = nil

        self.petScroll:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_petList,1)
	end
	self.m_petList = nil;
end 	
 

return PetChooseDlg
