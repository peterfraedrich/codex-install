#!/usr/bin/python

# config.py

def get_eth_port():
	r = open('/root/codex-install/eth', 'r')
	a = r.readlines()
	a = a[0].strip(' ')
	a = a.split('inet addr:')
	a = a[1].split(' ')
	a = a[0]
	return a

def ask_ip():
	ip = raw_input('Type the IP address of this Codex server: ')
	return ip

def load_config():
	r = open('/codex/js/angular-modules.js','r')
	angular_modules = r.readlines()
	return angular_modules

def write_config(ip,data):
	r = open('/codex/js/angular-modules.js','w')
	for i in data:
		if "var rooturl" in i:
			r.write("    var rooturl = 'http://"+ip+":666'\n")
		else:
			r.write(i)
	r.close()

ip = ask_ip()
data = load_config()
write_config(ip,data)
exit()


