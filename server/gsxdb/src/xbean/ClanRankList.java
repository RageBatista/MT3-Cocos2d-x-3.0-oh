
package xbean;

public interface ClanRankList extends mkdb.Bean {
	public ClanRankList copy(); // 深拷贝
	public ClanRankList toData(); // 一个 Data 实例
	public ClanRankList toBean(); // 一个 Bean 实例
	public ClanRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ClanRankRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.ClanRankRecord> getRecordsAsData(); // 所有的记录

}
