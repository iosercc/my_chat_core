
package com.miyu.my_chat_core;

import android.content.Context;

import net.x52im.mobileimsdk.android.event.ChatBaseEvent;
import net.x52im.mobileimsdk.android.event.ChatMessageEvent;
import net.x52im.mobileimsdk.android.event.MessageQoSEvent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.content.Intent;

import io.flutter.plugin.common.EventChannel;

public class ChatMessageEventListener implements ChatMessageEvent, ChatBaseEvent, MessageQoSEvent, EventChannel.StreamHandler {
    private EventChannel.EventSink events;

    public ChatMessageEventListener() {

    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.events = events;
    }


    @Override
    public void onRecieveMessage(String fingerId, String userId, String dataContent, int type) {
        try {
            Map map = new HashMap();
            map.put("fun", "onRecieveMessage");
            map.put("fingerId", fingerId);
            map.put("userId", userId);
            map.put("dataContent", dataContent);
            map.put("type", type);
            this.events.success(map);
        } catch (Exception e) {
            sendMessage("");
        }
    }


    @Override
    public void onErrorResponse(int errorCode, String errorMsg) {
        try {
            Map map = new HashMap();
            map.put("fun", "onErrorResponse");
            map.put("errorCode", errorCode);
            map.put("errorMsg", errorMsg);
            sendMessage(map);
        } catch (Exception e) {
            sendMessage("");
        }
    }

    @Override
    public void messagesLost(ArrayList arrayList) {
        try {
            Map map = new HashMap();
            map.put("fun", "messagesLost");
            map.put("arrayList", arrayList);
            sendMessage(map);
        } catch (Exception e) {
            sendMessage("");
        }
    }

    @Override
    public void messagesBeReceived(String message) {
        try {
            Map map = new HashMap();
            map.put("fun", "messagesBeReceived");
            map.put("message", message);
            sendMessage(map);
        } catch (Exception e) {
            sendMessage("");
        }
    }

    @Override
    public void onLoginResponse(int code) {
        try {
            Map map = new HashMap();
            map.put("fun", "onLoginResponse");
            map.put("code", code);
            sendMessage(map);
        } catch (Exception e) {
            sendMessage("");
        }
    }

    @Override
    public void onLinkClose(int code) {
        try {
            Map map = new HashMap();
            map.put("fun", "onLinkClose");
            map.put("code", code);
            sendMessage(map);
        } catch (Exception e) {
            sendMessage("");
        }
    }

    @Override
    public void onCancel(Object arguments) {

    }

    private void sendMessage(Object map) {
        try {
            this.events.success(map);
        } catch (Exception e) {
        }
    }


}
