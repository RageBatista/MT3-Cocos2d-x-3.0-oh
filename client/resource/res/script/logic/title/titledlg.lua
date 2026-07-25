require "logic.dialog"
require "logic.title.titlecell"
TitleDlg = {}
setmetatable(TitleDlg, Dialog)
TitleDlg.__index = TitleDlg

local _instance
function TitleDlg.getInstance()
	if not _instance then
		_instance = TitleDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function TitleDlg.getInstanceAndShow()
	if not _instance then
		_instance = TitleDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function TitleDlg.getInstanceNotCreate()
	return _instance
end

function TitleDlg.DestroyDialog()
	if _instance then 
	_instance.m_ok.animation:stop()
        if _instance.tableview then
            _instance.tableview:destroyCells()
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TitleDlg.ToggleOpenClose()
	if not _instance then
		_instance = TitleDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function TitleDlg.GetLayoutFileName()
	return "chengwei_mtg.layout"
end

function TitleDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TitleDlg)
	return self
end

function TitleDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function TitleDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.cc_Title = winMgr:getWindow("chengwei_mtg")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_Title)
    self.animationInstance:start()
	
    self.m_nulltext = winMgr:getWindow("chengwei_mtg/tu")
    self.m_nullhead = winMgr:getWindow("chengwei_mtg/touxiang")
    self.m_textbg = winMgr:getWindow("chengwei_mtg/bg")
    self.m_celltable = winMgr:getWindow("chengwei_mtg/list")
    self.m_ok = CEGUI.toPushButton(winMgr:getWindow("chengwei_mtg/btnqueren"))
    self.m_ok:subscribeEvent("Clicked",TitleDlg.handleOkClicked,self)
	self:addButtonAnimation(self.m_ok, "studyBtnPress")
    self.m_pFrameWindow = CEGUI.toFrameWindow(winMgr:getWindow("chengwei_mtg"))
	self.m_pFrameWindow:getCloseButton():subscribeEvent("Clicked", TitleDlg.handleCancelClicked, self)

    self.m_textmiaoshu= CEGUI.toRichEditbox(winMgr:getWindow("chengwei_mtg/bg/miaoshubox"))
    self.m_texthuoqu= CEGUI.toRichEditbox(winMgr:getWindow("chengwei_mtg/bg/huodebox"))
    self.m_textmiaoshutitle = winMgr:getWindow("chengwei_mtg/bg/miaoshu")
    self.m_texthuoqutitle = winMgr:getWindow("chengwei_mtg/bg/huode")
    self.m_null = winMgr:getWindow("chengwei_mtg/bg1")
    self.m_EndTime = winMgr:getWindow("chengwei_mtg/bg/daoqi")
    self.m_Time = winMgr:getWindow("chengwei_mtg/bg/daoqishijian")
	self.m_cwname = winMgr:getWindow("chengwei_mtg/bg/name")
	self.m_playerName = winMgr:getWindow("chengwei_mtg/bg/playerName")
	self.m_pSpriteBack = CEGUI.toWindow(winMgr:getWindow("chengwei_mtg/spriteBack"))
    

    local shapeId = gGetDataManager():GetMainCharacterShape() 

    local s = self.m_pSpriteBack:getPixelSize() 
    local characterModel = gGetGameUIManager():AddWindowSprite(self.m_pSpriteBack, shapeId, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 48, true)

    local mainCharacter = GetMainCharacter() 
    local weapon = mainCharacter:GetSpriteComponent(eSprite_Weapon)
    local rsA = mainCharacter:GetSpriteComponent(eSprite_DyePartA)
    local rsB = mainCharacter:GetSpriteComponent(eSprite_DyePartB)

    characterModel:SetSpriteComponent(eSprite_Weapon, weapon)
    characterModel:SetDyePartIndex(0, rsA)
    characterModel:SetDyePartIndex(1, rsB)
    self.m_select = 1
    self.m_listTitleID = {}
    self:refreshCell()

end
function TitleDlg.refresh()
    local dlg = require"logic.title.titledlg".getInstanceNotCreate()
    if dlg then
        dlg:refreshCell()
    end
end
function TitleDlg:Update()
    if self.m_select  == 1 then
        self.m_EndTime:setVisible(false)
        self.m_Time:setVisible(false)
        return
    end
    local time = 0
    time = gGetDataManager():getTitleTime(self.m_listTitleID[self.m_select])
    if time == -1 then
        self.m_EndTime:setVisible(false)
        self.m_Time:setVisible(true)
        self.m_Time:setText(MHSD_UTILS.get_resstring(11470))
    else
        self.m_Time:setVisible(true)
        self.m_EndTime:setVisible(true)
        if gGetServerTime() > time or time == 0 then
            --table.remove(self.m_listTitleID, self.m_select)
            self.m_Time:setVisible(true)
            self.m_Time:setText(MHSD_UTILS.get_resstring(11535))
            --self.m_select = 1
            --self:refreshCell()
            return
        end
        local servertime = StringCover.getTimeStruct(gGetServerTime() / 1000)
        local endtiem = StringCover.getTimeStruct(time / 1000)

        if endtiem.tm_year == servertime.tm_year and endtiem.tm_mon == servertime.tm_mon and endtiem.tm_mday  == servertime.tm_mday then
            local actnowAll  = servertime.tm_hour * 3600 + servertime.tm_min * 60 + servertime.tm_sec
            local actEndAll  = endtiem.tm_hour * 3600 + endtiem.tm_min * 60 + endtiem.tm_sec
            local disTime = actEndAll - actnowAll
            --计算倒计时时间
            local hour = math.floor(disTime / 3600)
            local strhour = ""
    
            if hour < 10 then
                strhour = "0"..tostring(hour)
            else
                strhour = tostring(hour)
            end
            local min = math.floor((disTime - hour * 3600) / 60)
            local strmin = ""
            if min < 10 then
                strmin = "0"..tostring(min)
            else
                strmin = tostring(min)
            end
    
            local sec = math.floor((disTime - hour * 3600 -  min * 60))
            local strsec = ""
            if sec < 10 then
                strsec = "0"..tostring(sec)
            else
                strsec = tostring(sec)
            end
            self.m_Time:setText(tostring(strhour..":"..strmin..":"..strsec))
        else
            local yearCur = endtiem.tm_year + 1900
	        local monthCur = endtiem.tm_mon + 1
	        local dayCur = endtiem.tm_mday
            self.m_Time:setText(tostring(yearCur.."-"..monthCur.."-"..dayCur))
        end
    end
end
function TitleDlg:handleCancelClicked(e)
    self.DestroyDialog()
end

function TitleDlg:handleOkClicked(e)
    if self.m_listTitleID[self.m_select] < 0 then
        local offTitleAction = COffTitle.Create()
        LuaProtocolManager.getInstance():send(offTitleAction)
    else
        local onTitleAction = COnTitle.Create()
        onTitleAction.titleid = self.m_listTitleID[self.m_select]
        LuaProtocolManager.getInstance():send(onTitleAction)
    end

    self.DestroyDialog()
end
function TitleDlg:refreshCell()
    if gGetDataManager() then
        local curid = gGetDataManager():GetCurTitleID()     
		if not gGetDataManager():HasTitles() then
            self.m_celltable:setVisible(false)
            self.m_ok:setVisible(false)
            self.m_textbg:setVisible(false)
            self.m_null:setVisible(true)
            self.m_nulltext:setVisible(true)
            self.m_nullhead:setVisible(true)
        else
            self.m_nulltext:setVisible(false)
            self.m_nullhead:setVisible(false)
            self.m_null:setVisible(false)
            self.m_listTitleID = {}
            self.m_listTitleID[1] = -1
            if gGetDataManager() then
                local vecID = gGetDataManager():GetAllTitleID()
                local num = #vecID
                for i=1,num,1 do
                    self.m_listTitleID[#self.m_listTitleID+1] = vecID[i]
                    if curid == vecID[i] then
                        self.m_select = #self.m_listTitleID
                    end
                end
                if not self.tableview then
		            local s = self.m_celltable:getPixelSize()
		            self.tableview = TableView.create(self.m_celltable)
		            self.tableview:setViewSize(s.width, s.height)
		            self.tableview:setPosition(0, 0)
		            self.tableview:setDataSourceFunc(self, TitleDlg.tableViewGetCellAtIndex)
                    self.tableview:setCellCountAndSize(num + 1, 190, 96)
	                self.tableview:reloadData()
                else 
                    self.tableview:clear()
                    self.tableview:setCellCountAndSize(num + 1, 190, 96)
	                self.tableview:reloadData()
	            end
            end
        end
        if self.m_listTitleID[self.m_select] == nil or self.m_listTitleID[self.m_select] < 0 then
        local titleDlg = TitleDlg.getInstanceNotCreate() 
        if titleDlg then
            titleDlg.m_cwname:setText("")  

            titleDlg.m_textmiaoshu:Clear()
            titleDlg.m_textmiaoshu:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11326)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff553923")))
            titleDlg.m_textmiaoshu:Refresh()

            titleDlg.m_texthuoqu:Clear()
            titleDlg.m_texthuoqu:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11326)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff553923")))
            titleDlg.m_texthuoqu:Refresh()
        end
    else
            self.m_textmiaoshu:setVisible(true)
            self.m_texthuoqu:setVisible(true)
            self.m_textmiaoshutitle:setVisible(true)
            self.m_texthuoqutitle:setVisible(true)
            local titleRecord = BeanConfigManager.getInstance():GetTableByName("title.ctitleconfig"):getRecorder(self.m_listTitleID[self.m_select])

           
            local description = titleRecord.description 
            self.m_textmiaoshu:Clear()
            self.m_textmiaoshu:AppendParseText(CEGUI.String(description)) 
            self.m_textmiaoshu:Refresh()

            
            self.m_texthuoqu:Clear()
            self.m_texthuoqu:AppendText(CEGUI.String(titleRecord.gettype),  CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff743a0f")))
            self.m_texthuoqu:Refresh()
        end
		local playerName = gGetDataManager():GetMainCharacterName() 
        local titleDlg = TitleDlg.getInstanceNotCreate()
        if titleDlg then
            titleDlg.m_playerName:setText(playerName) 
        end
    end
end
function TitleDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    idx = idx + 1
	if not cell then
		cell = TitleCell.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("SelectStateChanged", TitleDlg.handleLabelClicked, self)
	end
    cell.window:setID(idx)
    cell.window:setSelected(self.m_select== idx )
    cell:setData(self.m_listTitleID[idx])
	return cell
end
function TitleDlg:handleLabelClicked(e)
    local idx = CEGUI.toWindowEventArgs(e).window:getID()
    self.m_select = idx

    if self.m_listTitleID[self.m_select] < 0 then
        local titleDlg = TitleDlg.getInstanceNotCreate()
        if titleDlg then
            titleDlg.m_cwname:setText("")

            titleDlg.m_textmiaoshu:Clear()
            titleDlg.m_textmiaoshu:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11326)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff553923")))
            titleDlg.m_textmiaoshu:Refresh()

            titleDlg.m_texthuoqu:Clear()
            titleDlg.m_texthuoqu:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11326)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff553923")))
            titleDlg.m_texthuoqu:Refresh()
        end
    else

        self.m_textmiaoshu:setVisible(true)
        self.m_texthuoqu:setVisible(true)
        self.m_textmiaoshutitle:setVisible(true)
        self.m_texthuoqutitle:setVisible(true)

        local titleDlg = TitleDlg.getInstanceNotCreate()  
        if titleDlg then
            
            local titleRecord = BeanConfigManager.getInstance():GetTableByName("title.ctitleconfig"):getRecorder(self.m_listTitleID[self.m_select])
            local titleName = titleRecord.titlename  
            titleDlg.m_cwname:setText(titleName) 

            titleDlg.m_textmiaoshu:Clear()
            titleDlg.m_textmiaoshu:AppendParseText(CEGUI.String(titleRecord.description))
            titleDlg.m_textmiaoshu:Refresh()

            titleDlg.m_texthuoqu:Clear()
            titleDlg.m_texthuoqu:AppendText(CEGUI.String(titleRecord.gettype),  CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff553923")))
            titleDlg.m_texthuoqu:Refresh()
        end 
    end
	local playerName = gGetDataManager():GetMainCharacterName()
    local titleDlg = TitleDlg.getInstanceNotCreate()
    if titleDlg then
        titleDlg.m_playerName:setText(playerName)
    end
end

return TitleDlg
