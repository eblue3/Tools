#!atomapi/bin/python
# -*- coding: utf-8 -*-
from flask import *

PublicIPapp = Flask(__name__)
ipfile = open("PublicIP.txt","r")

#Copy PyublicIP to WebFolder
import shutil
shutil.copyfile("PublicIP.txt","/var/www/html/PublicIP.txt")

devices = json.loads(ipfile.read())
#print(devices[0]['PublicIP'])   # Only get 1 Key on JSON file
ipfile.close()

# --- --- ROUTE --- --- /api
@PublicIPapp.route('/api', methods=['GET'])
def get_devices():
    return jsonify({'devices': devices})

# --- --- GET --- ---   /api/devices/id
@PublicIPapp.route('/api/devices/<int:device_id>', methods=['GET'])
def get_device(device_id):
    device = [device for device in devices if device['id'] == device_id]
    if len(device) == 0:
        abort(404)
    return jsonify({'devices': device[0]})

# --- --- POST --- ---  /api/devices
@PublicIPapp.route('/api/devices', methods=['POST'])
def create_device():
    if not request.json or not 'Name' in request.json:
        abort(400)
    device = {
        'id': devices[-1]['id'] + 1,
        'Name': request.json.get('Name', devices[0]['Name']),
        'PublicIP': request.json.get('PublicIP', devices[0]['PublicIP'])
    }   # devices id <=> devices[-1] because the list start with [0], but our devices list start with 1.
    devices.append(device)
    with open("PublicIP.txt", "w+") as publicipf:
        json.dump(devices, publicipf)
    return jsonify({'devices': device}), 201
# curl -i -H "Content-Type: application/json" -X POST -d '{"Name":"New Atom"}' http://172.16.70.132:3592/api/devices

# --- --- PUT --- ---   /api/devices/id
@PublicIPapp.route('/api/devices/<int:device_id>', methods=['PUT'])
def update_device(device_id):
    device = [device for device in devices if device['id'] == device_id]
    if len(device) == 0:
        abort(404)
    if not request.json:
        abort(400)
    if 'Name' in request.json and type(request.json['Name']) != str:
        abort(400)
    if 'PublicIP' in request.json and type(request.json['PublicIP']) is not str:
        abort(400)
    device[0]['Name'] = request.json.get('Name', device[0]['Name'])
    device[0]['PublicIP'] = request.json.get(
        'PublicIP', device[0]['PublicIP'])
    with open("PublicIP.txt", "w+") as publicipf:
        json.dump(devices, publicipf)
    return jsonify({'devices': device[0]})
# curl -i -H "Content-Type: application/json" -X PUT -d '{"PublicIP": "NewIP"}' http://172.16.70.132:3592/api/devices                                                                                                                        /2

# --- --- DELETE --- ---    /api/devices/id
@PublicIPapp.route('/api/devices/<int:device_id>', methods=['DELETE'])
def delete_device(device_id):
    device = [device for device in devices if device['id'] == device_id]
    if len(device) == 0:
        abort(404)
    with open("PublicIP.bk", "w+") as publicipf:
        json.dump(devices, publicipf)
    devices.remove(device[0])
    return jsonify({'result': True})

# --- --- ERROR --- ---
@PublicIPapp.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'Error': 'Not Found. Please Try Again.'}), 404)

if __name__ == "__main__":
    PublicIPapp.run(host='172.16.70.132', port=3500, debug=True)
