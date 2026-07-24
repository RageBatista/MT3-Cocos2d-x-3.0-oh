
package xbean;

public interface XingChenItem extends mkdb.Bean {
	public XingChenItem copy(); // 深拷贝
	public XingChenItem toData(); // 一个 Data 实例
	public XingChenItem toBean(); // 一个 Bean 实例
	public XingChenItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public XingChenItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 称谓id
	public int getPos(); // 称谓名
	public int getLevel(); // 剩余有效时间
	public int getPinzhi(); // 剩余有效时间
	public int getNaijiu(); // 剩余有效时间
	public int getShuxing(); // 剩余有效时间
	public int getXishu(); // 剩余有效时间

	public void setId(int _v_); // 称谓id
	public void setPos(int _v_); // 称谓名
	public void setLevel(int _v_); // 剩余有效时间
	public void setPinzhi(int _v_); // 剩余有效时间
	public void setNaijiu(int _v_); // 剩余有效时间
	public void setShuxing(int _v_); // 剩余有效时间
	public void setXishu(int _v_); // 剩余有效时间
}
