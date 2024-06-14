import matplotlib.pyplot as plt
import numpy as np


E = np.genfromtxt('E.txt') #
E50 = np.genfromtxt('E50.txt') #

H = np.genfromtxt('H.txt') #

t = np.genfromtxt('T.txt') #

plt.plot(t,E50)

plt.show()
