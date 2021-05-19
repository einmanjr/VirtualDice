//
//  ViewController.swift
//  VirtualDice
//
//  Created by Michael Einman on 5/11/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let material = SCNMaterial()
//
//        material.diffuse.contents = UIColor.red
//
//        cube.materials = [material]
//
//        let node = SCNNode()
//
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
//        node.geometry = cube
//
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
        
        
        // Set the scene to the view

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

 
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        print("Session is supported = \(ARConfiguration.isSupported)")
        print("World Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
//      Deprication Devistation
//            let results = sceneview.hitTest(touchLocation, option: nil)
//            if !results.isEmpty {
//                print("touched the plane")
//            } else {
//                print("not good touched")
//            }
            
            let query: ARRaycastQuery? = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)
            guard let nonOptQuery = query else {
                print("Query is nil")
                return
            }
            let results: [ARRaycastResult] = sceneView.session.raycast(nonOptQuery)
            let hitResult = results.first
            if !results.isEmpty {
//                let hitResult = results.first
                print("touched the plane")
                print(touchLocation)
                
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    diceNode.position = SCNVector3(
                        x: hitResult!.worldTransform.columns.3.x,
                        y: hitResult!.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult!.worldTransform.columns.3.z
                    )
                
                            sceneView.scene.rootNode.addChildNode(diceNode)
                        } else {
                            fatalError("Error in getting diceNode to get onto the scene")
                        }
                
                
            } else {
                print("Not good touch")
            }
            for result in results {
                print(result)
            }
        }
    }
    
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            
            print("plane detected")
        } else {
            return
        }
    }
 
}
