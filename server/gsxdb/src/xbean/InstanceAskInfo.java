
package xbean;

public interface InstanceAskInfo extends mkdb.Bean {
	public InstanceAskInfo copy(); // 深拷贝
	public InstanceAskInfo toData(); // 一个 Data 实例
	public InstanceAskInfo toBean(); // 一个 Bean 实例
	public InstanceAskInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceAskInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Integer> getAnswerinfo(); // key为角色id,value为回答状态,0为不同意,1为同意
	public java.util.Map<Long, Integer> getAnswerinfoAsData(); // key为角色id,value为回答状态,0为不同意,1为同意
	public int getInstid(); // 副本ID
	public long getAsktime(); // 询问的时间

	public void setInstid(int _v_); // 副本ID
	public void setAsktime(long _v_); // 询问的时间
}
