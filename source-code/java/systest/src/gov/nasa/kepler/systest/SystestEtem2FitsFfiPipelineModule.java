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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.Etem2FitsFfi;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class SystestEtem2FitsFfiPipelineModule extends PipelineModule {

    private static final String FFI_ORIG = "ffi-orig";
    public static final String MODULE_NAME = "etem2FitsFfi";

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(DataGenParameters.class);
        requiredParams.add(TadParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(DataRepoParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, packerParams, tadParameters);

            DataRepoParameters dataRepoParams = pipelineTask.getParameters(DataRepoParameters.class);

            PlannedSpacecraftConfigParameters plannedConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);

            Date startDate = MatlabDateFormatter.dateFormatter().parse(packerParams.getStartDate());
            String startTimestamp = DateUtils.formatLikeDmc(startDate);
            double startMjd = ModifiedJulianDate.dateToMjd(startDate);
            double daysPerLongCadence = (plannedConfigParams.getSecondsPerShortCadence() * plannedConfigParams.getShortCadencesPerLongCadence()) / 86400; 
            double endMjd = startMjd + daysPerLongCadence;
            
            String ffiFitsDir = dataGenDirManager.getFfiFitsDir();

            // Clean output dir.
            FileUtil.cleanDir(ffiFitsDir);

            String masterFfiDirPath = dataRepoParams.getFfiPath();
            File masterFfiDirFile = new File(masterFfiDirPath);
            File[] masterFitsFfiFiles = masterFfiDirFile.listFiles(new FilenameFilter(){
                @Override
                public boolean accept(File dir, String name) {
                    return name.endsWith(".fits");
                }
            });
            
            if(masterFitsFfiFiles.length != 1){
                throw new ModuleFatalProcessingException("Found more than one master FFI found in: " + masterFfiDirPath);
            }
            
            File masterFitsFfi = masterFitsFfiFiles[0];
            
            Etem2FitsFfi etem2FitsFfi = new Etem2FitsFfi(
                masterFitsFfi.getAbsolutePath(), startTimestamp, startMjd, endMjd,
                plannedConfigParams.getIntegrationsPerShortCadence(),
                plannedConfigParams.getShortCadencesPerLongCadence(),
                dataGenDirManager.getMergedDir(), ffiFitsDir, FFI_ORIG);
            etem2FitsFfi.generateFits();

            // Generate nm.
            NmGenerator.generateNotificationMessage(ffiFitsDir, "sfnm");

        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }
}
