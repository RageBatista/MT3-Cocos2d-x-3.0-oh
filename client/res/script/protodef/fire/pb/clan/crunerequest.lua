require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.runerequestinfo"
CRuneRequest = {}
CRuneRequest.__index = CRuneRequest



CRuneRequest.PROTOCOL_TYPE = 808511

function CRuneRequest.Create()
	print("enter CRuneRequest create")
	return CRuneRequest:new()
end
function CRuneRequest:new()
	local self = {}
	setmetatable(self, CRuneRequest)
	self.type = self.PROTOCOL_TYPE
	self.runerequestinfolist = {}

	return self
end
function CRuneRequest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRuneRequest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.runerequestinfolist))
	for k,v in ipairs(self.runerequestinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function CRuneRequest:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_runerequestinfolist=0,_os_null_runerequestinfolist
	_os_null_runerequestinfolist, sizeof_runerequestinfolist = _os_: uncompact_uint32(sizeof_runerequestinfolist)
	for k = 1,sizeof_runerequestinfolist do
		----------------unmarshal bean
		self.runerequestinfolist[k]=RuneRequestInfo:new()

		self.runerequestinfolist[k]:unmarshal(_os_)

	end
	return _os_
end

return CRuneRequest
