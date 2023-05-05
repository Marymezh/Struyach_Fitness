//
//  ProgramDescription.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation

struct ProgramDescription {
    let programName: String
    let programDetail: String
    let cellImage: String
    
    init(programName: String, programDetail: String, cellImage: String) {
         self.programName = programName
         self.programDetail = programDetail
         self.cellImage = cellImage
     }

}
