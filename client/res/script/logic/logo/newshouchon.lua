------------------------------------------------------------------
-- 新首冲  黑泡泡
------------------------------------------------------------------

require "logic.dialog"
require "logic.pet.firstchargegiftpetdlg"



NewShouchon = {}
setmetatable(NewShouchon, Dialog)
NewShouchon.__index = NewShouchon

local _instance
function NewShouchon.getInstance()
	if not _instance then
		_instance = NewShouchon:new()
		_instance:OnCreate()
	end
	return _instance
end

function NewShouchon.getInstanceAndShow()
	if not _instance then
		_instance = NewShouchon:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NewShouchon.getInstanceOrNot()
	return _instance
end

function NewShouchon.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NewShouchon:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function NewShouchon.ToggleOpenClose()
	if not _instance then
		_instance = NewShouchon:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NewShouchon.GetLayoutFileName()

	return "NewShouchon.layout"
end

function NewShouchon:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NewShouchon)
	return self
end

function NewShouchon:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	--宠物模型控件
	self.petmodel = winMgr:getWindow("NewShouchon/PetModel")
	self.petmodel:subscribeEvent("MouseButtonUp",NewShouchon.HandlePetModel,self)
	self.petname =  winMgr:getWindow("NewShouchon/petname")

	
	self.petskill = {}
	for i = 1, 3 do
		self.petskill[i] = CEGUI.toSkillBox(winMgr:getWindow("NewShouchon/petskill"..i))
		self.petskill[i]:subscribeEvent("MouseClick", NewShouchon.handleSkillClicked, self)
		self.petskill[i]:SetBackGroupOnTop(true)
	end
	
	--关闭按钮
	self.close = winMgr:getWindow("NewShouchon/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)


	self.m_listCell = {}
    local cShapeId = gGetDataManager():GetMainCharacterCreateShape()
	if IsPointCardServer() then	
        for i = 1, 6 do
            local index = i
            if i > 1 then
                index = i + 1
            end
		    local cell = CEGUI.toItemCell(winMgr:getWindow("NewShouchon/itemBox/item" .. i ))
		    cell:setID( i )
		    cell:subscribeEvent("MouseClick",NewShouchon.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

            local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(i)
            if cfg.borderpic:size() > 0 then
                -- local corner = winMgr:getWindow("NewShouchon/ditu/wupin"..index.."/biaoqian" .. index )
                -- corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
                -- corner:setVisible(false)--隐藏角标
            end

	    end
        -- local hengfu1 = winMgr:getWindow("NewShouchon/hengfu")
        -- hengfu1:setVisible(false)
        -- local hengfu2 = winMgr:getWindow("NewShouchon/hengfu1")
        -- hengfu2:setVisible(true)
    else
	    for i = 1, 6 do
		    local cell = CEGUI.toItemCell(winMgr:getWindow("NewShouchon/itemBox/item" .. i ))
		    cell:setID( i )
		    cell:subscribeEvent("MouseClick",NewShouchon.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

            local cfg = BeanConfigManager.getInstance():GetTableByName("game.cshouchonglibao"):getRecorder(i)
            if cfg.borderpic:size() > 0 then
                -- local corner = winMgr:getWindow("NewShouchon/ditu/wupin"..i.."/biaoqian" .. i )
                -- corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
                -- corner:setVisible(false)--隐藏角标
           end

	    end
    end
	

	
	self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("NewShouchon/btn1"))
	self.m_btnCharge:subscribeEvent("Clicked",NewShouchon.HandleBtnChargeClicked,self)
	
	self:RefreshItem()
	self:RefreshBtn()
	
	--特效
	self.sctx = winMgr:getWindow("NewShouchon/hppSp")
	local sctxANi = gGetGameUIManager():AddUIEffect(self.sctx, "spine/my_spine/my_hpp", true) --�ϳ���Ч ����
	sctxANi:SetDefaultActName("stand1")
	sctxANi:SetScale(0.9)
	
	

end


function NewShouchon:HandlePetModel(args)

    local cShapeID = gGetDataManager():GetMainCharacterCreateShape()

	local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(1)

    FirstChargeGiftPetDlg.getInstanceAndShow(cfg.petid[cShapeID-1])
	

end


function NewShouchon:handleSkillClicked(args)
    local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
    if wnd:GetSkillID() == 0 then
        return
    end
    local pos = wnd:GetScreenPos()
	
    PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

 function NewShouchon:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
	
    local cShapeID = gGetDataManager():GetMainCharacterCreateShape()

	local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(index)

    if index == 1 then
        FirstChargeGiftPetDlg.getInstanceAndShow(cfg.petid[cShapeID-1])
    else
    	local Commontipdlg = require "logic.tips.commontipdlg"
	    local commontipdlg = Commontipdlg.getInstanceAndShow()
	    local nType = Commontipdlg.eType.eNormal
	    local nItemId = cfg.itemid[cShapeID-1]
	    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end

 function NewShouchon:RefreshItem()
    local cShapeID = gGetDataManager():GetMainCharacterCreateShape()
    
	for i, v in pairs( self.m_listCell ) do
		local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(i)


        if i == 1 then
            local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(cfg.petid[cShapeID - 1])
            if petAttrCfg then
                local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttrCfg.modelid)
	            local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                v:SetImage(image)
            
                SetItemCellBoundColorByQulityPet(v,petAttrCfg.quality)
                if cfg.petnum[cShapeID - 1] ~= 1 and cfg.petnum[cShapeID - 1] ~= 0 then
                    v:SetTextUnitText(CEGUI.String(""..cfg.petnum[cShapeID - 1]))
                end
				
				--设置宠物模型
				local s1 = self.petmodel:getPixelSize()
				gGetGameUIManager():AddWindowSprite(self.petmodel,  petAttrCfg.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
				self.petname:setText(petAttrCfg.name)
				
				
				for A1 = 1, 3 do
					SetPetSkillBoxInfo(self.petskill[A1], petAttrCfg.skillid[A1-1])
				end
				
            end
        else
            local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cfg.itemid[cShapeID - 1])
            if itembean then
		        v:SetImage(gGetIconManager():GetItemIconByID( itembean.icon))
                SetItemCellBoundColorByQulityItemWithId(v,itembean.id)
                if cfg.itemnum[cShapeID - 1] ~= 1 and cfg.itemnum[cShapeID - 1] ~= 0 then
		            v:SetTextUnitText(CEGUI.String(""..cfg.itemnum[cShapeID - 1]))
                end
                ShowItemTreasureIfNeed(v,itembean.id)
            end
        end
	end
	
end

function NewShouchon:RefreshBtn()  --刷新按钮
	local mgr = LoginRewardManager.getInstance()

	if mgr.m_firstchargeState == 1 then  --冲了但是没有领取礼包
		self.m_btnCharge:setText(MHSD_UTILS.get_resstring(2780))
	elseif mgr.m_firstchargeState == 2 then --冲了已经领取礼包
		self.m_btnCharge:setText("已领取")
		self.m_btnCharge:setEnabled(false)
	end
		
end

function NewShouchon:HandleBtnChargeClicked(e)
	local mgr = LoginRewardManager.getInstance()
    if mgr.m_firstchargeState==0 then--没冲的情况
		--ShopLabel.showRecharge()  --
		
		require("logic.shop.shoplabel").getInstance():showOnly(3)
	--	require"logic.logo.chonzhi_mtg".getInstanceAndShow(1)  --充值打开事件 --选择第一档 30那个位置
		
		--require "logic.shop.Newchongzhi"--打开充值商店
		--Newchongzhi.getInstanceAndShow()--打开充值商店

	end

	if mgr.m_firstchargeState==1 then  ----冲了但是没有领取礼包  ，领取礼包协议
		require "protodef.fire.pb.fushi.cgetfirstpayreward"
		local luap = CGetFirstPayReward.Create()
		LuaProtocolManager.getInstance():send(luap)
	end

end


return NewShouchon