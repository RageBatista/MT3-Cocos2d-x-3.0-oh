
package xbean;

public interface RecoveryAttr extends mkdb.Bean {
	public RecoveryAttr copy(); // 深拷贝
	public RecoveryAttr toData(); // 一个 Data 实例
	public RecoveryAttr toBean(); // 一个 Bean 实例
	public RecoveryAttr toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RecoveryAttr toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getQuality(); // 

	public void setQuality(int _v_); // 
}
