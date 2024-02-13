//
//  SkeletonBone.swift
//  FitBuddy
//
//  Created by Sachin on 2024-02-05.
//

import Foundation
import RealityKit

struct SkeletonBone {
    var fromJoint: SkeletonJoint
    var toJoint: SkeletonJoint
    
    var centerPosition: SIMD3<Float>{
        [(fromJoint.jointPosition.x + toJoint.jointPosition.x)/2,(fromJoint.jointPosition.y + toJoint.jointPosition.y)/2,(fromJoint.jointPosition.z + toJoint.jointPosition.z)/2]
    }
    
    var length:Float {
        simd_distance(fromJoint.jointPosition, toJoint.jointPosition)
    }
}


