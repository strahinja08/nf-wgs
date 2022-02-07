nextflow.enable.dsl=2

//
// TODO: fastqc_version.yml
// TODO: use metamap
//

// TODO: use Fastqc result html insetead (?)
include { MULTIQC } from '../MultiQC/multiqc.nf'

process FASTQC {
    tag "FASTQC on $sample_id, SingleEnd: $single_end"

    input:
    // tuple val(id), val(single_end)
    tuple val(sample_id), path(reads)
    

    output:
    path "fastqc_${sample_id}_logs", emit: fastqc

    script:
    """
    mkdir fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads}
    """
}

process FASTQC_VERSION {
    tag "FASTQC version"
    publishDir $params.outdir 

    output:
    path "fastqc_version.yml", emit: fastqc_version

    script:
    """
    echo "---" > fasta_version.yaml && \    
    fa=$(echo "  FastQC:") && \
    ver=$(fastqc --version | grep -Po "v.*") &&\
    echo $fa$ver >> fasta_version.yaml
    """
}

workflow test_fastqc_single_end {
    input = [ 
                [ id:'test', single_end:true ], // meta map
                [ file(params.test_data['test_dna_ercc_1.fq.gz'], checkIfExists: true) ]
            ]
    
    FASTQC_VERSION
    FASTQC ( input )
}

workflow {
    input = [ 
                [id: 'test', single_end: false], // meta map
                [ 
                    file(params.test_data['test_dna_ercc_1.fq.gz'], checkIfExists: true),
                    file(params.test_data['test_dna_ercc_2.fq.gz'], checkIfExists: true) 
                ]
            ]

    FASTQC_VERSION
    FASTQC ( input )

    MULTIQC ( FASTQC.out.collect() )
}

workflow.onComplete {
    log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : null)
}

workflow.onError {
    log.info "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}