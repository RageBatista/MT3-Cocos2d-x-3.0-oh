QiandaosongliCell = {}

setmetatable(QiandaosongliCell, Dialog)
QiandaosongliCell.__index = QiandaosongliCell
local prefix = 0

function QiandaosongliCell.CreateNewDlg(parent)
	local newDlg = QiandaosongliCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end


function QiandaosongliCell.GetLayoutFileName()
	return "qiandaosonglicell.layout"
end


function QiandaosongliCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, QiandaosongliCell)
	return self
end

function QiandaosongliCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_bg = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "qiandaosonglicell/back"))
	self.m_bg:subscribeEvent("MouseButtonUp", self.HandleItemClicked, self)
	self.m_itemcellReward = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "qiandaosonglicell/back/item"))
	self.m_itemcellReward:subscribeEvent("MouseButtonUp", self.HandleOnlyItemClicked, self)
	self.m_effectReward = winMgr:getWindow(prefixstr .. "qiandaosonglicell/back/effect")
	self.m_imgGot = winMgr:getWindow(prefixstr .. "qiandaosonglicell/up")
    self.m_Buqian = winMgr:getWindow(prefixstr.."qiandaosonglicell/back/buqian")
	self.m_width = self:GetWindow():getPixelSize().width
	self.m_height = self:GetWindow():getPixelSize().height
	self.m_Day = winMgr:getWindow(prefixstr .. "qiandaosonglicell/back/tianshu")
    self.m_bgImg = winMgr:getWindow(prefixstr .. "qiandaosonglicell/back")
	self.m_dateID = 0
	self.m_flag = -1
	self.m_parentTimes = 0

end

function QiandaosongliCell:SetBuqian( bln )
    self.m_Buqian:setVisible(bln)
end

function QiandaosongliCell:SetID( id )
	self.m_dateID =  id		
end

function QiandaosongliCell:SetFlag( flag )
	self.m_flag = flag
end

function QiandaosongliCell:SetTimes( times )
	self.m_parentTimes = times	
end	

function QiandaosongliCell:GetRecord( id )
	local tb = BeanConfigManager.getInstance():GetTableByName("game.cqiandaojiangli")
	if tb then
		return (tb:getRecorder(id))
	end
	return nil
end

function QiandaosongliCell:RefreshShow( )
	
	local cfg = self:GetRecord(self.m_dateID)
	if not cfg then
		self:GetWindow():setVisible(false)
	else
		self:GetWindow():setVisible(true)
		
		gGetGameUIManager():RemoveUIEffect(self.m_effectReward)
		gGetGameUIManager():RemoveUIEffect(self.m_itemcellReward)

        if self.m_dateID % 100 % 5 == 2 or self.m_dateID % 100 % 5 == 0 then
            self.m_bgImg:setProperty("Image",  "set:cc2542 image:r1")
        else
            self.m_bgImg:setProperty("Image",  "set:cc2542 image:r1")
        end

		self.m_imgGot:setVisible(self.m_dateID%100 <= self.m_parentTimes)

		self.m_Day:setText(self.m_dateID%100 .. MHSD_UTILS.get_resstring(317))
		local itemAttrCfg = nil
		local itemID = 0
		if cfg.itemid == 0 then
			local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(cfg.mtype)
			local set,img = string.match(conf.iconpath, "set:(.*) image:(.*)")
			self.m_itemcellReward:SetImage( set, img  )
		else
			itemID = cfg.itemid
			itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
            if itemAttrCfg then
			    self.m_itemcellReward:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
                SetItemCellBoundColorByQulityItemWithId(self.m_itemcellReward,itemAttrCfg.id)
            end
		end
		local mm = cfg.borderpic

		local num = 0
		
		if cfg.itemid ~= 0  then
			num = cfg.itemnum
		end
		
		if cfg.mtype ~= 0 then
			num = cfg.money
		end

		if num == 1 then
			self.m_itemcellReward:SetTextUnitText(CEGUI.String(""))
		else
			self.m_itemcellReward:SetTextUnitText(CEGUI.String(""..num))
		end

		if self.m_flag == 0 and self.m_dateID%100 == self.m_parentTimes + 1 then
            NewRoleGuideManager.getInstance():AddParticalEffect(self.m_effectReward, 11076)
		end
-----------------------------------------------------------------------------------------------------
	end
	
end	

function QiandaosongliCell:HandleItemClicked(args)
	
	local parentDlg = QiandaosongliDlg.getInstanceNotCreate()	
	local cellid = self.m_dateID
	if self.m_dateID%100 <= 31  then
		if  self.m_flag == 0 then
			if  self.m_dateID % 100 == self.m_parentTimes + 1 then
				local p = require "protodef.fire.pb.activity.reg.creg":new()
				p.month = self.m_dateID/100
				require "manager.luaprotocolmanager":send(p)
			end
		elseif self.m_flag == -1 and self.m_dateID % 100 == self.m_parentTimes + 1 then	
            local nCansuppregtime = parentDlg.m_cansuppregtimes
            if parentDlg.m_nFillTimes <= parentDlg.m_cansuppregtimes then
                nCansuppregtime = parentDlg.m_nFillTimes
            end
			if nCansuppregtime > 0 then
			    local p = require "protodef.fire.pb.activity.reg.creg":new()
			    p.month = self.m_dateID/100
			    require "manager.luaprotocolmanager":send(p)
		    end
		end
	end
end

function QiandaosongliCell:HandleOnlyItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local parentDlg = QiandaosongliDlg.getInstanceNotCreate()
    local nCansuppregtime = parentDlg.m_cansuppregtimes
    if parentDlg.m_nFillTimes <= parentDlg.m_cansuppregtimes then
        nCansuppregtime = parentDlg.m_nFillTimes
    end
	if  not ( (self.m_flag == 0 and self.m_dateID % 100 == self.m_parentTimes + 1)
		or ( self.m_flag == -1 and self.m_dateID % 100 == self.m_parentTimes + 1
				 and nCansuppregtime > 0)				
		)  then
		local Commontipdlg = require "logic.tips.commontipdlg"
		local commontipdlg = Commontipdlg.getInstanceAndShow()
		local nType = Commontipdlg.eType.eSignIn
		local nItemId = self.m_dateID
		local scrollpos = parentDlg:GetWindow():getPosition()
		commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)		
	end
	
	
	local cellid = self.m_dateID
	if self.m_dateID%100 <= 31  then
		if  self.m_flag == 0 then
			if  self.m_dateID % 100 == self.m_parentTimes + 1 then
				local p = require "protodef.fire.pb.activity.reg.creg":new()
				p.month = self.m_dateID/100
				require "manager.luaprotocolmanager":send(p)
			end
		elseif self.m_flag == -1 and self.m_dateID % 100 == self.m_parentTimes + 1 then	
			 if parentDlg.m_nFillTimes > 0 then
				local p = require "protodef.fire.pb.activity.reg.creg":new()
				p.month = self.m_dateID/100
				require "manager.luaprotocolmanager":send(p)
			end						
		end
	end	
end

return QiandaosongliCell
