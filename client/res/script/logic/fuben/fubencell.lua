
Fubencell = {}
Fubencell.__index = Fubencell


function Fubencell.new(parent,prefix)
	local self = {}
	setmetatable(self, Fubencell)
	self.__index = Fubencell
	self:OnCreate(parent, prefix)
	
	return self
end

function Fubencell:OnCreate(parent, prefix)
	
	if prefix then
		print("Fubencell=prefix="..prefix)
	else
		print("Fubencell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "fubencell_mtg.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("Fubencell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Fubencell.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix.."fubencell_mtg"))
	self.btnBg:EnableClickAni(false) 

    self.imageShowBg = winMgr:getWindow(prefix.."fubencell_mtg/beijingtu")  --fubencell_mtg/beijingtu
	
	self.labelTitle1 = winMgr:getWindow(prefix.."fubencell_mtg/text") 
	self.labelTitle2 = winMgr:getWindow(prefix.."fubencell_mtg/kaiqishijian") 
	
	self.imageBgSprite = winMgr:getWindow(prefix.."fubencell_mtg/fazhen/image") 
    
    self.imageBgCircle = winMgr:getWindow(prefix.."fubencell_mtg/fazhen") 
	
	self.labelDes = winMgr:getWindow(prefix.."fubencell_mtg/shuoming") 
	self.labelNoPass = winMgr:getWindow(prefix.."fubencell_mtg/weitongguan") 
	
	self.btnEnter = CEGUI.toPushButton(winMgr:getWindow(prefix.."fubencell_mtg/btnjinru"))
    if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end

end

function Fubencell:DestroyDialog()
	self:OnClose()
end

function Fubencell:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Fubencell


