module YTables
using DataFrames

export latex, org

## utility
($)(f::Function, g::Function) = x->f(g(x))


## types
abstract YStyle


immutable LatexStyle <: YStyle
    embed_in_table::Bool
    tabular::String
    align::Dict{Symbol, String}
    format::Dict{Symbol, Function}
end


immutable OrgStyle <: YStyle
end


immutable YTable
    data
    style::YStyle
end


## constructors
type_align(_::Number) = "r"
type_align(_::String) = "l"


make_align(data) =
    Dict(n => type_align(data[1, n]) for n = names(data))


type_format(_::Integer) = v -> @sprintf("%d", v)
type_format(_::Real)    = v -> @sprintf("%.2f", v)
type_format(_::String)  = v -> @sprintf("%s", v)


make_format(data) =
    Dict(n => type_format(data[1, n]) for n in names(data))


formatter(f::String) =   @eval v -> @sprintf($f, v)
formatter(f::Function) = f


formatters(fs) =
    [formatter(v) for (k, v) = fs]


latex(data; embed_in_table::Bool=true, tabular::String="tabular", alignment=Dict(), format=Dict()) =
    YTable(data, LatexStyle(embed_in_table,
                            tabular,
                            merge(make_align(data), alignment),
                            merge(make_format(data), format)))


org(data) = YTable(data, OrgStyle())


## printing
format_row(row, format::Dict{Symbol, Function}) =
    [string(format[n](row[n])) for n in names(row)]

function show_rows(io, data, format, pre, sep, post)
    for r = eachrow(data)
        println(io, pre, join(format_row(r, format), sep), post)
    end
end


function show_table(io::IO, data::DataFrame, style::LatexStyle)
    println(io, string("% latex table generated in Julia ",
                       VERSION, " by YTables"))
    println(io, string("% ", now()))

    if style.embed_in_table
        println(io, "\\begin{table}[ht]")
        println(io, "  \\centering")
    end
    as = [style.align[n] for n in names(data)]
    println(io, "  \\begin{", style.tabular, "}{", join(as), "}")
    println(io, "    \\hline")
    println(io, "    ", join(map(string, names(data)), " & "), " \\\\")
    println(io, "    \\hline")
    show_rows(io, data, style.format, "    ", " & ", " \\\\")
    println(io, "    \\hline")
    println(io, "  \\end{tabular}")
    if style.embed_in_table
        print(io, "\\end{table}")
    end
end


function show_table(io::IO, data::DataFrame, style::OrgStyle)
    valwidths = map(c->mapreduce(length $ string, max, c), eachcol(data))
    widths = Dict(n => max(length(string(n)), vs[1]) for (n,vs) = eachcol(valwidths))
    format = Dict(n => formatter("%$v\s") for (n,v) = widths)
    ns = DataFrame(convert(Array{Any, 1}, [[n] for n in names(data)]), names(data))
    show_rows(io, ns, format, "| ", " | ", " |")
    println(io, "|-", join([repeat("-", widths[n]) for n = names(data)], "-+-"), "-|")
    show_rows(io, data, format, "| ", " | ", " |")
end


import Base.show
function show(io::IO, t::YTable)
    show_table(io, t.data, t.style)
end

import Base.writecsv
function writecsv(filename, a::YTable; opts...)
    io = open(filename, "w")
    show(io, a)
    close(io)
end

end # module
