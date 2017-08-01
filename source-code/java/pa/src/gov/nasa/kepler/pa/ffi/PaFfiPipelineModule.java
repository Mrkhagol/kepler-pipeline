/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.pa.ffi;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pa.ApertureModelParameters;
import gov.nasa.kepler.pa.ArgabrighteningModuleParameters;
import gov.nasa.kepler.pa.EncircledEnergyModuleParameters;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.kepler.pa.OapAncillaryEngineeringParameters;
import gov.nasa.kepler.pa.PaCoaModuleParameters;
import gov.nasa.kepler.pa.PaCosmicRayParameters;
import gov.nasa.kepler.pa.PaHarmonicsIdentificationParameters;
import gov.nasa.kepler.pa.PaInputs;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pa.PaOutputs;
import gov.nasa.kepler.pa.PaPipelineModule.ProcessingState;
import gov.nasa.kepler.pa.ReactionWheelAncillaryEngineeringParameters;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsGroup;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Photometric Analysis (PA) FFI pipeline module.
 * 
 * @author Forrest Girouard
 * 
 */
public class PaFfiPipelineModule extends MatlabPipelineModule implements
    AsyncPipelineModule {

    private static final Log log = LogFactory.getLog(PaFfiPipelineModule.class);

    public static final String MODULE_NAME = "paffi";

    public PaFfiPipelineModule() {
        super();
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = newArrayList();
        requiredParameters.add(AncillaryPipelineParameters.class);
        requiredParameters.add(AncillaryDesignMatrixParameters.class);
        requiredParameters.add(ApertureModelParameters.class);
        requiredParameters.add(ArgabrighteningModuleParameters.class);
        requiredParameters.add(BackgroundModuleParameters.class);
        requiredParameters.add(CalFfiModuleParameters.class);
        requiredParameters.add(CustomTargetParameters.class);
        requiredParameters.add(EncircledEnergyModuleParameters.class);
        requiredParameters.add(GapFillModuleParameters.class);
        requiredParameters.add(MotionModuleParameters.class);
        requiredParameters.add(OapAncillaryEngineeringParameters.class);
        requiredParameters.add(PaCoaModuleParameters.class);
        requiredParameters.add(PaCosmicRayParameters.class);
        requiredParameters.add(PaFfiModuleParameters.class);
        requiredParameters.add(PaHarmonicsIdentificationParameters.class);
        requiredParameters.add(PaModuleParameters.class);
        requiredParameters.add(PouModuleParameters.class);
        requiredParameters.add(ReactionWheelAncillaryEngineeringParameters.class);
        requiredParameters.add(SaturationSegmentModuleParameters.class);
        requiredParameters.add(ThrusterDataAncillaryEngineeringParameters.class);
        return requiredParameters;
    }

    @Override
    public Class<?> outputsClass() {
        return PaOutputs.class;
    }

    @Override
    public void generateInputs(InputsHandler subTaskSequence,
        PipelineTask pipelineTask, File taskWorkingDirectory)
        throws RuntimeException {

        setPipelineTask(pipelineTask);

        ModOutUowTask task = pipelineTask.uowTaskInstance();
        for (int channelNumber : task.getChannels()) {
            Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(channelNumber);
            PaFfiInputsRetriever paFfiInputsRetriever = new PaFfiInputsRetriever(
                pipelineTask, modOut.left, modOut.right);
            List<ProcessingState> processingStates = new ArrayList<ProcessingState>();
            InputsGroup subTaskGroup = subTaskSequence.createGroup();

            while (paFfiInputsRetriever.hasNext()) {
                File subTaskWorkingDirectory = subTaskGroup.subTaskDirectory();
                PaInputs inputs = paFfiInputsRetriever.retrieveInputs(subTaskWorkingDirectory);

                processingStates.add(ProcessingState.valueOf(inputs.getProcessingState()));
                subTaskGroup.addSubTaskInputs(inputs);
            }

            paFfiInputsRetriever.serializeProducerTaskIds(taskWorkingDirectory);

            generateSequence(subTaskGroup, processingStates);
        }
    }

    @Override
    public void processOutputs(PipelineTask pipelineTask,
        Iterator<AlgorithmResults> outputs) throws RuntimeException {

        if (outputs.hasNext()) {
            while (outputs.hasNext()) {
                AlgorithmResults algorithmResults = outputs.next();

                if (!algorithmResults.successful()) {
                    log.warn("Skipping failed sub-task due to MATLAB error for sub-task "
                        + algorithmResults.getResultsDir());
                    continue;
                }

                File subTaskWorkingDirectory = algorithmResults.getResultsDir();
                PaOutputs paOutputs = (PaOutputs) algorithmResults.getOutputs();

                PaFfiOutputsStorer paFfiOutputsStorer = new PaFfiOutputsStorer(
                    pipelineTask, paOutputs.getCcdModule(),
                    paOutputs.getCcdOutput());
                paFfiOutputsStorer.storeOutputs(subTaskWorkingDirectory,
                    paOutputs);
            }

            storeProducerTaskIds(pipelineTask, getCurrentWorkingDir());
        }
    }

    private void storeProducerTaskIds(PipelineTask pipelineTask, File workingDir) {
        Set<Long> producerTaskIds = new ProducerTaskIdsStream().read(workingDir);
        log.info("[" + getModuleName() + "]Count of producerTaskIds: "
            + producerTaskIds.size());
        if (producerTaskIds.size() > 0) {
            log.info("[" + getModuleName()
                + "]Creating data accountability trail");
            new DataAccountabilityTrailCrud().create(pipelineTask,
                producerTaskIds);
        }
    }

    private static void generateSequence(InputsGroup inputsGroup,
        List<ProcessingState> states) {

        ProcessingState lastState = states.get(0);
        int index = 0;
        int lastIndex = 0;
        for (ProcessingState state : states) {
            if (state != lastState) {
                inputsGroup.add(lastIndex, index - 1);
                lastState = state;
                lastIndex = index;
            }
            index++;
        }
        inputsGroup.add(lastIndex, index - 1);
    }
}
