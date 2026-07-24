
package xbean;

public interface Effect extends mkdb.Bean {
	public Effect copy(); // 深拷贝
	public Effect toData(); // 一个 Data 实例
	public Effect toBean(); // 一个 Bean 实例
	public Effect toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Effect toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getEffecttypeid(); // 目标加成属性类型Id
	public float getValue(); // 加成的值
	public boolean getEnable(); // 是否生效

	public void setEffecttypeid(int _v_); // 目标加成属性类型Id
	public void setValue(float _v_); // 加成的值
	public void setEnable(boolean _v_); // 是否生效
}
