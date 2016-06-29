

if (sim_call_type==sim_childscriptcall_initialization) then 
    -- Make sure we have version 2.4.13 or above (the particles are not supported otherwise)
    v=simGetInt32Parameter(sim_intparam_program_version)
    if (v<20413) then
        simDisplayDialog('Warning','The propeller model is only fully supported from V-REP version 2.4.13 and above.&&nThis simulation will not run as expected!',sim_dlgstyle_ok,false,'',nil,{0.8,0,0,0,0,0})
    end
    init = true
    moduleName=0
    index=0
    rosInterfacePresent=false
    while moduleName do
        moduleName=simGetModuleName(index)
        if (moduleName=='RosInterface') then
            rosInterfacePresent=true
        end
        index=index+1
    end

    -- Prepare the float32 publisher and subscriber (we subscribe to the topic we advertise):
    if rosInterfacePresent then
        client=simExtRosInterface_serviceClient('/quadcontrol', 'PID_control/controlserver')
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

    particlesTargetVelocities={5,5,5,5}

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

    -- Following not really needed in a simulation script (i.e. automatically shut down at simulation end):
    if rosInterfacePresent then
        simExtRosInterface_shutdownServiceClient(client)
    end
end 

function getVector3(vec)
    return {x=vec[1],y=vec[2],z=vec[3]}
end

function getTransform(objHandle,relTo)
    -- This function retrieves the stamped transform for a specific object
    p=simGetObjectPosition(objHandle,relTo)
    o=simGetObjectQuaternion(objHandle,relTo)
    return {
        translation={x=p[1],y=p[2],z=p[3]},
        rotation={x=o[1],y=o[2],z=o[3],w=o[4]}
    }
end

if (sim_call_type==sim_childscriptcall_actuation) then 
    s=simGetObjectSizeFactor(d)
    pos=simGetObjectPosition(d,-1)

    -- Send an updated simulation time message, and send the transform of the object attached to this script:
    
    request = {transform = getTransform(d,-1),
    target_error = getVector3(simGetObjectPosition(targetObj,d)),
    velocity=getVector3(simGetVelocity(heli)),reset=init}
    if (init) then
        init = false
    end
    if rosInterfacePresent then
        --simExtRosInterface_publish(publisher,{data=simGetSimulationTime()})
        --simExtRosInterface_sendTransform(getTransformStamped(objectHandle,objectName,-1,'world'))
        -- To send several transforms at once, use simExtRosInterface_sendTransforms instead
        response=simExtRosInterface_call(client,request)
    end
    

    
    --newprint("hi")
    --newprint(response.a)
    if (response) then
        -- Decide of the motor velocities:
        particlesTargetVelocities[1]=response.a
        particlesTargetVelocities[2]=response.b
        particlesTargetVelocities[3]=response.c
        particlesTargetVelocities[4]=response.d
    end

    for i=1,4,1 do
        simSetScriptSimulationParameter(propellerScripts[i],'particleVelocity',particlesTargetVelocities[i])
    end
end



