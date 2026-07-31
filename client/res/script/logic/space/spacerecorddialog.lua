require "logic.dialog"

Spacerecorddialog = {}
setmetatable(Spacerecorddialog, Dialog)
Spacerecorddialog.__index = Spacerecorddialog

local _instance

function Spacerecorddialog.getInstance()
	if not _instance then
		_instance = Spacerecorddialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spacerecorddialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacerecorddialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Spacerecorddialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacerecorddialog:OnClose()
     require("logic.task.schedulermanager").getInstance():deleteTimerWithTarget(self)
    getSpaceManager():stopRecord()
	Dialog.OnClose(self)
end

function Spacerecorddialog.GetLayoutFileName()
	return "kongjianluyin.layout"
end

function Spacerecorddialog.getInstanceNotCreate()
	return _instance
end


function Spacerecorddialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacerecorddialog)
	return self
end

function Spacerecorddialog:OnCreate()
     Dialog.OnCreate(self)
     SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	
    --self.btnCamera = CEGUI.toPushButton(winMgr:getWindow("kongjianbtnzu/btn1")) 
    --self.btnCamera:subscribeEvent("MouseClick", Spacerecorddialog.clickCamera, self)

    self.btnCancel = CEGUI.toPushButton(winMgr:getWindow("kongjianluyin/btn1")) 
    self.btnCancel:subscribeEvent("MouseClick", Spacerecorddialog.clickCancel, self)

    self.btnDone = CEGUI.toPushButton(winMgr:getWindow("kongjianluyin/btn11")) 
    self.btnDone:subscribeEvent("MouseClick", Spacerecorddialog.clickDone, self)

    getSpaceManager():beginRecord()

    local timerData = {}
    require("logic.task.schedulermanager").getInstance():getTimerDataInit(timerData)
    local  Schedulermanager = require("logic.task.schedulermanager")
	--//=======================================
	timerData.eType = Schedulermanager.eTimerType.repeatCount
	timerData.fDurTime = 15
	timerData.nRepeatCount = 1
	--timerData.nParam1 = nTaskTypeId
    timerData.pTarget = self
    timerData.callback= Spacerecorddialog.timerCallBack
	--//=======================================
	require("logic.task.schedulermanager").getInstance():addTimer(timerData)

end

function Spacerecorddialog:timerCallBack()
    --Spacerecorddialog.DestroyDialog()

    self:clickDone()
end

function Spacerecorddialog:clickCancel(args)
    Spacerecorddialog.DestroyDialog()
end

function Spacerecorddialog:clickDone(args)
    getSpaceManager():stopRecord()

    local Spaceprotocol = require("logic.space.spaceprotocol")
    local strVoiceData = Spaceprotocol.strFileDataParam --"$filedata$"
    local nnRoleId = getSpaceManager():getMyRoleId()
    local strTempSoundPath = getSpaceManager():getTempSoundFilePath()
    gGetSpaceManager():SaveDefaultVoiceToCurString(strTempSoundPath)
    require("logic.space.spacepro.spaceprotocol_setVoice").request(nnRoleId,strVoiceData)

    Spacerecorddialog.DestroyDialog()
end

return Spacerecorddialog