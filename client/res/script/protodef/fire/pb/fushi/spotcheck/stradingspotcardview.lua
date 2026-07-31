require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.spotcheck.spotcardinfo"
STradingSpotCardView = {}
STradingSpotCardView.__index = STradingSpotCardView



STradingSpotCardView.PROTOCOL_TYPE = 812638

function STradingSpotCardView.Create()
	print("enter STradingSpotCardView create")
	return STradingSpotCardView:new()
end
function STradingSpotCardView:new()
	local self = {}
	setmetatable(self, STradingSpotCardView)
	self.type = self.PROTOCOL_TYPE
	self.sellspotcardinfolist = {}
	self.buyspotcardinfolist = {}

	return self
end
function STradingSpotCardView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STradingSpotCardView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.sellspotcardinfolist))
	for k,v in ipairs(self.sellspotcardinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.buyspotcardinfolist))
	for k,v in ipairs(self.buyspotcardinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function STradingSpotCardView:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_sellspotcardinfolist=0,_os_null_sellspotcardinfolist
	_os_null_sellspotcardinfolist, sizeof_sellspotcardinfolist = _os_: uncompact_uint32(sizeof_sellspotcardinfolist)
	for k = 1,sizeof_sellspotcardinfolist do
		----------------unmarshal bean
		self.sellspotcardinfolist[k]=SpotCardInfo:new()

		self.sellspotcardinfolist[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_buyspotcardinfolist=0,_os_null_buyspotcardinfolist
	_os_null_buyspotcardinfolist, sizeof_buyspotcardinfolist = _os_: uncompact_uint32(sizeof_buyspotcardinfolist)
	for k = 1,sizeof_buyspotcardinfolist do
		----------------unmarshal bean
		self.buyspotcardinfolist[k]=SpotCardInfo:new()

		self.buyspotcardinfolist[k]:unmarshal(_os_)

	end
	return _os_
end

return STradingSpotCardView
