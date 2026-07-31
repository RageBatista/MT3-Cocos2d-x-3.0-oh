require "utils.tableutil"
CChangeShizhuangShiYong = {}
CChangeShizhuangShiYong.__index = CChangeShizhuangShiYong



CChangeShizhuangShiYong.PROTOCOL_TYPE = 800011

function CChangeShizhuangShiYong.Create()
	print("enter CChangeSchool create")
	return CChangeShizhuangShiYong:new()
end
function CChangeShizhuangShiYong:new()
	local self = {}
	setmetatable(self, CChangeShizhuangShiYong)
	self.type = self.PROTOCOL_TYPE
	self.shizhuangid = 0
	self.moxing = 0
	return self
end
function CChangeShizhuangShiYong:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeShizhuangShiYong:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shizhuangid)
	_os_:marshal_int32(self.moxing)
	return _os_
end

function CChangeShizhuangShiYong:unmarshal(_os_)
	self.shizhuangid = _os_:unmarshal_int32()
	self.moxing = _os_:unmarshal_int32()
	return _os_
end

return CChangeShizhuangShiYong
