### Task-02b

#Ex2a
'''Сделать копию скрипта задания 6.2.
Добавить проверку введенного IP-адреса.
Адрес считается корректно заданным, если он:
    • состоит из 4 чисел разделенных точкой,
    • каждое число в диапазоне от 0 до 255.
Если адрес задан неправильно, выводить сообщение: „Неправильный IP-адрес“'''

ip = input('Input IP address in a format 10.0.1.1: ')

try:
    oct1, oct2, oct3, oct4 = ip.split('.')
except ValueError:
    print('IP should consists of 4 octets, divided with dots')

if int(oct1) in range(0, 256) and int(oct2) in range(0, 256)\
        and int(oct3) in range(0, 256) and int(oct4) in range(0, 256):
    pass
else:
    print('Incorrect IP address')
    exit(-1)

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