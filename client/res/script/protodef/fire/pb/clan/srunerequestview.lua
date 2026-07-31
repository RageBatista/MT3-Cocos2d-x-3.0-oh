require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.runerequestinfo"
SRuneRequestView = {}
SRuneRequestView.__index = SRuneRequestView



SRuneRequestView.PROTOCOL_TYPE = 808516

function SRuneRequestView.Create()
	print("enter SRuneRequestView create")
	return SRuneRequestView:new()
end
function SRuneRequestView:new()
	local self = {}
	setmetatable(self, SRuneRequestView)
	self.type = self.PROTOCOL_TYPE
	self.requestnum = 0
	self.runerequestinfolist = {}

	return self
end
function SRuneRequestView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRuneRequestView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.requestnum)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.runerequestinfolist))
	for k,v in ipairs(self.runerequestinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRuneRequestView:unmarshal(_os_)
	self.requestnum = _os_:unmarshal_int32()
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

return SRuneRequestView
