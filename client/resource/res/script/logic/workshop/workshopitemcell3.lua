require "logic.dialog"

Workshopitemcell3 = {}
setmetatable(Workshopitemcell3, Dialog)
Workshopitemcell3.__index = Workshopitemcell3

Workshopitemcell3.strImageSelName = "set:common_sangongge4 image:common_equipzhengtu" 
Workshopitemcell3.mWndName_btnBg = "workshopitemcell/back"
Workshopitemcell3.mWndName_imageBg = "workshopitemcell/back/bgimage" 
Workshopitemcell3.mWndName_itemCell = "workshopitemcell/back/item"
Workshopitemcell3.mWndName_imageHaveEquiped = "workshopitemcell/back/item/xqyizhuangbei"
Workshopitemcell3.mWndName_imageCanMake = "workshopitemcell/back/item/kedazao"
Workshopitemcell3.mWndName_labItemName = "workshopitemcell/back/name"
--//dz 60�� ����
Workshopitemcell3.mWndName_labBottom1 = "workshopitemcell/back/label1"
Workshopitemcell3.mWndName_labBottom2 = "workshopitemcell/back/label2"
--//xq 
Workshopitemcell3.mWndName_imageStone1 = "workshopitemcell/back/xqbaoshi1"
Workshopitemcell3.mWndName_imageStone2 = "workshopitemcell/back/xqbaoshi2"
Workshopitemcell3.mWndName_imageStone3 = "workshopitemcell/back/xqbaoshi3"
--//hc ��Ѫ+40 bottom1
--//xl �;ö�
Workshopitemcell3.mWndName_labDurance = "workshopitemcell/back/xiulilabel"
Workshopitemcell3.mWndName_imageRed = "workshopitemcell/back/hongdian"
--equipCell.imageRed

local nIndexPrefix = 1

function Workshopitemcell3.new(parent,prefix)
	local newcell = Dialog:new()
    prefix = nIndexPrefix..nIndexPrefix
	setmetatable(newcell, Workshopitemcell3)
	newcell:OnCreate(parent, prefix)
	nIndexPrefix = nIndexPrefix + 1
	--local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	--local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))

	return newcell
end


function Workshopitemcell3:GetLayoutFileName()
	return "workshopitemcell.layout"
end

function Workshopitemcell3:OnCreate(parent, prefix)
	
	Dialog.OnCreate(self,parent,prefix)
	
	--local layoutName = "workshopitemcell.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	--self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopitemcell3.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..Workshopitemcell3.mWndName_btnBg))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 
	self.imageBg = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageBg)  
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix..Workshopitemcell3.mWndName_itemCell))
	self.imageHaveEquiped = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageHaveEquiped) 
	self.imageCanMake = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageCanMake) 
	self.labItemName = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_labItemName) 
	self.labBottom1 = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_labBottom1) 
	self.labBottom2 = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_labBottom2) 
	self.imageStone1 = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageStone1) 
	self.imageStone2 = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageStone2) 
	self.imageStone3 = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageStone3) 
	self.labDurance = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_labDurance) 
	self.imageRed  = winMgr:getWindow(prefix..Workshopitemcell3.mWndName_imageRed) --Workshopitemcell3.mWndName_imageRed 

    self.iamgeCanEquip = winMgr:getWindow(prefix.."workshopitemcell/back/kechuandai") 

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	
	--parent:addChildWindow(self.m_pMainFrame)
	
end

function Workshopitemcell3:RefreshVisibleWithType(eType)
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

return Workshopitemcell3


