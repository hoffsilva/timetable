//
//  DI.swift
//  timetable
//
//  Created by Hoff Silva on 24/11/21.
//

import Resolver

extension Resolver: ResolverRegistering {
    
    public static func registerAllServices() {
        registerCoordinators()
        registerViews()
        registerViewModels()
        registerUseCases()
    }
    
}

extension Resolver {
    
    public static func registerCoordinators() {
        
        register { _, args in
            AppCoordinator(window: args())
        }
        .scope(.application)
        .implements(Coordinator.self)
        
        register { _, args in
            EventListViewCoordinator(window: args("window"))
        }
        .scope(.application)
        .implements(Coordinator.self)
        
    }
    
    public static func registerViews() {
        
        register {
            EventListViewController()
        }
        .scope(.application)
        
        register {
            CustomLaunchScreen()
        }
        .scope(.application)
        
        register { _, args in
            ErrorViewController()
        }
        .scope(.application)
        
    }
    
    public static func registerViewModels() {
        register {
            EventViewModel()
        }
        .scope(.application)
        
        register { _, args in
            ErrorViewModel(errorMessage: args.get("errorMessage"), allowCalendarAccess: args.get("allowCalendarAccess"))
        }
        .scope(.application)
    }
    
    public static func registerUseCases() {
        
        register {
            GetEventsUseCaseImp()
        }
        .scope(.application)
        .implements(GetEventsUseCase.self)
        
    }
    
}
