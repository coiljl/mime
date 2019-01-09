@require "github.com/jkroso/parse-json.jl" parse

const db = open(parse, "$(@dirname)/deps/mime-db.json")

const types = Dict{String,String}()

for (mime, info) in db
  exts = get(info, "extensions", Dict())
  isempty(exts) && continue
  for ext in exts
    types[ext] = mime
  end
end

"""
Get the mime type of a file `path`
"""
lookup(path::AbstractString) = get(types, ext(path), nothing)

"""
Get the extension of `path`
"""
ext(path::AbstractString) = splitext(path)[2][2:end]

"""
Get the expected string encoding for a mime type
"""
charset(::Nothing) = nothing
charset(mime::AbstractString) = begin
  info = get(db, mime, db)
  haskey(info, "charset") && return info["charset"]
  # default text/* to utf-8
  occursin(r"^text/.", mime) ? "UTF-8" : nothing
end

"""
Generate the HTTP Content-Type header for `mime`
"""
content_type(mime::AbstractString) = begin
  if !haskey(db, mime) mime = lookup(mime) end
  encoding = charset(mime)
  encoding === nothing && return mime
  "$mime; charset=$(lowercase(encoding))"
end

"""
Checks if a type is compressible.
"""
compressible(mime::AbstractString) = begin
  # strip charset
  mime = split(mime, ';')[1]
  # attempt to look up from database
  info = get(db, mime, nothing)
  info !== nothing && return get(info, "compressible", false)
  # fallback to regex if not found
  occursin(r"^text/|\+json$|\+text$|\+xml$", mime)
end
