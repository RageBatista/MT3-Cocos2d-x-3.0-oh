require "utils.tableutil"
SRspServerId = {}
SRspServerId.__index = SRspServerId



SRspServerId.PROTOCOL_TYPE = 812473

function SRspServerId.Create()
	print("enter SRspServerId create")
	return SRspServerId:new()
end
function SRspServerId:new()
	local self = {}
	setmetatable(self, SRspServerId)
	self.type = self.PROTOCOL_TYPE
	self.serverid = 0
	self.flag = 0

	return self
end
function SRspServerId:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRspServerId:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.serverid)
	_os_:marshal_int32(self.flag)
	return _os_
end

function SRspServerId:unmarshal(_os_)
	self.serverid = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return SRspServerId
