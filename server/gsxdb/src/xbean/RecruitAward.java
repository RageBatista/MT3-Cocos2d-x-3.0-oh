
package xbean;

public interface RecruitAward extends mkdb.Bean {
	public RecruitAward copy(); // 深拷贝
	public RecruitAward toData(); // 一个 Data 实例
	public RecruitAward toBean(); // 一个 Bean 实例
	public RecruitAward toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RecruitAward toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getGetnum(); // 领取次数
	public long getGettime(); // 上次领取的时间

	public void setGetnum(int _v_); // 领取次数
	public void setGettime(long _v_); // 上次领取的时间
}
