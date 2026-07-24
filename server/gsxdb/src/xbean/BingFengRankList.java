
package xbean;

public interface BingFengRankList extends mkdb.Bean {
	public BingFengRankList copy(); // 深拷贝
	public BingFengRankList toData(); // 一个 Data 实例
	public BingFengRankList toBean(); // 一个 Bean 实例
	public BingFengRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BingFengRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.BingFengListRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.BingFengListRecord> getRecordsAsData(); // 所有的记录

}
