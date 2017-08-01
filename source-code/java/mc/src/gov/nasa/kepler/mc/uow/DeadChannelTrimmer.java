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

package gov.nasa.kepler.mc.uow;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.List;

import com.google.common.primitives.Ints;

/**
 * Trims dead channels.
 * 
 * @author Miles Cote
 * 
 */
public class DeadChannelTrimmer {

    public List<ModOutCadenceUowTask> trim(List<ModOutCadenceUowTask> tasks,
        List<Pair<Integer, Integer>> deadChannelCadencePairs) {
        List<ModOutCadenceUowTask> trimmedTasks = newArrayList(tasks);
        for (ModOutCadenceUowTask task : tasks) {
            for (Pair<Integer, Integer> deadChannelCadencePair : deadChannelCadencePairs) {

                int deadChannel = deadChannelCadencePair.left;
                int deathCadence = deadChannelCadencePair.right;

                if (channelsContainsDeadChannel(task, deadChannel)
                    && deathCadence <= task.getEndCadence()) {
                    if (task.getChannels().length > 1) {
                        // Remove the dead channel from the task, but leave
                        // the valid channels in the task.
                        removeDeadChannel(task, deadChannel);
                    } else {
                        // The dead channel was the only channel in the
                        // task, so remove the task.
                        int index = trimmedTasks.indexOf(task);
                        trimmedTasks.remove(index);
                    }

                    if (deathCadence > task.getStartCadence()) {
                        // There are some valid cadences for the dead
                        // channel, so create a new task for it.
                        ModOutCadenceUowTask deadChannelTask = task.makeCopy();
                        deadChannelTask.setChannels(new int[] { deadChannel });
                        deadChannelTask.setEndCadence(deathCadence - 1);
                        trimmedTasks.add(deadChannelTask);
                    }
                }
            }
        }

        return trimmedTasks;
    }

    private void removeDeadChannel(ModOutCadenceUowTask task, int deadChannel) {
        List<Integer> channels = newArrayList();
        for (int channel : task.getChannels()) {
            if (channel != deadChannel) {
                channels.add(channel);
            }
        }
        task.setChannels(Ints.toArray(channels));
    }

    private boolean channelsContainsDeadChannel(ModOutCadenceUowTask task,
        int deadChannel) {
        boolean channelsContainsDeadChannel = false;
        for (int channel : task.getChannels()) {
            if (channel == deadChannel) {
                channelsContainsDeadChannel = true;
            }
        }
        return channelsContainsDeadChannel;
    }

}
