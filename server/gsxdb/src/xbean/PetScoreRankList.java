
package xbean;

public interface PetScoreRankList extends mkdb.Bean {
	public PetScoreRankList copy(); // 深拷贝
	public PetScoreRankList toData(); // 一个 Data 实例
	public PetScoreRankList toBean(); // 一个 Bean 实例
	public PetScoreRankList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PetScoreRankList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.PetScoreListRecord> getRecords(); // 所有的记录
	public java.util.List<xbean.PetScoreListRecord> getRecordsAsData(); // 所有的记录

}
