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

package gov.nasa.kepler.hibernate.ppa;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.criterion.Restrictions;

/**
 * Data access operations for PPA objects.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class PpaCrud extends AbstractCrud {

    /**
     * Creates a {@link PpaCrud}.
     */
    public PpaCrud() {
        super(null);
    }

    /**
     * Creates a new {@code PdqCrud} object with the specified persistence
     * manager.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public PpaCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Stores an {@link MetricReport} instance.
     * 
     * @param metricReport the {@link MetricReport} object to create/update
     */
    public void createMetricReport(MetricReport metricReport) {
        if (metricReport == null) {
            throw new NullPointerException("metricReport is null");
        }

        getSession().save(metricReport);
    }

    /**
     * Stores a list of {@link MetricReport} instances or update existing ones.
     * 
     * @param metricReports the list of {@link MetricReport} objects to store
     */
    public void createMetricReports(List<? extends MetricReport> metricReports) {
        if (metricReports == null) {
            throw new NullPointerException("metricReports is null");
        }
        if (metricReports.isEmpty()) {
            throw new IllegalArgumentException("metricReports is empty");
        }

        for (MetricReport metricReport : metricReports) {
            createMetricReport(metricReport);
        }
    }

    /**
     * Retrieves all {@link PmdMetricReport} instances for the given target
     * table, start cadence, and end cadence.
     */
    public List<PmdMetricReport> retrievePmdMetricReports(
        PipelineInstance pipelineInstance) {

        Criteria query = getSession().createCriteria(PmdMetricReport.class);
        query.add(Restrictions.eq("pipelineInstance", pipelineInstance));

        List<PmdMetricReport> result = list(query);

        return result;
    }
}
