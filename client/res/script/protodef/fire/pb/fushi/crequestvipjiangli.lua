require "utils.tableutil"
CRequestVipJiangli = {}
CRequestVipJiangli.__index = CRequestVipJiangli



CRequestVipJiangli.PROTOCOL_TYPE = 812488

function CRequestVipJiangli.Create()
	print("enter CRequestVipJiangli create")
	return CRequestVipJiangli:new()
end
function CRequestVipJiangli:new()
	local self = {}
	setmetatable(self, CRequestVipJiangli)
	self.type = self.PROTOCOL_TYPE
	self.bounusindex = 0

	return self
end
function CRequestVipJiangli:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestVipJiangli:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.bounusindex)
	return _os_
end

function CRequestVipJiangli:unmarshal(_os_)
	self.bounusindex = _os_:unmarshal_int32()
	return _os_
end

return CRequestVipJiangli
