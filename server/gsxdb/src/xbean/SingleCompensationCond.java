
package xbean;

public interface SingleCompensationCond extends mkdb.Bean {
	public SingleCompensationCond copy(); // 深拷贝
	public SingleCompensationCond toData(); // 一个 Data 实例
	public SingleCompensationCond toBean(); // 一个 Bean 实例
	public SingleCompensationCond toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SingleCompensationCond toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getCondid(); // 条件的id
	public java.util.List<String> getCondparams(); // 条件的参数
	public java.util.List<String> getCondparamsAsData(); // 条件的参数

	public void setCondid(int _v_); // 条件的id
}
