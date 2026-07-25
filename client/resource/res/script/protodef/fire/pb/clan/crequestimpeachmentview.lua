require "utils.tableutil"
CRequestImpeachMentView = {}
CRequestImpeachMentView.__index = CRequestImpeachMentView



CRequestImpeachMentView.PROTOCOL_TYPE = 808526

function CRequestImpeachMentView.Create()
	print("enter CRequestImpeachMentView create")
	return CRequestImpeachMentView:new()
end
function CRequestImpeachMentView:new()
	local self = {}
	setmetatable(self, CRequestImpeachMentView)
	self.type = self.PROTOCOL_TYPE
	self.cmdtype = 0

	return self
end
function CRequestImpeachMentView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestImpeachMentView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.cmdtype)
	return _os_
end

function CRequestImpeachMentView:unmarshal(_os_)
	self.cmdtype = _os_:unmarshal_char()
	return _os_
end

return CRequestImpeachMentView
