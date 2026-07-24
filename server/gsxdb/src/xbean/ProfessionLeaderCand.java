
package xbean;

public interface ProfessionLeaderCand extends mkdb.Bean {
	public ProfessionLeaderCand copy(); // 深拷贝
	public ProfessionLeaderCand toData(); // 一个 Data 实例
	public ProfessionLeaderCand toBean(); // 一个 Bean 实例
	public ProfessionLeaderCand toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ProfessionLeaderCand toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getCandidatelist(); // 职业领袖候选人list,该表每周清除一次
	public java.util.List<Long> getCandidatelistAsData(); // 职业领袖候选人list,该表每周清除一次

}
