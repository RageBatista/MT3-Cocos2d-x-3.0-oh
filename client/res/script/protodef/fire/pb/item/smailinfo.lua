require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.mailinfo"
SMailInfo = {}
SMailInfo.__index = SMailInfo



SMailInfo.PROTOCOL_TYPE = 787705

function SMailInfo.Create()
	print("enter SMailInfo create")
	return SMailInfo:new()
end
function SMailInfo:new()
	local self = {}
	setmetatable(self, SMailInfo)
	self.type = self.PROTOCOL_TYPE
	self.mail = MailInfo:new()

	return self
end
function SMailInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMailInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.mail:marshal(_os_) 
	return _os_
end

function SMailInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.mail:unmarshal(_os_)

	return _os_
end

return SMailInfo
