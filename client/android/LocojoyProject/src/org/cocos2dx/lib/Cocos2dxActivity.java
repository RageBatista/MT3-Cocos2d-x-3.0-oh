/****************************************************************************
Copyright (c) 2010-2011 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/

package org.cocos2dx.lib;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.DisplayMetrics;

import com.locojoy.mini.mt3.GameApp;

@SuppressLint({ "HandlerLeak", "SdCardPath", "SimpleDateFormat" })
public class Cocos2dxActivity extends Activity {
	private static Cocos2dxMusic backgroundMusicPlayer;
	private static Cocos2dxSound soundPlayer;
	private static Cocos2dxAccelerometer accelerometer;
	private static boolean accelerometerEnabled = false;
	private static Handler handler;
	private final static int HANDLER_SHOW_DIALOG = 1;
	private final static String PREFS_NAME = "Cocos2dxPrefsFile";
	private static String packageName;

	private static native void nativeSetPaths(String apkPath, final AssetManager pAssetManager);
	private static native void nativeInitJniBridge(final Activity activity);

	private String flieName;
	
	protected Cocos2dxGLSurfaceView mGLView = null;
	
	public static int REQUEST_CODE_CAMERA = 10;
	public static int REQUEST_CODE_ALBUM = 11;
	private static final int REQUEST_CODE_PERMISSION_CAMERA = 110;
	private static final int REQUEST_CODE_PERMISSION_ALBUM = 111;
	private static final int PENDING_ACTION_NONE = 0;
	private static final int PENDING_ACTION_CAMERA = 1;
	private static final int PENDING_ACTION_ALBUM = 2;
	
	private static Cocos2dxActivity msInstance = null;
	private static String mCameraPhotoFilename = "";
	private static Uri mCameraPhotoUri = null;
	private static int mPendingAction = PENDING_ACTION_NONE;

	private static class MessageHandler extends Handler {
		private final WeakReference<Cocos2dxActivity> activityRef;

		MessageHandler(Cocos2dxActivity activity) {
			activityRef = new WeakReference<Cocos2dxActivity>(activity);
		}

		@Override
		public void handleMessage(Message msg) {
			Cocos2dxActivity activity = activityRef.get();
			if (activity == null) {
				return;
			}
			if (msg.what == HANDLER_SHOW_DIALOG) {
				DialogMessage dialogMessage = (DialogMessage) msg.obj;
				activity.showDialog(dialogMessage.title, dialogMessage.message);
			}
		}
	}
	
	public Cocos2dxActivity()
	{
		msInstance = this;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// get frame size
		DisplayMetrics dm = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(dm);
		accelerometer = new Cocos2dxAccelerometer(this);

		// init media player and sound player
		backgroundMusicPlayer = new Cocos2dxMusic(this);
		soundPlayer = new Cocos2dxSound(this);

		// init bitmap context
		Cocos2dxBitmap.setContext(this);

		handler = new MessageHandler(this);
	}

	public static String getCurrentLanguage() {
		String languageName = java.util.Locale.getDefault().getLanguage();
		return languageName;
	}

	public static void showMessageBox(String title, String message) {
		Handler messageHandler = handler;
		if (messageHandler == null) {
			return;
		}
		Message msg = new Message();
		msg.what = HANDLER_SHOW_DIALOG;
		msg.obj = new DialogMessage(title, message);

		messageHandler.sendMessage(msg);
	}

	public static void enableAccelerometer() {
		accelerometerEnabled = true;
		accelerometer.enable();
	}

	public static void disableAccelerometer() {
		accelerometerEnabled = false;
		accelerometer.disable();
	}

	public static void preloadBackgroundMusic(String path) {
		backgroundMusicPlayer.preloadBackgroundMusic(path);
	}

	public static void playBackgroundMusic(String path, boolean isLoop) {
		backgroundMusicPlayer.playBackgroundMusic(path, isLoop);
	}

	public static void stopBackgroundMusic() {
		backgroundMusicPlayer.stopBackgroundMusic();
	}

	public static void pauseBackgroundMusic() {
		backgroundMusicPlayer.pauseBackgroundMusic();
	}

	public static void resumeBackgroundMusic() {
		backgroundMusicPlayer.resumeBackgroundMusic();
	}

	public static void rewindBackgroundMusic() {
		backgroundMusicPlayer.rewindBackgroundMusic();
	}

	public static boolean isBackgroundMusicPlaying() {
		return backgroundMusicPlayer.isBackgroundMusicPlaying();
	}

	public static float getBackgroundMusicVolume() {
		return backgroundMusicPlayer.getBackgroundVolume();
	}

	public static void setBackgroundMusicVolume(float volume) {
		backgroundMusicPlayer.setBackgroundVolume(volume);
	}

	public static int playEffect(String path, boolean isLoop) {
		return soundPlayer.playEffect(path, isLoop, 1.f, 0.f, 1.f);
	}

	public static void stopEffect(int soundId) {
		soundPlayer.stopEffect(soundId);
	}
	
	public static void stopEffectByPath(String path) {
		soundPlayer.stopEffectByPath(path);
	}
	
	public static boolean getEffectIsPlaying(String path) {
		return soundPlayer.getEffectIsPlaying(path);
	}

	public static void pauseEffect(int soundId) {
		soundPlayer.pauseEffect(soundId);
	}

	public static void resumeEffect(int soundId) {
		soundPlayer.resumeEffect(soundId);
	}

	public static float getEffectsVolume() {
		return soundPlayer.getEffectsVolume();
	}

	public static void setEffectsVolume(float volume) {
		soundPlayer.setEffectsVolume(volume);
	}

	public static void preloadEffect(String path) {
		soundPlayer.preloadEffect(path);
	}

	public static void unloadEffect(String path) {
		soundPlayer.unloadEffect(path);
	}

	public static void stopAllEffects() {
		soundPlayer.stopAllEffects();
	}

	public static void pauseAllEffects() {
		soundPlayer.pauseAllEffects();
	}

	public static void resumeAllEffects() {
		soundPlayer.resumeAllEffects();
	}
	
	public static void setEffectVolume(int streamId, float fVolume)
	{
		soundPlayer.setEffectVolume(streamId, fVolume);
	}
	
	public static boolean hasEffect(int streamId)
	{
		return soundPlayer.hasEffect(streamId);
	}
	
	public static boolean isEffectPlaying(int streamId)
	{
		return soundPlayer.isEffectPlaying(streamId);
	}

	public static void end() {
		backgroundMusicPlayer.end();
		soundPlayer.end();
	}

	public static String getCocos2dxPackageName() {
		return packageName;
	}

	public static String getCocos2dxWritablePath() {
		if (msInstance == null) {
			return "";
		}
		return msInstance.getFilesDir().getAbsolutePath();
	}

	public static String getDeviceModel() {
		return Build.MODEL;
	}

	private static SharedPreferences getCocos2dxPreferences() {
		if (msInstance == null) {
			return null;
		}
		return msInstance.getSharedPreferences(PREFS_NAME, 0);
	}

	public static boolean getBoolForKey(String key, boolean defaultValue) {
		SharedPreferences settings = getCocos2dxPreferences();
		return settings == null ? defaultValue : settings.getBoolean(key, defaultValue);
	}

	public static int getIntegerForKey(String key, int defaultValue) {
		SharedPreferences settings = getCocos2dxPreferences();
		return settings == null ? defaultValue : settings.getInt(key, defaultValue);
	}

	public static float getFloatForKey(String key, float defaultValue) {
		SharedPreferences settings = getCocos2dxPreferences();
		return settings == null ? defaultValue : settings.getFloat(key, defaultValue);
	}

	public static double getDoubleForKey(String key, double defaultValue) {
		SharedPreferences settings = getCocos2dxPreferences();
		return settings == null ? defaultValue : settings.getFloat(key, (float)defaultValue);
	}

	public static String getStringForKey(String key, String defaultValue) {
		SharedPreferences settings = getCocos2dxPreferences();
		return settings == null ? defaultValue : settings.getString(key, defaultValue);
	}

	public static void setBoolForKey(String key, boolean value) {
		SharedPreferences settings = getCocos2dxPreferences();
		if (settings == null) {
			return;
		}
		SharedPreferences.Editor editor = settings.edit();
		editor.putBoolean(key, value);
		editor.commit();
	}

	public static void setIntegerForKey(String key, int value) {
		SharedPreferences settings = getCocos2dxPreferences();
		if (settings == null) {
			return;
		}
		SharedPreferences.Editor editor = settings.edit();
		editor.putInt(key, value);
		editor.commit();
	}

	public static void setFloatForKey(String key, float value) {
		SharedPreferences settings = getCocos2dxPreferences();
		if (settings == null) {
			return;
		}
		SharedPreferences.Editor editor = settings.edit();
		editor.putFloat(key, value);
		editor.commit();
	}

	public static void setDoubleForKey(String key, double value) {
		SharedPreferences settings = getCocos2dxPreferences();
		if (settings == null) {
			return;
		}
		SharedPreferences.Editor editor = settings.edit();
		editor.putFloat(key, (float)value);
		editor.commit();
	}

	public static void setStringForKey(String key, String value) {
		SharedPreferences settings = getCocos2dxPreferences();
		if (settings == null) {
			return;
		}
		SharedPreferences.Editor editor = settings.edit();
		editor.putString(key, value);
		editor.commit();
	}

	public static void terminateProcess() {
//		JniProxy.release();
		GameApp.getApp().finish();
		System.exit(0);
		// android.os.Process.killProcess(android.os.Process.myPid());
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (accelerometerEnabled) {
			accelerometer.enable();
		}
	}

	@Override
	protected void onPause() {
		super.onPause();
		if (accelerometerEnabled) {
			accelerometer.disable();
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (handler != null) {
			handler.removeCallbacksAndMessages(null);
			handler = null;
		}
		if (accelerometer != null) {
			accelerometer.disable();
			accelerometer = null;
		}
		if (backgroundMusicPlayer != null) {
			backgroundMusicPlayer.end();
			backgroundMusicPlayer = null;
		}
		if (soundPlayer != null) {
			soundPlayer.end();
			soundPlayer = null;
		}
		Cocos2dxBitmap.setContext(null);
		msInstance = null;
	}

	protected void setPackageName(String packageName) {
		Cocos2dxActivity.packageName = packageName;

		String apkFilePath = "";
		ApplicationInfo appInfo = null;
		PackageManager packMgmr = getApplication().getPackageManager();
		try {
			appInfo = packMgmr.getApplicationInfo(packageName, 0);
		} catch (NameNotFoundException e) {
			e.printStackTrace();
			throw new RuntimeException("Unable to locate assets, aborting...");
		}
		apkFilePath = appInfo.sourceDir;

		nativeInitJniBridge(this);

		// add this link at the renderer class
		nativeSetPaths(apkFilePath, this.getAssets());
	}

	private void showDialog(String title, String message) {
		Dialog dialog = new AlertDialog.Builder(this).setTitle(title).setMessage(message).setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int whichButton) {

			}
		}).create();

		dialog.show();
	}

	// /////////////////////////////////////////////
	// copy and unzip assets to sd or /data/data/xxx/

	private void CopyAssets(String assetDir, String dir) {
		String[] files;
		try {
			files = this.getResources().getAssets().list(assetDir);
		} catch (IOException e1) {
			return;
		}
		File mWorkingPath = new File(dir);
		// if this directory does not exists, make one.
		if (!mWorkingPath.exists()) {
			if (!mWorkingPath.mkdirs()) {

			}
		}

		for (int i = 0; i < files.length; i++) {
			try {
				String fileName = files[i];
				// we make sure file name not contains '.' to be a folder.
				if (!fileName.contains(".")) {
					if (0 == assetDir.length()) {
						CopyAssets(fileName, dir + fileName + "/");
					} else {
						CopyAssets(assetDir + "/" + fileName, dir + fileName + "/");
					}
					continue;
				}

				String outfileName = fileName;
				if (fileName.contains(".pfs")) {
					outfileName = fileName.substring(0, fileName.indexOf(".")) + ".pfs";
				}
				File outFile = new File(mWorkingPath, outfileName);
				// if(outFile.exists())
				// outFile.delete();
				InputStream in = null;
				if (0 != assetDir.length())
					in = getAssets().open(assetDir + "/" + fileName);
				else
					in = getAssets().open(fileName);

				OutputStream out = new FileOutputStream(outFile, true);

				// Transfer bytes from in to out
				byte[] buf = new byte[1024];
				int len;
				while ((len = in.read(buf)) > 0) {
					out.write(buf, 0, len);
				}

				in.close();
				out.close();
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static String getAssetsOutDir() {

		if (GameApp.getApp().getExternalFilesDir(null) != null) {
			return GameApp.getApp().getExternalFilesDir(null) + "/gamedata";
		} else {
			return "/data/data/" + getCocos2dxPackageName() + "/assets";
		}
	}

	public void unzipAndCopyAssetsTo() {
		String outDir = getAssetsOutDir();
		File outfile = new File(outDir);
		deleteFile(outfile);
		CopyAssets("", outDir + "/");
	}

	public void deleteFile(File file) {
		if (!file.exists())
			return;
		if (file.isDirectory()) {
			for (File f : file.listFiles())
				deleteFile(f);
		}
		file.delete();

	}
	
	public void runOnGLThread(Runnable action){
		if (mGLView != null) {
			mGLView.queueEvent(action);
		} else {
			runOnUiThread(action);
		}
	}
	
	public static boolean openCamera()
	{
		if (msInstance == null) {
			return false;
		}
		if (!hasPermission(android.Manifest.permission.CAMERA)
				|| !hasPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
			mPendingAction = PENDING_ACTION_CAMERA;
			requestRuntimePermissions(new String[] {
					android.Manifest.permission.CAMERA,
					android.Manifest.permission.WRITE_EXTERNAL_STORAGE }, REQUEST_CODE_PERMISSION_CAMERA);
			return false;
		}
		return startCameraActivity();
	}
	
	public static boolean openAlbum()
	{
		if (msInstance == null) {
			return false;
		}
		if (!hasPermission(android.Manifest.permission.READ_EXTERNAL_STORAGE)) {
			mPendingAction = PENDING_ACTION_ALBUM;
			requestRuntimePermissions(new String[] {
					android.Manifest.permission.READ_EXTERNAL_STORAGE }, REQUEST_CODE_PERMISSION_ALBUM);
			return false;
		}
		Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		intent.setType("image/*");
		msInstance.startActivityForResult(intent, REQUEST_CODE_ALBUM);  
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(requestCode == REQUEST_CODE_CAMERA || requestCode == REQUEST_CODE_ALBUM)
		{
			String path = "";
			if(resultCode == Activity.RESULT_OK)
			{
				if(requestCode == REQUEST_CODE_CAMERA)
				{
					Uri cameraUri = mCameraPhotoUri;
					if (cameraUri == null && data != null) {
						cameraUri = data.getData();
					}
					path = resolvePathFromUri(cameraUri);
					if ((path == null || path.length() == 0) && mCameraPhotoFilename != null) {
						path = mCameraPhotoFilename;
					}
				}
				else if(requestCode == REQUEST_CODE_ALBUM)
				{
					Uri selectedImage = data == null ? null : data.getData();
					path = resolvePathFromUri(selectedImage);
				}
			}
			nativeAddSelectedPhoto(path);
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

	public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
		boolean granted = isAllGranted(grantResults);
		if (requestCode == REQUEST_CODE_PERMISSION_CAMERA) {
			if (granted && mPendingAction == PENDING_ACTION_CAMERA) {
				startCameraActivity();
			} else {
				nativeAddSelectedPhoto("");
			}
			mPendingAction = PENDING_ACTION_NONE;
		} else if (requestCode == REQUEST_CODE_PERMISSION_ALBUM) {
			if (granted && mPendingAction == PENDING_ACTION_ALBUM) {
				openAlbum();
			} else {
				nativeAddSelectedPhoto("");
			}
			mPendingAction = PENDING_ACTION_NONE;
		}
	}
	
	public static native void nativeAddSelectedPhoto(String path);

	private static boolean startCameraActivity() {
		String state = Environment.getExternalStorageState();
		if (!state.equals(Environment.MEDIA_MOUNTED)) {
			return false;
		}

		Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
		Date date = new Date(System.currentTimeMillis());
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
		String filename = "IMG_" + dateFormat.format(date) + ".jpg";
		Uri photoOutUri = null;

		if (Build.VERSION.SDK_INT >= 24) {
			try {
				ContentValues values = new ContentValues();
				values.put(MediaStore.Images.Media.TITLE, filename);
				values.put(MediaStore.Images.Media.DISPLAY_NAME, filename);
				values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
				photoOutUri = msInstance.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		if (photoOutUri == null) {
			if (Build.VERSION.SDK_INT >= 24) {
				return false;
			}
			File cameraAlbumDir = new File(Environment.getExternalStorageDirectory() + "/DCIM/Camera");
			if(!cameraAlbumDir.exists())
			{
				cameraAlbumDir.mkdirs();
			}
			File cameraPhotoFile = new File(cameraAlbumDir, filename);
			photoOutUri = Uri.fromFile(cameraPhotoFile);
			mCameraPhotoFilename = cameraPhotoFile.getAbsolutePath();
		} else {
			mCameraPhotoFilename = "";
		}

		mCameraPhotoUri = photoOutUri;
		intent.putExtra(MediaStore.EXTRA_OUTPUT, photoOutUri);
		intent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 0.8);

		msInstance.startActivityForResult(intent, REQUEST_CODE_CAMERA);
		return true;
	}

	private static boolean hasPermission(String permission) {
		if (Build.VERSION.SDK_INT < 23) {
			return true;
		}
		try {
			Method method = Activity.class.getMethod("checkSelfPermission", String.class);
			Object result = method.invoke(msInstance, permission);
			return result instanceof Integer && ((Integer) result).intValue() == PackageManager.PERMISSION_GRANTED;
		} catch (Exception e) {
			e.printStackTrace();
			return true;
		}
	}

	private static void requestRuntimePermissions(String[] permissions, int requestCode) {
		if (Build.VERSION.SDK_INT >= 23) {
			try {
				Method method = Activity.class.getMethod("requestPermissions", String[].class, int.class);
				method.invoke(msInstance, new Object[] { permissions, Integer.valueOf(requestCode) });
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static boolean isAllGranted(int[] grantResults) {
		if (grantResults == null || grantResults.length == 0) {
			return false;
		}
		for (int result : grantResults) {
			if (result != PackageManager.PERMISSION_GRANTED) {
				return false;
			}
		}
		return true;
	}

	private String resolvePathFromUri(Uri uri) {
		if (uri == null) {
			return "";
		}
		if ("file".equalsIgnoreCase(uri.getScheme())) {
			return uri.getPath();
		}

		Cursor cursor = null;
		try {
			String[] filePathColumn = { MediaStore.Images.Media.DATA };
			cursor = getContentResolver().query(uri, filePathColumn, null, null, null);
			if (cursor != null && cursor.moveToFirst()) {
				int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
				if (columnIndex >= 0) {
					String path = cursor.getString(columnIndex);
					if (path != null && path.length() > 0) {
						return path;
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		return copyUriToPrivateCache(uri);
	}

	private String copyUriToPrivateCache(Uri uri) {
		InputStream in = null;
		OutputStream out = null;
		try {
			in = getContentResolver().openInputStream(uri);
			if (in == null) {
				return "";
			}
			File outDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
			if (outDir == null) {
				outDir = getCacheDir();
			}
			if (!outDir.exists()) {
				outDir.mkdirs();
			}
			File outFile = new File(outDir, "selected_" + System.currentTimeMillis() + ".jpg");
			out = new FileOutputStream(outFile, false);
			byte[] buffer = new byte[8192];
			int len;
			while ((len = in.read(buffer)) > 0) {
				out.write(buffer, 0, len);
			}
			return outFile.getAbsolutePath();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return "";
	}
	
	// /////////////////////////////////////////////
}

class DialogMessage {
	public String title;
	public String message;

	public DialogMessage(String title, String message) {
		this.message = message;
		this.title = title;
	}
}
