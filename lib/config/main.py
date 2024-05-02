from flask import Flask, jsonify, request
from agora_token_builder import RtcTokenBuilder, RtmTokenBuilder
import os
import time

app = Flask(__name__)

app_id = os.environ.get("APP_ID", "17642ba74dc1423b9cafea30e6cdb88e")
app_certificate = os.environ.get("APP_CERTIFICATE", "0cd11d5efba64df5bf6673ab4cf5da46")

def generate_rtc_token(channel_name, uid_str, token_type, role, expire_timestamp):
    if token_type == "userAccount":
        print(f"Building Token with userAccount: {uid_str}")
        rtc_token = RtcTokenBuilder.build_token_with_user_account(app_id, app_certificate, channel_name, uid_str, role, expire_timestamp)
        return rtc_token
    elif token_type == "uid":
        uid = int(uid_str)
        print(f"Building Token with uid: {uid}")
        rtc_token = RtcTokenBuilder.build_token_with_uid(app_id, app_certificate, channel_name, uid, role, expire_timestamp)
        return rtc_token
    else:
        raise ValueError(f"Failed to generate RTC token for unknown token type: {token_type}")

def generate_rtm_token(uid_str, expire_timestamp):
    print("rtm token")
    rtm_token = RtmTokenBuilder.build_token(app_id, app_certificate, uid_str, RtmTokenBuilder.RoleRtmUser, expire_timestamp)
    return rtm_token

@app.route('/ping')
def ping():
    return jsonify(message='pong')

@app.route('/rtc/<channel_name>/<role>/<token_type>/<uid>/', methods=['GET'])
def get_rtc_token(channel_name, role, token_type, uid):
    print("rtc token")
    try:
        expire_timestamp = int(request.args.get('expiry', '3600'))
        rtc_token = generate_rtc_token(channel_name, uid, token_type, role, expire_timestamp)
        return jsonify(rtcToken=rtc_token), 200
    except Exception as e:
        return jsonify(error=str(e), status=400), 400

@app.route('/rtm/<uid>/', methods=['GET'])
def get_rtm_token(uid):
    print("rtm token")
    try:
        expire_timestamp = int(request.args.get('expiry', '3600'))
        rtm_token = generate_rtm_token(uid, expire_timestamp)
        return jsonify(rtmToken=rtm_token), 200
    except Exception as e:
        return jsonify(error=str(e), status=400), 400

@app.route('/rte/<channel_name>/<role>/<token_type>/<uid>/', methods=['GET'])
def get_both_tokens(channel_name, role, token_type, uid):
    print("dual token")
    try:
        expire_timestamp = int(request.args.get('expiry', '3600'))
        rtc_token = generate_rtc_token(channel_name, uid, token_type, role, expire_timestamp)
        rtm_token = generate_rtm_token(uid, expire_timestamp)
        return jsonify(rtcToken=rtc_token, rtmToken=rtm_token), 200
    except Exception as e:
        return jsonify(error=str(e), status=400), 400

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 8080))
    app.run(port=port)