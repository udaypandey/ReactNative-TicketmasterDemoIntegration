//
//  PrePurchaseSdkViewController.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Daniel Olugbade on 24/08/2023.
//

import TicketmasterAuthentication
import TicketmasterTickets
import TicketmasterDiscoveryAPI
import TicketmasterPrePurchase
import TicketmasterPurchase

class PrePurchaseSdkViewController: UIViewController, TMPrePurchaseNavigationDelegate, SendAttractionIdDelegate {
  var attractionId: String = "attractionId"
  
  func prePurchaseViewController(_ viewController: TicketmasterPrePurchase.TMPrePurchaseViewController, navigateToEventDetailsPageWithIdentifier eventIdentifier: String) {
    let configuration = TMPurchaseWebsiteConfiguration(eventID: eventIdentifier)
    let apiKey = RNCConfig.env(for: "API_KEY") ?? ""
    TMPurchase.shared.configure(apiKey: apiKey, completion: {isPurchaseApiSet in
      TMDiscoveryAPI.shared.configure(apiKey: apiKey, completion: { isDiscoveryApiSet in
        if (isDiscoveryApiSet && isPurchaseApiSet) {
          let purchaseNavController = TMPurchaseNavigationController(configuration: configuration)
          viewController.present(purchaseNavController, animated: true, completion: nil)
        }
      })
    })
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let customView = PrePurchaseView()
    customView.delegate = self
    self.view = customView
    
    print("PrePurchaseSdkViewController viewDidLoad")
    let apiKey = RNCConfig.env(for: "API_KEY") ?? ""
    let tmxServiceSettings = TMAuthentication.TMXSettings(apiKey: apiKey,
                                                          region: .US)
    
    let branding = TMAuthentication.Branding(displayName: "My Team",
                                             backgroundColor: .init(hexString: "#026cdf"),
                                             theme: .light)
    
    let brandedServiceSettings = TMAuthentication.BrandedServiceSettings(tmxSettings: tmxServiceSettings,
                                                                         branding: branding)
    
    TMPrePurchase.shared.configure(apiKey: apiKey, completion: { isPrePurchaseApiSet in
      print("PrePurchase api key set result: \(isPrePurchaseApiSet)")
      TMDiscoveryAPI.shared.configure(apiKey: apiKey, completion: { isDiscoveryApiSet in
        print("Discovery api key set result: \(isDiscoveryApiSet)")
        TMPrePurchase.shared.brandColor = UIColor(red: 0.19, green: 0.02, blue: 0.16, alpha: 1.00)
        
        // configure TMAuthentication with Settings and Branding
        print("Authentication SDK Configuring...")
        TMAuthentication.shared.configure(brandedServiceSettings: brandedServiceSettings) {
          backendsConfigured in
          
          // your API key may contain configurations for multiple backend services
          // the details are not needed for most common use-cases
          print(" - Authentication SDK Configured: \(backendsConfigured.count)")
          
          
         
          
          // TMTickets inherits it's configuration and branding from TMAuthentication
          print("Tickets SDK Configuring...")
          TMTickets.shared.configure {
            
            // Tickets is configured, now we are ready to present TMTicketsViewController or TMTicketsView
            print(" - Tickets SDK Configured")
            
            customView.getAttractionId()
            let viewController = TMPrePurchaseViewController.attractionDetailsViewController(attractionIdentifier: self.attractionId, enclosingEnvironment: .modalPresentation)
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
            
            
          } failure: { error in
            // something went wrong, probably TMAuthentication was not configured correctly
            print(" - Tickets SDK Configuration Error: \(error.localizedDescription)")
          }
          
          
          
        } failure: { error in
          // something went wrong, probably the wrong apiKey+region combination
          print(" - Authentication SDK Configuration Error: \(error.localizedDescription)")
        }
      })
    })
  }
  
  func sendAttractionIdFromView(attractionIdProp: String) {
    print("Received data in UIViewController: \(attractionIdProp)")
    attractionId = attractionIdProp
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("PrePurchaseSdkViewController viewDidAppear")
   
  }
  
}
