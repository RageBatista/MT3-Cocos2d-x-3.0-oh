
package xbean;

public interface InvitePeopleInfo extends mkdb.Bean {
	public InvitePeopleInfo copy(); // 深拷贝
	public InvitePeopleInfo toData(); // 一个 Data 实例
	public InvitePeopleInfo toBean(); // 一个 Bean 实例
	public InvitePeopleInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InvitePeopleInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getInviteme(); // 邀请我的人
	public java.util.List<Long> getAminvites(); // 我邀请的人
	public java.util.List<Long> getAminvitesAsData(); // 我邀请的人
	public java.util.List<Integer> getAwardhistory(); // 已经领取过的奖励ID 0-填写邀请人奖励
	public java.util.List<Integer> getAwardhistoryAsData(); // 已经领取过的奖励ID 0-填写邀请人奖励

	public void setInviteme(long _v_); // 邀请我的人
}
