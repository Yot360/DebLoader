//
//  ContentView.swift
//  DebLoader
//
//  Created by Eliott on 08/01/2022.
//

import SwiftUI

enum ActiveAlert {
    case first, second
}

struct ContentView: View {
    
    @State private var bid: String = ""
    @State private var packageURL: String = ""
    @State var log: String = "Hello log"
    
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .first
    
    fileprivate func installedPackages() -> Data {
        let task = NSTask()
        task.setLaunchPath("/bin/sh")
        task.setArguments(["-c","dpkg -l"])
        let pipe = Pipe()
        task.setStandardOutput(pipe)
        task.launch()
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
    
    var body: some View {
        
        ZStack{
            VStack(alignment: .leading, spacing: 0){
                Text("DebLoader")
                    .font(.title)
                    .bold()
                    .padding(.top, 50.0)
                Spacer()
            }
            VStack(alignment: .center){
                Text("Enter tweak's bundle identifier below to download it")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20.0)
                    .padding()
                TextField("Bundle ID, ex: com.yot.ioslanplay", text: $bid)
                    .padding()
                    .multilineTextAlignment(.leading)
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 1.2)))
                    .padding()
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                var timesRunned = 0
                Button(action: {
                    
                    var executeCommandProcess: NSTask!
                    
                    
                    DispatchQueue.global().async {
                        
                        if(timesRunned > 1){
                            timesRunned = 0
                        }
                        
                        executeCommandProcess = NSTask()
                        let pipe = Pipe()
                        
                        executeCommandProcess.setLaunchPath("/usr/bin/apt-get")
                        executeCommandProcess.setArguments(["download", "--print-uris", "\(bid)"])
                        // Get error / output
                        executeCommandProcess.setStandardOutput(pipe)
                        var bigOutputString: String = ""
                        
                        pipe.fileHandleForReading.readabilityHandler = { (fileHandle) -> Void in
                            let availableData = fileHandle.availableData
                            let newOutput = String.init(data: availableData, encoding: .utf8)
                            bigOutputString.append(newOutput!)
                            if(newOutput!.contains(".deb")){
                                NSLog("\(newOutput!)")
                                NSLog("PACKAGE FOUND")
                                let outputArr = newOutput?.components(separatedBy: "\'")
                                packageURL = outputArr![1] //Get the url from output
                                NSLog("GOT URL FROM PACKAGE; READY TO DOWNLOAD \n\(packageURL)")
                                
                                //DOWNLOAD PACKAGE WITH PURE SWIFT
                                let url = URL(string: packageURL)
                                let fileName = String((url!.lastPathComponent)) as NSString
                                // Create destination URL
                                let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
                                let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
                                //Create URL to the source file you want to download
                                let fileURL = URL(string: packageURL)
                                let sessionConfig = URLSessionConfiguration.default
                                let session = URLSession(configuration: sessionConfig)
                                let request = URLRequest(url:fileURL!)
                                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                                    if let tempLocalUrl = tempLocalUrl, error == nil {
                                        // Success
                                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                            NSLog("Successfully downloaded. Status code: \(statusCode)")
                                        }
                                        do {
                                            try FileManager.default.copyItem(at: tempLocalUrl, to: URL(fileURLWithPath: "/var/mobile/DebLoader/packages/\(fileName)"))
                                            do {
                                                //Show UIActivityViewController to save the downloaded file
                                                let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                                                for indexx in 0..<contents.count {
                                                    if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                                                        //let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                                        //self.present(activityViewController, animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                            catch (let err) {
                                                NSLog("error: \(err)")
                                            }
                                        } catch (let writeError) {
                                            NSLog("Error creating a file \(destinationFileUrl) : \(writeError)")
                                        }
                                    } else {
                                        NSLog("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
                                    }
                                }
                                task.resume()
                                
                                
                            }else if(timesRunned < 1 && !bid.isEmpty){
                                NSLog("ERROR")
                                self.showAlert.toggle()
                                self.activeAlert = .first
                            }else if(bid.isEmpty){
                                self.showAlert.toggle()
                                self.activeAlert = .second
                            }
                            
                            
                            timesRunned += 1
                        }
                        
                        executeCommandProcess.launch()
                        executeCommandProcess.waitUntilExit()
                        
                        DispatchQueue.main.async {
                            // End of the Process, give feedback to the user.
                        }
                    }
                    
                    
                }) {
                    HStack{
                        Image(systemName: "network")
                        Text("Download package")
                    }
                }
                .padding()
                .foregroundColor(Color.white)
                .background(Color.blue)
                .cornerRadius(15)
                .padding()
                .alert(isPresented: $showAlert) {
                    switch activeAlert {
                    case .first:
                        return Alert(
                            title: Text("Error"),
                            message: Text("Package \(bid) not found.")
                        )
                    case .second:
                        return Alert(
                            title: Text("Error"),
                            message: Text("Enter a package to download.")
                        )
                    }
                }
                
                //Open folder button
                Button(action: {
                    
                    //Check if filza is installed
                    let appName = "filza"
                    let appScheme = "\(appName)://view/var/mobile/DebLoader/packages"
                    let appUrl = URL(string: appScheme)
                    
                    if UIApplication.shared.canOpenURL(appUrl! as URL) {
                        UIApplication.shared.open(appUrl!)
                    } else {
                        NSLog("Filza not installed")
                        self.showAlert.toggle()
                        self.activeAlert = .first
                    }
                    
                }){
                    HStack{
                        Image(systemName: "folder")
                        Text("Open download folder")
                    }
                }
                .padding(.all)
                .foregroundColor(Color.white)
                .background(Color.blue)
                .cornerRadius(15)
                .alert(isPresented: $showAlert) {
                    switch activeAlert {
                    case .first:
                        return Alert(
                            title: Text("Error"),
                            message: Text("App filza is not installed, please install it."),
                            primaryButton: .default(Text("Install from Sileo")){
                                let sileoURL = URL(string: "sileo://package/com.tigisoftware.filza")
                                if UIApplication.shared.canOpenURL(sileoURL! as URL) {
                                    UIApplication.shared.open(sileoURL!)
                                }
                            },
                            secondaryButton: .default(Text("Install from Cydia")){
                                let sileoURL = URL(string: "cydia://package/com.tigisoftware.filza")
                                if UIApplication.shared.canOpenURL(sileoURL! as URL) {
                                    UIApplication.shared.open(sileoURL!)
                                }
                            }
                        )
                    case .second:
                        return Alert(
                            title: Text("Error"),
                            message: Text("Enter a package to download.")
                        )
                    }
                }
                
            }
        }
        .onAppear(perform: MakeDirs)
        
    }
}

func MakeDirs() {
    let docURL = URL(string: "/var/mobile/")!
    let dataPath = docURL.appendingPathComponent("DebLoader/packages")
    if !FileManager.default.fileExists(atPath: dataPath.path) {
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
