using CSV, DataFrames, Plots, Distributions
plotlyjs()

"""Estrutura de dados dos Resultados"""
mutable struct Result
    score::Array{Int64}
    man_ans::Int64
    mach_ans::Int64
end

"""Estrutura de dados para a construção do método"""
mutable struct Basics
    a::Array{Float64}
    p1::Int64
    p2::Int64
    c1::Int64
    c2::Int64
    moves::Int64
end

#constants
const MACH = 1
const MAN = 2

"""Avalia respostas e retorna resultado acumulado"""
function evaluate!(result::Result)
    if result.mach_ans != 2
        if result.mach_ans == result.man_ans
            result.score[MACH] += 1
        else
            result.score[MAN] += 1
        end
    end
    return nothing
end

"""Calcula a resposta da maquina por magia negra"""
function move!(r::Result, b::Basics)
    if b.moves < 3
        r.mach_ans = 2
    elseif abs.(b.a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 1] - b.a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 2]) <= 1.8*(1.01^b.moves)
        r.mach_ans = 2
    elseif b.a[b.p1+ 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 1] < b.a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 2]
        r.mach_ans = 1
    else
        r.mach_ans = 0
    end
    b.a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, r.man_ans + 1] += 1.1^b.moves
    b.c1 = b.c2
    b.c2 = r.mach_ans
    b.p1 = b.p2
    b.p2 = r.man_ans
    b.moves += 1
    return nothing
end

"""Inicializa o jogo"""
function initialize()
    a = zeros(2, 3, 2, 3, 2)
    b = Basics(a, 0, 0, 0, 0, 0)
    r = Result(zeros(2), 1, 0)
    return a, r, b
end

"""Coloca a resposta fo humano na estrutura Result"""
function answer!(ans::Int64, result::Result)
    result.man_ans = ans
    return nothing
end

"""Faz a jogada e da print no score e número de jogadas"""
function play(ans::Int64, a::Array{Float64}, r::Result, b::Basics)
    answer!(ans, r)
    move!(r, b)
    evaluate!(r)
end

"""Aplica o método para a série de 1s e 0s inputada"""
function test_machine(timeserie::Vector{Float64})
    len = length(timeserie)
    up_or_down = Array{Int64}(len - 1)
    #Transform timeserie into 0's (down) and 1's (up)
    for i = 1:len-1
        if timeserie[i] < timeserie[i + 1]
            up_or_down[i] = 1
        else
            up_or_down[i] = 0
        end
    end
    a, r, b = initialize()
    for i = 1:len-1
        play(up_or_down[i], a, r, b)
    end
    machine_wins = r.score[MACH]
    machine_loses = r.score[MAN]
    return Dict("machine_wins" => machine_wins, "machine_loses" => machine_loses, "timeserie" => timeserie)
end

"""Plota os resultados: O histograma em azul representa a disperção do número de acertos da máquina
   enquanto o vermelho representa a disperção do número de erros. A linha azul
   representa o número de acertos para a timeserie testada e o a linha vermelha
   o número de erros"""
function plot_results(result::Dict{String, Any})
    len = length(result["timeserie"])
    machinescore = Array{Int64}(10000)
    manscore = Array{Int64}(10000)
    for j = 1:10000
        a, r, b = initialize()
        for i = 1:len - 1
            play(rand([0, 1]), a, r, b)
        end
        machinescore[j] = r.score[MACH]
        manscore[j] = r.score[MAN]
    end
    histogram(machinescore)
    histogram!(manscore)
    vline!([result["machine_wins"] result["machine_loses"]], color = ["blue" "red"])
end

#Scripts

#Esse script permite testar os número de acertos em uma serie "timeseries" desejada
#A função test_machine ja transforma a série em 0's e 1's
timeseries = ... #Definir timeseries
res = test_machine(timeseries)
plot_results(res)

#Esse script permite testar em números aleatórios
plays = 200 #Número de jogadas
timeserie = Array{Int64}(plays)
a, r, b = initialize()
for i = 1:plays
    timeserie[i] = rand(Bernoulli(0.5))
    play(timeserie[i], a, r, b)
end
res = Dict("machine_wins" => r.score[MACH], "machine_loses" => r.score[MAN], "timeserie" => timeserie)
plot_results(res)
