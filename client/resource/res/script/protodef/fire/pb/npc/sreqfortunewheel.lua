require "utils.tableutil"
require "protodef.rpcgen.fire.pb.npc.forturnewheeltype"
SReqFortuneWheel = {}
SReqFortuneWheel.__index = SReqFortuneWheel



SReqFortuneWheel.PROTOCOL_TYPE = 795445

function SReqFortuneWheel.Create()
	print("enter SReqFortuneWheel create")
	return SReqFortuneWheel:new()
end
function SReqFortuneWheel:new()
	local self = {}
	setmetatable(self, SReqFortuneWheel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.serviceid = 0
	self.itemids = {}
	self.index = 0
	self.flag = 0

	return self
end
function SReqFortuneWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqFortuneWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.serviceid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.itemids))
	for k,v in ipairs(self.itemids) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.index)
	_os_:marshal_char(self.flag)
	return _os_
end

function SReqFortuneWheel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.serviceid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_itemids=0,_os_null_itemids
	_os_null_itemids, sizeof_itemids = _os_: uncompact_uint32(sizeof_itemids)
	for k = 1,sizeof_itemids do
		----------------unmarshal bean
		self.itemids[k]=ForturneWheelType:new()

		self.itemids[k]:unmarshal(_os_)

	end
	self.index = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	return _os_
end

return SReqFortuneWheel
