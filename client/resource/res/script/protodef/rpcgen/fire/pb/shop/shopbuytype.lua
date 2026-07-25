require "utils.tableutil"
ShopBuyType = {
	NORMAL_SHOP = 1,
	PET_SHOP = 2,
	MALL_SHOP = 3,
	CHAMBER_OF_COMMERCE_SHOP_BUY = 4,
	CHAMBER_OF_COMMERCE_SHOP_SALE = 5,
	EXCHANGE_BUY = 6,
	SHENSHOU_SHOP = 7
}
ShopBuyType.__index = ShopBuyType


function ShopBuyType:new()
	local self = {}
	setmetatable(self, ShopBuyType)
	return self
end
function ShopBuyType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function ShopBuyType:unmarshal(_os_)
	return _os_
end

return ShopBuyType
