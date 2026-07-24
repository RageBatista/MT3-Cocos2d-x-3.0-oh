
package xbean;

public interface TestType extends mkdb.Bean {
	public TestType copy(); // deep clone
	public TestType toData(); // a Data instance
	public TestType toBean(); // a Bean instance
	public TestType toDataIf(); // a Data instance If need. else return this
	public TestType toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // test
	public java.util.Map<Integer, xbean.Second> getVmap(); // test
	public java.util.Map<Integer, xbean.Second> getVmapAsData(); // test

	public void setId(int _v_); // test
}
