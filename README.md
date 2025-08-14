# aind-behavior-camstim-pipeline

The aind-behavior-camstim-pipeline processes camstim data using their input ephys or ophys asset. The data from the h5, sync, and pkl files are added as stimulus tables, running speed tables, and lick/behavior tables to the nwb. 

The pipeline runs on [Nextflow](https://www.nextflow.io/) and contains the following steps:

* [aind-stimulus-packaging-nwb-capsule](https://github.com/AllenNeuralDynamics/NWB-Packaging-Stimulus-Capsule.git): The data from the rows of the input csv data is added to a stimulus table within the nwb
* [aind-running-speed-nwb-capsule](https://github.com/AllenNeuralDynamics/NWB-Packaging-Running-Capsule.git): The data from the sync file is used to create a raw running speed and processed running speed table. These are appended to the nwb file
* [aind-licks-rewards-capsule](https://github.com/AllenNeuralDynamics/aind-licks-rewards-nwb): The data from the pkl and sync files are used to create a licks/rewards table in the nwb file. 

# Input

Currently, the pipeline supports the following input data types:

* `aind`: data ingestion used at AIND. The input folder must contain a subdirectory called `behavior` (for planar-ophys) which contains a csv file containing the stimulus table. The root directory must contain JSON files following [aind-data-schema](https://github.com/AllenNeuralDynamics/aind-data-schema).

```plaintext
📦data
 ┣ 📂single-plane-ophys_MouseID_YYYY-MM-DD_HH-M-S
 ┃ ┣ 📂pophys
 ┣ 📜data_description.json
 ┣ 📜session.json
 ┗ 📜processing.json
 ```

The pipeline populates the NWB file with structured behavior data derived from 2-photon photostimulation or electrophysiological experiments.


# Output

Tools used to read files in python are [h5py](https://pypi.org/project/h5py/), json and csv.

* `aind`: The pipeline outputs are saved under the `results` top-level folder with JSON files following [aind-data-schema](https://github.com/AllenNeuralDynamics/aind-data-schema). Each field of view (plane) runs as a parallel process from motion-correction to event detection. The first subdirectory under `results` is named according to Allen Institute for Neural Dynamics standard for derived asset formatting. Below that folder, each field of view is named according to the anatomical region of imaging and the index (or plane number) it corresponds to. The index number is generated before processing in the session.json which details out the imaging configuration during acquisition. As the movies go through the processsing pipeline, a JSON file called processing.json is created where processing data from input parameters are appended. The final JSON will sit at the root of the `results` folder at the end of processing. 

```plaintext
📦results
 ┣ 📂single-plane-ophys_MouseID_YYYY-MM-DD_HH-M-S
 ┃ ┣ 📂single-plane-ophys_MouseID_YYYY-MM-DD_HH-M-S-processed_YYYY-MM-DD_HH-M-S.nwb
 ┗ 📜processing.json
 ```


# Run

`aind` Runs in the Code Ocean pipeline [here](https://codeocean.allenneuraldynamics.org/capsule/7026342/tree). If a user has credentials for `aind` Code Ocean, the pipeline can be run using the [Code Ocean API](https://github.com/codeocean/codeocean-sdk-python). 

Derived from the example on the [Code Ocean API Github](https://github.com/codeocean/codeocean-sdk-python/blob/main/examples/run_pipeline.py)

```python
import os

from codeocean import CodeOcean
from codeocean.computation import RunParams
from codeocean.data_asset import (
    DataAssetParams,
    DataAssetsRunParam,
    PipelineProcessParams,
    Source,
    ComputationSource,
    Target,
    AWSS3Target,
)

# Create the client using your domain and API token.

client = CodeOcean(domain=os.environ["CODEOCEAN_URL"], token=os.environ["API_TOKEN"])

# Run a pipeline with ordered parameters.

run_params = RunParams(
    pipeline_id=os.environ["PIPELINE_ID"],
    data_assets=[
        DataAssetsRunParam(
            id="6a980dad-f508-4d81-b879-6c7bb94935a9",
            mount="Reference",
        ),
)

computation = client.computations.run_capsule(run_params)

# Wait for pipeline to finish.

computation = client.computations.wait_until_completed(computation)

# Create an external (S3) data asset from computation results.

data_asset_params = DataAssetParams(
    name="My External Result",
    description="Computation result",
    mount="my-result",
    tags=["my", "external", "result"],
    source=Source(
        computation=ComputationSource(
            id=computation.id,
        ),
    ),
    target=Target(
        aws=AWSS3Target(
            bucket=os.environ["EXTERNAL_S3_BUCKET"],
            prefix=os.environ.get("EXTERNAL_S3_BUCKET_PREFIX"),
        ),
    ),
)

data_asset = client.data_assets.create_data_asset(data_asset_params)

data_asset = client.data_assets.wait_until_ready(data_asset)
```


