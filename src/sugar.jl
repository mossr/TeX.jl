# Pulled and modified from deprecated Sugar.jl
function get_source_at(file::String, linestart::Integer)
    code, str = open(file) do io
        line = ""
        for i=1:linestart-1
            line = readline(io)
        end
        try # lines can be one off, which will result in a parse error
            parse(line)
        catch e
            line = readline(io)
        end
        while !eof(io)
            line = line * "\n" * readline(io)
            e = Base.parse_input_line(line; filename=file)
            if !(isa(e,Expr) && e.head === :incomplete)
                return e, line
            end
        end
    end
    code, str
end

get_source(file::Symbol, linestart::Integer) = get_source(string(file), linestart)
function get_source(file::String, linestart::Integer)
    code, str = get_source_at(file, linestart)
    # for consistency, we always return the `function f(args...) end` form
    long = MacroTools.longdef(code)
    # and return only the source body
    return str
end