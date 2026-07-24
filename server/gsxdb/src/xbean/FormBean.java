
package xbean;

public interface FormBean extends mkdb.Bean {
	public FormBean copy(); // 深拷贝
	public FormBean toData(); // 一个 Data 实例
	public FormBean toBean(); // 一个 Bean 实例
	public FormBean toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FormBean toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getActivetimes(); // 
	public int getLevel(); // 等级
	public int getExp(); // 经验，作者 changhao

	public void setActivetimes(int _v_); // 
	public void setLevel(int _v_); // 等级
	public void setExp(int _v_); // 经验，作者 changhao
}
