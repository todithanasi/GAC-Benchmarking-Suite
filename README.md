#  GAC Benchmarking Suite
GAC is a scripting benchmarking suite created as part of my master thesis work. Below it is a description of the Benchmarking Suite extracted from my master thesis.

``start_benchmarking.sh`` it is the main file to start the scripts. Inside the file there is documentation in how to use it and the parameters to pass. 

# GAC Benchmarking Suite

GAC Benchmarking Suite follows a modular software design and has several
modules. The main reasons for using a modular architecture are to
guarantee flexibility of the system and that the framework is
extensible. The GAC supports benchmarking for several engines and
datasets, which can be entirely different from each other. The GAC has
several modules that can easily be modified, extended, and replaced
without impacting the rest of the system. Such implementation of using
separated modules provides the possibility of extending and enriching
with new engines, datasets, and functionalities the benchmarking suite.
Figure [\[fig:GAC\_Architecture\]](#fig:GAC_Architecture) shows an
architecture overview of the system, including the modules and their
interoperability. We explain in this section the components of each
module and their functionality.

![The system architecture overview of the GAC Benchmarking
Suite](GAC_Architecture.png)  

<span id="fig:GAC_Architecture" label="fig:GAC_Architecture">\[fig:GAC\_Architecture\]</span>

## Data Module

Data Module has two main components: Dataset Converter and the Data
Integration Component. **The Dataset Converter Component** provides some
scripts which convert the datasets coming from different providers into
standard file formats. The system supports so far handling for two
different dataset providers: Standford  and WebGraph  . The datasets
that are part of the Standford Large Network Dataset Collection are
straightforward to use because after uncompressing they are in "txt"
format. However, the usage for the WebGraph is not so smooth because
they use their algorithm to compress and decompress the graphs. Also, it
is important to mention that even after decompression, the file format
is not "txt" format but in some other custom format that WebGraph uses.
So, the usage of such component helps to address and solve the provider
heterogeneity issue.

**The Data Integration Component** is responsible for (1) transforming
the data in the expected format (such as HDFS files, CSV, txt) for the
underlying engine and (2) loading the datasets in the respective engine
part of the testing experiment.

## Query Module

GAC supports several engines like relational row store and column store,
graph store, and dataflow engines. These engines come with different
query semantics, and it is the task of the Query Module to provide the
algorithm in the appropriate language that the system under test (SUT)
supports. The module has a component named Query Generator that is using
a few scripts to map the different algorithms in different languages
like Cypher (in the case of the Neo4J database) and SQL (in the case of
the relational databases).

## SUT Tuning Module

The SUT Tuning Module plays an essential role in the GAC Benchmarking
Suite because it provides crucial optimizations to leverage full power
from the SUT. The module uses the Engine Tuning Component and the Query
Tuning Component to gain the maximum performance from the engine that is
running the queries.

The Engine Tuning Component is responsible for tuning different
low-level engine configuration parameters such as heap memory, buffer
memory, compression method, network buffer sizes, log buffer size, hdfs
block size, disable transactions, etc. The list of parameters to tune
varies from engine to engine since they have an entirely different
internal implementation. It is part of our work to study the internals
of the engines and try to tune them accordingly.

The Query Tuning Component is responsible for tuning the implementation
of algorithms in terms of selecting the right data structures, usage of
indexes when possible and prevent the usage of unnecessary data. By
reducing the data which the computation algorithms do not use
contributes to reducing the network load. Also, such optimizations do
not apply to every engine, but we use them when it is possible. The
above optimizations emphasize the importance of this module in providing
a fair comparison between engines.

## Utility Module

The GAC Benchmarking offers the possibility to compare several engines,
which means the existence of heterogeneity in the log file formats and
the errors that the engines generate. Said that using the default files
would lead to difficulties in processing them afterward. So, we
introduce the Utility Module, which as the name indicates is providing
some utility functionalities to the system. The module is helping in
standardizing and unifying some features like logging and error
handling. It composes by the Error Handler Component, Logging Component,
and the Configuration Parser Component. The Error Handler Component is
responsible for providing detailed and user-friendly error messages to
facilitate the process of debugging in case of thrown errors. The Error
Handler Component is categorizing the errors in several categories to
give more insights to the user of the system for the possible reason for
the issue. Also, the component is helping to unify the error handling,
and its functionality is independent, and the engine does not pose any
restriction.

The Logging Component write and gathers the logs in a centralized and
standardized way. The log files that this component generates contain
detailed information regarding the parameters, default system settings,
datasets, algorithm, and metrics that the system uses to measure
performance. Such implementation helps in tracking different
experiments, and the processing of the logs quickly.

The Configuration Parser Component is responsible for parsing different
configurations that are useful to the other modules. The configurations
are both provided in the form of property files or as parameters. The
parses check the validity of the settings and transform them into the
appropriate format for the module that is going to use them.

## Engine Module

The Engine Module has only one component named System Configurator in
the actual version of the software. The System Configurator Component is
responsible for changing and applying specific configuration settings
that are suggested by the configuration files or the optimization
module. The component handles the start and stop of the engines and
monitors the status of the engine. The Engine Module expects that the
engines are already present in the servers and it relies on the settings
configuration to propagate and apply the changes in the engines.

## Core Module

The Core Module is the brain of the GAC Benchmarking Suite because it is
orchestrating and interacting with the other modules during the
execution of the experiments. The module has two components named
Execution Manager and Scheduler Manager.

The Execution Manager Component plays the role of the orchestrator and
is responsible for the full coordination between the other modules. The
Execution Manager Component executes several scripts to check and
validate the system configuration settings, check the engine’s status,
load the data into the system, prepare the optimized algorithms for the
respective engine, and finally, execute the experiments with all
parameters.

The Scheduler Manager Component is scheduling and checking the execution
order of the Benchmarking experiments by providing in the needed set of
parameters. Also, the component is taking care of controlling and
cleaning the environment before launching the next experiment. The
existence of such components helps to isolate the experiments running in
different engines and guarantees that there is no overlap within the
same machine to prevent resource competition.
