#!/usr/bin/env nextflow
// hash:sha256:1f8b72b430cf5a706c7f02e264be20f70c6bd49bcf11bd021df6447845faf53e

nextflow.enable.dsl = 1

params.ophys_mount_url = 's3://aind-private-data-prod-o5171v/multiplane-ophys_770966_2025-05-14_12-14-46'

ophys_mount_to_nwb_packaging_subject_capsule_1 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
ophys_mount_to_aind_running_speed_nwb_2 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_nwb_packaging_subject_capsule_2_to_capsule_aind_running_speed_nwb_3_3 = channel.create()
ophys_mount_to_aind_stimulus_camstim_nwb_4 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_5 = channel.create()
ophys_mount_to_aind_ophys_camstim_behavior_qc_6 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_aind_stimulus_camstim_nwb_4_to_capsule_aind_licks_rewards_nwb_6_7 = channel.create()
ophys_mount_to_aind_licks_rewards_nwb_8 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')

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
	tag 'capsule-4510069'
	container "$REGISTRY_HOST/capsule/6b0aa5c9-bc08-46c6-8d16-712d706eb966:40a52bb25365f8abe450516a45d9a155"

	cpus 4
	memory '30 GB'

	input:
	path 'capsule/data/session' from ophys_mount_to_aind_stimulus_camstim_nwb_4.collect()
	path 'capsule/data/nwb/' from capsule_aind_running_speed_nwb_3_to_capsule_aind_stimulus_camstim_nwb_4_5.collect()

	output:
	path 'capsule/results/*' into capsule_aind_stimulus_camstim_nwb_4_to_capsule_aind_licks_rewards_nwb_6_7

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=6b0aa5c9-bc08-46c6-8d16-712d706eb966
	export CO_CPUS=4
	export CO_MEMORY=32212254720

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-4510069.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-4510069.git" capsule-repo
	fi
	git -C capsule-repo checkout 2ba077986f7558ce617b2a12ca5b483dc6cac42c --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_stimulus_camstim_nwb_4_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-ophys-camstim-behavior-qc
process capsule_aind_ophys_camstim_behavior_qc_test_5 {
	tag 'capsule-9367761'
	container "$REGISTRY_HOST/capsule/a7306bbf-3ea1-4f7f-9b97-cd62658604e5:02f429dcb2edd78bdff28f0e02657dc3"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data' from ophys_mount_to_aind_ophys_camstim_behavior_qc_6.collect()

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
	git -C capsule-repo checkout f2878b6ba67211e140638f21da75bfd24218a435 --quiet
	mv capsule-repo/code capsule/code
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
	tag 'capsule-0086166'
	container "$REGISTRY_HOST/capsule/65a959cd-4190-4998-bbfd-9eb812974c1d:f516778900cffc836efec014c625cdf7"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/nwb/' from capsule_aind_stimulus_camstim_nwb_4_to_capsule_aind_licks_rewards_nwb_6_7.collect()
	path 'capsule/data/session' from ophys_mount_to_aind_licks_rewards_nwb_8.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=65a959cd-4190-4998-bbfd-9eb812974c1d
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-0086166.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-0086166.git" capsule-repo
	fi
	git -C capsule-repo checkout 0ee74a7072c44f42ffd42254a2283bea314a279f --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_licks_rewards_nwb_6_args}

	echo "[${task.tag}] completed!"
	"""
}
