require "utils.tableutil"
CChangeShizhuangGouMai = {}
CChangeShizhuangGouMai.__index = CChangeShizhuangGouMai



CChangeShizhuangGouMai.PROTOCOL_TYPE = 800012

function CChangeShizhuangGouMai.Create()
	print("enter CChangeSchool create")
	return CChangeShizhuangGouMai:new()
end
function CChangeShizhuangGouMai:new()
	local self = {}
	setmetatable(self, CChangeShizhuangGouMai)
	self.type = self.PROTOCOL_TYPE
	self.shizhuangid = 0
	return self
end
function CChangeShizhuangGouMai:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeShizhuangGouMai:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shizhuangid)
	return _os_
end

function CChangeShizhuangGouMai:unmarshal(_os_)
	self.shizhuangid = _os_:unmarshal_int32()
	return _os_
end

return CChangeShizhuangGouMai
