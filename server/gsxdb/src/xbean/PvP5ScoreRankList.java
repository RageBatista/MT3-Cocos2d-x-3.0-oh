
package xbean;

public interface PvP5ScoreRankList extends mkdb.Bean {
	public PvP5ScoreRankList copy(); // 深拷贝
	public PvP5ScoreRankList toData(); // 一个 Data 实例
	public PvP5ScoreRankList toBean(); // 一个 Bean 实例
	public PvP5ScoreRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP5ScoreRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.PvP5ScoreRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.PvP5ScoreRecord> getRecordsAsData(); // 所有的记录

}
