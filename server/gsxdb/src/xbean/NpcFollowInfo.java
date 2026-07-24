
package xbean;

public interface NpcFollowInfo extends mkdb.Bean {
	public NpcFollowInfo copy(); // 深拷贝
	public NpcFollowInfo toData(); // 一个 Data 实例
	public NpcFollowInfo toBean(); // 一个 Bean 实例
	public NpcFollowInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NpcFollowInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getNpcid(); // npc跟随的id
	public int getQuestid(); // 
	public long getValiddate(); // npc跟随的时限

	public void setNpcid(int _v_); // npc跟随的id
	public void setQuestid(int _v_); // 
	public void setValiddate(long _v_); // npc跟随的时限
}
