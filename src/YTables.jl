module YTables

using DataFrames, Datetime

## utility
($)(f::Function, g::Function) = x->f(g(x))


sprintf(fmt, val) = @eval @sprintf($fmt, $val)


## types
abstract YStyle


immutable LatexStyle <: YStyle
    tabular::String
    align::Dict{Symbol, ASCIIString}
    format::Dict{Symbol, ASCIIString}
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


make_align(data) = [n => type_align(data[1, n]) for n = names(data)]


type_format(_::Integer) = "%d"
type_format(_::Real) = "%.2f"
type_format(_::String) = "%s"


make_format(data) = [n => type_format(data[1, n]) for n = names(data)]


latex_table(data; tabular::String="tabular", alignment=Dict(), format=Dict()) =
    YTable(data, LatexStyle(tabular,
                            merge(make_align(data), alignment),
                            merge(make_format(data), format)))


org_table(data) = YTable(data, OrgStyle())


## printing
function format_row(row::DataFrameRow{DataFrame}, format::Dict{Symbol, ASCIIString})
    return map(n -> sprintf(format[n], row[n]), names(row))
end


function show_table(io::IO, data::DataFrame, style::LatexStyle)
    println(io, string("% latex table generated in Julia ",
                       VERSION, " by YTables"))
    println(io, string("% ", now()))

    println(io, "\\begin{table}[ht]")
    println(io, "  \\centering")
    println(io, "  \\begin{", style.tabular, "}{",
            join(map(n->style.align[n], names(data)), ""), "}")
    println(io, "    \\hline")
    println(io, "    ", join(map(string, names(data)), " & "), " \\\\")
    println(io, "    \\hline")

    println(io, "    ",
            join(map(row -> join(format_row(row, style.format), " & "),
                     eachrow(data)),
                 " \\\\ \n    "), " \\\\")

    println(io, "    \\hline")
    println(io, "  \\end{tabular}")
    println(io, "\\end{table}")
end


function show_table(io::IO, data::DataFrame, style::OrgStyle)
    ns = names(data)
    println(io, "| ", join(map(string, ns), " | "), " |")
    println(io, "|-", repeat("-+-", length(ns) - 1), "-|")
    for r = eachrow(data)
        println(io, "| ", join(map(n->r[n], ns), " | "), " |")
    end
end


import Base.show
function show(io::IO, t::YTable)
    show_table(io, t.data, t.style)
end

end # module
