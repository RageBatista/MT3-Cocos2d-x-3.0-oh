require "logic.dialog"
require "utils.commonutil"

AddpetListfyDlg = {}
setmetatable(AddpetListfyDlg, Dialog)
AddpetListfyDlg.__index = AddpetListfyDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local quanbu = "全部";
local yesheng = "普通";
local shenshou = "特殊";
local lingshou = "灵兽";
local zhenshou="珍兽";

function AddpetListfyDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AddpetListfyDlg)
    return self
end

function AddpetListfyDlg.getInstance(parent)
    if not _instance then
        _instance = AddpetListfyDlg:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function AddpetListfyDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = AddpetListfyDlg:new()
        _instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function AddpetListfyDlg.getInstanceNotCreate()
    return _instance
end

function AddpetListfyDlg.DestroyDialog()
	if _instance then 
        PetGalleryDlg.getInstance():SetSchemeArrowImg(false);	
		_instance:OnClose()		
		_instance = nil
	end
end

function AddpetListfyDlg.ToggleOpenClose(parent)
	if not _instance then 
		_instance = AddpetListfyDlg:new() 
		_instance:OnCreate(parent)
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true) 
		end
	end
end
----/////////////////////////////////////////------

function AddpetListfyDlg.GetLayoutFileName()
    return "addpetlistfydlg.layout"
end

function AddpetListfyDlg:OnCreate(parent)

    Dialog.OnCreate(self, parent)

    local winMgr = CEGUI.WindowManager:getSingleton()
	
	local winbg = winMgr:getWindow("AddpetListfyDlg")
    self.container = CEGUI.toScrollablePane(winMgr:getWindow("AddpetListfyDlg/container"))
	
	self:deployAccountList()
	
end
function AddpetListfyDlg:HandlClickBg(e)
	AddpetListfyDlg.DestroyDialog()
end
function AddpetListfyDlg:deployAccountList()
	
	PetGalleryDlg.getInstance():SetSchemeArrowImg(true);	
	self:clearList()
	self.cells = {}

	local winMgr = CEGUI.WindowManager:getSingleton()
	local s = self.container:getPixelSize()
	local cellh = 50
	local cellh1 = 55

    local btnSize = CEGUI.UVector2(CEGUI.UDim(0, s.width), CEGUI.UDim(0, cellh))
    local btnPosition = CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,0))
    local btnPosition1 = CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,1*(cellh1)))
    local btnPosition3= CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,2*(cellh1)))
    local btnPosition2 = CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,3*(cellh1)))
    local btnPosition4 = CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,4*(cellh1)))
    local font = "simhei-12"
    local TaharezLook =  "TaharezLook/GroupButtonHong"

    local wnd = CEGUI.toPushButton(winMgr:createWindow(TaharezLook))
    local wnd1 = CEGUI.toPushButton(winMgr:createWindow(TaharezLook))
    local wnd2 = CEGUI.toPushButton(winMgr:createWindow(TaharezLook))
    local wnd3 = CEGUI.toPushButton(winMgr:createWindow(TaharezLook))
    local wnd4 = CEGUI.toPushButton(winMgr:createWindow(TaharezLook))

    self.container:addChildWindow(wnd)
    wnd:subscribeEvent("SelectStateChanged", AddpetListfyDlg.handleallClicked, self)
    wnd:setSize(btnSize)
    wnd:setPosition(btnPosition)
    wnd:EnableClickAni(false)
    wnd:setProperty("Font", font);
    wnd:setProperty("NormalTextColour", "ff6e4506");
    wnd:setText(quanbu)
    table.insert(self.cells, wnd)


    self.container:addChildWindow(wnd1)
    wnd1:subscribeEvent("SelectStateChanged", AddpetListfyDlg.handleFilterClicked, self)
    wnd1:setSize(btnSize)
    wnd1:setPosition(btnPosition1)
    wnd1:EnableClickAni(false)
    wnd1:setProperty("Font", font);
    wnd1:setProperty("NormalTextColour", "ff6e4506");
    wnd1:setText(yesheng)
    table.insert(self.cells, wnd1)


    self.container:addChildWindow(wnd2)
	wnd2:subscribeEvent("SelectStateChanged", AddpetListfyDlg.handleShenShouClicked, self)
    wnd2:setSize(btnSize)
    wnd2:setPosition(btnPosition2)
    wnd2:EnableClickAni(false)
    wnd2:setProperty("Font", font);
    wnd2:setProperty("NormalTextColour", "ff6e4506");
    wnd2:setText(shenshou)
    table.insert(self.cells, wnd2)


    self.container:addChildWindow(wnd3)
	wnd3:subscribeEvent("SelectStateChanged", AddpetListfyDlg.handleLingShouClicked, self)
    wnd3:setSize(btnSize)
	wnd3:setPosition(btnPosition3)
    wnd3:EnableClickAni(false)
    wnd3:setProperty("Font", font);
    wnd3:setProperty("NormalTextColour", "ff6e4506");
    wnd3:setText(lingshou)
    table.insert(self.cells, wnd3)

    self.container:addChildWindow(wnd4)
	wnd4:subscribeEvent("SelectStateChanged", AddpetListfyDlg.handleZhenShouClicked, self)
    wnd4:setSize(btnSize)
	wnd4:setPosition(btnPosition4)
    wnd4:EnableClickAni(false)
    wnd4:setProperty("Font", font);
    wnd4:setProperty("NormalTextColour", "ff6e4506");
    wnd4:setText(zhenshou)
    table.insert(self.cells, wnd4)

    

	
	
end

function AddpetListfyDlg:handleallClicked(args)
	PetGalleryDlg.getInstance().m_schemeBtnStatus = false
	PetGalleryDlg.getInstance():refreshPetTable(0, 50000)
    PetGalleryDlg.getInstance():setTextPetlist(quanbu)
    self.DestroyDialog()
end
function AddpetListfyDlg:handleFilterClicked(args)
	PetGalleryDlg.getInstance().m_schemeBtnStatus = false
	PetGalleryDlg.getInstance():refreshPetTable(0, 0)
    PetGalleryDlg.getInstance():setTextPetlist(yesheng)
    self.DestroyDialog()
end
function AddpetListfyDlg:handleShenShouClicked(args)
	PetGalleryDlg.getInstance().m_schemeBtnStatus = false
	PetGalleryDlg.getInstance():refreshPetTable(10000, 10000)
    PetGalleryDlg.getInstance():setTextPetlist(shenshou)
    self.DestroyDialog()
end
function AddpetListfyDlg:handleLingShouClicked(args)
	PetGalleryDlg.getInstance().m_schemeBtnStatus = false
	PetGalleryDlg.getInstance():refreshPetTable(20000, 20000)
    PetGalleryDlg.getInstance():setTextPetlist(lingshou)
    self.DestroyDialog()
end

function AddpetListfyDlg:handleZhenShouClicked(args)
	PetGalleryDlg.getInstance().m_schemeBtnStatus = false
	PetGalleryDlg.getInstance():refreshPetTable(30000, 30000)
    PetGalleryDlg.getInstance():setTextPetlist(zhenshou)
    self.DestroyDialog()
end





function AddpetListfyDlg:clearList()
	if not self.cells or #self.cells == 0 then return end
	
	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

return AddpetListfyDlg
