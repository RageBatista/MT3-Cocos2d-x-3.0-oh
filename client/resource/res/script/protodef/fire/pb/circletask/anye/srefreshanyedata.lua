require "utils.tableutil"
require "protodef.rpcgen.fire.pb.circletask.anye.anyetask"
SRefreshAnYeData = {}
SRefreshAnYeData.__index = SRefreshAnYeData



SRefreshAnYeData.PROTOCOL_TYPE = 807454

function SRefreshAnYeData.Create()
	print("enter SRefreshAnYeData create")
	return SRefreshAnYeData:new()
end
function SRefreshAnYeData:new()
	local self = {}
	setmetatable(self, SRefreshAnYeData)
	self.type = self.PROTOCOL_TYPE
	self.times = 0
	self.renxins = 0
	self.anyetasks = {}
	self.awardexp = 0
	self.awardsilver = 0
	self.swardgold = 0
	self.jointime = 0
	self.legendpos = 0

	return self
end
function SRefreshAnYeData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshAnYeData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.times)
	_os_:marshal_int32(self.renxins)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.anyetasks))
	for k,v in ipairs(self.anyetasks) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int64(self.awardexp)
	_os_:marshal_int64(self.awardsilver)
	_os_:marshal_int64(self.swardgold)
	_os_:marshal_int64(self.jointime)
	_os_:marshal_int32(self.legendpos)
	return _os_
end

function SRefreshAnYeData:unmarshal(_os_)
	self.times = _os_:unmarshal_int32()
	self.renxins = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_anyetasks=0,_os_null_anyetasks
	_os_null_anyetasks, sizeof_anyetasks = _os_: uncompact_uint32(sizeof_anyetasks)
	for k = 1,sizeof_anyetasks do
		----------------unmarshal bean
		self.anyetasks[k]=AnYeTask:new()

		self.anyetasks[k]:unmarshal(_os_)

	end
	self.awardexp = _os_:unmarshal_int64()
	self.awardsilver = _os_:unmarshal_int64()
	self.swardgold = _os_:unmarshal_int64()
	self.jointime = _os_:unmarshal_int64()
	self.legendpos = _os_:unmarshal_int32()
	return _os_
end

return SRefreshAnYeData
