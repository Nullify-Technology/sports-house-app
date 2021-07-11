package app.matchcafe.match_cafe;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;
import io.flutter.plugin.common.MethodChannel;

import static app.matchcafe.match_cafe.MatchCafeApplication.CHANNEL;
import static app.matchcafe.match_cafe.RoomService.ACTION_OPEN;
import static app.matchcafe.match_cafe.RoomService.ACTION_START;

public class MainActivity extends FlutterActivity {
    private Intent roomService;
    private String roomId = "";
    private String userId = "";
    private String userType = "";
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        roomService = new Intent(MainActivity.this,RoomService.class);
        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler((methodCall, result) -> {
            if(methodCall.method.equals("startService")){
                String currentRoom = methodCall.argument("roomName");
                String createdBy = methodCall.argument("createdBy");
                roomId = methodCall.argument("roomId");
                userId = methodCall.argument("userId");
                userType = methodCall.argument("userType");
                Log.d("current room details", currentRoom + " " + createdBy+ " "+ roomId+ " "+ userId);
                roomService.putExtra("roomName", currentRoom);
                roomService.putExtra("createdBy", createdBy);
                roomService.setAction(ACTION_START);
                startService();
                result.success("Service Started");
            }
            if(methodCall.method.equals("stopService")){
                stopService(roomService);
                result.success("Service stopped");
            }
        });
        LocalBroadcastManager.getInstance(this)
                .registerReceiver(new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        boolean leaveRoom = intent.getBooleanExtra("leaveRoom", false);
                        if(leaveRoom){
                            Log.d("Broadcast receiver", "calling leaveRoom");
                            channel.invokeMethod("leaveRoom",null);
                        }
                    }
                }, new IntentFilter("match_cafe"));
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopService(roomService);
        if(null != roomId && null != userId && !roomId.isEmpty() && !userId.isEmpty()){
            FirebaseDatabase.getInstance("https://sports-house-bab4a.asia-southeast1.firebasedatabase.app/")
                    .getReference().child("rtc_room").child(roomId).child(userType).child(userId).removeValue();
        }
    }

    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(roomService);
        } else {
            startService(roomService);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }
}
