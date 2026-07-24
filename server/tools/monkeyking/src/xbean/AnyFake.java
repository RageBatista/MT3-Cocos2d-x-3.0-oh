
package xbean;

public interface AnyFake extends mkdb.Bean {
	public AnyFake copy(); // deep clone
	public AnyFake toData(); // a Data instance
	public AnyFake toBean(); // a Bean instance
	public AnyFake toDataIf(); // a Data instance If need. else return this
	public AnyFake toBeanIf(); // a Bean instance If need. else return this

	public int getFake(); // comment

	public void setFake(int _v_); // comment
}
