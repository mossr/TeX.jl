using TeX
using PGFPlots
using LinearAlgebra

doc = globaldoc("ml"; tufte=true)
doc.title = "Loss Functions in Machine Learning"
doc.author = "Robert Moss"
doc.address = "Stanford University, Stanford, CA 94305"
doc.email = "mossr@cs.stanford.edu"
doc.date = T"\today"
doc.auto_sections = false # do not create new \sections for @tex'd functions
doc.build_dir = "output_ml"

@tex begin
    𝕀(b) = b ? 1 : 0 # indicator function
    margin(x, y, 𝐰, φ) = (𝐰⋅φ(x))*y
end

@tex T"""\section{Zero-One Loss}
The \textit{zero-one loss} corresponds exactly to the notion of whether our
predictor made a mistake or not. We can also write the loss in terms of the margin.
Plotting the loss as a function of the margin, it is clear that the loss is $1$
when the margin is negative and $0$ when it is positive.
\[
    \ZeroOneLoss(x, y, \w) =
        \mathbb{1}[\underbrace{(\vec{w} \cdot \phi(x)) y}_{\rm margin} \le 0]
\]
""" ->
Loss_01(x, y, 𝐰, φ) = 𝕀(margin(x, y, 𝐰, φ) ≤ 0)

plot_01 = Plots.Linear(x->Loss_01(x, 1, [1], x->x), (-3,3), xbins=1000,
                       style="solid, ultra thick, mark=none, red",
                       legendentry=L"\ZeroOneLoss")
ax = Axis([plot_01],
          ymin=0, ymax=4,
          xlabel=L"{\rm margin}~(\mathbf{w}\cdot\phi(x))y",
          ylabel=L"\Loss(x,y,\mathbf{w})",
          style="ymajorgrids, enlarge x limits=0, ylabel near ticks",
          legendPos="north west",
          legendStyle="{at={(0.5,-0.5)},anchor=north}",
          width="5cm", height="4cm")

addplot!(ax; figure=true, figtype="marginfigure", figure_pos="-6cm",
         caption="\\textit{Zero-one loss}.", caption_pos=:above)


@tex T"""\section{Hinge Loss (SVMs)}
Hinge loss upper bounds $\ZeroOneLoss$ and has a non-trivial gradient.
The intuition is we try to increase the margin if it is less than $1$.
Minimizing upper bounds are a general idea; the hope is that pushing
down the upper bound leads to pushing down the actual function.
\[
    \HingeLoss(x, y, \w) = \max\{1 - (\w \cdot \phi(x)) y, 0 \}
\]
""" ->
Loss_hinge(x, y, 𝐰, φ) = max(1 - margin(x, y, 𝐰, φ), 0)

plot_hinge = Plots.Linear(x->Loss_hinge(x, +1, [1], x->x), (-3,3),
                          style="solid, ultra thick, mark=none, darkgreen",
                          legendentry=L"\HingeLoss")
ax.plots = [plot_01, plot_hinge]

addplot!(ax; figure=true, figtype="marginfigure", figure_pos="-6cm",
         caption="\\textit{Hinge loss}.", caption_pos=:above)


@tex T"""\section{Logistic Loss}
Another popular loss function is the \textit{logistic loss}.
The intuition is we try to increase the margin even when it already exceeds $1$.
The main property of the logistic loss is no matter how correct your prediction is,
you will have non-zero loss. Thus, there is still an incentive (although diminishing)
to increase the margin. This means that you'll update on every single example.
\[
    \LogisticLoss(x, y, \w) = \log(1 + e^{-(\w \cdot \phi(x)) y})
\]
""" ->
Loss_logistic(x, y, 𝐰, φ) = log(1 + exp(-margin(x, y, 𝐰, φ)))

plot_logistic = Plots.Linear(x->Loss_logistic(x, +1, [1], x->x), (-3,3),
                             style="solid, ultra thick, mark=none, sun",
                             legendentry=L"\LogisticLoss")
ax.plots = [plot_01, plot_hinge, plot_logistic]

addplot!(ax; figure=true, figtype="marginfigure", figure_pos="-6cm",
         caption="\\textit{Logistic loss}.", caption_pos=:above)

# note, content from CS221 at Stanford
texgenerate()