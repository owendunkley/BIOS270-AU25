// RNA-seq QC → Trim Galore → Salmon + DESeq2 (from CSV samplesheet)
// Expect a CSV with columns: sample,read1,read2,condition
// No intermediate samples.csv is generated; DESeq2 infers quant.sf paths
// from --outdir/<sample>/salmon_outs/quant.sf
nextflow.enable.dsl=2

include { FASTQC } from './modules/qc/fastqc.nf'
include { TRIMGALORE } from './modules/qc/trimgalore.nf'
include { SALMON } from './modules/pseudoalign/salmon.nf'
include { SALMON_INDEX } from './modules/pseudoalign/salmon_index.nf'
include { DESEQ2 } from './modules/diffexp/deseq2.nf'

// -------------------- Channels --------------------
def samplesheet_ch = Channel
  .fromPath(params.samplesheet)
  .ifEmpty { error "Missing --samplesheet file: ${params.samplesheet}" }

samples_ch = samplesheet_ch.splitCsv(header:true).map { row ->
    tuple(row.sample.trim(), file(row.read1.trim(), absolute: true), file(row.read2.trim(), absolute:true), row.condition.trim())
}


// -------------------- Workflow --------------------

workflow {
    FASTQC(samples_ch)
    trimmed_ch = TRIMGALORE(samples_ch)

    // Check user input of index or transcriptome file
    if (params.index) {
        // If index is provided, use it directly
        quant_ch = SALMON(trimmed_ch, params.index)
    } else if (params.transcriptome) {
        // If index is not provided, create the index using the provided transcriptome file
        salmon_index_ch = SALMON_INDEX(params.transcriptome)
        quant_ch = SALMON(trimmed_ch, salmon_index_ch)
    } else {
        error "You must provide either a transcriptome file (params.transcriptome) or a pre-built index (params.index)."
    }

    if( params.run_deseq ) {
        // Collect all Salmon outputs into a map {sample: quant_path}

        quant_paths_ch = quant_ch
            .map { sample, quant, cond -> "${sample},${quant}" }
            .collectFile(
                name: "quant_paths.csv", 
                newLine: true, 
                seed: "sample,quant_path"  // This adds the header as the first line
            )
        DESEQ2(quant_paths_ch, samplesheet_ch)
    }
}
workflow.onComplete {
    log.info "Pipeline finished. Results in: ${params.outdir}"
}