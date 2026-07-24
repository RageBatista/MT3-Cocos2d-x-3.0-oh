
package xbean;

public interface crossMessageBean extends mkdb.Bean {
	public crossMessageBean copy(); // 深拷贝
	public crossMessageBean toData(); // 一个 Data 实例
	public crossMessageBean toBean(); // 一个 Bean 实例
	public crossMessageBean toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public crossMessageBean toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<String> getParms(); // 消息参数
	public java.util.List<String> getParmsAsData(); // 消息参数
	public int getMessageid(); // 消息id

	public void setMessageid(int _v_); // 消息id
}
