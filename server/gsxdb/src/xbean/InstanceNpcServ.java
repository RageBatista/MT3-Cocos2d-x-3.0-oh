
package xbean;

public interface InstanceNpcServ extends mkdb.Bean {
	public InstanceNpcServ copy(); // 深拷贝
	public InstanceNpcServ toData(); // 一个 Data 实例
	public InstanceNpcServ toBean(); // 一个 Bean 实例
	public InstanceNpcServ toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceNpcServ toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getServiceid(); // 服务id
	public int getActid(); // 0为隐藏，大于0则为某个服务动作的ID，显示出来肯定得有服务动作

	public void setServiceid(long _v_); // 服务id
	public void setActid(int _v_); // 0为隐藏，大于0则为某个服务动作的ID，显示出来肯定得有服务动作
}
