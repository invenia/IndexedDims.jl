using Documenter, IndexedDims

makedocs(;
    modules=[IndexedDims],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/IndexedDims.jl/blob/{commit}{path}#L{line}",
    sitename="IndexedDims.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)

deploydocs(;
    repo="github.com/invenia/IndexedDims.jl",
)
