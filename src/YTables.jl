module YTables
using DataFrames

export latex, org

## utility
($)(f::Function, g::Function) = x->f(g(x))


## types
abstract YStyle


immutable LatexStyle <: YStyle
    na::String
    embed_in_table::Bool
    tabular::String
    align::Dict{Symbol, String}
    format::Dict{Symbol, Function}
end


immutable OrgStyle <: YStyle
    na::String
end


immutable YTable
    data
    style::YStyle
end


## constructors
#type_align(_::Number) = "r"
#type_align(_::String) = "l"

type_align{T<:Number}(_::DataArrays.DataArray{T,1}) = "r"
type_align{T<:String}(_::DataArrays.DataArray{T,1}) = "l"


make_align(data) =
    Dict(n => type_align(data[:, n]) for n = names(data))

type_format{T<:Integer}(_::DataArrays.DataArray{T,1}) = v -> @sprintf("%d", v)
type_format{T<:Real}(_::DataArrays.DataArray{T,1})    = v -> @sprintf("%.2f", v)
type_format{T<:String}(_::DataArrays.DataArray{T,1})  = v -> @sprintf("%s", v)

make_format(data) =
    Dict(n => type_format(data[:, n]) for n in names(data))


formatter(f::String) =   @eval v -> @sprintf($f, v)
formatter(f::Function) = f


formatters(fs) =
    [formatter(v) for (k, v) = fs]


latex(data; embed_in_table::Bool=true, tabular::String="tabular",na::String="-",alignment=Dict(), format=Dict()) =
    YTable(data, LatexStyle(na,
                            embed_in_table,
                            tabular,
                            merge(make_align(data), alignment),
                            merge(make_format(data), format)))


org(data ; na::String="NA") = YTable(data, OrgStyle(na))


## printing
format_row(row, format::Dict{Symbol, Function}, na::String) =
    [string(isna(row[n]) ? na : format[n](row[n])) for n in names(row)]

function show_rows(io, data, format, na, pre, sep, post)
    for r = eachrow(data)
        println(io, pre, join(format_row(r, format, na), sep), post)
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
    show_rows(io, data, style.format, style.na, "    ", " & ", " \\\\")
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
    show_rows(io, ns, format, style.na, "| ", " | ", " |")
    println(io, "|-", join([repeat("-", widths[n]) for n = names(data)], "-+-"), "-|")
    show_rows(io, data, format, style.na, "| ", " | ", " |")
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
