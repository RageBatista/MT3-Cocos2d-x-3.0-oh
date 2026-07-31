require "logic.dialog"

CharacterXiuxingDlg = { }
setmetatable(CharacterXiuxingDlg, Dialog)
CharacterXiuxingDlg.__index = CharacterXiuxingDlg

local _instance

function CharacterXiuxingDlg.DestroyDialog()
    if _instance then
        Dialog.OnClose(_instance)
        _instance = nil
    end
    XiulianguoTipsDlg.DestroyDialog()
end

function CharacterXiuxingDlg.getInstance()
    if not _instance then
        _instance = CharacterXiuxingDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function CharacterXiuxingDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterXiuxingDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function CharacterXiuxingDlg.getInstanceNotCreate()
    return _instance
end



function CharacterXiuxingDlg.ToggleOpenClose()
    if not _instance then
        _instance = CharacterXiuxingDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function CharacterXiuxingDlg.GetLayoutFileName()
    return "characterxiuxing.layout"
end

function CharacterXiuxingDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, CharacterXiuxingDlg)
    return self
end
function CharacterXiuxingDlg:HandlClickBg(e)
	XiulianguoTipsDlg.DestroyDialog()
end
function CharacterXiuxingDlg:OnCreate()
    Dialog.OnCreate(self)
    SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

    self:GetCloseBtn():removeEvent("Clicked")
    self:GetCloseBtn():subscribeEvent("Clicked", CharacterLabel.DestroyDialog, nil)
	
    self.qngdesc = winMgr:getWindow("characterxiuxingdlg/qngdesc")
    self.qngdesc:setText("日月得天，而能久照;四时变化，而能\n久成，循其道，观其恒，天下万物之情\n可见，则印鉴自身。")
    self.qjbmdesc = winMgr:getWindow("characterxiuxingdlg/qjbmdesc")
    self.qjbmdesc:setText("三界初成，元气蒙鸿，萌芽兹始，肇立\n乾坤，启阴感阳，奇经八脉，通络中枢\n唯能者可通其道。")
	
	
    self.qng = winMgr:getWindow("characterxiuxingdlg/qng")
    self.qng:subscribeEvent("Clicked", CharacterXiuxingDlg.HandleClickQngBtn, self)

    self.qiannengguo = CEGUI.Window.toPushButton(winMgr:getWindow("characterxiuxingdlg/qiannengguo"))
    self.qiannengguo:subscribeEvent("Clicked", CharacterXiuxingDlg.HandleClickQngBtn, self)


    self.qjbm = winMgr:getWindow("characterxiuxingdlg/qjbm")
    self.qjbm:subscribeEvent("Clicked", CharacterXiuxingDlg.HandleClickQjbmBtn, self)


    self.qijingbamai = CEGUI.Window.toPushButton(winMgr:getWindow("characterxiuxingdlg/qijingbamai"))
    self.qijingbamai:subscribeEvent("Clicked", CharacterXiuxingDlg.HandleClickQjbmBtn, self)



end


function CharacterXiuxingDlg:HandleClickQngBtn()
	require "logic.characterinfo.characterlabel".DestroyDialog()

	require "logic.characterinfo.characterxiulianguodlg".getInstanceAndShow()
end


function CharacterXiuxingDlg:HandleClickQjbmBtn()

    local dlg = require("logic.workshop.jingmai.jingmaizhu").getInstanceAndShow()

    local p = debugrequire "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 1 --normal
    require "manager.luaprotocolmanager":send(p)

    self.DestroyDialog()
    CharacterLabel.DestroyDialog()

	--GetCTipsManager():AddMessageTipByMsg("正在研发中")
end



return CharacterXiuxingDlg
