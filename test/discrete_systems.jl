println("\nTesting discrete system evolution...")
if current_module() != DynamicalSystemsBase
  using DynamicalSystemsBase
end
using Base.Test, StaticArrays

@testset "Logistic Map" begin

  d1 = Systems.logistic(0.1)
  d2 = DiscreteDS1D(0.1, d1.eom)
  d3 = DiscreteDS1D(big(0.1), d1.eom, d1.deriv)

  @testset "Evolution & trajectory" begin
    st1 = evolve(d1)
    st2 = evolve(d2)
    st3 = evolve(d3)
    @test st1 == st2
    @test st1 ≈ st3
    @test typeof(st3) == BigFloat
    ts1 = trajectory(d1, 100)
    ts3 = trajectory(d3, 100)
    @test ts1[10] ≈ ts3[10]
    @test eltype(ts3) == BigFloat
  end
  @testset "Derivatives" begin
    f1 = d1.deriv(d1.state)
    f2 = d2.deriv(d2.state)
    f3 = d3.deriv(d3.state)
    @test isapprox(f1, f2;rtol = 1e-12)
    @test isapprox(f1, f3;rtol = 1e-12)
    @test typeof(f3) == BigFloat
  end
end

@testset "Folded-Towel Map" begin

  s1 = Systems.towel(0.1ones(3))
  s2 = DiscreteDS(0.1ones(3), s1.eom)
  s4 = DiscreteDS(round.(big.(0.1ones(3)),3), s1.eom, s1.jacob)

  @testset "Evolution & trajectory" begin
    st1 = evolve(s1)
    st2 = evolve(s2)
    st4 = evolve(s4)

    @test isapprox.(st1, st2; rtol = 1e-12) == trues(s1.state)
    @test isapprox.(st1, st4; rtol = 1e-12) == trues(s1.state)

    ts = trajectory(s1, 100)
    @test size(ts) == (100, 3)
    ts4 = trajectory(s4, 100)
    @test size(ts4) == (100, 3)
    @test eltype(ts4) == BigFloat
    @test isapprox.(ts[10, :],ts4[10, :]) == trues(3)
  end
  @testset "Jacobians" begin

    J1 = s1.jacob(s1.state)
    @test typeof(J1) <: SMatrix
    J2 = s2.jacob(s2.state)
    J4 = s4.jacob(s4.state)
    @test typeof(J4) <: SMatrix

    @test isapprox.(J1, J2; rtol = 1e-6) == trues(J1)
    @test isapprox.(J1, J4; rtol = 1e-6) == trues(J1)
    @test eltype(J4) == BigFloat
  end
end

@testset "Coupled standard maps" begin
    M = 5; ks = 0.5ones(M); Γ = 0.05;
    ds = Systems.coupledstandardmaps(M, 0.1rand(2M); ks=ks, Γ = Γ)

    u0 = copy(state(ds))
    st1 = evolve(ds, 100)

    @test st1 != u0
    @test u0 == state(ds)

    Jbef = copy(ds.J)
    ds.jacob!(ds.J, evolve(ds))
    @test Jbef != ds.J
    ds.jacob!(Jbef, evolve(ds))
    @test Jbef == ds.J
end
