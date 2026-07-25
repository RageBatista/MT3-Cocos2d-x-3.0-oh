require "utils.tableutil"
CXshGiveGift = {}
CXshGiveGift.__index = CXshGiveGift



CXshGiveGift.PROTOCOL_TYPE = 806649

function CXshGiveGift.Create()
	print("enter CXshGiveGift create")
	return CXshGiveGift:new()
end
function CXshGiveGift:new()
	local self = {}
	setmetatable(self, CXshGiveGift)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.itemnum = 0
	self.content = "" 
	self.force = 0

	return self
end
function CXshGiveGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CXshGiveGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_char(self.itemnum)
	_os_:marshal_wstring(self.content)
	_os_:marshal_char(self.force)
	return _os_
end

function CXshGiveGift:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_char()
	self.content = _os_:unmarshal_wstring(self.content)
	self.force = _os_:unmarshal_char()
	return _os_
end

return CXshGiveGift
