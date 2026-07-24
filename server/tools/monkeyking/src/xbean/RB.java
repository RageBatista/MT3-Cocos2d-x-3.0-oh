
package xbean;

public interface RB extends mkdb.Bean {
	public RB copy(); // deep clone
	public RB toData(); // a Data instance
	public RB toBean(); // a Bean instance
	public RB toDataIf(); // a Data instance If need. else return this
	public RB toBeanIf(); // a Bean instance If need. else return this

	public int getI(); // int test

	public void setI(int _v_); // int test
}
