package app.matchcafe.match_cafe;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

public class RoomService extends Service {

    public static final String ACTION_LEAVE = "ACTION_LEAVE";
    public static final String ACTION_START = "ACTION_START";
    public static final String ACTION_OPEN = "ACTION_OPEN";
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(intent != null)
        {
            String action = intent.getAction();
            Log.d("Actions", action);
            if (ACTION_LEAVE.equals(action)) {
                leaveRoom();
            }else if(ACTION_START.equals(action)){
                showNotification(intent.getStringExtra("roomName"), intent.getStringExtra("createdBy"));
            }
        }
        return super.onStartCommand(intent, flags, startId);
    }

    private void showNotification(String roomName, String createdBy) {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"match_cafe")
                    .setContentText("Created by: "+ createdBy)
                    .setContentTitle("You are now listening to " + roomName)
                    .setSmallIcon(R.mipmap.ic_launcher);
            Intent leaveIntent = new Intent(this, RoomService.class);
            leaveIntent.setAction(ACTION_LEAVE);

            Intent openIntent = new Intent(this, MainActivity.class);
            openIntent.setAction(ACTION_OPEN);
            PendingIntent pendingIntent=PendingIntent.getActivity(this, 0,
                    openIntent,PendingIntent.FLAG_UPDATE_CURRENT);


            PendingIntent pendingPlayIntent = PendingIntent.getService(this, 0, leaveIntent, 0);
            NotificationCompat.Action leaveAction = new NotificationCompat.Action(android.R.drawable.ic_media_next, "Leave room", pendingPlayIntent);
            builder.addAction(leaveAction);
            builder.setContentIntent(pendingIntent);
            builder.setPriority(NotificationManager.IMPORTANCE_MAX);
            startForeground(101,builder.build());
        }
    }

    private void leaveRoom(){
        Log.d("service", "leaving room");
        Intent intent = new Intent("match_cafe");
        intent.putExtra("leaveRoom", true);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        stopForeground(true);
        stopSelf();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
