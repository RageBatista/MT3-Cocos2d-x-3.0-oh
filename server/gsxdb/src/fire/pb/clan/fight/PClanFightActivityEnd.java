package fire.pb.clan.fight;

import com.locojoy.base.Runnable;

/***
 * 公会战活动结束，作者 changhao
 */
public class PClanFightActivityEnd extends Runnable
{
	public long datetime; //周几的战场活动，作者 changhao
	
	public PClanFightActivityEnd(long datetime)
	{
		this.datetime = datetime;
	}
	
	@Override
	public void run()
	{
		//java.util.List<Long> timelist = new java.util.ArrayList<Long>();
		//timelist.add(datetime);
		
		//new fire.pb.clan.fight.PClanFightRaceRank(timelist).submit();
		
		
		//mkdb.Executor.getInstance().schedule(new fire.pb.clan.fight.PClanFightRaceRank(wednesday1500), 3000, TimeUnit.MILLISECONDS);
	}
}
