"""
@tex "\\LaTeX{} code goes here" ->
function algorithm(args)
	# Julia code here
end

A macro to write LaTeX formatted code in-line with your Julia algorithms.
The tex document will be named after the function (example "algorithm.tex")
"""
module TeX

export @tex,
       @tex_str,
       @L_str,
       TeXDocument,
       TeXSection,
       texgenerate,
       texclear,
       globaldoc,
       add!,
       addpackage!,
       addtitle!

include("TeXTypes.jl")

global USE_GLOBAL_DOC = false
"""
Compile all descriptions and code in the same document.
"""
globaldoc() = global USE_GLOBAL_DOC = true

global WORKINGDOC
function texclear()
	global WORKINGDOC = TeXDocument()
	return nothing # Suppress REPL
end

texclear()


function textranslate(tex::TeXDocument)
	str = string("\\documentclass[", tex.documentfontsizept, "pt]{", tex.documentclass, "}\n")
	for p in tex.packages
		op = ""
		if p.option != ""
			op = string("[", p.option, "]")
		end
		str = string(str, "\\usepackage", op, "{", p.name, "}\n")
	end

	if length(tex.preamble) > 0
		str = string(str, tex.preamble, "\n")
	end

	for c in tex.commands
		str = string(str, "\\", c.name, "{", c.value, "}\n")
	end

	if !isempty(tex.title)
		str = string(str, "\n\\title{\\vspace{-2.0cm}$(tex.title)}\n")
		str = string(str, "\\date{}\n")
	end

	str = string(str, "\n\\begin{document}\n")
	if !isempty(tex.title)
		str = string(str, "\\maketitle\n")
	end
	for i in tex.inputs
		str = string(str, "\\input{", i.name, "}\n")
	end
	str = string(str, "\\end{document}")
	return str
end

function texwrite(tex::TeXDocument)
	# writes each input file
	for i in tex.inputs
		input = open(abspath(joinpath(tex.build_dir, i.name * ".tex")), "w")
		if i.needs_section_name
			write(input, string("\\section{", texformat(i.name), "}\n"))
		end
		write(input, i.body)
		close(input)
	end

	# writes the main document
	main = open(tex.jobname * ".tex", "w")
	write(main, textranslate(tex))
	close(main)
end

function texcompile(tex::TeXDocument)
	filename = tex.jobname * ".tex"
	cmd = ["pdflatex", "-quiet", abspath(filename)]
	if tex.build_dir != ""
		push!(cmd, string("-aux-directory=", abspath(tex.build_dir)))
		push!(cmd, string("-output-directory=", abspath(tex.build_dir)))
		include_dir = joinpath(dirname(pathof(TeX)), "include")
		include_dirs = [dirname(abspath(filename)), include_dir]
		map(d->push!(cmd,"-include-directory=$d"), include_dirs)
	end
	@info "Running: $(`$cmd`)"
	run(`$cmd`)
end

function texopen(tex::TeXDocument)
	pdf = tex.jobname * ".pdf"
	try
		run(`explorer $pdf`)
	catch e
	end
end

const TeXSections = Array{TeXSection}

function texgenerate(document::TeXDocument; output="output")
	isdir(output) ? nothing : mkdir(output)
	cd(output) do
		# writes the LaTeX string and function code to a .tex file
		texwrite(document)

		# compiles the latex document
		texcompile(document)

		# open compiled pdf
		if document.open
			texopen(document)
		end
	end
end


function texgenerate(;kwargs...)
	if USE_GLOBAL_DOC
		document = WORKINGDOC
	else
		error("texgenerate requires either a TeXDocument input or usage of globaldoc()")
	end
	return texgenerate(document; kwargs...)
end

# Specify main TeX filename
function texgenerate(jobname::String; kwargs...)
	if USE_GLOBAL_DOC
		document = WORKINGDOC
	else
		error("texgenerate requires either a TeXDocument input or usage of globaldoc()")
	end
	document.jobname = jobname
	texgenerate(document; kwargs...)
end



function texformat(str::String; replace_with_spaces::Bool=true, use_title_case::Bool=true)
	if replace_with_spaces
		str = replace(str, "_" => " ")
		if use_title_case
			str = titlecase(str)
		end
	else
		str = replace(str, "_" => "\\_")
	end
	return str
end

function lstlisting(code::String)
	str = "\n\\begin{lstlisting}\n"
	str *= code
	str *= "\n\\end{lstlisting}\n"
end

function parse_latex(idx, args...)
	local accompanying_func::Bool

	if isa(args[idx].args[1], Symbol)
		expr = args[idx]
		accompanying_func = false
	else
		expr = args[idx].args[1]
		accompanying_func = true
	end
	latex = expr.args[3] # [@L_str, "#= comment node =#", "Auto-escaped LaTeX string"]

	return (latex, accompanying_func)
end


function add!(document::TeXDocument, latex_str::String, name_str::String = "", func_str::String = "")
	input = TeXSection(name_str)
	input.body = string(latex_str, lstlisting(func_str))
	push!(document.inputs, input)
end

function add!(document::TeXDocument, input::TeXSection)
	push!(document.inputs, input)
end

function _tex(tmodule, args...)
	global USE_GLOBAL_DOC

	if !isa(args[1], Symbol) # i.e. doc wasn't passed in, USE_GLOBAL_DOC
		global WORKINGDOC
		# uses existing working document (global)
		doc_idx = 0
		document = WORKINGDOC
		parse_idx = 1
	else
		# use TeXDocument passed in as input: @tex doc L"..."
		doc_idx = 1
		document = @eval(tmodule, $(args[doc_idx]))
		parse_idx = 2
	end

	desc_idx = doc_idx+1
	# grabs the latex string
	(latex, accompanying_func::Bool) = parse_latex(parse_idx, args...)

	if accompanying_func
		expr = args[desc_idx].args

		func = expr[2].args[2]

		is_func_block::Bool = isa(func, Expr)
		if is_func_block
			# grabs the function name
			name_sym = func.args[1].args[1]
			name_str = string(name_sym)
		else
			name_str = ""

			# grab code block that's not necessarily a function
			func = expr[2]
		end

		# eval the code block into the scope of the calling module
		@eval(tmodule, $func)

		firstline::LineNumberNode = args[desc_idx].args[2].args[1]
		file::Symbol = firstline.file
		startline::Int = firstline.line + 1
		local lastline::LineNumberNode
		if is_func_block
			codelines = args[desc_idx].args[end].args[end].args[2].args
		else
			codelines = args[desc_idx].args[end].args
		end

		lastline = codelines[findlast(a->isa(a,LineNumberNode), codelines)]
		endline::Int = lastline.line + 1

		filelines = readlines(string(file), keep=true)
		func_str = join(filelines[startline:endline])

		add!(document, latex, name_str, func_str)
	else
		add!(document, latex)
	end
end

# L"" formatted LaTeX string with accompanying function
# @tex L"\LaTeX un-escaped formatted string" -> function name(...) ... end
macro tex(args...)
	_tex(__module__, args...)
end

# L"\blah \blah \blah un-escaped"
macro L_str(latex_str)
	########################################
	# No op. Used for escaping string before
	# passing to the @tex macro
	########################################
	return latex_str
end

end # module TeX