require "logic.dialog"

ZhuanZhiDlg = {}
setmetatable(ZhuanZhiDlg, Dialog)
ZhuanZhiDlg.__index = ZhuanZhiDlg

local _instance
function ZhuanZhiDlg.getInstance()
	if not _instance then
		_instance = ZhuanZhiDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiDlg.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiDlg.GetLayoutFileName()
	return "zhuanzhi.layout"
end

function ZhuanZhiDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiDlg)
	return self
end

function ZhuanZhiDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
	local iconpath = gGetIconManager():GetImagePathByID(Shape.littleheadID)
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())


	local ids = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getAllID()
	for index, var in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(var)

		if Shape.id == conf.model then
			ZhuanZhiSex = conf.sex
			break
		end

	end

	self.m_CostMoney = GameTable.common.GetCCommonTableInstance():getRecorder(446).value

	self.m_CurHeadIcon =  CEGUI.toPushButton(winMgr:getWindow("Zhuanzhi/Icon1/headicon1"))
	self.m_CurHeadIcon:setProperty("Image",iconpath:c_str())
	self.m_CurHeadIconText = winMgr:getWindow("Zhuanzhi/dikuang/jueseming1")
	self.m_CurHeadIconText:setText(Shape.name)

	self.m_CurClass =  CEGUI.toPushButton(winMgr:getWindow("Zhuanzhi/dikuang/zhiyetubiao1"))
	self.m_CurClass:setProperty("Image", school.schooliconpath)
	self.m_CurClassText = winMgr:getWindow("Zhuanzhi/dikuang/zhiye1")
	self.m_CurClassText:setText(school.name)

	self.m_NextHeadIcon = CEGUI.toPushButton(winMgr:getWindow("Zhuanzhi/Icon1/headicon11"))

	self.m_NextHeadIconText = winMgr:getWindow("Zhuanzhi/dikuang/jueseming2")
	self.m_NextHeadIconText:setText("")

	self.m_NextClass = CEGUI.toPushButton(winMgr:getWindow("Zhuanzhi/dikuang/zhiyetubiao2"))

	self.m_NextClassText = winMgr:getWindow("Zhuanzhi/dikuang/zhiye2")
	self.m_NextClassText:setText("")

	self.m_ChooseSchool = CEGUI.toPushButton(winMgr:getWindow("Zhuanzhi/dikuang/dangqiandi1/btn1"))
	self.m_ChooseSchool:subscribeEvent("MouseButtonUp", ZhuanZhiDlg.SelectZhongZu, self)

	self.m_ChooseClass = CEGUI.toPushButton(winMgr:getWindow("Zhuanzhi/dikuang/dangqiandi1/btn2"))
	self.m_ChooseClass:subscribeEvent("MouseButtonUp", ZhuanZhiDlg.SelectClass, self)
	
	--��Ǯ
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local tmpmoney = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	local numStr1 = "0"
	local numStr2 = formatMoneyString(""..tmpmoney)

	self.m_NeedMoney = winMgr:getWindow("Zhuanzhi/jinbi1/text1")
	self.m_NeedMoney:setText(numStr1)
	self.m_HaveMoney = winMgr:getWindow("Zhuanzhi/jinbi2/text2")
	self.m_HaveMoney:setText(numStr2)

	--˵����ť
	self.m_TipsButton = CEGUI.Window.toPushButton(winMgr:getWindow("Zhuanzhi/tips"))
	self.m_TipsButton:subscribeEvent("Clicked", ZhuanZhiDlg.HandleTipsBtn, self)

	--תְ��ť
	self.m_chargeButton = CEGUI.Window.toPushButton(winMgr:getWindow("Zhuanzhi/zhuanbtn"))
	self.m_chargeButton:subscribeEvent("Clicked", ZhuanZhiDlg.HandleChargeBtn, self)

	--��ǰģ��
	self.m_CurSpriteBack = CEGUI.toWindow(winMgr:getWindow("Zhuanzhi/spriteEffect1/xingxiang1/top"))
	self.m_CurSpriteBack:setAlwaysOnTop(true)
    local s = self.m_CurSpriteBack:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack, Shape.id, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
	local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
	local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
	local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
	self.m_CurSprite:SetSpriteComponent(eSprite_Weapon, weapon)
	self.m_CurSprite:SetDyePartIndex(0, pA)
    self.m_CurSprite:SetDyePartIndex(1, pB)

	self.m_NextSpriteBack = CEGUI.toWindow(winMgr:getWindow("Zhuanzhi/spriteEffect2/xingxiang2/top"))
	self.m_NextSpriteBack:setAlwaysOnTop(true)

	self.m_SelNextSchool = -1
	self.m_SelNextClass = -1

	self.m_CurServerLv = gGetDataManager():getServerLevel()

	--�����ְҵ�б�
	local cmd = require "protodef.fire.pb.school.change.coldschoollist".Create()
	LuaProtocolManager.getInstance():send(cmd)
end

function ZhuanZhiDlg:SetOldSchoolList(schoollist, classlist)
	self.m_OldSchoolList = schoollist
	self.m_OldClassList = classlist
end

function ZhuanZhiDlg:SelectZhongZu()
	local dlg = require "logic.zhuanzhi.zhuanzhiselectjuese".getInstance()

	if dlg then
		dlg.getInstanceAndShow()
	end

end

function ZhuanZhiDlg:SelectClass()

	if self.m_SelNextSchool == -1 then
		GetCTipsManager():AddMessageTipById(142925)
		return
	end

	local dlg = require "logic.zhuanzhi.zhuanzhizhiye".getInstance()

	if dlg then
		dlg.getInstanceAndShow()

		dlg:GenerateClassInfo(self.m_SelNextSchool)
	end
end

function ZhuanZhiDlg:HandleChargeBtn()
	if self.m_SelNextSchool == -1 then
		GetCTipsManager():AddMessageTipById(142925)
		return
	end

	if self.m_SelNextClass == -1 then
		GetCTipsManager():AddMessageTipById(410065)
		return
	end

	if SchoolID[1][self.m_SelNextSchool] == gGetDataManager():GetMainCharacterShape() 
	and ZhiYeStrID[1][self.m_SelNextSchool][self.m_SelNextClass] == gGetDataManager():GetMainCharacterSchoolID() then
		GetCTipsManager():AddMessageTipById(174015)
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipInBodykeys = { }
	equipInBodykeys = roleItemManager:GetItemKeyListByType(equipInBodykeys, eItemType_EQUIP, fire.pb.item.BagTypes.EQUIP)

	if #equipInBodykeys > 0 then
		GetCTipsManager():AddMessageTipById(410064)
		return
	end

	local serverlv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(447).value)
	if self.m_CurServerLv < serverlv then
		GetCTipsManager():AddMessageTipById(174011)
		return
	end



  --VIPתְ����

    local hyviplevel = gGetDataManager():GetVipLevel()
    if 1 > hyviplevel then
		GetCTipsManager():AddMessageTipById(191066)
        return
    end



	local data = gGetDataManager():GetMainCharacterData()
	local lv = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	local needlv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(448).value)
	if lv < needlv then
		GetCTipsManager():AddMessageTipById(174012)
		return
	end


	local dlg = require "logic.zhuanzhi.zhuanzhiconfrimdlg".getInstance()

	if dlg then
		dlg.getInstanceAndShow()
		dlg:RefreshData(self.m_SelNextSchool, self.m_SelNextClass, self:CalculateNeedMoney())
	end

end

function ZhuanZhiDlg:HandleTipsBtn()
	
	local dlg = require "logic.zhuanzhi.zhuanzhitips".getInstance()

	if dlg then
		dlg.getInstanceAndShow()
		dlg:RefreshData(self.m_OldSchoolList, self.m_OldClassList)
	end

end

function ZhuanZhiDlg:RefreshSelectSchool(id)
	self.m_SelNextSchool = id

	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(SchoolID[1][id])
	local iconpath = gGetIconManager():GetImagePathByID(Shape.littleheadID)

	self.m_NextHeadIcon:setProperty("Image", iconpath:c_str())

	self.m_NextHeadIconText:setText(Shape.name)

	local s = self.m_NextSpriteBack:getPixelSize()

	if not self.m_NextSprite then
		self.m_NextSprite = gGetGameUIManager():AddWindowSprite(self.m_NextSpriteBack, Shape.id + 1000, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
	else
		self.m_NextSprite:SetModel(Shape.id + 1000)
	end

	if self.m_NextSprite then
		local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
		local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
		self.m_NextSprite:SetDyePartIndex(0, pA)
		self.m_NextSprite:SetDyePartIndex(1, pB)
	end

	self.m_SelNextClass = -1
	self.m_NextClassText:setText("")
	self.m_NeedMoney:setText("0")

end

function ZhuanZhiDlg:RefreshSelectClass(id)
	self.m_SelNextClass = id

	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(ZhiYeStrID[1][self.m_SelNextSchool][id])

	self.m_NextClass:setProperty("Image", school.schooliconpath)

	self.m_NextClassText:setText(school.name)

	self.m_NeedMoney:setText(self:CalculateNeedMoney())
end

function ZhuanZhiDlg:CalculateNeedMoney()
	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	local TotalNeedMoney = 0

	if SchoolID[1][self.m_SelNextSchool] ~= Shape.id then
		local ishad = false
		 
		for i = 1, #self.m_OldSchoolList do
			local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.m_OldSchoolList[i])
			
			if conf and SchoolID[1][self.m_SelNextSchool] == conf.model then
				TotalNeedMoney = TotalNeedMoney + self.m_CostMoney/2
				ishad = true
				break
			end
		end

		if not  ishad then
			TotalNeedMoney = TotalNeedMoney + self.m_CostMoney
		end
		
	end

	if ZhiYeStrID[1][self.m_SelNextSchool][self.m_SelNextClass] ~= school.id  then
		local ishad = false
		for i = 1, #self.m_OldClassList do
			if ZhiYeStrID[1][self.m_SelNextSchool][self.m_SelNextClass] == self.m_OldClassList[i] then
				TotalNeedMoney = TotalNeedMoney + self.m_CostMoney/2
				ishad = true
				break
			end
		end

		if not  ishad then
			TotalNeedMoney = TotalNeedMoney + self.m_CostMoney
		end
	end

	return tostring(TotalNeedMoney)

end


return ZhuanZhiDlg