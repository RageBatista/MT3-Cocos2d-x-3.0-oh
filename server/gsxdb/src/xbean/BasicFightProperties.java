
package xbean;

public interface BasicFightProperties extends mkdb.Bean {
	public BasicFightProperties copy(); // 深拷贝
	public BasicFightProperties toData(); // 一个 Data 实例
	public BasicFightProperties toBean(); // 一个 Bean 实例
	public BasicFightProperties toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BasicFightProperties toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getStr(); // 力量
	public int getIq(); // 智力
	public int getCons(); // 体质
	public int getEndu(); // 耐力
	public int getAgi(); // 敏捷

	public void setStr(int _v_); // 力量
	public void setIq(int _v_); // 智力
	public void setCons(int _v_); // 体质
	public void setEndu(int _v_); // 耐力
	public void setAgi(int _v_); // 敏捷
}
