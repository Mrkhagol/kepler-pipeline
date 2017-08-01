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

package gov.nasa.kepler.mr.scriptlet;

import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the data compression report.
 * 
 * @author Bill Wohler
 */
public class DataCompressionScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(DataCompressionScriptlet.class);

    public static final String REPORT_NAME_DATA_COMPRESSION = "data-compression";
    public static final String REPORT_TITLE_DATA_COMPRESSION = "Data Compression";

    private static final long JAN_01_2020 = 1577865600000L;

    private CompressionCrud compressionCrud = new CompressionCrud();
    private List<HuffmanTableDescriptor> huffmanTableDescriptors;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // Retrieve the Huffman tables.
        try {
            huffmanTableDescriptors = compressionCrud.retrieveAllHuffmanTableDescriptors();

            if (huffmanTableDescriptors == null
                || huffmanTableDescriptors.size() == 0) {
                String text = "Huffman tables unavailable.";
                setErrorText(text);
                log.error(text);
                return;
            }

            log.debug("Read " + huffmanTableDescriptors.size() + " tables");
        } catch (HibernateException e) {
            String text = "Could not obtain Huffman tables: ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the
     * {@link HuffmanTableDescriptor}s as a time series.
     * 
     * @return a non-{@code null} data source
     */
    public JRDataSource dataSource() {
        List<MrTimeSeries> list = new ArrayList<MrTimeSeries>();

        if (huffmanTableDescriptors == null
            || huffmanTableDescriptors.size() == 0) {
            log.error("Should not be called if Huffman tables unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (HuffmanTableDescriptor huffmanTableDescriptor : huffmanTableDescriptors) {
            Date plannedStartTime = null;
            if (huffmanTableDescriptor.getPlannedStartTime() != null) {
                plannedStartTime = huffmanTableDescriptor.getPlannedStartTime();
            } else {
                // Place possibly new tables impossibly far to the right, but
                // chronologically correct with each other.
                plannedStartTime = new Date(JAN_01_2020
                    + huffmanTableDescriptor.getId());
            }
            list.add(new MrTimeSeries("Effective Compression",
                plannedStartTime,
                huffmanTableDescriptor.getEffectiveCompressionRate()));
            list.add(new MrTimeSeries("Theoretical Compression",
                plannedStartTime,
                huffmanTableDescriptor.getTheoreticalCompressionRate()));
        }

        return new JRBeanCollectionDataSource(list);
    }
}
