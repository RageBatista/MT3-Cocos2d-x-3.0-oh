
package xbean;

public interface Gather extends mkdb.Bean {
	public Gather copy(); // 深拷贝
	public Gather toData(); // 一个 Data 实例
	public Gather toBean(); // 一个 Bean 实例
	public Gather toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Gather toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public final static int GETITEM = 0; // 获得物品
	public final static int LAUNCHBATTLE = 1; // 开始战斗

	public long getGatherkey(); // 采集物key
	public int getResult(); // 采集的结果,战斗或者获得物品
	public long getEndgathertime(); // 开始采集的时间

	public void setGatherkey(long _v_); // 采集物key
	public void setResult(int _v_); // 采集的结果,战斗或者获得物品
	public void setEndgathertime(long _v_); // 开始采集的时间
}
