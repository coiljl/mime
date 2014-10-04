@require "parse-json" parse

const db = open(parse, "$(dirname(string(current_module())))/dependencies/mime-db/db.json")

# types[extension] = type
const types = Dict{String,String}()

for (mime, info) in db
  exts = get(info, "extensions", {})
  isempty(exts) && continue
  for ext in exts
    types[ext] = mime
  end
end

##
# Get the mime type of a file `path`
#
lookup(path::String) = get(types, ext(path), nothing)

##
# Get the extension of `path`
#
ext(path::String) = splitext(path)[2][2:end]

##
# Get the expected string encoding for a mime type
#
charset(::Nothing) = nothing
function charset(mime::String)
  info = get(db, mime, db)
  haskey(info, "charset") && return info["charset"]
  # default text/* to utf-8
  ismatch(r"^text/.", mime) ? "UTF-8" : nothing
end

##
# Generate the HTTP Content-Type header for `mime`
#
function content_type(mime::String)
  if !haskey(db, mime) mime = lookup(mime) end
  encoding = charset(mime)
  encoding === nothing && return mime
  "$mime; charset=$(lowercase(encoding))"
end

##
# Checks if a type is compressible.
#
function compressible(mime::String)
  # strip charset
  mime = split(mime, ';')[1]
  # attempt to look up from database
  info = get(db, mime, nothing)
  info !== nothing && return get(info, "compressible", false)
  # fallback to regex if not found
  ismatch(r"^text/|\+json$|\+text$|\+xml$", mime)
end
