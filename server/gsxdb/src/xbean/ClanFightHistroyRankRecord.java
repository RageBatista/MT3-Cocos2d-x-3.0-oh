
package xbean;

public interface ClanFightHistroyRankRecord extends mkdb.Bean {
	public ClanFightHistroyRankRecord copy(); // 深拷贝
	public ClanFightHistroyRankRecord toData(); // 一个 Data 实例
	public ClanFightHistroyRankRecord toBean(); // 一个 Bean 实例
	public ClanFightHistroyRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanFightHistroyRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTriggertime(); // 
	public xbean.MarshalClanFightHistroyRankRecord getMarshaldata(); // 

	public void setTriggertime(long _v_); // 
}
