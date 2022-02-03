=====
USAGE
=====

**Steps involved in execution:**

#. Go to the parent directory of the distribution component and perform the execution steps listed below:

   #. Generate distribution grid populated with households with the choice of 'Household Type' by executing the following:

      python IEEE123_glm_yaml_bat_writer.py NDistSys Mix Type
   
      The above commands depend on the following user-specified parameters: 

      * NDistSys - The number of distribution systems that are handled by the IDSO

      * Mix - Represents if the chosen households are a mix of different structure types or single structure type;

        * Mix is set to 0: A single structure type, set by input parameter 'Type' described below, is chosen to populate the distribution grid;

        * Mix is set to 1: A mix of structure types Low, Medium, High are used to populate the distribution grid;

      * Type - Represents household's structure quality type; 

        * Set Type to 1 for Low Structure Quality Type;

        * Set Type to 2 for Medium Structure Quality Type;

        * Set Type to 3 for High Structure Quality Type;

      (Example usage: python IEEE123_glm_yaml_bat_writer.py 1 0 2)

   #. Generate required additional files by executing the following command:

      python prep_agents123.py FileName NDistSys 

      The above commands depend on the following user-specified parameters: 

      * FileName - The name of the distribution grid generated in the above step (do not include .glm extension)

      * NDistSys - The number of distribution systems that are handled by the IDSO

      (Example usage: python prep_agents123.py IEEEModified1 1)  

      Outcomes: FNCS configuration txt file and json registration files for IDSO and households.
      FNCS configuration txt file contains needed input information for configuring GridLAB-D subscriptions and publications. IDSO json file contains needed input information for the IDSO and Household json file contains household specific information (household attributes).

   #. Set the following parameters in the runITD.bat

      * TSDir - Set the path of parent directory of AMES
      * TDIDir - Set the path of TDIInterconnectionFiles folder to this parameter
      * DSDir - Set the path of HouseholdFormulationRepository folder to this parameter
      * AMESVersion - Set the version of AMES (e.g. AMESV5.0)

      * NHour - Number of additional hours the simulation needs to be carried out after the simulation is run for NDay

      * deltaT - Length (seconds) of each control-step of the Five-Step TES design

      * NoOfHouses - Number of households connected to the distribution grid

      * NDistSys - Number of distribution systems monitored by the IDSO

      * C - Choose an appropriate case; 

        * Set C to 0 for generating test case outcomes with a flat retail price. Also set FRP(cents/kWh) to user specified retail price 

        * Set C to 1 for generating test case outcomes for 'Test Case 2: IDSO Peak Load Reduction Capabilities'. Also set PL(kW) and TPLR(kW) to user specified values

        * Set C to 2 for generating test case outcomes for 'Test Case 3: IDSO Load Matching Capabilities'. Also set RefLoad


#. Run all the distribution system processes together with transmission processes by executing the following command:
   runITD.bat FileName
   The above commands depend on the following user-specified parameter:
   FileName - The name of the input data file, e.g. 2BusTestCase
   
#. Check additional instructions starting from Step 2 provided at https://github.com/ames-market/AMES-V5.0/blob/master/USAGE.pdf
   
   
**Miscellaneous Notes:** 

* Users can end a simulation run in the middle of the run by executing 'kill5570.bat'. Executing 'list5570.bat' lists all currently running processes. If you perform 'kill5570.bat', you should next be sure to run 'list5570.bat' to check that no processes are currently running before you attempt to execute another 'runIDSO.bat' operation. 
* AMES generates many temporary files. To delete them, execute 'deleteTempFiles.bat'. 
* Note for developers:
	* If you make modifications to AMES, you can compile the modified version of AMES from the ITD TES Platform repository by running 'compileAMES.bat'. Make sure that you edit 'compileAMES.bat' to reflect the correct path and version number before you run it.
