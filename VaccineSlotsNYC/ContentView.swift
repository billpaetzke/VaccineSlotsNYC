//
//  ContentView.swift
//  VaccineSlotsNYC
//
//  Created by Bill Paetzke on 2/12/21.
//

import SwiftUI
import UserNotifications
import AVFoundation
import SwiftSMTP

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var isAvailable = false
    @State var isRunning = false
    @State var isNycVaccineListAvailable = false
    @State var isTurboVaxAvailable = false
    @State var isNYSListAvailable = false
    @State var isNYCVaccineHubAvailable = false
    
    var body: some View {
        
        VStack {
            
            Text("TurboVax: \(String(isTurboVaxAvailable))")
            
            Text("NycVaccineList: \(String(isNycVaccineListAvailable))")
            
            Text("NYSList: \(String(isNYSListAvailable))")
            
            Text("NYCVaccineHub: \(String(isNYCVaccineHubAvailable))")
            
            Button(isRunning ? "Stop Timer" : "Run Timer") {
                isRunning.toggle()
                
                if isRunning {
                    
                    checkTurboVax()
                    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                        if !isRunning {
                            timer.invalidate()
                        }
                        checkTurboVax()
                    }
                    
                    checkNycVaccineList()
                    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                        if !isRunning {
                            timer.invalidate()
                        }
                        checkNycVaccineList()
                    }
                    
                    checkNYSList()
                    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                        if !isRunning {
                            timer.invalidate()
                        }
                        checkNYSList()
                    }
                    
                    checkNYCVaccineHub()
                    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                        if !isRunning {
                            timer.invalidate()
                        }
                        checkNYCVaccineHub()
                    }
                }
            }
            
        }
        .onChange(of: isAvailable, perform: { value in
            if value == true {
                //print("True at \(Date())")
                //var alarmNumber = 0
                
                 Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { alarmTimer in
                     AudioServicesPlaySystemSound(1026)
                     //alarmNumber += 1
                     
                     if !isAvailable || !isRunning {
                         alarmTimer.invalidate()
                     }
                 }
                
                let smtp = SMTP(
                    hostname: "smtp.gmail.com",     // SMTP server address
                    email: "billpaetzke@gmail.com",        // username to login
                    password: "paranoid-pants-84"            // password to login
                )
                
                let fromUser = Mail.User(name: "Bill Paetzke", email: "billpaetzke@gmail.com")
                let toUser = Mail.User(name: "Bill Paetzke", email: "billpaetzke@icloud.com")

                let mail = Mail(
                    from: fromUser,
                    to: [toUser],
                    subject: "An appointment is available",
                    text: "\(isTurboVaxAvailable ? "https://turbovax.info" : "") \(isNycVaccineListAvailable ? "https://nycvaccinelist.com/?includeDose=unspecified" : "") \(isNYSListAvailable ? "https://am-i-eligible.covid19vaccine.health.ny.gov" : "") \(isNYCVaccineHubAvailable ? "https://vax4nyc.nyc.gov/patient/s/vaccination-schedule" : "")"
                )

                smtp.send(mail) { (error) in
                    if let error = error {
                        print(error)
                    }
                }
                
            }
            else {
                print("Unavailable at \(Date())")
            }
        })
        .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                } else if newPhase == .background {
                    print("Background")
                    let content = UNMutableNotificationContent()
                    content.title = "Feed the cat"
                    content.subtitle = "It looks hungry"
                    content.sound = UNNotificationSound.default

                    // show this notification X seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: true)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
            }
        
    }
    
    func checkTurboVax() {
        print("TurboVax: \(Date())")
        let url = URL(string: "https://spreadsheets.google.com/feeds/cells/10l-N3bDVpJPH5IWc3Jak2jzWr0BRNax65jjxzAo_tLs/5/public/full?alt=json")!
        //let pattern = #"\\"is_available\\": true[^}]*(Manhattan|Queens|Brooklyn)"#
        let pattern = #"\\"is_available\\": true, \\"portal_name\\": \\"(NYC Vaccine Hub|NYS Department of Health)\\"[^}]*(Manhattan|Queens|Brooklyn|Long Island)"#
        self.fetch(url, for: pattern)
    }
    
    func checkNycVaccineList() {
        print("NycVaccineList: \(Date())")
        let url = URL(string: "https://admin.nycvaccinelist.com/api/locations")!
        /*let pattern = #"(address[^\/]*(11213|11216|11233|11238|11209|11214|11228|11204|11218|11219|11230|11234|11236|11239|11223|11224|11229|11235|11201|11205|11215|11217|11231|11203|11210|11225|11226|11211|11222|11206|11221|11237|10026|10027|10030|10037|10039|10001|10011|10018|10019|10020|10036|10029|10035|10010|10016|10017|10022|10012|10013|10014|10004|10005|10006|10007|10038|10280|10002|10003|10009|10021|10028|10044|10065|10075|10128|10023|10024|10025|11361|11362|11363|11364|11354|11355|11356|11357|11358|11359|11360|11365|11366|11367|11412|11423|11432|11433|11434|11435|11436|11101|11102|11103|11104|11105|11106|11374|11375|11379|11385|11004|11005|11411|11413|11422|11426|11427|11428|11429|11414|11415|11416|11417|11418|11419|11420|11421|11368|11369|11370|11372|11373|11377|11378|11793|11794)[^\/]*"is_stale":false[^\/]*total_available":[^0][\d]*)|(address":\[\][^\/]*"is_stale":false[^\/]*(Manhattan|Brooklyn|Queens)[^\/]*total_available":[^0][\d]*)"#*/
        let pattern = #"(address[^\/]+is_stale":false[^\/]+name":"(Javits|Aqueduct|Jones Beach|SUNY Stony Brook)[^\/]+total_available":([^01234][\d]|[^0][\d][\d]+)[^\}]+\})|(address[^\/]+is_stale":false[^\/]+name":"(Aviation|Marta|George Westinghouse|Bushwick)[^\/]+total_available":[^0][^\}]+\})"#
        self.fetch(url, for: pattern)
    }
    
    func checkNYSList() {
        print("NYSList: \(Date())")
        
        let url = URL(string: "https://am-i-eligible.covid19vaccine.health.ny.gov/api/list-providers")!
        let pattern = #"(New York|South Ozone Park|Wantagh|Stony Brook), NY","availableAppointments":"AA""#
        self.fetch(url, for: pattern)
    }
    
    func checkNYCVaccineHub() {
        print("NYCVaccineHub: \(Date())")
        
        //let url = URL(string: "https://vax4nyc.nyc.gov/patient/s/")!
        //let pattern = #"waiting room"#
        let url = URL(string: "https://vax4nyc.nyc.gov/patient/s/sfsites/aura?r=11&aura.ApexAction.execute=1")!
        let pattern = #"lstMainWrapper":\[[^\]]+\]"#//#"lstDataWrapper":\[[^\]]+(Marta Valle|Aviation|George Westinghouse|Bushwick Educational)[^\]]+\]"#
        self.fetch(url, for: pattern)
    }
    
    func fetch(_ url: URL, for pattern: String) {
        
        if url.absoluteString.contains("nyc.gov") { // start complex fetch
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.addValue("*/*", forHTTPHeaderField: "Accept")
            request.addValue("en-us", forHTTPHeaderField: "Accept-Language")
            request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("vax4nyc.nyc.gov", forHTTPHeaderField: "Host")
            request.addValue("https://vax4nyc.nyc.gov", forHTTPHeaderField: "Origin")
            request.addValue("User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            request.addValue("https://vax4nyc.nyc.gov/patient/s/vaccination-schedule", forHTTPHeaderField: "Referer")
            request.addValue("keep-alive", forHTTPHeaderField: "Connection")
            request.addValue("akavpau_vax4nyc=1613610447~id=c1d1a994c56c496c789d57de6a182dd1; force-stream=!tEMciscBFGezRYHV65k3d0afM5g6WBAdPcDCz88KIdfPfmJG7uUTMa78Fs+N/EbYPzSCVpR0lLe5LQ==; pctrk=1b562dd9-329f-4c84-88b6-e48ef0360cce; WT_FPC=id=74a09a1e-9aae-45af-9366-45b2002327f8:lv=1613279301424:ss=1613279287418", forHTTPHeaderField: "Cookie")
            //request.addValue("X-SFDC-Request-Id", forHTTPHeaderField: "884282500000098d36")
            //request.addValue("X-SFDC-Page-Scope-Id", forHTTPHeaderField: "5e58f0d9-e9d0-4ec1-9d5d-dbdb68c254bb")
            request.httpBody = "message=%7B%22actions%22%3A%5B%7B%22id%22%3A%2290%3Ba%22%2C%22descriptor%22%3A%22aura%3A%2F%2FApexActionController%2FACTION%24execute%22%2C%22callingDescriptor%22%3A%22UNKNOWN%22%2C%22params%22%3A%7B%22namespace%22%3A%22%22%2C%22classname%22%3A%22VCMS_BookAppointmentCtrl%22%2C%22method%22%3A%22fetchDataWrapper%22%2C%22params%22%3A%7B%22isOnPageLoad%22%3Afalse%2C%22scheduleDate%22%3A%222021-02-26%22%2C%22zipCode%22%3A%2211101%22%2C%22isSecondDose%22%3Afalse%2C%22vaccineName%22%3A%22%22%2C%22isReschedule%22%3Afalse%2C%22programId%22%3Anull%2C%22isClinicPortal%22%3Afalse%7D%2C%22cacheable%22%3Afalse%2C%22isContinuation%22%3Afalse%7D%7D%5D%7D&aura.context=%7B%22mode%22%3A%22PROD%22%2C%22fwuid%22%3A%228WYDoRiNKzw4em08r-Gg4A%22%2C%22app%22%3A%22siteforce%3AcommunityApp%22%2C%22loaded%22%3A%7B%22APPLICATION%40markup%3A%2F%2Fsiteforce%3AcommunityApp%22%3A%22fV3Zo7mI3PLrr1VMsCPF3w%22%7D%2C%22dn%22%3A%5B%5D%2C%22globals%22%3A%7B%7D%2C%22uad%22%3Afalse%7D&aura.pageURI=%2Fpatient%2Fs%2Fvaccination-schedule&aura.token=undefined".data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                }
                else if let data = data {
                    // decode and print
                    let html = String(decoding: data, as: UTF8.self)
                    
                    if html.range(of: pattern, options: .regularExpression) != nil
                    {
                        //isNYCVaccineHubAvailable = true
                        print("NYCVaccineHub available at: \(Date()) for anyone")
                        print(html)
                    }
                    else {
                        //isNYCVaccineHubAvailable = false
                    }
                    
                    //isAvailable = isTurboVaxAvailable || isNycVaccineListAvailable || isNYSListAvailable || isNYCVaccineHubAvailable
                }
            }.resume()
            
        } // end complex fetch
        else { // start simple fetch
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    // decode and print
                    let html = String(decoding: data, as: UTF8.self)
                    
                    if html.range(of: pattern, options: .regularExpression) != nil
                    {
                        
                        if (url.absoluteString.contains("google")) {
                            isTurboVaxAvailable = true
                            print("TurboVax available at: \(Date())")
                            print(html)
                        }
                        else if (url.absoluteString.contains("ny.gov")) {
                            isNYSListAvailable = true
                            print("NYSList available at: \(Date())")
                            print(html)
                        }
                        else {
                            
                            let regex = try! NSRegularExpression(pattern: pattern, options: [])
                            let results = regex.matches(in: html, options: [], range: NSRange(html.startIndex..<html.endIndex,
                                                                                in: html))
                            
                            var isActuallyAvailable = false
                            for result in results {

                                for idx in (0..<1/*result.numberOfRanges*/) {
                                    if let capturedRange = Range(result.range(at: idx), in: html) {
                                        let matchedText = html[capturedRange]
                                        //print(matchedText)
                                        if !matchedText.contains("City Employees Only")
                                            && !matchedText.contains("Second Dose")
                                            && !matchedText.contains("NYCHA Seniors Only")
                                            && !matchedText.contains("Brooklyn Residents Only")
                                            && !matchedText.contains("Manhattan Residents Only")
                                            && !matchedText.contains("Drug Store")
                                            && !matchedText.contains("Church")
                                            && !matchedText.contains("Sikh")
                                        {
                                            isActuallyAvailable = true
                                            print("NycVaccineList available at: \(Date())")
                                            print(matchedText)
                                        }
                                    }
                                }
                                
                            }
                            
                            isNycVaccineListAvailable = isActuallyAvailable
                        }
                        
                        isAvailable = isTurboVaxAvailable || isNycVaccineListAvailable || isNYSListAvailable || isNYCVaccineHubAvailable
                    }
                    else {
                        
                        
                        if (url.absoluteString.contains("google")) {
                            isTurboVaxAvailable = false
                        }
                        else if (url.absoluteString.contains("ny.gov")) {
                            isNYSListAvailable = false
                        }
                        else {
                            isNycVaccineListAvailable = false
                        }
                        
                        isAvailable = isTurboVaxAvailable || isNycVaccineListAvailable || isNYSListAvailable || isNYCVaccineHubAvailable
                    }
                }
            }.resume()
            
        } // end simple fetch
        
        
        
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
