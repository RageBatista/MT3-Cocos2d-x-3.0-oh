--debugrequire "logic.zhenfa.zhenfadlg".getInstanceAndShow()
--debugrequire "logic.shop.goodscell"
debugrequire "logic.shop.stalldownshelf"
debugrequire "logic.pet.petdetaildlg"

--debugrequire "utils.commonutil"



--[[require("logic.shop.shoplabel").DestroyDialog()
debugrequire "logic.shop.stalldlg"
require("logic.shop.shoplabel").getInstance():showOnly(2)--]]



--[[require("logic.pet.petlabel").DestroyDialog()
debugrequire "logic.pet.petlianyaodlg"
require("logic.pet.petlabel").getInstance():ShowOnly(2)--]]



--[[debugrequire "logic.shop.stallpetupshelf"
local dlg = StallPetUpShelf.getInstanceAndShow()
local petData = MainPetDataManager.getInstance():getPet(1)
if petData then
	dlg:setPetData(petData)
end--]]


--collectgarbage("collect")
