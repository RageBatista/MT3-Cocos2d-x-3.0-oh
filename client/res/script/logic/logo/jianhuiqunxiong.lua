------------------------------------------------------------------
-- 剑会群雄
------------------------------------------------------------------

require "logic.dialog"



jianhuiqunxiong = {}
setmetatable(jianhuiqunxiong, Dialog)
jianhuiqunxiong.__index = jianhuiqunxiong

local _instance
function jianhuiqunxiong.getInstance()
	if not _instance then
		_instance = jianhuiqunxiong:new()
		_instance:OnCreate()
	end
	return _instance
end

function jianhuiqunxiong.getInstanceAndShow()
	if not _instance then
		_instance = jianhuiqunxiong:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jianhuiqunxiong.getInstanceOrNot()
	return _instance
end

function jianhuiqunxiong.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jianhuiqunxiong:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function jianhuiqunxiong.ToggleOpenClose()
	if not _instance then
		_instance = jianhuiqunxiong:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jianhuiqunxiong.GetLayoutFileName()

	return "jianhuiqunxiong.layout"
end

function jianhuiqunxiong:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jianhuiqunxiong)
	return self
end

function jianhuiqunxiong:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	
	--关闭按钮
	self.close = winMgr:getWindow("jianhuiqunxiong/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)
	
	self.items = { --5个道具 仅作显示用  杂货表等  只要是道具的id  就可以
	340010,
	560011,
	254010,
	259201,
	710006
	}
	self.txt1 = "  "




	self.tishiTxt = winMgr:getWindow("jianhuiqunxiong/di/txt")
	self.tishiTxt:setText(self.txt1)
	
	
	self.m_listCell = {}

	    for i = 1, 5 do
		    local cell = CEGUI.toItemCell(winMgr:getWindow("jianhuiqunxiong/itemBox/item" .. i ))
		    cell:setID( i )
			cell:SetBackGroundImage("my_qng", "18")
			local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.items[i])
            if itembean then
				cell:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))

			end
			
		    cell:subscribeEvent("MouseClick",jianhuiqunxiong.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

	    end
	

	
	self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("jianhuiqunxiong/btn1"))
	self.m_btnCharge:subscribeEvent("Clicked",jianhuiqunxiong.HandleBtnChargeClicked,self)
	

	
	--特效
	self.bgtx = winMgr:getWindow("jianhuiqunxiong/tx")
	local bgtxANi = gGetGameUIManager():AddUIEffect(self.bgtx, "spine/my_spine/my_jhqx", true) --�ϳ���Ч ����
	bgtxANi:SetDefaultActName("stand1")
	bgtxANi:SetScale(1)
	
	

end







 function jianhuiqunxiong:HandleItemClicked(args)

	
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = self.items[e.window:getID()]--e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position

    -- local nIndex = e.window.nIndex
    -- local nComeFromItemId = self.items[nIndex]
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal--eComeFrom
	--nType = Commontipdlg.eType.eNormal 

	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    --commontipdlg.nComeFromItemId = nComeFromItemId
	
end




function jianhuiqunxiong:HandleBtnChargeClicked(e) --立刻进入

	GetCTipsManager():AddMessageTip("当前服务器大区暂不满足开启剑会条件，等待客服通知开启。")



end


return jianhuiqunxiong