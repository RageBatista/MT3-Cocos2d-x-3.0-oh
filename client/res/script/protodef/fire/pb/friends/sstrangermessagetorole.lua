require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
require "protodef.rpcgen.fire.pb.friends.strangermessagebean"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
SStrangerMessageToRole = {}
SStrangerMessageToRole.__index = SStrangerMessageToRole



SStrangerMessageToRole.PROTOCOL_TYPE = 806443

function SStrangerMessageToRole.Create()
	print("enter SStrangerMessageToRole create")
	return SStrangerMessageToRole:new()
end
function SStrangerMessageToRole:new()
	local self = {}
	setmetatable(self, SStrangerMessageToRole)
	self.type = self.PROTOCOL_TYPE
	self.strangermessage = StrangerMessageBean:new()

	return self
end
function SStrangerMessageToRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SStrangerMessageToRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.strangermessage:marshal(_os_) 
	return _os_
end

function SStrangerMessageToRole:unmarshal(_os_)
	----------------unmarshal bean

	self.strangermessage:unmarshal(_os_)

	return _os_
end

return SStrangerMessageToRole
