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

package gov.nasa.kepler.aft.gar;

import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.gar.HistogramPipelineParameters;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class provides the basis for tests of the histogram pipeline modules.
 * Subclasses must override {@link #getHistogramPipelineParameters()} and
 * provide their uniqueness by jiggling the pipeline's parameters. Their
 * constructor must call {@code super(Class)} and pass their own class.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public abstract class AbstractHistogramFeatureTest extends AutomatedFeatureTest {

    private static final String GENERATOR_NAME = "histogram";

    private static final String HISTOGRAM_TRIGGER_NAME = "HISTOGRAM";

    private static final Log log = LogFactory.getLog(AbstractHistogramFeatureTest.class);

    public AbstractHistogramFeatureTest(String testName) {
        super(GENERATOR_NAME, testName);
    }

    @Override
    protected void createDatabaseContents() throws Exception {

        log.info(getLogName() + ": Importing pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + GENERATOR_NAME + ".xml"));

        updateCadenceRangeParameters();
        updateHistoramPipelineParameters();
    }

    private void updateHistoramPipelineParameters() {

        ParameterSet histogramParameterSet = retrieveParameterSet(GENERATOR_NAME);
        if (histogramParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", GENERATOR_NAME));
        }

        new PipelineOperations().updateParameterSet(histogramParameterSet,
            getHistogramPipelineParameters(), false);
    }

    protected abstract HistogramPipelineParameters getHistogramPipelineParameters();

    @Override
    protected void process() throws Exception {
        runPipeline(HISTOGRAM_TRIGGER_NAME);
    }
}
