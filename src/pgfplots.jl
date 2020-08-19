const PGFPlotType = Union{PGFPlots.Plot, PGFPlots.Axis, PGFPlots.GroupPlot}

function addpdfplots!(doc::TeXDocument)
    doc.preamble *= pgfplotspreamble()
end

function addplot!(p::PGFPlotType; kwargs...)
    global WORKINGDOC
    if !@isdefined(WORKINGDOC)
        error("Please call globaldoc() before using `addplot!` without a TeXDocument.")
    end
    return addplot!(WORKINGDOC, p; kwargs...)
end

function addplot!(doc::TeXDocument, p::PGFPlotType;
                  center::Bool=true,
                  figure::Bool=false,
                  figtype::String="figure",
                  figure_pos::String=figtype == "marginfigure" ? "" : "!hb",
                  caption::String="",
                  caption_pos::Symbol=:below) # :above or :below
    tikz = tikzCode(p)
    tikz = environment("tikzpicture", tikz)
    if figure
        if center
            tikz = string("\\centering", tikz)
        end
        if !isempty(caption)
            if caption_pos == :above
                tikz = string("\\caption{$caption}", tikz)
            else # implicit :below
                tikz = string(tikz, "\\caption{$caption}")
            end
        end
        tikz = environment(figtype, tikz; options=figure_pos)
    else
        if center
            tikz = environment("center", tikz)
        end
    end

    _tex(doc, nothing; latex=tikz)

    return tikz
end