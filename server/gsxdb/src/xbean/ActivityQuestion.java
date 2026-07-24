
package xbean;

public interface ActivityQuestion extends mkdb.Bean {
	public ActivityQuestion copy(); // 深拷贝
	public ActivityQuestion toData(); // 一个 Data 实例
	public ActivityQuestion toBean(); // 一个 Bean 实例
	public ActivityQuestion toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ActivityQuestion toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getActivityquestionstarttime(); // 活动答题开启时间，作者 changhao
	public java.util.List<Integer> getQuestionids(); // 题目，作者 changhao
	public java.util.List<Integer> getQuestionidsAsData(); // 题目，作者 changhao
	public int getCurquestionindex(); // 当前回答的问题，作者 changhao
	public int getCurquestionstep(); // 当前回答的步骤，作者 changhao
	public int getAnswerrighttimes(); // 回答正确的次数，作者 changhao
	public int getTotalanswernum(); // 总共回答的数量，作者 changhao
	public int getGrabreward(); // 1是可以领取2是已经领取3是不能领取，作者 changhao
	public int getTotalexp(); // 总经验，作者 changhao
	public int getTotalmoney(); // 总金币，作者 changhao
	public int getHelptimes(); // 帮助次数，作者 changhao

	public void setActivityquestionstarttime(long _v_); // 活动答题开启时间，作者 changhao
	public void setCurquestionindex(int _v_); // 当前回答的问题，作者 changhao
	public void setCurquestionstep(int _v_); // 当前回答的步骤，作者 changhao
	public void setAnswerrighttimes(int _v_); // 回答正确的次数，作者 changhao
	public void setTotalanswernum(int _v_); // 总共回答的数量，作者 changhao
	public void setGrabreward(int _v_); // 1是可以领取2是已经领取3是不能领取，作者 changhao
	public void setTotalexp(int _v_); // 总经验，作者 changhao
	public void setTotalmoney(int _v_); // 总金币，作者 changhao
	public void setHelptimes(int _v_); // 帮助次数，作者 changhao
}
