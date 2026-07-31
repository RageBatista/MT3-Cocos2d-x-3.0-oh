require "utils.tableutil"
CReqColorRoomView = {}
CReqColorRoomView.__index = CReqColorRoomView



CReqColorRoomView.PROTOCOL_TYPE = 786534

function CReqColorRoomView.Create()
	print("enter CReqColorRoomView create")
	return CReqColorRoomView:new()
end
function CReqColorRoomView:new()
	local self = {}
	setmetatable(self, CReqColorRoomView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqColorRoomView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqColorRoomView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqColorRoomView:unmarshal(_os_)
	return _os_
end

return CReqColorRoomView
