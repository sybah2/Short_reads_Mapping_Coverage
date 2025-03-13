#!/usr/bin/env nextflow

//---------------------------------------
// include the mapping_cov workflow
//---------------------------------------

include { mapping_cov } from  './modules/mapping_cov.nf'


//---------------------------------------------------------------
// Param Checking 
//---------------------------------------------------------------

if(!params.reference) {
    throw new Exception("Missing parameter params.reference")
  }
if(!params.result) {
    throw new Exception("Missing parameter params.result")
  } 

Channel
    .fromPath(params.samples)  
    .splitCsv(header: false)  
    .filter { row -> row.size() > 1 } 
    .map { row -> 
        def sample_name = row[0] 
        def read1 = file(row[1])  
        def read2 = file(row[2])  
        return [sample_name, read1, read2]
    }
    .set { samples }

  
//--------------------------------------
// Process the workflow
//-------------------------------------

workflow {
    mapping_cov(samples)
}