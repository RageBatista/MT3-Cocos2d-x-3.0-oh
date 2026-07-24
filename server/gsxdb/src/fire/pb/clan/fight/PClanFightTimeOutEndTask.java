package fire.pb.clan.fight;

import com.locojoy.base.Runnable;

/***
 * 公会战场结束定时器，作者 changhao
 */
public class PClanFightTimeOutEndTask extends Runnable
{
	long clanfightid;
	
	public PClanFightTimeOutEndTask(long clanfightid)
	{
		this.clanfightid = clanfightid;
	}

	@Override
	public void run()
	{
		new PClanFightTimeOutEnd(clanfightid).submit();
	}

}
