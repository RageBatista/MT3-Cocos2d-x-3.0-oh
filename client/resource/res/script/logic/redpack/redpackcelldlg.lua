RedPackCellDlg = {}
setmetatable(RedPackCellDlg, Dialog)
RedPackCellDlg.__index = RedPackCellDlg
local prefix = 0
local STATE_CANGET = 0 --可以抢红包
local STATE_HAVE = 1 --已经领取红包
local STATE_NONE = 2 --红包已经抢光
function RedPackCellDlg.CreateNewDlg(parent)
	local newDlg = RedPackCellDlg:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RedPackCellDlg.GetLayoutFileName()
	return "hongbao.layout"
end

function RedPackCellDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackCellDlg)
	return self
end

function RedPackCellDlg:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.window = CEGUI.Window.toPushButton(winMgr:getWindow(prefixstr.."hongbaocell"))
    self.m_name = winMgr:getWindow(prefixstr.."hongbaocell/mingzi1")
    self.m_dec = CEGUI.Window.toRichEditbox(winMgr:getWindow(prefixstr.."hongbaocell/text"))
    self.m_markimg = winMgr:getWindow(prefixstr.."hongbaocell/anniu1")
    self.m_marktxt = winMgr:getWindow(prefixstr.."hongbaocell/anniu1/txt")
    self.m_marktxt1 = winMgr:getWindow(prefixstr.."hongbaocell/anniu1/txt1")
    self.m_look = winMgr:getWindow(prefixstr.."hongbaocell/chakan")
    self.m_img = winMgr:getWindow(prefixstr.."hongbaocell/jinbi")
    
    self.m_ditu = winMgr:getWindow(prefixstr.."hongbaocell/ditu1")
end

function RedPackCellDlg:setCellData(data, index)
    self.m_dec:Clear()
    if data.redpackstate == STATE_CANGET then
        self.m_marktxt:setVisible(false)
        self.m_marktxt1:setVisible(false)
        self.m_look:setText(MHSD_UTILS.get_resstring(11451))
        self.m_dec:setVisible(false)
        self.m_ditu:setVisible(true)
    elseif data.redpackstate == STATE_HAVE then
        self.m_dec:setVisible(true)
        self.m_marktxt:setVisible(true)
        self.m_marktxt1:setVisible(false)
        self.m_look:setText(MHSD_UTILS.get_resstring(11452))
        local defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
	    self.m_dec:AppendText(CEGUI.String(data.redpackdes),defaultColor)
        self.m_dec:Refresh()
        self.m_ditu:setVisible(false)
    elseif data.redpackstate == STATE_NONE then
        self.m_dec:setVisible(true)
        self.m_marktxt:setVisible(false)
        self.m_marktxt1:setVisible(true)
        self.m_look:setText(MHSD_UTILS.get_resstring(11452))
        local defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
	    self.m_dec:AppendText(CEGUI.String(data.redpackdes),defaultColor)
        self.m_dec:Refresh()
        self.m_ditu:setVisible(false)    
    end
    self.m_name:setText(data.rolename)

    self.m_img:setProperty("Image", "set:common image:common_jinb")
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    local blnJin = false
    local numStand = 1000
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            numStand = numStand * 100
        end
    end
    if data.fushi >= numStand * realsize  then
        blnJin = true
    end 

    if data.redpackstate == STATE_CANGET then
        self.m_img:setVisible(true)
        if blnJin then
            self.window:setProperty("Image", "set:hongbao image:fushibao")
        else
            self.window:setProperty("Image", "set:hongbao image:jinbibao")
        end
        
    else
        self.m_img:setVisible(false)
        if blnJin then
            self.window:setProperty("Image", "set:hongbao image:fushibaokai")
        else
            self.window:setProperty("Image", "set:hongbao image:jinbibaokai")
        end
    end
end
return RedPackCellDlg