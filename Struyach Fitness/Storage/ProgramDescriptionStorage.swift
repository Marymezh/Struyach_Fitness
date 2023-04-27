//
//  ProgramDescriptionStorage.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import Foundation

struct ProgramDescriptionStorage {
   static let programArray = [
    ProgramDescription(programName: K.bodyweight, programDetail: "Get fit and toned with our Bodyweight Training Plan - no equipment needed, perfect for on-the-go workouts!", cellImage: "bodyweight"),
    ProgramDescription(programName: K.ecd, programDetail: "Transform your body with our ECD Plan - designed for gym or CrossFit box training!", cellImage: "general"),
    ProgramDescription(programName: K.struyach, programDetail: "Take your training to the next level with our Struyach Plan - designed specifically for experienced athletes.", cellImage: "struyach"),
    ProgramDescription(programName: K.pelvicPower, programDetail: "Tone and strengthen your pelvic muscles with our 10 high-intensity workouts.", cellImage: "badass"),
    ProgramDescription(programName: K.bellyBurner, programDetail: "Get rid of stubborn belly fat and achieve a leaner, fitter body with our 10 high-intensity workouts.", cellImage: "hardpress")
   ]
}

