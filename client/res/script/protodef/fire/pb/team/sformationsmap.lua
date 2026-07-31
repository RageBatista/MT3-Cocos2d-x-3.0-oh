require "utils.tableutil"
require "protodef.rpcgen.fire.pb.formbean"
SFormationsMap = {}
SFormationsMap.__index = SFormationsMap



SFormationsMap.PROTOCOL_TYPE = 794551

function SFormationsMap.Create()
	print("enter SFormationsMap create")
	return SFormationsMap:new()
end
function SFormationsMap:new()
	local self = {}
	setmetatable(self, SFormationsMap)
	self.type = self.PROTOCOL_TYPE
	self.formationmap = {}

	return self
end
function SFormationsMap:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFormationsMap:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.formationmap))
	for k,v in pairs(self.formationmap) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SFormationsMap:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_formationmap=0,_os_null_formationmap
	_os_null_formationmap, sizeof_formationmap = _os_: uncompact_uint32(sizeof_formationmap)
	for k = 1,sizeof_formationmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=FormBean:new()

		newvalue:unmarshal(_os_)

		self.formationmap[newkey] = newvalue
	end
	return _os_
end

return SFormationsMap
