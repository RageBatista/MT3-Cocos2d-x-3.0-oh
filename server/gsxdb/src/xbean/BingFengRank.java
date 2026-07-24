
package xbean;

public interface BingFengRank extends mkdb.Bean {
	public BingFengRank copy(); // 深拷贝
	public BingFengRank toData(); // 一个 Data 实例
	public BingFengRank toBean(); // 一个 Bean 实例
	public BingFengRank toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BingFengRank toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.BingFengRankList> getRanks(); // key为职业id
	public java.util.Map<Integer, xbean.BingFengRankList> getRanksAsData(); // key为职业id

}
