require "utils.tableutil"
require "protodef.rpcgen.fire.pb.buff.buff"
SBuffChangeResult = {}
SBuffChangeResult.__index = SBuffChangeResult



SBuffChangeResult.PROTOCOL_TYPE = 796442

function SBuffChangeResult.Create()
	print("enter SBuffChangeResult create")
	return SBuffChangeResult:new()
end
function SBuffChangeResult:new()
	local self = {}
	setmetatable(self, SBuffChangeResult)
	self.type = self.PROTOCOL_TYPE
	self.agenttype = 0
	self.id = 0
	self.petid = 0
	self.addedbuffs = {}
	self.deletedbuffs = {}

	return self
end
function SBuffChangeResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBuffChangeResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.agenttype)
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.petid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.addedbuffs))
	for k,v in pairs(self.addedbuffs) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.deletedbuffs))
	for k,v in ipairs(self.deletedbuffs) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SBuffChangeResult:unmarshal(_os_)
	self.agenttype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int64()
	self.petid = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_addedbuffs=0,_os_null_addedbuffs
	_os_null_addedbuffs, sizeof_addedbuffs = _os_: uncompact_uint32(sizeof_addedbuffs)
	for k = 1,sizeof_addedbuffs do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=Buff:new()

		newvalue:unmarshal(_os_)

		self.addedbuffs[newkey] = newvalue
	end
	----------------unmarshal list
	local sizeof_deletedbuffs=0 ,_os_null_deletedbuffs
	_os_null_deletedbuffs, sizeof_deletedbuffs = _os_: uncompact_uint32(sizeof_deletedbuffs)
	for k = 1,sizeof_deletedbuffs do
		self.deletedbuffs[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SBuffChangeResult
