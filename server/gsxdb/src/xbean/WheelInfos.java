
package xbean;

public interface WheelInfos extends mkdb.Bean {
	public WheelInfos copy(); // 深拷贝
	public WheelInfos toData(); // 一个 Data 实例
	public WheelInfos toBean(); // 一个 Bean 实例
	public WheelInfos toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WheelInfos toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.WheelInfo> getWheellist(); // 
	public java.util.List<xbean.WheelInfo> getWheellistAsData(); // 

}
