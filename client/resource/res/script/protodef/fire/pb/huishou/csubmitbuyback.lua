require "utils.tableutil"
CSubmitBuyBack = {}
CSubmitBuyBack.__index = CSubmitBuyBack



CSubmitBuyBack.PROTOCOL_TYPE = 819409


function CSubmitBuyBack.Create()
	print("enter CSubmitBuyBack create")
	return CSubmitBuyBack:new()
end
function CSubmitBuyBack:new()
	local self = {}
	setmetatable(self, CSubmitBuyBack)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.itemtype = 0
	self.istimelimit = 0
	self.num = 0

	return self
end
function CSubmitBuyBack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSubmitBuyBack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.istimelimit)
	_os_:marshal_int32(self.num)
	return _os_
end

function CSubmitBuyBack:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	self.istimelimit = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end


return CSubmitBuyBack
