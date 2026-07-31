require "utils.mhsdutils"
require "logic.dialog"


Workshopdzconfirm = {}
setmetatable(Workshopdzconfirm, Dialog)
Workshopdzconfirm.__index = Workshopdzconfirm

------------------- public: -----------------------------------
local _instance;

function Workshopdzconfirm:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    --SetPositionOfWindowWithLabel(self:GetWindow())

    self.btnNotTiShi= CEGUI.toCheckbox(winMgr:getWindow("workshopdazaoqueren/jiemian/tishi"))
	self.btnNotTiShi:subscribeEvent("CheckStateChanged", Workshopdzconfirm.clickNotTishi, self)
    
	local closeBtn = CEGUI.toPushButton(winMgr:getWindow("workshopdazaoqueren/jiemian/quxiao"))
	closeBtn:subscribeEvent("MouseClick",Workshopdzconfirm.clickClose,self)
	
    local confirmBtn = CEGUI.toPushButton(winMgr:getWindow("workshopdazaoqueren/jiemian/queding"))
	confirmBtn:subscribeEvent("MouseClick",Workshopdzconfirm.clickConfirm,self)

end

function Workshopdzconfirm:clickNotTishi(args)
   
end

function Workshopdzconfirm:clickClose(e)
	Workshopdzconfirm.DestroyDialog()
end

function Workshopdzconfirm:clickConfirm(e)
    local wsManager = Workshopmanager.getInstance()
    local bSel = self.btnNotTiShi:isSelected()
	if bSel then 
        wsManager.nNotTishi = 1
	else
        wsManager.nNotTishi = 0
	end

    Workshopdzconfirm.DestroyDialog()
	local dzDlg = require "logic.workshop.workshopdznew".getInstanceOrNot()
	if dzDlg then 
		dzDlg:continueMake()
	end
end

function Workshopdzconfirm:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Workshopdzconfirm)
    return self
end

--//==========================================
function Workshopdzconfirm.getInstance()
    if not _instance then
        _instance = Workshopdzconfirm:new()
        _instance:OnCreate()
    end
    return _instance
end

function Workshopdzconfirm.getInstanceOrNot()
	return _instance
end
	
function Workshopdzconfirm.getInstanceAndShow()
    if not _instance then
        _instance = Workshopdzconfirm:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Workshopdzconfirm.getInstanceNotCreate()
    return _instance
end

function Workshopdzconfirm.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function Workshopdzconfirm:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function Workshopdzconfirm.GetLayoutFileName()
   return "workshopdazaoqueren.layout"
end

return Workshopdzconfirm

