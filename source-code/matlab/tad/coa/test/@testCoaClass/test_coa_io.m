function self = test_coa_io(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_coa_io(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% loads standard input and output data from disk, writes as a .bin file,
% read .bin file and compares result.  
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% we have to seed the random number generators since these algorithms make
% statistical choices
rand('seed', 0);
randn('seed', 0);

% first test the inputs
% get the standard data input struct
coaParameterStruct = setup_standard_coa_test_data();

% write the input structure as a .bin file
write_CoaInputs('testCoaIn.bin', coaParameterStruct);

% read the input .bin file
testParameterStruct = read_CoaInputs('testCoaIn.bin');

% test for equality of the input structures
assert(isequal(testParameterStruct, coaParameterStruct), ...
    'TAD:target pixel processing: input test fail');

delete testCoaIn.bin

% now test the outputs
% get the standard result
load /path/to/matlab/tad/coa/coa_standard_test_result standardCoaResultStruct;

% write the output structure as a .bin file
write_CoaOutputs('testCoaOut.bin', standardCoaResultStruct);

% read the output .bin file
testResultStruct = read_CoaOutputs('testCoaOut.bin');

% tets all fields except completeOutputImage
assert(isequal(rmfield(testResultStruct, 'completeOutputImage'), ...
    rmfield(standardCoaResultStruct, 'completeOutputImage')), ...
    'TAD:COA: output test fail');

% tets completeOutputImage, which requires special treatment
assert(isequal(struct_to_array2D(testResultStruct.completeOutputImage), ...
    struct_to_array2D(standardCoaResultStruct.completeOutputImage)), ...
    'TAD:COA:completeOutputImage: output  test fail');

delete testCoaOut.bin

