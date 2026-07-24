
package xbean;

public interface InstanceActivity extends mkdb.Bean {
	public InstanceActivity copy(); // 深拷贝
	public InstanceActivity toData(); // 一个 Data 实例
	public InstanceActivity toBean(); // 一个 Bean 实例
	public InstanceActivity toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceActivity toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public final static int STATE_UNSTART = 0; // 
	public final static int STATE_START = 1; // 
	public final static int STATE_END = 2; // 

	public int getInstanceid(); // 副本id,跟任务配置.xlsx中的id对应
	public int getState(); // 状态,0=未开始；1=已开始；2=已结束
	public int getBaseid(); // 活动基础id
	public long getStarttime(); // 开始时间
	public long getEndtime(); // 结束时间

	public void setInstanceid(int _v_); // 副本id,跟任务配置.xlsx中的id对应
	public void setState(int _v_); // 状态,0=未开始；1=已开始；2=已结束
	public void setBaseid(int _v_); // 活动基础id
	public void setStarttime(long _v_); // 开始时间
	public void setEndtime(long _v_); // 结束时间
}
