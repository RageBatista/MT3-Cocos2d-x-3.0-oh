------------------------------------------------------------------
-- ��̯�����ϼ�/�¼�
------------------------------------------------------------------
require "logic.dialog"


StallPetUpShelf = {
	UP_SHELF = 1,
	RE_UP_SHELF = 2,
	DOWN_SHELF = 3
}
setmetatable(StallPetUpShelf, Dialog)
StallPetUpShelf.__index = StallPetUpShelf

local _instance
function StallPetUpShelf.getInstance()
	if not _instance then
		_instance = StallPetUpShelf:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallPetUpShelf.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallPetUpShelf:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallPetUpShelf.getInstanceNotCreate()
	return _instance
end

function StallPetUpShelf.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallPetUpShelf.ToggleOpenClose()
	if not _instance then
		_instance = StallPetUpShelf:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallPetUpShelf.GetLayoutFileName()
	return "baitanpetshangejia.layout"
end

function StallPetUpShelf:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallPetUpShelf)
	return self
end

function StallPetUpShelf:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.back = winMgr:getWindow("baitanpetshangjia/window")
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("baitanpetshangjia/wupin"))
	self.name = winMgr:getWindow("baitanpetshangjia/mingzi")
	self.levelText = winMgr:getWindow("baitanpetshangjia/dengji")
	
	self.groupBtnSkill = CEGUI.toGroupButton(winMgr:getWindow("baitanpetshangjia/jineng"))
	self.groupBtnZizhi = CEGUI.toGroupButton(winMgr:getWindow("baitanpetshangjia/jineng1"))
	self.groupBtnAttr = CEGUI.toGroupButton(winMgr:getWindow("baitanpetshangjia/jineng11"))
	self.groupBtnNeidan = CEGUI.toGroupButton(winMgr:getWindow("baitanpetshangjia/jineng112"))
	
	self.priceCell = winMgr:getWindow("baitanpetshangjia/shangjia/jiage")
	self.inputPriceBg = winMgr:getWindow("baitanpetshangjia/shangjia/shuliang/shurukuang")
	self.priceText = winMgr:getWindow("baitanpetshangjia/shangjia/jiage/huobizhi")
	self.priceText:setProperty("TextColours", "FFFFFFFF")
	
	self.cc_jiagebg = winMgr:getWindow("baitanpetshangjia/shangjia/shuliang/shurukuang1")
	
	self.downPriceText = winMgr:getWindow("baitanpetshangjia/shangjia/jiage/downprice")
	self.downPriceText:setProperty("TextColours", "FFFFFFFF")
	
	self.posPriceCell = winMgr:getWindow("baitanpetshangjia/shangjia/tanweifei")
	self.tipBtn = CEGUI.toPushButton(winMgr:getWindow("baitanpetshangjia/shangjia/tanweifei/anniu"))
	self.posCostText = winMgr:getWindow("baitanpetshangjia/shangjia/tanweifei/huobizhi")
	self.posCostText:setProperty("TextColours", "FFFFFFFF")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("baitanpetshangjia/shangjia/quhui"))
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("baitanpetshangjia/shangjia/guanbi"))
	self.upShelfBtn = CEGUI.toPushButton(winMgr:getWindow("baitanpetshangjia/shangjia/upshelf"))
	self.tipText = winMgr:getWindow("baitanpetshangjia/window/shangjiazhong")
	self.cc_sjtips = CEGUI.toRichEditbox(winMgr:getWindow("baitanpetshangjia/window/shangjiazhong/tips"))
	self.cc_sjtips:Clear()
    self.cc_sjtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7421)))
    self.cc_sjtips:Refresh()

	
	-- 技能
	self.skillView = winMgr:getWindow("baitanpetshangjia/fenye1")
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("baitanpetshangjia/fenye1/skillscroll"))
	
	-- 资质
	self.zizhiView = winMgr:getWindow("baitanpetshangjia/fenye2")
	self.gongziBar = CEGUI.toProgressBar(winMgr:getWindow("baitanpetshangjia/fenye2/1/jindu"))	--攻击资质
	self.fangziBar = CEGUI.toProgressBar(winMgr:getWindow("baitanpetshangjia/fenye2/2/jindu"))	--防御资质
	self.tiziBar = CEGUI.toProgressBar(winMgr:getWindow("baitanpetshangjia/fenye2/3/jindu"))	--体力资质
	self.faziBar = CEGUI.toProgressBar(winMgr:getWindow("baitanpetshangjia/fenye2/4/jindu"))	--法术资质
	self.suziBar = CEGUI.toProgressBar(winMgr:getWindow("baitanpetshangjia/fenye2/5/jindu"))	--速度资质
	self.grow = CEGUI.toProgressBar(winMgr:getWindow("baitanpetshangjia/fenye2/6/wenben2"))		--成长
	self.zizhidanNum = winMgr:getWindow("baitanpetshangjia/fenye2/7/wenben1")					--元宵
	self.growItemUseNum = winMgr:getWindow("baitanpetshangjia/fenye2/7/wenben2")				--炼兽
	
	-- 属性
	self.attrView = winMgr:getWindow("baitanpetshangjia/fenye3")
	self.hp = winMgr:getWindow("baitanpetshangjia/fenye3/zhi1")
	self.tizhi = winMgr:getWindow("baitanpetshangjia/fenye3/zhi2")
	self.mp = winMgr:getWindow("baitanpetshangjia/fenye3/zhi3")
	self.moli = winMgr:getWindow("baitanpetshangjia/fenye3/zhi4")	--����
	self.phyAttack = winMgr:getWindow("baitanpetshangjia/fenye3/zhi5")
	self.power = winMgr:getWindow("baitanpetshangjia/fenye3/zhi6")
	self.phyDefend = winMgr:getWindow("baitanpetshangjia/fenye3/zhi7")
	self.naili = winMgr:getWindow("baitanpetshangjia/fenye3/zhi8")
	self.magicAttack = winMgr:getWindow("baitanpetshangjia/fenye3/zhi9")
	self.minjie = winMgr:getWindow("baitanpetshangjia/fenye3/zhi10")
	self.magicDefend = winMgr:getWindow("baitanpetshangjia/fenye3/zhi11")
	self.qianneng = winMgr:getWindow("baitanpetshangjia/fenye3/zhi12")
	self.speed = winMgr:getWindow("baitanpetshangjia/fenye3/zhi13")
	self.life = winMgr:getWindow("baitanpetshangjia/fenye3/zhi14")

	-- 内丹、装备
	self.ccskillView = winMgr:getWindow("baitanpetshangjia/fenye4")
	self.ccskillScroll = CEGUI.toScrollablePane(winMgr:getWindow("baitanpetshangjia/fenye4/skillscroll"))
	------------------ event ------------------
	self.groupBtnSkill:subscribeEvent("SelectStateChanged", StallPetUpShelf.handleGroupBtnClicked, self)
	self.groupBtnZizhi:subscribeEvent("SelectStateChanged", StallPetUpShelf.handleGroupBtnClicked, self)
	self.groupBtnAttr:subscribeEvent("SelectStateChanged", StallPetUpShelf.handleGroupBtnClicked, self)
	self.groupBtnNeidan:subscribeEvent("SelectStateChanged", StallPetUpShelf.handleGroupBtnClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", StallPetUpShelf.handleCancelClicked, self)
	self.upShelfBtn:subscribeEvent("Clicked", StallPetUpShelf.handleUpShelfClicked, self)
	self.priceText:subscribeEvent("MouseClick", StallPetUpShelf.handlePriceTextClicked, self)
	self.closeBtn:subscribeEvent("Clicked", StallPetUpShelf.DestroyDialog, self)
    self.tipBtn:subscribeEvent("Clicked", StallPetUpShelf.handleTipBtnClicked, self)
	
	------------------ init ------------------
	self.skillBoxes = {}
	for i=1,24 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("baitanpetshangjia/fenye1/skillscroll/skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", StallPetUpShelf.handleSkillClicked, self)
	end
	self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
	self.skillBoxes2 = {}
	for i=1,6 do
		self.skillBoxes2[i] = CEGUI.toSkillBox(winMgr:getWindow("baitanpetshangjia/fenye4/skillscroll/skill" .. i))
		self.skillBoxes2[i]:subscribeEvent("MouseClick", StallPetUpShelf.handleSkillClicked, self)
	end
	self.ccskillScroll:EnableAllChildDrag(self.ccskillScroll)
		
	self.price = 0
	self.priceText:setText(0)
end

--��������г���ʱ
function StallPetUpShelf:setPetData(petData)
	self.tipText:setVisible(false)
	self.type = self.UP_SHELF
	
	self.key = petData.key
	
	self.name:setText(petData.name)
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.itemCell:SetImage(image)

    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if petAttr then
        SetItemCellBoundColorByQulityPet(self.itemCell, petAttr.quality)
    end

    local bTreasure = isPetTreasure(petData)
	if bTreasure then
		self.itemCell:SetCornerImageAtPos("ccui1", "newzp", 0, 0.8)
	end
	
	self:refreshPetData(petData)
end

function StallPetUpShelf:refreshPetData(petData)
	
	self.levelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	
	--����
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	for i = 1, 24 do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification)
		end
	end
	
	local neidannum = (petData and petData:getInternallistlen() or 0)
	for i = 1, 6 do
		self.skillBoxes2[i]:Clear()
		if i <= neidannum then
			local neidan = petData:getInternal(i)
			SetPetSkillBoxInfond(self.skillBoxes2[i], neidan.skillid, petData, true, neidan.certification)
		end
	end

	--����
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if petAttr then
		if petAttr.kind == fire.pb.pet.PetTypeEnum.VARIATION then
            local nBaoBaoId = petAttr.thebabyid 
            local baobaoTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nBaoBaoId)
            if baobaoTable then
                petAttr = baobaoTable
            end
        end

	    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	    self.gongziBar:setText(curVal)
	    self.gongziBar:setProgress((curVal-petAttr.attackaptmin)/(petAttr.attackaptmax-petAttr.attackaptmin))

	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	    self.fangziBar:setText(curVal)
	    self.fangziBar:setProgress((curVal-petAttr.defendaptmin)/(petAttr.defendaptmax-petAttr.defendaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	    self.tiziBar:setText(curVal)
	    self.tiziBar:setProgress((curVal-petAttr.phyforceaptmin)/(petAttr.phyforceaptmax-petAttr.phyforceaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	    self.faziBar:setText(curVal)
	    self.faziBar:setProgress((curVal-petAttr.magicaptmin)/(petAttr.magicaptmax-petAttr.magicaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	    self.suziBar:setText(curVal)
	    self.suziBar:setProgress((curVal-petAttr.speedaptmin)/(petAttr.speedaptmax-petAttr.speedaptmin))
	
	    curVal = math.floor(petData.growrate*1000) / 1000
	    self.grow:setText(curVal)
		if petAttr.growrate:size() > 1 then
			local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
			if maxgrow > 0 then
				self.grow:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
            else
				self.grow:setProgress(1)
			end
		end
    end
	
	self.zizhidanNum:setText(petData.aptaddcount)
	self.growItemUseNum:setText(petData.growrateaddcount)
	
	--����
	self.hp:setText(petData:getAttribute(fire.pb.attr.AttrType.HP))
	self.mp:setText(petData:getAttribute(fire.pb.attr.AttrType.MP))
	self.phyAttack:setText(petData:getAttribute(fire.pb.attr.AttrType.ATTACK))
	self.phyDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.DEFEND))
	self.magicAttack:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK))
	self.magicDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF))
	self.speed:setText(petData:getAttribute(fire.pb.attr.AttrType.SPEED))
	self.tizhi:setText(petData:getAttribute(fire.pb.attr.AttrType.CONS))
	self.moli:setText(petData:getAttribute(fire.pb.attr.AttrType.IQ))
	self.power:setText(petData:getAttribute(fire.pb.attr.AttrType.STR))
	self.naili:setText(petData:getAttribute(fire.pb.attr.AttrType.ENDU))
	self.minjie:setText(petData:getAttribute(fire.pb.attr.AttrType.AGI))
	self.qianneng:setText(petData:getAttribute(fire.pb.attr.AttrType.POINT))

    if petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE) < 0 then
        self.life:setFont("simhei-10")
        self.life:setText(MHSD_UTILS.get_resstring(11548)) --永生
    else
	    self.life:setText(petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE))
    end
end

--���̯λ�ϳ���ʱ
function StallPetUpShelf:setGoodsData(goods, outdate)
	self.key = goods.key
    self.price = goods.price
	self.recommendPrice = goods.price
	self.goods = goods

	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemid)
    if petAttr then
	    self.name:setText(petAttr.name)
	
	    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
	    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	    self.itemCell:SetImage(image)
        SetItemCellBoundColorByQulityPet(self.itemCell, petAttr.quality)

        self.itemCell:SetCornerImageAtPos("ccui1", "newzp", 0, 0.8)
    end
		
	local p = require("protodef.fire.pb.shop.cmarketpettips"):new()
	p.roleid = goods.saleroleid
	p.key = goods.key
	p.tipstype = PETTIPS_T.STALL_DOWN_SHELF
	LuaProtocolManager:send(p)
	
	--[[print('------------- cmarketpettips --------------')
	for k,v in pairs(p) do
		print(k,v)
	end--]]
	
	if outdate then
		self.type = self.RE_UP_SHELF
		self.tipText:setText(MHSD_UTILS.get_resstring(11198)) --�ѹ���
        self.cancelBtn:setText(MHSD_UTILS.get_resstring(11197)) --ȡ��
		self.upShelfBtn:setText(MHSD_UTILS.get_resstring(11196)) --�����ϼ�
        self:refreshPriceShow()
	else
		self.type = self.DOWN_SHELF
		self.upShelfBtn:setText(MHSD_UTILS.get_resstring(11199)) --�¼�
		self.posPriceCell:setVisible(false)
		self.inputPriceBg:setVisible(false)
		self.cc_jiagebg:setVisible(true)
		self.priceText = self.downPriceText
	end
	
	self.priceText:setText(MoneyFormat(goods.price))
end

function StallPetUpShelf:refreshPriceShow()
	self.priceText:setText(MoneyFormat(self.price))
	local posCost = math.floor(math.min(100000, math.max(1000, self.price)))
	self.posCostText:setText(MoneyFormat(posCost))
end

function StallPetUpShelf:onPriceInputChanged(num)
	self.price = num
	self:refreshPriceShow()
end

function StallPetUpShelf:doUpShelf(optType)
	local p = nil
    if self.type == self.UP_SHELF then
        p = require("protodef.fire.pb.shop.cmarketup"):new()
		p.containertype = STALL_GOODS_T.PET
		p.key = self.key
		p.num = 1
		p.price = self.price
    elseif self.type == self.RE_UP_SHELF then
        p = require("protodef.fire.pb.shop.cremarketup"):new()
        p.itemtype = STALL_GOODS_T.PET
        p.id = self.goods.id
		p.money = self.price
    end

		
	--��̯���Ƿ�
	local upshelfCost = MoneyNumber(self.posCostText:getText())
	local needMoney = CurrencyManager.canAfford(fire.pb.game.MoneyType.MoneyType_SilverCoin, upshelfCost)
	if needMoney > 0 then
		StallPetUpShelf.DestroyDialog()
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needMoney, upshelfCost, p)
		return
	end
		
	LuaProtocolManager:send(p)
	StallPetUpShelf.DestroyDialog()
end

function StallPetUpShelf:handleConfirUpShelf()
	self:doUpShelf(self.RE_UP_SHELF)
end

function StallPetUpShelf:handlePriceTextClicked(args)
	if self.type == self.DOWN_SHELF then
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.priceText)
		dlg:setMaxValue(999999999)
		dlg:setInputChangeCallFunc(StallPetUpShelf.onPriceInputChanged, self)
		
		local p = self.priceText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x+self.priceText:getPixelSize().width*0.5, p.y-10, 0.5, 1)
	end
end

function StallPetUpShelf:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local s = GetScreenSize()
	local x = (s.width - self.back:getPixelSize().width)*0.5 - 5
	--SetPositionOffset(tip:GetWindow(), x, s.height*0.5, 1, 0.5)
	SetPositionOffset(tip:GetWindow(), s.width*0.5+50, s.height*0.5, 0, 0.5)
end

function StallPetUpShelf:handleGroupBtnClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	self.skillView:setVisible(btn == self.groupBtnSkill)
	self.zizhiView:setVisible(btn == self.groupBtnZizhi)
	self.attrView:setVisible(btn == self.groupBtnAttr)
	self.ccskillView:setVisible(btn == self.groupBtnNeidan)
end

function StallPetUpShelf:handleCancelClicked(args)
    if self.type == self.RE_UP_SHELF then
		if MainPetDataManager.getInstance():IsMyPetFull() then
			GetCTipsManager():AddMessageTipById(100041) --��ĳ��������ˡ�
		else
			--ȡ��
			local p = require("protodef.fire.pb.shop.cmarketdown"):new()
			p.downtype = STALL_GOODS_T.PET
			p.key = self.key
			LuaProtocolManager:send(p)
		end
    end
	StallPetUpShelf.DestroyDialog()
end

function StallPetUpShelf:handleTipBtnClicked(args)
	local tip = TextTip.CreateNewDlg()
	local str = MHSD_UTILS.get_msgtipstring(150507)
	tip:setTipText(str)
end

function StallPetUpShelf:handleUpShelfClicked(args)
	local dlg = StallDlg.getInstance()
	if dlg.myStallGoods and #dlg.myStallGoods == 8 and self.type == self.UP_SHELF then
		GetCTipsManager():AddMessageTipById(160048) --ͬʱ�ϼܵ���Ʒ���ܳ���8��Ŷ
		return
	end
	
	if self.type == self.UP_SHELF then
		if self.price == 0 then
			GetCTipsManager():AddMessageTipById(150510) --�����ۼۿ�����۸�
			return
		end
		self:doUpShelf(self.UP_SHELF)
		
    elseif self.type == self.RE_UP_SHELF then
        if self.price == 0 then
			GetCTipsManager():AddMessageTipById(150510) --�����ۼۿ�����۸�
			return
		end
        
        if not IsPointCardServer() then
		    if self.price == self.recommendPrice then
			    MessageBoxSimple.show(
				    MHSD_UTILS.get_msgtipstring(160377),  --��Ʒ�۸�δ���޸ģ�������ǰ�۸񲻽��빫ʾ�ڣ�ֱ���ϼܳ��ۡ�
				    StallPetUpShelf.handleConfirUpShelf, self, nil, nil
			    )
		    else
			    MessageBoxSimple.show(
				    MHSD_UTILS.get_msgtipstring(160381),  --�޸ļ۸����Ҫ���½���8Сʱ��ʾ���޸���
				    StallPetUpShelf.handleConfirUpShelf, self, nil, nil
			    )
		    end
        else
            self:doUpShelf(self.RE_UP_SHELF)
        end

	else
        --������������
		if MainPetDataManager.getInstance():IsMyPetFull() then
			GetCTipsManager():AddMessageTipById(100041) --��ĳ��������ˡ�
			return
		end

		--�¼�
		local p = require("protodef.fire.pb.shop.cmarketdown"):new()
		p.downtype = STALL_GOODS_T.PET
		p.key = self.key
		LuaProtocolManager:send(p)
		StallPetUpShelf.DestroyDialog()
	end
end

return StallPetUpShelf
