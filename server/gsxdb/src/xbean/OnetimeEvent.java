
package xbean;

public interface OnetimeEvent extends mkdb.Bean {
	public OnetimeEvent copy(); // 深拷贝
	public OnetimeEvent toData(); // 一个 Data 实例
	public OnetimeEvent toBean(); // 一个 Bean 实例
	public OnetimeEvent toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OnetimeEvent toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public fire.pb.WorldEventTab.OnetimeTask getOnetimeevent(); // 

	public void setOnetimeevent(fire.pb.WorldEventTab.OnetimeTask _v_); // 
}
