
Workshopitemcell4 = {}
Workshopitemcell4.__index = Workshopitemcell4


Workshopitemcell4.strImageSelName = "set:common_sangongge4 image:common_equipzhengtu" 
Workshopitemcell4.mWndName_btnBg = "Workshopitemcell4/back"
Workshopitemcell4.mWndName_imageBg = "Workshopitemcell4/back/bgimage" 
Workshopitemcell4.mWndName_itemCell = "Workshopitemcell4/back/item"
Workshopitemcell4.mWndName_imageHaveEquiped = "Workshopitemcell4/back/item/xqyizhuangbei"
Workshopitemcell4.mWndName_imageCanMake = "Workshopitemcell4/back/item/kedazao"
Workshopitemcell4.mWndName_labItemName = "Workshopitemcell4/back/name"
--//dz 60�� ����
Workshopitemcell4.mWndName_labBottom1 = "Workshopitemcell4/back/label1"
Workshopitemcell4.mWndName_labBottom2 = "Workshopitemcell4/back/label2"
--//xq 
Workshopitemcell4.mWndName_imageStone1 = "Workshopitemcell4/back/xqbaoshi1"
Workshopitemcell4.mWndName_imageStone2 = "Workshopitemcell4/back/xqbaoshi2"
Workshopitemcell4.mWndName_imageStone3 = "Workshopitemcell4/back/xqbaoshi3"
--//hc ��Ѫ+40 bottom1
--//xl �;ö�
Workshopitemcell4.mWndName_labDurance = "Workshopitemcell4/back/xiulilabel"
--Workshopitemcell4.mWndName_imageAdd = "Workshopitemcell4/back/item/jiahao"
--Workshopitemcell4.mWndName_labHeChengGem = "Workshopitemcell4/back/textwubaoshi"

Workshopitemcell4.mWndName_imageRed = "Workshopitemcell4/back/hongdian"
--equipCell.imageRed

function Workshopitemcell4.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Workshopitemcell4)
	newcell.__index = Workshopitemcell4
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	--Workshopitemcell4.id = Workshopitemcell4.id + 1
	return newcell
end

function Workshopitemcell4:OnCreate(parent, prefix)
	
	if prefix then
		print("Workshopitemcell4=prefix="..prefix)
	else
		print("Workshopitemcell4=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "Workshopitemcell4.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("Workshopitemcell4=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	
	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopitemcell4.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..Workshopitemcell4.mWndName_btnBg))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 
	self.imageBg = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageBg)  
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix..Workshopitemcell4.mWndName_itemCell))
	self.imageHaveEquiped = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageHaveEquiped) 
	self.imageCanMake = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageCanMake) 
	self.labItemName = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_labItemName) 
	self.labBottom1 = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_labBottom1) 
	self.labBottom2 = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_labBottom2) 
	self.imageStone1 = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageStone1) 
	self.imageStone2 = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageStone2) 
	self.imageStone3 = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageStone3) 
	self.labDurance = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_labDurance) 
	self.imageRed  = winMgr:getWindow(prefix..Workshopitemcell4.mWndName_imageRed) --Workshopitemcell4.mWndName_imageRed 

    self.iamgeCanEquip = winMgr:getWindow(prefix.."Workshopitemcell4/back/kechuandai") 

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end

function Workshopitemcell4:RefreshVisibleWithType(eType)
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

function Workshopitemcell4.GetLayoutFileName()
	--return "Workshopitemcell4.layout"
end

function Workshopitemcell4:DestroyDialog()
	self:OnClose()
end

function Workshopitemcell4:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Workshopitemcell4


