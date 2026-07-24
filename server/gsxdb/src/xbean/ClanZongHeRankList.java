
package xbean;

public interface ClanZongHeRankList extends mkdb.Bean {
	public ClanZongHeRankList copy(); // 深拷贝
	public ClanZongHeRankList toData(); // 一个 Data 实例
	public ClanZongHeRankList toBean(); // 一个 Bean 实例
	public ClanZongHeRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanZongHeRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ClanZongHeRankRecord> getRecords(); // 
	public java.util.List<xbean.ClanZongHeRankRecord> getRecordsAsData(); // 

}
