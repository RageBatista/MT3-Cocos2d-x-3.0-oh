
package xbean;

public interface ClanFightRaceRankRecord extends mkdb.Bean {
	public ClanFightRaceRankRecord copy(); // 深拷贝
	public ClanFightRaceRankRecord toData(); // 一个 Data 实例
	public ClanFightRaceRankRecord toBean(); // 一个 Bean 实例
	public ClanFightRaceRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanFightRaceRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTriggertime(); // 
	public xbean.MarshalClanFightRaceRankRecord getMarshaldata(); // 

	public void setTriggertime(long _v_); // 
}
