require "utils.tableutil"
SVisitNpc = {}
SVisitNpc.__index = SVisitNpc



SVisitNpc.PROTOCOL_TYPE = 795434

function SVisitNpc.Create()
	print("enter SVisitNpc create")
	return SVisitNpc:new()
end
function SVisitNpc:new()
	local self = {}
	setmetatable(self, SVisitNpc)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.services = {}
	self.scenarioquests = {}

	return self
end
function SVisitNpc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SVisitNpc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.services))
	for k,v in ipairs(self.services) do
		_os_:marshal_int32(v)
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.scenarioquests))
	for k,v in ipairs(self.scenarioquests) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SVisitNpc:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	----------------unmarshal vector
	local sizeof_services=0,_os_null_services
	_os_null_services, sizeof_services = _os_: uncompact_uint32(sizeof_services)
	for k = 1,sizeof_services do
		self.services[k] = _os_:unmarshal_int32()
	end
	----------------unmarshal vector
	local sizeof_scenarioquests=0,_os_null_scenarioquests
	_os_null_scenarioquests, sizeof_scenarioquests = _os_: uncompact_uint32(sizeof_scenarioquests)
	for k = 1,sizeof_scenarioquests do
		self.scenarioquests[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SVisitNpc
