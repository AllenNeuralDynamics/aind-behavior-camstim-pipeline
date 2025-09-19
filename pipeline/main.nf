#!/usr/bin/env nextflow
// hash:sha256:586c1ce3e77689bea56a7f1c7a6f571a67ad73af8f9c4fb99691008aed5b2a06

nextflow.enable.dsl = 1

params.ophys_mount_url = 's3://aind-private-data-prod-o5171v/multiplane-ophys_770966_2025-05-14_12-14-46'

ophys_mount_to_aind_running_speed_nwb_1 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
ophys_mount_to_aind_stimulus_camstim_nwb_2 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_3 = channel.create()
ophys_mount_to_aind_ophys_camstim_behavior_qc_4 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_aind_stimulus_camstim_nwb_4_to_capsule_aind_licks_rewards_nwb_6_5 = channel.create()
ophys_mount_to_aind_licks_rewards_nwb_6 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
ophys_mount_to_aind_pipeline_processing_metadata_aggregator_7 = channel.fromPath(params.ophys_mount_url + "/*.json", type: 'any')
capsule_aind_running_speed_nwb_3_to_capsule_aind_pipeline_processing_metadata_aggregator_7_8 = channel.create()

// capsule - aind-running-speed-nwb
process capsule_aind_running_speed_nwb_3 {
	tag 'capsule-7501486'
	container "$REGISTRY_HOST/published/06b256c7-4869-40ab-82c1-3c74bff19009:v8"

	cpus 4
	memory '30 GB'

	input:
	path 'capsule/data/session' from ophys_mount_to_aind_running_speed_nwb_1.collect()

	output:
	path 'capsule/results/*' into capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_3
	path 'capsule/results/*.json' into capsule_aind_running_speed_nwb_3_to_capsule_aind_pipeline_processing_metadata_aggregator_7_8

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=06b256c7-4869-40ab-82c1-3c74bff19009
	export CO_CPUS=4
	export CO_MEMORY=32212254720

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v8.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7501486.git" capsule-repo
	else
		git clone --branch v8.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7501486.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-stimulus-camstim-nwb
process capsule_aind_stimulus_camstim_nwb_4 {
	tag 'capsule-6731893'
	container "$REGISTRY_HOST/published/b6908082-5b36-4e64-91d2-1b960d93a31d:v3"

	cpus 4
	memory '30 GB'

	input:
	path 'capsule/data/session' from ophys_mount_to_aind_stimulus_camstim_nwb_2.collect()
	path 'capsule/data/nwb/' from capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_3.collect()

	output:
	path 'capsule/results/*' into capsule_aind_stimulus_camstim_nwb_4_to_capsule_aind_licks_rewards_nwb_6_5

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=b6908082-5b36-4e64-91d2-1b960d93a31d
	export CO_CPUS=4
	export CO_MEMORY=32212254720

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v3.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-6731893.git" capsule-repo
	else
		git clone --branch v3.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-6731893.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_stimulus_camstim_nwb_4_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-ophys-camstim-behavior-qc
process capsule_aind_ophys_camstim_behavior_qc_5 {
	tag 'capsule-2806581'
	container "$REGISTRY_HOST/published/b8993607-57ed-4cbe-8b18-a0523228410f:v1"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/ophys' from ophys_mount_to_aind_ophys_camstim_behavior_qc_4.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=b8993607-57ed-4cbe-8b18-a0523228410f
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-2806581.git" capsule-repo
	else
		git clone --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-2806581.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-licks-rewards-nwb
process capsule_aind_licks_rewards_nwb_6 {
	tag 'capsule-3770822'
	container "$REGISTRY_HOST/published/a1a6795a-6f4c-4311-87f8-53e93bc90fb5:v1"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/nwb/' from capsule_aind_stimulus_camstim_nwb_4_to_capsule_aind_licks_rewards_nwb_6_5.collect()
	path 'capsule/data/session' from ophys_mount_to_aind_licks_rewards_nwb_6.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=a1a6795a-6f4c-4311-87f8-53e93bc90fb5
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3770822.git" capsule-repo
	else
		git clone --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3770822.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_licks_rewards_nwb_6_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-pipeline-processing-metadata-aggregator
process capsule_aind_pipeline_processing_metadata_aggregator_7 {
	tag 'capsule-8250608'
	container "$REGISTRY_HOST/published/d51df783-d892-4304-a129-238a9baea72a:v6"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/' from ophys_mount_to_aind_pipeline_processing_metadata_aggregator_7.collect()
	path 'capsule/data/' from capsule_aind_running_speed_nwb_3_to_capsule_aind_pipeline_processing_metadata_aggregator_7_8.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=d51df783-d892-4304-a129-238a9baea72a
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v6.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8250608.git" capsule-repo
	else
		git clone --branch v6.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8250608.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_pipeline_processing_metadata_aggregator_7_args}

	echo "[${task.tag}] completed!"
	"""
}
