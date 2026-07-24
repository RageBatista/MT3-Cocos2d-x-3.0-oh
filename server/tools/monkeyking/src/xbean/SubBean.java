
package xbean;

public interface SubBean extends mkdb.Bean {
	public SubBean copy(); // deep clone
	public SubBean toData(); // a Data instance
	public SubBean toBean(); // a Bean instance
	public SubBean toDataIf(); // a Data instance If need. else return this
	public SubBean toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // int value

	public void setId(int _v_); // int value
}
