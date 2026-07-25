require "utils.tableutil"
require "protodef.rpcgen.fire.pb.rolecolortype"
SReqUseColor = {}
SReqUseColor.__index = SReqUseColor



SReqUseColor.PROTOCOL_TYPE = 786539

function SReqUseColor.Create()
	print("enter SReqUseColor create")
	return SReqUseColor:new()
end
function SReqUseColor:new()
	local self = {}
	setmetatable(self, SReqUseColor)
	self.type = self.PROTOCOL_TYPE
	self.rolecolorinfo = RoleColorType:new()

	return self
end
function SReqUseColor:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqUseColor:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.rolecolorinfo:marshal(_os_) 
	return _os_
end

function SReqUseColor:unmarshal(_os_)
	----------------unmarshal bean

	self.rolecolorinfo:unmarshal(_os_)

	return _os_
end

return SReqUseColor
