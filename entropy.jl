mutable struct Result
    score::Array{Int64}
    man_ans::Int64
    mach_ans::Int64
end

mutable struct Basics
    a::Array{Int64}
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

"""Calcula a resposta da maquina"""
function move!(r::Result, b::Basics)
    if b.moves < 3
        r.mach_ans = 2
    elseif abs.(a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 1] - a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 2]) <= 1.8*(1.01^b.moves)
        r.mach_ans = 2
    elseif a[b.p1+ 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 1] < a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, 2]
        r.mach_ans = 1
    else
        r.mach_ans = 0
    end
    a[b.p1 + 1, b.c1 + 1, b.p2 + 1, b.c2 + 1, r.man_ans + 1] += 1.1^b.moves
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

function answer(ans::Int64, result::Result)
    result.man_ans = ans
end

"""Faz a jogada e da print no score e número de jogadas"""
function play(ans::Int64, a::Array{Float64}, r::Result, b::Basics)
    answer(ans, r)
    move!(r, b)
    evaluate!(r)
    if r.mach_ans == 2
        print("-----------Play $(b.moves)-----------------\n")
        print("Machine move - pass  | Machine score - $(r.score[MACH])\n")
        print("Man move - $(r.man_ans)         | Man score - $(r.score[MAN])\n")
    else
        print("-----------Play $(b.moves)-----------------\n")
        print("Machine move - $(r.mach_ans)  | Machine score - $(r.score[MACH])\n")
        print("Man move - $(r.man_ans)      | Man score - $(r.score[MAN])\n")
        print("Moves - $(b.moves)\n")
    end
end

a, r, b = initialize()
for i = 1:30000
    play(rand([0, 1]), a, r, b)
end
