
package xbean;

public interface PresellItem extends mkdb.Bean {
	public PresellItem copy(); // 深拷贝
	public PresellItem toData(); // 一个 Data 实例
	public PresellItem toBean(); // 一个 Bean 实例
	public PresellItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PresellItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getRoleid(); // 参与预售玩家
	public java.util.List<Long> getRoleidAsData(); // 参与预售玩家
	public long getExpiretime(); // 到期时间

	public void setExpiretime(long _v_); // 到期时间
}
