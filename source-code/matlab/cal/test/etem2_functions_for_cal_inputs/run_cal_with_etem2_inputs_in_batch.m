function run_cal_with_etem2_inputs_in_batch()
% 
% function to run the CAL CSCI for a list of inputs created from ETEM2 output
%
%   ex. run_cal_with_etem2_inputs(etem2ParametersString,  getRequantizedPixFlag, includeCosmicRaysFlag)
%
%   run_cal_with_etem2_inputs('2d_st_sm_dc_nl_lu_ff_rn_qn_sn', 1, 0)
%   run_cal_with_etem2_inputs('2d_st_sm_dc_nl_lu_ff_rn_qn_sn', 0, 0)
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%
 

%--------------------------------------------------------------------------
% List of cal etem2 input files   (Jan 20)
%--------------------------------------------------------------------------
%
% calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat
% calETEM_2d_st_sm_dc_nl_lu_ff_RN_QN_SN.mat
% calETEM_2d_ST_sm_dc_nl_lu_ff_rn_qn_sn.mat
% calETEM_2d_ST_sm_dc_nl_lu_ff_RN_QN_SN.mat
% calETEM_2d_ST_sm_dc_nl_lu_FF_rn_qn_sn.mat
% calETEM_2d_ST_sm_dc_nl_lu_FF_RN_QN_SN.mat
% calETEM_2d_ST_sm_dc_nl_LU_ff_rn_qn_sn.mat
% calETEM_2d_ST_sm_dc_nl_LU_ff_RN_QN_SN.mat
% calETEM_2d_ST_sm_dc_NL_lu_ff_rn_qn_sn.mat
% calETEM_2d_ST_sm_dc_NL_lu_ff_RN_QN_SN.mat
% calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn.mat
% calETEM_2D_st_sm_dc_nl_lu_ff_RN_QN_SN.mat
% calETEM_2D_st_sm_dc_nl_lu_FF_rn_qn_sn.mat
% calETEM_2D_st_sm_dc_nl_lu_FF_RN_QN_SN.mat
% calETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn.mat
% calETEM_2D_ST_sm_dc_nl_lu_ff_RN_QN_SN.mat
% calETEM_2D_ST_sm_dc_nl_LU_ff_rn_qn_sn.mat
% calETEM_2D_ST_sm_dc_nl_LU_ff_RN_QN_SN.mat
% calETEM_2D_ST_sm_dc_NL_lu_ff_rn_qn_sn.mat
% calETEM_2D_ST_sm_dc_NL_lu_ff_RN_QN_SN.mat
% calETEM_2D_ST_sm_DC_nl_lu_ff_rn_qn_sn.mat
% calETEM_2D_ST_sm_DC_nl_lu_ff_RN_QN_SN.mat
% calETEM_2D_ST_SM_dc_nl_lu_ff_rn_qn_sn.mat
% calETEM_2D_ST_SM_dc_nl_lu_ff_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_nl_lu_ff_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_nl_lu_FF_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_nl_LU_ff_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_nl_LU_FF_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_nl_LU_FF_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_NL_lu_ff_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_NL_lu_FF_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_NL_lu_FF_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_NL_LU_ff_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_NL_LU_ff_RN_QN_SN.mat
% calETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn.mat
% calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN.mat
%
%--------------------------------------------------------------------------
% additional runs added Jan 21:
%
% calETEM_2D_ST_sm_dc_nl_lu_FF_rn_qn_sn
% calETEM_2D_ST_sm_dc_nl_lu_FF_RN_QN_SN

close all
clear classes


run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_FF_RN_QN_SNTEST', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_ff_RN_QN_SNTEST', 0, 0)






return;


run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_FF_rn_qn_snTEST', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_ff_rn_qn_snTEST', 0, 0)



return;

run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_FF_RN_QN_SN', 0, 0)


return;

% Run CAL for NON-REQUANTIZED pixels without cosmic rays
run_cal_with_etem2_inputs('2d_st_sm_dc_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2d_st_sm_dc_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_FF_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_LU_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_LU_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_NL_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_NL_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_FF_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_LU_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_LU_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_NL_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_NL_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_DC_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_sm_DC_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_dc_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_dc_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_FF_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_FF_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_FF_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_ff_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_ff_RN_QN_SN', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_FF_rn_qn_sn', 0, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_FF_RN_QN_SN', 0, 0)


return;

%NEW
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_FF_RN_QN_SN', 1, 0)


% Run CAL for REQUANTIZED pixels without cosmic rays
run_cal_with_etem2_inputs('2d_st_sm_dc_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2d_st_sm_dc_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_lu_FF_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_LU_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_nl_LU_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_NL_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2d_ST_sm_dc_NL_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_st_sm_dc_nl_lu_FF_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_LU_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_nl_LU_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_NL_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_dc_NL_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_DC_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_sm_DC_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_dc_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_dc_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_lu_FF_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_nl_LU_FF_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_lu_FF_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_ff_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_ff_RN_QN_SN', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_FF_rn_qn_sn', 1, 0)
run_cal_with_etem2_inputs('2D_ST_SM_DC_NL_LU_FF_RN_QN_SN', 1, 0)


return;   % Jan 20
