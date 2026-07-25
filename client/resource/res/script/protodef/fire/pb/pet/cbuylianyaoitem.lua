require "utils.tableutil"
CBuyLianYaoItem = {}
CBuyLianYaoItem.__index = CBuyLianYaoItem



CBuyLianYaoItem.PROTOCOL_TYPE = 810519

function CBuyLianYaoItem.Create()
	print("enter CBuyLianYaoItem create")
	return CBuyLianYaoItem:new()
end
function CBuyLianYaoItem:new()
	local self = {}
	setmetatable(self, CBuyLianYaoItem)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.buynum = 0
 

	return self
end
function CBuyLianYaoItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuyLianYaoItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.buynum)
 
	return _os_
end

function CBuyLianYaoItem:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.buynum = _os_:unmarshal_int32()
	return _os_
end

return CBuyLianYaoItem
