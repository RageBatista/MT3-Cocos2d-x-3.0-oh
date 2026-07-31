
Workshopitemcell5 = {}
Workshopitemcell5.__index = Workshopitemcell5


Workshopitemcell5.strImageSelName = "set:common_sangongge4 image:common_equipzhengtu" 
Workshopitemcell5.mWndName_btnBg = "Workshopitemcell5/back"
Workshopitemcell5.mWndName_imageBg = "Workshopitemcell5/back/bgimage" 
Workshopitemcell5.mWndName_itemCell = "Workshopitemcell5/back/item"
Workshopitemcell5.mWndName_imageHaveEquiped = "Workshopitemcell5/back/item/xqyizhuangbei"
Workshopitemcell5.mWndName_imageCanMake = "Workshopitemcell5/back/item/kedazao"
Workshopitemcell5.mWndName_labItemName = "Workshopitemcell5/back/name"
--//dz 60�� ����
Workshopitemcell5.mWndName_labBottom1 = "Workshopitemcell5/back/label1"
Workshopitemcell5.mWndName_labBottom2 = "Workshopitemcell5/back/label2"
--//xq 
Workshopitemcell5.mWndName_imageStone1 = "Workshopitemcell5/back/xqbaoshi1"
Workshopitemcell5.mWndName_imageStone2 = "Workshopitemcell5/back/xqbaoshi2"
Workshopitemcell5.mWndName_imageStone3 = "Workshopitemcell5/back/xqbaoshi3"
--//hc ��Ѫ+40 bottom1
--//xl �;ö�
Workshopitemcell5.mWndName_labDurance = "Workshopitemcell5/back/xiulilabel"
--Workshopitemcell5.mWndName_imageAdd = "Workshopitemcell5/back/item/jiahao"
--Workshopitemcell5.mWndName_labHeChengGem = "Workshopitemcell5/back/textwubaoshi"

Workshopitemcell5.mWndName_imageRed = "Workshopitemcell5/back/hongdian"
--equipCell.imageRed

function Workshopitemcell5.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Workshopitemcell5)
	newcell.__index = Workshopitemcell5
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	--Workshopitemcell5.id = Workshopitemcell5.id + 1
	return newcell
end

function Workshopitemcell5:OnCreate(parent, prefix)
	
	if prefix then
		print("Workshopitemcell5=prefix="..prefix)
	else
		print("Workshopitemcell5=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "Workshopitemcell5.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("Workshopitemcell5=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	
	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopitemcell5.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..Workshopitemcell5.mWndName_btnBg))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 
	self.imageBg = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageBg)  
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix..Workshopitemcell5.mWndName_itemCell))
	self.imageHaveEquiped = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageHaveEquiped) 
	self.imageCanMake = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageCanMake) 
	self.labItemName = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_labItemName) 
	self.labBottom1 = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_labBottom1) 
	self.labBottom2 = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_labBottom2) 
	self.imageStone1 = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageStone1) 
	self.imageStone2 = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageStone2) 
	self.imageStone3 = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageStone3) 
	self.labDurance = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_labDurance) 
	self.imageRed  = winMgr:getWindow(prefix..Workshopitemcell5.mWndName_imageRed) --Workshopitemcell5.mWndName_imageRed 

    self.iamgeCanEquip = winMgr:getWindow(prefix.."Workshopitemcell5/back/kechuandai") 

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end

function Workshopitemcell5:RefreshVisibleWithType(eType)
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

function Workshopitemcell5.GetLayoutFileName()
	--return "Workshopitemcell5.layout"
end

function Workshopitemcell5:DestroyDialog()
	self:OnClose()
end

function Workshopitemcell5:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Workshopitemcell5


