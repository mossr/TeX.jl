using TeX

doc = globaldoc() # we are using the global document internal to TeX
doc.jobname = "multiline"
doc.title = "Multiline Debugging"
doc.build_dir = "output_$(doc.jobname)"
addpackage!("url")

sigmoid(t) = 1 / (1 + exp(-t)) # not part of Tex.

# @tex T"This works." ->
# begin
#     using UnicodePlots
#     display(lineplot(sigmoid.(-5:0.1:5), title="Sigmoid", xlabel="t", ylabel="sigmoid(t)"))
# end

@tex T"This \textit{was} broken." ->
begin
    using UnicodePlots
    display(lineplot(sigmoid.(-5:0.1:5),
                     title="Sigmoid",
                     xlabel="t",
                     ylabel="sigmoid(t)"))
end


@tex T"How about this?" ->
g(x,
  y,
  c=10) =
    2x^2 +
    5y^3 +
    c


texgenerate()