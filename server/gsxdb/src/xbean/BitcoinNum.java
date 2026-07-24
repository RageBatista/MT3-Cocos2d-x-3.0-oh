
package xbean;

public interface BitcoinNum extends mkdb.Bean {
	public BitcoinNum copy(); // 深拷贝
	public BitcoinNum toData(); // 一个 Data 实例
	public BitcoinNum toBean(); // 一个 Bean 实例
	public BitcoinNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BitcoinNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getNum(); // 现金充值比特币数
	public int getSysnum(); // 系统赠送比特币数
	public int getNopresentnum(); // 没有包含赠送的实际充值总比特币
	public java.util.List<Long> getSnlist(); // 玩家充值的序列号
	public java.util.List<Long> getSnlistAsData(); // 玩家充值的序列号
	public int getBindorsysnumtoday(); // 该玩家今天获得的比特币数量(不包括充值的)
	public long getBindorsysnumtodaytime(); // 这个time跟下面time不一样,这个time只有绑定或系统比特币增加的时候才会变
	public long getTime(); // 最近一次比特币数量发生变化的时间
	public long getBitcoinall(); // 累计比特币总数，包括所有产出途径的比特币数

	public void setNum(int _v_); // 现金充值比特币数
	public void setSysnum(int _v_); // 系统赠送比特币数
	public void setNopresentnum(int _v_); // 没有包含赠送的实际充值总比特币
	public void setBindorsysnumtoday(int _v_); // 该玩家今天获得的比特币数量(不包括充值的)
	public void setBindorsysnumtodaytime(long _v_); // 这个time跟下面time不一样,这个time只有绑定或系统比特币增加的时候才会变
	public void setTime(long _v_); // 最近一次比特币数量发生变化的时间
	public void setBitcoinall(long _v_); // 累计比特币总数，包括所有产出途径的比特币数
}
