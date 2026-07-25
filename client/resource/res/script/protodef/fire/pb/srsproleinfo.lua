require "utils.tableutil"
SRspRoleInfo = {}
SRspRoleInfo.__index = SRspRoleInfo



SRspRoleInfo.PROTOCOL_TYPE = 786509

function SRspRoleInfo.Create()
	print("enter SRspRoleInfo create")
	return SRspRoleInfo:new()
end
function SRspRoleInfo:new()
	local self = {}
	setmetatable(self, SRspRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.hpmpstore = {}
	self.wencaivalue = 0
	self.wuxun = 0
	self.gongde = 0
	self.honour = 0
	self.reqkey = 0

	return self
end
function SRspRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRspRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.hpmpstore))
	for k,v in pairs(self.hpmpstore) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	_os_:marshal_int32(self.wencaivalue)
	_os_:marshal_int32(self.wuxun)
	_os_:marshal_int32(self.gongde)
	_os_:marshal_int64(self.honour)
	_os_:marshal_int32(self.reqkey)
	return _os_
end

function SRspRoleInfo:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_hpmpstore=0,_os_null_hpmpstore
	_os_null_hpmpstore, sizeof_hpmpstore = _os_: uncompact_uint32(sizeof_hpmpstore)
	for k = 1,sizeof_hpmpstore do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.hpmpstore[newkey] = newvalue
	end
	self.wencaivalue = _os_:unmarshal_int32()
	self.wuxun = _os_:unmarshal_int32()
	self.gongde = _os_:unmarshal_int32()
	self.honour = _os_:unmarshal_int64()
	self.reqkey = _os_:unmarshal_int32()
	return _os_
end

return SRspRoleInfo
