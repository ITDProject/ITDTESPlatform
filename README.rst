**# ITDTESPlatformV2.1**

The code/data in this repository are for ITDTESPlatformV2.1 provided in support of the ITD Project. The details of this project can be found at http://www2.econ.iastate.edu/tesfatsi/ITDProjectHome.htm

A preliminary version of this platform is called ITDTESPlatformV1.0, developed by Hieu T. Nguyen, Swathi Battula, Rohit Reddy Takkala, Leigh Tesfatsion; see Nguyen et al. (2019), "An Integrated Transmission and Distribution Test System for Evaluation of Transactive Energy Designs," *Applied Energy*, Volume 240, 666-679. 

In this repository, the ITD TES Platform versions start from V2.0; they do not build on V1.0. Currently, these versions are only supported on a Windows operating system.

**Installation Instructions:**

#. Download the contents of this repository into a folder, let's call it 'ITDTESPlatformV2.1'. Now make 'ITDTESPlatformV2.1' the parent directory to install the components given in the steps 2 and 3.

#. Install the transmission component of the ITDTESPlatformV2.1, AMES V5.1, by following the installation instructions given at: https://github.com/ITDProject/AMES/blob/V5.1/INSTALLATION.rst

#. Download the contents of the distribution component of ITDTESPlatformV2.1 located at https://github.com/ITDProject/DistributionSystem/tree/V1.0 into the directory 'ITDTESPlatformV2.1'. Follow the installation instructions given at https://github.com/ITDProject/DistributionSystem/blob/V1.0/README.rst to install the necessary components.


**Steps involved in execution:**

#. Go to the directory of the distribution component and perform the execution steps listed below:

   #. Generate distribution system feeder populated with households with the choice of 'Household Type' by executing the following:

      python FeederWriter.py FeederFileName FeederLoadFileName NDistSys Mix Type TxBus
   
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
	   
      * TxBus - The transmission bus to which the distribution system is considered to be connected to (Note: This input is needed if this model is used within an ITD system, else it defaults to 1)
   
      Example usage: python FeederWriter.py IEEE123Feeder.glm IEEE123LoadObjects.txt 1 0 2 1;
   
      Outcomes:
   
      * A '.glm' file for the distribution system: It is the required distribution feeder populated by households
   
      * A '.yaml' file for the IDSO: IDSO yaml file would contain all necessary details required to communicate with distribution agents (and transmission agents if this model is used within an ITD)
   
      * A '.bat' file for the households: It would contain the required code to run household processes, used in Step 4.
    
      Sample outcomes: IEEE123FeederModified1.glm, IDSO.yaml, runHouseholds.bat

   #. Generate required additional files by executing the following command:
   
      python AgentPrep.py FileName NDistSys TxBus
   
      The above commands depend on the following user-specified parameters: 
   
      * FileName - The name of the distribution feeder generated in the above step
   
      * NDistSys - The number of distribution systems that are handled by the IDSO
   
      * TxBus - The transmission bus to which the distribution system is considered to be connected to (Note: This input is needed if this model is used within an ITD system, else it defaults to 1)
   
      Example usage: python AgentPrep.py IEEEModified1 1 1
    		
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
   
      * TxBus - The transmission bus to which the distribution system is considered to be connected to (Note: This input is needed if this model is used within an ITD system, else it defaults to 1)
   
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
   
#. Check additional instructions starting from Step 2 provided at https://github.com/ITDProject/AMES/blob/V5.1/USAGE.pdf

   
**Miscellaneous Notes:** 

* User can end the simulation run in the middle of the run by executing 'kill5570.bat'. Executing 'list5570.bat' lists all the processes. If you perform 'kill5570.bat', make sure to run 'list5570.bat' shows no process before executing another 'runIDSO.bat' operation. 
* If a user is interested to run transmission processes only, 'runAMES.bat' needs to be used in the place of 'runITD.bat'.
* AMES generates a lot of temporary files. To delete them, execute 'deleteTempFiles.bat'. 
* Note for developers: 
	* For 'import fncs' to work, the environmental variable $PATH needs to be appended to add location of 'fncs.py'.
	* If you make modifications to AMESV5.1, it can be compiled from ITD TES Platform repository as well by using 'compileAMES.bat'. Make sure that you have set the correct path and version by editing the file compileAMES.bat. 
