# YTables

Markup and markdown formatting for Julia DataFrames

I am still very new to Julia, so interface is likely to change to be more idiomatic. Consequently, pull requests to make the interface more idiomatic would be appreciated!

## How to get it
YTables has not been registered yet; install with:

```julia
Pkg.clone("git@github.com:farrellm/YTables.jl.git")
```

## Examples
### From Julia
```julia
using YTables, RDatasets
form = dataset("datasets","Formaldehyde")
latex(form)
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

### From Babel
```julia
#+BEGIN_SRC julia :exports both :results raw
  using RDatasets, YTables
  form = dataset("datasets","Formaldehyde")
  org(form)
#+END_SRC

#+RESULTS:
| Carb | OptDen |
|------+--------|
|  0.1 |  0.086 |
|  0.3 |  0.269 |
|  0.5 |  0.446 |
|  0.6 |  0.538 |
|  0.7 |  0.626 |
|  0.9 |  0.782 |
```

```julia
#+BEGIN_SRC julia :exports both :results latex verbatim
  using RDatasets, YTables
  form = dataset("datasets","Formaldehyde")
  latex(form)
#+END_SRC

#+RESULTS:
#+BEGIN_LaTeX
% latex table generated in Julia 0.3.0-prerelease+2640 by YTables
% 2014-04-17T04:41:43 UTC
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
#+END_LaTeX
```

[![Build Status](https://travis-ci.org/farrellm/YTables.jl.png)](https://travis-ci.org/farrellm/YTables.jl)
