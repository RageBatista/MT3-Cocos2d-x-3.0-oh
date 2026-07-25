ShouJiGuanLianJiangLi = {}
ShouJiGuanLianJiangLi.__index = ShouJiGuanLianJiangLi

local _instance

function ShouJiGuanLianJiangLi.create()
    if not _instance then
		_instance = ShouJiGuanLianJiangLi:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiGuanLianJiangLi.getInstance()
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceAndShow()
    if not jlDlg then
        return nil
    end 
    local dlg = jlDlg:showSysId(Jianglinew.systemId.PhoneBind)
	return dlg
end

function ShouJiGuanLianJiangLi.getInstanceAndShow()
	return ShouJiGuanLianJiangLi.getInstance()
end

function ShouJiGuanLianJiangLi.getInstanceNotCreate()
	return _instance
end

function ShouJiGuanLianJiangLi:remove()
    self:clearData()
    _instance = nil
end

function ShouJiGuanLianJiangLi:clearData()
end

function ShouJiGuanLianJiangLi.DestroyDialog()
_instance.m_btnGot.animation:stop()--停止
_instance.m_btnJump.animation:stop()--停止
    require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
end

function ShouJiGuanLianJiangLi:new()
	local self = {}
	setmetatable(self, ShouJiGuanLianJiangLi)
	return self
end
function ShouJiGuanLianJiangLi:addButtonAnimation(button, animationName)
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

function ShouJiGuanLianJiangLi:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()

	local layoutName = "shoujiguanlianjiangli.layout"
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)

    self.m_text12 = winMgr:getWindow("shoujiguanlianjiangli/text12")
    self.m_text_free = winMgr:getWindow("shoujiguanlianjiangli/text3")
    self.m_text_pointcard = winMgr:getWindow("shoujiguanlianjiangli/text32")
    self.m_text_award = winMgr:getWindow("shoujiguanlianjiangli/text31")

    self.m_itemCell = CEGUI.toItemCell(winMgr:getWindow("shoujiguanlianjiangli/item"))
    self.m_itemCell:subscribeEvent("MouseClick",ShouJiGuanLianJiangLi.HandleItemClicked,self)
    self.m_itemBean = nil

	self.m_btnJump = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlianjiangli/btn1"))
	self:addButtonAnimation(self.m_btnJump, "studyBtnPress")
    self.m_btnJump:subscribeEvent("Clicked", ShouJiGuanLianJiangLi.OnJumpBtnClicked, self)

	self.m_btnGot = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlianjiangli/btn11"))
	self:addButtonAnimation(self.m_btnGot, "studyBtnPress")
    self.m_btnGot:subscribeEvent("Clicked", ShouJiGuanLianJiangLi.OnGotBtnClicked, self)

    self:initItem()
    self:refreshUI()
end

function ShouJiGuanLianJiangLi:refreshUI()
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.canGetAward() then
        self.m_text12:setVisible(false)
        self.m_text_free:setVisible(false)
        self.m_text_pointcard:setVisible(false)
        self.m_text_award:setVisible(true)
        self.m_btnGot:setVisible(true)
        self.m_btnJump:setVisible(false)
    else
        self.m_text12:setVisible(true)
        if IsPointCardServer() then
            self.m_text_free:setVisible(false)
            self.m_text_pointcard:setVisible(true)
        else
            self.m_text_free:setVisible(true)
            self.m_text_pointcard:setVisible(false)
        end
        self.m_text_award:setVisible(false)
        self.m_btnGot:setVisible(false)
        self.m_btnJump:setVisible(true)
    end
end

function ShouJiGuanLianJiangLi:initItem()
    local tableName = ""
    if IsPointCardServer() then
        tableName = "game.cpointcardbindtelaward"
    else
        tableName = "game.cbindtelaward"
    end
    local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(1)
    if record then
        local cShapeId = gGetDataManager():GetMainCharacterCreateShape()
        local itemid = record.itemid[cShapeId-1]
        local itemnum = record.itemnum[cShapeId-1]
		self.m_itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
        if self.m_itemBean then
            self.m_itemCell:SetImage(gGetIconManager():GetItemIconByID(self.m_itemBean.icon))
            if itemnum > 1 then
                self.m_itemCell:SetTextUnitText(CEGUI.String(tostring(itemnum)))
            end
            SetItemCellBoundColorByQulityItemWithIdtm(self.m_itemCell, self.m_itemBean.id)
            SetItemCellBoundColorByQulityItemtm(self.m_itemCell, self.m_itemBean.nquality, self.m_itemBean.itemtypeid)
        end
    end
end

function ShouJiGuanLianJiangLi:HandleItemClicked(args)
	if not self.m_itemBean then
        return true
    end
    
    local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	if self.m_itemBean.itemtypeid ~= 166 then
	    require ("logic.tips.commontipdlg").getInstanceAndShow():RefreshItem(Commontipdlg.eType.eNormal, self.m_itemBean.id, nPosX, nPosY)
	end
	
	return true
end

function ShouJiGuanLianJiangLi:OnJumpBtnClicked()
    require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
end

function ShouJiGuanLianJiangLi:OnGotBtnClicked()
    local p = require("protodef.fire.pb.cgetbindtelaward"):new()
    LuaProtocolManager:send(p)
end

return ShouJiGuanLianJiangLi
