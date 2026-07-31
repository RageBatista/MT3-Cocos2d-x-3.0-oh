require "logic.dialog"
require "logic.worldmap.worldmapdlg"

SmallMapDlg = {
	m_trailPos = {},
	m_mapScale = 0.3,
	m_trail_si = {},
	m_step = 20
}
setmetatable(SmallMapDlg, Dialog)
SmallMapDlg.__index = SmallMapDlg

local _instance

function SmallMapDlg.getInstance()
	LogInfo("enter get SmallMapDlg instance");

	if not _instance then
		_instance = SmallMapDlg:new();
		_instance:OnCreate();
	end

	return _instance
end

function SmallMapDlg.DestroyDialog()
	if _instance then 
	    if _instance.cc_AnimationInstance1 then 
           _instance.cc_AnimationInstance1:stop()
           _instance.cc_AnimationInstance1 = nil 
        end
	    if _instance.cc_AnimationInstance2 then 
           _instance.cc_AnimationInstance2:stop()
           _instance.cc_AnimationInstance2 = nil 
        end
		print("before OnClose().......")
		_instance:OnClose()
		_instance = nil
	end
end

function SmallMapDlg.getInstanceAndShow()

	if not _instance then
        _instance = SmallMapDlg:new()
        _instance:OnCreate()
	else
		_instance:setVisible(true)
    end
    return _instance
end

function SmallMapDlg.getInstanceNotCreate()
    return _instance
end

function SmallMapDlg:new()
	local self = {}
	setmetatable(self, SmallMapDlg)
	return self
end

function SmallMapDlg.GetLayoutFileName()
	return "xiaoditu_mtg.layout";
end

function SmallMapDlg:OnCreate()
	Dialog.OnCreate(self)
	-- 实际窗口大小
	self.m_screenWidth = Nuclear.GetEngine():GetScreenWidth()
	self.m_screenHeight = Nuclear.GetEngine():GetScreenHeight()
	-- 获得逻辑窗口大小
	self.m_logicWidth = Nuclear.GetEngine():GetLogicWidth()
	self.m_logicHeight = Nuclear.GetEngine():GetLogicHeight()
	-- 当前地图ID
	local mapid = gGetScene():GetMapID()
	-- 获得地图信息
	local mapRec = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(mapid)
	self.m_backMapWidth = mapRec.width
	self.m_backMapHeight = mapRec.height
	-- 小地图信息
	local worldmapRec = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapid)
	self.m_smallMapRes = worldmapRec.smallmapRes

	local smallmapSize = worldmapRec.smallmapSize
	local commaIndex = string.find(smallmapSize, ";")
	if not commaIndex then
		self.m_smallMapWidth = 900
		self.m_smallMapHeight = 485
	else
		self.m_smallMapWidth = tonumber(string.sub(smallmapSize, 1, commaIndex-1))
		self.m_smallMapHeight = tonumber(string.sub(smallmapSize, commaIndex+1))
	end

	-- 计算缩小比例
	self.m_mapScale = self.m_smallMapHeight/self.m_backMapHeight
	self.m_menuCells = {}
    -- 加载UI
	self:LoadUI()
	
	self:GetWindow():subscribeEvent("WindowUpdate", SmallMapDlg.HandleWindowUpdate, self)

    self.tickCount = 0
end

function SmallMapDlg:OnClose()
	self.m_trailPos = {}
	self.m_trail_si = {}
	Dialog.OnClose(self)
	_instance = nil
end

function SmallMapDlg:LoadUI()
	local winMgr = CEGUI.WindowManager:getSingleton()

	-- 查找按钮
	local searchBtn = CEGUI.Window.toPushButton(winMgr:getWindow("xiaoditu/btn"))
	searchBtn:subscribeEvent("Clicked", self.HandleSearchBtnClick, self)
	
	-- 世界地图切换按钮
	local switchBtn = CEGUI.toPushButton(winMgr:getWindow("xiaoditu/btn1"))
	switchBtn:subscribeEvent("Clicked", self.HandleSwitchBtnClick, self)
	
	self.cc_xdtbg = winMgr:getWindow("xiaoditu")
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen1 = aniMan:getAnimation("cc_bgani_1") 
    self.cc_AnimationInstance1 = aniMan:instantiateAnimation(animationOpen1) 
    self.cc_AnimationInstance1:setTargetWindow(self.cc_xdtbg)
    self.cc_AnimationInstance1:start()

	-- NPC滑动菜单
	self.m_npcFrame = winMgr:getWindow("xiaoditu/kuang")
	self.m_npcFrame:setVisible(false)
	self.m_npcFrame:setAlwaysOnTop(true)
	self.m_npcFrame:setMousePassThroughEnabled(false)
	self.m_npcList_sp = CEGUI.Window.toScrollablePane(winMgr:getWindow("xiaoditu/kuang/list"))

	-- 小地图控件
	self.m_map_si = winMgr:getWindow("xiaoditu/image")
	self.m_map_si:setProperty("Image",self.m_smallMapRes)
	self.m_map_si:setMousePassThroughEnabled(true)
	self.m_map_si = winMgr:getWindow("xiaoditu/image")
	

	
	-- 根节点
	self.m_rootWnd = winMgr:getWindow("xiaoditu")
	self.m_rootWnd:setWidth(CEGUI.UDim(0,self.m_smallMapWidth+10))
	self.m_rootWnd:setHeight(CEGUI.UDim(0,self.m_smallMapHeight+10))
	
	self.m_roleEffectWnd = winMgr:getWindow("xiaoditu/effet")

	-- 关闭按钮
	self.m_closeBtn = winMgr:getWindow("xiaoditu/close")
	self.m_closeBtn:setProperty("AlwaysOnTop", "True")
	self.m_closeBtn:subscribeEvent("Clicked", self.HandleCloseBtnClick, self)
	local closeBtnWidth = self.m_closeBtn:getWidth().offset
	local closeBtnPos = self.m_closeBtn:getPosition()
	local imagePos = self.m_map_si:getPosition()
	local closeBtnNewPos = CEGUI.UVector2(CEGUI.UDim(0,imagePos.x.offset+self.m_smallMapWidth-closeBtnWidth*1.0), CEGUI.UDim(0, closeBtnPos.y.offset))
	self.m_closeBtn:setPosition(closeBtnNewPos)
	

	--根控件
	self.m_map = winMgr:getWindow("xiaoditu")
	-- 根上加上点击事件
	self.m_map:subscribeEvent("MouseClick", SmallMapDlg.HandleMapClick, self)
	-- 设置小地图UI位置
	local mapPos = CEGUI.UVector2(CEGUI.UDim(0, (self.m_logicWidth-self.m_smallMapWidth)*0.5), CEGUI.UDim(0, (self.m_logicHeight-self.m_smallMapHeight)*0.5))
	self.m_map:setPosition(mapPos)
	self.m_map:setAlwaysOnTop(true)
	self.m_map:setWidth(CEGUI.UDim(0,self.m_smallMapWidth))
	self.m_map:setHeight(CEGUI.UDim(0,self.m_smallMapHeight))
	
	--self.cc_xdtbg:setWidth(CEGUI.UDim(0, self.m_smallMapWidth)) 
   -- self.cc_xdtbg:setHeight(CEGUI.UDim(0, self.m_smallMapHeight)) 

    --表示自动寻路用的小图标因为渲染层级的原因，需要先加到map上。
    self.m_pathIcons = {}
    
	self.trailImageWidth = 13
	self.trailImageHeight = 13
    for j = 1, 65 do
	    local namePrefix = "trail"..tostring(25*100+j)
	    local trail_si = winMgr:createWindow("TaharezLook/StaticImage", namePrefix )
	    self.m_map:addChildWindow(trail_si)
	    trail_si:setProperty("Image","set:huobanui image:lujingdian")
	    trail_si:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, -50), CEGUI.UDim(0.0, -50)))
	    trail_si:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.trailImageWidth), CEGUI.UDim(0, self.trailImageHeight)))
	    trail_si:setProperty("FrameEnabled", "False")
	    table.insert(self.m_pathIcons,trail_si)
    end

    -- 玩家的位置信息
	local worldPos = GetMainCharacter():GetLocation()
	local worldPosX = worldPos.x
	local worldPosY = worldPos.y
	local roleX = worldPos.x*self.m_mapScale
	local roleY = worldPos.y*self.m_mapScale
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_roleEffectWnd:setMousePassThroughEnabled(false)
	self.m_map:addChildWindow(self.m_roleEffectWnd)
	self.m_roleEffectWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, roleX), CEGUI.UDim(0.0, roleY)))
	local shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape());
	local iconpath = gGetIconManager():GetImagePathByID(shape.mapheadID):c_str();
	self.m_roleEffectWnd:setProperty("Image", iconpath);

    -- 目标图标
    self.endImageWidth = 41
	self.endImageHeight = 59

	self.end_si = winMgr:createWindow("TaharezLook/StaticImage", "end")
	self.m_map:addChildWindow(self.end_si)
    self.end_si:setProperty("Image","set:huobanui image:mubiaodian")
    self.end_si:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.endImageWidth), CEGUI.UDim(0, self.endImageHeight)))
	self.end_si:setZOrderingEnabled(false)
	self.end_si:setProperty("FrameEnabled", "False")
	self.end_si:setMousePassThroughEnabled(true)
    self.end_si:setVisible(false)
	
	self.m_lNpcList = {}
	-- 读出该地图对应的NPC数据
    gGetScene():getGuaJiMapNpc()


end

function SmallMapDlg:isShowNpc(npcTmp)
    
    if not npcTmp then
        return false
    end

    if not npcTmp.showInMiniMap or 0 == npcTmp.showInMiniMap then
        return false;
    end
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            if npcTmp.showinserver == 2 then
                return false
            end
        else
            if npcTmp.showinserver == 1 then
                return false
            end
        end
    end
    return true
end


function SmallMapDlg:InsertNpcList(id, posX, posY)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local npcInfo = {}
	npcInfo.npcID = id
	npcInfo.xpos = posX
	npcInfo.ypos = posY
	local npcTmp = BeanConfigManager.getInstance():GetTableByName("npc.cnpcinfo"):getRecorder(npcInfo.npcID)
	local npcType = npcTmp.npctype
	local hide = npcTmp.hide
    local bNeedShow = self:isShowNpc(npcTmp)
	if bNeedShow  then

		table.insert(self.m_lNpcList, npcInfo)
				
		local namePrefix = tostring(npcInfo.npcID)
		local npcName_st = CEGUI.toRichEditbox(winMgr:createWindow("TaharezLook/StaticText", namePrefix))
		npcName_st:setProperty("Font", "simhei-9")
		npcName_st:setProperty("HorizontalAlignment", "Left")
		npcName_st:setProperty("VerticalAlignment", "Top")
		local textColor = "tl:"..npcTmp.namecolour.." tr:"..npcTmp.namecolour.." bl:"..npcTmp.namecolour.." br:"..npcTmp.namecolour
		npcName_st:setProperty("TextColours", textColor)
		npcName_st:setProperty("MousePassThroughEnabled", "False")
		npcName_st:setID(npcInfo.npcID)
		if npcTmp.bordercolour ~= "0" and npcTmp.bordercolour ~= "" then
			npcName_st:setProperty("BorderEnable", "True")
			npcName_st:setProperty("BorderColour", npcTmp.bordercolour)
		end
		self.m_map:addChildWindow(npcName_st)
		-- NPC名字
		npcName_st:setText(npcTmp.name)
		local font = npcName_st:getFont()
		local nameWidth = font:getTextExtent(npcTmp.name)
		local nameHeight = font:getFontHeight()
					
		npcName_st:setSize(CEGUI.UVector2(CEGUI.UDim(0, nameWidth+6), CEGUI.UDim(0, nameHeight+4)))
		npcName_st:setClippedByParent(true)
		-- 转换为世界坐标
		local smallPosX = (npcInfo.xpos*1.5)*self.m_mapScale - nameWidth*0.6
		local smallPosY = npcInfo.ypos*self.m_mapScale - nameHeight*1.1
		npcName_st:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, smallPosX), CEGUI.UDim(0.0, smallPosY)))
		-- 加上点击事件
		npcName_st:subscribeEvent("MouseClick", SmallMapDlg.HandleItemClick, self)
	end
end
function SmallMapDlg.InitNpcList(id, posX, posY, a)
    local dlg = require "logic.mapchose.smallmapdlg".getInstanceNotCreate()

    if dlg then
        dlg:InsertNpcList(id, posX, posY)
    end
end
local callTimes = 1

function SmallMapDlg:HandleMapClick(args)
    GetMainCharacter():RemoveAutoWalkingEffect()
	self.m_npcFrame:setVisible(false)
	callTimes = callTimes + 1
	local winMgr = CEGUI.WindowManager:getSingleton()
	-- 清理上次的轨迹
	local trailSize = table.getn(self.m_trail_si)
	for i = 1, trailSize do
		if self.m_trail_si[i] then
			self.m_trail_si[i]:setVisible(false)
		end
	end
	self.m_trail_si = {}
	self.m_trailPos = {}
	

	local event = CEGUI.toMouseEventArgs(args)
	local touchScreenPos = event.position
	local touchX = touchScreenPos.x
	local touchY = touchScreenPos.y

	--点击世界坐标
	local worldTouchPos = gGetScene():MousePointToPixel(Nuclear.NuclearPoint(touchX,touchY))
	local worldTouchPosX = worldTouchPos.x
	local worldTouchPosY = worldTouchPos.y
	-- 小地图屏幕坐标
	local smallMapPos = self.m_map:getPosition()
	local smallMapPosX = smallMapPos.x.offset
	local smallMapPosY = smallMapPos.y.offset
	-- 小地图世界坐标
	local worldSMPos = gGetScene():MousePointToPixel(Nuclear.NuclearPoint(smallMapPosX,smallMapPosY))
	local worldSMPosX = worldSMPos.x
	local worldSMPosY = worldSMPos.y
	-- 世界坐标差
	local worldPosX = (worldTouchPosX - worldSMPosX)/self.m_mapScale
	local worldPosY = (worldTouchPosY - worldSMPosY)/self.m_mapScale
	
	local logicPosX = worldPosX/1.5
	local logicPosY = worldPosY

	local bingo = GetMainCharacter():ActiveMoveTo(Nuclear.NuclearPoint(logicPosX, logicPosY), 0, false, 0)
	local pathVec = GetMainCharacter():GetAstarPath()
	local pathSize = pathVec:size()
	if pathSize == 0 then
		return
	end

	-- 换算成世界坐标
	local beginPoint = Nuclear.NuclearPoint(pathVec[0].x*1.5, pathVec[0].y)
	for i = 1, pathSize-1 do 
		local curPoint = Nuclear.NuclearPoint(pathVec[i].x*1.5, pathVec[i].y)
		self:CalculatePath(beginPoint, curPoint)
		beginPoint = curPoint
	end

    -- 最后加上最终点标志
    local lastX = pathVec[pathSize-1].x*1.5*self.m_mapScale
    local lastY = pathVec[pathSize-1].y*self.m_mapScale
    table.insert(self.m_trailPos, Nuclear.NuclearPoint(lastX, lastY))
    local trailPosCount = table.getn(self.m_trailPos)
    if trailPosCount > 65 then
        trailPosCount = 65
    end
    for j = 1,  trailPosCount do
		local curPos = self.m_trailPos[j]
		-- 创建表示路径的静态图片
		local trail_si = self.m_pathIcons[j]
        trail_si:setVisible(true)
		trail_si:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, curPos.x-self.trailImageWidth*0.5), CEGUI.UDim(0.0, curPos.y-self.trailImageHeight*0.5)))
		table.insert(self.m_trail_si,trail_si)
	end

	if self.end_si then
        self.end_si:setVisible(true)
		self.end_si:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, lastX-self.endImageWidth*0.5), CEGUI.UDim(0.0, lastY-self.endImageHeight*0.85)))
    end

	table.insert(self.m_trail_si,self.end_si)

    local dlg = require "logic.npc.npcdialog".getInstanceNotCreate()

    if dlg then dlg.DestroyDialog() end
end

-- 计算局部的目标点
function SmallMapDlg:CalculatePath(beginPoint, endPoint)
	local step = self.m_step/self.m_mapScale
	local subY = endPoint.y-beginPoint.y
	local subX = endPoint.x-beginPoint.x
	local dist = math.sqrt(subY*subY+subX*subX)
	local stepCount = math.floor(dist/step)
	local xPos = beginPoint.x
	local yPos = beginPoint.y
	for i =1, stepCount do
		table.insert(self.m_trailPos, Nuclear.NuclearPoint(xPos*self.m_mapScale, yPos*self.m_mapScale))
		xPos = xPos + subX/stepCount
		yPos = yPos + subY/stepCount
	end
    
end

function SmallMapDlg:HandleCloseBtnClick(args)
if _instance.cc_AnimationInstance1 then 
           _instance.cc_AnimationInstance1:stop()
           _instance.cc_AnimationInstance1 = nil 
        end
	    if _instance.cc_AnimationInstance2 then 
           _instance.cc_AnimationInstance2:stop()
           _instance.cc_AnimationInstance2 = nil 
        end

	self:DestroyDialog()
	return true
end

function SmallMapDlg:HandleSwitchBtnClick(args)
if _instance.cc_AnimationInstance1 then 
           _instance.cc_AnimationInstance1:stop()
           _instance.cc_AnimationInstance1 = nil 
        end
	    if _instance.cc_AnimationInstance2 then 
           _instance.cc_AnimationInstance2:stop()
           _instance.cc_AnimationInstance2 = nil 
        end
	self:DestroyDialog()
	WorldMapdlg.GetSingletonDialogAndShowIt()
end

function SmallMapDlg:HandleSearchBtnClick(args)
	local ifVisible = self.m_npcFrame:isVisible()
	self.m_npcFrame:setVisible(not ifVisible)
	if self.m_npcFrame:isVisible() == false then
		return 
	end
	local winMgr = CEGUI.WindowManager:getSingleton()
	-- 设置框的高度
	local frameHeight = 120*3.8
	if frameHeight > self.m_smallMapHeight then
		frameHeight = self.m_smallMapHeight
	end
	
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen2 = aniMan:getAnimation("huadongc1") 
    self.cc_AnimationInstance2 = aniMan:instantiateAnimation(animationOpen2) 
    self.cc_AnimationInstance2:setTargetWindow(self.m_npcFrame)
    self.cc_AnimationInstance2:start()
	
	self.m_npcFrame:setHeight(CEGUI.UDim(0,frameHeight))
	self.m_npcList_sp:setHeight(CEGUI.UDim(0,frameHeight-20.0))	
	
	if table.maxn(self.m_menuCells) > 0 then
		return 
	end
	-- 加载所有的NPC
	local npcCount = table.maxn(self.m_lNpcList)
	local cellHeight = 0
	for i = 0, npcCount-1 do
		local npcBaseID = self.m_lNpcList[i+1].npcID
		local namePrefix = tostring(npcBaseID)..i
		print("in SmallMapDlg namePrefix: 	"..tostring(npcBaseID))
		local cellWnd = winMgr:loadWindowLayout("xiaoditucell_mtg.layout", namePrefix)
		self.m_npcList_sp:addChildWindow(cellWnd)
		table.insert(self.m_menuCells, cellWnd)

		-- 加上点击事件
		local npcItemWnd = CEGUI.toPushButton(winMgr:getWindow(namePrefix.."xiaoditucell_mtg"))
		npcItemWnd:setID(npcBaseID)
		npcItemWnd:subscribeEvent("Clicked", SmallMapDlg.HandleItemClick, self)
		npcItemWnd:EnableClickAni(false)
		-- CELL的大小与横向，竖向间隔
		cellHeight = cellWnd:getPixelSize().height
		local cellWidth = cellWnd:getPixelSize().width
		local yDistance = 0.0
		local yPos = -0.01 + (cellHeight+yDistance)*i
		local xPos = 0.01
		
		LogInfo("i, xPos, yPos: "..tostring(i).." "..tostring(xPos).." "..tostring(yPos))
		cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))

		-- 获得造型ID
		local npcConfig =BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(npcBaseID)
		local shapeID = npcConfig and npcConfig.modelID or nil
		--获取NPC对象
		local npc = gGetScene():FindNpcByBaseID(npcBaseID)
		if npc then
			shapeID = npc:GetShapeID()
		end

        if shapeID then
		    local shapeRecord = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeID)
		
		    local item_cell = CEGUI.toItemCell(winMgr:getWindow(namePrefix.."xiaoditucell_mtg/"))
		    item_cell:SetImage(gGetIconManager():GetImageByID(shapeRecord.littleheadID))
		    item_cell:setClippedByParent(true)
		    item_cell:setMousePassThroughEnabled(true)
		    -- NPC名字
		    local npcTmp = BeanConfigManager.getInstance():GetTableByName("npc.cnpcinfo"):getRecorder(npcBaseID)
		    local item_st = winMgr:getWindow(namePrefix.."xiaoditucell_mtg/name")
		    item_st:setText(npcTmp.name)
		    item_st:setClippedByParent(true)
		    item_st:setMousePassThroughEnabled(true)
        end
	end
end



function SmallMapDlg:HandleItemClick(args)

	self:DestroyDialog()
	local event = CEGUI.toWindowEventArgs(args)
	local npcBaseID = event.window:getID()
	local npc = gGetScene():FindNpcByBaseID(npcBaseID)
	-- 如果NPC还未被推送到客户端
	if not npc then
		for _, npcInfo in ipairs(self.m_lNpcList) do
			if npcBaseID == npcInfo.npcID then
				local flyWalkData = {}
				require("logic.task.taskhelpergoto").GetInitedFlyWalkData(flyWalkData)
				
				flyWalkData.nNpcId = npcBaseID
				local xPos = npcInfo.xpos/16
				flyWalkData.nTargetPosX = xPos
				local yPos = npcInfo.ypos/16
				flyWalkData.nTargetPosY = yPos
				require("logic.task.taskhelpergoto").FlyOrWalkTo(flyWalkData)
				return
			end
		end
	end
		
 	gGetScene():ResetMouseOverObjectsListWithNpcBaseID(npcBaseID)
	GetMainCharacter():TalkCursorOperateWithNpcBaseID(npcBaseID)

    local dlg = require "logic.npc.npcdialog".getInstanceNotCreate()
    if dlg then dlg.DestroyDialog() end
end

function SmallMapDlg:LoadImage()

end

function SmallMapDlg.Draw()
	local localInstance = SmallMapDlg.getInstanceNotCreate() 
	if not localInstance then
		return false
	end
	
	if localInstance.m_smallMapHandle then
		local picRect = localInstance.m_mapRect
		local picHandle = localInstance.m_smallMapHandle
		Nuclear.GetEngine():GetRenderer():DrawPicture(picHandle, picRect.left, picRect.top, picRect.right, picRect.bottom)

	end

	return true
	
end

function SmallMapDlg:HandleWindowUpdate(args)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local worldPos = GetMainCharacter():GetLocation()
	local roleX = worldPos.x*self.m_mapScale
	local roleY = worldPos.y*self.m_mapScale
	self.m_roleEffectWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, roleX - self.m_roleEffectWnd:getPixelSize().width / 2), 
                                                    CEGUI.UDim(0.0, roleY -  self.m_roleEffectWnd:getPixelSize().height / 2)))

    local siCount =  table.getn(self.m_trail_si)
    if siCount > 0 and self.m_trail_si[siCount-1]:isVisible() == false then
        self.tickCount = self.tickCount + 1
        if self.tickCount >= 7 then
            self.tickCount = 0
            self.m_trail_si[siCount]:setVisible(false)
        end
    end

	-- 隐藏经过的路标点
    local trailCount = table.getn(self.m_trailPos)
    if trailCount > 65 then
        trailCount = 65
    end
	for i = 1, trailCount do
		local trailPos = self.m_trailPos[i]
		local dist= math.sqrt((roleX-trailPos.x)*(roleX-trailPos.x)+(roleY-trailPos.y)*(roleY-trailPos.y))
		if dist < self.m_step then
			self.m_trail_si[i]:setVisible(false)
		end
	end



end

function SmallMapDlg.DrawMainRole()
		
end


return SmallMapDlg
