
package xbean;

public interface RoleColorType extends mkdb.Bean {
	public RoleColorType copy(); // 深拷贝
	public RoleColorType toData(); // 一个 Data 实例
	public RoleColorType toBean(); // 一个 Bean 实例
	public RoleColorType toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleColorType toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getColorpos1(); // 染色部位1
	public int getColorpos2(); // 染色部位2

	public void setColorpos1(int _v_); // 染色部位1
	public void setColorpos2(int _v_); // 染色部位2
}
