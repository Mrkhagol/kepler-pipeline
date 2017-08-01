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

package gov.nasa.kepler.services.messaging;

import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.MessageProducer;
import javax.jms.ObjectMessage;
import javax.jms.Session;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class TestJmsProducer extends TestJmsClient{
    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(TestJmsProducer.class);

    private static final int MESSAGE_COUNT = 20;
    /**
     * 
     */
    public TestJmsProducer() {
    }

    public void send() throws Exception{
        initialize();
//        createQueue( "my-dest" );
        
        Session session = connection.createSession( true, Session.AUTO_ACKNOWLEDGE );
//        Destination destination = (Destination) context.lookup( "my-dest" );
        Destination destination = session.createQueue("my-dest");
        MessageProducer producer = session.createProducer( destination );
        
        for (int i = 0; i < MESSAGE_COUNT; i++) {
            log.info("sending...");
            TestMessage msg = new TestMessage("msg-" + i);
            ObjectMessage jmsMessage = session.createObjectMessage();
            jmsMessage.setObject( msg );

            producer.send( jmsMessage, DeliveryMode.PERSISTENT, 4, 0 );
        }
        
        session.commit();
        
        System.exit(0);
    }
    
    /**
     * @param args
     * @throws PipelineException 
     */
    public static void main(String[] args) throws Exception {
        DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);
        
        TestJmsProducer testProducer = new TestJmsProducer();
        testProducer.send();
    }

}
