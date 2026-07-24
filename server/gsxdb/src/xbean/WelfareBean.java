
package xbean;

public interface WelfareBean extends mkdb.Bean {
	public WelfareBean copy(); // 深拷贝
	public WelfareBean toData(); // 一个 Data 实例
	public WelfareBean toBean(); // 一个 Bean 实例
	public WelfareBean toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WelfareBean toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBuytimes(); // 购买次数
	public long getLastbuytime(); // 

	public void setBuytimes(int _v_); // 购买次数
	public void setLastbuytime(long _v_); // 
}
