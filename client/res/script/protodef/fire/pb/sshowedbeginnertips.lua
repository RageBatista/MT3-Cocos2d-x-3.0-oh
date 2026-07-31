require "utils.tableutil"
SShowedBeginnerTips = {}
SShowedBeginnerTips.__index = SShowedBeginnerTips



SShowedBeginnerTips.PROTOCOL_TYPE = 786461

function SShowedBeginnerTips.Create()
	print("enter SShowedBeginnerTips create")
	return SShowedBeginnerTips:new()
end
function SShowedBeginnerTips:new()
	local self = {}
	setmetatable(self, SShowedBeginnerTips)
	self.type = self.PROTOCOL_TYPE
	self.tipid = {}
	self.pilottype = 0

	return self
end
function SShowedBeginnerTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SShowedBeginnerTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal set
	_os_:compact_uint32(TableUtil.tablelength(self.tipid))
	for k,v in pairs(self.tipid) do
		_os_:marshal_int32(k)
	end

	_os_:marshal_int32(self.pilottype)
	return _os_
end

function SShowedBeginnerTips:unmarshal(_os_)
	----------------unmarshal set
	local sizeof_tipid=0,_os_null_tipid
	_os_null_tipid, sizeof_tipid = _os_: uncompact_uint32(sizeof_tipid)
	for k = 1,sizeof_tipid do
		local newkey
		newkey = _os_:unmarshal_int32()
		self.tipid[newkey] = true
	end
	self.pilottype = _os_:unmarshal_int32()
	return _os_
end

return SShowedBeginnerTips
