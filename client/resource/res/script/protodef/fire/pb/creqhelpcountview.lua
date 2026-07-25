require "utils.tableutil"
CReqHelpCountView = {}
CReqHelpCountView.__index = CReqHelpCountView



CReqHelpCountView.PROTOCOL_TYPE = 786532

function CReqHelpCountView.Create()
	print("enter CReqHelpCountView create")
	return CReqHelpCountView:new()
end
function CReqHelpCountView:new()
	local self = {}
	setmetatable(self, CReqHelpCountView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqHelpCountView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqHelpCountView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqHelpCountView:unmarshal(_os_)
	return _os_
end

return CReqHelpCountView
