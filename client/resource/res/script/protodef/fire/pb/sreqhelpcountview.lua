require "utils.tableutil"
SReqHelpCountView = {}
SReqHelpCountView.__index = SReqHelpCountView



SReqHelpCountView.PROTOCOL_TYPE = 786533

function SReqHelpCountView.Create()
	print("enter SReqHelpCountView create")
	return SReqHelpCountView:new()
end
function SReqHelpCountView:new()
	local self = {}
	setmetatable(self, SReqHelpCountView)
	self.type = self.PROTOCOL_TYPE
	self.expvalue = 0
	self.expvaluemax = 0
	self.shengwangvalue = 0
	self.shengwangvaluemax = 0
	self.factionvalue = 0
	self.factionvaluemax = 0
	self.helpgiveitemnum = 0
	self.helpgiveitemnummax = 0
	self.helpitemnum = 0
	self.helpitemnummax = 0

	return self
end
function SReqHelpCountView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqHelpCountView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.expvalue)
	_os_:marshal_int64(self.expvaluemax)
	_os_:marshal_int32(self.shengwangvalue)
	_os_:marshal_int32(self.shengwangvaluemax)
	_os_:marshal_int32(self.factionvalue)
	_os_:marshal_int32(self.factionvaluemax)
	_os_:marshal_int32(self.helpgiveitemnum)
	_os_:marshal_int32(self.helpgiveitemnummax)
	_os_:marshal_int32(self.helpitemnum)
	_os_:marshal_int32(self.helpitemnummax)
	return _os_
end

function SReqHelpCountView:unmarshal(_os_)
	self.expvalue = _os_:unmarshal_int64()
	self.expvaluemax = _os_:unmarshal_int64()
	self.shengwangvalue = _os_:unmarshal_int32()
	self.shengwangvaluemax = _os_:unmarshal_int32()
	self.factionvalue = _os_:unmarshal_int32()
	self.factionvaluemax = _os_:unmarshal_int32()
	self.helpgiveitemnum = _os_:unmarshal_int32()
	self.helpgiveitemnummax = _os_:unmarshal_int32()
	self.helpitemnum = _os_:unmarshal_int32()
	self.helpitemnummax = _os_:unmarshal_int32()
	return _os_
end

return SReqHelpCountView
