# from matplotlib.pyplot import*
# from math import*

# plot(1,3,"*")
# plot(2,6,'bo')
# plot(4,5,'r+')
# show()


# 1/ Ce programme affiche :
#   - a>20 car "if" et "elif" sont des conditions, si la première est validée, la deuxième ne s'affichera pas.


a=42
if a>20: 
    print ("a>20")
    if a>30:
        print("a>30")
# Nous avons changé "elif" par "if" sur la ligne 17

a=42
if a>30:
    print("a>30")
if (a>=20)and (a<=30):
    print("20<=a<=30")

