# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# Module of Optimization Tool for Tufin
# OS: Windows
# Language & Version: Python 3.9.2
__author__ = "Do Hoang Anh"
__credits__ = ["Do Hoang Anh"]
__maintainer__ = "Do Hoang Anh"
__email__ = "blue3.do@gmail.com"
__status__ = "Completed"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# Library & Modules Import------------------------------------------------------
import requests
import urllib3
urllib3.disable_warnings()
import xml.etree.ElementTree as ET
# ------------------------------------------------------------------------------

# Juniper Optimization Function ------------------------------------------------
def Juniper(TufinIP, userpassencoded, deviceID, deviceName, curtime):
    # Example:
    #set security policies from-zone <from_zone> to-zone <to_zone> policy <policy_name> then log session-init
    #set security policies from-zone <from_zone> to-zone <to_zone> policy <policy_name> then log session-close
    print("[D] Generating Juniper scripts for bulk log enable.")
    from_zone = ""
    to_zone = ""
    policy_name = ""
    txtPath = "./{}/enable-log-{}.txt".format(deviceName, curtime)
    url = "https://{}/securetrack/api/rule_search/{}?search_text=log.isempty:true rule.isdisabled:false".format(TufinIP, deviceID)
    headers = {
        'Authorization': "Basic %s" %userpassencoded
        }
    response = requests.get(url, headers=headers, verify=False)
    tree = ET.fromstring(response.content)
    for child in tree:
        if child.tag == "rule":
            for y in child:
                if y.tag == "binding":
                    for z in y:
                        if z.tag == "from_zone":
                            from_zone = z.text
                        if z.tag == "to_zone":
                            to_zone = z.text
                if y.tag == "name":
                    policy_name = y.text
            f = open(txtPath, "a+")
            print("File Name: {}".format(txtPath))
            print("Writing script for {}".format(policy_name))
            f.write("set security policies from-zone {} to-zone {} policy {} then log session-init\n".format(from_zone, to_zone, policy_name))
            f.write("set security policies from-zone {} to-zone {} policy {} then log session-close\n".format(from_zone, to_zone, policy_name))
            f.close()
        else:
            pass
    print("Enable Log script file: {}\nPaste it on Juniper using SSH CLI to enable log.".format(txtPath))
# ------------------------------------------------------------------------------

# Main Function ----------------------------------------------------------------
def OptimizeNoLog(TufinIP, userpassencoded, deviceID, deviceName, deviceType, curtime):
    # Model define
    CheckPoint_model = ["cp_clm", "cp_mds", "cp_cma", "cp_domain_r80plus", "cp_smc_r80plus", "cp_mds_r80plus", "cp_smrt_cntr", "module", "module_cluster"]
    Cisco_model = ["router", "xr_router", "nexus", "asa", "L3_switch", "switch", "fwsm", "csm", "csm_asa", "csm_fwsm", "csm_router", "csm_nexus", "csm_switch", "fmc", "firepower", "fmc_domain", "aci", "aci_tenant"]
    Juniper_model = ["netscreen", "netscreen_cluster", "junos", "junosStateless", "nsm", "nsm_device", "nsm_netscreen_isg"]
    PaloAlto_model = ["Panorama_ng", "Panorama_device_group", "Panorama_ng_fw", "Panorama", "PaloAltoFW", "Panorama_device", "Panorama_device_cluster"]
    Fortinet_model = ["fortimanager", "fmg_adom", "fmg_firewall", "fmg", "fmg_vdom", "fmg_fw", "fmg_vdom_manager", "fortigate"]
    Stonesoft_model = ["stonesoft_smc", "single_fw", "master_engine", "virtual_fw", "fw_cluster"]
    McAfee_model = ["mcafeeFW"]
    F5_model = ["bigip"]
    NewF5_model = ["new_bigip"]
    BlueCoat_model = ["proxysg"]
    Linux_model = ["iptables"]
    VMware_model = ["nsx_manager", "nsx_fw", "nsx_lrtr", "nsx_edge"]
    Amazon_model = ["aws_manager", "aws_vpc"]
    Openstack_model = ["openStack_manager", "openStack_region"]
    Azure_model = ["azure_rm_manager", "azure_rm_vnet"]

    # Export with No Hit polices in all Device
    url = "https://{}/securetrack/api/rule_search/export?search_text=log.isempty:true".format(TufinIP)
    headers = {
        'Authorization': "Basic %s" %userpassencoded
        }
    print("[D] Exporting all No Log policy!")
    response = requests.get(url, headers=headers, verify=False)
    print("[D] Done.\n[D] Please check your Tufin Report Repository [Dashboard > Report > Reports Repository].\n")

    # Depend on Device Type
    for x in range(0, len(deviceID)):
        print("[D] Working on device: {}.".format(deviceName[x]))
        if deviceType[x] in CheckPoint_model:
            print("No supported CLI for Checkpoint!\nPlease manually enable log on Checkpoint devices.\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Cisco_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Juniper_model:
            Juniper(TufinIP, userpassencoded, deviceID[x], deviceName[x], curtime)
        elif deviceType[x] in PaloAlto_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Fortinet_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Stonesoft_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in McAfee_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in F5_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in NewF5_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in BlueCoat_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Linux_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in VMware_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Amazon_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Openstack_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        elif deviceType[x] in Azure_model:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
        else:
            print("No supported code yet. Please contact Author!\n- - - - - - - - - - - - - - - - - - - - -")
# ------------------------------------------------------------------------------
