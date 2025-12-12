process SALMON_INDEX {
    tag "index_${params.transcriptome}"

    input:
      path transcriptome

    output:
      path 'salmon_index'

    script:
      """
      set -euo pipefail
      salmon index -t "${transcriptome}" -i salmon_index
      """
}
