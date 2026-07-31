require "utils.tableutil"

ZuoQiPetKey = {}
ZuoQiPetKey.__index = ZuoQiPetKey


function ZuoQiPetKey:new()
	local self = {}
	setmetatable(self, ZuoQiPetKey)

	self.petkeys = {}

	return self
end
function ZuoQiPetKey:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	
	_os_:compact_uint32(TableUtil.tablelength(self.petkeys))
	for k,v in ipairs(self.petkeys) do
		----------------marshal bean
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	return _os_
end

function ZuoQiPetKey:unmarshal(_os_)


	local sizeof_petkeys=0,_os_null_petkeys
	_os_null_petkeys, sizeof_petkeys = _os_: uncompact_uint32(sizeof_petkeys)
	for k = 1,sizeof_petkeys do
		local newkey = _os_:unmarshal_int32()
		local newv = _os_:unmarshal_int32()
		self.petkeys[newkey]=newv
	end
	return _os_
end

return ZuoQiPetKey
