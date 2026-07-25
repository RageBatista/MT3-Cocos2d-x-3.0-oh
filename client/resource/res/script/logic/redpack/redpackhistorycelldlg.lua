RedPackHistoryCellDlg = {}

setmetatable(RedPackHistoryCellDlg, Dialog)
RedPackHistoryCellDlg.__index = RedPackHistoryCellDlg
local prefix = 0

function RedPackHistoryCellDlg.CreateNewDlg(parent)
	local newDlg = RedPackHistoryCellDlg:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RedPackHistoryCellDlg.GetLayoutFileName()
	return "hongbaogerenjilubiaoqian.layout"
end

function RedPackHistoryCellDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackHistoryCellDlg)
	return self
end

function RedPackHistoryCellDlg:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
    --self.m_Head = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/head")
    self.m_Time = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/shijian")
    self.m_Num = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/dikuang/shulaing")
    self.window = winMgr:getWindow(prefixstr.."hongbaogerenjilucell")
    self.m_img = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/dikuang/fushi")
    self.m_send = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/dikuang/kong1")
    self.m_receive = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/dikuang/kong")
    self.m_Head = winMgr:getWindow(prefixstr.."hongbaogerenjilucell/head/tu")
    
end
function RedPackHistoryCellDlg:setCellData(data, index)
    local time = StringCover.getTimeStruct(data.time / 1000)
    local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday
    self.m_Num:setText(data.redpackmoney)
    local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
	local iconpath = gGetIconManager():GetImagePathByID(Shape.littleheadID)
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	self.m_Head:setProperty("Image",iconpath:c_str())
    self.m_Time:setText(yearCur.."-"..monthCur.."-"..dayCur)
    self.m_img:setProperty("Image", "set:common image:common_jinb")
    if index == 1 then
        self.m_send:setVisible(false)
        self.m_receive:setVisible(true)
        self.m_Time:setText(data.rolename)
    else
        self.m_send:setVisible(true)
        self.m_receive:setVisible(false)
    end
end
return RedPackHistoryCellDlg