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
            EventListView()
        }
        
        register {
            CustomLaunchScreen()
        }
        
    }
    
    public static func registerViewModels() {
        register {
            EventViewModel()
        }
    }
    
    public static func registerUseCases() {
        
        register {
            GetEventsUseCaseImp()
        }
        .implements(GetEventsUseCase.self)
        
    }
    
}