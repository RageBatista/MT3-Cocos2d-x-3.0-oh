require "logic.dialog"
debugrequire "logic.mapchose.mapchosedlg"


WorldMapdlg = {};
setmetatable(WorldMapdlg, Dialog);
WorldMapdlg.__index = WorldMapdlg;

-----------------------------public:------------------------------------
----------------////////////singleton------------------------------
local  _instance;
function WorldMapdlg.GetSingleton()
	return _instance;
end

function WorldMapdlg.GetSingletonDialog()
	if not _instance then
		_instance = WorldMapdlg:new();
		_instance:OnCreate();
	end
	
	return _instance;
end

function WorldMapdlg.GetSingletonDialogAndShowIt()
	if not _instance then
		_instance = WorldMapdlg:new();
		_instance:OnCreate();
	else 
		_instance:SetVisible(true);
	end
end

function WorldMapdlg.DestroyDialog()
	if _instance then 
	_instance.cc_animationInstance1:stop()
	_instance.cc_animationInstance2:stop()
	_instance.cc_animationInstance3:stop()
	_instance.cc_animationInstance4:stop()
		_instance:CloseDialog();
	end
end

function WorldMapdlg.SigleUpdateUseFlyFlagState()
	_instance:UpdateUseFlyFlagState();
end

function WorldMapdlg:CloseDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function WorldMapdlg.ToggleOpenClose()
	if not _instance then 
		_instance = WorldMapdlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


----------//////////////////////////---------------------------
function WorldMapdlg:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, WorldMapdlg);
	self:init();
	return self;
end

function WorldMapdlg:init( )
	self.m_bFlyRuneMode = false;
	self.m_FlyRuneItemID = -1;
end

function WorldMapdlg.GetLayoutFileName()
	return "worldmap.layout";
end

function WorldMapdlg:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_CloseButton = winMgr:getWindow("WorldMap/CloseButton")
	self.m_CloseButton:subscribeEvent("Clicked", self.HandleCloseClick, self)
	self.m_MapImage = winMgr:getWindow("WorldMap/MapImage")
	self.m_MapImage:setAlwaysOnTop(true)
	self.m_MapImage:setMousePassThroughEnabled(false);

	self.m_HighLight = winMgr:getWindow("WorldMap/MapImage/highlight");
	self.m_HighLight:subscribeEvent("MouseButtonUp", self.SetHighLightDisable, self)
	self.m_MapImage:setAlwaysOnTop(true)
	self.m_MapImage:setMousePassThroughEnabled(false)
	
	--跳转按钮（回小地图）
	self.m_JumpButton = CEGUI.toPushButton(winMgr:getWindow("WorldMap/MapImage/btn"))
	self.m_JumpButton:setAlwaysOnTop(true)
	self.m_JumpButton:setMousePassThroughEnabled(false)--MouseButtonDown,MouseButtonDown
	self.m_JumpButton:subscribeEvent("Clicked", self.HandleJumpClick, self)
	
	self.cc_ditubg = winMgr:getWindow("WorldMap/MapImage/ccditubg")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen1 = aniMan:getAnimation("cc_bgani_1") 
    self.cc_animationInstance1 = aniMan:instantiateAnimation(animationOpen1) 
    self.cc_animationInstance1:setTargetWindow(self.cc_ditubg)
    self.cc_animationInstance1:start()
	
	self.cc_xz = winMgr:getWindow("WorldMap/MapImage/ccditubg/dhck1")
    self.cc_xy = winMgr:getWindow("WorldMap/MapImage/ccditubg/dhck2")
    local animationOpen2 = aniMan:getAnimation("mapjiantou1") 
    self.cc_animationInstance2 = aniMan:instantiateAnimation(animationOpen2) 
    self.cc_animationInstance2:setTargetWindow(self.cc_xz)
    self.cc_animationInstance2:start()
	
	local animationOpen3 = aniMan:getAnimation("mapjiantou2") 
    self.cc_animationInstance3 = aniMan:instantiateAnimation(animationOpen3) 
    self.cc_animationInstance3:setTargetWindow(self.cc_xy)
    self.cc_animationInstance3:start()
	
	self.m_ditu_mh1 = winMgr:getWindow("WorldMap/MapImage/ditu1")

	self.m_dikuang = CEGUI.toScrollablePane(winMgr:getWindow("WorldMap/MapImage/kuang"))
	self.m_dikuang:setHorizontalScrollPosition(0.25) --预选滚动到中间位置
	self.m_dikuang:EnableHorzScrollBar(true)
	
    self.isemoved = false
    self.movedir = 1

	self.m_MapButtonMap = {}

	self.c_ditutupian = winMgr:getWindow("WorldMap/MapImage/map1")

	self.m_TozuoBtn = winMgr:getWindow("WorldMap/MapImage/zhezhao1/zuobtn")
	self.m_ToyouBtn = winMgr:getWindow("WorldMap/MapImage/zhezhao1/youbtn")
	
	self.m_TozuoBtn:subscribeEvent("Clicked", self.handTozuo, self)
	self.m_ToyouBtn:subscribeEvent("Clicked", self.handToyou, self)

	self.m_PlayerPosImage = winMgr:getWindow("WorldMap/MapImage/PlayerPosImage")
	self.m_PlayerPosImage:setAlwaysOnTop(true)
	self.m_PlayerPosImage:setMousePassThroughEnabled(true)

	self.cc_dtzsck = winMgr:getWindow("WorldMap/MapImage/ccditubg/dhck")
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen4 = aniMan:getAnimation("huadongc2") 
    self.cc_animationInstance4 = aniMan:instantiateAnimation(animationOpen4) 
    self.cc_animationInstance4:setTargetWindow(self.cc_dtzsck)
    self.cc_animationInstance4:start()
	gGetGameUIManager():AddUIEffect(self.cc_dtzsck, "geffect/ui/ccnewani/cc_dituzs", true) 

	self.m_pSubFlyFlag = CEGUI.toCheckbox(winMgr:getWindow("WorldMap/MapImage/fly"))
	self.m_pSubFlyFlag:subscribeEvent("CheckStateChanged", self.HandleUseFlyFlagChange, self)

	--地图跳转延迟
	self.delayTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(199).value) * 1000
	self.Time = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(199).value) * 1000

	if self.delayTime == nil or self.Time == nil then
		self.delayTime = 0.5
		self.Time = 0.5
	end

	self.mapId = -1
	self.bGoto = false
    self:initBtnAndData()
	
	self:UpdateButtonPos()
	self:SetPlayerMapPos()
	self:UpdateUseFlyFlagState()

end



   
function WorldMapdlg:handTozuo()
    self.isemoved = true
    self.movedir = 1
    self:StartSmoothScroll()
end

function WorldMapdlg:handToyou()
    self.isemoved = true
    self.movedir = 2
    self:StartSmoothScroll()
end

function WorldMapdlg:StartSmoothScroll()
    self.m_pMainFrame:removeEvent("WindowUpdate")
    self.m_pMainFrame:subscribeEvent("WindowUpdate", self.HandleWindowUpdate, self)
end

function WorldMapdlg:HandleWindowUpdate(args)
    if self.isemoved then
        local curPos = self.m_dikuang:getHorzScrollbar():getScrollPosition()
        local targetPos = 0 
        if self.movedir == 2 then
            targetPos = self.m_dikuang:getHorzScrollbar():getDocumentSize() - self.m_dikuang:getPixelSize().width
        end
        if math.abs(curPos - targetPos) <= 50  then 
            self.m_dikuang:getHorzScrollbar():setScrollPosition(targetPos)
            self.m_dikuang:getHorzScrollbar():Stop()
            self.isemoved = false
        else
            if self.movedir == 1 then
                curPos = curPos - 50
                if curPos < targetPos then
                    curPos = targetPos 
                end
            else
                curPos = curPos + 50
                if curPos > targetPos then 
                    curPos = targetPos
                end
            end
            self.m_dikuang:getHorzScrollbar():setScrollPosition(curPos)
            self.m_dikuang:getHorzScrollbar():Stop()
        end
    end
end


function WorldMapdlg:initBtnAndData()
    self.map_icon_index = {}
    self.fuben = {}
	local num = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()

	
    for _, v in pairs(num) do
	    local record = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
        if record.bShowInWorld then  --在表里的 是否显示在世界地图
            table.insert(self.map_icon_index, record.id)
		--GetCTipsManager():AddMessageTip(record.id)
			
            if string.find(record.sonmapid, ",") then
                local strIds = self.GetMapIDByString(record.sonmapid)
                table.insert(self.fuben, strIds)
            end
        end
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
	
    for k,v in pairs(self.map_icon_index) do
		local wndName = "WorldMap/" .. tostring(v)
		if winMgr:isWindowPresent(wndName) then
			self.m_MapButtonMap[v] = CEGUI.toPushButton(winMgr:getWindow(wndName))
			self.m_MapButtonMap[v]:subscribeEvent("MouseButtonDown", WorldMapdlg.HandleMapBtnDown, self)
			self.m_MapButtonMap[v]:subscribeEvent("MouseButtonUp", WorldMapdlg.HandleMapBtnUp, self)
			self.m_MapButtonMap[v]:setID(v)
		end

	end

end

-- 检测地图上是否由此索引的地图图标
function WorldMapdlg.isMapIdInMap(id)
	for k,v in pairs(self.map_icon_index) do 
		if v == id then
			return true;
		end
	end
	return false;
end
function WorldMapdlg:initMapBtnStatus()
	for k,v in pairs(self.map_icon_index) do
		self.m_MapButtonMap[v]:setVisible(true)

	end
end
function WorldMapdlg:SetHighLightDisable(e)

end

--点击地图块
function WorldMapdlg:HandleMapBtnDown(e)

	if self.bGoto then
		return true
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e);
	local mapId = mouseArgs.window:getID();
	print("MapID: " .. mapId)

	if mapId < 0 then
		return true;
	end

	local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId);

	if mapRecord == nil then
		return true
	end
	self.mapId = mapId
end

function WorldMapdlg:HandleMapBtnUp(e)
	if self.bGoto then
		return true
	end
	print("WorldMapdlg:HandleMapButtonClick")
	local mouseArgs = CEGUI.toMouseEventArgs(e);
	local mapId = mouseArgs.window:getID();
	print("MapID: " .. mapId)

	if mapId < 0 then
		return true;
	end

	local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId);

	if mapRecord == nil then
		return true
	end

    if GetIsInFamilyFight() then
         local function ClickYes2(self, args)
            if self.mapId == mapId then
		        self.bGoto = true
	        else
		        self:SetHighLightDisable(e)
	        end 
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)   
        end
        local msg = MHSD_UTILS.get_msgtipstring(410053)
        gGetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes2,self,MessageManager.HandleDefaultCancelEvent,MessageManager)
    else
        if self.mapId == mapId then
		    self.bGoto = true
	    else
		    self:SetHighLightDisable(e)
	    end    
    end

end

function WorldMapdlg:update(delta)

	if self.bGoto then

		self.delayTime = self.delayTime - delta

		if self.delayTime > 0 then
			return true
		end

		self:SetHighLightDisable(e)

		if GetTeamManager() and not GetTeamManager():CanIMove() then--处于组队状态，无法传送

			GetChatManager():AddTipsMsg(150030) 

			self.bGoto = false
			self.delayTime = self.Time

			return true
		end
		
		local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.mapId);

		if mapRecord.maptype == 1 or mapRecord.maptype == 2 then
		
			local randX = mapRecord.bottomx - mapRecord.topx;
			randX = mapRecord.topx + math.random(0, randX);

			local randY = mapRecord.bottomy - mapRecord.topy;
			randY = mapRecord.topy + math.random(0, randY);
		
			require("logic.fuben.fubenmanager").getInstance():checkForSendExitFuben()
		
			gGetNetConnection():send(fire.pb.mission.CReqGoto(self.mapId, randX, randY));
		
			GetMainCharacter():RemoveAutoWalkingEffect()
            if gGetScene()  then
			    gGetScene():EnableJumpMapForAutoBattle(false);
		    end
			WorldMapdlg.DestroyDialog();

		elseif mapRecord.maptype == 3 and mapRecord.sonmapid ~= "0" then

			MapChoseDlg.getInstanceAndShow();


			if MapChoseDlg.getInstanceNotCreate() then
				MapChoseDlg.getInstanceNotCreate().SetMapID(self.mapId)
	_instance.cc_animationInstance1:stop()
	_instance.cc_animationInstance2:stop()
	_instance.cc_animationInstance3:stop()
	_instance.cc_animationInstance4:stop()
				WorldMapdlg.DestroyDialog();
			end
		else
		


		end

	else

		
	end
	local maxScrollPos = 0.36583028864861
    local scrollPos = self.m_dikuang:getHorizontalScrollPosition()
    print("Current Scroll Position: " .. scrollPos)  
    -- 左按钮
    print("Left button visible before:", self.m_TozuoBtn:isVisible())
    print("Scroll Position:", scrollPos) 
    self.m_TozuoBtn:setVisible(scrollPos > 0)
    print("Left button visible after:", self.m_TozuoBtn:isVisible())

    -- 右按钮
    print("Right button visible before:", self.m_ToyouBtn:isVisible())
    print("Scroll Position:", scrollPos) 
    self.m_ToyouBtn:setVisible(scrollPos < maxScrollPos)  -- 显示右按钮 
    print("Right button visible after:", self.m_ToyouBtn:isVisible())

end

function WorldMapdlg:HandleJumpClick(e)
    local mapID = gGetScene():GetMapID()
    local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapID)
    if not mapCfg or not mapCfg.smallmapRes or mapCfg.smallmapRes == "" then
        GetCTipsManager():AddMessageTipById(160140) --该场景没有小地图
        return
    end
	_instance.cc_animationInstance1:stop()
	_instance.cc_animationInstance2:stop()
	_instance.cc_animationInstance3:stop()
	_instance.cc_animationInstance4:stop()

    WorldMapdlg.DestroyDialog()
    if not SmallMapDlg.getInstanceNotCreate() then
        SmallMapDlg.getInstanceAndShow()
	end
end


   
function WorldMapdlg:HandleCloseClick(e)

	if self.bGoto then
		return true
	end

	local mouseArgs = CEGUI.toMouseEventArgs(e);
	if mouseArgs.window == self.m_MapImage then
		if mouseArgs.button ~= CEGUI.RightButton then
			return true;
		end
	end
	_instance.cc_animationInstance1:stop()
	_instance.cc_animationInstance2:stop()
	_instance.cc_animationInstance3:stop()
	_instance.cc_animationInstance4:stop()
	WorldMapdlg.DestroyDialog();
	return true;
end


function WorldMapdlg:HandleUseFlyFlagChange(e)
	if self.bGoto then
		return true
	end

	local bUse = self.m_pSubFlyFlag:isSelected();
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	roleItemManager:EnableUseFlyFlagToFly(bUse);
end

function WorldMapdlg:UpdateButtonPos()

end

function WorldMapdlg.RectToStringAbsolute( rect )
	local iss = "{{" .. "0" .. "," .. rect.d_left .. "},{" ..
						"0" .. "," .. rect.d_top .. "},{" ..
						"0" .. "," .. rect.d_right .. "},{" ..
						"0" .. "," .. rect.d_bottom .. "}}";
	return iss;
end

function WorldMapdlg:SetPlayerMapPos()
    --副本部分的头像处理
    local mapid = gGetScene():GetMapID();
    local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapid)

    if mapCfg and mapCfg.bShowInWorld == false then
        for mm, nn in pairs(self.fuben) do 
            for m,n in pairs(nn) do 
                if mapid == tonumber(n) then
                    mapid = tonumber(self.fuben[mm][1])
                end
            end
        end
    end

    if not self.m_MapButtonMap[mapid] then
        self.m_PlayerPosImage:setVisible(false);
       -- self.cc_zsp:setVisible(false); -- 设置不可见

        return;
    end
    local  mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(mapid);

    if mapconfig.playerPosX >= 0 and mapconfig.playerPosY >= 0 then
		local shape=gGetDataManager():GetMainCharacterShape() % 100+1010100

        local shape = BeanConfigManager.getInstance():GetTableByName("map.cworldmapsmallheadconfig"):getRecorder(shape);
        local shapeId = shape.ccwordmaphead -- 新头像
        local iconpath = gGetIconManager():GetImagePathByID(tonumber(shapeId)):c_str();
        
        self.m_PlayerPosImage:setVisible(true);
        self.m_PlayerPosImage:setProperty("Image", iconpath);
        --self.cc_zsp:setVisible(true); 
        
        local buttonPos = self.m_MapButtonMap[mapid]:getPosition() 
        local buttonSize = self.m_MapButtonMap[mapid]:getPixelSize()
        local iconSize = self.m_PlayerPosImage:getPixelSize()

        -- 计算头像位置
        local relativeX = (buttonSize.width - iconSize.width) * 0.5
        local relativeY = buttonSize.height - iconSize.height - 30

        -- 设置头像位置
        self.m_PlayerPosImage:setPosition(CEGUI.UVector2(
            CEGUI.UDim(buttonPos.x.scale, buttonPos.x.offset + relativeX), 
            CEGUI.UDim(buttonPos.y.scale, buttonPos.y.offset + relativeY)
        ))
        
    else
        self.m_PlayerPosImage:setVisible(false);
    --	self.cc_zsp:setVisible(false);
    end
end

function WorldMapdlg.GetMapIDByString(strSubMaps)
	local sub_str_tab = {};
	local str = strSubMaps;
	while (true) do 
		local pos = string.find(str, ",");
		if not pos then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end
	return sub_str_tab;
end

function WorldMapdlg:UpdateUseFlyFlagState()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local bUse = roleItemManager:isUseFlyFlagToFly();
	self.m_pSubFlyFlag:setSelected(bUse);
end
return WorldMapdlg;
