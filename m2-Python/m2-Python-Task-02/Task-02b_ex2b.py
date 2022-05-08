### Task-02b

#Ex2b
'''Сделать копию скрипта задания 6.2a.
Дополнить скрипт: Если адрес был введен неправильно, запросить адрес снова.'''

ip = input('Input IP address in a format 10.0.1.1: ')
try:
    oct1, oct2, oct3, oct4 = ip.split('.')
except ValueError:
    print('IP should consists of 4 octets, divided with dots: 10.0.1.1')
while len(ip.split('.')) != 4 or int(oct1) not in range(0, 256) or int(oct2) not in range(0, 256)\
        or int(oct3) not in range(0, 256) or int(oct4) not in range(0, 256):
    ip = input('Incorrect IP address. Try once more:')
    try:
        oct1, oct2, oct3, oct4 = ip.split('.')
    except ValueError:
        print('IP should consists of 4 octets, divided with dots: 10.0.1.1')

if int(ip.split('.')[0]) in range(1, 224):
    print('unicast')
elif int(ip.split('.')[0]) in range(224, 240):
    print('multicast')
elif ip == '255.255.255.255':
    print('local broadcast')
elif ip == '0.0.0.0':
    print('unassigned')
else:
    print('unused')