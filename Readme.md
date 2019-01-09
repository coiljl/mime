# mime

General mime type utilities:

- filename => mime-type
- mime-type => charset
- filename/mime-type => HTTP Content-Type header
- mime-type => is compressible

```julia
@require "github.com/coiljl/mime" lookup charset content_type compressible
```

## API

### lookup(path::AbstractString)
Get the mime type for a given file's name

```julia
lookup("some.json") # "application/json"
```

### charset(mime::AbstractString)

Get the default encoding for a given mime type

```julia
charset("application/json") # "UTF-8"
```

### content_type(mime::AbstractString)

Generate the HTTP Content-Type header for mime

```julia
content_type("application/json") # "application/json; charset=utf-8"
```

It can also handle file names

```julia
content_type("some.json") # "application/json; charset=utf-8"
```

### compressible(mime::AbstractString)

Lookup if mime is known to be compressible or not

```julia
compressible("application/json") # true
```
