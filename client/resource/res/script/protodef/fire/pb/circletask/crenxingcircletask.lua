require "utils.tableutil"
CRenXingCircleTask = {}
CRenXingCircleTask.__index = CRenXingCircleTask



CRenXingCircleTask.PROTOCOL_TYPE = 807451

function CRenXingCircleTask.Create()
	print("enter CRenXingCircleTask create")
	return CRenXingCircleTask:new()
end
function CRenXingCircleTask:new()
	local self = {}
	setmetatable(self, CRenXingCircleTask)
	self.type = self.PROTOCOL_TYPE
	self.serviceid = 0
	self.moneytype = 0

	return self
end
function CRenXingCircleTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRenXingCircleTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.serviceid)
	_os_:marshal_int32(self.moneytype)
	return _os_
end

function CRenXingCircleTask:unmarshal(_os_)
	self.serviceid = _os_:unmarshal_int32()
	self.moneytype = _os_:unmarshal_int32()
	return _os_
end

return CRenXingCircleTask
