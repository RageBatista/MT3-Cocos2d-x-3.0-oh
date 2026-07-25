require "utils.tableutil"
SCreateRoleError = {
	CREATE_OK = 1,
	CREATE_ERROR = 2,
	CREATE_INVALID = 3,
	CREATE_DUPLICATED = 4,
	CREATE_OVERCOUNT = 5,
	CREATE_OVERLEN = 6,
	CREATE_SHORTLEN = 7,
	CREATE_CREATE_GM_FORBID = 8
}
SCreateRoleError.__index = SCreateRoleError



SCreateRoleError.PROTOCOL_TYPE = 786440

function SCreateRoleError.Create()
	print("enter SCreateRoleError create")
	return SCreateRoleError:new()
end
function SCreateRoleError:new()
	local self = {}
	setmetatable(self, SCreateRoleError)
	self.type = self.PROTOCOL_TYPE
	self.err = 0

	return self
end
function SCreateRoleError:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCreateRoleError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.err)
	return _os_
end

function SCreateRoleError:unmarshal(_os_)
	self.err = _os_:unmarshal_int32()
	return _os_
end

return SCreateRoleError
