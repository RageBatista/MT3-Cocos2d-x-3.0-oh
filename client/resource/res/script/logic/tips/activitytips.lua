require "logic.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
ActivityTips = {}
setmetatable(ActivityTips, Dialog)
ActivityTips.__index = ActivityTips

--»î¶¯tips  wjf

local _instance
function ActivityTips.getInstance()
	if not _instance then
		_instance = ActivityTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function ActivityTips.getInstanceAndShow()
	
	if not _instance then
		_instance = ActivityTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ActivityTips.getInstanceNotCreate()
	return _instance
end

function ActivityTips.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ActivityTips.ToggleOpenClose()
	if not _instance then
		_instance = ActivityTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ActivityTips.GetLayoutFileName()
	return "huodongtips.layout"
end

function ActivityTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ActivityTips)
	return self
end



function ActivityTips:OnCreate()
	LogInfo("enter ActivityTips OnCreate")
	self.prefix = "commontipdlg"
	Dialog.OnCreate(self,nil,self.prefix)
	local prefix = self.prefix
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_MainFrame = winMgr:getWindow(prefix.."huodongtips")
	self.m_txtName = winMgr:getWindow(prefix.."huodongtips/huodongmingzi")
	self.m_txtNumTip = winMgr:getWindow(prefix.."huodongtips/cishu")
	self.m_txtNum = winMgr:getWindow(prefix.."huodongtips/cishuzhi")
	self.m_txtTime = winMgr:getWindow(prefix.."huodongtips/wenben2")
	self.m_txtType = winMgr:getWindow(prefix.."huodongtips/wenben4")
	self.m_txtLevel = winMgr:getWindow(prefix.."huodongtips/wenben6")
	self.m_txtText = CEGUI.toRichEditbox(winMgr:getWindow(prefix.."huodongtips/wenben8"))
	self.m_txtActTip = winMgr:getWindow(prefix.."huodongtips/wenben9")
	self.m_txtAct = winMgr:getWindow(prefix.."huodongtips/wenben10")
	
	self.m_itemIcon = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."huodongtips/tubiao"))
	
	self.m_itemAct1 = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."huodongtips/wupin1"))
	self.m_itemAct1:subscribeEvent("MouseClick",ActivityTips.HandleItemClicked,self)
	self.m_itemAct2 = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."huodongtips/wupin2"))
	self.m_itemAct2:subscribeEvent("MouseClick",ActivityTips.HandleItemClicked,self)
	self.m_itemAct3 = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."huodongtips/wupin3"))
	self.m_itemAct3:subscribeEvent("MouseClick",ActivityTips.HandleItemClicked,self)
	self.m_itemAct4 = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."huodongtips/wupin4"))
	self.m_itemAct4:subscribeEvent("MouseClick",ActivityTips.HandleItemClicked,self)
	self.m_itemAct5 = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."huodongtips/wupin5"))
	self.m_itemAct5:subscribeEvent("MouseClick",ActivityTips.HandleItemClicked,self)
	self.m_MainFrame:subscribeEvent("MouseClick",ActivityTips.HandleCloseClicked,self)

	self.m_id = 0
	
end
	
function ActivityTips:RefreshTips( )
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
	local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(self.m_id)
	self.m_txtName:setText(record.name)

	if record.isshowmaxnum == 0 then 
		local x = self.m_txtNumTip:getPosition().x
		local y = self.m_txtNumTip:getPosition().y
		local pos = CEGUI.UVector2(x,y)
		local x1 = self.m_txtActTip:getPosition().x
		local x2 = self.m_txtAct:getPosition().x
		local pos1 = CEGUI.UVector2(x +(x2 - x1 ) ,y) 	
		self.m_txtNumTip:setVisible(false)
		self.m_txtNum:setVisible(false)
		self.m_txtActTip:setPosition(pos)
		self.m_txtAct:setPosition( pos1 )
	else
		self.m_txtNumTip:setVisible(true)
		self.m_txtNum:setVisible(true)
		if record.maxnum > 0 then
			self.m_txtNum:setText(record.maxnum)
		else
			self.m_txtNum:setText(MHSD_UTILS.get_resstring(11327))
		end
	end 
	
	
	self.m_txtTime:setText(record.timetext)
	self.m_txtType:setText(record.activitylv)
	self.m_txtLevel:setText(record.leveltext)
    self.m_txtText:Clear()
    local Color = "fffff2df"
    local nIndex = string.find(record.text, "<T")
    if nIndex then
        self.m_txtText:AppendParseText(CEGUI.String(record.text))
    else
        self.m_txtText:AppendText(CEGUI.String(record.text), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color)))
    end
    self.m_txtText:Refresh()
    local height = self.m_txtText:GetExtendSize().height
    
    self.m_txtText:setHeight(CEGUI.UDim(0, height + self.m_txtText:getHeight().offset))
    self.m_MainFrame:setHeight(CEGUI.UDim(0, height + self.m_MainFrame:getHeight().offset))
    self.m_txtText:Refresh()
	if record.maxact > 0 then
		self.m_txtAct:setText(record.maxact)
	end
	local iconManager = gGetIconManager()
	self.m_itemIcon:SetImage(iconManager:GetItemIconByID(record.imgid))
    self.m_itemIcon:setID(record.imgid)
	
    if record.getfoodid1 == 0 then
        self.m_itemAct1:setVisible(false)
    else
        local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.getfoodid1)
        if itemAttrCfg1 then
            self.m_itemAct1:SetImage(iconManager:GetItemIconByID(itemAttrCfg1.icon))
        end
        self.m_itemAct1:setID(record.getfoodid1)
        SetItemCellBoundColorByQulityItemWithId(self.m_itemAct1,record.getfoodid1)
    end

    if record.getfoodid2 == 0 then
        self.m_itemAct2:setVisible(false)
    else
        local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.getfoodid2)
        if itemAttrCfg2 then
	        self.m_itemAct2:SetImage(iconManager:GetItemIconByID(itemAttrCfg2.icon))
        end
        self.m_itemAct2:setID(record.getfoodid2)
        SetItemCellBoundColorByQulityItemWithId(self.m_itemAct2,record.getfoodid2)
    end
	
    if record.getfoodid3 == 0 then
        self.m_itemAct3:setVisible(false)
    else
        local itemAttrCfg3 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.getfoodid3)
        if itemAttrCfg3 then
	        self.m_itemAct3:SetImage(iconManager:GetItemIconByID(itemAttrCfg3.icon))
        end
        self.m_itemAct3:setID(record.getfoodid3)
        SetItemCellBoundColorByQulityItemWithId(self.m_itemAct3,record.getfoodid3)
    end

    if record.getfoodid4 == 0 then
        self.m_itemAct4:setVisible(false)
    else
    	local itemAttrCfg4 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.getfoodid4)
        if itemAttrCfg4 then
	        self.m_itemAct4:SetImage(iconManager:GetItemIconByID(itemAttrCfg4.icon))
        end
        self.m_itemAct4:setID(record.getfoodid4)
        SetItemCellBoundColorByQulityItemWithId(self.m_itemAct4,record.getfoodid4)
    end
    if record.getfoodid5 == 0 then
        self.m_itemAct5:setVisible(false)
    else
	    local itemAttrCfg5 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.getfoodid5)
        if itemAttrCfg5 then
	        self.m_itemAct5:SetImage(iconManager:GetItemIconByID(itemAttrCfg5.icon))
        end
        self.m_itemAct5:setID(record.getfoodid5)
        SetItemCellBoundColorByQulityItemWithId(self.m_itemAct5,record.getfoodid5)
    end	
end

function ActivityTips:HandleCloseClicked(args)
    self.DestroyDialog()
end
function ActivityTips:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local index = e.window:getID()
	
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eNormal
	local nItemId = index
	
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
	
	
end
return ActivityTips
