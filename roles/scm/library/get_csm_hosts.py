#!/usr/bin/python

from ansible.module_utils.basic import *

def main():
    module = AnsibleModule(
    argument_spec = dict(
        task_vars      = dict(required=True),
        scm_host_list   = dict(required=True)
    ))

    if task_vars is None:
    task_vars = dict()

    result = super(ActionModule, self).run(tmp, task_vars)

    host_ids = {}
    host_names = {}

    # Get SCM host details from inventory
    try:
        scm_host = task_vars["groups"]["scm_server"][0]
        scm_port = task_vars["hostvars"][scm_host]["scm_port"]
        scm_user = task_vars["hostvars"][scm_host]["scm_default_user"]
        scm_pass = task_vars["hostvars"][scm_host]["scm_default_pass"]
    except KeyError as e:
        result['failed'] = True
        result['msg'] = e.message
        module.exit_json(changed=False, meta=result)

    display.vv("Retrieved %d host(s) from SCM" % len(scm_host_list))

    if len(scm_host_list) == 0:
        result['failed'] = True
        result['msg'] = "No hosts defined in SCM"
        module.exit_json(changed=False, meta=result)

    for inv_host in task_vars["hostvars"]:
        host = str(inv_host)
        found_host = False
        for scm_host in scm_host_list:
            try:
                if scm_host.hostname == task_vars["hostvars"][host]["inventory_hostname"]:
                    found_host = True
                elif scm_host.ipAddress == task_vars["hostvars"][host]["inventory_hostname"]:
                    found_host = True
                elif "private_ip" in task_vars["hostvars"][host]:
                    if scm_host.ipAddress == task_vars["hostvars"][host]["private_ip"]:
                        found_host = True

                if found_host:
                    host_ids[host] = scm_host.hostId
                    host_names[host] = scm_host.hostname
                    display.vv("Inventory host '%s', SCM hostId: '%s', SCM hostname: '%s'"
                                % (host, scm_host.hostId, scm_host.hostname))
                    break
            except KeyError as e:
                display.vv("Key '%s' not defined for inventory host '%s'" % (e.message, host))
                continue

        if not found_host:
            display.vv("Unable to determine SCM host details for inventory host '%s'" % host)
            continue

    display.vv("host_ids: %s" % host_ids)
    display.vv("host_names: %s" % host_names)
    result['changed'] = True
    result['host_ids'] = host_ids
    result['host_names'] = host_names
    module.exit_json(changed=False, meta=result)

if __name__ == '__main__':
