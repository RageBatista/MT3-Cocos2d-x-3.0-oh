require "utils.tableutil"
SUpdateExtSkill = {}
SUpdateExtSkill.__index = SUpdateExtSkill



SUpdateExtSkill.PROTOCOL_TYPE = 800489

function SUpdateExtSkill.Create()
	print("enter SUpdateExtSkill create")
	return SUpdateExtSkill:new()
end
function SUpdateExtSkill:new()
	local self = {}
	setmetatable(self, SUpdateExtSkill)
	self.type = self.PROTOCOL_TYPE
	self.extskilllists = {}

	return self
end
function SUpdateExtSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateExtSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.extskilllists))
	for k,v in pairs(self.extskilllists) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SUpdateExtSkill:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_extskilllists=0,_os_null_extskilllists
	_os_null_extskilllists, sizeof_extskilllists = _os_: uncompact_uint32(sizeof_extskilllists)
	for k = 1,sizeof_extskilllists do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.extskilllists[newkey] = newvalue
	end
	return _os_
end

return SUpdateExtSkill
