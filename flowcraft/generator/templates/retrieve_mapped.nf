process retrieve_mapped_{{ pid }} {

    // Send POST request to platform
    {% include "post.txt" ignore missing %}

    tag { sample_id }

    input:
    set sample_id, file(bam) from {{ input_channel }}

    output:
    set sample_id , file("*_mapped_*.fq") into OUT_retrieve_mapped_{{ pid }}
    {% with task_name="retrieve_mapped" %}
    {%- include "compiler_channels.txt" ignore missing -%}
    {% endwith %}

    script:
    """
    samtools view -buh -F 12 -o ${sample_id}_samtools.bam -@ $task.cpus ${bam}

    rm ${bam}

    samtools fastq -1 ${sample_id}_mapped_1.fq -2 ${sample_id}_mapped_2.fq ${sample_id}_samtools.bam

    rm ${sample_id}_samtools.bam

    """
}

process renamePE_{{ pid }} {

    tag { sample_id }
    publishDir 'results/mapping/retrieve_mapped_{{ pid }}/'

    input:
    set sample_if, file(fastq_pair} from OUT_retrieve_mapped_{{ pid }}

    output:
    set sample_id , file("*.headersRenamed_*.fq.gz") into {{ output_channel }}
    {% with task_name="renamePE" %}
    {%- include "compiler_channels.txt" ignore missing -%}
    {% endwith %}

    script:
    template "renamePE_samtoolsFASTQ.py"

}

{{ forks }}