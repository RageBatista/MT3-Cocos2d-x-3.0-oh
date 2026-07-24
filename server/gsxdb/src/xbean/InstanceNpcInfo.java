
package xbean;

public interface InstanceNpcInfo extends mkdb.Bean {
	public InstanceNpcInfo copy(); // 深拷贝
	public InstanceNpcInfo toData(); // 一个 Data 实例
	public InstanceNpcInfo toBean(); // 一个 Bean 实例
	public InstanceNpcInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceNpcInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getNpckey(); // 目的npc的key
	public int getNpcid(); // 目的npc的id
	public int getMapid(); // 目的npc的mapid
	public int getPosx(); // 目的坐标
	public int getPosy(); // 目的坐标

	public void setNpckey(long _v_); // 目的npc的key
	public void setNpcid(int _v_); // 目的npc的id
	public void setMapid(int _v_); // 目的npc的mapid
	public void setPosx(int _v_); // 目的坐标
	public void setPosy(int _v_); // 目的坐标
}
