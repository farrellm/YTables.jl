# YTables

Markup and markdown formatting for Julia DataFrames

I am still very new to Julia, so interface is likely to change to be more idiomatic. Consequently, pull requests to make the interface more idiomatic would be appreciated!

## Examples

```julia
using YTables, RDatasets
form = dataset("datasets","Formaldehyde")
```

```julia
latex_table(form)
```

```latex
% latex table generated in Julia 0.3.0-prerelease+2566 by YTables
% 2014-04-09T05:29:53 UTC
\begin{table}[ht]
  \centering
  \begin{tabular}{rr}
    \hline
    Carb & OptDen \\
    \hline
    0.10 & 0.09 \\ 
    0.30 & 0.27 \\ 
    0.50 & 0.45 \\ 
    0.60 & 0.54 \\ 
    0.70 & 0.63 \\ 
    0.90 & 0.78 \\
    \hline
  \end{tabular}
\end{table}
```

```latex
org_table(form)
```

```
| Carb | OptDen |
|--+--|
| 0.1 | 0.086 |
| 0.3 | 0.269 |
| 0.5 | 0.446 |
| 0.6 | 0.538 |
| 0.7 | 0.626 |
| 0.9 | 0.782 |

```

## How to get it
YTables has not been registered yet; install with:

```julia
Pkg.clone("git@github.com:farrellm/YTables.jl.git")
```

[![Build Status](https://travis-ci.org/farrellm/YTables.jl.png)](https://travis-ci.org/farrellm/YTables.jl)
