require "utils.tableutil"
SVisitNpcContainChatMsg = {}
SVisitNpcContainChatMsg.__index = SVisitNpcContainChatMsg



SVisitNpcContainChatMsg.PROTOCOL_TYPE = 795526

function SVisitNpcContainChatMsg.Create()
	print("enter SVisitNpcContainChatMsg create")
	return SVisitNpcContainChatMsg:new()
end
function SVisitNpcContainChatMsg:new()
	local self = {}
	setmetatable(self, SVisitNpcContainChatMsg)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.services = {}
	self.scenarioquests = {}
	self.msgid = 0
	self.parameters = {}

	return self
end
function SVisitNpcContainChatMsg:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SVisitNpcContainChatMsg:marshal(ostream)
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

	_os_:marshal_int32(self.msgid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.parameters))
	for k,v in ipairs(self.parameters) do
		_os_: marshal_octets(v)
	end

	return _os_
end

function SVisitNpcContainChatMsg:unmarshal(_os_)
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
	self.msgid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_parameters=0,_os_null_parameters
	_os_null_parameters, sizeof_parameters = _os_: uncompact_uint32(sizeof_parameters)
	for k = 1,sizeof_parameters do
		self.parameters[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.parameters[k])
	end
	return _os_
end

return SVisitNpcContainChatMsg
