require "logic.dialog"

bingfengwangzuoTips = {}
setmetatable(bingfengwangzuoTips, Dialog)
bingfengwangzuoTips.__index = bingfengwangzuoTips

local _instance
function bingfengwangzuoTips.getInstance()
	if not _instance then
		_instance = bingfengwangzuoTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function bingfengwangzuoTips.getInstanceAndShow(parent)
	if not _instance then
		_instance = bingfengwangzuoTips:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function bingfengwangzuoTips.getInstanceNotCreate()
	return _instance
end

function bingfengwangzuoTips.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function bingfengwangzuoTips.ToggleOpenClose()
	if not _instance then
		_instance = bingfengwangzuoTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function bingfengwangzuoTips.GetLayoutFileName()
	return "bingfengdianji_mtg.layout"
end

function bingfengwangzuoTips:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, bingfengwangzuoTips)
    return self 
end

function bingfengwangzuoTips:OnCreate(parent)
	Dialog.OnCreate(self,parent,1)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.image = CEGUI.toItemCell(winMgr:getWindow(tostring(1).."bingfengdianji_mtg/tu"))
	self.ccmoxing = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/moxing")
    self.ccmoxing:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, bingfengwangzuoTips.performPostRenderFunctions))
	self.guan = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/guan")
	self.name = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/mingzi")
	self.explain = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/miaoshu")
	self.otherPlayerName = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/diban/name")
	self.time = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/diban/shijian")
	self.myInfo = winMgr:getWindow(tostring(1).."bingfengdianji_mtg/diban/shijian2")
	self.btnFight = CEGUI.toPushButton(winMgr:getWindow(tostring(1).."bingfengdianji_mtg/btn"))
	self.btnClose = CEGUI.toPushButton(winMgr:getWindow(tostring(1).."bingfengdianji_mtg/close"))
    self.video = CEGUI.toPushButton(winMgr:getWindow(tostring(1).."bingfengdianji_mtg/diban/btnluxiang"))
	self.btnFight:subscribeEvent("MouseClick", bingfengwangzuoTips.HandleFightBtnClick, self)
	self.btnClose:subscribeEvent("MouseClick", bingfengwangzuoTips.HandleCloseDlg, self)
    self.video:subscribeEvent("MouseClick", bingfengwangzuoTips.HandleVideoDlg, self)
end

function bingfengwangzuoTips:initData( itemId )
    local info = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(itemId)
    local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(info.FocusNpc)
	self.npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(info.FocusNpc)  --  初始化 self.npcConfig
    if npcConfig then
	    local shapeID = npcConfig.modelID
		--print("shapeID:", shapeID)
	    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeID)
  	    local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
		self:addSprite(shapeID)
        if self.image then
            self.image:SetImage(image)
        end
        if self.name then
            self.name:setText(info.name)
        end
  	    if self.explain then
  	        self.explain:setText(info.introduce)
  	    end
  	    if self.guan then
  	        self.guan:setText(info.level)
  	    end
        self.battleId = info.Fightid
    end
end

function bingfengwangzuoTips:addSprite(modelId)
    if not self.sprite then  
        local pos = self.ccmoxing:GetScreenPosOfCenter() 
        local loc = Nuclear.NuclearPoint(pos.x, pos.y + 50) 

        self.sprite = UISprite:new(modelId)
        if self.sprite then
            self.sprite:SetUILocation(loc)
			self.sprite:SetUIScale(0.9)
			self.sprite:SetDyePartIndex(0, self.npcConfig.area1colour)
            self.sprite:SetDyePartIndex(1, self.npcConfig.area2colour)
            self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)

            local weapon = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(modelId)
            if weapon then 
                self.sprite:SetSpriteComponent(eSprite_Weapon, weapon.showWeaponId)  
            end

        end
	else
		self.sprite:SetModel(modelId)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
    end
end

function bingfengwangzuoTips.performPostRenderFunctions(id)
	local inst = bingfengwangzuoTips.getInstanceNotCreate()
	if inst and inst:IsVisible() and inst:GetWindow():getEffectiveAlpha() > 0.95 and inst.sprite then
		inst.sprite:RenderUISprite()
	end
end

function bingfengwangzuoTips:OnClose()
	if self.sprite then
		pcall(function() self.sprite:delete() end)
		self.sprite = nil
	end
	Dialog.OnClose(self)
end

function bingfengwangzuoTips:initPageInfo( page, stage )
	self.pageId = page
	self.stage = stage
end

function bingfengwangzuoTips:HandleCloseDlg( args )
	bingfengwangzuoTips.DestroyDialog()
end

function bingfengwangzuoTips:HandleFightBtnClick( args )
 	local p = require "protodef.fire.pb.instancezone.bingfeng.centerbingfengland".new()
	p.landid = self.pageId
	p.stage = self.stage
	require "manager.luaprotocolmanager":send(p)
end

function bingfengwangzuoTips:HandleVideoDlg(args)
    -- 战斗录像
    local p = require "protodef.fire.pb.battle.creqcameraurl":new()
    p.battleid = self.battleId
    require "manager.luaprotocolmanager":send(p)
end

function bingfengwangzuoTips:refreshData( roleName, useTime, stagestate, myusetime )
	self.otherPlayerName:setText(roleName)
	self.time:setText(useTime)
	local str
	if stagestate == 0 then --未通过
		str = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11249).msg
	elseif stagestate == 1 then   --通过
		str = myusetime..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11650).msg
	end
	self.myInfo:setText(str)
end

return bingfengwangzuoTips
