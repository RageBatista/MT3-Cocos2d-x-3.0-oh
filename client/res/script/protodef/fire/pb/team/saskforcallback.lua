require "utils.tableutil"
SAskforCallBack = {}
SAskforCallBack.__index = SAskforCallBack



SAskforCallBack.PROTOCOL_TYPE = 794456

function SAskforCallBack.Create()
	print("enter SAskforCallBack create")
	return SAskforCallBack:new()
end
function SAskforCallBack:new()
	local self = {}
	setmetatable(self, SAskforCallBack)
	self.type = self.PROTOCOL_TYPE
	self.leaderid = 0

	return self
end
function SAskforCallBack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAskforCallBack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.leaderid)
	return _os_
end

function SAskforCallBack:unmarshal(_os_)
	self.leaderid = _os_:unmarshal_int64()
	return _os_
end

return SAskforCallBack
