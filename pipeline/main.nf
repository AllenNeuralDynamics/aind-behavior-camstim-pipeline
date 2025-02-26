#!/usr/bin/env nextflow
// hash:sha256:56e2227db759ea8220b009adaa6e2a3d8041f59d139037a08d30bdfa59651f0f

nextflow.enable.dsl = 1

params.multiplane_ophys_775682_2025_02_24_09_13_44_url = 's3://aind-open-data/multiplane-ophys_775682_2025-02-24_09-13-44'

multiplane_ophys_775682_2025_02_24_09_13_44_to_nwb_packaging_subject_capsule_1 = channel.fromPath(params.multiplane_ophys_775682_2025_02_24_09_13_44_url + "/*", type: 'any')
capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_2 = channel.create()
multiplane_ophys_775682_2025_02_24_09_13_44_to_aind_running_speed_nwb_3 = channel.fromPath(params.multiplane_ophys_775682_2025_02_24_09_13_44_url + "/*", type: 'any')

// capsule - NWB-Packaging-Subject-Capsule
process capsule_nwb_packaging_subject_capsule_2 {
	tag 'capsule-8198603'
	container "$REGISTRY_HOST/published/bdc9f09f-0005-4d09-aaf9-7e82abd93f19:v2"

	cpus 1
	memory '8 GB'

	input:
	path 'capsule/data/' from multiplane_ophys_775682_2025_02_24_09_13_44_to_nwb_packaging_subject_capsule_1

	output:
	path 'capsule/results/*' into capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_2

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=bdc9f09f-0005-4d09-aaf9-7e82abd93f19
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8198603.git" capsule-repo
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
	tag 'capsule-0283283'
	container "$REGISTRY_HOST/capsule/14e3df38-c03c-4e40-bb97-b4d80564c214"

	cpus 1
	memory '8 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/' from capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_2
	path 'capsule/data/' from multiplane_ophys_775682_2025_02_24_09_13_44_to_aind_running_speed_nwb_3

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=14e3df38-c03c-4e40-bb97-b4d80564c214
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-0283283.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}
