import pprint
import json
import sys
import os

PATH = os.path.dirname(os.path.abspath(__file__))
INVENTORY_FILE_PATH = os.path.join(PATH,'..','hosts')
inventory_template = '''
[scm_server]
{spot_cdh_scm}

[krb5_server]
{spot_cdh_scm}

[db_server]
{spot_cdh_scm}

[utility_servers:children]
scm_server
db_server
krb5_server

[gateway_servers]
utiliy_servers

[master_servers]
{spot_cdh_master}

[worker_servers]
{spot_cdh_worker}

#following three roles are also installed on scm as of now
[ldap_servers]
{spot_cdh_scm}

[worker_servers:vars]
host_template=HostTemplate-Workers

[cdh_servers:children]
utility_servers
gateway_servers
master_servers
worker_servers
'''

def parse_file(file_name):
    result = {}
    with open(file_name,'r') as tf_file:
        tf_data = json.loads(tf_file.read())
        buffer = {}
        for element in tf_data['modules']:
            buffer = {}
            buffer = element['outputs']
            resource_info = buffer.copy()
            resource_info.update(buffer)

        for key, value in resource_info.iteritems():
            result[key] = value['value']
    return result

def write_to_file(file_name,f_output):
    with open(file_name,'w') as f:
        f.write(f_output)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Usage: make_inventory.py <tfstate file name>')
        sys.exit()
    value_dict = parse_file(sys.argv[1])
    value_dict_normalized = {}
    for key, value in value_dict.items():
        if isinstance(value_dict[key],list):
            value_dict_normalized[key] = '\n'.join(value_dict[key])
        else:
            value_dict_normalized[key] = value_dict[key]
    inventory_value = str(inventory_template.format(**value_dict_normalized))
    print(inventory_value)
    write_to_file(INVENTORY_FILE_PATH,inventory_value)
