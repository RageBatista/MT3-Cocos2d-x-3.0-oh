------------------------------------------------------------------
-- 新首冲  黑泡泡
------------------------------------------------------------------

require "logic.dialog"
require "logic.pet.firstchargegiftpetdlg"



xiaritupian = {}
setmetatable(xiaritupian, Dialog)
xiaritupian.__index = xiaritupian

local _instance
function xiaritupian.getInstance()
	if not _instance then
		_instance = xiaritupian:new()
		_instance:OnCreate()
	end
	return _instance
end

function xiaritupian.getInstanceAndShow()
	if not _instance then
		_instance = xiaritupian:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function xiaritupian.getInstanceOrNot()
	return _instance
end

function xiaritupian.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function xiaritupian:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function xiaritupian.ToggleOpenClose()
	if not _instance then
		_instance = xiaritupian:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function xiaritupian.GetLayoutFileName()

	return "xiaritupian.layout"
end

function xiaritupian:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, xiaritupian)
	return self
end

function xiaritupian:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	--关闭按钮
	self.close = winMgr:getWindow("xiaritupian/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)


	self.m_listCell = {}
    local cShapeId = gGetDataManager():GetMainCharacterCreateShape()
	if IsPointCardServer() then	
        for i = 1, 6 do
            local index = i
            if i > 1 then
                index = i + 1
            end
		    local cell = CEGUI.toItemCell(winMgr:getWindow("xiaritupian/itemBox/item" .. i ))
		    cell:setID( i )
		    cell:subscribeEvent("MouseClick",xiaritupian.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

            local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(i)
            if cfg.borderpic:size() > 0 then
                -- local corner = winMgr:getWindow("xiaritupian/ditu/wupin"..index.."/biaoqian" .. index )
                -- corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
                -- corner:setVisible(false)--隐藏角标
            end

	    end
        -- local hengfu1 = winMgr:getWindow("xiaritupian/hengfu")
        -- hengfu1:setVisible(false)
        -- local hengfu2 = winMgr:getWindow("xiaritupian/hengfu1")
        -- hengfu2:setVisible(true)
    else
	    for i = 1, 6 do
		    local cell = CEGUI.toItemCell(winMgr:getWindow("xiaritupian/itemBox/item" .. i ))
		    cell:setID( i )
		    cell:subscribeEvent("MouseClick",xiaritupian.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

            local cfg = BeanConfigManager.getInstance():GetTableByName("game.cshouchonglibao"):getRecorder(i)
            if cfg.borderpic:size() > 0 then
                -- local corner = winMgr:getWindow("xiaritupian/ditu/wupin"..i.."/biaoqian" .. i )
                -- corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
                -- corner:setVisible(false)--隐藏角标
           end

	    end
    end
	

	
	self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("xiaritupian/btn1"))
	self.m_btnCharge:subscribeEvent("Clicked",xiaritupian.HandleBtnChargeClicked,self)
	
	self:RefreshItem()
	self:RefreshBtn()
	

end


function xiaritupian:HandlePetModel(args)

    local cShapeID = gGetDataManager():GetMainCharacterCreateShape()

	local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(1)

    FirstChargeGiftPetDlg.getInstanceAndShow(cfg.petid[cShapeID-1])
	

end


function xiaritupian:handleSkillClicked(args)
    local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
    if wnd:GetSkillID() == 0 then
        return
    end
    local pos = wnd:GetScreenPos()
	
    PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

 function xiaritupian:HandleItemClicked(args)
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

 function xiaritupian:RefreshItem()
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



return xiaritupian