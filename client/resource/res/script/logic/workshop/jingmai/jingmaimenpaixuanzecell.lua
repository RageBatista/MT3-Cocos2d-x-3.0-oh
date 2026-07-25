require "logic.dialog"

JingMaiMenPaiXuanZeCell = {}
JingMaiMenPaiXuanZeCell.__index = JingMaiMenPaiXuanZeCell

JingMaiMenPaiXuanZeCell.mWndName_btnBg = "jingmaimenpaixuanzecell/back"
JingMaiMenPaiXuanZeCell.mWndName_imageBg = "jingmaimenpaixuanzecell/back/bgimage"
JingMaiMenPaiXuanZeCell.mWndName_labItemName = "jingmaimenpaixuanzecell/back/name"

function JingMaiMenPaiXuanZeCell.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, JingMaiMenPaiXuanZeCell)
	newcell.__index = JingMaiMenPaiXuanZeCell
	newcell:OnCreate(parent, prefix)

		local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
		local offset = height * posindex or 1
		newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))

	--JingMaiMenPaiXuanZeCell.id = JingMaiMenPaiXuanZeCell.id + 1
	return newcell
end

function JingMaiMenPaiXuanZeCell:OnCreate(parent, prefix)

	if prefix then
		print("JingMaiMenPaiXuanZeCell=prefix="..prefix)
	else
		print("JingMaiMenPaiXuanZeCell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "jingmaimenpaixuanzecell.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("JingMaiMenPaiXuanZeCell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)


	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..JingMaiMenPaiXuanZeCell.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..JingMaiMenPaiXuanZeCell.mWndName_btnBg))
	--toGroupButton
	self.btnBg:EnableClickAni(false)
	self.imageBg = winMgr:getWindow(prefix..JingMaiMenPaiXuanZeCell.mWndName_imageBg)
	self.labItemName = winMgr:getWindow(prefix..JingMaiMenPaiXuanZeCell.mWndName_labItemName)
	
	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	if parent then
		parent:addChildWindow(self.m_pMainFrame)
	end

end

--function JingMaiMenPaiXuanZeCell:RefreshVisibleWithType(eType)
--	self.imageHaveEquiped:setVisible(false)
--	self.imageCanMake:setVisible(false)
--	self.labBottom1:setVisible(false)
--	self.labBottom2:setVisible(false)
--	self.imageStone1:setVisible(false)
--	self.imageStone2:setVisible(false)
--	self.labDurance:setVisible(false)
--	--self.imageAdd:setVisible(false)
--	--self.labHeChengGem:setVisible(false)
--	self.imageRed:setVisible(false)
--
--	if eType == 1 then
--		self.labBottom1:setVisible(true)
--		self.labBottom2:setVisible(true)
--	elseif eType==2 then
--		self.imageStone1:setVisible(true)
--		self.imageStone2:setVisible(true)
--	elseif eType==3 then
--		self.labBottom1:setVisible(true)
--	elseif eType==4 then
--		self.labBottom1:setVisible(true)
--		self.labDurance:setVisible(true)
--	elseif eType==5 then --baoshi
--		self.labBottom1:setVisible(true)
--	elseif eType==6 then --jiabaoshi
--		--self.imageAdd.setVisible(true)
--		--self.labHeChengGem.setVisible(true)
--	end
--end

function JingMaiMenPaiXuanZeCell.GetLayoutFileName()
	--return "xingyindzitemcell.layout"
end

function JingMaiMenPaiXuanZeCell:DestroyDialog()
	self:OnClose()
end

function JingMaiMenPaiXuanZeCell:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return JingMaiMenPaiXuanZeCell


