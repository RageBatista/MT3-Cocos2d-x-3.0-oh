
package xbean;

public interface ETeamMelon extends mkdb.Bean {
	public ETeamMelon copy(); // 深拷贝
	public ETeamMelon toData(); // 一个 Data 实例
	public ETeamMelon toBean(); // 一个 Bean 实例
	public ETeamMelon toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ETeamMelon toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.TeamMelon> getMelonid2melons(); // 队伍分赃链表，作者 changhao
	public java.util.Map<Long, xbean.TeamMelon> getMelonid2melonsAsData(); // 队伍分赃链表，作者 changhao
	public int getMelontype(); // 分赃类型 0表示以前默认的;1表示循环打明雷怪任务,2表示精英副本
	public int getDataid(); // 结合melontype,表示子类型;精英副本里表示副本id
	public long getDataid2(); // 明雷怪用的角色id,如果是在队伍内,则是队长id;精英副本里表示副本唯一id
	public java.util.List<Long> getMelonerlist(); // 有资格分赃的原始人员，作者 changhao
	public java.util.List<Long> getMelonerlistAsData(); // 有资格分赃的原始人员，作者 changhao
	public java.util.List<Long> getWatchmelonerlist(); // 没资格观看人员，作者 changhao
	public java.util.List<Long> getWatchmelonerlistAsData(); // 没资格观看人员，作者 changhao

	public void setMelontype(int _v_); // 分赃类型 0表示以前默认的;1表示循环打明雷怪任务,2表示精英副本
	public void setDataid(int _v_); // 结合melontype,表示子类型;精英副本里表示副本id
	public void setDataid2(long _v_); // 明雷怪用的角色id,如果是在队伍内,则是队长id;精英副本里表示副本唯一id
}
