#  Copyright (c) 2017-23, Arnab Bhattacharya.

using SDDP, HiGHS, Test

# stages = 20, 30, 40, 50 ,60

function test_mpo_example()
    model = customSDDP.PolicyGraph(
        stages = 20,
        lower_bound = -5.0,
        optimizer = HiGHS.Optimizer,
        type = 'reg',
    ) do subproblem, stage
        @variable(
            subproblem,
            0 <= stock[i = 1:3] <= 1,
            SDDP.State,
            initial_value = 0.5
        )
        @variables(subproblem, begin
            0 <= control[i = 1:3] <= 0.5
            ξ[i = 1:3]  # Dummy for RHS noise.
        end)
        @constraints(
            subproblem,
            begin
                sum(control) - 0.5 * 3 <= 0
                [i = 1:3], stock[i].out == stock[i].in + control[i] - ξ[i]
            end
        )
        Ξ = collect(
            Base.product((0.0, 0.15, 0.3), (0.0, 0.15, 0.3), (0.0, 0.15, 0.3)),
        )[:]
        customSDDP.parameterize(subproblem, Ξ) do ω
            return JuMP.fix.(ξ, ω)
        end
        @stageobjective(subproblem, (sin(3 * stage) - 1) * sum(control))
    end
    customSDDP.train(
        model,
        iteration_limit = 100,
        cut_type = customSDDP.SINGLE_CUT,
        log_frequency = 10,
    )
    @test customSDDP.calculate_bound(model) ≈ -4.349 atol = 0.01

    simulation_results = customSDDP.simulate(model, 5000)
    @test length(simulation_results) == 5000
    μ = customSDDP.Statistics.mean(
        sum(data[:stage_objective] for data in simulation) for
        simulation in simulation_results
    )
    @test μ ≈ -4.349 atol = 0.1
    return
end

test_mpo_example()
