
package xbean;

public interface InstanceInfoCol extends mkdb.Bean {
	public InstanceInfoCol copy(); // 深拷贝
	public InstanceInfoCol toData(); // 一个 Data 实例
	public InstanceInfoCol toBean(); // 一个 Bean 实例
	public InstanceInfoCol toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceInfoCol toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLastinstanceid(); // 最后进入的一个副本
	public int getCounts(); // 今天做了多少次副本
	public long getAccepttime(); // 最后接副本时间
	public java.util.Map<Integer, xbean.InstanceTaskInfo> getInstinfo(); // 键重复 id，值 InstanceTaskInfo
	public java.util.Map<Integer, xbean.InstanceTaskInfo> getInstinfoAsData(); // 键重复 id，值 InstanceTaskInfo
	public java.util.Map<Integer, xbean.InstanceTimeAwardInfo> getInstcount(); // 今天进入的副本id和次数
	public java.util.Map<Integer, xbean.InstanceTimeAwardInfo> getInstcountAsData(); // 今天进入的副本id和次数
	public int getFanpai(); // 当前副本是否需要翻牌 0 不需要, 1 需要
	public int getReset(); // 当前副本是否重置过 0 没有重置过, 1 重置过

	public void setLastinstanceid(int _v_); // 最后进入的一个副本
	public void setCounts(int _v_); // 今天做了多少次副本
	public void setAccepttime(long _v_); // 最后接副本时间
	public void setFanpai(int _v_); // 当前副本是否需要翻牌 0 不需要, 1 需要
	public void setReset(int _v_); // 当前副本是否重置过 0 没有重置过, 1 重置过
}
