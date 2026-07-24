
package xbean;

public interface TicketItemExInfo extends mkdb.Bean {
	public TicketItemExInfo copy(); // 深拷贝
	public TicketItemExInfo toData(); // 一个 Data 实例
	public TicketItemExInfo toBean(); // 一个 Bean 实例
	public TicketItemExInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TicketItemExInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getTicketcode(); // 
	public com.locojoy.base.Octets getTicketcodeOctets(); // 

	public void setTicketcode(String _v_); // 
	public void setTicketcodeOctets(com.locojoy.base.Octets _v_); // 
}
