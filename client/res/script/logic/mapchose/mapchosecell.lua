require "logic.workshop.tipsguajiimg"

MapChooseCell = {}

setmetatable(MapChooseCell, Dialog)
MapChooseCell.__index = MapChooseCell
local prefix = 0

function MapChooseCell.CreateNewDlg(parent)
	local newDlg = MapChooseCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function MapChooseCell.GetLayoutFileName()
	return "mapchosedialogcell_mtg.layout"
end

function MapChooseCell:OnClose()
	Dialog.OnClose(self)
	if self.m_sprite then
		self.m_sprite = nil		
	end
end

function MapChooseCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MapChooseCell)
	return self
end

function MapChooseCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_imgBg = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "mapchosedialogcell_mtg"))
	self.m_imgBg:EnableClickAni(false)
	self.m_imgRole = winMgr:getWindow(prefixstr .. "mapchosedialogcell_mtg/fazhen/image")
	self.m_btnIntro = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "mapchosedialogcell_mtg/btntishi"))
	self.m_txtMapName = winMgr:getWindow(prefixstr .. "mapchosedialogcell_mtg/textditu")
	self.m_txtLevel = winMgr:getWindow(prefixstr .. "mapchosedialogcell_mtg/textdengji")

	self.m_imgBg:subscribeEvent("MouseButtonUp", MapChooseCell.HandleImgBgClick, self)
	self.m_imgBg:subscribeEvent("MouseButtonDown", MapChooseCell.HandleImgBgBtnDown, self)
	self.m_imgBg:subscribeEvent("MouseButtonUp", MapChooseCell.HandleImgBgBtnUp, self)
	self.m_btnIntro:subscribeEvent("Clicked", MapChooseCell.HandleBtnIntroClick, self)

	self.m_sprite = nil
	self.m_mapID = 0
	
end

function MapChooseCell:SetMapID(id)
	self.m_mapID = id
end

function MapChooseCell:GetMapID()
	return self.m_mapID
end

function MapChooseCell:Refresh()
	self:RefreshTxt()	
	self:RefreshAnimation()
end

function MapChooseCell:RefreshTxt()	
	local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.m_mapID)
	local minLevel = mapconfig.LevelLimitMin
	local maxlevel = mapconfig.LevelLimitMax
	local levelstr = ""..(minLevel).."-"..(maxlevel)
	self.m_txtMapName:setText(mapconfig.mapName)
	self.m_txtLevel:setText(levelstr)
end
	
function MapChooseCell:RefreshAnimation()
	local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.m_mapID)
	local pt = self:GetWindow():GetScreenPosOfCenter()
	local width = 230
	local height  = 336
	local sculptid =  mapconfig.sculptid 
	self.m_sprite = gGetGameUIManager():AddWindowSprite(self.m_imgRole, sculptid, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
	self.m_sprite:SetUIScale(1.0)
end

function MapChooseCell:HandleImgBgBtnDown(args)

	return true
end	
	
	
function MapChooseCell:HandleImgBgBtnUp(args)

	return true
end

function MapChooseCell:SetSelectedBySelf( bSelected )
	self.m_imgBg:setSelected(bSelected)
end

function MapChooseCell:HandleImgBgClick(args)
	print("MapChooseCell:HandleImgBgClick(args)")
	
	if GetBattleManager():IsInBattle() then	
		GetChatManager():AddTipsMsg(150157)
		return true
	end
	
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(1230);
	local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.m_mapID)
	local minLevel = mapconfig.LevelLimitMin
	local maxlevel = mapconfig.LevelLimitMax

	
	local mapdlg = MapChoseDlg:getInstanceNotCreate()
	if mapdlg then
		mapdlg:RefreshCellColor()
	end

	local mapID = self.m_mapID -- wndE.window:getID();
	if mapID > 0 then
		local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapID)
        local disLevel = GameTable.common.GetCCommonTableInstance():getRecorder(206).value
		if mapRecord then -- 存在地图
			
			if GetTeamManager() and not GetTeamManager():CanIMove() then
				if GetChatManager() then GetChatManager():AddTipsMsg(150030) end --处于组队状态，无法传送
				return true
			end

			local roleLevel = gGetDataManager():GetMainCharacterLevel();
			if roleLevel < mapRecord.LevelLimitMin - disLevel then -- 等级限制的判断

				local strMessage = MHSD_UTILS.get_msgtipstring(150150);
				gGetMessageManager():AddConfirmBox(eConfirmGotoHighLevelMap, strMessage,
					MapChooseCell.OnConfirmGoHighLevelMap, self,
					MapChooseCell.HandleDefaultCancelEvent,self);
				return true;
			
			elseif 	roleLevel > mapRecord.LevelLimitMax + disLevel then
				local strMessage = MHSD_UTILS.get_msgtipstring(150149)		
				gGetMessageManager():AddConfirmBox(eConfirmGotoHighLevelMap, strMessage,
					MapChooseCell.OnConfirmGoHighLevelMap, self,
					MapChooseCell.HandleDefaultCancelEvent,self);
				return true;
			end

			-- 没有进入选定的地图，在当前地图中漫步
			if gGetScene() and mapID == gGetScene():GetMapID() and GetMainCharacter() then

				GetMainCharacter():SetRandomPacing();
				MapChoseDlg.DestroyDialog()
				return true;
			end

			local randX=mapRecord.bottomx - mapRecord.topx;
			randX = mapRecord.topx + math.random(0, randX);

			local randY = mapRecord.bottomy - mapRecord.topy;
			randY = mapRecord.topy + math.random(0, randY);
			print( "MapChooseCell:HandleImgBgClick: MapID : "..mapID )
			local cmd = fire.pb.mission.CReqGoto(mapID, randX, randY);
			gGetNetConnection():send(cmd);

			if gGetScene()  then
				gGetScene():EnableJumpMapForAutoBattle(true);
			end
			MapChoseDlg.DestroyDialog()
		end
	end
	--end
	return true;
end

function MapChooseCell:HandleDefaultCancelEvent(args)
	print("MapChooseCell:HandleDefaultCancelEvent(args)")
    local windowargs = CEGUI.toWindowEventArgs(args)

    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
        gGetMessageManager():CloseConfirmBox(eConfirmGotoHighLevelMap,false)
    end

    local mapdlg = MapChoseDlg:getInstanceNotCreate()
	if mapdlg then
		mapdlg:RefreshCellColor()
	end
end

function MapChooseCell:OnConfirmGoHighLevelMap(e)
	if self.m_mapID == 0 then 
		return true;
	end

	if gGetScene() and self.m_mapID == gGetScene():GetMapID() and GetMainCharacter() then
		GetMainCharacter():SetRandomPacing();
	else
		local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.m_mapID);
		if mapRecord then
			local randX = mapRecord.bottomx - mapRecord.topx;
			randX = mapRecord.topx + math.random(0, randX);

			local randY = mapRecord.bottomy - mapRecord.topy;
			randY = mapRecord.topy + math.random(0, randY);

			gGetNetConnection():send(fire.pb.mission.CReqGoto(self.m_mapID, randX, randY));

			if gGetScene()  then
				gGetScene():EnableJumpMapForAutoBattle(true);
			end
		end
	end

	MessageManager:HandleDefaultCancelEvent(e);
	MapChoseDlg.DestroyDialog()

	return true;
end


function MapChooseCell:HandleBtnIntroClick(args)
	print("MapChooseCell:HandleBtnIntroClick(args)")
	
	if TipsGuajiImg.getInstanceNotCreate() then
		TipsGuajiImg.DestroyDialog()
	end

	local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.m_mapID)
	local myy = mapRecord.sonmapid
	local mmm = mapRecord.sculptimgid
	print(""..mmm)
	local vecSubMaps =  MapChoseDlg.GetSubMapIDByString(mapRecord.sculptimgid);
	
	local dlg = TipsGuajiImg.getInstanceAndShow(self.m_mapID, vecSubMaps)
	local chargeDlg = MapChoseDlg.getInstanceNotCreate()
	local pos = chargeDlg:GetWindow():GetScreenPos()
	
	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,pos.x + 220), CEGUI.UDim(0, pos.y + 150)))
	dlg:GetWindow():setAlwaysOnTop(true)
	
end

return MapChooseCell
