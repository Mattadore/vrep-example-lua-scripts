

if (sim_call_type==sim_childscriptcall_initialization) then 

    -- Make sure we have version 2.4.13 or above (the particles are not supported otherwise)
    v=simGetInt32Parameter(sim_intparam_program_version)
    if (v<20413) then
        simDisplayDialog('Warning','The propeller model is only fully supported from V-REP version 2.4.13 and above.&&nThis simulation will not run as expected!',sim_dlgstyle_ok,false,'',nil,{0.8,0,0,0,0,0})
    end

    -- Detatch the manipulation sphere:
    targetObj=simGetObjectHandle('Quadricopter_target')
    simSetObjectParent(targetObj,-1,true)

    -- This control algo was quickly written and is dirty and not optimal. It just serves as a SIMPLE example

    d=simGetObjectHandle('Quadricopter_base')

    particlesAreVisible=simGetScriptSimulationParameter(sim_handle_self,'particlesAreVisible')
    simSetScriptSimulationParameter(sim_handle_tree,'particlesAreVisible',tostring(particlesAreVisible))
    simulateParticles=simGetScriptSimulationParameter(sim_handle_self,'simulateParticles')
    simSetScriptSimulationParameter(sim_handle_tree,'simulateParticles',tostring(simulateParticles))

    propellerScripts={-1,-1,-1,-1}
    for i=1,4,1 do
        propellerScripts[i]=simGetScriptHandle('Quadricopter_propeller_respondable'..i)
    end
    heli=simGetObjectAssociatedWithScript(sim_handle_self)

    particlesTargetVelocities={0,0,0,0}

    pParam=2
    iParam=0
    dParam=0
    vParam=-2

    cumul=0
    lastE=0
    pAlphaE=0
    pBetaE=0
    psp2=0
    psp1=0

    prevEuler=0

    -- Prepare 2 floating views with the camera views:

end 

if (sim_call_type==sim_childscriptcall_cleanup) then 

end 

if (sim_call_type==sim_childscriptcall_actuation) then 
    
    vels=simExtPidControl(d,targetObj)
    
    -- Decide of the motor velocities:
    particlesTargetVelocities[1]=vels[1]
    particlesTargetVelocities[2]=vels[2]
    particlesTargetVelocities[3]=vels[3]
    particlesTargetVelocities[4]=vels[4]
    
    
    -- Send the desired motor velocities to the 4 rotors:
    for i=1,4,1 do
        simSetScriptSimulationParameter(propellerScripts[i],'particleVelocity',particlesTargetVelocities[i])
    end
end  
