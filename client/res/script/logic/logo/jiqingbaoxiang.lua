------------------------------------------------------------------
-- 激情宝箱
------------------------------------------------------------------

require "logic.dialog"



jiqingbaoxiang = {}
setmetatable(jiqingbaoxiang, Dialog)
jiqingbaoxiang.__index = jiqingbaoxiang

local _instance
function jiqingbaoxiang.getInstance()
	if not _instance then
		_instance = jiqingbaoxiang:new()
		_instance:OnCreate()
	end
	return _instance
end

function jiqingbaoxiang.getInstanceAndShow()
	if not _instance then
		_instance = jiqingbaoxiang:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jiqingbaoxiang.getInstanceOrNot()
	return _instance
end

function jiqingbaoxiang.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jiqingbaoxiang:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function jiqingbaoxiang.ToggleOpenClose()
	if not _instance then
		_instance = jiqingbaoxiang:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jiqingbaoxiang.GetLayoutFileName()

	return "jiqingbaoxiang.layout"
end

function jiqingbaoxiang:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jiqingbaoxiang)
	return self
end

function jiqingbaoxiang:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	
	--关闭按钮
	self.close = winMgr:getWindow("jiqingbaoxiang/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)
	
	self.items = { --5个道具 仅作显示用  杂货表等  只要是道具的id  就可以
	340768,
	680700,
	710023,
	259303,
	710006
	
	
	}
	self.txt1 = "活动开始19:00-19:30每5分钟刷新1次。"




	self.tishiTxt = winMgr:getWindow("jiqingbaoxiang/di/txt")
	self.tishiTxt:setText(self.txt1)
	
	
	self.m_listCell = {}

	    for i = 1, 5 do
		    local cell = CEGUI.toItemCell(winMgr:getWindow("jiqingbaoxiang/itemBox/item" .. i ))
		    cell:setID( i )
			cell:SetBackGroundImage("my_qng", "18")
			local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.items[i])
            if itembean then
				cell:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))

			end
			
		    cell:subscribeEvent("MouseClick",jiqingbaoxiang.HandleItemClicked,self)
		    table.insert( self.m_listCell, cell )

	    end
	

	
	self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("jiqingbaoxiang/btn1"))
	self.m_btnCharge:subscribeEvent("Clicked",jiqingbaoxiang.HandleBtnChargeClicked,self)
	

	
	--特效
	self.bgtx = winMgr:getWindow("jiqingbaoxiang/tx")
	local bgtxANi = gGetGameUIManager():AddUIEffect(self.bgtx, "spine/my_spine/my_jqbx", true) --�ϳ���Ч ����
	bgtxANi:SetDefaultActName("stand1")
	bgtxANi:SetScale(1)
	
	

end







 function jiqingbaoxiang:HandleItemClicked(args)

	
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




function jiqingbaoxiang:HandleBtnChargeClicked(e) --转跳地图


	if GetTeamManager() and  not GetTeamManager():CanIMove() then
	
		if GetChatManager() then
			GetChatManager():AddTipsMsg(150030)
		end
		return true
	end

	
	local  nMapID = 5020 --这里填激情宝箱的跳转的地图
	local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
	
	if mapRecord == nil then	
		return true;
	end

	if mapRecord.maptype == 1 or mapRecord.maptype == 2  then
	
		local randX = mapRecord.bottomx - mapRecord.topx
		randX = mapRecord.topx + math.random(0, randX)

		local randY = mapRecord.bottomy - mapRecord.topy
		randY = mapRecord.topy + math.random(0, randY)
		gGetNetConnection():send(fire.pb.mission.CReqGoto(nMapID, randX, randY));
        if gGetScene()  then
			gGetScene():EnableJumpMapForAutoBattle(false);
		end
		self.DestroyDialog()
	else
		
		return false
	end	
		
	return true;


end


return jiqingbaoxiang