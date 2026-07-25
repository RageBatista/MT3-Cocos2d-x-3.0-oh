require "utils.tableutil"
Buff = {}
Buff.__index = Buff


function Buff:new()
	local self = {}
	setmetatable(self, Buff)
	self.time = 0
	self.count = 0
	self.tipargs = {}

	return self
end
function Buff:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.time)
	_os_:marshal_int32(self.count)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.tipargs))
	for k,v in ipairs(self.tipargs) do
		_os_: marshal_octets(v)
	end

	return _os_
end

function Buff:unmarshal(_os_)
	self.time = _os_:unmarshal_int64()
	self.count = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_tipargs=0 ,_os_null_tipargs
	_os_null_tipargs, sizeof_tipargs = _os_: uncompact_uint32(sizeof_tipargs)
	for k = 1,sizeof_tipargs do
		self.tipargs[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.tipargs[k])
	end
	return _os_
end

return Buff
