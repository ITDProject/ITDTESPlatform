**# ITDTESPlatform**

The ITDTESPlatform repository provides code/data for the ITD TES Platform V2.XX (and later), a co-simulated software platform permitting users to undertake Transactive Energy System (TES) design studies for Integrated Transmission and Distribution (ITD) systems.  See, for example, the annotated links to the ITD TES design studies undertaken for the ITD Project that are provided at the project homepage: http://www2.econ.iastate.edu/tesfatsi/ITDProjectHome.htm. 

Currently, versions 2.XX (and later) are only supported on a Windows operating system.

A preliminary version of the ITD TES platform was developed by Hieu T. Nguyen et al. [1-2]:

[1] Hieu Trung Nguyen, Swathi Battula, Rohit Reddy Takkala, and Leigh Tesfatsion (2017), ITD TES Platform: Code and data repository. URL: https://github.com/htnnguyen/ITD_TES

[2] Hieu Trung Nguyen, Swathi Battula, Rohit Reddy Takkala, Zhaoyu Wang, and Leigh Tesfatsion (2019), "An Integrated Transmission and Distribution Test System for Evaluation of Transactive Energy Designs," Applied Energy, Volume 240, 666-679. 

Versions 2.XX (and later) of the ITD TES Platform do not build on version 1.0. 

The folder 'TDInterconnection' contains linkage files necessary for simulating the transmission and distribution components of the ITD TES Platform V2.XX in a coordinated manner.

**Installation Instructions:**

#. Download the contents of this repository into a folder, let's call it 'ITDTESPlatform'. Now make 'ITDTESPlatform' the parent directory to install the components given in the steps 2 and 3.

#. Install the transmission component of the ITDTESPlatform, AMES, by following the installation instructions given at: https://github.com/ITDProject/AMES/blob/main/INSTALLATION.rst

#. Download the contents of the distribution component of ITDTESPlatform located at https://github.com/ITDProject/DistributionSystem into the directory 'ITDTESPlatform'. Follow the installation instructions given at https://github.com/ITDProject/DistributionSystem/blob/main/README.rst to install the necessary components.


**Steps involved in execution:**

#. Go to the directory of the distribution component and perform the execution steps listed below:

   #. Generate distribution system feeder populated with households with the choice of 'Household Type' by executing the following:

      python feederWriter.py FeederFileName FeederLoadFileName NDistSys Mix Type TxBus
   
      The above commands depend on the following user-specified parameters: 
   
      * FeederFileName - The name of the feeder file, e.g. IEEE123.glm, IEEE13.glm, etc
   
      * FeederLoadFileName - The name of the file that has original feeder load details
   
      * NDistSys - The number of distribution systems that are handled by the IDSO
   
      * Mix - Represents if the chosen households are a mix of different structure types or single structure type;
   
        * Mix is set to 0: A single structure type, set by input parameter 'Type' described below, is chosen to populate the distribution system feeder;
   
        * Mix is set to 1: A mix of structure types Low, Medium, High are used to populate the distribution system feeder;
	 
      * Type - Represents household's structure quality type; 

        * Set Type to 1 for Low Structure Quality Type;

        * Set Type to 2 for Medium Structure Quality Type;

        * Set Type to 3 for High Structure Quality Type;
	   
      * TxBus - The transmission bus to which the distribution system is considered to be connected. (Note: This input is needed if this model is used within an ITD system, else it defaults to 1)
   
      Example usage: python feederWriter.py IEEE123Feeder.glm IEEE123LoadObjects.txt 1 0 2 1;
   
      Outcomes:
   
      * A '.glm' file for the distribution system: It is the required distribution feeder populated by households
   
      * A '.yaml' file for the IDSO: IDSO yaml file would contain all necessary details required to communicate with distribution agents (and transmission agents if this model is used within an ITD)
   
      * A '.bat' file for the households: It would contain the required code to run household processes, used in Step 4.
    
      Sample outcomes: IEEE123FeederModified1.glm, IDSO.yaml, runHouseholds.bat

   #. Generate required additional files by executing the following command:
   
      python agentPreparation.py FileName NDistSys TxBus
   
      The above commands depend on the following user-specified parameters: 
   
      * FileName - The name of the distribution feeder generated in the above step
   
      * NDistSys - The number of distribution systems that are handled by the IDSO
   
      * TxBus - The transmission bus to which the distribution system is considered to be connected. (Note: This input is needed if this model is used within an ITD system, else it defaults to 1)
   
      Example usage: python agentPreparation.py IEEE123FeederModified1 1 1
    		
      Outcomes: 
   
      * FNCS configuration txt file: It contains needed input information for configuring GridLAB-D subscriptions and publications
   
      * '.json' registration file for the IDSO: It contains the input information required to initialize the IDSO
   
      * '.json' registration files for the households: Each file contains input information (household attributes) specific to each household
   
      Sample outcomes: IEEE123FeederModified1_FNCS_Config.txt, IDSO_registration.json, etc
   
      Note: 'agentPreparation.py' imports 'agentRegistration' class from 'agentRegistration.py'.

#. Go to the directory 'TDInterconnection' and perform the steps listed below:

   #. Generate YAML file for AMES by executing the below command:
   
      python YAMLWriter.py NTxBus NLSE TxBus
   
      The above commands depend on the following user-specified parameters: 
   
      * NTxBus - The number of transmission buses
   
      * NLSE - The number of LSEs present in the tranmission model
   
      * TxBus - The transmission bus to which the distribution system is considered to be connected. (Note: This input is needed if this model is used within an ITD system, else it defaults to 1)
   
      (Example usage: python YAMLWriter.py 2 1 1)  
      
      The generated YAML file contains the required subscriptions for configuring AMES.
      

   #. Set the following parameters in the runITD.bat

      * TSDir - Set the path of parent directory of AMES version that is being used
      
      * TDIDir - Set the path of TDIInterconnectionFiles folder to this parameter
      
      * DSDir - Set the path of HouseholdFormulationRepository folder to this parameter
      
      * AMESVersion - Set the version of AMES (e.g. AMESV5.1)

      * NHour - Number of additional hours the simulation needs to be carried out after the simulation is run for NDay

      * deltaT - Length (seconds) of each control-step of the Five-Step TES design

      * NoOfHouses - Number of households connected to the distribution system feeder

      * NDistSys - Number of distribution systems monitored by the IDSO
     
      * FeederFileName - The name of the feeder file given in Step 1 (without '.glm' extension), e.g. IEEE123, IEEE13, etc

      * C - Choose an appropriate case; 

        * Set C to 0 for generating test case outcomes with a flat retail price. Also set FRP(cents/kWh) to user specified retail price 

        * Set C to 1 for generating test case outcomes for 'Test Case 2: IDSO Peak Load Reduction Capabilities'. Also set PL(kW) and TPLR(kW) to user specified values

        * Set C to 2 for generating test case outcomes for 'Test Case 3: IDSO Load Matching Capabilities'. Also set RefLoad


#. Run all the distribution system processes together with transmission processes by executing the following command:
   
   runITD.bat FileName
   
   The above command depends on the following user-specified parameter:
   
   * FileName - The name of the input data file, e.g. 2BusTestCase
   
#. Check additional instructions starting from Step 2 provided at https://github.com/ITDProject/AMES/blob/main/USAGE.pdf

   
**Miscellaneous Notes:** 

* Users can end a simulation run in the middle of the run by executing 'kill5570.bat'. Executing 'list5570.bat' lists all currently running processes. If you perform 'kill5570.bat', you should next be sure to run 'list5570.bat' to check that no processes are currently running before you attempt to execute another 'runIDSO.bat' operation. 
* If a user wishes to run transmission processes only, 'runAMES.bat' needs to be used in place of 'runITD.bat'.
* AMES generates many temporary files. To delete them, execute 'deleteTempFiles.bat'. 
* Note for developers: 
	* For 'import fncs' to work, the environmental variable $PATH needs to be appended to add the location of 'fncs.py'.
	* If you make modifications to AMES, you can compile the modified version of AMES from the ITD TES Platform repository by running 'compileAMES.bat'. Make sure that you edit 'compileAMES.bat' to reflect the correct path and version number before you run it.
