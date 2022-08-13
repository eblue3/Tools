import requests
import random
import string

def junkspam(url, data, headers, session):
    url = "https://vpbank.vn-zr.top/createOrder"
    headers = {
        "authority": "vpbank.vn-zr.top",
        "accept": "application/json, text/javascript, */*; q=0.01",
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "x-requested-with": "XMLHttpRequest",
        "sec-ch-ua-mobile": "?1",
        "user-agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.82 Mobile Safari/537.36",
        "sec-ch-ua-platform": "^\^\"Android^\^\"",
        "origin": "https://vpbank.vn-zr.top",
        "sec-fetch-site": "same-origin",
        "sec-fetch-mode": "cors",
        "sec-fetch-dest": "empty",
        "referer": "https://vpbank.vn-zr.top/",
        "accept-language": "en-US,en;q=0.9",
        "cookie": "think_language=en-US; PHPSESSID=f2pnhog0lp4iqjft2nqto7vp8u"
    }
    jname_rng = random.sample(set('789'), 1)
    jnum_rng = jname_rng = random.sample(set('345'), 1)
    jname = ''.join(random.choice(string.ascii_lowercase) for _ in range(jname_rng))
    jnum = ''.join(random.choice(string.digits) for _ in range(jnum_rng))
    junkitem = jname+jnum
    jpass = ''.join(random.choice(string.ascii_lowercase + string.ascii_uppercase + string.digits) for _ in range(12))
    data = "orderid=&account={}&pass={}&bankname=VPBank&d_ip=&d_location=&d_loc=".format(junkitem, jpass)
    r = requests.post(url, headers=headers, data=data)
    if (r.status_code) == 200:
        print("{}: Sent OK!".format(data))
    else:
        print("{}: [{}] {}".format(data, r.status_code, r.text))