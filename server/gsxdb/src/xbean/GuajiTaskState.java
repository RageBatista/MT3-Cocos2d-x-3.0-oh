
package xbean;

public interface GuajiTaskState extends mkdb.Bean {
	public GuajiTaskState copy(); // 深拷贝
	public GuajiTaskState toData(); // 一个 Data 实例
	public GuajiTaskState toBean(); // 一个 Bean 实例
	public GuajiTaskState toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GuajiTaskState toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getGuajitypeids(); // 挂机类型ID列表
	public java.util.List<Integer> getGuajitypeidsAsData(); // 挂机类型ID列表
	public int getInitialmapid(); // 初始地图ID
	public int getGuajitypeindex(); // 当前挂机类型索引
	public int getMapidindex(); // 当前地图ID索引
	public long getLastruntimestamp(); // 最后运行时间戳
	public long getStarttime(); // 挂机开始时间
	public String getSource(); // 挂机来源(client/gm)
	public com.locojoy.base.Octets getSourceOctets(); // 挂机来源(client/gm)
	public int getStatus(); // 挂机状态: 0=已停止, 1=运行中, 2=暂停

	public void setInitialmapid(int _v_); // 初始地图ID
	public void setGuajitypeindex(int _v_); // 当前挂机类型索引
	public void setMapidindex(int _v_); // 当前地图ID索引
	public void setLastruntimestamp(long _v_); // 最后运行时间戳
	public void setStarttime(long _v_); // 挂机开始时间
	public void setSource(String _v_); // 挂机来源(client/gm)
	public void setSourceOctets(com.locojoy.base.Octets _v_); // 挂机来源(client/gm)
	public void setStatus(int _v_); // 挂机状态: 0=已停止, 1=运行中, 2=暂停
}
