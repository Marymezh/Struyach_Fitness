//
//  ProgramDescriptionStorage.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation

struct ProgramDescriptionStorage {
  static let programArray = [
    ProgramDescription(programEngID: K.bodyweight,
                       cellImage: "bodyweight"),
    ProgramDescription(programEngID: K.ecd,
                       cellImage: "camp1"),
    ProgramDescription(programEngID: K.struyach,
                       cellImage: "struyach"),
    ProgramDescription(programEngID: K.pelvicPower,
                       cellImage: "pistols"),
    ProgramDescription(programEngID: K.bellyBurner,
                       cellImage: "hardpress")
   ]
}
