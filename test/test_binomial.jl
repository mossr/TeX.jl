using TeX

doc = TeXDocument("random_variables"; tufte=true, title="Random Variables")

@tex doc T"\section{Bernoulli Random Variable}"

@tex doc T"""
\marginnote{A \textit{Bernoulli random variable} maps ``success'' to $1$ and ``failure'' to $0$.}
\marginnote{Support for \textit{Bernoulli}: $\{0,1\}$}
"""

@tex doc T"""
A \textit{Bernoulli random variable} is the simplest kind of random variable.
It can take on two values, $1$ and $0$. It takes on a $1$ if an experiment with
probability $p$ resulted in success and a $0$ otherwise.%
\sidenote{The Bernoulli random variable is the simplest random variable
          (i.e. an \textit{indicator} or \textit{boolean} random variable)}
Some example uses include a coin flip, a random binary digit, and whether a disk drive
crashed. If $X$ is a Bernoulli random
variable, denoted%
\sidenote{Sampling $x$ from a distribution $D$ can also be written $x \sim D$,
          where $\sim$ is read as ``is distributed as''.} $X \sim \Ber(p)$:
"""

@tex doc T"""
\begin{align}
    \textit{Probability mass function:} \quad &P(X = 1) = p\\
                                             &P(X = 0) = (1 - p)\\
    \textit{Expectation:} \quad &\mathbb{E}[X] = p\\
    \textit{Variance:} \quad &\Var(X) = p(1 - p)
\end{align}

Bernoulli random variables and \textit{indicator variables} are two aspects of the same concept.
A random variable $I$ is an indicator variable for an event $A$ if $I = 1$ when $A$ occurs and
$I = 0$ if $A$ does not occur. ${P(I{=}1){=}P(A)}$ and ${\mathbb{E}[I]{=}P(A)}$. Indicator random
variables are Bernoulli random variables, with ${p{=}P(A)}$.
"""


@tex doc T"\section{Binomial Random Variable}"

@tex doc T"""
\marginnote{A \textit{binomial random variable} is the number of successes in $n$ trials.
            Note that $\Ber(p) = \Bin(1,p)$.}
\marginnote[2mm]{Support for \textit{binomial}: $\{0,1,\ldots,n\}$}

A \textit{binomial random variable} is random variable that represents the number of
successes in $n$ successive independent trials of a Bernoulli experiment. Some example
uses include the number of heads in $n$ coin flips, the number of disk drives that
crashed in a cluster of $1000$ computers, and the number of advertisements that are
clicked when $40{,}000$ are served.

If $X$ is a Binomial random variable, we denote this $X \sim \Bin(n, p)$, where $p$ is
the probability of success in a given trial. A binomial random variable has the following
properties:\sidenote{A binomial random variable is the sum of Bernoulli random variables.}
\begin{align}
    \textit{Probability mass function:} \quad &\begin{cases}
        P(X = k) = \dbinom{n}{k} p^k (1 - p)^{n-k} & \text{if } k \in \mathbb{N},\, 0 \le k \le n\\
        0 & \text{otherwise}
    \end{cases}\\
    \textit{Expectation:} \quad &\mathbb{E}[X] = np\\
    \textit{Variance:} \quad &\Var(X) = np(1 - p)
\end{align}


\begin{marginfigure}
    \begin{center}
        \begin{tikzpicture}
            \pgfplotsset{
                /pgfplots/layers/Bowpark/.define layer set={
                    axis background,axis grid,main,axis ticks,axis lines,axis tick labels,
                    axis descriptions,axis foreground
                }{/pgfplots/layers/standard},
            }
            \begin{axis}[ybar, ymajorgrids, width=5.1cm, height=4cm, xlabel={$x$},
                         ylabel={$P(X=x)$}, yticklabel pos=right, ylabel style={rotate=-90},
                         xtick={0,1,2,3}, ytick={0,1/8,2/8,3/8}, yticklabels={$0$, $1/8$,$2/8$,$3/8$},
                         every axis y label/.style={at={(ticklabel* cs:1.05)}, anchor=south},
                         set layers=Bowpark, ymin=0, xmin=-1, xmax=4]
                \addplot+[pastelBlue, ybar, bar width=5mm, solid, draw, mark=none] coordinates {(0,1/8) (1,3/8) (2,3/8) (3,1/8)};
            \end{axis}
        \end{tikzpicture}
    \end{center}

    \caption{
        \textit{Probability mass function} of a \textit{binomial random variable};
        number of heads after three coin flips.
    }
\end{marginfigure}
"""

texgenerate(doc; output="output_binomial")