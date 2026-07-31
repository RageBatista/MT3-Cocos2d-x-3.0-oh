require "utils.tableutil"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
SChatItemTips = {}
SChatItemTips.__index = SChatItemTips



SChatItemTips.PROTOCOL_TYPE = 792446

function SChatItemTips.Create()
	print("enter SChatItemTips create")
	return SChatItemTips:new()
end
function SChatItemTips:new()
	local self = {}
	setmetatable(self, SChatItemTips)
	self.type = self.PROTOCOL_TYPE
	self.displayinfo = DisplayInfo:new()
	self.tips = FireNet.Octets() 

	return self
end
function SChatItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChatItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.displayinfo:marshal(_os_) 
	_os_: marshal_octets(self.tips)
	return _os_
end

function SChatItemTips:unmarshal(_os_)
	----------------unmarshal bean

	self.displayinfo:unmarshal(_os_)

	_os_:unmarshal_octets(self.tips)
	return _os_
end

return SChatItemTips
