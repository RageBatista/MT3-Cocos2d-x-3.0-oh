require "logic.dialog"

Spacebuyflowerdialog = {}
setmetatable(Spacebuyflowerdialog, Dialog)
Spacebuyflowerdialog.__index = Spacebuyflowerdialog

Spacebuyflowerdialog.eCallBackType = 
{
    clickCamera = 1,
    clickPhoto=2,
    clickDel=3,
}


local _instance

function Spacebuyflowerdialog.getInstance()
	if not _instance then
		_instance = Spacebuyflowerdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spacebuyflowerdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacebuyflowerdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Spacebuyflowerdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacebuyflowerdialog:OnClose()
    self:clearData()
	Dialog.OnClose(self)
end

function Spacebuyflowerdialog.GetLayoutFileName()
	return "kongjianhua.layout"
end

function Spacebuyflowerdialog.getInstanceNotCreate()
	return _instance
end

function Spacebuyflowerdialog:clearData()
    self.mapCallBack = {}
end

function Spacebuyflowerdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacebuyflowerdialog)
    self:clearData()
	return self
end

function Spacebuyflowerdialog:OnCreate()
     Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	
    self.btn1 = CEGUI.toPushButton(winMgr:getWindow("kongjianhua/ditu/btndagong")) 
    self.btn1:subscribeEvent("MouseClick", Spacebuyflowerdialog.clickBuy1, self)

    self.btnPhoto = CEGUI.toPushButton(winMgr:getWindow("kongjianhua/ditu/zhizuo")) 
    self.btnPhoto:subscribeEvent("MouseClick", Spacebuyflowerdialog.clickBuy2, self)

    self.itemCell1 = CEGUI.toItemCell(winMgr:getWindow("kongjianhua/ditu/item1"))
    self.itemCell2 = CEGUI.toItemCell(winMgr:getWindow("kongjianhua/ditu/item2"))
    --self.btnDelPic = CEGUI.toPushButton(winMgr:getWindow("kongjianbtnzu/btn3")) 
    --self.btnDelPic:subscribeEvent("MouseClick", Spacebuyflowerdialog.clickDelPic, self)

    local itemAttr1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(339103)
    if itemAttr1 then
        self.itemCell1:SetImage(gGetIconManager():GetImageByID(itemAttr1.icon))
    end
    local itemAttr2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(339104)
    if itemAttr2 then
        self.itemCell2:SetImage(gGetIconManager():GetImageByID(itemAttr2.icon))
    end
    	
    local frameWnd = CEGUI.toFrameWindow(winMgr:getWindow("kongjianhua/ditu"))
	local closeBtn = CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",Spacebuyflowerdialog.clickClose,self)

end


function Spacebuyflowerdialog:clickClose()
    Spacebuyflowerdialog.DestroyDialog()
end


function Spacebuyflowerdialog:clickBuy1()

    ShopManager:tryQuickBuy(339103)
end

function Spacebuyflowerdialog:clickBuy2()

    ShopManager:tryQuickBuy(339104)
end


function Spacebuyflowerdialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end


function Spacebuyflowerdialog:callEvent(eType)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end


function Spacebuyflowerdialog:clickCamera(args)
    self:callEvent(Spacebuyflowerdialog.eCallBackType.clickCamera)
    Spacebuyflowerdialog.DestroyDialog()
end

function Spacebuyflowerdialog:clickPhoto(args)
    self:callEvent(Spacebuyflowerdialog.eCallBackType.clickPhoto)
    Spacebuyflowerdialog.DestroyDialog()
end

function Spacebuyflowerdialog:clickDelPic(args)
    self:callEvent(Spacebuyflowerdialog.eCallBackType.clickDel)
    Spacebuyflowerdialog.DestroyDialog()
end

return Spacebuyflowerdialog