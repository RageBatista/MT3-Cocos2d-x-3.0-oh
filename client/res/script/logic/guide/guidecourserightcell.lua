require "logic.dialog"

--成就列表
GuideCourseRightCell = {}
setmetatable(GuideCourseRightCell, Dialog)
GuideCourseRightCell.__index = GuideCourseRightCell

local prefix = 0
local _instance
function GuideCourseRightCell.getInstance()
	if not _instance then
		_instance = GuideCourseRightCell:new()
		_instance:OnCreate()
	end
	return _instance
end

function GuideCourseRightCell.getInstanceAndShow()
	if not _instance then
		_instance = GuideCourseRightCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function GuideCourseRightCell.getInstanceNotCreate()
	return _instance
end

function GuideCourseRightCell.DestroyDialog()
	if _instance then 
	_instance.m_btnLingqu.animation:stop()
	_instance.m_btnGo.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function GuideCourseRightCell.ToggleOpenClose()
	if not _instance then
		_instance = GuideCourseRightCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function GuideCourseRightCell.CreateNewDlg(parent,id)
	local newDlg = GuideCourseRightCell:new()
	newDlg:OnCreate(parent,id)
	return newDlg
end

function GuideCourseRightCell.GetLayoutFileName()
	return "zhiyinlichengcell2.layout"
end

function GuideCourseRightCell:addButtonAnimation(button, animationName)
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

function GuideCourseRightCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GuideCourseRightCell)
	return self
end

function GuideCourseRightCell:OnCreate(parent,id)
    prefix = id
	Dialog.OnCreate(self, parent, prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)
    self.m_image = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/wupin"))
    self.m_name = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/mingzi"))
    self.m_name1 = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/mingzi1")
    self.m_text = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/miaoshu")
    self.m_has = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/yilingqu")
    self.m_btnLingqu = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/anniu1"))
    self.m_btnGo = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/anniu2"))
    self.m_btnLingqu:subscribeEvent("Clicked", self.handleLingquClicked, self)
	self:addButtonAnimation(self.m_btnLingqu, "studyBtnPress")
    self.m_btnGo:subscribeEvent("Clicked", self.handleGoBtnClicked, self)
	self:addButtonAnimation(self.m_btnGo, "studyBtnPress")
    self.m_name:getVertScrollbar():EnbalePanGuesture(false);
    self.m_imageMask = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/biaoqian")
    self.m_items = {}
    self.m_items[1] = {}
    self.m_items[1].icon = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Icon1")
    self.m_items[1].text = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Text1")
    self.m_items[2] = {}
    self.m_items[2].icon = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Icon2")
    self.m_items[2].text = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Text2")
    self.m_items[3] = {}
    self.m_items[3].icon = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Icon3")
    self.m_items[3].text = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Text3")
    self.m_items[4] = {}
    self.m_items[4].icon = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Icon4")
    self.m_items[4].text = winMgr:getWindow(prefixstr .. "zhiyinlichengcell2/jiangli_Text4")
    self.index = 0

end
function GuideCourseRightCell:handleLingquClicked(e)
    if self.m_btnLingqu.animation then
        self.m_btnLingqu.animation:stop()  
    end
    local guidemanager = require "logic.guide.guidemanager".getInstance()
	
    if guidemanager.m_CellData[self.index]~=nil then
        local p = require("protodef.fire.pb.mission.cgetarchiveaward"):new()
        p.archiveid = guidemanager.m_CellData[self.index].id
	    LuaProtocolManager:send(p)
    end
end
function GuideCourseRightCell:handleGoBtnClicked(e)
--1，打开界面
--2，找NPC
--3，继续主线任务（根据主线不同变化）
--4，找职业NPC（不同职业不同NPC）
--5，公会。判断是否加入公会？
--             是，打开公会聊天频道
--             否，打开申请公会界面
--6，领取任务

    local guidemanager = require "logic.guide.guidemanager".getInstance()
    if guidemanager.m_CellData[self.index]~=nil then
        local data = gGetDataManager():GetMainCharacterData()
	    local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
        local enter = guidemanager.m_CellData[self.index].enter
        if enter == 1 then
            require("logic.openui").OpenUI(guidemanager.m_CellData[self.index].enterlink)
            if guidemanager.m_CellData[self.index].enterlink == 44 then
                CChatOutputDialog:getInstance():ChangeOutChannel(5)
                CChatOutputDialog:getInstance():RefreshOpenedDlgChannel()
                local label = require "logic.guide.guidelabel"
                label.hide()
            end
        elseif enter == 2 then
            TaskHelper.gotoNpc(guidemanager.m_CellData[self.index].enterlink)
            local label = require "logic.guide.guidelabel"
	        label.hide()
        elseif enter == 3 then
            Taskhelperscenario.OnClickCellGoto_Scenario(GetTaskManager():GetMainScenarioQuestId())
            local label = require "logic.guide.guidelabel"
	        label.hide()
        elseif enter == 4 then
            local schoolID = gGetDataManager():GetMainCharacterSchoolID()
		    local schoolRecord = BeanConfigManager.getInstance():GetTableByName("role.schoolmasterskillinfo"):getRecorder(schoolID)
		    if schoolRecord == nil then
			    return false
		    end
		    TaskHelper.gotoNpc(schoolRecord.masterid)
            local label = require "logic.guide.guidelabel"
	        label.hide()
        elseif enter == 5 then
            local datamanager = require "logic.faction.factiondatamanager"
            if datamanager:IsHasFaction() then
                require("logic.openui").OpenUI(44)
                CChatOutputDialog:getInstance():ChangeOutChannel(4)
                CChatOutputDialog:getInstance():RefreshOpenedDlgChannel()
                local label = require "logic.guide.guidelabel"
                label.hide()
            else
                if require "logic.xingongnengkaiqi.xingongnengopendlg".checkFeatureOpened(5) then
                    Familyjiarudialog.getInstanceAndShow()
                else
                    local msg = require "utils.mhsdutils".get_msgtipstring(145390)
		            GetCTipsManager():AddMessageTip(msg)                   
                end
            end
        elseif enter == 6 then
            NpcServiceManager.SendNpcService(0, guidemanager.m_CellData[self.index].enterlink)
            local label = require "logic.guide.guidelabel"
	        label.hide()
        end

    end
end
function GuideCourseRightCell:setData(id)
    self.index = id
    local guidemanager = require "logic.guide.guidemanager".getInstance()
    if guidemanager.m_CellData[id]~=nil then
        local iconManager = gGetIconManager()
		self.m_image:SetImage(iconManager:GetItemIconByID(guidemanager.m_CellData[id].image))
        if guidemanager.m_CellData[id].style == 0 then
            self.m_image:SetStyle(CEGUI.ItemCellStyle_IconInside)
        else
            self.m_image:SetStyle(CEGUI.ItemCellStyle_IconExtend)
        end
        self.m_name:Clear()
		self.m_name:AppendParseText(CEGUI.String(guidemanager.m_CellData[id].name))
		self.m_name:Refresh()       
        self.m_name1:setText(tostring(guidemanager.m_CellData[id].enterlevel))


        self.m_text:setText(guidemanager.m_CellData[id].info)
		local data = gGetDataManager():GetMainCharacterData()
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
        if guidemanager.m_CellStatus[guidemanager.m_CellData[id].id] == 0 then
            self.m_btnGo:setVisible(true)
            self.m_btnLingqu:setVisible(false)
            self.m_has:setVisible(false)
            self.m_imageMask:setVisible(false)
        elseif guidemanager.m_CellStatus[guidemanager.m_CellData[id].id] == 1 then
            self.m_imageMask:setVisible(true)
            self.m_imageMask:setProperty("Image","set:shopui image:yiwancheng")
            self.m_btnGo:setVisible(false)
            self.m_btnLingqu:setVisible(true)
            self.m_has:setVisible(false)
            if guidemanager.m_CellData[id].id == guidemanager.m_Effectid then
                 NewRoleGuideManager.getInstance():AddParticalEffect(self.m_btnLingqu)
            else
                gGetGameUIManager():RemoveUIEffect(self.m_btnLingqu)
            end
           
        else
            self.m_imageMask:setVisible(true)
            self.m_imageMask:setProperty("Image","set:shopui image:yiwancheng")
            self.m_btnGo:setVisible(false)
            self.m_btnLingqu:setVisible(false)
            self.m_has:setVisible(true)
            self.m_has:setEnabled(false)
        end

        --
        local xPos = 0
        if #self.m_items > 0 then
            xPos = self.m_items[1].icon:getXPosition()
        end
        local index = 1
        for i=0, #guidemanager.m_CellData[id].itemicons do
            local icon = guidemanager.m_CellData[id].itemicons[i]
            local text = guidemanager.m_CellData[id].itemtexts[i]
            if icon > 0 and index<=#self.m_items then
                self.m_items[index].icon:setVisible(true)
                local iconPath = iconManager:GetItemIconPathByID(icon)
                self.m_items[index].icon:setProperty("Image", iconPath:c_str())
                self.m_items[index].icon:setXPosition(xPos)
                xPos = xPos + self.m_items[index].icon:getWidth()

                self.m_items[index].text:setVisible(true)
                self.m_items[index].text:setText(text)
                self.m_items[index].text:setXPosition(xPos)
                local width=self.m_items[index].text:getProperty("HorzExtent") + 20
                xPos.offset = xPos.offset + tonumber(width)
                self.m_items[index].text:setWidth(CEGUI.UDim(0,tonumber(width)))
                index = index + 1
            end
        end
        for j=index,#self.m_items do
            self.m_items[j].icon:setVisible(false)
            self.m_items[j].text:setVisible(false)
        end
    end
    
end
return GuideCourseRightCell
