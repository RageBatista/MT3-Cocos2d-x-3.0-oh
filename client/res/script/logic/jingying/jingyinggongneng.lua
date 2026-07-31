
JingyingendPic = {}
function JingyingendPic.New()
    local self = {}
    self.nNum = 0
    self.pItemName = nil
    self.pItemGuang = nil
    self.nItemId = 0
    self.btnItemPic = nil
    self.pItemCell = nil
    
    return self
end

function JingyingendPic.hideItem(oneItem)
    oneItem.pItemCell:setVisible(false)
end

function JingyingendPic.showItem(oneItem)
    oneItem.pItemCell:setVisible(true)
end
