//
//  BodySkeleton.swift
//  FitBuddy
//
//  Created by Sachin on 2024-02-09.
//

import Foundation
import RealityKit
import ARKit

class BodySkeleton: Entity {
    var bones: [String: Entity] = [:]
    var joints: [String: Entity] = [:]
    required init(for bodyAnchor: ARBodyAnchor) {
        super.init()
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            var jointRadius: Float = 0.05
            var jointColor: UIColor = .blue
            
            switch jointName {
            case "neck_1_joint", "neck 2 joint", "neck_3_joint", "neck_4_joint", "head_joint",
                "left_shoulder_1_joint", "right_ shoulder_1_joint" :
                
                jointRadius *= 0.5
                
            case "chin joint" , "jaw_joint", "left_eye_joint", "left_eyeLowerLid_joint", "left_eyeUpperLid_joint",
                "left_eyeball_joint", "nose_joint", "right_eye_joint","right_eyeLowerLid_joint",
                "right_eyeUpperLid_joint","right_eyeball_joint" :
                
                jointRadius *= 0.2
                jointColor = .yellow
                
            case _ where jointName.hasPrefix("left_hand") || jointName.hasPrefix("right_hand"):
                jointRadius *= 0.25
                jointColor = .yellow
            case _ where jointName.hasPrefix("left_toes") || jointName.hasPrefix("right_toes"):
                jointRadius *= 0.5
                jointColor = .yellow
            case _ where jointName.hasPrefix("spine_"):
                jointRadius *= 0.75
            case "right_hand_joint","left_hand_joint" :
                jointRadius *= 1
                jointColor = .blue
            default:
                jointRadius *= 0.05
                jointColor = .blue
                
            }
            let jointEntity = createJointEntity(radius: jointRadius , color: jointColor)
            joints[jointName] = jointEntity
            self.addChild(jointEntity)
        }
        
        for bone in Bones.allCases {
           guard let skeletonBone = createBone(bone: bone, bodyAnchor: bodyAnchor)
            else {
               continue
           }
            let boneEntity = createBoneEntity(for: skeletonBone)
            bones[bone.name] = boneEntity
            self.addChild(boneEntity)
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func update(with bodyAnchor: ARBodyAnchor){
        
        let originPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            if let jointEntity = joints[jointName],
               let jointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)){
                
                let jointEntityOffsetFromOrigin = simd_make_float3(jointEntityTransform.columns.3)
                jointEntity.position = jointEntityOffsetFromOrigin + originPosition
                jointEntity.orientation = Transform(matrix: jointEntityTransform).rotation
            }
        }
        
        for bone in Bones.allCases {
            
            let boneName = bone.name
            
            guard let entity = bones[boneName],
                  let skeletonBone = createBone(bone: bone, bodyAnchor: bodyAnchor)
            else{
                continue
            }
            
            entity.position = skeletonBone.centerPosition
            entity.look(at: skeletonBone.toJoint.jointPosition, from: skeletonBone.centerPosition, relativeTo: nil)
        }
    }
    
    private func createJointEntity(radius: Float, color: UIColor = .white) -> Entity {
        let jointMesh = MeshResource.generateSphere(radius: radius)
        let jointMaterial = SimpleMaterial(color: color,roughness: 0.7, isMetallic: false)
        let entity = ModelEntity(mesh: jointMesh , materials: [jointMaterial])
        
        return entity
    }
    
    private func createBone(bone: Bones , bodyAnchor : ARBodyAnchor) -> SkeletonBone? {
        guard let fromJointEntityModelTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointFromName)),
              let toJointEntityModelTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointToName))
        else {
            return nil
        }
        
        let originPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        let fromJointEntityOffsetFromOrigin = simd_make_float3(fromJointEntityModelTransform.columns.3)
        let fromJointEntityPosotion = originPosition + fromJointEntityOffsetFromOrigin
        
        let toJointEntityOffsetFromOrigin = simd_make_float3(toJointEntityModelTransform.columns.3)
        let toJointEntityPosotion = originPosition + toJointEntityOffsetFromOrigin
        
        let fromJoint = SkeletonJoint(jointName: bone.jointFromName, jointPosition: fromJointEntityPosotion)
        let toJoint = SkeletonJoint(jointName: bone.jointToName, jointPosition: toJointEntityPosotion)

        return SkeletonBone(fromJoint: fromJoint, toJoint: toJoint)

    }
    
    private func createBoneEntity(for skeletonBone: SkeletonBone, diameter: Float = 0.04, color: UIColor = .white) -> Entity {
        let boneMesh = MeshResource.generateBox(size: [diameter,diameter,skeletonBone.length], cornerRadius: diameter/2)
        let boneMaterial = SimpleMaterial(color: color,roughness: 0.5, isMetallic: false)
        let entity = ModelEntity(mesh: boneMesh , materials: [boneMaterial])
        
        return entity
    }
    
}
