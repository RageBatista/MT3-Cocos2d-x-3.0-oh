require "utils.tableutil"
require "protodef.rpcgen.fire.pb.rolecolortype"
CReqUseColor = {}
CReqUseColor.__index = CReqUseColor



CReqUseColor.PROTOCOL_TYPE = 786538

function CReqUseColor.Create()
	print("enter CReqUseColor create")
	return CReqUseColor:new()
end
function CReqUseColor:new()
	local self = {}
	setmetatable(self, CReqUseColor)
	self.type = self.PROTOCOL_TYPE
	self.rolecolorinfo = RoleColorType:new()

	return self
end
function CReqUseColor:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqUseColor:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.rolecolorinfo:marshal(_os_) 
	return _os_
end

function CReqUseColor:unmarshal(_os_)
	----------------unmarshal bean

	self.rolecolorinfo:unmarshal(_os_)

	return _os_
end

return CReqUseColor
