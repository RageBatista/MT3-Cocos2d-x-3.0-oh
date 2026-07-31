require "utils.tableutil"
require "protodef.rpcgen.fire.pb.title.titleinfo"
SAddTitle = {}
SAddTitle.__index = SAddTitle



SAddTitle.PROTOCOL_TYPE = 798433

function SAddTitle.Create()
	print("enter SAddTitle create")
	return SAddTitle:new()
end
function SAddTitle:new()
	local self = {}
	setmetatable(self, SAddTitle)
	self.type = self.PROTOCOL_TYPE
	self.info = TitleInfo:new()

	return self
end
function SAddTitle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddTitle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.info:marshal(_os_) 
	return _os_
end

function SAddTitle:unmarshal(_os_)
	----------------unmarshal bean

	self.info:unmarshal(_os_)

	return _os_
end

return SAddTitle
