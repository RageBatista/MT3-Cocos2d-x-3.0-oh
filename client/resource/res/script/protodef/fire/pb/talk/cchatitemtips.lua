require "utils.tableutil"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
CChatItemTips = {}
CChatItemTips.__index = CChatItemTips



CChatItemTips.PROTOCOL_TYPE = 792445

function CChatItemTips.Create()
	print("enter CChatItemTips create")
	return CChatItemTips:new()
end
function CChatItemTips:new()
	local self = {}
	setmetatable(self, CChatItemTips)
	self.type = self.PROTOCOL_TYPE
	self.displayinfo = DisplayInfo:new()

	return self
end
function CChatItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChatItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.displayinfo:marshal(_os_) 
	return _os_
end

function CChatItemTips:unmarshal(_os_)
	----------------unmarshal bean

	self.displayinfo:unmarshal(_os_)

	return _os_
end

return CChatItemTips
