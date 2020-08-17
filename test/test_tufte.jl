using TeX

doc = TeXDocument("tufte"; tufte=true)
doc.author = "Robert Moss"
doc.email = "mossr@cs.stanford.edu"
doc.address = "Stanford University, Stanford, CA 94305"
addpackage!(doc, "url")
addtitle!(doc, L"Tufte Example")

@tex doc L"In mathematical optimization, statistics, decision theory and machine learning,
a \textit{loss function} or \textit{cost function} is a function that maps an event or
values of one or more variables onto a real number intuitively representing some ``cost''
associated with the event.\footnote{\url{https://en.wikipedia.org/wiki/Loss_function}}
An optimization problem seeks to minimize a loss function. An objective function is
either a loss function or its negative (sometimes called a \textit{reward function}
or a \textit{utility function}), in which case it is to be maximized.

\begin{equation}
J(\theta) = \frac{1}{m}\sum_{i=1}^{m}\left[ -y^{(i)} \log(h_{\theta}(x^{(i)})) -
                (1 - y^{(i)}) \log(1 - h_{\theta}(x^{(i)}))\right]
\end{equation}" ->
function loss_function(theta, X, y)
    m = length(y) # number of training examples
    grad = zeros(size(theta))
    h = sigmoid(X * theta)
    J = 1/m * sum((-y'*log(h))-(1 .- y)'*log(1 .- h))
    grad = 1/m*(X'*(h-y))
    return (J, grad)
end

texgenerate(doc; output="output_tufte") # Compile the document to PDF