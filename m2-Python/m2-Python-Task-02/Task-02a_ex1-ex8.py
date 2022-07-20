### Task-02a

# Ex1
'''Обработать строку nat таким образом,
чтобы в имени интерфейса вместо FastEthernet
было GigabitEthernet.'''

NAT = "ip nat inside source list ACL interface FastEthernet0/1 overload"
NAT = NAT.replace('Fast', 'Gigabit')
print(NAT)

# Ex2
'''Преобразовать строку mac из формата
XXXX:XXXX:XXXX в формат XXXX.XXXX.XXXX'''

mac = 'AAAA:BBBB:CCCC'
print(mac.replace(':', '.'))

# Ex3
'''Получить из строки config список VLAN-ов
вида: ['1', '3', '10', '20', '30','100']'''

config = 'switchport trunk allowed vlan 1,3,10,20,30,100'
vlan_list = config.split()[-1].split(',')
print(vlan_list)

# Ex4
'''Из списка нужно получить уникальный список VLAN-ов,
отсортированный по возрастанию номеров.'''

vlans = [10, 20, 30, 1, 2, 100, 10, 30, 3, 4, 10]
unique_vlans = list(set(vlans))
unique_vlans.sort()
print(unique_vlans)

# Ex5
'''Из строк command1 и command2 получить список VLAN-ов,
которые есть и в команде command1 и в команде command2.
Результатом должен быть список: ['1', '3', '8']'''

command1 = 'switchport trunk allowed vlan 1,2,3,5,8'
command2 = 'switchport trunk allowed vlan 1,3,8,9'

vlan_set_1 = set(command1.split()[-1].split(','))
vlan_set_2 = set(command2.split()[-1].split(','))
common_vlans = list(vlan_set_1.intersection(vlan_set_2))
print(common_vlans)

# Ex6
'''Обработать строку ospf_route и вывести информацию
на стандартный поток вывода в виде:
Protocol:           OSPF
Prefix:             10.0.24.0/24
AD/Metric:          110/41
Next-Hop:           10.0.13.3
Last update:        3d18h
Outbound Interface: FastEthernet0'''

ospf_route = 'O 10.0.24.0/24 [110/41] via 10.0.13.3, 3d18h, FastEthernet0/0'


def proto_def(sign):
    protocols = {'O': 'OSPF', 'R': 'RIP', 'I': 'IS-IS', 'E': 'EIGRP'}
    return protocols.get(sign)


route_info = ospf_route.split()
template = """Protocol:           {proto}
Prefix:             {ip}
AD/Metric:          {metric}
Next-Hop:           {next}
Last update:        {last_update}
Outbound Interface: {interface}"""
output = template.format(proto=proto_def(route_info[0]),
                         ip=route_info[1],
                         metric=route_info[2].strip('[]'),
                         next=route_info[4].strip(','),
                         last_update=route_info[5].strip(','),
                         interface=route_info[6])
print(output)

# Ex7
'''Преобразовать MAC-адрес mac в двоичную строку такого вида:
101010101010101010111011101110111100110011001100'''

mac = 'AAAA:BBBB:CCCC'

mac_16 = mac.split(':')
mac_2 = ""
for each in mac_16:
    mac_2 += f'{int(each, 16):08b}'
print(mac_2)

# Ex8
'''Преобразовать IP-адрес в двоичный формат и вывести
на стандартный поток вывода вывод столбцами, таким образом:
• первой строкой должны идти десятичные значения байтов
• второй строкой двоичные значения
Вывод должен быть упорядочен также, как в примере:
• столбцами
• ширина столбца 10 символов
Пример вывода для адреса 10.1.1.1:
10       1        1        1 
00001010 00000001 00000001 00000001'''

ip = '192.168.3.1'

oct1, oct2, oct3, oct4 = ip.split('.')
message = f'''{int(oct1):<10}{int(oct2):<10}{int(oct3):<10}{int(oct4):<10}
{f'{int(oct1):08b}':<10}{f'{int(oct2):08b}':<10}{f'{int(oct3):08b}':<10}{f'{int(oct4):08b}':<10}'''
print(message)
