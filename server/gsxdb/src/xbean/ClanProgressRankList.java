
package xbean;

public interface ClanProgressRankList extends mkdb.Bean {
	public ClanProgressRankList copy(); // 深拷贝
	public ClanProgressRankList toData(); // 一个 Data 实例
	public ClanProgressRankList toBean(); // 一个 Bean 实例
	public ClanProgressRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanProgressRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ClanProgressRankRecord> getRecords(); // 
	public java.util.List<xbean.ClanProgressRankRecord> getRecordsAsData(); // 

}
