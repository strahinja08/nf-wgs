nextflow.enable.dsl=2

log.info """\
         W G S - N F   P I P E L I N E    
         ===================================
         reads              : ${params.reads}
         multiqc            : ${params.outmultiqc}
         outdir             : ${params.outdir}
         reference_genome   : ${params.reference_genome}
         """
         .stripIndent()

// include { FASTQC } from './modules/fastqc/fastqc.nf'
include { BWA } from './modules/bwa/bwa.nf'
// include { BWA_MEM } from './modules/bwa/bwa.nf'
// include { MARKDUPLICATES } from './modules/bwa/bwa.nf'
// include { BASERECALIBRATOR } from './modules/bwa/bwa.nf'
// include { SAMTOOLS_REPORT } from 'modules/samtools/samtools.nf'
// include { QUALIMAP } from 'modules/qualimap/qualimap.nf'
// include { HAPOLOTYPER } from 'modules/haplotyper/haplotyper.nf'
include { MULTIQC } from './modules/multiqc/multiqc.nf'

// unnamed 
workflow { 
    // channel
    // .fromFilePairs( params.reads, checkIfExists: true )
    // .set { read_pairs_ch }
    // fastqc_ch = FASTQC( read_pairs_ch )

    // TODO: Create index files
    channel.fromPath(params.reference_genome).set{ data }
    BWA(data)
    // TODO: bwa x3 processes
    // bwa_ch = BWA( fastqc_ch )
    // markduplicates_ch = MARKDUPLICATES( bwa_ch )
    // baserecalibrator_ch = BASERECALIBRATOR( markduplicates_ch )
    // TODO: samtools
    
    // TODO: qualimap

    // TODO: haplotyper

    // TODO: ...

    // MULTIQC(fastqc_ch.mix(baserecalibrator_ch))
}

// TODO: named 
// workflow EXAMPLE {
//   take:
//     transcriptome
//     read_pairs_ch

//   main:
//     INDEX( transcriptome )
//     QUANT( INDEX.out, read_pairs_ch )
//     FASTQC( read_pairs_ch )
//     MULTIQC(
//             QUANT.out.mix(FASTQC.out).collect(),
//             file(params.multiqc) )
// }

workflow.onComplete {
    log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : null)
}

workflow.onError {
    log.info "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}