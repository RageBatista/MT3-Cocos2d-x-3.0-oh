require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.spotcheck.roletradingrecord"
SRoleTradingRecordView = {}
SRoleTradingRecordView.__index = SRoleTradingRecordView



SRoleTradingRecordView.PROTOCOL_TYPE = 812642

function SRoleTradingRecordView.Create()
	print("enter SRoleTradingRecordView create")
	return SRoleTradingRecordView:new()
end
function SRoleTradingRecordView:new()
	local self = {}
	setmetatable(self, SRoleTradingRecordView)
	self.type = self.PROTOCOL_TYPE
	self.roletradingrecordlist = {}

	return self
end
function SRoleTradingRecordView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleTradingRecordView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.roletradingrecordlist))
	for k,v in ipairs(self.roletradingrecordlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRoleTradingRecordView:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_roletradingrecordlist=0,_os_null_roletradingrecordlist
	_os_null_roletradingrecordlist, sizeof_roletradingrecordlist = _os_: uncompact_uint32(sizeof_roletradingrecordlist)
	for k = 1,sizeof_roletradingrecordlist do
		----------------unmarshal bean
		self.roletradingrecordlist[k]=RoleTradingRecord:new()

		self.roletradingrecordlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRoleTradingRecordView
