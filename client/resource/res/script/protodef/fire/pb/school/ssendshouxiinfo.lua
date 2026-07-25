require "utils.tableutil"
require "protodef.rpcgen.fire.pb.school.shouxiinfo"
SSendShouxiInfo = {}
SSendShouxiInfo.__index = SSendShouxiInfo



SSendShouxiInfo.PROTOCOL_TYPE = 810433

function SSendShouxiInfo.Create()
	print("enter SSendShouxiInfo create")
	return SSendShouxiInfo:new()
end
function SSendShouxiInfo:new()
	local self = {}
	setmetatable(self, SSendShouxiInfo)
	self.type = self.PROTOCOL_TYPE
	self.shouxi = ShouxiInfo:new()
	self.shouxikey = 0

	return self
end
function SSendShouxiInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendShouxiInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.shouxi:marshal(_os_) 
	_os_:marshal_int64(self.shouxikey)
	return _os_
end

function SSendShouxiInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.shouxi:unmarshal(_os_)

	self.shouxikey = _os_:unmarshal_int64()
	return _os_
end

return SSendShouxiInfo
