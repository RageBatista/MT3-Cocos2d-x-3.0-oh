require "utils.tableutil"
SGeneralSummonCommand = {}
SGeneralSummonCommand.__index = SGeneralSummonCommand



SGeneralSummonCommand.PROTOCOL_TYPE = 795505

function SGeneralSummonCommand.Create()
	print("enter SGeneralSummonCommand create")
	return SGeneralSummonCommand:new()
end
function SGeneralSummonCommand:new()
	local self = {}
	setmetatable(self, SGeneralSummonCommand)
	self.type = self.PROTOCOL_TYPE
	self.summontype = 0
	self.roleid = 0
	self.npckey = 0
	self.mapid = 0
	self.minimal = 0

	return self
end
function SGeneralSummonCommand:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGeneralSummonCommand:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.summontype)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.mapid)
	_os_:marshal_int32(self.minimal)
	return _os_
end

function SGeneralSummonCommand:unmarshal(_os_)
	self.summontype = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.npckey = _os_:unmarshal_int64()
	self.mapid = _os_:unmarshal_int32()
	self.minimal = _os_:unmarshal_int32()
	return _os_
end

return SGeneralSummonCommand
