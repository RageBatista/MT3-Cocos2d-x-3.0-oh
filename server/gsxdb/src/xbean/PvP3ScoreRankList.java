
package xbean;

public interface PvP3ScoreRankList extends mkdb.Bean {
	public PvP3ScoreRankList copy(); // 深拷贝
	public PvP3ScoreRankList toData(); // 一个 Data 实例
	public PvP3ScoreRankList toBean(); // 一个 Bean 实例
	public PvP3ScoreRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP3ScoreRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.PvP3ScoreRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.PvP3ScoreRecord> getRecordsAsData(); // 所有的记录

}
