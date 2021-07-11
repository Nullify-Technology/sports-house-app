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
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(intent != null)
        {
            String action = intent.getAction();
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
            Intent playIntent = new Intent(this, RoomService.class);
            playIntent.setAction(ACTION_LEAVE);
            PendingIntent pendingPlayIntent = PendingIntent.getService(this, 0, playIntent, 0);
            NotificationCompat.Action leaveAction = new NotificationCompat.Action(android.R.drawable.ic_media_next, "Leave room", pendingPlayIntent);
            builder.addAction(leaveAction);
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
