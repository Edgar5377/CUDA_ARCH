#Programa en Julia

import CPUTime


clock1 = time()

tamaño = 200 #size es una palabra reservada # dimension del espacio
imp0 = 377.0
maxTime = 250

#println(size)

ez = zeros(Float64, tamaño)
hy = zeros(Float64, tamaño)
E50 = zeros(Float64, maxTime)
ez_time = Vector{Vector{Float64}}()
hy_time = Vector{Vector{Float64}}()
#println(size(ez))
"""
println(hy)
println(size(hy))
println(hy[1])
"""
#TODO CPU
#variables para medir el CPU maxTime
##
# ¿Como guardar archivos?

# BUCLE 1 qtime - Tiempo

for qtime in 1:(maxTime)
    #println(qtime)

    # BUCLE 2 hy - Magnetic Field
    for mm in 1:(tamaño-1)
        #println(mm)        
        hy[mm] = hy[mm] + (ez[mm+1] - ez[mm]) / imp0
    end
    # BUCLE 3 ez - Electric Field
    for mm in 2:(tamaño)
        ez[mm] = ez[mm] + (hy[mm] - hy[mm-1]) * imp0
    end

    #node
    ez[1] = exp((-1 * (qtime - 30.0) * (qtime - 30.0)) / 100.0)
    E50[qtime] = ez[50]

    # Almacenar las copias de los vectores
    push!(ez_time, copy(ez))
    push!(hy_time, copy(hy))
end

#println(dec(time_ns()))
#Guardando datos

h = open("H.txt", "w") do h
    for i in 1:tamaño
        println(h, hy[i])
    end
end

e = open("E.txt", "w") do e
    for i in 1:tamaño
        println(e, ez[i])
    end
end
t = open("T.txt", "w") do t
    for i in 1:maxTime
        println(t, i)
    end
end
e50 = open("E50.txt", "w") do e50
    for i in 1:maxTime
        println(e50, E50[i])
    end
end

println("Tiempo de ejecución: ",time() - clock1)

#TODO CPU

using Plots
using LaTeXStrings

# Supongamos que ya tienes los vectores ez y hy, y el valor de maxTime
tiempo_final = maxTime

# Crear la gráfica
plot(1:tamaño, ez, label="Campo Eléctrico (ez)", xlabel="Posición", ylabel="Magnitud", title="Campos Electromagnéticos en el Tiempo Final", lw=2)
plot!(1:tamaño, hy, label="Campo Magnético (hy)", lw=2)

# Guardar la gráfica como imagen
savefig("campos_electromagneticos.png")

# Mostrar la gráfica
display(plot)


using Plots
using LaTeXStrings

# Datos de ejemplo
tamaño = 200
maxTime = 250
ez = [rand(tamaño) for _ in 1:maxTime]  # Reemplazar con tus datos
hy = [rand(tamaño) for _ in 1:maxTime]  # Reemplazar con tus datos

# Crear la animación
anim = @animate for t in 1:maxTime
    plot(1:tamaño, ez_time[t], label="Campo Eléctrico (ez)", xlabel="Posición", ylabel="Magnitud", title="Campos Electromagnéticos", lw=2, ylim=(-1, 1))
    plot!(1:tamaño, hy_time[t], label="Campo Magnético (hy)", lw=2)
end

# Guardar la animación
gif(anim, "campos_electromagneticos.gif", fps=15)
