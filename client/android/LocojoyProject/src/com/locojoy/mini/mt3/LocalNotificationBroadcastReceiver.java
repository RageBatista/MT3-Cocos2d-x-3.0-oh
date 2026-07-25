package com.locojoy.mini.mt3;


import java.util.HashMap;

import org.w3c.dom.Element;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build.VERSION;

public class LocalNotificationBroadcastReceiver extends BroadcastReceiver {
	@SuppressWarnings("deprecation")
	@Override
	public void onReceive(Context context, Intent intent) {
		// TODO Auto-generated method stub
		String id = intent.getStringExtra("id");
		String xmlpath = intent.getStringExtra("xmlpath");
		String classname = intent.getStringExtra("classname");
		int iconid = intent.getIntExtra("iconid", 0);
		if (id == null || id.equals("") || xmlpath == null || xmlpath.equals("") || classname == null || classname.equals("") || iconid == 0)return;

		try{
			Element root = LocalNotificationManager.getXmlRoot(xmlpath);
			HashMap<String, String> map = null;
			String attr[] = {"day", "bar", "title", "content"};
			map =  LocalNotificationManager.getAttribute(root,attr, id);
			if (map == null || map.isEmpty()) {
				return;
			}

			int NOTIFICATION_BASE_NUMBER=110;
			NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

			  try{
				  Intent pintent = new Intent();
				  pintent.setClassName(context.getPackageName(), classname);
				  PendingIntent contentIndent = PendingIntent.getActivity(context, 0, pintent, PendingIntent.FLAG_UPDATE_CURRENT);
				  Notification notification = null;
				  if (VERSION.SDK_INT < 16)
				  {
					  Notification.Builder builder = new Notification.Builder(context)
					  .setAutoCancel(true)
					  .setContentTitle(map.get("title"))
					  .setContentText(map.get("content"))
					  .setContentIntent(contentIndent)
					  .setSmallIcon(iconid)
					  .setDefaults(Notification.DEFAULT_SOUND)
					  .setWhen(System.currentTimeMillis())
					  .setOngoing(true);
					  notification = builder.getNotification();
				  }
				  else
				  {
					  notification = new Notification.Builder(context)
					  .setAutoCancel(true)
					  .setContentTitle(map.get("title"))
					  .setContentText(map.get("content"))
					  .setContentIntent(contentIndent)
					  .setSmallIcon(iconid)
					  .setWhen(System.currentTimeMillis())
					  .setDefaults(Notification.DEFAULT_SOUND)
					  .build();
				  }
				 nm.notify(NOTIFICATION_BASE_NUMBER, notification);

				AlarmManager alarmMgr = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
				if (alarmMgr != null) {
					Intent cancelIntent = new Intent(context, LocalNotificationBroadcastReceiver.class);
					cancelIntent.setAction(id);
					PendingIntent alarmPendingIntent = PendingIntent.getBroadcast(context, 0, cancelIntent, PendingIntent.FLAG_UPDATE_CURRENT);
					alarmMgr.cancel(alarmPendingIntent);
				}
			  }
			  catch(Exception e){
				  e.printStackTrace();
			  }
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
}
