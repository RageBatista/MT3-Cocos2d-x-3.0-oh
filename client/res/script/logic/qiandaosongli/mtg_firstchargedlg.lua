require "logic.pet.firstchargegiftpetdlg"

MTGFirstChargeDlg = {}
MTGFirstChargeDlg.__index = MTGFirstChargeDlg

local _instance

function MTGFirstChargeDlg.create()
    if not _instance then
		_instance = MTGFirstChargeDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function MTGFirstChargeDlg.getInstance()
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceAndShow()
     if not jlDlg then
        return nil
    end 
    local dlg = jlDlg:showSysId(Jianglinew.systemId.firstBuyReward)
	return dlg
end

function MTGFirstChargeDlg.getInstanceAndShow()
	return MTGFirstChargeDlg.getInstance()
end

function MTGFirstChargeDlg.getInstanceNotCreate()
	return _instance
end

function MTGFirstChargeDlg:remove()
     _instance = nil
end


function MTGFirstChargeDlg.DestroyDialog()
    require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
end

function MTGFirstChargeDlg:new()
	local self = {}
	setmetatable(self, MTGFirstChargeDlg)
	return self
end

function MTGFirstChargeDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function MTGFirstChargeDlg:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()

	local layoutName = "shouchong.layout"
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)


	self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("shouchong"))
	--self.m_txtTopText = winMgr:getWindow("shouchong/wenben1")
	
	self.m_listCell = {}
    local cShapeId = gGetDataManager():GetMainCharacterCreateShape()
	if IsPointCardServer() then	
        for i = 1, 6 do
            --因为表里只有10个id了 但是layout 还是11个 第2个被隐藏了
            local index = i
            if i > 1 then
                index = i + 1
            end
		    local cell = CEGUI.toItemCell(winMgr:getWindow("shouchong/ditu/wupin" .. index ))
		    cell:setID( i )
		    cell:subscribeEvent("MouseClick",MTGFirstChargeDlg.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

            local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(i)
            if cfg.borderpic:size() > 0 then
                local corner = winMgr:getWindow("shouchong/ditu/wupin"..index.."/biaoqian" .. index )
                corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
            end

	    end
        --物品2隐藏
        local wupin2 = winMgr:getWindow("shouchong/ditu/wing2")
        wupin2:setVisible(false)
        --物品1改位置
        local wupin1 = winMgr:getWindow("shouchong/ditu/wing1")
    	local x = wupin1:getXPosition().offset
		local y = wupin1:getYPosition().offset
        wupin1:setPosition(NewVector2(x + 90, y))
        --横幅显示隐藏
        local hengfu1 = winMgr:getWindow("shouchong/hengfu")
        hengfu1:setVisible(false)
        local hengfu2 = winMgr:getWindow("shouchong/hengfu1")
        hengfu2:setVisible(true)
    else
	    for i = 1, 6 do
		    local cell = CEGUI.toItemCell(winMgr:getWindow("shouchong/ditu/wupin" .. i ))
		    cell:setID( i )
		    cell:subscribeEvent("MouseClick",MTGFirstChargeDlg.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

            local cfg = BeanConfigManager.getInstance():GetTableByName("game.cshouchonglibao"):getRecorder(i)
            if cfg.borderpic:size() > 0 then
                local corner = winMgr:getWindow("shouchong/ditu/wupin"..i.."/biaoqian" .. i )
                corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
            end

	    end
    end
	
	self.ccsctips = CEGUI.toRichEditbox(winMgr:getWindow("shouchong/ccyz/ccyc11/sctips"))
	self.ccsctips:Clear()
    self.ccsctips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7502)))
    self.ccsctips:Refresh()

	
	self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("shouchong/chongzhi"))
	self:addButtonAnimation(self.m_btnCharge, "studyBtnPress")
	self.m_btnCharge:subscribeEvent("Clicked",MTGFirstChargeDlg.HandleBtnChargeClicked,self)

	self:RefreshItem()
	self:RefreshBtn()
end

function MTGFirstChargeDlg:RefreshItem()
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

function MTGFirstChargeDlg:RefreshBtn()
	local mgr = LoginRewardManager.getInstance()

	if mgr.m_firstchargeState == 1 then
		self.m_btnCharge:setText(MHSD_UTILS.get_resstring(2780))
	elseif mgr.m_firstchargeState == 2 then
		self.m_btnCharge:setText(MHSD_UTILS.get_resstring(2780))
		self.m_btnCharge:setEnabled(false)
	end
		
end

function MTGFirstChargeDlg:HandleItemClicked(args)
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


function MTGFirstChargeDlg:HandleBtnChargeClicked(e)
	-- local mgr = LoginRewardManager.getInstance()
    -- if mgr.m_firstchargeState==0 then
	-- --IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DUmthYW9waGlWdlNF")
	-- --	ShopLabel.showRecharge()
	--     require("logic.libaoduihuan.libaoduihuanma")
    --     Libaoduihuanma.getInstanceAndShow()
	-- end

	-- if mgr.m_firstchargeState==1 then
	-- 	require "protodef.fire.pb.fushi.cgetfirstpayreward"
	-- 	local luap = CGetFirstPayReward.Create()
	-- 	LuaProtocolManager.getInstance():send(luap)
	-- end

	require"logic.logo.NewShouchon".getInstanceAndShow()


	--require("logic.shop.shoplabel").getInstance():showOnly(3)
end

return MTGFirstChargeDlg
