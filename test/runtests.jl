using Base.Test
using DataFrames
using YTables

# Custom formatters:
@test ismatch(r"0.00 ", string(latex(DataFrame(a=[0.00101]))))
@test ismatch(r"0.0010 ", string(latex(DataFrame(a=[0.00101]),format=Dict(:a => v-> @sprintf("%.4f", v)))))

# No embed in table
@test ismatch(r"{table}", string(latex(DataFrame(a=[42]))))
@test !ismatch(r"{table}", string(latex(DataFrame(a=[42]), embed_in_table=false)))

# Handling of NA values in tables
# This would fail before commit 7da7b2e
@test ismatch(r"0.00 ", string(latex(DataFrame(a=@data [0.00111111,NA]))))
@test ismatch(r"0.00 ", string(latex(DataFrame(a=@data [NA,0.00111111]))))
