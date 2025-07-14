#!/usr/bin/env nextflow
// hash:sha256:e620959761dd1b4fce4a25ad0507102496c06a4609120c8a8225da312ddefc33

nextflow.enable.dsl = 1

params.ophys_mount_url = 's3://aind-private-data-prod-o5171v/multiplane-ophys_749315_2024-11-22_14-41-18'

ophys_mount_to_nwb_packaging_subject_capsule_1 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
ophys_mount_to_aind_running_speed_nwb_2 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_3 = channel.create()
ophys_mount_to_aind_stimulus_camstim_nwb_4 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_5 = channel.create()
ophys_mount_to_aind_ophys_camstim_behavior_qc_test_6 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')

// capsule - NWB-Packaging-Subject-Capsule
process capsule_nwb_packaging_subject_capsule_2 {
	tag 'capsule-8198603'
	container "$REGISTRY_HOST/published/bdc9f09f-0005-4d09-aaf9-7e82abd93f19:v2"

	cpus 1
	memory '7.5 GB'

	input:
	path 'capsule/data/ophys_session' from ophys_mount_to_nwb_packaging_subject_capsule_1.collect()

	output:
	path 'capsule/results/*' into capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_3

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
	tag 'capsule-3123019'
	container "$REGISTRY_HOST/capsule/7963f0cb-e861-4a33-978e-d9ced0fa8230:f5bd9659678acae98324541685635563"

	cpus 4
	memory '30 GB'

	input:
	path 'capsule/data/session' from ophys_mount_to_aind_running_speed_nwb_2.collect()
	path 'capsule/data/nwb/' from capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_3.collect()

	output:
	path 'capsule/results/*' into capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_5

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=7963f0cb-e861-4a33-978e-d9ced0fa8230
	export CO_CPUS=4
	export CO_MEMORY=32212254720

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3123019.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3123019.git" capsule-repo
	fi
	git -C capsule-repo checkout e197000d953a1e293318434e2891b6d39ef22a15 --quiet
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
	tag 'capsule-9822388'
	container "$REGISTRY_HOST/capsule/e85387cd-a40e-4b9e-b2b3-5fe11c893fb4:40a52bb25365f8abe450516a45d9a155"

	cpus 4
	memory '30 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/session' from ophys_mount_to_aind_stimulus_camstim_nwb_4.collect()
	path 'capsule/data/nwb/' from capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_5.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=e85387cd-a40e-4b9e-b2b3-5fe11c893fb4
	export CO_CPUS=4
	export CO_MEMORY=32212254720

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9822388.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9822388.git" capsule-repo
	fi
	git -C capsule-repo checkout 20fb768bb28db3f9a0a7b335a84a005bff423fd1 --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_stimulus_camstim_nwb_4_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-ophys-camstim-behavior-qc TEST
process capsule_aind_ophys_camstim_behavior_qc_test_5 {
	tag 'capsule-9367761'
	container "$REGISTRY_HOST/capsule/a7306bbf-3ea1-4f7f-9b97-cd62658604e5:02f429dcb2edd78bdff28f0e02657dc3"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data' from ophys_mount_to_aind_ophys_camstim_behavior_qc_test_6.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=a7306bbf-3ea1-4f7f-9b97-cd62658604e5
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9367761.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9367761.git" capsule-repo
	fi
	git -C capsule-repo checkout 8f2637a71d0b014be9c53f6d15553d685a85939d --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}
