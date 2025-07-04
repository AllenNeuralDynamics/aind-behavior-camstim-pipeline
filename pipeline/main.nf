#!/usr/bin/env nextflow
// hash:sha256:4931020c4582dce19d9ee0e98faa682f2b3849f0a583845fe7699a747a1e6eec

nextflow.enable.dsl = 1

params.ophys_mount_url = 's3://aind-open-data/multiplane-ophys_790107_2025-07-01_09-39-45'

ophys_mount_to_nwb_packaging_subject_capsule_1 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_2 = channel.create()
capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_3 = channel.create()

// capsule - NWB-Packaging-Subject-Capsule
process capsule_nwb_packaging_subject_capsule_2 {
	tag 'capsule-8198603'
	container "$REGISTRY_HOST/published/bdc9f09f-0005-4d09-aaf9-7e82abd93f19:v2"

	cpus 1
	memory '7.5 GB'

	input:
	path 'capsule/data' from ophys_mount_to_nwb_packaging_subject_capsule_1.collect()

	output:
	path 'capsule/results/*' into capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_2

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=bdc9f09f-0005-4d09-aaf9-7e82abd93f19
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8198603.git" capsule-repo
	else
		git clone --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8198603.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_nwb_packaging_subject_capsule_2_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-running-speed-nwb
process capsule_aind_running_speed_nwb_3 {
	tag 'capsule-7501486'
	container "$REGISTRY_HOST/published/06b256c7-4869-40ab-82c1-3c74bff19009:v4"

	cpus 1
	memory '7.5 GB'

	input:
	path 'capsule/data/nwb/' from capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_2.collect()

	output:
	path 'capsule/results/*' into capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_3

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=06b256c7-4869-40ab-82c1-3c74bff19009
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v4.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7501486.git" capsule-repo
	else
		git clone --branch v4.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7501486.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code
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
	container "$REGISTRY_HOST/published/b6908082-5b36-4e64-91d2-1b960d93a31d:v2"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/nwb/' from capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_3.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=b6908082-5b36-4e64-91d2-1b960d93a31d
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-6731893.git" capsule-repo
	else
		git clone --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-6731893.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_stimulus_camstim_nwb_4_args}

	echo "[${task.tag}] completed!"
	"""
}
