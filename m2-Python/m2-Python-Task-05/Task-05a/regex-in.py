#!/usr/bin/env/python3

"""Task-05a"""

import re


def main() -> None:
    # IPv4 address pattern
    ip4 = 'Some IP address: 172.16.12.50/24'
    ip4_short = re.search(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", ip4)
    print(ip4_short)
    ip4_valid = re.search(r"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.)"
                          r"{3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", ip4)
    print(ip4_valid)
    ip4_cidr = re.search(r"((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)([/][0-3][0-2]?|[/][1-2][0-9]|[/][0-9])?$", ip4)
    print(ip4_cidr)
    ip4_private = re.search(r"(10(\.(25[0-5]|2[0-4][0-9]|1[0-9]{1,2}|[0-9]{1,2})){3}|((172\.(1[6-9]|2[0-9]|3[01]))|192\.168)(\.(25[0-5]|2[0-4][0-9]|1[0-9]{1,2}|[0-9]{1,2})){2})([/][0-3][0-2]?|[/][1-2][0-9]|[/][0-9])?$", ip4)
    '''CIDR check added to the end. CIDR regex: ([/][0-3][0-2]?|[/][1-2][0-9]|[/][0-9])?'''
    print(ip4_private)

    # IPv6 address pattern
    ip6 = 'Some IPv6 address: fe80:0000:0000:0000:0204:61ff:fe9d:f156'
    ip6_short = re.search(r"\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:)"
                          r"{6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?"
                          r"\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d"
                          r"|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:"
                          r"[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]"
                          r"|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:"
                          r"[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?"
                          r"\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4})"
                          r"{0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))"
                          r"{3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4})"
                          r"{0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))"
                          r"{3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]"
                          r"\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$", ip6)
    print(ip6_short)

    # IP mask
    mask = 'Some IP mask: 255.255.255.248'
    msk_valid = re.search(r"((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", mask)
    print(msk_valid)

    # MAC address
    mac = 'Some string with mac: 3D-F2-C9-A6-B3-4F'
    mac_linux_windows = re.search(r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$', mac)
    print(mac_linux_windows)
    mac_c = 'Cisco format: 0010.7b3a.923c'
    mac_cisco = re.search(r'([0-9A-Fa-f]{4}\.){2}([0-9A-Fa-f]{4})$', mac_c)
    print(mac_cisco)
    mac_any = re.search(r'\b(?:(?<![-:\.])(?:(?:[0-9A-Fa-f]{2}(?=([-:\.]))(?:\1[0-9A-Fa-f]{2}){5})|(?:[0-9A-Fa-f]{4}'
                        r'(?=([-:\.]))(?:\2[0-9A-Fa-f]{4}){2}))(?![-:\.])|(?:[0-9A-Fa-f]{12}))\b', mac)
    print(mac_any)

    # Domain address
    domain = 'Some domain.com.ua'
    domain_name = re.search(r'([A-Za-z0-9]\.|[A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9]\.){1,3}[A-Za-z]{2,6}$', domain)
    print(domain_name)
    tld = domain_name.group().split('.')[-1]
    print(tld)
    second_ld = domain_name.group().split('.')[-2]
    print(second_ld)

    # Email
    address = 'yuriypelykh@gmail.com'
    email = re.search(r'[^@]+@[^@]+\.[^@]+', address)
    print(email)

    # URI
    uri = '<p>Hi!</p><a href="https://example.com/downloads/1.jpg">More Examples</a><a ' \
          'href="http://example2.com">Even More Examples</a>'
    uris = re.findall(r'(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^'
                      r'\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?«»“”‘’]))', uri)
    print(uris)

    # URL
    url = '<p>Hi!</p><a href="http://example.com.ua/downloads/1.jpg">More Examples</a><a ' \
          'href="http://example2.com">Even More Examples</a>'
    urls = re.findall('https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+', url)
    print(urls)

    # SSH Key private
    # SSH Key public
    key = """-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA+xGZ/wcz9ugFpP07Nspo6U17l0YhFiFpxxU4pTk3Lifz9R3zsIsu
ERwta7+fWIfxOo208ett/jhskiVodSEt3QBGh4XBipyWopKwZ93HHaDVZAALi/2A
+xTBtWdEo7XGUujKDvC2/aZKukfjpOiUI8AhLAfjmlcD/UZ1QPh0mHsglRNCmpCw
mwSXA9VNmhz+PiB+Dml4WWnKW/VHo2ujTXxq7+efMU4H2fny3Se3KYOsFPFGZ1TN
QSYlFuShWrHPtiLmUdPoP6CV2mML1tk+l7DIIqXrQhLUKDACeM5roMx0kLhUWB8P
+0uj1CNlNN4JRZlC7xFfqiMbFRU9Z4N6YwIDAQAB
-----END RSA PUBLIC KEY-----"""
    key_found = re.search('-{3}\n([\s\S]*?)\n-{3}', key)
    print(key_found.group().strip('---'))

    # Card number
    card = '5123-4567-8912-3456'
    card_number = re.findall('(?:[0-9]{4}-){3}[0-9]{4}|[0-9]{16}', card)
    print(card_number)

    # UUID
    uuid = '6a2f41a3-c54c-fce8-32d2-0324e1c32e22'
    uuids = re.findall('[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}', uuid)
    print(uuids)


if __name__ == '__main__':
    main()
