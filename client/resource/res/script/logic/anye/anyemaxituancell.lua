require "logic.dialog"


Anyemaxituancell = {}
setmetatable(Anyemaxituancell, Dialog)
Anyemaxituancell.__index = Anyemaxituancell
local nIndexPrefix = 1


function Anyemaxituancell.create(parent)
    local newcell = Dialog:new()
    local prefix = tostring(nIndexPrefix)
    nIndexPrefix = nIndexPrefix + 1
	setmetatable(newcell, Anyemaxituancell)
	newcell:OnCreate(parent, prefix)
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    return newcell
end

--//===============================

function Anyemaxituancell:OnCreate(parent,prefix)
    Dialog.OnCreate(self,parent,prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.nodeBg = CEGUI.toGroupButton(winMgr:getWindow(prefix.."anyemaxituancell"))

    self.labelTaskName = winMgr:getWindow(prefix.."anyemaxituancell/di1/mingzi") 
    self.itemcellTaskIcon = CEGUI.toItemCell(winMgr:getWindow(prefix.."anyemaxituancell/xuqiutubiao"))

    self.labelTarget = winMgr:getWindow(prefix.."anyemaxituancell/renwumubiao1/di1/mubiaomingcheng")  
    self.labelNum = winMgr:getWindow(prefix.."anyemaxituancell/renwumubiao1/di2/mubiaomingcheng")   
    self.labelQuality = winMgr:getWindow(prefix.."anyemaxituancell/renwumubiao1/di3/mubiaomingcheng")  

    self.nodeLabelBg = winMgr:getWindow(prefix.."anyemaxituancell/renwumubiao1")  

    self.iamgeBattle = winMgr:getWindow(prefix.."anyemaxituancell/zhandoubiaoshi") 
    self.imageSuccess = winMgr:getWindow(prefix.."anyemaxituancell/wanchengbiaoshi") 

    self.richBoxDesc = CEGUI.toRichEditbox(winMgr:getWindow(prefix.."anyemaxituancell/renwumubiao2"))
    self.richBoxDesc:setReadOnly(true)

    self.btnFindTreasure = winMgr:getWindow(prefix.."anyemaxituancell/xunbao")
    self.imgFindTreasureDo = winMgr:getWindow(prefix.."anyemaxituancell/xunbaozhong")
    self.imgFindTreasureFail = winMgr:getWindow(prefix.."anyemaxituancell/xunbaoshibai")
    self.imgFindTreasureFinish = winMgr:getWindow(prefix.."anyemaxituancell/xunbaochenggong")
    
    local nChildcount = self.nodeBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.nodeBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
    self.btnFindTreasure:setMousePassThroughEnabled(false)
end

function Anyemaxituancell.GetLayoutFileName()
    return "anyemaxituancell.layout"
end

return Anyemaxituancell
