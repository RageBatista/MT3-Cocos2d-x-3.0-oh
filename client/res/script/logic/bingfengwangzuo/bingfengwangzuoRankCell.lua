bingfengwangzuoRankCell = {}

setmetatable(bingfengwangzuoRankCell, Dialog)
bingfengwangzuoRankCell.__index = bingfengwangzuoRankCell
local prefix = 0

function bingfengwangzuoRankCell.CreateNewDlg(parent)
	local newDlg = bingfengwangzuoRankCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function bingfengwangzuoRankCell.GetLayoutFileName()
	return "bingfengwangzuopaihangcell_mtg.layout"
end

function bingfengwangzuoRankCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuoRankCell)
	return self
end

function bingfengwangzuoRankCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.rank = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/paiming")
	self.name = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/wanjia")
	self.score = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/guanshu")
	self.time = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/haoshi")
	self.ccrank = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/ccrank")

end

function bingfengwangzuoRankCell:reloadData( data )
    self.rank:setText(data.rank)
    self.name:setText(data.rolename)
    self.score:setText(data.stage)
    self.time:setText(data.times)

    -- 根据排名设置ccrank的图片
    if data.rank == 1 then
        self.ccrank:setProperty("Image","set:ccui image:no1");
    elseif data.rank == 2 then
        self.ccrank:setProperty("Image","set:ccui image:no2");
    elseif data.rank == 3 then
        self.ccrank:setProperty("Image","set:ccui image:no3");
    else
        self.ccrank:setProperty("Image","");
    end
end

return bingfengwangzuoRankCell
