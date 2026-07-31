
Workshopitemcell = {}
Workshopitemcell.__index = Workshopitemcell


Workshopitemcell.strImageSelName = "set:common_sangongge4 image:common_equipzhengtu" 
Workshopitemcell.mWndName_btnBg = "workshopitemcell/back"
Workshopitemcell.mWndName_imageBg = "workshopitemcell/back/bgimage" 
Workshopitemcell.mWndName_itemCell = "workshopitemcell/back/item"
Workshopitemcell.mWndName_imageHaveEquiped = "workshopitemcell/back/item/xqyizhuangbei"
Workshopitemcell.mWndName_imageCanMake = "workshopitemcell/back/item/kedazao"
Workshopitemcell.mWndName_labItemName = "workshopitemcell/back/name"
--//dz 60�� ����
Workshopitemcell.mWndName_labBottom1 = "workshopitemcell/back/label1"
Workshopitemcell.mWndName_labBottom2 = "workshopitemcell/back/label2"
--//xq 
Workshopitemcell.mWndName_imageStone1 = "workshopitemcell/back/xqbaoshi1"
Workshopitemcell.mWndName_imageStone2 = "workshopitemcell/back/xqbaoshi2"
Workshopitemcell.mWndName_imageStone3 = "workshopitemcell/back/xqbaoshi3"
--//hc ��Ѫ+40 bottom1
--//xl �;ö�
Workshopitemcell.mWndName_labDurance = "workshopitemcell/back/xiulilabel"
--Workshopitemcell.mWndName_imageAdd = "workshopitemcell/back/item/jiahao"
--Workshopitemcell.mWndName_labHeChengGem = "workshopitemcell/back/textwubaoshi"

Workshopitemcell.mWndName_imageRed = "workshopitemcell/back/hongdian"
--equipCell.imageRed

function Workshopitemcell.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Workshopitemcell)
	newcell.__index = Workshopitemcell
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	--Workshopitemcell.id = Workshopitemcell.id + 1
	return newcell
end

function Workshopitemcell:OnCreate(parent, prefix)
	
	if prefix then
		print("Workshopitemcell=prefix="..prefix)
	else
		print("Workshopitemcell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "workshopitemcell.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("Workshopitemcell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	
	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopitemcell.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..Workshopitemcell.mWndName_btnBg))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 
	self.imageBg = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageBg)  
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix..Workshopitemcell.mWndName_itemCell))
	self.imageHaveEquiped = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageHaveEquiped) 
	self.imageCanMake = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageCanMake) 
	self.labItemName = winMgr:getWindow(prefix..Workshopitemcell.mWndName_labItemName) 
	self.labBottom1 = winMgr:getWindow(prefix..Workshopitemcell.mWndName_labBottom1) 
	self.labBottom2 = winMgr:getWindow(prefix..Workshopitemcell.mWndName_labBottom2) 
	self.imageStone1 = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageStone1) 
	self.imageStone2 = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageStone2) 
	self.imageStone3 = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageStone3) 
	self.labDurance = winMgr:getWindow(prefix..Workshopitemcell.mWndName_labDurance) 
	self.imageRed  = winMgr:getWindow(prefix..Workshopitemcell.mWndName_imageRed) --Workshopitemcell.mWndName_imageRed 

    self.iamgeCanEquip = winMgr:getWindow(prefix.."workshopitemcell/back/kechuandai") 

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end

function Workshopitemcell:RefreshVisibleWithType(eType)
	self.imageHaveEquiped:setVisible(false)
	self.imageCanMake:setVisible(false)
	self.labBottom1:setVisible(false)
	self.labBottom2:setVisible(false)
	self.imageStone1:setVisible(false)
	self.imageStone2:setVisible(false)
	self.imageStone3:setVisible(false)
	self.labDurance:setVisible(false)
	--self.imageAdd:setVisible(false)
	--self.labHeChengGem:setVisible(false)
	self.imageRed:setVisible(false)
	
	if eType == 1 then
		self.labBottom1:setVisible(true)
		self.labBottom2:setVisible(true)
	elseif eType==2 then
		self.imageStone1:setVisible(true)
		self.imageStone2:setVisible(true)
		self.imageStone3:setVisible(true)
	elseif eType==3 then
		self.labBottom1:setVisible(true)
	elseif eType==4 then
		self.labBottom1:setVisible(true)
		self.labDurance:setVisible(true)
	elseif eType==5 then --baoshi
		self.labBottom1:setVisible(true)
	elseif eType==6 then --jiabaoshi
		--self.imageAdd.setVisible(true)
		--self.labHeChengGem.setVisible(true)
	end
end

function Workshopitemcell.GetLayoutFileName()
	--return "workshopitemcell.layout"
end

function Workshopitemcell:DestroyDialog()
	self:OnClose()
end

function Workshopitemcell:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Workshopitemcell


