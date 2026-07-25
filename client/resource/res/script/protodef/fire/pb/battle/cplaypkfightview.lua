require "utils.tableutil"
CPlayPKFightView = {}
CPlayPKFightView.__index = CPlayPKFightView



CPlayPKFightView.PROTOCOL_TYPE = 793683

function CPlayPKFightView.Create()
	print("enter CPlayPKFightView create")
	return CPlayPKFightView:new()
end
function CPlayPKFightView:new()
	local self = {}
	setmetatable(self, CPlayPKFightView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.school = 0
	self.levelindex = 0

	return self
end
function CPlayPKFightView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPlayPKFightView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.levelindex)
	return _os_
end

function CPlayPKFightView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.levelindex = _os_:unmarshal_int32()
	return _os_
end

return CPlayPKFightView
