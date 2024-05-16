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

a = 42
if a > 30:
    print(f"{a}>30")
if (a >= 20) and (a <= 30):
    print("20<={a}<=30")

if a > 50:
    print(f"{a}>50")
else:
    print(f"{a}<=50")

    a = 42  # Définit une variable 'a' et lui attribue la valeur 42

    # Vérifie si 'a' est supérieur à 30. Si c'est le cas, il imprime "42>30" (ou quelle que soit la valeur de 'a')
    if a > 30:
        print(f"{a}>30")

    # Vérifie si 'a' est supérieur ou égal à 20 et inférieur ou égal à 30. Si c'est le cas, il imprime "20<=42<=30" (ou quelle que soit la valeur de 'a')
    if (a >= 20) and (a <= 30):
        print(f"20<={a}<=30")

    # Vérifie si 'a' est supérieur à 50. Si c'est le cas, il imprime "42>50" (ou quelle que soit la valeur de 'a'). Sinon, il imprime "42<=50" (ou quelle que soit la valeur de 'a')
    if a > 50:
        print(f"{a}>50")
    else:
        print(f"{a}<=50")