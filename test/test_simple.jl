using TeX

doc = TeXDocument("default") # PDF file name
doc.title = T"Simple \TeX.jl Example: \texttt{@tex}" # Use T"..." to escape TeX strings (raw"..." works too)
doc.author = "Robert Moss"
doc.address = "Stanford University, Stanford, CA 94305"
doc.email = "mossr@cs.stanford.edu"
doc.date = T"\today"
doc.build_dir = "output_simple"
addpackage!(doc, "url")

@tex doc T"In mathematical optimization, statistics, decision theory and machine learning,
a \textit{loss function} or \textit{cost function} is a function that maps an event or
values of one or more variables onto a real number intuitively representing some ``cost''
associated with the event.\footnote{\url{https://en.wikipedia.org/wiki/Loss_function}}
An optimization problem seeks to minimize a loss function. An objective function is
either a loss function or its negative (sometimes called a \textit{reward function}
or a \textit{utility function}), in which case it is to be maximized.

\begin{equation}
    J(\theta) = \frac{1}{m}\sum_{i=1}^{m}\biggl[ -y_i \log(h_{\theta}(x_i)) -
                    (1 - y_i) \log(1 - h_{\theta}(x_i)) \biggr]
\end{equation}" ->
function loss_function(theta, X, y)
    m = length(y) # number of training examples
    grad = zeros(size(theta))
    h = sigmoid(X * theta)
    J = 1/m*sum(-y'*log(h)-(1 .- y)'*log(1 .- h))
    grad = 1/m*(X'*(h-y))
    return (J, grad)
end


texgenerate(doc) # Compile the document to PDF