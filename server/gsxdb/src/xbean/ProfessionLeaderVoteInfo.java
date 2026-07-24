
package xbean;

public interface ProfessionLeaderVoteInfo extends mkdb.Bean {
	public ProfessionLeaderVoteInfo copy(); // 深拷贝
	public ProfessionLeaderVoteInfo toData(); // 一个 Data 实例
	public ProfessionLeaderVoteInfo toBean(); // 一个 Bean 实例
	public ProfessionLeaderVoteInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ProfessionLeaderVoteInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getVotetime(); // role最近一次投票的时间
	public long getChallengetime(); // role最近一次挑战成功的时间

	public void setVotetime(long _v_); // role最近一次投票的时间
	public void setChallengetime(long _v_); // role最近一次挑战成功的时间
}
