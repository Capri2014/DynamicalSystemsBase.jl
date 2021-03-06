__precompile__()

"""
Definitions of core system and data types used
in in the ecosystem of DynamicalSystems.jl
"""
module DynamicalSystemsBase

include("dataset.jl")
include("reconstruction.jl")
include("various.jl")

include("dynamicalsystem/dynamicalsystem.jl")
include("dynamicalsystem/discrete.jl")
include("dynamicalsystem/continuous.jl")
include("dynamicalsystem/famous_systems.jl")

include("deprecations.jl")

export Systems

end
