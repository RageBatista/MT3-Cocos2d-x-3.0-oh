require "logic.dialog"

Spaceselpicdialog = {}
setmetatable(Spaceselpicdialog, Dialog)
Spaceselpicdialog.__index = Spaceselpicdialog

Spaceselpicdialog.eCallBackType = 
{
    clickCamera = 1,
    clickPhoto=2,
    clickDel=3,
}


local _instance

function Spaceselpicdialog.getInstance()
	if not _instance then
		_instance = Spaceselpicdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spaceselpicdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spaceselpicdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Spaceselpicdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spaceselpicdialog:OnClose()
    self:clearData()
	Dialog.OnClose(self)
end

function Spaceselpicdialog.GetLayoutFileName()
	return "kongjianbtnzu.layout"
end

function Spaceselpicdialog.getInstanceNotCreate()
	return _instance
end

function Spaceselpicdialog:clearData()
    self.mapCallBack = {}
end

function Spaceselpicdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spaceselpicdialog)
    self:clearData()
	return self
end

function Spaceselpicdialog:OnCreate()
     Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	
    self.btnCamera = CEGUI.toPushButton(winMgr:getWindow("kongjianbtnzu/btn1")) 
    self.btnCamera:subscribeEvent("MouseClick", Spaceselpicdialog.clickCamera, self)

    self.btnPhoto = CEGUI.toPushButton(winMgr:getWindow("kongjianbtnzu/btn2")) 
    self.btnPhoto:subscribeEvent("MouseClick", Spaceselpicdialog.clickPhoto, self)

    self.btnDelPic = CEGUI.toPushButton(winMgr:getWindow("kongjianbtnzu/btn3")) 
    self.btnDelPic:subscribeEvent("MouseClick", Spaceselpicdialog.clickDelPic, self)

end

function Spaceselpicdialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end


function Spaceselpicdialog:callEvent(eType)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end


function Spaceselpicdialog:clickCamera(args)
    self:callEvent(Spaceselpicdialog.eCallBackType.clickCamera)
    Spaceselpicdialog.DestroyDialog()
end

function Spaceselpicdialog:clickPhoto(args)
    self:callEvent(Spaceselpicdialog.eCallBackType.clickPhoto)
    Spaceselpicdialog.DestroyDialog()
end

function Spaceselpicdialog:clickDelPic(args)
    self:callEvent(Spaceselpicdialog.eCallBackType.clickDel)
    Spaceselpicdialog.DestroyDialog()
end

return Spaceselpicdialog