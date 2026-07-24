
package xbean;

public interface EnhancementAttr extends mkdb.Bean {
	public EnhancementAttr copy(); // 深拷贝
	public EnhancementAttr toData(); // 一个 Data 实例
	public EnhancementAttr toBean(); // 一个 Bean 实例
	public EnhancementAttr toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EnhancementAttr toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLevel(); // 等级，作者 changhao
	public java.util.Map<Integer, Integer> getAttrmap(); // 附魔增加的属性，作者 changhao
	public java.util.Map<Integer, Integer> getAttrmapAsData(); // 附魔增加的属性，作者 changhao

	public void setLevel(int _v_); // 等级，作者 changhao
}
