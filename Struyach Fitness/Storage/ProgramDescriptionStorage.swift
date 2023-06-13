//
//  ProgramDescriptionStorage.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation

struct ProgramDescriptionStorage {
  static let programArray = [
    ProgramDescription(programName: K.bodyweight,
                       cellImage: "bodyweight"),
    ProgramDescription(programName: K.ecd,
                       cellImage: "camp1"),
    ProgramDescription(programName: K.struyach,
                       cellImage: "struyach"),
    ProgramDescription(programName: K.pelvicPower,
                       cellImage: "pistols"),
    ProgramDescription(programName: K.bellyBurner,
                       cellImage: "hardpress")
   ]
}
